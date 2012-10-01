-- Example Design based on genral-cores top example design
-- from OHWR repositories http://www.ohwr.org/projects/general-cores

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.gencores_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dbe_bpm_top is
	port(
		-----------------------------------------
		-- Clocking pins
		-----------------------------------------
		--clk100_i 						: in std_logic;
		sys_clk_p_i						: in std_logic;
		sys_clk_n_i						: in std_logic;

		-----------------------------------------
		-- Button pins
		-----------------------------------------
		buttons_i						: in std_logic_vector(7 downto 0);
		  
		-----------------------------------------
		-- User LEDs
		-----------------------------------------
		leds_o							: out std_logic_vector(7 downto 0)
	);
end dbe_bpm_top;

architecture rtl of dbe_bpm_top is

	-- Simple GPIO interface device
	constant c_xwb_gpio32_sdb : t_sdb_device := (
		abi_class     => x"0000", 				-- undocumented device
		abi_ver_major => x"01",
		abi_ver_minor => x"00",
		wbd_endian    => c_sdb_endian_big,
		wbd_width     => x"7", 					-- 8/16/32-bit port granularity
		sdb_component => (
		addr_first    => x"0000000000000000",
		addr_last     => x"00000000000000FF", 	-- Max of 256 pins. Max of 8 32-bit registers
		product => (
		vendor_id     => x"0000000000000651", 	-- GSI
		device_id     => x"35aa6b95",
		version       => x"00000001",
		date          => x"20120305",
		name          => "GSI_GPIO_32        ")));

	-- Simple IRQ manager interface device
	constant c_xwb_irqmngr_sdb : t_sdb_device := (
		abi_class     => x"0000", 				-- undocumented device
		abi_ver_major => x"01",
		abi_ver_minor => x"00",
		wbd_endian    => c_sdb_endian_big,
		wbd_width     => x"7", 					-- 8/16/32-bit port granularity
		sdb_component => (
		addr_first    => x"0000000000000000",
		addr_last     => x"0000000000000007", 	-- Two 4 byte registers
		product => (
		vendor_id     => x"1000000000001215", 	-- LNLS
		device_id     => x"15ff65e1",		
		version       => x"00000001",
		date          => x"20120903",			-- YY/MM/DD ??
		name          => "LNLS_IRQMNGR       ")));
    
	-- Top crossbar layout
	constant c_slaves 				: natural := 5;			-- LED, Button, Dual-port memory, DMA control port
	constant c_masters 				: natural := 4;			-- LM32 master. Data + Instruction, DMA read+write master
	constant c_dpram_size 			: natural := 16384;     -- in 32-bit words (64KB)

	-- GPIO num pins
	constant c_leds_num_pins 		: natural := 8;
	constant c_buttons_num_pins 	: natural := 8;

	-- Counter width. It willl count up to 2^27 clock cycles
	--constant c_counter_width		: natural := 27;

	-- WB SDB (Self describing bus) layout
	constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
	(0 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size), 	x"00000000"),		-- 64KB RAM
	1 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size), 		x"10000000"),		-- Second port to the same memory
    2 => f_sdb_embed_device(c_xwb_dma_sdb,                  x"20000400")        -- DMA control port
	3 => f_sdb_embed_device(c_xwb_gpio32_sdb,          		x"20000500"),		-- GPIO LED
	4 => f_sdb_embed_device(c_xwb_gpio32_sdb,             	x"20000600"),		-- GPIO Button
	--4 => f_sdb_embed_device(c_xwb_irqmngr_sdb,				x"00100600") 	-- IRQ_MNGR
	);	

	-- Self Describing Bus ROM Address. It is addressed as slave as well.
	constant c_sdb_address 			: t_wishbone_address := x"20000000";

	-- Crossbar master/slave arrays
	signal cbar_slave_i  			: t_wishbone_slave_in_array (c_masters-1 downto 0);
	signal cbar_slave_o  			: t_wishbone_slave_out_array(c_masters-1 downto 0);
	signal cbar_master_i 			: t_wishbone_master_in_array(c_slaves-1 downto 0);
	signal cbar_master_o 			: t_wishbone_master_out_array(c_slaves-1 downto 0);

	-- LM32 signals
	signal clk_sys 					: std_logic;
	signal lm32_interrupt 			: std_logic_vector(31 downto 0);
	signal lm32_rstn 				: std_logic;

	-- Global clock and reset signals
	signal locked 					: std_logic;
	signal clk_sys_rstn 			: std_logic;

	-- Only one clock domain
	signal reset_clks 				: std_logic_vector(0 downto 0);
	signal reset_rstn 				: std_logic_vector(0 downto 0);

	-- Global Clock Single ended
	signal sys_clk_gen				: std_logic;

	-- GPIO LED signals
	signal gpio_slave_led_o 		: t_wishbone_slave_out;
	signal gpio_slave_led_i 		: t_wishbone_slave_in;
	signal s_leds					: std_logic_vector(c_leds_num_pins-1 downto 0);
	-- signal leds_gpio_dummy_in 		: std_logic_vector(c_leds_num_pins-1 downto 0);

	-- GPIO Button signals
	signal gpio_slave_button_o 		: t_wishbone_slave_out;
	signal gpio_slave_button_i 		: t_wishbone_slave_in;

	-- IRQ manager  signals
	--signal gpio_slave_irqmngr_o 	: t_wishbone_slave_out;
	--signal gpio_slave_irqmngr_i 	: t_wishbone_slave_in;

	-- LEDS, button and irq manager signals
	--signal r_leds : std_logic_vector(7 downto 0);
	--signal r_reset : std_logic;

	-- Counter signal
	--signal s_counter				: unsigned(c_counter_width-1 downto 0);
	-- 100MHz period or 1 second
	--constant s_counter_full			: integer := 100000000;
    
    -- Chipscope signals
    signal clk_25mhz                : std_logic;
    signal CONTROL                  : std_logic_vector(35 downto 0);
    signal TRIG0                    : std_logic_vector(31 downto 0);
    signal TRIG1                    : std_logic_vector(31 downto 0);
    signal TRIG2                    : std_logic_vector(31 downto 0);
    signal TRIG3                    : std_logic_vector(31 downto 0);

    ---------------------------
	--      Components       --
    ---------------------------

	-- Clock generation
	component clk_gen is
	port(
		sys_clk_p_i					: in std_logic;
		sys_clk_n_i					: in std_logic;
		sys_clk_o					: out std_logic
	);
	end component;

	-- Xilinx Megafunction
  	component sys_pll is
    port(
		rst_i						: in std_logic  := '0';
		clk_i						: in std_logic  := '0';
		clk0_o						: out std_logic;
		clk1_o						: out std_logic;
		locked_o					: out std_logic 
	);
  	end component;
    
    -- Xilinx Chipscope Controller
    component chipscope_icon
    port (
        CONTROL0                      : inout std_logic_vector(35 downto 0)
    );
    end component;

    -- Xilinx Chipscope Logic Analyser
    component chipscope_ila
    port (
        CONTROL                       : inout std_logic_vector(35 downto 0);
        CLK                           : in    std_logic;
        TRIG0                         : in    std_logic_vector(31 downto 0);
        TRIG1                         : in    std_logic_vector(31 downto 0);
        TRIG2                         : in    std_logic_vector(31 downto 0);
        TRIG3                         : in    std_logic_vector(31 downto 0)
    );
    end component;
begin

	-- Clock generation
	cmp_clk_gen : clk_gen
	port map (
		sys_clk_p_i					=> sys_clk_p_i,
		sys_clk_n_i					=> sys_clk_n_i,
		sys_clk_o					=> sys_clk_gen
	);

	-- Obtain core locking!
	cmp_sys_pll_inst : sys_pll
	port map (
		rst_i						=> '0',
		clk_i						=> sys_clk_gen,
		clk0_o						=> clk_sys,     -- 100MHz locked clock
        clk1_o                      => clk_25mhz,    -- 25MHz locked clock
		locked_o					=> locked		-- '1' when the PLL has locked
	);
  
	-- Reset synchronization. Hold reset line until few locked cycles hava passed 
	cmp_reset : gc_reset
	port map(
		free_clk_i 					=> sys_clk_gen,
		locked_i   					=> locked,
		clks_i     					=> reset_clks,
		rstn_o     					=> reset_rstn
	);

	reset_clks(0) 					<= clk_sys;
	clk_sys_rstn 					<= reset_rstn(0);
  
  -- The top-most Wishbone B.4 crossbar
	cmp_interconnect : xwb_sdb_crossbar
	generic map(
		g_num_masters 				=> c_masters,
		g_num_slaves  				=> c_slaves,
		g_registered  				=> true,
		g_wraparound  				=> false, -- Should be true for nested buses
		g_layout      				=> c_layout,
		g_sdb_addr    				=> c_sdb_address
	)
	port map(
		clk_sys_i     				=> clk_sys,
		rst_n_i       				=> clk_sys_rstn,
		-- Master connections (INTERCON is a slave)
		slave_i       				=> cbar_slave_i,
		slave_o       				=> cbar_slave_o,
		-- Slave connections (INTERCON is a master)
		master_i      				=> cbar_master_i,
		master_o      				=> cbar_master_o
	);
  
	-- The LM32 is master 0+1
	lm32_rstn 						<= clk_sys_rstn;    -- and not r_reset;

	cmp_lm32 : xwb_lm32
	generic map(
		g_profile => "medium_icache_debug"
	) -- Including JTAG and I-cache (no divide)
	port map(
		clk_sys_i 					=> clk_sys,
		rst_n_i   					=> lm32_rstn,
		irq_i     					=> lm32_interrupt,
		dwb_o     					=> cbar_slave_i(0), -- Data bus
		dwb_i     					=> cbar_slave_o(0),
		iwb_o     					=> cbar_slave_i(1), -- Instruction bus
		iwb_i     					=> cbar_slave_o(1)
	);
  
	-- Interrupts 31 downto 1 disabled for now. 
    -- Interrupt '0' is DMA completion.
	lm32_interrupt(31 downto 1) 	<= (others => '0');
    
    -- A DMA controller is master 2+3, slave 2, and interrupt 0
    cmp_dma : xwb_dma
    port map(
        clk_i                       => clk_sys,
        rst_n_i                     => clk_sys_rstn,
        slave_i                     => cbar_master_o(2),
        slave_o                     => cbar_master_i(2),
        r_master_i                  => cbar_slave_o(2),
        r_master_o                  => cbar_slave_i(2),
        w_master_i                  => cbar_slave_o(3),
        w_master_o                  => cbar_slave_i(3),
        interrupt_o                 => lm32_interrupt(0)
    );
  
  	-- Slave 0+1 is the RAM. Load a input file containing a simple led blink program!
	cmp_ram : xwb_dpram
	generic map(
		g_size                  	=> c_dpram_size, -- must agree with sw/target/lm32/ram.ld:LENGTH / 4
		g_init_file             	=> "../../top/ml_605/dbe_bpm/sw/main.ram",
		g_must_have_init_file   	=> true,
		g_slave1_interface_mode 	=> PIPELINED,
		g_slave2_interface_mode 	=> PIPELINED,
		g_slave1_granularity    	=> BYTE,
		g_slave2_granularity    	=> BYTE
    )
	port map(
		clk_sys_i 					=> clk_sys,
		rst_n_i   					=> clk_sys_rstn,
		-- First port connected to the crossbar
		slave1_i  					=> cbar_master_o(0),
		slave1_o  					=> cbar_master_i(0),
		-- Second port connected to the crossbar
		slave2_i  				    => cbar_master_o(1),
		slave2_o  				    => cbar_master_i(1)
		--slave2_i  					=> cc_dummy_slave_in, -- CYC always low
      	--slave2_o  					=> open
	);

	-- Slave 3 is the example LED driver
	cmp_leds : xwb_gpio_port
	generic map(
		--g_interface_mode         	=> CLASSIC;
		g_address_granularity    	=> BYTE,
		g_num_pins 					=> c_leds_num_pins,
		g_with_builtin_tristates 	=> false
	)
	port map(
		clk_sys_i 					=> clk_sys,
		rst_n_i   					=> clk_sys_rstn,

		-- Wishbone
		slave_i 					=> cbar_master_o(3),
		slave_o 					=> cbar_master_i(3),
		desc_o  					=> open,	-- Not implemented

		--gpio_b : inout std_logic_vector(g_num_pins-1 downto 0);

		gpio_out_o 					=> s_leds,
		--gpio_out_o 				=> open,
		gpio_in_i 					=> s_leds,
		gpio_oen_o 					=> open
    );

	--leds_o						<= x"55";
	leds_o							<= s_leds;

	--p_test_leds : process (clk_sys)
	--begin
	--	if rising_edge(clk_sys) then
	--		if clk_sys_rstn = '0' then
	--			s_counter			<= (others => '0');
	--			s_leds				<= x"55";
	--		else
	--			if (s_counter = s_counter_full-1) then
	--				s_counter		<= (others => '0');
	--				s_leds			<= s_leds(c_leds_num_pins-2 downto 0) & s_leds(c_leds_num_pins-1);
	--			else
	--				s_counter		<= s_counter + 1;
	--			end if;
	--		end if;
	--	end if;
	--end process;

	-- Slave 1 is the example LED driver
	--gpio_slave_led_i 				<= cbar_master_o(1);
	--cbar_master_i(1) 				<= gpio_slave_led_o;
	--leds_o 							<= not r_leds;
  
	-- There is a tool called 'wbgen2' which can autogenerate a Wishbone
	-- interface and C header file, but this is a simple example.
	--gpio : process(clk_sys)
	--begin
	--	if rising_edge(clk_sys) then
		-- It is vitally important that for each occurance of
		--   (cyc and stb and not stall) there is (ack or rty or err)
		--   sometime later on the bus.
		--
		-- This is an easy solution for a device that never stalls:
	--	gpio_slave_led_o.ack 		<= gpio_slave_led_i.cyc and gpio_slave_led_i.stb;
      
		-- Detect a write to the register byte
	--	if gpio_slave_led_i.cyc = '1' and gpio_slave_led_i.stb = '1' and
	--		gpio_slave_led_i.we = '1' and gpio_slave_led_i.sel(0) = '1' then
			-- Register 0x0 = LEDs, 0x4 = CPU reset
	--		if gpio_slave_led_i.adr(2) = '0' then
	--			r_leds 				<= gpio_slave_led_i.dat(7 downto 0);
	--		else
	--			r_reset 			<= gpio_slave_led_i.dat(0);
	--		end if;
	--	end if;
      
		-- Read to the register byte
	--	if gpio_slave_led_i.adr(2) = '0' then
	--		gpio_slave_led_o.dat(31 downto 8) <= (others => '0');
	--		gpio_slave_led_o.dat(7 downto 0) <= r_leds;
	--	else
	--		gpio_slave_led_o.dat(31 downto 2) <= (others => '0');
	--		gpio_slave_led_o.dat(0) <= r_reset;
	--	end if;
    --end if;
	--end process;

	--gpio_slave_led_o.int 			<= '0';
	--gpio_slave_led_o.err 			<= '0';
	--gpio_slave_led_o.rty 			<= '0';
	--gpio_slave_led_o.stall 		<= '0'; -- This simple example is always ready

  	-- Slave 4 is the example Button driver
	cmp_buttons : xwb_gpio_port
	generic map(
        --g_interface_mode            => CLASSIC;
		g_address_granularity       => BYTE;
		g_num_pins					=> c_buttons_num_pins,
		g_with_builtin_tristates 	=> false
	)
	port map(
		clk_sys_i 					=> clk_sys,
		rst_n_i   					=> clk_sys_rstn,

		-- Wishbone
		slave_i 					=> cbar_master_o(4),
		slave_o 					=> cbar_master_i(4),
		desc_o  					=> open,	-- Not implemented

		--gpio_b : inout std_logic_vector(g_num_pins-1 downto 0);

		gpio_out_o 					=> open,
		gpio_in_i 					=> buttons_i,
		gpio_oen_o 					=> open
    );
    
    -- Xilinx Chipscope
    cmp_chipscope_icon_1 : chipscope_icon
    port map (
        CONTROL0                    => CONTROL
    );

    cmp_chipscope_ila_1 : chipscope_ila
    port map (
        CONTROL                     => CONTROL,
        CLK                         => clk_25mhz,
        TRIG0                       => TRIG0,
        TRIG1                       => TRIG1,
        TRIG2                       => TRIG2,
        TRIG3                       => TRIG3
    );

    -- DMA Write Master output
    TRIG0                           <= cbar_slave_i(3).dat(31 downto 0);
    -- DMA Read Master input
    TRIG1                           <= cbar_slave_o(2).dat(31 downto 0);
    -- Global reset
    TRIG2(0)                        <= clk_sys_rstn;
    TRIG2(31 downto 1)              <= (others => '0');
    TRIG3(31 downto 0)              <= (others => '0');
   
end rtl;
