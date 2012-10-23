-- Simple IRQ Manager
-- Based on the original design by:
--	
-- Fabrice Mousset (fabrice.mousset@laposte.net)
-- Project       :  Wishbone Interruption Manager (ARMadeus wishbone example)

-- See: http://www.armadeus.com/wiki/index.php?title=A_simple_design_with_Wishbone_bus

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.wishbone_pkg.all;
use work.gencores_pkg.all;

entity wb_irq_mngr is
  generic(
		g_irq_count				          : integer := 16;
		g_irq_level 			          : std_logic := '1';
		g_interface_mode            : t_wishbone_interface_mode       := CLASSIC;
    g_address_granularity       : t_wishbone_address_granularity  := BYTE
  );
	port(
		-- Global Signals
		clk_sys_i 				          : in std_logic;
		rst_n_i   				          : in std_logic;
      
		-- Wishbone interface signals
    wb_sel_i                    : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0);
    wb_cyc_i                    : in  std_logic;
    wb_stb_i                    : in  std_logic;
    wb_we_i                     : in  std_logic;
    wb_adr_i                    : in  std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_dat_i                    : in  std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_dat_o                    : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_ack_o                    : out std_logic;
    wb_stall_o                  : out std_logic;
    --slave_i 				    : in  t_wishbone_slave_in;
    --slave_o 				    : out t_wishbone_slave_out;
    
    -- irq from other IP
    irq_req_i        			      : in  std_logic_vector(g_irq_count-1 downto 0);

    -- Component external signals
    irq_req_o           		    : out std_logic
  );
end wb_irq_mngr;
    
architecture rtl of wb_irq_mngr is
	-- Read/Write regs
  constant c_IRQ_REG_MASK 			: std_logic_vector(2 downto 0) := "000";  -- *reg* IRQ mask
	constant c_IRQ_REG_ACK 				: std_logic_vector(2 downto 0) := "001";  -- *reg* IRQ acknowledge from master
    
	-- Read regs
	constant c_IRQ_REG_PEND 			: std_logic_vector(2 downto 0) := "010";  -- *reg* IRQ pending
    
    -- Slave Wishbone structs
    signal wb_in                    : t_wishbone_slave_in;
    signal wb_out                   : t_wishbone_slave_out;
    
    -- IRQ signals
	signal irq_r    				: std_logic_vector(g_irq_count-1 downto 0);
	signal irq_old  				: std_logic_vector(g_irq_count-1 downto 0);

	signal irq_pend 				: std_logic_vector(g_irq_count-1 downto 0);
	signal irq_ack  				: std_logic_vector(g_irq_count-1 downto 0);

	signal irq_mask 				: std_logic_vector(g_irq_count-1 downto 0);

	signal readdata 				: std_logic_vector(c_wishbone_data_width-1 downto 0);
	signal rd_ack 					: std_logic;
	signal wr_ack 					: std_logic;

	signal sel						: std_logic;

begin

--  External signals synchronization process

	gen_sync_ff : for i in 0 to g_irq_count-1 generate
		cmp_input_sync : gc_sync_ffs
		generic map (
			g_sync_edge => "positive")
		port map (
			rst_n_i  			    => rst_n_i,
		    clk_i    			    => clk_sys_i,
		    data_i   			    => irq_req_i(i),
		    synced_o 			    => irq_old(i),
		    ppulse_o 			    => irq_r(i));
	end generate gen_sync_ff;

	-- Simple sel bus aggregate
	sel 						<= '1' when (unsigned(not wb_in.sel) = 0) else '0';
    
    -- Slave adapter for granularity (byte, word) and interface mode (classic, pipelined)

    cmp_slv_adapter : wb_slave_adapter
    generic map (
        g_master_use_struct         => true,
        g_master_mode               => CLASSIC,
        g_master_granularity        => WORD,
        g_slave_use_struct          => false,
        g_slave_mode                => g_interface_mode,
        g_slave_granularity         => g_address_granularity)
    port map (
        clk_sys_i                   => clk_sys_i,
        rst_n_i                     => rst_n_i,
        master_i                    => wb_out,
        master_o                    => wb_in,
        sl_adr_i                    => wb_adr_i,
        sl_dat_i                    => wb_dat_i,
        sl_sel_i                    => wb_sel_i,
        sl_cyc_i                    => wb_cyc_i,
        sl_stb_i                    => wb_stb_i,
        sl_we_i                     => wb_we_i,
        sl_dat_o                    => wb_dat_o,
        sl_ack_o                    => wb_ack_o,
        sl_stall_o                  => wb_stall_o
    );

----------------------------------------------------------------------------
--  Interruption requests latching process on rising edge
----------------------------------------------------------------------------
	p_int_req : process(clk_sys_i, rst_n_i)
	begin
		if(rst_n_i = '0') then
			irq_pend 			<= (others => '0');
	  	elsif rising_edge(clk_sys_i) then
			irq_pend 			<= (irq_pend or (irq_r and irq_mask)) and (not irq_ack);
	  	end if;
	end process p_int_req;

----------------------------------------------------------------------------
--  Register reading process
----------------------------------------------------------------------------
	p_read_reg : process(clk_sys_i, rst_n_i)
	begin
		if(rst_n_i = '0') then
			rd_ack    			<= '0';
			readdata 			<= (others => '0');
		elsif rising_edge(clk_sys_i) then
			rd_ack  			<= '0';
			-- WB READ classic cycle
			if(wb_in.stb = '1' and wb_in.we = '0' and wb_in.cyc = '1') then
				rd_ack  		<= '1';

			-- Decode address (partial decoding only). Word granularity.
		  	if(wb_in.adr(4 downto 2) = c_IRQ_REG_MASK) then
				readdata(g_irq_count-1 downto 0)	<= irq_mask;
		  	elsif(wb_in.adr(4 downto 2) = c_IRQ_REG_PEND) then
				readdata(g_irq_count-1 downto 0) 	<= irq_pend;
		  	--elsif(wbs_s1_address="10") then
				--readdata <= std_logic_vector(to_unsigned(id,16));
		  	else
				readdata 		<= (others => '0');
		  end if;
		end if;
	  end if;
	end process p_read_reg;

----------------------------------------------------------------------------
--  Register update process
----------------------------------------------------------------------------
	p_update_reg : process(clk_sys_i, rst_n_i)
	begin
		if(rst_n_i = '0') then
			irq_ack				<= (others => '0');
			wr_ack  			<= '0';
			irq_mask 			<= (others => '0');
		elsif rising_edge(clk_sys_i) then
			irq_ack 			<= (others => '0');
			wr_ack  			<= '0';

		-- WB WRITE classic cycle. Word granularity
      if(wb_in.stb = '1' and wb_in.we = '0' and wb_in.cyc = '1' and sel = '1') then
          wr_ack  		    <= '1';
        if(wb_in.adr(4 downto 2) = c_IRQ_REG_MASK) then
          irq_mask 		<= wb_in.dat(g_irq_count-1 downto 0);
        elsif(wb_in.adr(4 downto 2) = c_IRQ_REG_ACK) then
          irq_ack 		<= wb_in.dat(g_irq_count-1 downto 0);
        end if;
			end if;
    end if;
	end process;

	irq_req_o 							<= g_irq_level when(unsigned(irq_pend) /= 0 and rst_n_i = '1') else
		       								not g_irq_level;

	wb_out.ack 						    <= rd_ack or wr_ack;
	wb_out.dat  						<= readdata when (wb_in.stb = '1' and wb_in.we = '0' and wb_in.cyc = '1') else (others => '0');

	wb_out.err   						<= '0';
	wb_out.int   						<= '0';
	wb_out.rty   						<= '0';
	wb_out.stall 						<= '0';

end rtl;
