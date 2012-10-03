library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.custom_wishbone_pkg.all;
-- Wishbone Stream Interface
use work.wb_stream_pkg.all;

entity xwb_fmc150 is
generic
(
    g_interface_mode                        : t_wishbone_interface_mode      := PIPELINED;
    g_address_granularity                   : t_wishbone_address_granularity := WORD;
    g_packet_size                           : natural := 32;
    g_sim                                   : boolean := false
);      
port        
(       
    rst_n_i                                      : in std_logic;
    clk_sys_i                                    : in std_logic;
    clk_100Mhz_i                                 : in std_logic;
    clk_200Mhz_i                                 : in std_logic;
            
    -----------------------------       
    -- Wishbone signals     
    -----------------------------       
        
    wb_slv_i                                    : in t_wishbone_slave_in;
    wb_slv_o                                    : out t_wishbone_slave_out;
            
    -----------------------------       
    -- External ports       
    -----------------------------       
    --Clock/Data connection to ADC on FMC150 (ADS62P49)
    adc_clk_ab_p_i                              : in  std_logic;
    adc_clk_ab_n_i                              : in  std_logic;
    adc_cha_p_i                                 : in  std_logic_vector(6 downto 0);
    adc_cha_n_i                                 : in  std_logic_vector(6 downto 0);
    adc_chb_p_i                                 : in  std_logic_vector(6 downto 0);
    adc_chb_n_i                                 : in  std_logic_vector(6 downto 0);
        
    --Clock/Data connection to DAC on FMC150 (DAC3283)
    dac_dclk_p_o                                : out std_logic;
    dac_dclk_n_o                                : out std_logic;
    dac_data_p_o                                : out std_logic_vector(7 downto 0);
    dac_data_n_o                                : out std_logic_vector(7 downto 0);
    dac_frame_p_o                               : out std_logic;
    dac_frame_n_o                               : out std_logic;
    txenable_o                                  : out std_logic;
            
    --Clock/Trigger connection to FMC150        
    --clk_to_fpga_p_i                             : in  std_logic;
    --clk_to_fpga_n_i                             : in  std_logic;
    --ext_trigger_p_i                             : in  std_logic;
    --ext_trigger_n_i                             : in  std_logic;
            
    -- Control signals from/to FMC150       
    --Serial Peripheral Interface (SPI)     
    spi_sclk_o                                  : out std_logic; -- Shared SPI clock line
    spi_sdata_o                                 : out std_logic; -- Shared SPI data line
                    
    -- ADC specific signals             
    adc_n_en_o                                  : out std_logic; -- SPI chip select
    adc_sdo_i                                   : in  std_logic; -- SPI data out
    adc_reset_o                                 : out std_logic; -- SPI reset
                    
    -- CDCE specific signals                
    cdce_n_en_o                                 : out std_logic; -- SPI chip select
    cdce_sdo_i                                  : in  std_logic; -- SPI data out
    cdce_n_reset_o                              : out std_logic;
    cdce_n_pd_o                                 : out std_logic;
    cdce_ref_en_o                               : out std_logic;
    cdce_pll_status_i                           : in  std_logic;
                    
    -- DAC specific signals             
    dac_n_en_o                                  : out std_logic; -- SPI chip select
    dac_sdo_i                                   : in  std_logic; -- SPI data out
                    
    -- Monitoring specific signals              
    mon_n_en_o                                  : out std_logic; -- SPI chip select
    mon_sdo_i                                   : in  std_logic; -- SPI data out
    mon_n_reset_o                               : out std_logic;
    mon_n_int_i                                 : in  std_logic;
                
    --FMC Present status            
    prsnt_m2c_l_i                               : in  std_logic;
    
    -- Wishbone Streaming Interface Source
    wbs_source_i                                : in t_wbs_source_in;
    wbs_source_o                                : out t_wbs_source_out
);

end xwb_fmc150;

architecture rtl of xwb_fmc150 is

    component wb_fmc150
    generic
    (
        g_interface_mode                        : t_wishbone_interface_mode      := PIPELINED;
        g_address_granularity                   : t_wishbone_address_granularity := WORD;
        g_packet_size                           : natural := 32;
        g_sim                                   : boolean := false
    );
    port
    (
        rst_n_i                                 : in std_logic;
        clk_sys_i                               : in std_logic;
        clk_100Mhz_i                            : in std_logic;
        clk_200Mhz_i                            : in std_logic;
        
        -----------------------------
        -- Wishbone signals
        -----------------------------

        wb_adr_i                                : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
        wb_dat_i                                : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
        wb_dat_o                                : out std_logic_vector(c_wishbone_data_width-1 downto 0);
        wb_sel_i                                : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
        wb_we_i                                 : in  std_logic := '0';
        wb_cyc_i                                : in  std_logic := '0';
        wb_stb_i                                : in  std_logic := '0';
        wb_ack_o                                : out std_logic;
        wb_err_o                                : out std_logic;
        wb_rty_o                                : out std_logic;
        wb_stall_o                              : out std_logic;
        
        -----------------------------
        -- External ports
        -----------------------------
        --Clock/Data connection to ADC on FMC150 (ADS62P49)
        adc_clk_ab_p_i                          : in  std_logic;
        adc_clk_ab_n_i                          : in  std_logic;
        adc_cha_p_i                             : in  std_logic_vector(6 downto 0);
        adc_cha_n_i                             : in  std_logic_vector(6 downto 0);
        adc_chb_p_i                             : in  std_logic_vector(6 downto 0);
        adc_chb_n_i                             : in  std_logic_vector(6 downto 0);

        --Clock/Data connection to DAC on FMC150 (DAC3283)
        dac_dclk_p_o                            : out std_logic;
        dac_dclk_n_o                            : out std_logic;
        dac_data_p_o                            : out std_logic_vector(7 downto 0);
        dac_data_n_o                            : out std_logic_vector(7 downto 0);
        dac_frame_p_o                           : out std_logic;
        dac_frame_n_o                           : out std_logic;
        txenable_o                              : out std_logic;
        
        --Clock/Trigger connection to FMC150
        --clk_to_fpga_p_i                         : in  std_logic;
        --clk_to_fpga_n_i                         : in  std_logic;
        --ext_trigger_p_i                         : in  std_logic;
        --ext_trigger_n_i                         : in  std_logic;
        
        -- Control signals from/to FMC150
        --Serial Peripheral Interface (SPI)
        spi_sclk_o                              : out std_logic; -- Shared SPI clock line
        spi_sdata_o                             : out std_logic; -- Shared SPI data line
                
        -- ADC specific signals     
        adc_n_en_o                              : out std_logic; -- SPI chip select
        adc_sdo_i                               : in  std_logic; -- SPI data out
        adc_reset_o                             : out std_logic; -- SPI reset
                
        -- CDCE specific signals        
        cdce_n_en_o                             : out std_logic; -- SPI chip select
        cdce_sdo_i                              : in  std_logic; -- SPI data out
        cdce_n_reset_o                          : out std_logic;
        cdce_n_pd_o                             : out std_logic;
        cdce_ref_en_o                           : out std_logic;
        cdce_pll_status_i                       : in  std_logic;
                
        -- DAC specific signals     
        dac_n_en_o                              : out std_logic; -- SPI chip select
        dac_sdo_i                               : in  std_logic; -- SPI data out
                
        -- Monitoring specific signals      
        mon_n_en_o                              : out std_logic; -- SPI chip select
        mon_sdo_i                               : in  std_logic; -- SPI data out
        mon_n_reset_o                           : out std_logic;
        mon_n_int_i                             : in  std_logic;
                    
        --FMC Present status            
        prsnt_m2c_l_i                           : in  std_logic;
        
        -- Wishbone Streaming Interface Source
        wbs_adr_o                               : out std_logic_vector(c_wbs_address_width-1 downto 0);
        wbs_dat_o                               : out std_logic_vector(c_wbs_data_width-1 downto 0);
        wbs_cyc_o                               : out std_logic;
        wbs_stb_o                               : out std_logic;
        wbs_we_o                                : out std_logic;
        wbs_sel_o                               : out std_logic_vector((c_wbs_data_width/8)-1 downto 0);
        
        wbs_ack_i                               : in std_logic;
        wbs_stall_i                             : in std_logic;
        wbs_err_i                               : in std_logic;
        wbs_rty_i                               : in std_logic
    );
    end component;
    
begin

    cmp_wb_fmc150 : wb_fmc150
    generic map
    (
        g_interface_mode                        => g_interface_mode,     
        g_address_granularity                   => g_address_granularity,
        g_packet_size                           => g_packet_size,
        g_sim                                   => g_sim   
    )
    port map
    (
        rst_n_i                                 => rst_n_i,     
        clk_sys_i                               => clk_sys_i,   
        clk_100Mhz_i                            => clk_100Mhz_i,
        clk_200Mhz_i                            => clk_200Mhz_i,
        
        -----------------------------
        -- Wishbone signals
        -----------------------------

        wb_adr_i                                => wb_slv_i.adr,  
        wb_dat_i                                => wb_slv_i.dat,  
        wb_dat_o                                => wb_slv_o.dat,  
        wb_sel_i                                => wb_slv_i.sel,  
        wb_we_i                                 => wb_slv_i.we,   
        wb_cyc_i                                => wb_slv_i.cyc,  
        wb_stb_i                                => wb_slv_i.stb,  
        wb_ack_o                                => wb_slv_o.ack,  
        wb_err_o                                => wb_slv_o.err,  
        wb_rty_o                                => wb_slv_o.rty,  
        wb_stall_o                              => wb_slv_o.stall,

        -----------------------------
        -- External ports
        -----------------------------
        --Clock/Data connection to ADC on FMC150 (ADS62P49)
        adc_clk_ab_p_i                          => adc_clk_ab_p_i,
        adc_clk_ab_n_i                          => adc_clk_ab_n_i,
        adc_cha_p_i                             => adc_cha_p_i,   
        adc_cha_n_i                             => adc_cha_n_i,   
        adc_chb_p_i                             => adc_chb_p_i,   
        adc_chb_n_i                             => adc_chb_n_i,   

        --Clock/Data connection to DAC on FMC150 (DAC3283)
        dac_dclk_p_o                            => dac_dclk_p_o, 
        dac_dclk_n_o                            => dac_dclk_n_o, 
        dac_data_p_o                            => dac_data_p_o, 
        dac_data_n_o                            => dac_data_n_o, 
        dac_frame_p_o                           => dac_frame_p_o,
        dac_frame_n_o                           => dac_frame_n_o,
        txenable_o                              => txenable_o,   
                                                
        --Clock/Trigger connection to FMC150    
        --clk_to_fpga_p_i                         => clk_to_fpga_p_i,
        --clk_to_fpga_n_i                         => clk_to_fpga_n_i,
        --ext_trigger_p_i                         => ext_trigger_p_i,
        --ext_trigger_n_i                         => ext_trigger_n_i,
                                                
        -- Control signals from/to FMC150       
        --Serial Peripheral Interface (SPI)     
        spi_sclk_o                              => spi_sclk_o,  -- Shared SPI clock line
        spi_sdata_o                             => spi_sdata_o, -- Shared SPI data line
                                                
        -- ADC specific signals                 
        adc_n_en_o                              => adc_n_en_o,  -- SPI chip select
        adc_sdo_i                               => adc_sdo_i,   -- SPI data out
        adc_reset_o                             => adc_reset_o, -- SPI reset
                                                
        -- CDCE specific signals                
        cdce_n_en_o                             => cdce_n_en_o,       -- SPI chip select
        cdce_sdo_i                              => cdce_sdo_i,        -- SPI data out
        cdce_n_reset_o                          => cdce_n_reset_o,   
        cdce_n_pd_o                             => cdce_n_pd_o,      
        cdce_ref_en_o                           => cdce_ref_en_o,    
        cdce_pll_status_i                       => cdce_pll_status_i,
                                                
        -- DAC specific signals                
        dac_n_en_o                              => dac_n_en_o,  -- SPI chip select
        dac_sdo_i                               => dac_sdo_i,   -- SPI data out
                                                
        -- Monitoring specific signals          
        mon_n_en_o                              => mon_n_en_o,    -- SPI chip select
        mon_sdo_i                               => mon_sdo_i,     -- SPI data out
        mon_n_reset_o                           => mon_n_reset_o,
        mon_n_int_i                             => mon_n_int_i,  
                                                
        --FMC Present status                    
        prsnt_m2c_l_i                           => prsnt_m2c_l_i,
        
        -- Wishbone Streaming Interface Source
        wbs_adr_o                               => wbs_source_o.adr,  
        wbs_dat_o                               => wbs_source_o.dat,  
        wbs_cyc_o                               => wbs_source_o.cyc,  
        wbs_stb_o                               => wbs_source_o.stb,  
        wbs_we_o                                => wbs_source_o.we,   
        wbs_sel_o                               => wbs_source_o.sel,  
                                                  
        wbs_ack_i                               => wbs_source_i.ack,
        wbs_stall_i                             => wbs_source_i.stall,
        wbs_err_i                               => wbs_source_i.err,  
        wbs_rty_i                               => wbs_source_i.rty  
    );
    
    wb_slv_o.int                                <= '0';

end rtl;
