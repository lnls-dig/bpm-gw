library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;

package custom_wishbone_pkg is

    --------------------------------------------------------------------
    -- Records
    --------------------------------------------------------------------
    
    type t_wishbone_dflow_master_out is record
        cyc : std_logic;
        stb : std_logic;
        adr : t_wishbone_address;
        sel : t_wishbone_byte_select;
        cti : t_wishbone_cycle_type;
        bte : t_wishbone_burst_type;
        we  : std_logic;
        dat : t_wishbone_data;
    end record t_wishbone_dflow_master_out;

    subtype t_wishbone_dflow_slave_in is t_wishbone_dflow_master_out;

    type t_wishbone_dflow_slave_out is record
        ack   : std_logic;
        err   : std_logic;
        rty   : std_logic;
        stall : std_logic;
        int   : std_logic;
        dat   : t_wishbone_data;
    end record t_wishbone_dflow_slave_out;
    
    subtype t_wishbone_dflow_master_in is t_wishbone_dflow_slave_out;

    --------------------------------------------------------------------
    -- Components
    --------------------------------------------------------------------
    
	component wb_dma_interface
	generic(
        g_ovf_counter_width                 : natural := 10
	);
	port(
		-- Asynchronous Reset signal
		arst_n_i						   	: in std_logic;
        
        -- Write Domain Clock        
		dma_clk_i             		        : in  std_logic;
		--dma_valid_o             		   	: out std_logic;
		--dma_data_o              		   	: out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
		--dma_be_o                		   	: out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
		--dma_last_o              		   	: out std_logic;
		--dma_ready_i             		   	: in  std_logic;
     
        -- Slave Data Flow port
        --dma_dflow_slave_i                   : in  t_wishbone_dflow_slave_in;
        --dma_dflow_slave_o                   : out t_wishbone_dflow_slave_out;
        wb_sel_i                            : in std_logic_vector(c_wishbone_data_width/8-1 downto 0);
        wb_cyc_i                            : in std_logic;
        wb_stb_i                            : in std_logic;
        wb_we_i                             : in std_logic;
        wb_adr_i                            : in std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_dat_i                            : in std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_dat_o                            : out std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_ack_o                            : out std_logic;
        wb_stall_o                          : out std_logic;
		
		-- Slave Data Input Port
        --data_slave_i                         : in  t_wishbone_slave_in;
        --data_slave_o                         : out t_wishbone_slave_out;
		data_clk_i		               		: in std_logic;
		data_i       	          	  		: in std_logic_vector(c_wishbone_data_width-1 downto 0);
		data_valid_i						: in std_logic;
		data_ready_o						: out std_logic;
		
		-- Slave control port. use wbgen2 tool or not if it is simple.
        --control_slave_i                         : in  t_wishbone_slave_in;
        --control_slave_o                         : out t_wishbone_slave_out;
		capture_ctl_i				   		: in std_logic_vector(c_wishbone_data_width-1 downto 0);
		dma_complete_o						: out std_logic;
		dma_ovf_o							: out std_logic

		-- Debug Signals
		--dma_debug_clk_o            		   	: out std_logic;
		--dma_debug_data_o           		   	: out std_logic_vector(255 downto 0);
		--dma_debug_trigger_o        		   	: out std_logic_vector(15 downto 0)
	);
    end component;
    
    component xwb_dma_interface
	generic(
		-- Three 32-bit data input. LSB bits are valid.
	    --C_NBITS_VALID_INPUT             	: natural := 128;
		--C_NBITS_DATA_INPUT					: natural := 128;
		--C_OVF_COUNTER_SIZE					: natural := 10
        g_ovf_counter_width                 : natural := 10
	);
	port(
		-- Asynchronous Reset signal
		arst_n_i						   	: in std_logic;
        
        -- Write Domain Clock        
		dma_clk_i             		        : in  std_logic;
		--dma_valid_o             		   	: out std_logic;
		--dma_data_o              		   	: out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
		--dma_be_o                		   	: out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
		--dma_last_o              		   	: out std_logic;
		--dma_ready_i             		   	: in  std_logic;
     
        -- Slave Data Flow port
        dma_slave_i                         : in  t_wishbone_slave_in;
        dma_slave_o                         : out t_wishbone_slave_out;
		
		-- Slave Data Input Port
        --data_slave_i                         : in  t_wishbone_slave_in;
        --data_slave_o                         : out t_wishbone_slave_out;
		data_clk_i		               		: in std_logic;
		data_i       	          	  		: in std_logic_vector(c_wishbone_data_width-1 downto 0);
		data_valid_i						: in std_logic;
		data_ready_o						: out std_logic;
		
		-- Slave control port. use wbgen2 tool or not if it is simple.
        --control_slave_i                         : in  t_wishbone_slave_in;
        --control_slave_o                         : out t_wishbone_slave_out;
		capture_ctl_i				   		: in std_logic_vector(c_wishbone_data_width-1 downto 0);
		dma_complete_o						: out std_logic;
		dma_ovf_o							: out std_logic

		-- Debug Signals
		--dma_debug_clk_o            		   	: out std_logic;
		--dma_debug_data_o           		   	: out std_logic_vector(255 downto 0);
		--dma_debug_trigger_o        		   	: out std_logic_vector(15 downto 0)
	);
    end component;
	
	component dma_status_reg_synch
	generic
	(
		C_NUM_REG                      	: integer              := 10;
		C_SLV_DWIDTH                   	: integer              := 32;
		C_STATUS_REG_IDX				: natural	   		   := 1
	);
	port
	(
		bus_clk_i						: in  std_logic;
		bus_rst_n_i						: in  std_logic;
		bus_reg_read_sel_i				: in  std_logic_vector(C_NUM_REG-1 downto 0);   
		bus_reg_write_sel_i				: in  std_logic_vector(C_NUM_REG-1 downto 0);  
		bus_2_ip_data_i					: in  std_logic_vector(C_SLV_DWIDTH-1 downto 0);
		
		dma_complete_i					: in  std_logic;
		dma_ovf_i						: in  std_logic;
		
		dma_complete_synch_o			: out  std_logic;
		dma_ovf_synch_o					: out  std_logic
	);
	end component;
	
end custom_wishbone_pkg;
