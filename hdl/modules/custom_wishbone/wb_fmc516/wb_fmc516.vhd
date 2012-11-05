------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-17-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top Module for the FMC516 ADC board interface from Curtis Wright.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-29-10  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

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
-- Register Bank
use work.fmc516_wbgen2_pkg.all;
-- Reset Synch
use work.custom_common_pkg.all;

entity wb_fmc516 is
generic
(
    g_interface_mode                        : t_wishbone_interface_mode      := CLASSIC;
    g_address_granularity                   : t_wishbone_address_granularity := WORD;
    g_packet_size                           : natural := 32;
    g_sim                                   : integer := 0
);
port
(
    sys_clk_i                               : in std_logic;
    sys_rst_n_i                             : in std_logic;
    --clk_100Mhz_i                            : in std_logic;
    sys_clk_200Mhz_i                        : in std_logic;
    
    -----------------------------
    -- Wishbone Control Interface signals
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
    -- Simulation Only ports
    -----------------------------
    sim_adc_clk_i                           : in std_logic;
    --sim_adc_clk2x_i                         : in std_logic;
                
    sim_adc_ch0_data_i                      : in std_logic_vector(15 downto 0);
    sim_adc_ch1_data_i                      : in std_logic_vector(15 downto 0);
    sim_adc_ch2_data_i                      : in std_logic_vector(15 downto 0);
    sim_adc_ch3_data_i                      : in std_logic_vector(15 downto 0);
    sim_adc_data_valid                      : in std_logic;
    
    -----------------------------
    -- External ports
    -----------------------------
    -- System I2C Bus. Slaves: Atmel AT24C512B Serial EEPROM, 
    -- AD7417 temperature diodes and AD7417 supply rails
    sys_i2c_scl_b                           : inout std_logic;
    sys_i2c_sda_b                           : inout std_logic; 
    
    -- ADC clocks. One clock per ADC channel.
    -- Only ch0 clock is used as all data chains
    -- are sampled at the same frequency
    adc_clk_ch0_p_i                         : in std_logic;
    adc_clk_ch0_n_i                         : in std_logic;
    adc_clk_ch1_p_i                         : in std_logic;
    adc_clk_ch1_n_i                         : in std_logic;
    adc_clk_ch2_p_i                         : in std_logic;
    adc_clk_ch2_n_i                         : in std_logic;
    adc_clk_ch3_p_i                         : in std_logic;
    adc_clk_ch3_n_i                         : in std_logic;
    
    -- DDR ADC data channels.
    adc_ch0_p_i                             : in std_logic_vector(7 downto 0);
    adc_ch0_n_i                             : in std_logic_vector(7 downto 0);
    adc_ch1_p_i                             : in std_logic_vector(7 downto 0);
    adc_ch1_n_i                             : in std_logic_vector(7 downto 0);
    adc_ch2_p_i                             : in std_logic_vector(7 downto 0);
    adc_ch2_n_i                             : in std_logic_vector(7 downto 0);
    adc_ch3_p_i                             : in std_logic_vector(7 downto 0);
    adc_ch3_n_i                             : in std_logic_vector(7 downto 0);
    
    -- ADC clock (half of the sampling frequency) divider reset
    adc_clk_div_rst_p_o                     : out std_logic;
    adc_clk_div_rst_n_o                     : out std_logic;
    
    -- FMC Front leds. Typical uses: Over Range or Full Scale
    -- condition.
    fmc_leds_o                              : out std_logic_vector(1 downto 0);
    
    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    sys_spi_clk_o                           : out std_logic;
    sys_spi_data_b                          : inout std_logic;
    sys_spi_cs_adc1_n_o                     : out std_logic;  -- SPI ADC CS channel 0
    sys_spi_cs_adc2_n_o                     : out std_logic;  -- SPI ADC CS channel 1 
    sys_spi_cs_adc3_n_o                     : out std_logic;  -- SPI ADC CS channel 2 
    sys_spi_cs_adc4_n_o                     : out std_logic;  -- SPI ADC CS channel 3 
    
    -- External Trigger To/From FMC
    ext_trig_p_i                            : in std_logic; 
    ext_trig_n_i                            : in std_logic; 
    ext_trig_p_o                            : out std_logic;
    ext_trig_n_o                            : out std_logic;
    
    -- LMK (National Semiconductor) is the clock and distribution IC.
    -- SPI interface?
    lmk_lock_i                              : in std_logic;
    lmk_sync_o                              : out std_logic;
    lmk_latch_en_o                          : out std_logic;
    lmk_data_o                              : out std_logic;
    lmk_clock_o                             : out std_logic;
    
    -- Programable VCXO via I2C?
    vcxo_sda_b                              : inout std_logic;
    vcxo_scl_o                              : out std_logic;
    vcxo_pd_l_o                             : out std_logic;
    
    -- One-wire To/From DS2431 (VMETRO Data)
    fmc_id_dq_b                             : inout std_logic;
    -- One-wire To/From DS2432 SHA-1 (SP-Devices key)
    fmc_key_dq_b                            : inout std_logic;
    
    -- General board pins
    fmc_pwr_good_i                          : in std_logic;
    -- Internal/External clock distribution selection
    fmc_clk_sel_o                           : out std_logic;
    -- Reset ADCs
    fmc_reset_adcs_n_o                      : out std_logic;  
    --FMC Present status            
    fmc_prsnt_m2c_l_i                       : in  std_logic;
    
    -----------------------------
    -- ADC output signals. Continuous flow. Mostly used for debug
    -----------------------------
    adc_out_data_o                          : out std_logic_vector(63 downto 0);
    adc_out_clk_o                           : out std_logic;
    
    -----------------------------
    -- Wishbone Streaming Interface Source
    -----------------------------

    wbs_adr_o                               : out std_logic_vector(c_wbs_address_width-1 downto 0);
    wbs_dat_o                               : out std_logic_vector(c_wbs_data_width-1 downto 0);
    wbs_cyc_o                               : out std_logic;
    wbs_stb_o                               : out std_logic;
    wbs_we_o                                : out std_logic;
    wbs_sel_o                               : out std_logic_vector((c_wbs_data_width/8)-1 downto 0);
    wbs_ack_i                               : in std_logic := '0';
    wbs_stall_i                             : in std_logic := '0';
    wbs_err_i                               : in std_logic := '0';
    wbs_rty_i                               : in std_logic := '0'
);

end wb_fmc150;

architecture rtl of wb_fmc150 is

    -- Constants
    constant c_counter_size                 : natural := f_ceil_log2(g_packet_size);

    -----------------------------------------------------------------------------------------------
    -- IP / user logic interface signals
    -----------------------------------------------------------------------------------------------
    -- Clock and reset signals
    signal sys_rst                          : std_logic;
    
    
    -- FMC516 reg structure
    signal regs_in                          : t_fmc150_out_registers;
    signal regs_out                         : t_fmc150_in_registers;
        
    -- Stream Interface structure    
    signal wbs_stream_out                   : t_wbs_source_out;
    signal wbs_stream_in                    : t_wbs_source_in;
        
    -- FMC516 signals    
    --signal cdce_pll_status                  : std_logic;
    signal s_mmcm_adc_locked                : std_logic;
        
    signal s_adc_dout                       : std_logic_vector(31 downto 0);
    signal s_clk_adc                        : std_logic;
    signal rst_n_adc                        : std_logic;
    signal s_fmc150_rst                     : std_logic;
        
    -- Streaming control signals    
    signal s_wbs_packet_counter             : unsigned(c_counter_size-1 downto 0);
    signal s_addr                           : std_logic_vector(c_wbs_address_width-1 downto 0);
    signal s_data                           : std_logic_vector(c_wbs_data_width-1 downto 0);
    signal s_dvalid                         : std_logic;
    signal s_sof                            : std_logic;
    signal s_eof                            : std_logic;  
    signal s_error                          : std_logic;
    signal s_bytesel                        : std_logic_vector((c_wbs_data_width/8)-1 downto 0);
    signal s_dreq                           : std_logic;
        
    -- Wishbone adapter structures    
    signal wb_out                           : t_wishbone_slave_out;
    signal wb_in                            : t_wishbone_slave_in;
    
    signal resized_addr                     : std_logic_vector(c_wishbone_address_width-1 downto 0);
    
    -- Components
    -- Bank Register / Wishbone Interface
    --component wb_fmc516_port
    --  port (
    --    rst_n_i                             : in     std_logic;
    --    clk_sys_i                           : in     std_logic;
    --    wb_adr_i                            : in     std_logic_vector(2 downto 0);
    --    wb_dat_i                            : in     std_logic_vector(31 downto 0);
    --    wb_dat_o                            : out    std_logic_vector(31 downto 0);
    --    wb_cyc_i                            : in     std_logic;
    --    wb_sel_i                            : in     std_logic_vector(3 downto 0);
    --    wb_stb_i                            : in     std_logic;
    --    wb_we_i                             : in     std_logic;
    --    wb_ack_o                            : out    std_logic;
    --    wb_stall_o                          : out    std_logic;
    --    --clk_100Mhz_i                        : in     std_logic;
    --    --clk_wb_i                            : in     std_logic;
    --    regs_i                              : in     t_fmc150_in_registers;
    --    regs_o                              : out    t_fmc150_out_registers
    --  );
    --end component;

    
begin

  -- Resets
  sys_rst  <= not(sys_rst_n_i);
  --fs_rst_n <= sys_rst_n_i and locked_out;
  --fs_rst   <= not(fs_rst_n);
  
        
  cmp_fmc516_adc_iface : fmc516_adc_iface
  port map(
  
  
  
  
  );

end rtl;
