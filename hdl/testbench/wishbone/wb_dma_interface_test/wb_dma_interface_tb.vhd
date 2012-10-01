library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.custom_wishbone_pkg.all;

entity wb_dma_interface_tb is          
end wb_dma_interface_tb;

architecture sim of wb_dma_interface_tb is  
	-- 100.00 MHz clock
	constant c_data_clk_period				: time := 10.00 ns;
    -- 200.00 MHz clock
    constant c_dma_clk_period				: time := 5.00 ns;
	constant c_sim_time						: time := 10000.00 ns;
	
	signal g_end_simulation          		: boolean   := false; -- Set to true to halt the simulation
    
    signal arst_n_i                         : std_logic;
    signal dma_clk_i                        : std_logic := '0';
    signal data_clk_i                       : std_logic := '0';
    
    signal dma_slave_i                      : t_wishbone_slave_in;
    signal dma_slave_o                      : t_wishbone_slave_out;
    
    signal data_i       	          	  	: std_logic_vector(c_wishbone_data_width-1 downto 0);
    signal data_valid_i						: std_logic;
    signal data_ready_o						: std_logic;
    
    signal capture_ctl_i				   	: std_logic_vector(c_wishbone_data_width-1 downto 0);
    signal dma_complete_o					: std_logic;
    signal dma_ovf_o						: std_logic;
  
begin  -- sim

    p_data_clk_gen : process
	begin
		while g_end_simulation = false loop
			wait for c_data_clk_period/2;
			data_clk_i <= not data_clk_i;
			wait for c_data_clk_period/2;
			data_clk_i <= not data_clk_i;	
		end loop;
		wait;  -- simulation stops here
	end process;
    
    p_dma_clk_gen : process
	begin
		while g_end_simulation = false loop
			wait for c_dma_clk_period/2;
			dma_clk_i <= not dma_clk_i;
			wait for c_dma_clk_period/2;
			dma_clk_i <= not dma_clk_i;	
		end loop;
		wait;  -- simulation stops here
	end process;
	
	p_main_simulation : process
	begin
		wait for c_sim_time;
            g_end_simulation <= true;
		wait;
	end process;

    cmp_dut : xwb_dma_interface
	port map(
		-- Asynchronous Reset signal
		arst_n_i						   	=> arst_n_i,
        
        -- Write Domain Clock        
		dma_clk_i             		        => dma_clk_i,
		--dma_valid_o             		   	: out std_logic;
		--dma_data_o              		   	: out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
		--dma_be_o                		   	: out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
		--dma_last_o              		   	: out std_logic;
		--dma_ready_i             		   	: in  std_logic;
     
        -- Slave Data Flow port
        dma_slave_i                         => dma_slave_i,
        dma_slave_o                         => dma_slave_o,
		
		-- Slave Data Input Port
        --data_slave_i                         : in  t_wishbone_slave_in;
        --data_slave_o                         : out t_wishbone_slave_out;
		data_clk_i		               		=> data_clk_i,
		data_i       	          	  		=> data_i,
		data_valid_i						=> data_valid_i,
		data_ready_o						=> data_ready_o,
		
		-- Slave control port. use wbgen2 tool or not if it is simple.
        --control_slave_i                         : in  t_wishbone_slave_in;
        --control_slave_o                         : out t_wishbone_slave_out;
		capture_ctl_i				   		=> capture_ctl_i,
		dma_complete_o						=> dma_complete_o,
		dma_ovf_o							=> dma_ovf_o

		-- Debug Signals
		--dma_debug_clk_o            		   	: out std_logic;
		--dma_debug_data_o           		   	: out std_logic_vector(255 downto 0);
		--dma_debug_trigger_o        		   	: out std_logic_vector(15 downto 0)
	);

end sim;
