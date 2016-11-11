------------------------------------------------------------------------------
-- Title      : Top FMC250M design
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2016-02-19
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top design for testing the integration/control of the DSP with
-- FMC250M_4ch board
-------------------------------------------------------------------------------
-- Copyright (c) 2016 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-02-19  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dbe_bpm2 is
port(
  -----------------------------------------
  -- Clocking pins
  -----------------------------------------
  sys_clk_p_i                                : in std_logic;
  sys_clk_n_i                                : in std_logic;

  -----------------------------------------
  -- Reset Button
  -----------------------------------------
  sys_rst_button_n_i                         : in std_logic;

  -----------------------------------------
  -- UART pins
  -----------------------------------------

  rs232_txd_o                                : out std_logic;
  rs232_rxd_i                                : in std_logic;

  -----------------------------------------
  -- Trigger pins
  -----------------------------------------

  trig_dir_o                                 : out   std_logic_vector(7 downto 0);
  trig_b                                     : inout std_logic_vector(7 downto 0);

  -----------------------------
  -- AFC Diagnostics
  -----------------------------

  diag_spi_cs_i                              : in std_logic;
  diag_spi_si_i                              : in std_logic;
  diag_spi_so_o                              : out std_logic;
  diag_spi_clk_i                             : in std_logic;

  -----------------------------
  -- ADN4604ASVZ
  -----------------------------
  adn4604_vadj2_clk_updt_n_o                 : out std_logic;

  -----------------------------
  -- FMC1_250m_4ch ports
  -----------------------------

  -- ADC clock (half of the sampling frequency) divider reset
  fmc1_adc_clk_div_rst_p_o                   : out std_logic;
  fmc1_adc_clk_div_rst_n_o                   : out std_logic;
  fmc1_adc_ext_rst_n_o                       : out std_logic;
  fmc1_adc_sleep_o                           : out std_logic;

  -- ADC clocks. One clock per ADC channel.
  -- Only ch1 clock is used as all data chains
  -- are sampled at the same frequency
  fmc1_adc_clk0_p_i                          : in std_logic := '0';
  fmc1_adc_clk0_n_i                          : in std_logic := '0';
  fmc1_adc_clk1_p_i                          : in std_logic := '0';
  fmc1_adc_clk1_n_i                          : in std_logic := '0';
  fmc1_adc_clk2_p_i                          : in std_logic := '0';
  fmc1_adc_clk2_n_i                          : in std_logic := '0';
  fmc1_adc_clk3_p_i                          : in std_logic := '0';
  fmc1_adc_clk3_n_i                          : in std_logic := '0';

  -- DDR ADC data channels.
  fmc1_adc_data_ch0_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc1_adc_data_ch0_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc1_adc_data_ch1_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc1_adc_data_ch1_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc1_adc_data_ch2_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc1_adc_data_ch2_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc1_adc_data_ch3_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc1_adc_data_ch3_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');

  ---- FMC General Status
  --fmc1_prsnt_i                               : in std_logic;
  --fmc1_pg_m2c_i                              : in std_logic;
  --fmc1_clk_dir_i                             : in std_logic;

  -- Trigger
  fmc1_trig_dir_o                            : out std_logic;
  fmc1_trig_term_o                           : out std_logic;
  fmc1_trig_val_p_b                          : inout std_logic;
  fmc1_trig_val_n_b                          : inout std_logic;

  -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
  fmc1_adc_spi_clk_o                         : out std_logic;
  fmc1_adc_spi_mosi_o                        : out std_logic;
  fmc1_adc_spi_miso_i                        : in std_logic;
  fmc1_adc_spi_cs_adc0_n_o                   : out std_logic;  -- SPI ADC CS channel 0
  fmc1_adc_spi_cs_adc1_n_o                   : out std_logic;  -- SPI ADC CS channel 1
  fmc1_adc_spi_cs_adc2_n_o                   : out std_logic;  -- SPI ADC CS channel 2
  fmc1_adc_spi_cs_adc3_n_o                   : out std_logic;  -- SPI ADC CS channel 3

  -- Si571 clock gen
  fmc1_si571_scl_pad_b                       : inout std_logic;
  fmc1_si571_sda_pad_b                       : inout std_logic;
  fmc1_si571_oe_o                            : out std_logic;

  -- AD9510 clock distribution PLL
  fmc1_spi_ad9510_cs_o                       : out std_logic;
  fmc1_spi_ad9510_sclk_o                     : out std_logic;
  fmc1_spi_ad9510_mosi_o                     : out std_logic;
  fmc1_spi_ad9510_miso_i                     : in std_logic;

  fmc1_pll_function_o                        : out std_logic;
  fmc1_pll_status_i                          : in std_logic;

  -- AD9510 clock copy
  fmc1_fpga_clk_p_i                          : in std_logic;
  fmc1_fpga_clk_n_i                          : in std_logic;

  -- Clock reference selection (TS3USB221)
  fmc1_clk_sel_o                             : out std_logic;

  -- EEPROM (Connected to the CPU)
  --eeprom_scl_pad_b                          : inout std_logic;
  --eeprom_sda_pad_b                          : inout std_logic;
  fmc1_eeprom_scl_pad_b                     : inout std_logic;
  fmc1_eeprom_sda_pad_b                     : inout std_logic;

  -- AMC7823 temperature monitor
  fmc1_amc7823_spi_cs_o                      : out std_logic;
  fmc1_amc7823_spi_sclk_o                    : out std_logic;
  fmc1_amc7823_spi_mosi_o                    : out std_logic;
  fmc1_amc7823_spi_miso_i                    : in std_logic;
  fmc1_amc7823_davn_i                        : in std_logic;

  -- FMC LEDs
  fmc1_led1_o                                : out std_logic;
  fmc1_led2_o                                : out std_logic;
  fmc1_led3_o                                : out std_logic;

  -----------------------------
  -- FMC2_250m_4ch ports
  -----------------------------
  -- ADC clock (half of the sampling frequency) divider reset
  fmc2_adc_clk_div_rst_p_o                   : out std_logic;
  fmc2_adc_clk_div_rst_n_o                   : out std_logic;
  fmc2_adc_ext_rst_n_o                       : out std_logic;
  fmc2_adc_sleep_o                           : out std_logic;

  -- ADC clocks. One clock per ADC channel.
  -- Only ch1 clock is used as all data chains
  -- are sampled at the same frequency
  fmc2_adc_clk0_p_i                          : in std_logic := '0';
  fmc2_adc_clk0_n_i                          : in std_logic := '0';
  fmc2_adc_clk1_p_i                          : in std_logic := '0';
  fmc2_adc_clk1_n_i                          : in std_logic := '0';
  fmc2_adc_clk2_p_i                          : in std_logic := '0';
  fmc2_adc_clk2_n_i                          : in std_logic := '0';
  fmc2_adc_clk3_p_i                          : in std_logic := '0';
  fmc2_adc_clk3_n_i                          : in std_logic := '0';

  -- DDR ADC data channels.
  fmc2_adc_data_ch0_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc2_adc_data_ch0_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc2_adc_data_ch1_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc2_adc_data_ch1_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc2_adc_data_ch2_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc2_adc_data_ch2_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc2_adc_data_ch3_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  fmc2_adc_data_ch3_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');

  ---- FMC General Status
  --fmc2_prsnt_i                               : in std_logic;
  --fmc2_pg_m2c_i                              : in std_logic;
  --fmc2_clk_dir_i                             : in std_logic;

  -- Trigger
  fmc2_trig_dir_o                            : out std_logic;
  fmc2_trig_term_o                           : out std_logic;
  fmc2_trig_val_p_b                          : inout std_logic;
  fmc2_trig_val_n_b                          : inout std_logic;

  -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
  fmc2_adc_spi_clk_o                         : out std_logic;
  fmc2_adc_spi_mosi_o                        : out std_logic;
  fmc2_adc_spi_miso_i                        : in std_logic;
  fmc2_adc_spi_cs_adc0_n_o                   : out std_logic;  -- SPI ADC CS channel 0
  fmc2_adc_spi_cs_adc1_n_o                   : out std_logic;  -- SPI ADC CS channel 1
  fmc2_adc_spi_cs_adc2_n_o                   : out std_logic;  -- SPI ADC CS channel 2
  fmc2_adc_spi_cs_adc3_n_o                   : out std_logic;  -- SPI ADC CS channel 3

  -- Si571 clock gen
  fmc2_si571_scl_pad_b                       : inout std_logic;
  fmc2_si571_sda_pad_b                       : inout std_logic;
  fmc2_si571_oe_o                            : out std_logic;

  -- AD9510 clock distribution PLL
  fmc2_spi_ad9510_cs_o                       : out std_logic;
  fmc2_spi_ad9510_sclk_o                     : out std_logic;
  fmc2_spi_ad9510_mosi_o                     : out std_logic;
  fmc2_spi_ad9510_miso_i                     : in std_logic;

  fmc2_pll_function_o                        : out std_logic;
  fmc2_pll_status_i                          : in std_logic;

  -- AD9510 clock copy
  fmc2_fpga_clk_p_i                          : in std_logic;
  fmc2_fpga_clk_n_i                          : in std_logic;

  -- Clock reference selection (TS3USB221)
  fmc2_clk_sel_o                             : out std_logic;

  -- EEPROM (Connected to the CPU)
  --eeprom_scl_pad_b                          : inout std_logic;
  --eeprom_sda_pad_b                          : inout std_logic;

  -- AMC7823 temperature monitor
  fmc2_amc7823_spi_cs_o                      : out std_logic;
  fmc2_amc7823_spi_sclk_o                    : out std_logic;
  fmc2_amc7823_spi_mosi_o                    : out std_logic;
  fmc2_amc7823_spi_miso_i                    : in std_logic;
  fmc2_amc7823_davn_i                        : in std_logic;

  -- FMC LEDs
  fmc2_led1_o                                : out std_logic;
  fmc2_led2_o                                : out std_logic;
  fmc2_led3_o                                : out std_logic;

  -----------------------------------------
  -- Position Calc signals
  -----------------------------------------

  -- Uncross signals
  --clk_swap_o                                 : out std_logic;
  --clk_swap2x_o                               : out std_logic;
  --flag1_o                                    : out std_logic;
  --flag2_o                                    : out std_logic;

  -----------------------------------------
  -- General board status
  -----------------------------------------
  --fmc_mmcm_lock_led_o                       : out std_logic;
  --fmc_pll_status_led_o                      : out std_logic

  -----------------------------------------
  -- PCIe pins
  -----------------------------------------

  -- DDR3 memory pins
  ddr3_dq_b                                 : inout std_logic_vector(c_ddr_dq_width-1 downto 0);
  ddr3_dqs_p_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
  ddr3_dqs_n_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
  ddr3_addr_o                               : out   std_logic_vector(c_ddr_row_width-1 downto 0);
  ddr3_ba_o                                 : out   std_logic_vector(c_ddr_bank_width-1 downto 0);
  ddr3_cs_n_o                               : out   std_logic_vector(0 downto 0);
  ddr3_ras_n_o                              : out   std_logic;
  ddr3_cas_n_o                              : out   std_logic;
  ddr3_we_n_o                               : out   std_logic;
  ddr3_reset_n_o                            : out   std_logic;
  ddr3_ck_p_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
  ddr3_ck_n_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
  ddr3_cke_o                                : out   std_logic_vector(c_ddr_cke_width-1 downto 0);
  ddr3_dm_o                                 : out   std_logic_vector(c_ddr_dm_width-1 downto 0);
  ddr3_odt_o                                : out   std_logic_vector(c_ddr_odt_width-1 downto 0);

  -- PCIe transceivers
  pci_exp_rxp_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_rxn_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_txp_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_txn_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);

  -- PCI clock and reset signals
  pcie_clk_p_i                              : in std_logic;
  pcie_clk_n_i                              : in std_logic;

  -----------------------------------------
  -- Button pins
  -----------------------------------------
  --buttons_i                                 : in std_logic_vector(7 downto 0);

  -----------------------------------------
  -- User LEDs
  -----------------------------------------
  leds_o                                    : out std_logic_vector(2 downto 0)
);
end dbe_bpm2;

architecture rtl of dbe_bpm2 is

  ---------------------------
  --      Components       --
  ---------------------------

  component dbe_bpm_gen
  generic(
    g_fmc_adc_type                             : string := "FMC250M"
  );
  port(
    -----------------------------------------
    -- Clocking pins
    -----------------------------------------
    sys_clk_p_i                                : in std_logic;
    sys_clk_n_i                                : in std_logic;

    -----------------------------------------
    -- Reset Button
    -----------------------------------------
    sys_rst_button_n_i                         : in std_logic;

    -----------------------------------------
    -- UART pins
    -----------------------------------------

    rs232_txd_o                                : out std_logic;
    rs232_rxd_i                                : in std_logic;

    -----------------------------------------
    -- Trigger pins
    -----------------------------------------

    trig_dir_o                                 : out   std_logic_vector(7 downto 0);
    trig_b                                     : inout std_logic_vector(7 downto 0);

    -----------------------------
    -- AFC Diagnostics
    -----------------------------

    diag_spi_cs_i                              : in std_logic;
    diag_spi_si_i                              : in std_logic;
    diag_spi_so_o                              : out std_logic;
    diag_spi_clk_i                             : in std_logic;

    -----------------------------
    -- ADN4604ASVZ
    -----------------------------
    adn4604_vadj2_clk_updt_n_o                 : out std_logic;

    -----------------------------
    -- FMC1_130m_4ch ports
    -----------------------------

    -- ADC LTC2208 interface
    fmc1_adc_pga_o                             : out std_logic;
    fmc1_adc_shdn_o                            : out std_logic;
    fmc1_adc_dith_o                            : out std_logic;
    fmc1_adc_rand_o                            : out std_logic;

    -- ADC0 LTC2208
    fmc1_adc0_clk_i                            : in std_logic := '0';
    fmc1_adc0_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc1_adc0_of_i                             : in std_logic := '0'; -- Unused

    -- ADC1 LTC2208
    fmc1_adc1_clk_i                            : in std_logic := '0';
    fmc1_adc1_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc1_adc1_of_i                             : in std_logic := '0'; -- Unused

    -- ADC2 LTC2208
    fmc1_adc2_clk_i                            : in std_logic := '0';
    fmc1_adc2_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc1_adc2_of_i                             : in std_logic := '0'; -- Unused

    -- ADC3 LTC2208
    fmc1_adc3_clk_i                            : in std_logic := '0';
    fmc1_adc3_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc1_adc3_of_i                             : in std_logic := '0'; -- Unused

    ---- FMC General Status
    --fmc1_prsnt_i                               : in std_logic := '0';
    --fmc1_pg_m2c_i                              : in std_logic := '0';
    --fmc1_clk_dir_i                             : in std_logic := '0';

    -- Trigger
    fmc1_trig_dir_o                            : out std_logic;
    fmc1_trig_term_o                           : out std_logic;
    fmc1_trig_val_p_b                          : inout std_logic;
    fmc1_trig_val_n_b                          : inout std_logic;

    -- Si571 clock gen
    fmc1_si571_scl_pad_b                       : inout std_logic;
    fmc1_si571_sda_pad_b                       : inout std_logic;
    fmc1_si571_oe_o                            : out std_logic;

    -- AD9510 clock distribution PLL
    fmc1_spi_ad9510_cs_o                       : out std_logic;
    fmc1_spi_ad9510_sclk_o                     : out std_logic;
    fmc1_spi_ad9510_mosi_o                     : out std_logic;
    fmc1_spi_ad9510_miso_i                     : in std_logic := '0';

    fmc1_pll_function_o                        : out std_logic;
    fmc1_pll_status_i                          : in std_logic := '0';

    -- AD9510 clock copy
    fmc1_fpga_clk_p_i                          : in std_logic := '0';
    fmc1_fpga_clk_n_i                          : in std_logic := '0';

    -- Clock reference selection (TS3USB221)
    fmc1_clk_sel_o                             : out std_logic;

    -- EEPROM (Connected to the CPU)
    --eeprom_scl_pad_b                          : inout std_logic;
    --eeprom_sda_pad_b                          : inout std_logic;
    fmc1_eeprom_scl_pad_b                     : inout std_logic;
    fmc1_eeprom_sda_pad_b                     : inout std_logic;

    -- Temperature monitor (LM75AIMM)
    fmc1_lm75_scl_pad_b                       : inout std_logic;
    fmc1_lm75_sda_pad_b                       : inout std_logic;

    fmc1_lm75_temp_alarm_i                     : in std_logic := '0';

    -- FMC LEDs
    fmc1_led1_o                                : out std_logic;
    fmc1_led2_o                                : out std_logic;
    fmc1_led3_o                                : out std_logic;

    -----------------------------
    -- FMC2_130m_4ch ports
    -----------------------------

    -- ADC LTC2208 interface
    fmc2_adc_pga_o                             : out std_logic;
    fmc2_adc_shdn_o                            : out std_logic;
    fmc2_adc_dith_o                            : out std_logic;
    fmc2_adc_rand_o                            : out std_logic;

    -- ADC0 LTC2208
    fmc2_adc0_clk_i                            : in std_logic := '0';
    fmc2_adc0_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc2_adc0_of_i                             : in std_logic := '0'; -- Unused

    -- ADC1 LTC2208
    fmc2_adc1_clk_i                            : in std_logic := '0';
    fmc2_adc1_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc2_adc1_of_i                             : in std_logic := '0'; -- Unused

    -- ADC2 LTC2208
    fmc2_adc2_clk_i                            : in std_logic := '0';
    fmc2_adc2_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc2_adc2_of_i                             : in std_logic := '0'; -- Unused

    -- ADC3 LTC2208
    fmc2_adc3_clk_i                            : in std_logic := '0';
    fmc2_adc3_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0) := (others => '0');
    fmc2_adc3_of_i                             : in std_logic := '0'; -- Unused

    ---- FMC General Status
    --fmc2_prsnt_i                               : in std_logic := '0';
    --fmc2_pg_m2c_i                              : in std_logic := '0';
    --fmc2_clk_dir_i                             : in std_logic := '0';

    -- Trigger
    fmc2_trig_dir_o                            : out std_logic;
    fmc2_trig_term_o                           : out std_logic;
    fmc2_trig_val_p_b                          : inout std_logic;
    fmc2_trig_val_n_b                          : inout std_logic;

    -- Si571 clock gen
    fmc2_si571_scl_pad_b                       : inout std_logic;
    fmc2_si571_sda_pad_b                       : inout std_logic;
    fmc2_si571_oe_o                            : out std_logic;

    -- AD9510 clock distribution PLL
    fmc2_spi_ad9510_cs_o                       : out std_logic;
    fmc2_spi_ad9510_sclk_o                     : out std_logic;
    fmc2_spi_ad9510_mosi_o                     : out std_logic;
    fmc2_spi_ad9510_miso_i                     : in std_logic := '0';

    fmc2_pll_function_o                        : out std_logic;
    fmc2_pll_status_i                          : in std_logic := '0';

    -- AD9510 clock copy
    fmc2_fpga_clk_p_i                          : in std_logic := '0';
    fmc2_fpga_clk_n_i                          : in std_logic := '0';

    -- Clock reference selection (TS3USB221)
    fmc2_clk_sel_o                             : out std_logic;

    -- EEPROM (Connected to the CPU)
    --eeprom_scl_pad_b                          : inout std_logic;
    --eeprom_sda_pad_b                          : inout std_logic;

    -- Temperature monitor (LM75AIMM)
    fmc2_lm75_scl_pad_b                       : inout std_logic;
    fmc2_lm75_sda_pad_b                       : inout std_logic;

    fmc2_lm75_temp_alarm_i                     : in std_logic := '0';

    -- FMC LEDs
    fmc2_led1_o                                : out std_logic;
    fmc2_led2_o                                : out std_logic;
    fmc2_led3_o                                : out std_logic;

    -----------------------------
    -- FMC1_250m_4ch ports
    -----------------------------

    -- ADC clock (half of the sampling frequency) divider reset
    fmc1_adc_clk_div_rst_p_o                   : out std_logic;
    fmc1_adc_clk_div_rst_n_o                   : out std_logic;
    fmc1_adc_ext_rst_n_o                       : out std_logic;
    fmc1_adc_sleep_o                           : out std_logic;

    -- ADC clocks. One clock per ADC channel.
    -- Only ch1 clock is used as all data chains
    -- are sampled at the same frequency
    fmc1_adc_clk0_p_i                          : in std_logic := '0';
    fmc1_adc_clk0_n_i                          : in std_logic := '0';
    fmc1_adc_clk1_p_i                          : in std_logic := '0';
    fmc1_adc_clk1_n_i                          : in std_logic := '0';
    fmc1_adc_clk2_p_i                          : in std_logic := '0';
    fmc1_adc_clk2_n_i                          : in std_logic := '0';
    fmc1_adc_clk3_p_i                          : in std_logic := '0';
    fmc1_adc_clk3_n_i                          : in std_logic := '0';

    -- DDR ADC data channels.
    fmc1_adc_data_ch0_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc1_adc_data_ch0_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc1_adc_data_ch1_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc1_adc_data_ch1_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc1_adc_data_ch2_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc1_adc_data_ch2_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc1_adc_data_ch3_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc1_adc_data_ch3_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');

    ---- FMC General Status
    --fmc1_prsnt_i                               : in std_logic := '0';
    --fmc1_pg_m2c_i                              : in std_logic := '0';
    --fmc1_clk_dir_i                             : in std_logic := '0';

    -- Trigger
    fmc1_trig_dir_o                            : out std_logic;
    fmc1_trig_term_o                           : out std_logic;
    fmc1_trig_val_p_b                          : inout std_logic;
    fmc1_trig_val_n_b                          : inout std_logic;

    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    fmc1_adc_spi_clk_o                         : out std_logic;
    fmc1_adc_spi_mosi_o                        : out std_logic;
    fmc1_adc_spi_miso_i                        : in std_logic := '0';
    fmc1_adc_spi_cs_adc0_n_o                   : out std_logic;  -- SPI ADC CS channel 0
    fmc1_adc_spi_cs_adc1_n_o                   : out std_logic;  -- SPI ADC CS channel 1
    fmc1_adc_spi_cs_adc2_n_o                   : out std_logic;  -- SPI ADC CS channel 2
    fmc1_adc_spi_cs_adc3_n_o                   : out std_logic;  -- SPI ADC CS channel 3

    -- Si571 clock gen
    fmc1_si571_scl_pad_b                       : inout std_logic;
    fmc1_si571_sda_pad_b                       : inout std_logic;
    fmc1_si571_oe_o                            : out std_logic;

    -- AD9510 clock distribution PLL
    fmc1_spi_ad9510_cs_o                       : out std_logic;
    fmc1_spi_ad9510_sclk_o                     : out std_logic;
    fmc1_spi_ad9510_mosi_o                     : out std_logic;
    fmc1_spi_ad9510_miso_i                     : in std_logic := '0';

    fmc1_pll_function_o                        : out std_logic;
    fmc1_pll_status_i                          : in std_logic := '0';

    -- AD9510 clock copy
    fmc1_fpga_clk_p_i                          : in std_logic := '0';
    fmc1_fpga_clk_n_i                          : in std_logic := '0';

    -- Clock reference selection (TS3USB221)
    fmc1_clk_sel_o                             : out std_logic;

    -- EEPROM (Connected to the CPU)
    --eeprom_scl_pad_b                          : inout std_logic;
    --eeprom_sda_pad_b                          : inout std_logic;
    fmc1_eeprom_scl_pad_b                     : inout std_logic;
    fmc1_eeprom_sda_pad_b                     : inout std_logic;

    -- AMC7823 temperature monitor
    fmc1_amc7823_spi_cs_o                      : out std_logic;
    fmc1_amc7823_spi_sclk_o                    : out std_logic;
    fmc1_amc7823_spi_mosi_o                    : out std_logic;
    fmc1_amc7823_spi_miso_i                    : in std_logic := '0';
    fmc1_amc7823_davn_i                        : in std_logic := '0';

    -- FMC LEDs
    fmc1_led1_o                                : out std_logic;
    fmc1_led2_o                                : out std_logic;
    fmc1_led3_o                                : out std_logic;

    -----------------------------
    -- FMC2_250m_4ch ports
    -----------------------------
    -- ADC clock (half of the sampling frequency) divider reset
    fmc2_adc_clk_div_rst_p_o                   : out std_logic;
    fmc2_adc_clk_div_rst_n_o                   : out std_logic;
    fmc2_adc_ext_rst_n_o                       : out std_logic;
    fmc2_adc_sleep_o                           : out std_logic;

    -- ADC clocks. One clock per ADC channel.
    -- Only ch1 clock is used as all data chains
    -- are sampled at the same frequency
    fmc2_adc_clk0_p_i                          : in std_logic := '0';
    fmc2_adc_clk0_n_i                          : in std_logic := '0';
    fmc2_adc_clk1_p_i                          : in std_logic := '0';
    fmc2_adc_clk1_n_i                          : in std_logic := '0';
    fmc2_adc_clk2_p_i                          : in std_logic := '0';
    fmc2_adc_clk2_n_i                          : in std_logic := '0';
    fmc2_adc_clk3_p_i                          : in std_logic := '0';
    fmc2_adc_clk3_n_i                          : in std_logic := '0';

    -- DDR ADC data channels.
    fmc2_adc_data_ch0_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc2_adc_data_ch0_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc2_adc_data_ch1_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc2_adc_data_ch1_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc2_adc_data_ch2_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc2_adc_data_ch2_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc2_adc_data_ch3_p_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
    fmc2_adc_data_ch3_n_i                      : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');

    ---- FMC General Status
    --fmc2_prsnt_i                               : in std_logic := '0';
    --fmc2_pg_m2c_i                              : in std_logic := '0';
    --fmc2_clk_dir_i                             : in std_logic := '0';

    -- Trigger
    fmc2_trig_dir_o                            : out std_logic;
    fmc2_trig_term_o                           : out std_logic;
    fmc2_trig_val_p_b                          : inout std_logic;
    fmc2_trig_val_n_b                          : inout std_logic;

    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    fmc2_adc_spi_clk_o                         : out std_logic;
    fmc2_adc_spi_mosi_o                        : out std_logic;
    fmc2_adc_spi_miso_i                        : in std_logic := '0';
    fmc2_adc_spi_cs_adc0_n_o                   : out std_logic;  -- SPI ADC CS channel 0
    fmc2_adc_spi_cs_adc1_n_o                   : out std_logic;  -- SPI ADC CS channel 1
    fmc2_adc_spi_cs_adc2_n_o                   : out std_logic;  -- SPI ADC CS channel 2
    fmc2_adc_spi_cs_adc3_n_o                   : out std_logic;  -- SPI ADC CS channel 3

    -- Si571 clock gen
    fmc2_si571_scl_pad_b                       : inout std_logic;
    fmc2_si571_sda_pad_b                       : inout std_logic;
    fmc2_si571_oe_o                            : out std_logic;

    -- AD9510 clock distribution PLL
    fmc2_spi_ad9510_cs_o                       : out std_logic;
    fmc2_spi_ad9510_sclk_o                     : out std_logic;
    fmc2_spi_ad9510_mosi_o                     : out std_logic;
    fmc2_spi_ad9510_miso_i                     : in std_logic := '0';

    fmc2_pll_function_o                        : out std_logic;
    fmc2_pll_status_i                          : in std_logic := '0';

    -- AD9510 clock copy
    fmc2_fpga_clk_p_i                          : in std_logic := '0';
    fmc2_fpga_clk_n_i                          : in std_logic := '0';

    -- Clock reference selection (TS3USB221)
    fmc2_clk_sel_o                             : out std_logic;

    -- EEPROM (Connected to the CPU)
    --eeprom_scl_pad_b                          : inout std_logic;
    --eeprom_sda_pad_b                          : inout std_logic;

    -- AMC7823 temperature monitor
    fmc2_amc7823_spi_cs_o                      : out std_logic;
    fmc2_amc7823_spi_sclk_o                    : out std_logic;
    fmc2_amc7823_spi_mosi_o                    : out std_logic;
    fmc2_amc7823_spi_miso_i                    : in std_logic := '0';
    fmc2_amc7823_davn_i                        : in std_logic := '0';

    -- FMC LEDs
    fmc2_led1_o                                : out std_logic;
    fmc2_led2_o                                : out std_logic;
    fmc2_led3_o                                : out std_logic;

    -----------------------------------------
    -- Position Calc signals
    -----------------------------------------

    -- Uncross signals
    --clk_swap_o                                 : out std_logic;
    --clk_swap2x_o                               : out std_logic;
    --flag1_o                                    : out std_logic;
    --flag2_o                                    : out std_logic;

    -----------------------------------------
    -- General board status
    -----------------------------------------
    --fmc_mmcm_lock_led_o                       : out std_logic;
    --fmc_pll_status_led_o                      : out std_logic

    -----------------------------------------
    -- PCIe pins
    -----------------------------------------

    -- DDR3 memory pins
    ddr3_dq_b                                 : inout std_logic_vector(c_ddr_dq_width-1 downto 0);
    ddr3_dqs_p_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
    ddr3_dqs_n_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
    ddr3_addr_o                               : out   std_logic_vector(c_ddr_row_width-1 downto 0);
    ddr3_ba_o                                 : out   std_logic_vector(c_ddr_bank_width-1 downto 0);
    ddr3_cs_n_o                               : out   std_logic_vector(0 downto 0);
    ddr3_ras_n_o                              : out   std_logic;
    ddr3_cas_n_o                              : out   std_logic;
    ddr3_we_n_o                               : out   std_logic;
    ddr3_reset_n_o                            : out   std_logic;
    ddr3_ck_p_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
    ddr3_ck_n_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
    ddr3_cke_o                                : out   std_logic_vector(c_ddr_cke_width-1 downto 0);
    ddr3_dm_o                                 : out   std_logic_vector(c_ddr_dm_width-1 downto 0);
    ddr3_odt_o                                : out   std_logic_vector(c_ddr_odt_width-1 downto 0);

    -- PCIe transceivers
    pci_exp_rxp_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_rxn_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_txp_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);
    pci_exp_txn_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);

    -- PCI clock and reset signals
    pcie_clk_p_i                              : in std_logic;
    pcie_clk_n_i                              : in std_logic;

    -----------------------------------------
    -- Button pins
    -----------------------------------------
    --buttons_i                                 : in std_logic_vector(7 downto 0);

    -----------------------------------------
    -- User LEDs
    -----------------------------------------
    leds_o                                    : out std_logic_vector(2 downto 0)
  );
  end component;

begin

  cmp_dbe_bpm_gen : dbe_bpm_gen
  generic map (
    g_fmc_adc_type                             := "FMC250M"
  )
  port map (
    -----------------------------------------
    -- Clocking pins
    -----------------------------------------
    sys_clk_p_i                                => sys_clk_p_i,
    sys_clk_n_i                                => sys_clk_n_i,

    -----------------------------------------
    -- Reset Button
    -----------------------------------------
    sys_rst_button_n_i                         => sys_rst_button_n_i,

    -----------------------------------------
    -- UART pins
    -----------------------------------------

    rs232_txd_o                                => rs232_txd_o,
    rs232_rxd_i                                => rs232_rxd_i,

    -----------------------------------------
    -- Trigger pins
    -----------------------------------------

    trig_dir_o                                 => trig_dir_o,
    trig_b                                     => trig_b,

    -----------------------------
    -- AFC Diagnostics
    -----------------------------

    diag_spi_cs_i                              => diag_spi_cs_i,
    diag_spi_si_i                              => diag_spi_si_i,
    diag_spi_so_o                              => diag_spi_so_o,
    diag_spi_clk_i                             => diag_spi_clk_i,

    -----------------------------
    -- ADN4604ASVZ
    -----------------------------
    adn4604_vadj2_clk_updt_n_o                 => adn4604_vadj2_clk_updt_n_o,

    -----------------------------
    -- FMC1_250m_4ch ports
    -----------------------------

    -- ADC clock (half of the sampling frequency) divider reset
    fmc1_adc_clk_div_rst_p_o                   => fmc1_adc_clk_div_rst_p_o,
    fmc1_adc_clk_div_rst_n_o                   => fmc1_adc_clk_div_rst_n_o,
    fmc1_adc_ext_rst_n_o                       => fmc1_adc_ext_rst_n_o,
    fmc1_adc_sleep_o                           => fmc1_adc_sleep_o,

    -- ADC clocks. One clock per ADC channel.
    -- Only ch1 clock is used as all data chains
    -- are sampled at the same frequency
    fmc1_adc_clk0_p_i                          => fmc1_adc_clk0_p_i,
    fmc1_adc_clk0_n_i                          => fmc1_adc_clk0_n_i,
    fmc1_adc_clk1_p_i                          => fmc1_adc_clk1_p_i,
    fmc1_adc_clk1_n_i                          => fmc1_adc_clk1_n_i,
    fmc1_adc_clk2_p_i                          => fmc1_adc_clk2_p_i,
    fmc1_adc_clk2_n_i                          => fmc1_adc_clk2_n_i,
    fmc1_adc_clk3_p_i                          => fmc1_adc_clk3_p_i,
    fmc1_adc_clk3_n_i                          => fmc1_adc_clk3_n_i,

    -- DDR ADC data channels.
    fmc1_adc_data_ch0_p_i                      => fmc1_adc_data_ch0_p_i,
    fmc1_adc_data_ch0_n_i                      => fmc1_adc_data_ch0_n_i,
    fmc1_adc_data_ch1_p_i                      => fmc1_adc_data_ch1_p_i,
    fmc1_adc_data_ch1_n_i                      => fmc1_adc_data_ch1_n_i,
    fmc1_adc_data_ch2_p_i                      => fmc1_adc_data_ch2_p_i,
    fmc1_adc_data_ch2_n_i                      => fmc1_adc_data_ch2_n_i,
    fmc1_adc_data_ch3_p_i                      => fmc1_adc_data_ch3_p_i,
    fmc1_adc_data_ch3_n_i                      => fmc1_adc_data_ch3_n_i,

    ---- FMC General Status
    --fmc1_prsnt_i                               : in std_logic := '0';
    --fmc1_pg_m2c_i                              : in std_logic := '0';
    --fmc1_clk_dir_i                             : in std_logic := '0';

    -- Trigger
    fmc1_trig_dir_o                            => fmc1_trig_dir_o,
    fmc1_trig_term_o                           => fmc1_trig_term_o,
    fmc1_trig_val_p_b                          => fmc1_trig_val_p_b,
    fmc1_trig_val_n_b                          => fmc1_trig_val_n_b,

    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    fmc1_adc_spi_clk_o                         => fmc1_adc_spi_clk_o,
    fmc1_adc_spi_mosi_o                        => fmc1_adc_spi_mosi_o,
    fmc1_adc_spi_miso_i                        => fmc1_adc_spi_miso_i,
    fmc1_adc_spi_cs_adc0_n_o                   => fmc1_adc_spi_cs_adc0_n_o,
    fmc1_adc_spi_cs_adc1_n_o                   => fmc1_adc_spi_cs_adc1_n_o,
    fmc1_adc_spi_cs_adc2_n_o                   => fmc1_adc_spi_cs_adc2_n_o,
    fmc1_adc_spi_cs_adc3_n_o                   => fmc1_adc_spi_cs_adc3_n_o,

    -- Si571 clock gen
    fmc1_si571_scl_pad_b                       => fmc1_si571_scl_pad_b,
    fmc1_si571_sda_pad_b                       => fmc1_si571_sda_pad_b,
    fmc1_si571_oe_o                            => fmc1_si571_oe_o,

    -- AD9510 clock distribution PLL
    fmc1_spi_ad9510_cs_o                       => fmc1_spi_ad9510_cs_o,
    fmc1_spi_ad9510_sclk_o                     => fmc1_spi_ad9510_sclk_o,
    fmc1_spi_ad9510_mosi_o                     => fmc1_spi_ad9510_mosi_o,
    fmc1_spi_ad9510_miso_i                     => fmc1_spi_ad9510_miso_i,

    fmc1_pll_function_o                        => fmc1_pll_function_o,
    fmc1_pll_status_i                          => fmc1_pll_status_i,

    -- AD9510 clock copy
    fmc1_fpga_clk_p_i                          => fmc1_fpga_clk_p_i,
    fmc1_fpga_clk_n_i                          => fmc1_fpga_clk_n_i,

    -- Clock reference selection (TS3USB221)
    fmc1_clk_sel_o                             => fmc1_clk_sel_o,

    -- EEPROM (Connected to the CPU)
    --eeprom_scl_pad_b                          : inout std_logic;
    --eeprom_sda_pad_b                          : inout std_logic;
    fmc1_eeprom_scl_pad_b                     => fmc1_eeprom_scl_pad_b,
    fmc1_eeprom_sda_pad_b                     => fmc1_eeprom_sda_pad_b,

    -- AMC7823 temperature monitor
    fmc1_amc7823_spi_cs_o                      => fmc1_amc7823_spi_cs_o,
    fmc1_amc7823_spi_sclk_o                    => fmc1_amc7823_spi_sclk_o,
    fmc1_amc7823_spi_mosi_o                    => fmc1_amc7823_spi_mosi_o,
    fmc1_amc7823_spi_miso_i                    => fmc1_amc7823_spi_miso_i,
    fmc1_amc7823_davn_i                        => fmc1_amc7823_davn_i,

    -- FMC LEDs
    fmc1_led1_o                                => fmc1_led1_o,
    fmc1_led2_o                                => fmc1_led2_o,
    fmc1_led3_o                                => fmc1_led3_o,

    -----------------------------
    -- FMC2_250m_4ch ports
    -----------------------------
    -- ADC clock (half of the sampling frequency) divider reset
    fmc2_adc_clk_div_rst_p_o                   => fmc2_adc_clk_div_rst_p_o,
    fmc2_adc_clk_div_rst_n_o                   => fmc2_adc_clk_div_rst_n_o,
    fmc2_adc_ext_rst_n_o                       => fmc2_adc_ext_rst_n_o,
    fmc2_adc_sleep_o                           => fmc2_adc_sleep_o,

    -- ADC clocks. One clock per ADC channel.
    -- Only ch1 clock is used as all data chains
    -- are sampled at the same frequency
    fmc2_adc_clk0_p_i                          => fmc2_adc_clk0_p_i,
    fmc2_adc_clk0_n_i                          => fmc2_adc_clk0_n_i,
    fmc2_adc_clk1_p_i                          => fmc2_adc_clk1_p_i,
    fmc2_adc_clk1_n_i                          => fmc2_adc_clk1_n_i,
    fmc2_adc_clk2_p_i                          => fmc2_adc_clk2_p_i,
    fmc2_adc_clk2_n_i                          => fmc2_adc_clk2_n_i,
    fmc2_adc_clk3_p_i                          => fmc2_adc_clk3_p_i,
    fmc2_adc_clk3_n_i                          => fmc2_adc_clk3_n_i,

    -- DDR ADC data channels.
    fmc2_adc_data_ch0_p_i                      => fmc2_adc_data_ch0_p_i,
    fmc2_adc_data_ch0_n_i                      => fmc2_adc_data_ch0_n_i,
    fmc2_adc_data_ch1_p_i                      => fmc2_adc_data_ch1_p_i,
    fmc2_adc_data_ch1_n_i                      => fmc2_adc_data_ch1_n_i,
    fmc2_adc_data_ch2_p_i                      => fmc2_adc_data_ch2_p_i,
    fmc2_adc_data_ch2_n_i                      => fmc2_adc_data_ch2_n_i,
    fmc2_adc_data_ch3_p_i                      => fmc2_adc_data_ch3_p_i,
    fmc2_adc_data_ch3_n_i                      => fmc2_adc_data_ch3_n_i,

    ---- FMC General Status
    --fmc2_prsnt_i                               : in std_logic := '0';
    --fmc2_pg_m2c_i                              : in std_logic := '0';
    --fmc2_clk_dir_i                             : in std_logic := '0';

    -- Trigger
    fmc2_trig_dir_o                            => fmc2_trig_dir_o,
    fmc2_trig_term_o                           => fmc2_trig_term_o,
    fmc2_trig_val_p_b                          => fmc2_trig_val_p_b,
    fmc2_trig_val_n_b                          => fmc2_trig_val_n_b,

    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    fmc2_adc_spi_clk_o                         => fmc2_adc_spi_clk_o,
    fmc2_adc_spi_mosi_o                        => fmc2_adc_spi_mosi_o,
    fmc2_adc_spi_miso_i                        => fmc2_adc_spi_miso_i,
    fmc2_adc_spi_cs_adc0_n_o                   => fmc2_adc_spi_cs_adc0_n_o,
    fmc2_adc_spi_cs_adc1_n_o                   => fmc2_adc_spi_cs_adc1_n_o,
    fmc2_adc_spi_cs_adc2_n_o                   => fmc2_adc_spi_cs_adc2_n_o,
    fmc2_adc_spi_cs_adc3_n_o                   => fmc2_adc_spi_cs_adc3_n_o,

    -- Si571 clock gen
    fmc2_si571_scl_pad_b                       => fmc2_si571_scl_pad_b,
    fmc2_si571_sda_pad_b                       => fmc2_si571_sda_pad_b,
    fmc2_si571_oe_o                            => fmc2_si571_oe_o,

    -- AD9510 clock distribution PLL
    fmc2_spi_ad9510_cs_o                       => fmc2_spi_ad9510_cs_o,
    fmc2_spi_ad9510_sclk_o                     => fmc2_spi_ad9510_sclk_o,
    fmc2_spi_ad9510_mosi_o                     => fmc2_spi_ad9510_mosi_o,
    fmc2_spi_ad9510_miso_i                     => fmc2_spi_ad9510_miso_i,

    fmc2_pll_function_o                        => fmc2_pll_function_o,
    fmc2_pll_status_i                          => fmc2_pll_status_i,

    -- AD9510 clock copy
    fmc2_fpga_clk_p_i                          => fmc2_fpga_clk_p_i,
    fmc2_fpga_clk_n_i                          => fmc2_fpga_clk_n_i,

    -- Clock reference selection (TS3USB221)
    fmc2_clk_sel_o                             => fmc2_clk_sel_o,

    -- EEPROM (Connected to the CPU)
    --eeprom_scl_pad_b                          : inout std_logic;
    --eeprom_sda_pad_b                          : inout std_logic;

    -- AMC7823 temperature monitor
    fmc2_amc7823_spi_cs_o                      => fmc2_amc7823_spi_cs_o,
    fmc2_amc7823_spi_sclk_o                    => fmc2_amc7823_spi_sclk_o,
    fmc2_amc7823_spi_mosi_o                    => fmc2_amc7823_spi_mosi_o,
    fmc2_amc7823_spi_miso_i                    => fmc2_amc7823_spi_miso_i,
    fmc2_amc7823_davn_i                        => fmc2_amc7823_davn_i,

    -- FMC LEDs
    fmc2_led1_o                                => fmc2_led1_o,
    fmc2_led2_o                                => fmc2_led2_o,
    fmc2_led3_o                                => fmc2_led3_o,

    -----------------------------------------
    -- Position Calc signals
    -----------------------------------------

    -- Uncross signals
    --clk_swap_o                                 : out std_logic;
    --clk_swap2x_o                               : out std_logic;
    --flag1_o                                    : out std_logic;
    --flag2_o                                    : out std_logic;

    -----------------------------------------
    -- General board status
    -----------------------------------------
    --fmc_mmcm_lock_led_o                       : out std_logic;
    --fmc_pll_status_led_o                      : out std_logic

    -----------------------------------------
    -- PCIe pins
    -----------------------------------------

    -- DDR3 memory pins
    ddr3_dq_b                                 => ddr3_dq_b,
    ddr3_dqs_p_b                              => ddr3_dqs_p_b,
    ddr3_dqs_n_b                              => ddr3_dqs_n_b,
    ddr3_addr_o                               => ddr3_addr_o,
    ddr3_ba_o                                 => ddr3_ba_o,
    ddr3_cs_n_o                               => ddr3_cs_n_o,
    ddr3_ras_n_o                              => ddr3_ras_n_o,
    ddr3_cas_n_o                              => ddr3_cas_n_o,
    ddr3_we_n_o                               => ddr3_we_n_o,
    ddr3_reset_n_o                            => ddr3_reset_n_o,
    ddr3_ck_p_o                               => ddr3_ck_p_o,
    ddr3_ck_n_o                               => ddr3_ck_n_o,
    ddr3_cke_o                                => ddr3_cke_o,
    ddr3_dm_o                                 => ddr3_dm_o,
    ddr3_odt_o                                => ddr3_odt_o,

    -- PCIe transceivers
    pci_exp_rxp_i                             => pci_exp_rxp_i,
    pci_exp_rxn_i                             => pci_exp_rxn_i,
    pci_exp_txp_o                             => pci_exp_txp_o,
    pci_exp_txn_o                             => pci_exp_txn_o,

    -- PCI clock and reset signals
    pcie_clk_p_i                              => pcie_clk_p_i,
    pcie_clk_n_i                              => pcie_clk_n_i,

    -----------------------------------------
    -- Button pins
    -----------------------------------------
    --buttons_i                                 : in std_logic_vector(7 downto 0);

    -----------------------------------------
    -- User LEDs
    -----------------------------------------
    leds_o                                    => leds_o
  );

end rtl;
