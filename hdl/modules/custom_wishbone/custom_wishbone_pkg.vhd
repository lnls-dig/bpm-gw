library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.wb_stream_pkg.all;

package custom_wishbone_pkg is

    --------------------------------------------------------------------
    -- Components
    --------------------------------------------------------------------
    
	component wb_dma_interface
	generic(
        g_ovf_counter_width                   : natural := 10
	);      
	port(       
		-- Asynchronous Reset signal        
		arst_n_i						   	                  : in std_logic;
                
        -- Write Domain Clock               
		dma_clk_i             		                : in  std_logic;
		--dma_valid_o             		   	        : out std_logic;
		--dma_data_o              		   	        : out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
		--dma_be_o                		   	        : out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
		--dma_last_o              		   	        : out std_logic;
		--dma_ready_i             		   	        : in  std_logic;
     
    -- Slave Data Flow port
    --dma_dflow_slave_i                       : in  t_wishbone_dflow_slave_in;
    --dma_dflow_slave_o                       : out t_wishbone_dflow_slave_out;
    wb_sel_i                                  : in std_logic_vector(c_wishbone_data_width/8-1 downto 0);
    wb_cyc_i                                  : in std_logic;
    wb_stb_i                                  : in std_logic;
    wb_we_i                                   : in std_logic;
    wb_adr_i                                  : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_dat_i                                  : in std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
    wb_ack_o                                  : out std_logic;
    wb_stall_o                                : out std_logic;
		
		-- Slave Data Input Port
    --data_slave_i                            : in  t_wishbone_slave_in;
    --data_slave_o                            : out t_wishbone_slave_out;
		data_clk_i		               	            : in std_logic;
		data_i       	          	  		          : in std_logic_vector(c_wishbone_data_width-1 downto 0);
		data_valid_i						                  : in std_logic;
		data_ready_o						                  : out std_logic;
		
		-- Slave control port. use wbgen2 tool or not if it is simple.
    --control_slave_i                         : in  t_wishbone_slave_in;
    --control_slave_o                         : out t_wishbone_slave_out;
		capture_ctl_i				   		                : in std_logic_vector(c_wishbone_data_width-1 downto 0);
		dma_complete_o						                : out std_logic;
		dma_ovf_o							                    : out std_logic

		-- Debug Signals
		--dma_debug_clk_o            		   	          : out std_logic;
		--dma_debug_data_o           		   	          : out std_logic_vector(255 downto 0);
		--dma_debug_trigger_o        		   	          : out std_logic_vector(15 downto 0)
	);
    end component;
    
  component xwb_dma_interface
	generic(
		-- Three 32-bit data input. LSB bits are valid.
    --C_NBITS_VALID_INPUT             	        : natural := 128;
		--C_NBITS_DATA_INPUT					              : natural := 128;
		--C_OVF_COUNTER_SIZE					              : natural := 10
    g_ovf_counter_width                         : natural := 10
	);
	port(
		-- Asynchronous Reset signal
		arst_n_i						   	                  : in std_logic;
                
        -- Write Domain Clock               
		dma_clk_i             		                : in  std_logic;
		--dma_valid_o             		   	        : out std_logic;
		--dma_data_o              		   	        : out std_logic_vector(C_NBITS_DATA_INPUT-1 downto 0);
		--dma_be_o                		   	        : out std_logic_vector(C_NBITS_DATA_INPUT/8 - 1 downto 0);
		--dma_last_o              		   	        : out std_logic;
		--dma_ready_i             		   	        : in  std_logic;
     
        -- Slave Data Flow port
        dma_slave_i                           : in  t_wishbone_slave_in;
        dma_slave_o                           : out t_wishbone_slave_out;
		
		-- Slave Data Input Port
    --data_slave_i                              : in  t_wishbone_slave_in;
    --data_slave_o                              : out t_wishbone_slave_out;
		data_clk_i		               		          : in std_logic;
		data_i       	          	  		          : in std_logic_vector(c_wishbone_data_width-1 downto 0);
		data_valid_i						                  : in std_logic;
		data_ready_o						                  : out std_logic;
		
		-- Slave control port. use wbgen2 tool or not if it is simple.
    --control_slave_i                         : in  t_wishbone_slave_in;
    --control_slave_o                         : out t_wishbone_slave_out;
		capture_ctl_i				   		                : in std_logic_vector(c_wishbone_data_width-1 downto 0);
		dma_complete_o						                : out std_logic;
		dma_ovf_o							                    : out std_logic

		-- Debug Signals
		--dma_debug_clk_o            		   	        : out std_logic;
		--dma_debug_data_o           		   	        : out std_logic_vector(255 downto 0);
		--dma_debug_trigger_o        		   	        : out std_logic_vector(15 downto 0)
	);
    end component;
    
    component wb_fmc150
    generic
    (
        g_interface_mode                      : t_wishbone_interface_mode      := PIPELINED;
        g_address_granularity                 : t_wishbone_address_granularity := WORD;
        g_packet_size                         : natural := 32;
        g_sim                                 : integer := 0
    );
    port
    (
        rst_n_i                               : in std_logic;
        clk_sys_i                             : in std_logic;
        --clk_100Mhz_i                          : in std_logic;
        clk_200Mhz_i                          : in std_logic;
            
        -----------------------------   
        -- Wishbone signals 
        -----------------------------   
    
        wb_adr_i                              : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
        wb_dat_i                              : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
        wb_dat_o                              : out std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_sel_i                              : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
        wb_we_i                               : in  std_logic := '0';
        wb_cyc_i                              : in  std_logic := '0';
        wb_stb_i                              : in  std_logic := '0';
        wb_ack_o                              : out std_logic;
        wb_err_o                              : out std_logic;
        wb_rty_o                              : out std_logic;
        wb_stall_o                            : out std_logic;
        
        -----------------------------
        -- Simulation Only ports
        -----------------------------
        sim_adc_clk_i                         : in std_logic;
        sim_adc_clk2x_i                       : in std_logic;
                    
        sim_adc_cha_data_i                    : in std_logic_vector(13 downto 0);
        sim_adc_chb_data_i                    : in std_logic_vector(13 downto 0);
        sim_adc_data_valid                    : in std_logic;
        
        -----------------------------
        -- External ports
        -----------------------------
        --Clock/Data connection to ADC on FMC150 (ADS62P49)
        adc_clk_ab_p_i                        : in  std_logic;
        adc_clk_ab_n_i                        : in  std_logic;
        adc_cha_p_i                           : in  std_logic_vector(6 downto 0);
        adc_cha_n_i                           : in  std_logic_vector(6 downto 0);
        adc_chb_p_i                           : in  std_logic_vector(6 downto 0);
        adc_chb_n_i                           : in  std_logic_vector(6 downto 0);

        --Clock/Data connection to DAC on FMC150 (DAC3283)
        dac_dclk_p_o                          : out std_logic;
        dac_dclk_n_o                          : out std_logic;
        dac_data_p_o                          : out std_logic_vector(7 downto 0);
        dac_data_n_o                          : out std_logic_vector(7 downto 0);
        dac_frame_p_o                         : out std_logic;
        dac_frame_n_o                         : out std_logic;
        txenable_o                            : out std_logic;
            
        --Clock/Trigger connection to FMC150    
        --clk_to_fpga_p           : in  std_logic;
        --clk_to_fpga_n           : in  std_logic;
        --ext_trigger_p           : in  std_logic;
        --ext_trigger_n           : in  std_logic;
            
        -- Control signals from/to FMC150   
        --Serial Peripheral Interface (SPI) 
        spi_sclk_o                            : out std_logic; -- Shared SPI clock line
        spi_sdata_o                           : out std_logic; -- Shared SPI data line
                      
        -- ADC specific signals             
        adc_n_en_o                            : out std_logic; -- SPI chip select
        adc_sdo_i                             : in  std_logic; -- SPI data out
        adc_reset_o                           : out std_logic; -- SPI reset
                      
        -- CDCE specific signals              
        cdce_n_en_o                           : out std_logic; -- SPI chip select
        cdce_sdo_i                            : in  std_logic; -- SPI data out
        cdce_n_reset_o                        : out std_logic;
        cdce_n_pd_o                           : out std_logic;
        cdce_ref_en_o                         : out std_logic;
        cdce_pll_status_i                     : in  std_logic;
                    
        -- DAC specific signals         
        dac_n_en_o                                : out std_logic; -- SPI chip select
        dac_sdo_i                                 : in  std_logic; -- SPI data out
                    
        -- Monitoring specific signals          
        mon_n_en_o                                : out std_logic; -- SPI chip select
        mon_sdo_i                                 : in  std_logic; -- SPI data out
        mon_n_reset_o                             : out std_logic;
        mon_n_int_i                               : in  std_logic;
                        
        --FMC Present status                
        prsnt_m2c_l_i                             : in  std_logic;
        
        -- ADC output signals
        adc_dout_o                                : out std_logic_vector(31 downto 0);
        clk_adc_o                                 : out std_logic;
            
        -- Wishbone Streaming Interface Source  
        wbs_adr_o                                 : out std_logic_vector(c_wbs_address_width-1 downto 0);
        wbs_dat_o                                 : out std_logic_vector(c_wbs_data_width-1 downto 0);
        wbs_cyc_o                                 : out std_logic;
        wbs_stb_o                                 : out std_logic;
        wbs_we_o                                  : out std_logic;
        wbs_sel_o                                 : out std_logic_vector((c_wbs_data_width/8)-1 downto 0);
        
        wbs_ack_i                                 : in std_logic;
        wbs_stall_i                               : in std_logic;
        wbs_err_i                                 : in std_logic;
        wbs_rty_i                                 : in std_logic
    );
    end component;
    
    component xwb_fmc150
    generic
    (
        g_interface_mode                          : t_wishbone_interface_mode      := PIPELINED;
        g_address_granularity                     : t_wishbone_address_granularity := WORD;
        g_packet_size                             : natural := 32;
        g_sim                                     : integer := 0
    );      
    port        
    (       
        rst_n_i                                   : in std_logic;
        clk_sys_i                                 : in std_logic;
        --clk_100Mhz_i                              : in std_logic;
        clk_200Mhz_i                              : in std_logic;
                
        -----------------------------       
        -- Wishbone signals     
        -----------------------------       
            
        wb_slv_i                                  : in t_wishbone_slave_in;
        wb_slv_o                                  : out t_wishbone_slave_out;
        
        -----------------------------
        -- Simulation Only ports
        -----------------------------
        sim_adc_clk_i                             : in std_logic;
        sim_adc_clk2x_i                           : in std_logic;
                  
        sim_adc_cha_data_i                        : in std_logic_vector(13 downto 0);
        sim_adc_chb_data_i                        : in std_logic_vector(13 downto 0);
        sim_adc_data_valid                        : in std_logic;
                
        -----------------------------       
        -- External ports       
        -----------------------------       
        --Clock/Data connection to ADC on FMC150 (ADS62P49)
        adc_clk_ab_p_i                            : in  std_logic;
        adc_clk_ab_n_i                            : in  std_logic;
        adc_cha_p_i                               : in  std_logic_vector(6 downto 0);
        adc_cha_n_i                               : in  std_logic_vector(6 downto 0);
        adc_chb_p_i                               : in  std_logic_vector(6 downto 0);
        adc_chb_n_i                               : in  std_logic_vector(6 downto 0);
            
        --Clock/Data connection to DAC on FMC150 (DAC3283)
        dac_dclk_p_o                              : out std_logic;
        dac_dclk_n_o                              : out std_logic;
        dac_data_p_o                              : out std_logic_vector(7 downto 0);
        dac_data_n_o                              : out std_logic_vector(7 downto 0);
        dac_frame_p_o                             : out std_logic;
        dac_frame_n_o                             : out std_logic;
        txenable_o                                : out std_logic;
                
        --Clock/Trigger connection to FMC150        
        --clk_to_fpga_p           : in  std_logic;
        --clk_to_fpga_n           : in  std_logic;
        --ext_trigger_p           : in  std_logic;
        --ext_trigger_n           : in  std_logic;
                
        -- Control signals from/to FMC150       
        --Serial Peripheral Interface (SPI)     
        spi_sclk_o                                : out std_logic; -- Shared SPI clock line
        spi_sdata_o                               : out std_logic; -- Shared SPI data line
                          
        -- ADC specific signals                 
        adc_n_en_o                                : out std_logic; -- SPI chip select
        adc_sdo_i                                 : in  std_logic; -- SPI data out
        adc_reset_o                               : out std_logic; -- SPI reset
                          
        -- CDCE specific signals                  
        cdce_n_en_o                               : out std_logic; -- SPI chip select
        cdce_sdo_i                                : in  std_logic; -- SPI data out
        cdce_n_reset_o                            : out std_logic;
        cdce_n_pd_o                               : out std_logic;
        cdce_ref_en_o                             : out std_logic;
        cdce_pll_status_i                         : in  std_logic;
                        
        -- DAC specific signals             
        dac_n_en_o                                : out std_logic; -- SPI chip select
        dac_sdo_i                                 : in  std_logic; -- SPI data out
                        
        -- Monitoring specific signals            
        mon_n_en_o                                : out std_logic; -- SPI chip select
        mon_sdo_i                                 : in  std_logic; -- SPI data out
        mon_n_reset_o                             : out std_logic;
        mon_n_int_i                               : in  std_logic;
                    
        --FMC Present status            
        prsnt_m2c_l_i                             : in  std_logic;
        
        -- ADC output signals
        adc_dout_o                                : out std_logic_vector(31 downto 0);
        clk_adc_o                                 : out std_logic;
        
        -- Wishbone Streaming Interface Source
        wbs_source_i                              : in t_wbs_source_in;
        wbs_source_o                              : out t_wbs_source_out
    );
    end component;
    
  --------------------------------------------------------------------
  -- SDB Devices Structures
  --------------------------------------------------------------------
  
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
    
	-- IRQ manager interface device
	constant c_xwb_irqmngr_sdb : t_sdb_device := (
		abi_class     => x"0000", 				-- undocumented device
		abi_ver_major => x"01",
		abi_ver_minor => x"00",
		wbd_endian    => c_sdb_endian_big,
		wbd_width     => x"7", 					-- 8/16/32-bit port granularity (0111)
		sdb_component => (
		addr_first    => x"0000000000000000",
		addr_last     => x"00000000000000FF",
		product => (
		vendor_id     => x"1000000000001215", 	-- LNLS
		device_id     => x"15ff65e1",		
		version       => x"00000001",
		date          => x"20120903",			-- YY/MM/DD ??
		name          => "LNLS_IRQMNGR       ")));
    
  -- FMC150 Interface
  constant c_xwb_fmc150_sdb : t_sdb_device := (
		abi_class     => x"0000", 				-- undocumented device
		abi_ver_major => x"01",
		abi_ver_minor => x"00",
		wbd_endian    => c_sdb_endian_big,
		wbd_width     => x"7", 					-- 8/16/32-bit port granularity (0111)
		sdb_component => (
		addr_first    => x"0000000000000000",
		addr_last     => x"00000000000000FF",
		product => (
		vendor_id     => x"1000000000001215", 	-- LNLS
		device_id     => x"f8c150c1",		
		version       => x"00000001",
		date          => x"20121010",			-- YY/MM/DD ??
		name          => "LNLS_FMC150        ")));
    
  -- UART Interface
  constant c_xwb_uart_sdb : t_sdb_device := (
		abi_class     => x"0000", 				-- undocumented device
		abi_ver_major => x"01",
		abi_ver_minor => x"00",
		wbd_endian    => c_sdb_endian_big,
		wbd_width     => x"1", 					-- 8-bit port granularity (0001)
		sdb_component => (
		addr_first    => x"0000000000000000",
		addr_last     => x"00000000000000FF",
		product => (
		vendor_id     => x"000000000000CE42", 	-- CERN
		device_id     => x"8a5719ae",		
		version       => x"00000001",
		date          => x"20121011",			-- YY/MM/DD ??
		name          => "CERN_SIMPLE_UART   ")));
	
end custom_wishbone_pkg;
