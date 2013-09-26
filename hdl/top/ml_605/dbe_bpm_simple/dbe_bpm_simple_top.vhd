-- Simple DBE simple design
-- Created by Lucas Russo <lucas.russo@lnls.br>
-- Date: 11/10/2012

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Memory core generator
use work.gencores_pkg.all;
-- Custom Wishbone Modules
use work.dbe_wishbone_pkg.all;
-- Wishbone stream modules and interface
use work.wb_stream_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dbe_bpm_simple_top is
	port(
    -----------------------------------------
    -- Clocking pins
    -----------------------------------------
    sys_clk_p_i						          : in std_logic;
    sys_clk_n_i						          : in std_logic;
    
    -----------------------------------------
    -- Reset Button
    -----------------------------------------
    sys_rst_button_i                : in std_logic;
    
    -----------------------------------------
    -- FMC150 pins
    -----------------------------------------
    --Clock/Data connection to ADC on FMC150 (ADS62P49)
    adc_clk_ab_p_i                  : in  std_logic;
    adc_clk_ab_n_i                  : in  std_logic;
    adc_cha_p_i                     : in  std_logic_vector(6 downto 0);
    adc_cha_n_i                     : in  std_logic_vector(6 downto 0);
    adc_chb_p_i                     : in  std_logic_vector(6 downto 0);
    adc_chb_n_i                     : in  std_logic_vector(6 downto 0);

    --Clock/Data connection to DAC on FMC150 (DAC3283)
    dac_dclk_p_o                    : out std_logic;
    dac_dclk_n_o                    : out std_logic;
    dac_data_p_o                    : out std_logic_vector(7 downto 0);
    dac_data_n_o                    : out std_logic_vector(7 downto 0);
    dac_frame_p_o                   : out std_logic;
    dac_frame_n_o                   : out std_logic;
    txenable_o                      : out std_logic;
    
    --Clock/Trigger connection to FMC150
    --clk_to_fpga_p_i                 : in  std_logic;
    --clk_to_fpga_n_i                 : in  std_logic;
    --ext_trigger_p_i                 : in  std_logic;
    --ext_trigger_n_i                 : in  std_logic;
          
    -- Control signals from/to FMC150
    --Serial Peripheral Interface (SPI)
    spi_sclk_o                      : out std_logic; -- Shared SPI clock line
    spi_sdata_o                     : out std_logic; -- Shared SPI data line
            
    -- ADC specific signals     
    adc_n_en_o                      : out std_logic; -- SPI chip select
    adc_sdo_i                       : in  std_logic; -- SPI data out
    adc_reset_o                     : out std_logic; -- SPI reset
            
    -- CDCE specific signals        
    cdce_n_en_o                     : out std_logic; -- SPI chip select
    cdce_sdo_i                      : in  std_logic; -- SPI data out
    cdce_n_reset_o                  : out std_logic;
    cdce_n_pd_o                     : out std_logic;
    cdce_ref_en_o                   : out std_logic;
    cdce_pll_status_i               : in  std_logic;
            
    -- DAC specific signals     
    dac_n_en_o                      : out std_logic; -- SPI chip select
    dac_sdo_i                       : in  std_logic; -- SPI data out
              
    -- Monitoring specific signals  
    mon_n_en_o                      : out std_logic; -- SPI chip select
    mon_sdo_i                       : in  std_logic; -- SPI data out
    mon_n_reset_o                   : out std_logic;
    mon_n_int_i                     : in  std_logic;
                  
    --FMC Present status            
    prsnt_m2c_l_i                   : in  std_logic;
    
    -----------------------------------------
    -- UART pins
    -----------------------------------------
    
    uart_txd_o                      : out std_logic;
    uart_rxd_i                      : in std_logic;
    
    -----------------------------------------
    -- Button pins
    -----------------------------------------
    buttons_i						            : in std_logic_vector(7 downto 0);
    
    -----------------------------------------
    -- User LEDs
    -----------------------------------------
    leds_o							            : out std_logic_vector(7 downto 0)
	);
end dbe_bpm_simple_top;

architecture rtl of dbe_bpm_simple_top is
    
	-- Top crossbar layout
  -- Number of slaves
	constant c_slaves 				        : natural := 7;			-- LED, Button, Dual-port memory, UART, DMA control port, FMC150
  -- Number of masters
	constant c_masters 				        : natural := 4;			-- LM32 master. Data + Instruction, DMA read+write master
	--constant c_dpram_size 			      : natural := 16384; -- in 32-bit words (64KB)
  constant c_dpram_size 			      : natural := 22528; -- in 32-bit words (64KB)
  
  -- Number of source/sink Wishbone stream components
  constant c_sinks                  : natural := 1;
  constant c_sources                : natural := c_sinks;

	-- GPIO num pins
	constant c_leds_num_pins 		      : natural := 8;
	constant c_buttons_num_pins 	    : natural := 8;

	-- Counter width. It willl count up to 2^32 clock cycles
	constant c_counter_width		      : natural := 32;
  
  -- Number of reset clock cycles (FF)
  constant c_button_rst_width       : natural := 255;

	-- WB SDB (Self describing bus) layout
	constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
	( 0 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size),  x"00000000"),		-- 64KB RAM
    1 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size),  x"10000000"),		-- Second port to the same memory
    2 => f_sdb_embed_device(c_xwb_dma_sdb,              x"20000400"),   -- DMA control port
    3 => f_sdb_embed_device(c_xwb_fmc150_sdb,           x"20000500"),   -- FMC control port
    4 => f_sdb_embed_device(c_xwb_uart_sdb,             x"20000600"),   -- UART control port
    5 => f_sdb_embed_device(c_xwb_gpio32_sdb,           x"20000700"),		-- GPIO LED
    6 => f_sdb_embed_device(c_xwb_gpio32_sdb,           x"20000800")		-- GPIO Button
    --7 => f_sdb_embed_device(c_xwb_irqmngr_sdb,				  x"20000900") 	  -- IRQ_MNGR
	);	

	-- Self Describing Bus ROM Address. It will be an addressed slave as well.
	constant c_sdb_address 			      : t_wishbone_address := x"20000000";

	-- Crossbar master/slave arrays
	signal cbar_slave_i  			        : t_wishbone_slave_in_array (c_masters-1 downto 0);
	signal cbar_slave_o  			        : t_wishbone_slave_out_array(c_masters-1 downto 0);
	signal cbar_master_i 			        : t_wishbone_master_in_array(c_slaves-1 downto 0);
	signal cbar_master_o 			        : t_wishbone_master_out_array(c_slaves-1 downto 0);
  
  -- Wishbone Stream source/sinks arrays
  signal wbs_src_i                  : t_wbs_source_in_array(c_sources-1 downto 0);
  signal wbs_src_o                  : t_wbs_source_out_array(c_sources-1 downto 0);
  
  -- Check the use of this kind of alias
  alias wbs_sink_i                  is wbs_src_o;
  alias wbs_sink_o                  is wbs_src_i;

	-- LM32 signals
	signal clk_sys 					          : std_logic;
	signal lm32_interrupt 			      : std_logic_vector(31 downto 0);
	signal lm32_rstn 				          : std_logic;

	-- Clocks and resets signals
	signal locked 					          : std_logic;
	signal clk_sys_rstn 			        : std_logic;
  signal clk_adc_rstn 			        : std_logic;
  
  signal rst_button_sys_pp			    : std_logic;
  signal rst_button_adc_pp			    : std_logic;
  
  signal rst_button_sys             : std_logic;
  signal rst_button_adc             : std_logic;
  signal rst_button_sys_n           : std_logic;
  signal rst_button_adc_n           : std_logic;

	-- Only one clock domain
	signal reset_clks 				        : std_logic_vector(1 downto 0);
	signal reset_rstn 				        : std_logic_vector(1 downto 0);
  
  -- 200 Mhz clocck for iodelatctrl
  signal clk_200mhz                 : std_logic;

	-- Global Clock Single ended
	signal sys_clk_gen				        : std_logic;

	-- GPIO LED signals
	signal gpio_slave_led_o 		      : t_wishbone_slave_out;
	signal gpio_slave_led_i 		      : t_wishbone_slave_in;
	signal s_leds					            : std_logic_vector(c_leds_num_pins-1 downto 0);
	-- signal leds_gpio_dummy_in 		: std_logic_vector(c_leds_num_pins-1 downto 0);

	-- GPIO Button signals
	signal gpio_slave_button_o 		    : t_wishbone_slave_out;
	signal gpio_slave_button_i 		    : t_wishbone_slave_in;

	-- IRQ manager  signals
	--signal gpio_slave_irqmngr_o 	: t_wishbone_slave_out;
	--signal gpio_slave_irqmngr_i 	: t_wishbone_slave_in;

	-- LEDS, button and irq manager signals
	--signal r_leds : std_logic_vector(7 downto 0);
	--signal r_reset : std_logic;

	-- Counter signal
	signal s_counter				          : unsigned(c_counter_width-1 downto 0);
	-- 100MHz period or 1 second
	constant s_counter_full			      : integer := 100000000;
  
  -- FMC150 signals
  signal clk_adc                    : std_logic;
    
  -- Chipscope control signals
  signal CONTROL0                   : std_logic_vector(35 downto 0);
  signal CONTROL1                   : std_logic_vector(35 downto 0);
  
  -- Chipscope ILA 0 signals
  signal TRIG_ILA0_0                : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_1                : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_2                : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_3                : std_logic_vector(31 downto 0);
  
  -- Chipscope ILA 1 signals
  signal TRIG_ILA1_0                : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_1                : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_2                : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_3                : std_logic_vector(31 downto 0);

    ---------------------------
	--      Components       --
    ---------------------------

	-- Clock generation
	component clk_gen is
	port(
		sys_clk_p_i					            : in std_logic;
		sys_clk_n_i					            : in std_logic;
		sys_clk_o					              : out std_logic
	);
	end component;

	-- Xilinx Megafunction
  component sys_pll is
  port(
		rst_i						                : in std_logic  := '0';
		clk_i						                : in std_logic  := '0';
		clk0_o						              : out std_logic;
		clk1_o						              : out std_logic;
		locked_o					              : out std_logic 
	);
  end component;
    
  -- Xilinx Chipscope Controller
  component chipscope_icon_1_port
  port (
    CONTROL0                        : inout std_logic_vector(35 downto 0)
  );
  end component;
    
  -- Xilinx Chipscope Controller 2 port
  component chipscope_icon_2_port
  port (
    CONTROL0                        : inout std_logic_vector(35 downto 0);
    CONTROL1                        : inout std_logic_vector(35 downto 0)
  );
  end component;
  
  -- Xilinx Chipscope Logic Analyser
  component chipscope_ila
  port (
    CONTROL                         : inout std_logic_vector(35 downto 0);
    CLK                             : in    std_logic;
    TRIG0                           : in    std_logic_vector(31 downto 0);
    TRIG1                           : in    std_logic_vector(31 downto 0);
    TRIG2                           : in    std_logic_vector(31 downto 0);
    TRIG3                           : in    std_logic_vector(31 downto 0)
  );
  end component;
  
  -- Functions
  -- Generate dummy (0) values
  function f_zeros(size : integer)
      return std_logic_vector is
  begin
      return std_logic_vector(to_unsigned(0, size));
  end f_zeros;
begin

	-- Clock generation
	cmp_clk_gen : clk_gen
	port map (
		sys_clk_p_i					            => sys_clk_p_i,
		sys_clk_n_i					            => sys_clk_n_i,
		sys_clk_o					              => sys_clk_gen
	);

	-- Obtain core locking and generate necessary clocks
	cmp_sys_pll_inst : sys_pll
	port map (
		rst_i						                => '0',
		clk_i						                => sys_clk_gen,
		clk0_o						              => clk_sys,     -- 100MHz locked clock
    clk1_o                          => clk_200mhz,  -- 200MHz locked clock
		locked_o					              => locked		-- '1' when the PLL has locked
	);
  
	-- Reset synchronization. Hold reset line until few locked cycles have passed.
  -- Is this a safe approach to ADC reset domain?
	cmp_reset : gc_reset
  generic map(
    g_clocks                        => 2    -- CLK_SYS + CLK_ADC 
  )
	port map(
		free_clk_i 					            => sys_clk_gen,
		locked_i   					            => locked,
		clks_i     					            => reset_clks,
		rstn_o     					            => reset_rstn
	);
  
  -- Generate button reset synchronous to each clock domain
  -- Detect button positive edge of clk_sys
  cmp_button_sys_ffs : gc_sync_ffs 
  port map (
    clk_i                           => clk_sys,
    rst_n_i                         => '1',
    data_i                          => sys_rst_button_i,
    ppulse_o                        => rst_button_sys_pp
  );
  
  -- Detect button positive edge of clk_adc
  cmp_button_adc_ffs : gc_sync_ffs 
  port map (
    clk_i                           => clk_adc,
    rst_n_i                         => '1',
    data_i                          => sys_rst_button_i,
    ppulse_o                        => rst_button_adc_pp
  );
  
  -- Generate the reset signal based on positive edge 
  -- of synched sys_rst_button_i
  cmp_button_sys_rst : gc_extend_pulse   
  generic map (
    g_width                         => c_button_rst_width
  )
  port map(
    clk_i                           => clk_sys,
    rst_n_i                         => '1',
    pulse_i                         => rst_button_sys_pp,
    extended_o                      => rst_button_sys
  );
  
  -- Generate the reset signal based on positive edge 
  -- of synched sys_rst_button_i
  cmp_button_adc_rst : gc_extend_pulse   
  generic map (
    g_width                         => c_button_rst_width
  )
  port map(
    clk_i                           => clk_adc,
    rst_n_i                         => '1',
    pulse_i                         => rst_button_adc_pp,
    extended_o                      => rst_button_adc
  );
  
  rst_button_sys_n                  <= not rst_button_sys;
  rst_button_adc_n                  <= not rst_button_adc;

	reset_clks(0)                     <= clk_sys;
  reset_clks(1)                     <= clk_adc;
	clk_sys_rstn                      <= reset_rstn(0) and rst_button_sys_n;
  clk_adc_rstn                      <= reset_rstn(1) and rst_button_adc_n;
  
  -- The top-most Wishbone B.4 crossbar
	cmp_interconnect : xwb_sdb_crossbar
	generic map(
		g_num_masters 				          => c_masters,
		g_num_slaves  				          => c_slaves,
		g_registered  				          => true,
		g_wraparound  				          => false, -- Should be true for nested buses
		g_layout      				          => c_layout,
		g_sdb_addr    				          => c_sdb_address
	)
	port map(
		clk_sys_i     				          => clk_sys,
		rst_n_i       				          => clk_sys_rstn,
		-- Master connections (INTERCON is a slave)
		slave_i       				          => cbar_slave_i,
		slave_o       				          => cbar_slave_o,
		-- Slave connections (INTERCON is a master)
		master_i      				          => cbar_master_i,
		master_o      				          => cbar_master_o
	);
  
	-- The LM32 is master 0+1
	lm32_rstn                         <= clk_sys_rstn;

	cmp_lm32 : xwb_lm32
	generic map(
		g_profile => "medium_icache_debug"
	) -- Including JTAG and I-cache (no divide)
	port map(
		clk_sys_i 					            => clk_sys,
		rst_n_i   					            => lm32_rstn,
		irq_i     					            => lm32_interrupt,
		dwb_o     					            => cbar_slave_i(0), -- Data bus
		dwb_i     					            => cbar_slave_o(0),
		iwb_o     					            => cbar_slave_i(1), -- Instruction bus
		iwb_i     					            => cbar_slave_o(1)
	);
  
	-- Interrupts 31 downto 1 disabled for now. 
    -- Interrupt '0' is DMA completion.
	lm32_interrupt(31 downto 1) 	<= (others => '0');
    
  -- A DMA controller is master 2+3, slave 2, and interrupt 0
  cmp_dma : xwb_dma
  port map(
    clk_i                           => clk_sys,
    rst_n_i                         => clk_sys_rstn,
    slave_i                         => cbar_master_o(2),
    slave_o                         => cbar_master_i(2),
    r_master_i                      => cbar_slave_o(2),
    r_master_o                      => cbar_slave_i(2),
    w_master_i                      => cbar_slave_o(3),
    w_master_o                      => cbar_slave_i(3),
    interrupt_o                     => lm32_interrupt(0)
  );
  
  	-- Slave 0+1 is the RAM. Load a input file containing a simple led blink program!
	cmp_ram : xwb_dpram
	generic map(
		g_size                  	      => c_dpram_size, -- must agree with sw/target/lm32/ram.ld:LENGTH / 4
		g_init_file             	      => "../../../embedded-sw/dbe.ram",--"../../top/ml_605/dbe_bpm_simple/sw/main.ram",
		g_must_have_init_file   	      => true,
		g_slave1_interface_mode 	      => PIPELINED,
		g_slave2_interface_mode 	      => PIPELINED,
		g_slave1_granularity    	      => BYTE,
		g_slave2_granularity    	      => BYTE
  )
	port map(
		clk_sys_i 					            => clk_sys,
		rst_n_i   					            => clk_sys_rstn,
		-- First port connected to the crossbar
		slave1_i  					            => cbar_master_o(0),
		slave1_o  					            => cbar_master_i(0),
		-- Second port connected to the crossbar
		slave2_i  				              => cbar_master_o(1),
		slave2_o  				              => cbar_master_i(1)
		--slave2_i  					=> cc_dummy_slave_in, -- CYC always low
    --slave2_o  					=> open
	);

  -- Slave 3 is the FMC150 interface
  cmp_xwb_fmc150 : xwb_fmc150
  generic map(
    g_interface_mode                => CLASSIC,
    g_address_granularity           => BYTE
    --g_packet_size                           => 32,
    --g_sim                                   => 0
  )     
  port map(       
    rst_n_i                         => clk_sys_rstn,
    clk_sys_i                       => clk_sys,
    --clk_100Mhz_i                    : in std_logic;
    clk_200Mhz_i                    => clk_200mhz,
            
    -----------------------------       
    -- Wishbone signals     
    -----------------------------       
        
    wb_slv_i                        => cbar_master_o(3),
    wb_slv_o                        => cbar_master_i(3),
                                    
    -----------------------------
    -- Simulation Only ports!
    -----------------------------
    sim_adc_clk_i                   => '0',
    sim_adc_clk2x_i                 => '0',

    sim_adc_cha_data_i              => f_zeros(14),
    sim_adc_chb_data_i              => f_zeros(14),
    sim_adc_data_valid              => '0',
            
    -----------------------------       
    -- External ports       
    -----------------------------       
    --Clock/Data connection to ADC on FMC150 (ADS62P49)
    adc_clk_ab_p_i                  => adc_clk_ab_p_i,
    adc_clk_ab_n_i                  => adc_clk_ab_n_i,
    adc_cha_p_i                     => adc_cha_p_i,   
    adc_cha_n_i                     => adc_cha_n_i,   
    adc_chb_p_i                     => adc_chb_p_i,   
    adc_chb_n_i                     => adc_chb_n_i,   
        
    --Clock/Data connection to DAC on FMC150 (DAC3283)
    dac_dclk_p_o                    => dac_dclk_p_o, 
    dac_dclk_n_o                    => dac_dclk_n_o, 
    dac_data_p_o                    => dac_data_p_o, 
    dac_data_n_o                    => dac_data_n_o, 
    dac_frame_p_o                   => dac_frame_p_o,
    dac_frame_n_o                   => dac_frame_n_o,
    txenable_o                      => txenable_o,   
            
    --Clock/Trigger connection to FMC150        
    --clk_to_fpga_p_i                             : in  std_logic;
    --clk_to_fpga_n_i                             : in  std_logic;
    --ext_trigger_p_i                             : in  std_logic;
    --ext_trigger_n_i                             : in  std_logic;
            
    -- Control signals from/to FMC150       
    --Serial Peripheral Interface (SPI)     
    spi_sclk_o                      => spi_sclk_o, -- Shared SPI clock line
    spi_sdata_o                     => spi_sdata_o,-- Shared SPI data line
                          
    -- ADC specific signals         
    adc_n_en_o                      => adc_n_en_o, -- SPI chip select
    adc_sdo_i                       => adc_sdo_i,  -- SPI data out
    adc_reset_o                     => adc_reset_o,-- SPI reset
                          
    -- CDCE specific signals        
    cdce_n_en_o                     => cdce_n_en_o, -- SPI chip select
    cdce_sdo_i                      => cdce_sdo_i, -- SPI data out
    cdce_n_reset_o                  => cdce_n_reset_o,
    cdce_n_pd_o                     => cdce_n_pd_o,
    cdce_ref_en_o                   => cdce_ref_en_o,
    cdce_pll_status_i               => cdce_pll_status_i,
                          
    -- DAC specific signals         
    dac_n_en_o                      => dac_n_en_o, -- SPI chip select
    dac_sdo_i                       => dac_sdo_i, -- SPI data out
                    
    -- Monitoring specific signals              
    mon_n_en_o                      => mon_n_en_o, -- SPI chip select
    mon_sdo_i                       => mon_sdo_i, -- SPI data out
    mon_n_reset_o                   => mon_n_reset_o,
    mon_n_int_i                     => mon_n_int_i,
                                    
    --FMC Present status            
    prsnt_m2c_l_i                   => prsnt_m2c_l_i,
    
    -- ADC output signals
    -- ADC data is interfaced through the wishbone stream interface (wbs_src_o)
    adc_dout_o                      => open,                                
    clk_adc_o                       => clk_adc,
    
    -- Wishbone Streaming Interface Source
    wbs_source_i                    => wbs_src_i(0),
    wbs_source_o                    => wbs_src_o(0)
  );
  
  -- Slave 4 is the UART
  cmp_uart : xwb_simple_uart
  generic map (
    g_interface_mode                => PIPELINED,
    g_address_granularity           => BYTE
  )
  port map (
    clk_sys_i                       => clk_sys,
    rst_n_i                         => clk_sys_rstn,
    slave_i                         => cbar_master_o(4),
    slave_o                         => cbar_master_i(4),
    uart_rxd_i                      => uart_rxd_i,
    uart_txd_o                      => uart_txd_o
  );

	-- Slave 5 is the example LED driver
	cmp_leds : xwb_gpio_port
	generic map(
		--g_interface_mode         	=> CLASSIC;
		g_address_granularity    	      => BYTE,
		g_num_pins 					            => c_leds_num_pins,
		g_with_builtin_tristates 	      => false
	) 
	port map( 
		clk_sys_i 					            => clk_sys,
		rst_n_i   					            => clk_sys_rstn,
  
		-- Wishbone 
		slave_i 					              => cbar_master_o(5),
		slave_o 					              => cbar_master_i(5),
		desc_o  					              => open,	-- Not implemented
  
		--gpio_b : inout std_logic_vector(g_num_pins-1 downto 0);
  
		gpio_out_o 					            => s_leds,
		--gpio_out_o 				            => open,
		gpio_in_i 					            => s_leds,
		gpio_oen_o 					            => open
  );

	leds_o <= s_leds;

	--p_test_leds : process (clk_adc)
	--begin
	--	if rising_edge(clk_adc) then
	--		if clk_adc_rstn = '0' then
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

  -- Slave 6 is the example Button driver
	cmp_buttons : xwb_gpio_port
	generic map(
        --g_interface_mode            => CLASSIC;
		g_address_granularity           => BYTE,
		g_num_pins                      => c_buttons_num_pins,
		g_with_builtin_tristates 	      => false
	)
	port map(
		clk_sys_i 					            => clk_sys,
		rst_n_i   					            => clk_sys_rstn,

		-- Wishbone
		slave_i 					              => cbar_master_o(6),
		slave_o 					              => cbar_master_i(6),
		desc_o  					              => open,	-- Not implemented

		--gpio_b : inout std_logic_vector(g_num_pins-1 downto 0);

		gpio_out_o 					            => open,
		gpio_in_i 					            => buttons_i,
		gpio_oen_o 					            => open
  );
  
  -- Xilinx Chipscope
  cmp_chipscope_icon_0 : chipscope_icon_2_port
  port map (
      CONTROL0                    => CONTROL0,
      CONTROL1                    => CONTROL1
  );

  cmp_chipscope_ila_0 : chipscope_ila
  port map (
      CONTROL                     => CONTROL0,
      CLK                         => clk_sys,
      TRIG0                       => TRIG_ILA0_0,
      TRIG1                       => TRIG_ILA0_1,
      TRIG2                       => TRIG_ILA0_2,
      TRIG3                       => TRIG_ILA0_3
  );

  -- FMC150 master output (slave input) control data
  TRIG_ILA0_0                       <= cbar_master_o(3).dat;
  -- FMC150 master input (slave output) control data
  TRIG_ILA0_1                       <= cbar_master_i(3).dat;
  -- FMC150 master control output (slave input) control signals
  -- Partial decoding. Thus, only the LSB part of address matters to
  -- a specific slave core
  TRIG_ILA0_2(16 downto 0)          <= cbar_master_o(3).cyc &
                                      cbar_master_o(3).stb &
                                      cbar_master_o(3).adr(9 downto 0) &
                                      cbar_master_o(3).sel &
                                      cbar_master_o(3).we;
                                      
  --TRIG_ILA0_2(31 downto 11)         <= (others => '0');
  TRIG_ILA0_2(31 downto 17)         <= (others => '0');
                                      
  -- FMC150 master control input (slave output) control signals
  TRIG_ILA0_3(4 downto 0)           <= cbar_master_i(3).ack &
                                      cbar_master_i(3).err &
                                      cbar_master_i(3).rty &
                                      cbar_master_i(3).stall &
                                      cbar_master_i(3).int;
  TRIG_ILA0_3(31 downto 5)          <= (others => '0');
    
  cmp_chipscope_ila_1 : chipscope_ila
  port map (
      CONTROL                     => CONTROL1,
      CLK                         => clk_adc,
      TRIG0                       => TRIG_ILA1_0,
      TRIG1                       => TRIG_ILA1_1,
      TRIG2                       => TRIG_ILA1_2,
      TRIG3                       => TRIG_ILA1_3
  );
    
  -- FMC150 source output (sink input) stream data
  TRIG_ILA1_0                     <= wbs_src_o(0).dat;
  -- FMC150 source input (sink output) stream data
  --TRIG_ILA1_1                     <= wbs_src_i(0).dat;
  -- FMC150 source control output (sink input) stream signals
  -- Partial decoding. Thus, only the LSB part of address matters to
  -- a specific slave core
  TRIG_ILA1_1(10 downto 0)        <= wbs_src_o(0).cyc &
                                      wbs_src_o(0).stb &
                                      wbs_src_o(0).adr(3 downto 0) &
                                      wbs_src_o(0).sel &
                                      wbs_src_o(0).we;
  TRIG_ILA1_1(31 downto 11)       <= (others => '0');
                                      
  -- FMC150 master control input (slave output) stream signals
  TRIG_ILA1_2(3 downto 0)         <= wbs_src_i(0).ack &
                                      wbs_src_i(0).err &
                                      wbs_src_i(0).rty &
                                      wbs_src_i(0).stall;
  TRIG_ILA1_2(31 downto 4)        <= (others => '0');
  TRIG_ILA1_3(31 downto 0)        <= (others => '0');
end rtl;
