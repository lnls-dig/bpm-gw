------------------------------------------------------------------------------
-- Title      : Top generic BPM design with FMC130M and FMC250 options
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2016-11-11
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top generic BPM design with FMC130 or FMC250 ADC boards
-------------------------------------------------------------------------------
-- Copyright (c) 2016 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-11-11  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Memory core generator
use work.gencores_pkg.all;
-- Custom Wishbone Modules
use work.ifc_wishbone_pkg.all;
-- Custom common cores
use work.ifc_common_pkg.all;
-- Wishbone stream modules and interface
use work.wb_stream_generic_pkg.all;
-- FMC ADC definitions
use work.fmc_adc_pkg.all;
-- DSP definitions
use work.dsp_cores_pkg.all;
-- Positicon Calc constants
use work.machine_pkg.all;
-- Genrams
use work.genram_pkg.all;
-- Data Acquisition core
use work.acq_core_pkg.all;
-- IP cores constants
use work.ipcores_pkg.all;
-- Meta Package
use work.synthesis_descriptor_pkg.all;
-- AXI cores
use work.pcie_cntr_axi_pkg.all;
-- Trigger Modules
use work.trigger_pkg.all;

entity dbe_bpm_gen is
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
  fmc130_1_adc_pga_o                         : out std_logic;
  fmc130_1_adc_shdn_o                        : out std_logic;
  fmc130_1_adc_dith_o                        : out std_logic;
  fmc130_1_adc_rand_o                        : out std_logic;

  -- ADC0 LTC2208
  fmc130_1_adc0_clk_i                        : in std_logic := '0';
  fmc130_1_adc0_data_i                       : in std_logic_vector(16-1 downto 0) := (others => '0');
  fmc130_1_adc0_of_i                         : in std_logic := '0'; -- Unused

  -- ADC1 LTC2208
  fmc130_1_adc1_clk_i                        : in std_logic := '0';
  fmc130_1_adc1_data_i                       : in std_logic_vector(16-1 downto 0) := (others => '0');
  fmc130_1_adc1_of_i                         : in std_logic := '0'; -- Unused

  -- ADC2 LTC2208
  fmc130_1_adc2_clk_i                        : in std_logic := '0';
  fmc130_1_adc2_data_i                       : in std_logic_vector(16-1 downto 0) := (others => '0');
  fmc130_1_adc2_of_i                         : in std_logic := '0'; -- Unused

  -- ADC3 LTC2208
  fmc130_1_adc3_clk_i                        : in std_logic := '0';
  fmc130_1_adc3_data_i                       : in std_logic_vector(16-1 downto 0) := (others => '0');
  fmc130_1_adc3_of_i                         : in std_logic := '0'; -- Unused

  ---- FMC General Status
  --fmc130_1_prsnt_i                           : in std_logic := '0';
  --fmc130_1_pg_m2c_i                          : in std_logic := '0';
  --fmc130_1_clk_dir_i                         : in std_logic := '0';

  -- Trigger
  fmc130_1_trig_dir_o                        : out std_logic;
  fmc130_1_trig_term_o                       : out std_logic;
  fmc130_1_trig_val_p_b                      : inout std_logic;
  fmc130_1_trig_val_n_b                      : inout std_logic;

  -- Si571 clock gen
  fmc130_1_si571_scl_pad_b                   : inout std_logic;
  fmc130_1_si571_sda_pad_b                   : inout std_logic;
  fmc130_1_si571_oe_o                        : out std_logic;

  -- AD9510 clock distribution PLL
  fmc130_1_spi_ad9510_cs_o                   : out std_logic;
  fmc130_1_spi_ad9510_sclk_o                 : out std_logic;
  fmc130_1_spi_ad9510_mosi_o                 : out std_logic;
  fmc130_1_spi_ad9510_miso_i                 : in std_logic := '0';

  fmc130_1_pll_function_o                    : out std_logic;
  fmc130_1_pll_status_i                      : in std_logic := '0';

  -- AD9510 clock copy
  fmc130_1_fpga_clk_p_i                      : in std_logic := '0';
  fmc130_1_fpga_clk_n_i                      : in std_logic := '0';

  -- Clock reference selection (TS3USB221)
  fmc130_1_clk_sel_o                         : out std_logic;

  -- EEPROM (Connected to the CPU)
  --eeprom_scl_pad_b                          : inout std_logic;
  --eeprom_sda_pad_b                          : inout std_logic;
  fmc130_1_eeprom_scl_pad_b                  : inout std_logic;
  fmc130_1_eeprom_sda_pad_b                  : inout std_logic;

  -- Temperature monitor (LM75AIMM)
  fmc130_1_lm75_scl_pad_b                    : inout std_logic;
  fmc130_1_lm75_sda_pad_b                    : inout std_logic;

  fmc130_1_lm75_temp_alarm_i                 : in std_logic := '0';

  -- FMC LEDs
  fmc130_1_led1_o                            : out std_logic;
  fmc130_1_led2_o                            : out std_logic;
  fmc130_1_led3_o                            : out std_logic;

  -----------------------------
  -- FMC2_130m_4ch ports
  -----------------------------

  -- ADC LTC2208 interface
  fmc130_2_adc_pga_o                         : out std_logic;
  fmc130_2_adc_shdn_o                        : out std_logic;
  fmc130_2_adc_dith_o                        : out std_logic;
  fmc130_2_adc_rand_o                        : out std_logic;

  -- ADC0 LTC2208
  fmc130_2_adc0_clk_i                        : in std_logic := '0';
  fmc130_2_adc0_data_i                       : in std_logic_vector(16-1 downto 0) := (others => '0');
  fmc130_2_adc0_of_i                         : in std_logic := '0'; -- Unused

  -- ADC1 LTC2208
  fmc130_2_adc1_clk_i                        : in std_logic := '0';
  fmc130_2_adc1_data_i                       : in std_logic_vector(16-1 downto 0) := (others => '0');
  fmc130_2_adc1_of_i                         : in std_logic := '0'; -- Unused

  -- ADC2 LTC2208
  fmc130_2_adc2_clk_i                        : in std_logic := '0';
  fmc130_2_adc2_data_i                       : in std_logic_vector(16-1 downto 0) := (others => '0');
  fmc130_2_adc2_of_i                         : in std_logic := '0'; -- Unused

  -- ADC3 LTC2208
  fmc130_2_adc3_clk_i                        : in std_logic := '0';
  fmc130_2_adc3_data_i                       : in std_logic_vector(16-1 downto 0) := (others => '0');
  fmc130_2_adc3_of_i                         : in std_logic := '0'; -- Unused

  ---- FMC General Status
  --fmc130_2_prsnt_i                           : in std_logic := '0';
  --fmc130_2_pg_m2c_i                          : in std_logic := '0';
  --fmc130_2_clk_dir_i                         : in std_logic := '0';

  -- Trigger
  fmc130_2_trig_dir_o                        : out std_logic;
  fmc130_2_trig_term_o                       : out std_logic;
  fmc130_2_trig_val_p_b                      : inout std_logic;
  fmc130_2_trig_val_n_b                      : inout std_logic;

  -- Si571 clock gen
  fmc130_2_si571_scl_pad_b                   : inout std_logic;
  fmc130_2_si571_sda_pad_b                   : inout std_logic;
  fmc130_2_si571_oe_o                        : out std_logic;

  -- AD9510 clock distribution PLL
  fmc130_2_spi_ad9510_cs_o                   : out std_logic;
  fmc130_2_spi_ad9510_sclk_o                 : out std_logic;
  fmc130_2_spi_ad9510_mosi_o                 : out std_logic;
  fmc130_2_spi_ad9510_miso_i                 : in std_logic := '0';

  fmc130_2_pll_function_o                    : out std_logic;
  fmc130_2_pll_status_i                      : in std_logic := '0';

  -- AD9510 clock copy
  fmc130_2_fpga_clk_p_i                      : in std_logic := '0';
  fmc130_2_fpga_clk_n_i                      : in std_logic := '0';

  -- Clock reference selection (TS3USB221)
  fmc130_2_clk_sel_o                         : out std_logic;

  -- EEPROM (Connected to the CPU)
  --eeprom_scl_pad_b                          : inout std_logic;
  --eeprom_sda_pad_b                          : inout std_logic;

  -- Temperature monitor (LM75AIMM)
  fmc130_2_lm75_scl_pad_b                    : inout std_logic;
  fmc130_2_lm75_sda_pad_b                    : inout std_logic;

  fmc130_2_lm75_temp_alarm_i                 : in std_logic := '0';

  -- FMC LEDs
  fmc130_2_led1_o                            : out std_logic;
  fmc130_2_led2_o                            : out std_logic;
  fmc130_2_led3_o                            : out std_logic;

  -----------------------------
  -- FMC1_250m_4ch ports
  -----------------------------

  -- ADC clock (half of the sampling frequency) divider reset
  fmc250_1_adc_clk_div_rst_p_o               : out std_logic;
  fmc250_1_adc_clk_div_rst_n_o               : out std_logic;
  fmc250_1_adc_ext_rst_n_o                   : out std_logic;
  fmc250_1_adc_sleep_o                       : out std_logic;

  -- ADC clocks. One clock per ADC channel.
  -- Only ch1 clock is used as all data chains
  -- are sampled at the same frequency
  fmc250_1_adc_clk0_p_i                      : in std_logic := '0';
  fmc250_1_adc_clk0_n_i                      : in std_logic := '0';
  fmc250_1_adc_clk1_p_i                      : in std_logic := '0';
  fmc250_1_adc_clk1_n_i                      : in std_logic := '0';
  fmc250_1_adc_clk2_p_i                      : in std_logic := '0';
  fmc250_1_adc_clk2_n_i                      : in std_logic := '0';
  fmc250_1_adc_clk3_p_i                      : in std_logic := '0';
  fmc250_1_adc_clk3_n_i                      : in std_logic := '0';

  -- DDR ADC data channels.
  fmc250_1_adc_data_ch0_p_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_1_adc_data_ch0_n_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_1_adc_data_ch1_p_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_1_adc_data_ch1_n_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_1_adc_data_ch2_p_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_1_adc_data_ch2_n_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_1_adc_data_ch3_p_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_1_adc_data_ch3_n_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');

  ---- FMC General Status
  --fmc250_1_prsnt_i                           : in std_logic := '0';
  --fmc250_1_pg_m2c_i                          : in std_logic := '0';
  --fmc250_1_clk_dir_i                         : in std_logic := '0';

  -- Trigger
  fmc250_1_trig_dir_o                        : out std_logic;
  fmc250_1_trig_term_o                       : out std_logic;
  fmc250_1_trig_val_p_b                      : inout std_logic;
  fmc250_1_trig_val_n_b                      : inout std_logic;

  -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
  fmc250_1_adc_spi_clk_o                     : out std_logic;
  fmc250_1_adc_spi_mosi_o                    : out std_logic;
  fmc250_1_adc_spi_miso_i                    : in std_logic := '0';
  fmc250_1_adc_spi_cs_adc0_n_o               : out std_logic;  -- SPI ADC CS channel 0
  fmc250_1_adc_spi_cs_adc1_n_o               : out std_logic;  -- SPI ADC CS channel 1
  fmc250_1_adc_spi_cs_adc2_n_o               : out std_logic;  -- SPI ADC CS channel 2
  fmc250_1_adc_spi_cs_adc3_n_o               : out std_logic;  -- SPI ADC CS channel 3

  -- Si571 clock gen
  fmc250_1_si571_scl_pad_b                   : inout std_logic;
  fmc250_1_si571_sda_pad_b                   : inout std_logic;
  fmc250_1_si571_oe_o                        : out std_logic;

  -- AD9510 clock distribution PLL
  fmc250_1_spi_ad9510_cs_o                   : out std_logic;
  fmc250_1_spi_ad9510_sclk_o                 : out std_logic;
  fmc250_1_spi_ad9510_mosi_o                 : out std_logic;
  fmc250_1_spi_ad9510_miso_i                 : in std_logic := '0';

  fmc250_1_pll_function_o                    : out std_logic;
  fmc250_1_pll_status_i                      : in std_logic := '0';

  -- AD9510 clock copy
  fmc250_1_fpga_clk_p_i                      : in std_logic := '0';
  fmc250_1_fpga_clk_n_i                      : in std_logic := '0';

  -- Clock reference selection (TS3USB221)
  fmc250_1_clk_sel_o                         : out std_logic;

  -- EEPROM (Connected to the CPU)
  --eeprom_scl_pad_b                          : inout std_logic;
  --eeprom_sda_pad_b                          : inout std_logic;
  fmc250_1_eeprom_scl_pad_b                  : inout std_logic;
  fmc250_1_eeprom_sda_pad_b                  : inout std_logic;

  -- AMC7823 temperature monitor
  fmc250_1_amc7823_spi_cs_o                  : out std_logic;
  fmc250_1_amc7823_spi_sclk_o                : out std_logic;
  fmc250_1_amc7823_spi_mosi_o                : out std_logic;
  fmc250_1_amc7823_spi_miso_i                : in std_logic := '0';
  fmc250_1_amc7823_davn_i                    : in std_logic := '0';

  -- FMC LEDs
  fmc250_1_led1_o                            : out std_logic;
  fmc250_1_led2_o                            : out std_logic;
  fmc250_1_led3_o                            : out std_logic;

  -----------------------------
  -- FMC2_250m_4ch ports
  -----------------------------
  -- ADC clock (half of the sampling frequency) divider reset
  fmc250_2_adc_clk_div_rst_p_o               : out std_logic;
  fmc250_2_adc_clk_div_rst_n_o               : out std_logic;
  fmc250_2_adc_ext_rst_n_o                   : out std_logic;
  fmc250_2_adc_sleep_o                       : out std_logic;

  -- ADC clocks. One clock per ADC channel.
  -- Only ch1 clock is used as all data chains
  -- are sampled at the same frequency
  fmc250_2_adc_clk0_p_i                      : in std_logic := '0';
  fmc250_2_adc_clk0_n_i                      : in std_logic := '0';
  fmc250_2_adc_clk1_p_i                      : in std_logic := '0';
  fmc250_2_adc_clk1_n_i                      : in std_logic := '0';
  fmc250_2_adc_clk2_p_i                      : in std_logic := '0';
  fmc250_2_adc_clk2_n_i                      : in std_logic := '0';
  fmc250_2_adc_clk3_p_i                      : in std_logic := '0';
  fmc250_2_adc_clk3_n_i                      : in std_logic := '0';

  -- DDR ADC data channels.
  fmc250_2_adc_data_ch0_p_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_2_adc_data_ch0_n_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_2_adc_data_ch1_p_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_2_adc_data_ch1_n_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_2_adc_data_ch2_p_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_2_adc_data_ch2_n_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_2_adc_data_ch3_p_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');
  fmc250_2_adc_data_ch3_n_i                  : in std_logic_vector(16/2-1 downto 0) := (others => '0');

  ---- FMC General Status
  --fmc250_2_prsnt_i                           : in std_logic := '0';
  --fmc250_2_pg_m2c_i                          : in std_logic := '0';
  --fmc250_2_clk_dir_i                         : in std_logic := '0';

  -- Trigger
  fmc250_2_trig_dir_o                        : out std_logic;
  fmc250_2_trig_term_o                       : out std_logic;
  fmc250_2_trig_val_p_b                      : inout std_logic;
  fmc250_2_trig_val_n_b                      : inout std_logic;

  -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
  fmc250_2_adc_spi_clk_o                     : out std_logic;
  fmc250_2_adc_spi_mosi_o                    : out std_logic;
  fmc250_2_adc_spi_miso_i                    : in std_logic := '0';
  fmc250_2_adc_spi_cs_adc0_n_o               : out std_logic;  -- SPI ADC CS channel 0
  fmc250_2_adc_spi_cs_adc1_n_o               : out std_logic;  -- SPI ADC CS channel 1
  fmc250_2_adc_spi_cs_adc2_n_o               : out std_logic;  -- SPI ADC CS channel 2
  fmc250_2_adc_spi_cs_adc3_n_o               : out std_logic;  -- SPI ADC CS channel 3

  -- Si571 clock gen
  fmc250_2_si571_scl_pad_b                   : inout std_logic;
  fmc250_2_si571_sda_pad_b                   : inout std_logic;
  fmc250_2_si571_oe_o                        : out std_logic;

  -- AD9510 clock distribution PLL
  fmc250_2_spi_ad9510_cs_o                   : out std_logic;
  fmc250_2_spi_ad9510_sclk_o                 : out std_logic;
  fmc250_2_spi_ad9510_mosi_o                 : out std_logic;
  fmc250_2_spi_ad9510_miso_i                 : in std_logic := '0';

  fmc250_2_pll_function_o                    : out std_logic;
  fmc250_2_pll_status_i                      : in std_logic := '0';

  -- AD9510 clock copy
  fmc250_2_fpga_clk_p_i                      : in std_logic := '0';
  fmc250_2_fpga_clk_n_i                      : in std_logic := '0';

  -- Clock reference selection (TS3USB221)
  fmc250_2_clk_sel_o                         : out std_logic;

  -- EEPROM (Connected to the CPU)
  --eeprom_scl_pad_b                          : inout std_logic;
  --eeprom_sda_pad_b                          : inout std_logic;

  -- AMC7823 temperature monitor
  fmc250_2_amc7823_spi_cs_o                  : out std_logic;
  fmc250_2_amc7823_spi_sclk_o                : out std_logic;
  fmc250_2_amc7823_spi_mosi_o                : out std_logic;
  fmc250_2_amc7823_spi_miso_i                : in std_logic := '0';
  fmc250_2_amc7823_davn_i                    : in std_logic := '0';

  -- FMC LEDs
  fmc250_2_led1_o                            : out std_logic;
  fmc250_2_led2_o                            : out std_logic;
  fmc250_2_led3_o                            : out std_logic;

  -----------------------------------------
  -- FMC PICO 1M_4CH Ports
  -----------------------------------------

  fmcpico_1_adc_cnv_o                        : out std_logic;
  fmcpico_1_adc_sck_o                        : out std_logic;
  fmcpico_1_adc_sck_rtrn_i                   : in std_logic := '0';
  fmcpico_1_adc_sdo1_i                       : in std_logic := '0';
  fmcpico_1_adc_sdo2_i                       : in std_logic := '0';
  fmcpico_1_adc_sdo3_i                       : in std_logic := '0';
  fmcpico_1_adc_sdo4_i                       : in std_logic := '0';
  fmcpico_1_adc_busy_cmn_i                   : in std_logic := '0';

  fmcpico_1_rng_r1_o                         : out std_logic;
  fmcpico_1_rng_r2_o                         : out std_logic;
  fmcpico_1_rng_r3_o                         : out std_logic;
  fmcpico_1_rng_r4_o                         : out std_logic;

  fmcpico_1_led1_o                           : out std_logic;
  fmcpico_1_led2_o                           : out std_logic;

  fmcpico_1_sm_scl_o                         : out std_logic;
  fmcpico_1_sm_sda_b                         : inout std_logic;

  fmcpico_1_a_scl_o                          : out std_logic;
  fmcpico_1_a_sda_b                          : inout std_logic;

  -----------------------------------------
  -- FMC PICO 1M_4CH Ports
  -----------------------------------------
  fmcpico_2_adc_cnv_o                        : out std_logic;
  fmcpico_2_adc_sck_o                        : out std_logic;
  fmcpico_2_adc_sck_rtrn_i                   : in std_logic := '0';
  fmcpico_2_adc_sdo1_i                       : in std_logic := '0';
  fmcpico_2_adc_sdo2_i                       : in std_logic := '0';
  fmcpico_2_adc_sdo3_i                       : in std_logic := '0';
  fmcpico_2_adc_sdo4_i                       : in std_logic := '0';
  fmcpico_2_adc_busy_cmn_i                   : in std_logic := '0';

  fmcpico_2_rng_r1_o                         : out std_logic;
  fmcpico_2_rng_r2_o                         : out std_logic;
  fmcpico_2_rng_r3_o                         : out std_logic;
  fmcpico_2_rng_r4_o                         : out std_logic;

  fmcpico_2_led1_o                           : out std_logic;
  fmcpico_2_led2_o                           : out std_logic;

  ---- Connected through FPGA MUX
  --fmcpico_2_sm_scl_o                         : out std_logic;
  --fmcpico_2_sm_sda_b                         : inout std_logic;

  fmcpico_2_a_scl_o                          : out std_logic;
  fmcpico_2_a_sda_b                          : inout std_logic;

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
end dbe_bpm_gen;

architecture rtl of dbe_bpm_gen is

  function f_num_bits_adc(adc_type : string)
      return natural is
  begin
    if (adc_type = "FMC130M") then
      return 16;
    elsif (adc_type = "FMC250M") then
      return 16;
    elsif (adc_type = "FMCPICO_1M") then
      return 20;
    else
      return 16;
    end if;
  end f_num_bits_adc;

  function f_num_bits_se_adc(adc_type : string)
      return natural is
  begin
    if (adc_type = "FMC130M") then
      return 16;
    elsif (adc_type = "FMC250M") then
      return 16;
  elsif (adc_type = "FMCPICO_1M") then
      -- next power of 2
      return 32;
    else
      return 16;
    end if;
  end f_num_bits_se_adc;

  function f_acq_channel_adc_param(adc_type : string)
      return t_facq_chan_param is
    variable v_facq_chan                  : t_facq_chan_param;
  begin
    if (adc_type = "FMC130M") then
      v_facq_chan := (width => to_unsigned(64, c_acq_chan_cmplt_width_log2),
                      num_atoms => to_unsigned(4, c_acq_num_atoms_width_log2),
                      atom_width => to_unsigned(16, c_acq_atom_width_log2) -- 2^4 = 16-bit
                     );
    elsif (adc_type = "FMC250M") then
      v_facq_chan := (width => to_unsigned(64, c_acq_chan_cmplt_width_log2),
                      num_atoms => to_unsigned(4, c_acq_num_atoms_width_log2),
                      atom_width => to_unsigned(16, c_acq_atom_width_log2) -- 2^4 = 16-bit
                     );
    elsif (adc_type = "FMCPICO_1M") then
      v_facq_chan := (width => to_unsigned(128, c_acq_chan_cmplt_width_log2),
                      num_atoms => to_unsigned(4, c_acq_num_atoms_width_log2),
                      atom_width => to_unsigned(32, c_acq_atom_width_log2) -- 2^5 = 32-bit
                     );
    else
      v_facq_chan := (width => to_unsigned(64, c_acq_chan_cmplt_width_log2),
                      num_atoms => to_unsigned(4, c_acq_num_atoms_width_log2),
                      atom_width => to_unsigned(16, c_acq_atom_width_log2) -- 2^4 = 16-bit
                     );
    end if;
    return v_facq_chan;
  end f_acq_channel_adc_param;

  -- FIXME: get these values from machine_pkg.vhd for each machine
  function f_acq_channel_mix_param(adc_type : string)
      return t_facq_chan_param is
    variable v_facq_chan                  : t_facq_chan_param;
  begin
    if (adc_type = "FMC130M") then
      v_facq_chan := (width => to_unsigned(128, c_acq_chan_cmplt_width_log2),
                      num_atoms => to_unsigned(8, c_acq_num_atoms_width_log2),
                      atom_width => to_unsigned(16, c_acq_atom_width_log2) -- 2^4 = 16-bit
                     );
    elsif (adc_type = "FMC250M") then
      v_facq_chan := (width => to_unsigned(128, c_acq_chan_cmplt_width_log2),
                      num_atoms => to_unsigned(8, c_acq_num_atoms_width_log2),
                      atom_width => to_unsigned(16, c_acq_atom_width_log2) -- 2^4 = 16-bit
                     );
    elsif (adc_type = "FMCPICO_1M") then
      v_facq_chan := (width => to_unsigned(256, c_acq_chan_cmplt_width_log2),
                      num_atoms => to_unsigned(8, c_acq_num_atoms_width_log2),
                      atom_width => to_unsigned(32, c_acq_atom_width_log2) -- 2^5 = 32-bit
                     );
    else
      v_facq_chan := (width => to_unsigned(128, c_acq_chan_cmplt_width_log2),
                      num_atoms => to_unsigned(8, c_acq_num_atoms_width_log2),
                      atom_width => to_unsigned(16, c_acq_atom_width_log2) -- 2^4 = 16-bit
                     );
    end if;
    return v_facq_chan;
  end f_acq_channel_mix_param;

  -- Swap/de-swap settings
  constant c_pos_calc_delay_vec_width         : natural := 8;
  constant c_pos_calc_swap_div_freq_vec_width : natural := 16;

  -- Top crossbar layout
  -- Number of slaves
  constant c_slaves                         : natural := 15;
  -- FMC_ADC_1, FMC_ADC_2, Acq_Core 1, Acq_Core 2,
  -- Position_calc_1, Posiotion_calc_2, Peripherals, AFC diagnostics, ]
  -- Trigger Interface, Trigger MUX 1, Trigger MUX 2, Acq_Core PM 1, Acq_Core PM 2,
  -- Trigger MUX PM 1, Trigger MUX PM 2

  -- Slaves indexes
  constant c_slv_pos_calc_1_id             : natural := 0;
  constant c_slv_fmc_adc_1_id              : natural := 1;
  constant c_slv_acq_core_0_id             : natural := 2;
  constant c_slv_pos_calc_2_id             : natural := 3;
  constant c_slv_fmc_adc_2_id              : natural := 4;
  constant c_slv_acq_core_1_id             : natural := 5;
  constant c_slv_periph_id                 : natural := 6;
  constant c_slv_afc_diag_id               : natural := 7;
  constant c_slv_trig_iface_id             : natural := 8;
  constant c_slv_trig_mux_0_id             : natural := 9;
  constant c_slv_trig_mux_1_id             : natural := 10;
  constant c_slv_acq_core_pm_0_id          : natural := 11;
  constant c_slv_acq_core_pm_1_id          : natural := 12;
  constant c_slv_trig_mux_pm_0_id          : natural := 13;
  constant c_slv_trig_mux_pm_1_id          : natural := 14;
  -- These are not account in the number of slaves as these are special
  constant c_slv_sdb_repo_url_id           : natural := 15;
  constant c_slv_sdb_top_syn_id            : natural := 16;
  constant c_slv_sdb_dsp_cores_id          : natural := 17;
  constant c_slv_sdb_gen_cores_id          : natural := 18;
  constant c_slv_sdb_infra_cores_id        : natural := 19;

  -- Number of masters
  constant c_masters                        : natural := 2;            -- RS232-Syscon, PCIe

  -- Master indexes
  constant c_ma_pcie_id                    : natural := 0;
  constant c_ma_rs232_syscon_id            : natural := 1;

  constant c_acq_fifo_size                  : natural := 1024;

  constant c_acq_addr_width                 : natural := c_ddr_addr_width;
  constant c_acq_ddr_addr_res_width         : natural := 32;
  constant c_acq_ddr_addr_diff              : natural := c_acq_ddr_addr_res_width-c_ddr_addr_width;

  constant c_acq_adc_id                     : natural := 0;
  constant c_acq_adc_swap_id                : natural := 1;
  constant c_acq_mixiq_id                   : natural := 2;
  constant c_dummy0_id                      : natural := 3;
  constant c_acq_tbtdecimiq_id              : natural := 4;
  constant c_dummy1_id                      : natural := 5;
  constant c_acq_tbt_amp_id                 : natural := 6;
  constant c_acq_tbt_phase_id               : natural := 7;
  constant c_acq_tbt_pos_id                 : natural := 8;
  constant c_acq_fofbdecimiq_id             : natural := 9;
  constant c_dummy2_id                      : natural := 10;
  constant c_acq_fofb_amp_id                : natural := 11;
  constant c_acq_fofb_phase_id              : natural := 12;
  constant c_acq_fofb_pos_id                : natural := 13;
  constant c_acq_monit_amp_id               : natural := 14;
  constant c_acq_monit_pos_id               : natural := 15;
  constant c_acq_monit_1_pos_id             : natural := 16;
  constant c_trigger_sw_clk_id              : natural := 17;

  constant c_acq_pos_ddr3_width             : natural := 32;

  -- Number of acquisition cores (FMC1, FMC2, Post Mortem 1, Post Mortem 2)
  constant c_acq_num_cores                  : natural := 4;
  -- Type of DDR3 core interface
  constant c_ddr_interface_type             : string := "AXIS";

  -- Acquisition core IDs
  constant c_acq_core_0_id                  : natural := 0;
  constant c_acq_core_1_id                  : natural := 1;
  constant c_acq_core_2_id                  : natural := 2;
  constant c_acq_core_3_id                  : natural := 3;

  -- Number of channels per acquisition core
  constant c_acq_num_channels               : natural := 17; -- ADC + ADC SWAP + MIXER + TBT AMP + TBT POS +
                                                            -- FOFB AMP + FOFB POS + MONIT AMP + MONIT POS + MONIT_1 POS
                                                            -- for each FMC
  constant c_acq_width_u64                  : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(64, c_acq_chan_cmplt_width_log2);
  constant c_acq_width_u128                 : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(128, c_acq_chan_cmplt_width_log2);
  constant c_acq_width_u256                 : unsigned(c_acq_chan_cmplt_width_log2-1 downto 0) :=
                                                to_unsigned(256, c_acq_chan_cmplt_width_log2);
  constant c_acq_num_atoms_u4               : unsigned(c_acq_num_atoms_width_log2-1 downto 0) :=
                                                to_unsigned(4, c_acq_num_atoms_width_log2);
  constant c_acq_num_atoms_u8               : unsigned(c_acq_num_atoms_width_log2-1 downto 0) :=
                                                to_unsigned(8, c_acq_num_atoms_width_log2);
  constant c_acq_atom_width_u16              : unsigned(c_acq_atom_width_log2-1 downto 0) :=
                                                to_unsigned(16, c_acq_atom_width_log2);
  constant c_acq_atom_width_u32             : unsigned(c_acq_atom_width_log2-1 downto 0) :=
                                                to_unsigned(32, c_acq_atom_width_log2);

  constant c_facq_params_adc                : t_facq_chan_param := f_acq_channel_adc_param(g_fmc_adc_type);
  constant c_facq_params_mix                : t_facq_chan_param := f_acq_channel_mix_param(g_fmc_adc_type);

  constant c_facq_channels                  : t_facq_chan_param_array(c_acq_num_channels-1 downto 0) :=
  (
     c_acq_adc_id            => c_facq_params_adc,
     c_acq_adc_swap_id       => c_facq_params_adc,
     c_acq_mixiq_id          => c_facq_params_mix,
     c_dummy0_id             => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_tbtdecimiq_id     => (width => c_acq_width_u256, num_atoms => c_acq_num_atoms_u8, atom_width => c_acq_atom_width_u32),
     c_dummy1_id             => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_tbt_amp_id        => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_tbt_phase_id      => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_tbt_pos_id        => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_fofbdecimiq_id    => (width => c_acq_width_u256, num_atoms => c_acq_num_atoms_u8, atom_width => c_acq_atom_width_u32),
     c_dummy2_id             => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_fofb_amp_id       => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_fofb_phase_id     => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_fofb_pos_id       => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_monit_amp_id      => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_monit_pos_id      => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32),
     c_acq_monit_1_pos_id    => (width => c_acq_width_u128, num_atoms => c_acq_num_atoms_u4, atom_width => c_acq_atom_width_u32)
  );

  -- Trigger
  constant c_trig_sync_edge                 : string   := "positive";
  constant c_trig_trig_num                  : positive := 8; -- 8 MLVDS triggers
  constant c_trig_intern_num                : positive := 18; -- 17 acquisition channels + 1 switching clock channel
  constant c_trig_rcv_intern_num            : positive := 2; -- 2 FMCs
  constant c_trig_num_mux_interfaces        : natural  := c_acq_num_cores;
  constant c_trig_out_resolver              : string := "fanout";
  constant c_trig_in_resolver               : string := "or";
  constant c_trig_with_input_sync           : boolean := true;
  constant c_trig_with_output_sync          : boolean := true;

  -- Trigger RCV intern IDs
  constant c_trig_rcv_intern_chan_1_id      : positive := 0; -- Internal Channel 1
  constant c_trig_rcv_intern_chan_2_id      : positive := 1; -- Internal Channel 2

  -- Trigger core IDs
  constant c_trig_mux_0_id                  : natural := 0;
  constant c_trig_mux_1_id                  : natural := 1;
  constant c_trig_mux_2_id                  : natural := 2;
  constant c_trig_mux_3_id                  : natural := 3;

  -- GPIO num pinscalc
  constant c_leds_num_pins                  : natural := 3;
  constant c_with_leds_heartbeat            : t_boolean_array(c_leds_num_pins-1 downto 0) :=
                                                (2 => false,  -- Red LED
                                                 1 => true,   -- Green LED
                                                 0 => false); -- Blue LED
  constant c_buttons_num_pins               : natural := 8;

  -- Counter width. It willl count up to 2^32 clock cycles
  constant c_counter_width                  : natural := 32;

  -- TICs counter period. 100MHz clock -> msec granularity
  constant c_tics_cntr_period               : natural := 100000;

  -- Number of reset clock cycles (FF)
  constant c_button_rst_width               : natural := 255;

  -- number of the ADC reference clock used for all downstream
  -- FPGA logic
  constant c_adc_ref_clk                    : natural := 2;

  -- Number of top level clocks
  constant c_num_tlvl_clks                  : natural := 3; -- CLK_SYS and CLK_200 MHz and CLK_300 MHz
  constant c_clk_sys_id                     : natural := 0;
  constant c_clk_200mhz_id                  : natural := 1;
  constant c_clk_300mhz_id                  : natural := 2;

  -- FMC_ADC layout. Size (0x00000FFF) is larger than needed. Just to be sure
  -- no address overlaps will occur
  constant c_fmc_adc_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"0000FFFF", x"00006000");

  -- Position CAlC. layout. Regs, SWAP
  constant c_pos_calc_core_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000600");

  -- General peripherals layout. UART, LEDs (GPIO), Buttons (GPIO) and Tics counter
  constant c_periph_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000400");

  -- WB SDB (Self describing bus) layout
  constant c_layout : t_sdb_record_array(c_slaves+5-1 downto 0) :=
    (c_slv_pos_calc_1_id       => f_sdb_embed_bridge(c_pos_calc_core_bridge_sdb,
                                                                                 x"00310000"),   -- Position Calc Core 1 control port
     c_slv_fmc_adc_1_id        => f_sdb_embed_bridge(c_fmc_adc_bridge_sdb,       x"00320000"),   -- FMC_ADC control 1 port
     c_slv_acq_core_0_id       => f_sdb_embed_device(c_xwb_acq_core_sdb,         x"00330000"),   -- Data Acquisition control port
     c_slv_pos_calc_2_id       => f_sdb_embed_bridge(c_pos_calc_core_bridge_sdb,
                                                                                 x"00340000"),   -- Position Calc Core 2 control port
     c_slv_fmc_adc_2_id        => f_sdb_embed_bridge(c_fmc_adc_bridge_sdb,       x"00350000"),   -- FMC_ADC control 2 port
     c_slv_acq_core_1_id       => f_sdb_embed_device(c_xwb_acq_core_sdb,         x"00360000"),   -- Data Acquisition control port
     c_slv_periph_id           => f_sdb_embed_bridge(c_periph_bridge_sdb,        x"00370000"),   -- General peripherals control port
     c_slv_afc_diag_id         => f_sdb_embed_device(c_xwb_afc_diag_sdb,         x"00380000"),   -- AFC Diagnostics control port
     c_slv_trig_iface_id       => f_sdb_embed_device(c_xwb_trigger_iface_sdb,    x"00390000"),   -- Trigger Interface port
     c_slv_trig_mux_0_id       => f_sdb_embed_device(c_xwb_trigger_mux_sdb,      x"00400000"),   -- Trigger Mux 1 port
     c_slv_trig_mux_1_id       => f_sdb_embed_device(c_xwb_trigger_mux_sdb,      x"00410000"),   -- Trigger Mux 2 port
     c_slv_acq_core_pm_0_id    => f_sdb_embed_device(c_xwb_acq_core_pm_sdb,      x"00420000"),   -- Data Acquisition 0 Post-Mortem port
     c_slv_acq_core_pm_1_id    => f_sdb_embed_device(c_xwb_acq_core_pm_sdb,      x"00430000"),   -- Data Acquisition 1 Post-Mortem port
     c_slv_trig_mux_pm_0_id    => f_sdb_embed_device(c_xwb_trigger_mux_sdb,      x"00440000"),   -- Trigger Mux Post-Mortem 1 port
     c_slv_trig_mux_pm_1_id    => f_sdb_embed_device(c_xwb_trigger_mux_sdb,      x"00450000"),   -- Trigger Mux Post-Mortem 2 port
     c_slv_sdb_repo_url_id     => f_sdb_embed_repo_url(c_sdb_repo_url),
     c_slv_sdb_top_syn_id      => f_sdb_embed_synthesis(c_sdb_top_syn_info),
     c_slv_sdb_dsp_cores_id    => f_sdb_embed_synthesis(c_sdb_dsp_cores_syn_info),
     c_slv_sdb_gen_cores_id    => f_sdb_embed_synthesis(c_sdb_general_cores_syn_info),
     c_slv_sdb_infra_cores_id  => f_sdb_embed_synthesis(c_sdb_infra_cores_syn_info)
    );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well
  constant c_sdb_address                    : t_wishbone_address := x"00000000";

  constant c_num_unprocessed_bits           : natural := f_num_bits_adc(g_fmc_adc_type);
  constant c_num_unprocessed_se_bits        : natural := f_num_bits_se_adc(g_fmc_adc_type);

  -- FMC ADC data constants
  constant c_adc_data_ch0_lsb               : natural := 0;
  constant c_adc_data_ch0_msb               : natural := c_num_unprocessed_bits-1 + c_adc_data_ch0_lsb;

  constant c_adc_data_ch1_lsb               : natural := c_adc_data_ch0_msb + 1;
  constant c_adc_data_ch1_msb               : natural := c_num_unprocessed_bits-1 + c_adc_data_ch1_lsb;

  constant c_adc_data_ch2_lsb               : natural := c_adc_data_ch1_msb + 1;
  constant c_adc_data_ch2_msb               : natural := c_num_unprocessed_bits-1 + c_adc_data_ch2_lsb;

  constant c_adc_data_ch3_lsb               : natural := c_adc_data_ch2_msb + 1;
  constant c_adc_data_ch3_msb               : natural := c_num_unprocessed_bits-1 + c_adc_data_ch3_lsb;

  -- Crossbar master/slave arrays
  signal cbar_slave_i                       : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_o                       : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_i                      : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_o                      : t_wishbone_master_out_array(c_slaves-1 downto 0);
  signal acq_core_slave_i                   : t_wishbone_slave_in_array (c_acq_num_cores-1 downto 0);
  signal acq_core_slave_o                   : t_wishbone_slave_out_array(c_acq_num_cores-1 downto 0);

  -- LM32 signals
  signal clk_sys                            : std_logic;
  signal lm32_interrupt                     : std_logic_vector(31 downto 0);
  signal lm32_rstn                          : std_logic;

  -- PCIe signals
  signal wb_ma_pcie_ack_in                  : std_logic;
  signal wb_ma_pcie_dat_in                  : std_logic_vector(63 downto 0);
  signal wb_ma_pcie_addr_out                : std_logic_vector(28 downto 0);
  signal wb_ma_pcie_dat_out                 : std_logic_vector(63 downto 0);
  signal wb_ma_pcie_we_out                  : std_logic;
  signal wb_ma_pcie_stb_out                 : std_logic;
  signal wb_ma_pcie_sel_out                 : std_logic;
  signal wb_ma_pcie_cyc_out                 : std_logic;

  signal wb_ma_pcie_rst                     : std_logic;
  signal wb_ma_pcie_rstn                    : std_logic;
  signal wb_ma_pcie_rstn_sync               : std_logic;

  signal wb_ma_sladp_pcie_ack_in            : std_logic;
  signal wb_ma_sladp_pcie_dat_in            : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_addr_out          : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_dat_out           : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_we_out            : std_logic;
  signal wb_ma_sladp_pcie_stb_out           : std_logic;
  signal wb_ma_sladp_pcie_sel_out           : std_logic_vector(3 downto 0);
  signal wb_ma_sladp_pcie_cyc_out           : std_logic;

  -- PCIe Debug signals

  signal dbg_app_addr                       : std_logic_vector(31 downto 0);
  signal dbg_app_cmd                        : std_logic_vector(2 downto 0);
  signal dbg_app_en                         : std_logic;
  signal dbg_app_wdf_data                   : std_logic_vector(c_ddr_payload_width-1 downto 0);
  signal dbg_app_wdf_end                    : std_logic;
  signal dbg_app_wdf_wren                   : std_logic;
  signal dbg_app_wdf_mask                   : std_logic_vector(c_ddr_payload_width/8-1 downto 0);
  signal dbg_app_rd_data                    : std_logic_vector(c_ddr_payload_width-1 downto 0);
  signal dbg_app_rd_data_end                : std_logic;
  signal dbg_app_rd_data_valid              : std_logic;
  signal dbg_app_rdy                        : std_logic;
  signal dbg_app_wdf_rdy                    : std_logic;
  signal dbg_ddr_ui_clk                     : std_logic;
  signal dbg_ddr_ui_reset                   : std_logic;

  signal dbg_arb_req                        : std_logic_vector(1 downto 0);
  signal dbg_arb_gnt                        : std_logic_vector(1 downto 0);

  -- To/From Acquisition Core
  signal acq_chan_array                     : t_facq_chan_array2d(c_acq_num_cores-1 downto 0, c_acq_num_channels-1 downto 0);

  signal bpm_acq_dpram_dout_array           : std_logic_vector(c_acq_num_cores*f_acq_chan_find_widest(f_conv_facq_to_acq_chan_array(c_facq_channels))-1 downto 0);
  signal bpm_acq_dpram_valid_array          : std_logic_vector(c_acq_num_cores-1 downto 0);

  signal bpm_acq_ext_dout_array             : std_logic_vector(c_acq_num_cores*c_ddr_payload_width-1 downto 0);
  signal bpm_acq_ext_valid_array            : std_logic_vector(c_acq_num_cores-1 downto 0);
  signal bpm_acq_ext_addr_array             : std_logic_vector(c_acq_num_cores*c_acq_addr_width-1 downto 0);
  signal bpm_acq_ext_sof_array              : std_logic_vector(c_acq_num_cores-1 downto 0);
  signal bpm_acq_ext_eof_array              : std_logic_vector(c_acq_num_cores-1 downto 0);
  signal bpm_acq_ext_dreq_array             : std_logic_vector(c_acq_num_cores-1 downto 0);
  signal bpm_acq_ext_stall_array            : std_logic_vector(c_acq_num_cores-1 downto 0);

  signal ddr_aximm_clk                      : std_logic;
  signal ddr_aximm_rstn                     : std_logic;
  signal ddr_aximm_r_ma_in                  : t_aximm_r_master_in;
  signal ddr_aximm_r_ma_out                 : t_aximm_r_master_out;
  signal ddr_aximm_w_ma_in                  : t_aximm_w_master_in;
  signal ddr_aximm_w_ma_out                 : t_aximm_w_master_out;

  signal dbg_ddr_rb_data                    : std_logic_vector(c_ddr_payload_width-1 downto 0);
  signal dbg_ddr_rb_addr                    : std_logic_vector(c_acq_addr_width-1 downto 0);
  signal dbg_ddr_rb_valid                   : std_logic;

  -- memory arbiter interface
  signal memarb_acc_req                     : std_logic;
  signal memarb_acc_gnt                     : std_logic;

  -- Clocks and resets signals
  signal locked                             : std_logic;
  signal clk_sys_pcie_rstn                  : std_logic;
  signal clk_sys_pcie_rst                   : std_logic;
  signal clk_sys_rstn                       : std_logic;
  signal clk_sys_rst                        : std_logic;
  signal clk_200mhz_rst                     : std_logic;
  signal clk_200mhz_rstn                    : std_logic;
  signal clk_300mhz_rst                     : std_logic;
  signal clk_300mhz_rstn                    : std_logic;

  signal rst_button_sys_pp                  : std_logic;
  signal rst_button_sys                     : std_logic;
  signal rst_button_sys_n                   : std_logic;

  -- "c_num_tlvl_clks" clocks
  signal reset_clks                         : std_logic_vector(c_num_tlvl_clks-1 downto 0);
  signal reset_rstn                         : std_logic_vector(c_num_tlvl_clks-1 downto 0);

  signal rs232_rstn                         : std_logic;
  signal fs_rstn_dbg                        : std_logic;
  signal fs_rst2xn_dbg                      : std_logic;
  signal fs1_rstn                           : std_logic;
  signal fs1_rst2xn                         : std_logic;
  signal fs2_rstn                           : std_logic;
  signal fs2_rst2xn                         : std_logic;

  -- 200 Mhz clocck for iodelay_ctrl
  signal clk_200mhz                         : std_logic;
  signal clk_300mhz                         : std_logic;

  -- ADC clock
  signal fs1_clk                            : std_logic;
  signal fs1_clk2x                          : std_logic;
  signal fs2_clk                            : std_logic;
  signal fs2_clk2x                          : std_logic;
  signal fs_clk_dbg                         : std_logic;
  signal fs_clk2x_dbg                       : std_logic;
  signal fs_clk_array                       : std_logic_vector(c_acq_num_cores-1 downto 0);
  signal fs_rst_n_array                     : std_logic_vector(c_acq_num_cores-1 downto 0);
  signal fs_ce_array                        : std_logic_vector(c_acq_num_cores-1 downto 0);

   -- Global Clock Single ended
  signal sys_clk_gen                        : std_logic;
  signal sys_clk_gen_bufg                   : std_logic;

  -- FMC_ADC 1 Signals
  signal wbs_fmc1_in_array                  : t_wbs_source_in16_array(c_num_adc_channels-1 downto 0);
  signal wbs_fmc1_out_array                 : t_wbs_source_out16_array(c_num_adc_channels-1 downto 0);

  signal fmc1_mmcm_lock_int                  : std_logic;
  signal fmc1_pll_status_int                 : std_logic;

  signal fmc1_led1_int                       : std_logic;
  signal fmc1_led2_int                       : std_logic;
  signal fmc1_led3_int                       : std_logic;

  signal fmc1_clk                            : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc1_clk2x                          : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc1_data                           : std_logic_vector(c_num_adc_channels*c_num_unprocessed_bits-1 downto 0);
  signal fmc1_data_valid                     : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc1_adc_fast_spi_clk               : std_logic;
  signal fmc1_adc_fast_spi_rstn              : std_logic;
  signal fmc1_adc_busy                       : std_logic;

  signal fmc1_adc_data_ch0                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0) := (others => '0');
  signal fmc1_adc_data_ch1                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0) := (others => '0');
  signal fmc1_adc_data_ch2                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0) := (others => '0');
  signal fmc1_adc_data_ch3                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0) := (others => '0');

  signal fmc1_adc_data_se_ch0                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0) := (others => '0');
  signal fmc1_adc_data_se_ch1                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0) := (others => '0');
  signal fmc1_adc_data_se_ch2                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0) := (others => '0');
  signal fmc1_adc_data_se_ch3                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0) := (others => '0');

  signal fmc1_adc_valid                      : std_logic := '0';

  signal fmc1_debug                          : std_logic;
  signal fmc1_rst_n                          : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc1_rst2x_n                        : std_logic_vector(c_num_adc_channels-1 downto 0);

  signal fmc1_trig_hw                        : std_logic;
  signal fmc1_trig_hw_in                     : std_logic;

  signal trig_dir_int                       : std_logic_vector(7 downto 0);

  -- FMC_ADC 1 Debug
  signal fmc1_debug_valid_int                : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc1_debug_full_int                 : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc1_debug_empty_int                : std_logic_vector(c_num_adc_channels-1 downto 0);

  signal fmc1_adc_dly_debug_int             : t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

  -- FMC_ADC 2 Signals
  signal wbs_fmc2_in_array                  : t_wbs_source_in16_array(c_num_adc_channels-1 downto 0);
  signal wbs_fmc2_out_array                 : t_wbs_source_out16_array(c_num_adc_channels-1 downto 0);

  signal fmc2_mmcm_lock_int                  : std_logic;
  signal fmc2_pll_status_int                 : std_logic;

  signal fmc2_led1_int                       : std_logic;
  signal fmc2_led2_int                       : std_logic;
  signal fmc2_led3_int                       : std_logic;

  signal fmc2_clk                            : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc2_clk2x                          : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc2_data                           : std_logic_vector(c_num_adc_channels*c_num_unprocessed_bits-1 downto 0);
  signal fmc2_data_valid                     : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc2_adc_fast_spi_clk               : std_logic;
  signal fmc2_adc_fast_spi_rstn              : std_logic;
  signal fmc2_adc_busy                       : std_logic;

  signal fmc2_adc_data_ch0                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0) := (others => '0');
  signal fmc2_adc_data_ch1                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0) := (others => '0');
  signal fmc2_adc_data_ch2                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0) := (others => '0');
  signal fmc2_adc_data_ch3                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0) := (others => '0');

  signal fmc2_adc_data_se_ch0                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0) := (others => '0');
  signal fmc2_adc_data_se_ch1                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0) := (others => '0');
  signal fmc2_adc_data_se_ch2                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0) := (others => '0');
  signal fmc2_adc_data_se_ch3                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0) := (others => '0');

  signal fmc2_adc_valid                      : std_logic := '0';

  signal fmc2_debug                          : std_logic;
  signal fmc2_rst_n                          : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc2_rst2x_n                        : std_logic_vector(c_num_adc_channels-1 downto 0);

  signal fmc2_trig_hw                        : std_logic;
  signal fmc2_trig_hw_in                     : std_logic;

  -- FMC_ADC 2 Debug
  signal fmc2_debug_valid_int                : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc2_debug_full_int                 : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc2_debug_empty_int                : std_logic_vector(c_num_adc_channels-1 downto 0);

  signal fmc2_adc_dly_debug_int              : t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

  -- Uncross 1 signals
  signal dsp1_clk_rffe_swap                  : std_logic;
  signal dsp1_flag1_int                      : std_logic;
  signal dsp1_flag2_int                      : std_logic;

  -- DSP 1 signals
  signal dsp1_adc_ch0_data                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp1_adc_ch1_data                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp1_adc_ch2_data                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp1_adc_ch3_data                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp1_adc_valid                      : std_logic;

  signal dsp1_adc_se_ch0_data                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0);
  signal dsp1_adc_se_ch1_data                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0);
  signal dsp1_adc_se_ch2_data                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0);
  signal dsp1_adc_se_ch3_data                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0);

  signal dsp1_mixi_ch0                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp1_mixi_ch1                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp1_mixi_ch2                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp1_mixi_ch3                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp1_mix_valid                      : std_logic;

  signal dsp1_mixq_ch0                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp1_mixq_ch1                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp1_mixq_ch2                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp1_mixq_ch3                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);

  signal dsp1_tbtdecimi_ch0                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbtdecimi_ch1                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbtdecimi_ch2                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbtdecimi_ch3                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbtdecim_valid                 : std_logic;

  signal dsp1_tbtdecimq_ch0                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbtdecimq_ch1                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbtdecimq_ch2                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbtdecimq_ch3                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);

  signal dsp1_tbt_amp_ch0                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_amp_ch1                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_amp_ch2                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_amp_ch3                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_amp_valid                  : std_logic;

  signal dsp1_tbt_pha_ch0                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_pha_ch1                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_pha_ch2                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_pha_ch3                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_pha_valid                  : std_logic;

  signal dsp1_fofbdecimi_ch0                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofbdecimi_ch1                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofbdecimi_ch2                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofbdecimi_ch3                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofbdecim_valid                : std_logic;

  signal dsp1_fofbdecimq_ch0                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofbdecimq_ch1                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofbdecimq_ch2                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofbdecimq_ch3                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);

  signal dsp1_fofb_amp_ch0                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_amp_ch1                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_amp_ch2                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_amp_ch3                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_amp_valid                 : std_logic;

  signal dsp1_fofb_pha_ch0                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_pha_ch1                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_pha_ch2                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_pha_ch3                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_pha_valid                 : std_logic;

  signal dsp1_monit_amp_ch0                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit_amp_ch1                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit_amp_ch2                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit_amp_ch3                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit_amp_valid                : std_logic;

  signal dsp1_tbt_pos_x                      : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_pos_y                      : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_pos_q                      : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_pos_sum                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp1_tbt_pos_valid                  : std_logic;

  signal dsp1_fofb_pos_x                     : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_pos_y                     : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_pos_q                     : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_pos_sum                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp1_fofb_pos_valid                 : std_logic;

  signal dsp1_monit_pos_x                    : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit_pos_y                    : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit_pos_q                    : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit_pos_sum                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit_pos_valid                : std_logic;

  signal dsp1_dbg_cur_address                : std_logic_vector(31 downto 0);
  signal dsp1_dbg_adc_ch0_cond               : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp1_dbg_adc_ch1_cond               : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp1_dbg_adc_ch2_cond               : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp1_dbg_adc_ch3_cond               : std_logic_vector(c_num_unprocessed_bits-1 downto 0);

  -- Uncross 2 signals
  signal dsp2_clk_rffe_swap                  : std_logic;
  signal dsp2_flag1_int                      : std_logic;
  signal dsp2_flag2_int                      : std_logic;

  -- DSP 2 signals
  signal dsp2_adc_ch0_data                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp2_adc_ch1_data                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp2_adc_ch2_data                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp2_adc_ch3_data                   : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp2_adc_valid                      : std_logic;

  signal dsp2_adc_se_ch0_data                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0);
  signal dsp2_adc_se_ch1_data                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0);
  signal dsp2_adc_se_ch2_data                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0);
  signal dsp2_adc_se_ch3_data                : std_logic_vector(c_num_unprocessed_se_bits-1 downto 0);

  signal dsp2_mixi_ch0                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp2_mixi_ch1                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp2_mixi_ch2                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp2_mixi_ch3                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp2_mix_valid                      : std_logic;

  signal dsp2_mixq_ch0                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp2_mixq_ch1                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp2_mixq_ch2                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);
  signal dsp2_mixq_ch3                       : std_logic_vector(c_pos_calc_IQ_width-1 downto 0);

  signal dsp2_tbtdecimi_ch0                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbtdecimi_ch1                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbtdecimi_ch2                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbtdecimi_ch3                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbtdecim_valid                 : std_logic;

  signal dsp2_tbtdecimq_ch0                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbtdecimq_ch1                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbtdecimq_ch2                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbtdecimq_ch3                  : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);

  signal dsp2_tbt_amp_ch0                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_amp_ch1                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_amp_ch2                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_amp_ch3                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_amp_valid                  : std_logic;

  signal dsp2_tbt_pha_ch0                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_pha_ch1                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_pha_ch2                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_pha_ch3                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_pha_valid                  : std_logic;

  signal dsp2_fofbdecimi_ch0                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofbdecimi_ch1                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofbdecimi_ch2                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofbdecimi_ch3                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofbdecim_valid                : std_logic;

  signal dsp2_fofbdecimq_ch0                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofbdecimq_ch1                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofbdecimq_ch2                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofbdecimq_ch3                 : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);

  signal dsp2_fofb_amp_ch0                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_amp_ch1                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_amp_ch2                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_amp_ch3                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_amp_valid                 : std_logic;

  signal dsp2_fofb_pha_ch0                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_pha_ch1                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_pha_ch2                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_pha_ch3                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_pha_valid                 : std_logic;

  signal dsp2_monit_amp_ch0                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit_amp_ch1                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit_amp_ch2                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit_amp_ch3                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit_amp_valid                : std_logic;

  signal dsp2_tbt_pos_x                      : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_pos_y                      : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_pos_q                      : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_pos_sum                    : std_logic_vector(c_pos_calc_tbt_decim_width-1 downto 0);
  signal dsp2_tbt_pos_valid                  : std_logic;

  signal dsp2_fofb_pos_x                     : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_pos_y                     : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_pos_q                     : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_pos_sum                   : std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  signal dsp2_fofb_pos_valid                 : std_logic;

  signal dsp2_monit_pos_x                    : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit_pos_y                    : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit_pos_q                    : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit_pos_sum                  : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit_pos_valid                : std_logic;

  signal dsp2_dbg_cur_address                : std_logic_vector(31 downto 0);
  signal dsp2_dbg_adc_ch0_cond               : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp2_dbg_adc_ch1_cond               : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp2_dbg_adc_ch2_cond               : std_logic_vector(c_num_unprocessed_bits-1 downto 0);
  signal dsp2_dbg_adc_ch3_cond               : std_logic_vector(c_num_unprocessed_bits-1 downto 0);

  -- Trigger
  signal trig_core_slave_i                  : t_wishbone_slave_in_array (c_trig_num_mux_interfaces-1 downto 0);
  signal trig_core_slave_o                  : t_wishbone_slave_out_array(c_trig_num_mux_interfaces-1 downto 0);
  signal trig_ref_clk                       : std_logic;
  signal trig_ref_rst_n                     : std_logic;

  signal trig_rcv_intern                    : t_trig_channel_array2d(c_trig_num_mux_interfaces-1 downto 0, c_trig_rcv_intern_num-1 downto 0);
  signal trig_pulse_transm                  : t_trig_channel_array2d(c_trig_num_mux_interfaces-1 downto 0, c_trig_intern_num-1 downto 0);
  signal trig_pulse_rcv                     : t_trig_channel_array2d(c_trig_num_mux_interfaces-1 downto 0, c_trig_intern_num-1 downto 0);

  signal trig_fmc1_channel_1                : t_trig_channel;
  signal trig_fmc1_channel_2                : t_trig_channel;
  signal trig_fmc2_channel_1                : t_trig_channel;
  signal trig_fmc2_channel_2                : t_trig_channel;

  -- Post-Mortem triggers
  signal trig_fmc1_pm_channel_1             : t_trig_channel;
  signal trig_fmc1_pm_channel_2             : t_trig_channel;
  signal trig_fmc2_pm_channel_1             : t_trig_channel;
  signal trig_fmc2_pm_channel_2             : t_trig_channel;

  signal trig_dbg                           : std_logic_vector(7 downto 0);

  -- GPIO LED signals
  signal gpio_slave_led_o                   : t_wishbone_slave_out;
  signal gpio_slave_led_i                   : t_wishbone_slave_in;
  signal gpio_leds_out_int                  : std_logic_vector(c_leds_num_pins-1 downto 0);
  signal gpio_leds_in_int                   : std_logic_vector(c_leds_num_pins-1 downto 0) := (others => '0');
  -- signal leds_gpio_dummy_in                : std_logic_vector(c_leds_num_pins-1 downto 0);

  signal buttons_dummy                      : std_logic_vector(7 downto 0) := (others => '0');

  -- GPIO Button signals
  signal gpio_slave_button_o                : t_wishbone_slave_out;
  signal gpio_slave_button_i                : t_wishbone_slave_in;

  -- AFC diagnostics signals
  signal dbg_spi_clk                        : std_logic;
  signal dbg_spi_valid                      : std_logic;
  signal dbg_en                             : std_logic;
  signal dbg_addr                           : std_logic_vector(7 downto 0);
  signal dbg_serial_data                    : std_logic_vector(31 downto 0);
  signal dbg_spi_data                       : std_logic_vector(31 downto 0);

  -- Chipscope control signals
  signal CONTROL0                           : std_logic_vector(35 downto 0);
  signal CONTROL1                           : std_logic_vector(35 downto 0);
  signal CONTROL2                           : std_logic_vector(35 downto 0);
  signal CONTROL3                           : std_logic_vector(35 downto 0);
  signal CONTROL4                           : std_logic_vector(35 downto 0);

  -- Chipscope ILA 0 signals
  signal TRIG_ILA0_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 1 signals
  signal TRIG_ILA1_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 2 signals
  signal TRIG_ILA2_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 3 signals
  signal TRIG_ILA3_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 4 signals
  signal TRIG_ILA4_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_3                        : std_logic_vector(31 downto 0);

  ---- Chipscope ILA 6 signals
  --signal TRIG_ILA6_0                        : std_logic_vector(7 downto 0);
  --signal TRIG_ILA6_1                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA6_2                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA6_3                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA6_4                        : std_logic_vector(31 downto 0);

  ---- Chipscope ILA 7 signals
  --signal TRIG_ILA7_0                        : std_logic_vector(7 downto 0);
  --signal TRIG_ILA7_1                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA7_2                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA7_3                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA7_4                        : std_logic_vector(31 downto 0);

  ---- Chipscope ILA 8 signals
  --signal TRIG_ILA8_0                        : std_logic_vector(7 downto 0);
  --signal TRIG_ILA8_1                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA8_2                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA8_3                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA8_4                        : std_logic_vector(31 downto 0);

  ---- Chipscope ILA 9 signals
  --signal TRIG_ILA9_0                        : std_logic_vector(7 downto 0);
  --signal TRIG_ILA9_1                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA9_2                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA9_3                        : std_logic_vector(31 downto 0);
  --signal TRIG_ILA9_4                        : std_logic_vector(31 downto 0);

  ---- Chipscope ILA 10 signals
  --signal TRIG_ILA10_0                       : std_logic_vector(7 downto 0);
  --signal TRIG_ILA10_1                       : std_logic_vector(31 downto 0);
  --signal TRIG_ILA10_2                       : std_logic_vector(31 downto 0);
  --signal TRIG_ILA10_3                       : std_logic_vector(31 downto 0);
  --signal TRIG_ILA10_4                       : std_logic_vector(31 downto 0);

  ---------------------------
  --      Components       --
  ---------------------------

  -- Clock generation
  component clk_gen is
  port(
    sys_clk_p_i                             : in std_logic;
    sys_clk_n_i                             : in std_logic;
    sys_clk_o                               : out std_logic;
    sys_clk_bufg_o                          : out std_logic
  );
  end component;

  -- Xilinx PLL
  component sys_pll is
  generic(
    -- 200 MHz input clock
    g_clkin_period                          : real := 5.000;
    g_divclk_divide                         : integer := 1;
    g_clkbout_mult_f                        : integer := 5;

    -- 100 MHz output clock
    g_clk0_divide_f                         : integer := 10;
    -- 200 MHz output clock
    g_clk1_divide                           : integer := 5;
    -- 200 MHz output clock
    g_clk2_divide                           : integer := 5
  );
  port(
    rst_i                                   : in std_logic := '0';
    clk_i                                   : in std_logic := '0';
    clk0_o                                  : out std_logic;
    clk1_o                                  : out std_logic;
    clk2_o                                  : out std_logic;
    locked_o                                : out std_logic
  );
  end component;

  -- Xilinx Chipscope Controller
  component chipscope_icon_1_port
  port (
    CONTROL0                                : inout std_logic_vector(35 downto 0)
  );
  end component;

  component chipscope_icon_4_port
  port (
    CONTROL0                                : inout std_logic_vector(35 downto 0);
    CONTROL1                                : inout std_logic_vector(35 downto 0);
    CONTROL2                                : inout std_logic_vector(35 downto 0);
    CONTROL3                                : inout std_logic_vector(35 downto 0)
  );
  end component;

  component chipscope_ila
  port (
    control                                 : inout std_logic_vector(35 downto 0);
    clk                                     : in std_logic;
    trig0                                   : in std_logic_vector(31 downto 0);
    trig1                                   : in std_logic_vector(31 downto 0);
    trig2                                   : in std_logic_vector(31 downto 0);
    trig3                                   : in std_logic_vector(31 downto 0)
  );
  end component;

  -- Xilinx Chipscope Logic Analyser
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
    sys_clk_p_i                             => sys_clk_p_i,
    sys_clk_n_i                             => sys_clk_n_i,
    sys_clk_o                               => sys_clk_gen,
    sys_clk_bufg_o                          => sys_clk_gen_bufg
  );

   -- Obtain core locking and generate necessary clocks
  cmp_sys_pll_inst : sys_pll
  generic map (
    -- 125 MHz input clock
    g_clkin_period                          => 8.000,
    g_divclk_divide                         => 5,
    g_clkbout_mult_f                        => 48,

    -- 100 MHz output clock
    g_clk0_divide_f                         => 12,
    -- 200 MHz output clock
    g_clk1_divide                           => 6,
    -- 300 MHz output clock
    g_clk2_divide                           => 4
  )
  port map (
    rst_i                                   => '0',
    clk_i                                   => sys_clk_gen_bufg,
    --clk_i                                   => sys_clk_gen,
    clk0_o                                  => clk_sys,     -- 100MHz locked clock
    clk1_o                                  => clk_200mhz,  -- 200MHz locked clock
    clk2_o                                  => clk_300mhz,  -- 300MHz locked clock
    locked_o                                => locked        -- '1' when the PLL has locked
  );

  -- Reset synchronization. Hold reset line until few locked cycles have passed.
  cmp_reset : gc_reset
  generic map(
    g_clocks                                => c_num_tlvl_clks    -- CLK_SYS & CLK_200
  )
  port map(
    --free_clk_i                              => sys_clk_gen,
    free_clk_i                              => sys_clk_gen_bufg,
    locked_i                                => locked,
    clks_i                                  => reset_clks,
    rstn_o                                  => reset_rstn
  );

  reset_clks(c_clk_sys_id)                  <= clk_sys;
  reset_clks(c_clk_200mhz_id)               <= clk_200mhz;
  reset_clks(c_clk_300mhz_id)               <= clk_300mhz;

  -- Reset for PCIe core. Caution when resetting the PCIe core after the
  -- initialization. The PCIe core needs to retrain the link and the PCIe
  -- host (linux OS, likely) will not be able to do that automatically,
  -- probably.
  clk_sys_pcie_rstn                         <= reset_rstn(c_clk_sys_id) and rst_button_sys_n;
  clk_sys_pcie_rst                          <= not clk_sys_pcie_rstn;
  -- Reset for all other modules
  clk_sys_rstn                              <= reset_rstn(c_clk_sys_id) and rst_button_sys_n and
                                                  rs232_rstn and wb_ma_pcie_rstn_sync;
  clk_sys_rst                               <= not clk_sys_rstn;
  -- Reset synchronous to clk200mhz
  clk_200mhz_rstn                           <= reset_rstn(c_clk_200mhz_id);
  clk_200mhz_rst                            <=  not(reset_rstn(c_clk_200mhz_id));
  -- Reset synchronous to clk300mhz
  clk_300mhz_rstn                           <= reset_rstn(c_clk_300mhz_id);
  clk_300mhz_rst                            <=  not(reset_rstn(c_clk_300mhz_id));

  -- Generate button reset synchronous to each clock domain
  -- Detect button positive edge of clk_sys
  cmp_button_sys_ffs : gc_sync_ffs
  port map (
    clk_i                                   => clk_sys,
    rst_n_i                                 => '1',
    data_i                                  => sys_rst_button_n_i,
    npulse_o                                => rst_button_sys_pp
  );

  -- Generate the reset signal based on positive edge
  -- of synched gc
  cmp_button_sys_rst : gc_extend_pulse
  generic map (
    g_width                                 => c_button_rst_width
  )
  port map(
    clk_i                                   => clk_sys,
    rst_n_i                                 => '1',
    pulse_i                                 => rst_button_sys_pp,
    extended_o                              => rst_button_sys
  );

  rst_button_sys_n                          <= not rst_button_sys;

  -- The top-most Wishbone B.4 crossbar
  cmp_interconnect : xwb_sdb_crossbar
  generic map(
    g_num_masters                           => c_masters,
    g_num_slaves                            => c_slaves,
    g_registered                            => true,
    g_wraparound                            => true, -- Should be true for nested buses
    g_layout                                => c_layout,
    g_sdb_addr                              => c_sdb_address
  )
  port map(
    clk_sys_i                               => clk_sys,
    rst_n_i                                 => clk_sys_rstn,
    -- Master connections (INTERCON is a slave)
    slave_i                                 => cbar_slave_i,
    slave_o                                 => cbar_slave_o,
    -- Slave connections (INTERCON is a master)
    master_i                                => cbar_master_i,
    master_o                                => cbar_master_o
  );

  -- The LM32 is master 0+1
  --lm32_rstn                                 <= clk_sys_rstn;

  --cmp_lm32 : xwb_lm32
  --generic map(
  --  g_profile                               => "medium_icache_debug"
  --) -- Including JTAG and I-cache (no divide)
  --port map(
  --  clk_sys_i                               => clk_sys,
  --  rst_n_i                                 => lm32_rstn,
  --  irq_i                                   => lm32_interrupt,
  --  dwb_o                                   => cbar_slave_i(0), -- Data bus
  --  dwb_i                                   => cbar_slave_o(0),
  --  iwb_o                                   => cbar_slave_i(1), -- Instruction bus
  --  iwb_i                                   => cbar_slave_o(1)
  --);

  -- Interrupt '0' is Button(0).
  -- Interrupts 31 downto 1 are disabled

  --lm32_interrupt <= (0 => not buttons_i(0), others => '0');

  ----------------------------------
  --         PCIe Core            --
  ----------------------------------

  cmp_xwb_bpm_pcie : xwb_bpm_pcie
  generic map (
    g_ma_interface_mode                       => PIPELINED,
    g_ma_address_granularity                  => BYTE,
    g_simulation                              => "FALSE"
  )
  port map (
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

    -- Necessity signals
    ddr_clk_i                                 => clk_200mhz,   --200 MHz DDR core clock (connect through BUFG or PLL)
    ddr_rst_i                                 => clk_sys_rst,
    pcie_clk_p_i                              => pcie_clk_p_i, --100 MHz PCIe Clock (connect directly to input pin)
    pcie_clk_n_i                              => pcie_clk_n_i, --100 MHz PCIe Clock
    pcie_rst_n_i                              => clk_sys_pcie_rstn, -- PCIe core reset

    -- DDR memory controller interface --
    ddr_aximm_sl_aclk_o                       => ddr_aximm_clk,
    ddr_aximm_sl_aresetn_o                    => ddr_aximm_rstn,
    ddr_aximm_r_sl_i                          => ddr_aximm_r_ma_out,
    ddr_aximm_r_sl_o                          => ddr_aximm_r_ma_in,
    ddr_aximm_w_sl_i                          => ddr_aximm_w_ma_out,
    ddr_aximm_w_sl_o                          => ddr_aximm_w_ma_in,

    -- Wishbone interface --
    wb_clk_i                                  => clk_sys,
    -- Reset wishbone interface with the same reset as the other
    -- modules, including a reset coming from the PCIe itself.
    wb_rst_i                                  => clk_sys_rst,
    wb_ma_i                                   => cbar_slave_o(c_ma_pcie_id),
    wb_ma_o                                   => cbar_slave_i(c_ma_pcie_id),
    -- Additional exported signals for instantiation
    wb_ma_pcie_rst_o                          => wb_ma_pcie_rst
  );

  wb_ma_pcie_rstn                             <= not wb_ma_pcie_rst;

  cmp_pcie_reset_synch : reset_synch
  port map
  (
    clk_i                                    => clk_sys,
    arst_n_i                                 => wb_ma_pcie_rstn,
    rst_n_o                                  => wb_ma_pcie_rstn_sync
  );

  ----------------------------------
  --         RS232 Core            --
  ----------------------------------
  cmp_xwb_rs232_syscon : xwb_rs232_syscon
  generic map (
    g_ma_interface_mode                       => PIPELINED,
    g_ma_address_granularity                  => BYTE
  )
  port map(
    -- WISHBONE common
    wb_clk_i                                  => clk_sys,
    wb_rstn_i                                 => clk_sys_rstn,

    -- External ports
    rs232_rxd_i                               => rs232_rxd_i,
    rs232_txd_o                               => rs232_txd_o,

    -- Reset to FPGA logic
    rstn_o                                    => rs232_rstn,

    -- WISHBONE master
    wb_master_i                               => cbar_slave_o(c_ma_rs232_syscon_id),
    wb_master_o                               => cbar_slave_i(c_ma_rs232_syscon_id)
  );

  -- Insert more FMC ADC boards here
  assert (g_fmc_adc_type = "FMC130M" or g_fmc_adc_type = "FMC250M" or g_fmc_adc_type = "FMCPICO_1M")
    report "[dbe_bpm_gen] FMC ADC board must be either \'FMC130M\' or \'FMC250M\' or \'FMCPICO_1M\'"
    severity Failure;

  gen_fmc130 : if (g_fmc_adc_type = "FMC130M") generate

    ----------------------------------------------------------------------
    --                      FMC 130M_4CH 1 Core                         --
    ----------------------------------------------------------------------

    cmp1_xwb_fmc130m_4ch : xwb_fmc130m_4ch
    generic map(
      g_fpga_device                           => "7SERIES",
      g_delay_type                            => "VAR_LOAD",
      g_interface_mode                        => PIPELINED,
      g_address_granularity                   => BYTE,
      g_with_extra_wb_reg	                    => true,
      --g_adc_clk_period_values                 => default_adc_clk_period_values,
      g_adc_clk_period_values                 => (8.88, 8.88, 8.88, 8.88),
      --g_use_clk_chains                        => default_clk_use_chain,
      -- using clock1 from fmc130m_4ch (CLK2_ M2C_P, CLK2_ M2C_M pair)
      -- using clock0 from fmc130m_4ch.
      -- BUFIO can drive half-bank only, not the full IO bank
      g_use_clk_chains                        => "1111",
      g_with_bufio_clk_chains                 => "0000",
      g_with_bufr_clk_chains                  => "1111",
      g_with_idelayctrl                       => false,
      --g_with_idelayctrl                       => true,
      g_use_data_chains                       => "1111",
      --g_map_clk_data_chains                   => (-1,-1,-1,-1),
      -- Clock 1 is the adc reference clock
      g_ref_clk                               => c_adc_ref_clk,
      g_packet_size                           => 32,
      g_sim                                   => 0
    )
    port map(
      sys_clk_i                               => clk_sys,
      sys_rst_n_i                             => clk_sys_rstn,
      sys_clk_200Mhz_i                        => clk_200mhz,

      -----------------------------
      -- Wishbone Control Interface signals
      -----------------------------
      wb_slv_i                                => cbar_master_o(c_slv_fmc_adc_1_id),
      wb_slv_o                                => cbar_master_i(c_slv_fmc_adc_1_id),

      -----------------------------
      -- External ports
      -----------------------------

      -- ADC LTC2208 interface
      fmc_adc_pga_o                           => fmc130_1_adc_pga_o,
      fmc_adc_shdn_o                          => fmc130_1_adc_shdn_o,
      fmc_adc_dith_o                          => fmc130_1_adc_dith_o,
      fmc_adc_rand_o                          => fmc130_1_adc_rand_o,

      -- ADC0 LTC2208
      fmc_adc0_clk_i                          => fmc130_1_adc0_clk_i,
      fmc_adc0_data_i                         => fmc130_1_adc0_data_i,
      fmc_adc0_of_i                           => fmc130_1_adc0_of_i,

      -- ADC1 LTC2208
      fmc_adc1_clk_i                          => fmc130_1_adc1_clk_i,
      fmc_adc1_data_i                         => fmc130_1_adc1_data_i,
      fmc_adc1_of_i                           => fmc130_1_adc1_of_i,

      -- ADC2 LTC2208
      fmc_adc2_clk_i                          => fmc130_1_adc2_clk_i,
      fmc_adc2_data_i                         => fmc130_1_adc2_data_i,
      fmc_adc2_of_i                           => fmc130_1_adc2_of_i,

      -- ADC3 LTC2208
      fmc_adc3_clk_i                          => fmc130_1_adc3_clk_i,
      fmc_adc3_data_i                         => fmc130_1_adc3_data_i,
      fmc_adc3_of_i                           => fmc130_1_adc3_of_i,

      -- FMC General Status
      --fmc_prsnt_i                             => fmc130_1_prsnt_i,
      --fmc_pg_m2c_i                            => fmc130_1_pg_m2c_i,
      fmc_prsnt_i                             => '0', -- Connected to the CPU
      fmc_pg_m2c_i                            => '0', -- Connected to the CPU

      -- Trigger
      fmc_trig_dir_o                          => fmc130_1_trig_dir_o,
      fmc_trig_term_o                         => fmc130_1_trig_term_o,
      fmc_trig_val_p_b                        => fmc130_1_trig_val_p_b,
      fmc_trig_val_n_b                        => fmc130_1_trig_val_n_b,

      -- Si571 clock gen
      si571_scl_pad_b                         => fmc130_1_si571_scl_pad_b,
      si571_sda_pad_b                         => fmc130_1_si571_sda_pad_b,
      fmc_si571_oe_o                          => fmc130_1_si571_oe_o,

      -- AD9510 clock distribution PLL
      spi_ad9510_cs_o                         => fmc130_1_spi_ad9510_cs_o,
      spi_ad9510_sclk_o                       => fmc130_1_spi_ad9510_sclk_o,
      spi_ad9510_mosi_o                       => fmc130_1_spi_ad9510_mosi_o,
      spi_ad9510_miso_i                       => fmc130_1_spi_ad9510_miso_i,

      fmc_pll_function_o                      => fmc130_1_pll_function_o,
      fmc_pll_status_i                        => fmc130_1_pll_status_i,

      -- AD9510 clock copy
      fmc_fpga_clk_p_i                        => fmc130_1_fpga_clk_p_i,
      fmc_fpga_clk_n_i                        => fmc130_1_fpga_clk_n_i,

      -- Clock reference selection (TS3USB221)
      fmc_clk_sel_o                           => fmc130_1_clk_sel_o,

      -- EEPROM (Connected to the CPU)
      --eeprom_scl_pad_b                        => eeprom_scl_pad_b,
      --eeprom_sda_pad_b                        => eeprom_sda_pad_b,
      eeprom_scl_pad_b                        => fmc130_1_eeprom_scl_pad_b,
      eeprom_sda_pad_b                        => fmc130_1_eeprom_sda_pad_b,

      -- Temperature monitor
      -- LM75AIMM
      lm75_scl_pad_b                          => fmc130_1_lm75_scl_pad_b,
      lm75_sda_pad_b                          => fmc130_1_lm75_sda_pad_b,

      fmc_lm75_temp_alarm_i                   => fmc130_1_lm75_temp_alarm_i,

      -- FMC LEDs
      fmc_led1_o                              => fmc1_led1_int,
      fmc_led2_o                              => fmc1_led2_int,
      fmc_led3_o                              => fmc1_led3_int,

      -----------------------------
      -- Optional external reference clock ports
      -----------------------------
      fmc_ext_ref_clk_i                       => '0',
      fmc_ext_ref_clk2x_i                     => '0',
      fmc_ext_ref_mmcm_locked_i               => '0',

      -----------------------------
      -- ADC output signals. Continuous flow
      -----------------------------
      adc_clk_o                               => fmc1_clk,
      adc_clk2x_o                             => fmc1_clk2x,
      adc_rst_n_o                             => fmc1_rst_n,
      adc_rst2x_n_o                           => fmc1_rst2x_n,
      adc_data_o                              => fmc1_data,
      adc_data_valid_o                        => fmc1_data_valid,

      -----------------------------
      -- General ADC output signals and status
      -----------------------------
      -- Trigger to other FPGA logic
      trig_hw_o                               => fmc1_trig_hw,
      trig_hw_i                               => fmc1_trig_hw_in,

      -- General board status
      fmc_mmcm_lock_o                         => fmc1_mmcm_lock_int,
      fmc_pll_status_o                        => fmc1_pll_status_int,

      -----------------------------
      -- Wishbone Streaming Interface Source
      -----------------------------
      wbs_source_i                            => wbs_fmc1_in_array,
      wbs_source_o                            => wbs_fmc1_out_array,

      adc_dly_debug_o                         => fmc1_adc_dly_debug_int,

      fifo_debug_valid_o                      => fmc1_debug_valid_int,
      fifo_debug_full_o                       => fmc1_debug_full_int,
      fifo_debug_empty_o                      => fmc1_debug_empty_int
    );

    gen_wbs1_dummy_signals : for i in 0 to c_num_adc_channels-1 generate
      wbs_fmc1_in_array(i)                    <= cc_dummy_src_com_in;
    end generate;

    --fmc130_1_mmcm_lock_led_o                   <= fmc1_mmcm_lock_int;
    --fmc130_1_pll_status_led_o                  <= fmc1_pll_status_int;

    fmc130_1_led1_o                            <= fmc1_led1_int;
    fmc130_1_led2_o                            <= fmc1_led2_int;
    fmc130_1_led3_o                            <= fmc1_led3_int;

    fmc1_adc_data_ch0                          <= fmc1_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb);
    fmc1_adc_data_ch1                          <= fmc1_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb);
    fmc1_adc_data_ch2                          <= fmc1_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb);
    fmc1_adc_data_ch3                          <= fmc1_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb);

    fmc1_adc_data_se_ch0                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb)),
                                                   fmc1_adc_data_se_ch0'length));
    fmc1_adc_data_se_ch1                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb)),
                                                   fmc1_adc_data_se_ch1'length));
    fmc1_adc_data_se_ch2                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb)),
                                                   fmc1_adc_data_se_ch2'length));
    fmc1_adc_data_se_ch3                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb)),
                                                   fmc1_adc_data_se_ch3'length));

    fmc1_adc_valid                             <= '1';

    fs1_clk                                    <= fmc1_clk(c_adc_ref_clk);
    fs1_rstn                                   <= fmc1_rst_n(c_adc_ref_clk);
    fs1_clk2x                                  <= fmc1_clk2x(c_adc_ref_clk);
    fs1_rst2xn                                 <= fmc1_rst2x_n(c_adc_ref_clk);

    -- Use ADC trigger for testing
    fmc1_trig_hw_in                            <= trig_pulse_rcv(c_trig_mux_0_id, c_trigger_sw_clk_id).pulse;

    -- Debug clock for chipscope
    fs_clk_dbg                                 <= fs1_clk;
    fs_rstn_dbg                                <= fs1_rstn;
    fs_clk2x_dbg                               <= fs1_clk2x;
    fs_rst2xn_dbg                              <= fs1_rst2xn;

    ----------------------------------------------------------------------
    --                      FMC 130M_4CH 2 Core                         --
    ----------------------------------------------------------------------

    cmp2_xwb_fmc130m_4ch : xwb_fmc130m_4ch
    generic map(
      g_fpga_device                           => "7SERIES",
      g_delay_type                            => "VAR_LOAD",
      g_interface_mode                        => PIPELINED,
      g_address_granularity                   => BYTE,
      g_with_extra_wb_reg                     => true,
      --g_adc_clk_period_values                 => default_adc_clk_period_values,
      g_adc_clk_period_values                 => (8.88, 8.88, 8.88, 8.88),
      --g_use_clk_chains                        => default_clk_use_chain,
      -- using clock1 from fmc130m_4ch (CLK2_ M2C_P, CLK2_ M2C_M pair)
      -- using clock0 from fmc130m_4ch.
      -- BUFIO can drive half-bank only, not the full IO bank
      g_use_clk_chains                        => "1111",
      g_with_bufio_clk_chains                 => "0000",
      g_with_bufr_clk_chains                  => "1111",
      g_with_idelayctrl                       => false,
      --g_with_idelayctrl                       => true,
      g_use_data_chains                       => "1111",
      --g_map_clk_data_chains                   => (-1,-1,-1,-1),
      -- Clock 1 is the adc reference clock
      g_ref_clk                               => c_adc_ref_clk,
      g_packet_size                           => 32,
      g_sim                                   => 0
    )
    port map(
      sys_clk_i                               => clk_sys,
      sys_rst_n_i                             => clk_sys_rstn,
      sys_clk_200Mhz_i                        => clk_200mhz,

      -----------------------------
      -- Wishbone Control Interface signals
      -----------------------------
      wb_slv_i                                => cbar_master_o(c_slv_fmc_adc_2_id),
      wb_slv_o                                => cbar_master_i(c_slv_fmc_adc_2_id),

      -----------------------------
      -- External ports
      -----------------------------

      -- ADC LTC2208 interface
      fmc_adc_pga_o                           => fmc130_2_adc_pga_o,
      fmc_adc_shdn_o                          => fmc130_2_adc_shdn_o,
      fmc_adc_dith_o                          => fmc130_2_adc_dith_o,
      fmc_adc_rand_o                          => fmc130_2_adc_rand_o,

      -- ADC0 LTC2208
      fmc_adc0_clk_i                          => fmc130_2_adc0_clk_i,
      fmc_adc0_data_i                         => fmc130_2_adc0_data_i,
      fmc_adc0_of_i                           => fmc130_2_adc0_of_i,

      -- ADC1 LTC2208
      fmc_adc1_clk_i                          => fmc130_2_adc1_clk_i,
      fmc_adc1_data_i                         => fmc130_2_adc1_data_i,
      fmc_adc1_of_i                           => fmc130_2_adc1_of_i,

      -- ADC2 LTC2208
      fmc_adc2_clk_i                          => fmc130_2_adc2_clk_i,
      fmc_adc2_data_i                         => fmc130_2_adc2_data_i,
      fmc_adc2_of_i                           => fmc130_2_adc2_of_i,

      -- ADC3 LTC2208
      fmc_adc3_clk_i                          => fmc130_2_adc3_clk_i,
      fmc_adc3_data_i                         => fmc130_2_adc3_data_i,
      fmc_adc3_of_i                           => fmc130_2_adc3_of_i,

      -- FMC General Status
      --fmc_prsnt_i                             => fmc130_2_prsnt_i,
      --fmc_pg_m2c_i                            => fmc130_2_pg_m2c_i,
      fmc_prsnt_i                             => '0', -- Connected to the CPU
      fmc_pg_m2c_i                            => '0', -- Connected to the CPU

      -- Trigger
      fmc_trig_dir_o                          => fmc130_2_trig_dir_o,
      fmc_trig_term_o                         => fmc130_2_trig_term_o,
      fmc_trig_val_p_b                        => fmc130_2_trig_val_p_b,
      fmc_trig_val_n_b                        => fmc130_2_trig_val_n_b,

      -- Si571 clock gen
      si571_scl_pad_b                         => fmc130_2_si571_scl_pad_b,
      si571_sda_pad_b                         => fmc130_2_si571_sda_pad_b,
      fmc_si571_oe_o                          => fmc130_2_si571_oe_o,

      -- AD9510 clock distribution PLL
      spi_ad9510_cs_o                         => fmc130_2_spi_ad9510_cs_o,
      spi_ad9510_sclk_o                       => fmc130_2_spi_ad9510_sclk_o,
      spi_ad9510_mosi_o                       => fmc130_2_spi_ad9510_mosi_o,
      spi_ad9510_miso_i                       => fmc130_2_spi_ad9510_miso_i,

      fmc_pll_function_o                      => fmc130_2_pll_function_o,
      fmc_pll_status_i                        => fmc130_2_pll_status_i,

      -- AD9510 clock copy
      fmc_fpga_clk_p_i                        => fmc130_2_fpga_clk_p_i,
      fmc_fpga_clk_n_i                        => fmc130_2_fpga_clk_n_i,

      -- Clock reference selection (TS3USB221)
      fmc_clk_sel_o                           => fmc130_2_clk_sel_o,

      -- EEPROM (Connected to the CPU)
      --eeprom_scl_pad_b                        => eeprom_scl_pad_b,
      --eeprom_sda_pad_b                        => eeprom_sda_pad_b,
      eeprom_scl_pad_b                        => open,
      eeprom_sda_pad_b                        => open,

      -- Temperature monitor
      -- LM75AIMM
      lm75_scl_pad_b                          => fmc130_2_lm75_scl_pad_b,
      lm75_sda_pad_b                          => fmc130_2_lm75_sda_pad_b,

      fmc_lm75_temp_alarm_i                   => fmc130_2_lm75_temp_alarm_i,

      -- FMC LEDs
      fmc_led1_o                              => fmc2_led1_int,
      fmc_led2_o                              => fmc2_led2_int,
      fmc_led3_o                              => fmc2_led3_int,

      -----------------------------
      -- Optional external reference clock ports
      -----------------------------
      fmc_ext_ref_clk_i                       => '0',
      fmc_ext_ref_clk2x_i                     => '0',
      fmc_ext_ref_mmcm_locked_i               => '0',

      -----------------------------
      -- ADC output signals. Continuous flow
      -----------------------------
      adc_clk_o                               => fmc2_clk,
      adc_clk2x_o                             => fmc2_clk2x,
      adc_rst_n_o                             => fmc2_rst_n,
      adc_rst2x_n_o                           => fmc2_rst2x_n,
      adc_data_o                              => fmc2_data,
      adc_data_valid_o                        => fmc2_data_valid,

      -----------------------------
      -- General ADC output signals and status
      -----------------------------
      -- Trigger to other FPGA logic
      trig_hw_o                               => fmc2_trig_hw,
      trig_hw_i                               => fmc2_trig_hw_in,

      -- General board status
      fmc_mmcm_lock_o                         => fmc2_mmcm_lock_int,
      fmc_pll_status_o                        => fmc2_pll_status_int,

      -----------------------------
      -- Wishbone Streaming Interface Source
      -----------------------------
      wbs_source_i                            => wbs_fmc2_in_array,
      wbs_source_o                            => wbs_fmc2_out_array,

      adc_dly_debug_o                         => fmc2_adc_dly_debug_int,

      fifo_debug_valid_o                      => fmc2_debug_valid_int,
      fifo_debug_full_o                       => fmc2_debug_full_int,
      fifo_debug_empty_o                      => fmc2_debug_empty_int
    );

    gen_wbs2_dummy_signals : for i in 0 to c_num_adc_channels-1 generate
      wbs_fmc2_in_array(i)                    <= cc_dummy_src_com_in;
    end generate;

    -- Only FMC 1 is connected for now
    --fmc130_2_mmcm_lock_led_o                   <= fmc2_mmcm_lock_int;
    --fmc130_2_pll_status_led_o                  <= fmc2_pll_status_int;

    fmc130_2_led1_o                            <= fmc2_led1_int;
    fmc130_2_led2_o                            <= fmc2_led2_int;
    fmc130_2_led3_o                            <= fmc2_led3_int;

    fmc2_adc_data_ch0                          <= fmc2_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb);
    fmc2_adc_data_ch1                          <= fmc2_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb);
    fmc2_adc_data_ch2                          <= fmc2_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb);
    fmc2_adc_data_ch3                          <= fmc2_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb);

    fmc2_adc_data_se_ch0                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb)),
                                                   fmc2_adc_data_se_ch0'length));
    fmc2_adc_data_se_ch1                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb)),
                                                   fmc2_adc_data_se_ch1'length));
    fmc2_adc_data_se_ch2                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb)),
                                                   fmc2_adc_data_se_ch2'length));
    fmc2_adc_data_se_ch3                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb)),
                                                   fmc2_adc_data_se_ch3'length));

    fmc2_adc_valid                             <= '1';

    fs2_clk                                    <= fmc2_clk(c_adc_ref_clk);
    fs2_rstn                                   <= fmc2_rst_n(c_adc_ref_clk);
    fs2_clk2x                                  <= fmc2_clk2x(c_adc_ref_clk);
    fs2_rst2xn                                 <= fmc2_rst2x_n(c_adc_ref_clk);

    -- Use ADC trigger for testing
    fmc2_trig_hw_in                            <= trig_pulse_rcv(c_trig_mux_1_id, c_trigger_sw_clk_id).pulse;

  end generate;

  gen_fmc250 : if (g_fmc_adc_type = "FMC250M") generate

    ----------------------------------------------------------------------
    --                      FMC 250M_4CH 1 Core                         --
    ----------------------------------------------------------------------

    cmp1_xwb_fmc250m_4ch : xwb_fmc250m_4ch
    generic map(
      g_fpga_device                           => "7SERIES",
      g_delay_type                            => "VAR_LOAD",
      g_interface_mode                        => PIPELINED,
      g_address_granularity                   => BYTE,
      g_with_extra_wb_reg	                    => true,
      --g_adc_clk_period_values                 => default_adc_clk_period_values,
      g_adc_clk_period_values                 => (4.00, 4.00, 4.00, 4.00),
      --g_use_clk_chains                        => default_clk_use_chain,
      -- using clock1 from fmc250m_4ch (CLK2_ M2C_P, CLK2_ M2C_M pair)
      -- using clock0 from fmc250m_4ch.
      -- BUFIO can drive half-bank only, not the full IO bank
      g_use_clk_chains                        => "1111",
      g_with_bufio_clk_chains                 => "0000",
      g_with_bufr_clk_chains                  => "1111",
      g_with_idelayctrl                       => false,
      --g_with_idelayctrl                       => true,
      g_use_data_chains                       => "1111",
      --g_map_clk_data_chains                   => (-1,-1,-1,-1),
      -- Clock 1 is the adc reference clock
      g_ref_clk                               => c_adc_ref_clk,
      g_packet_size                           => 32,
      g_sim                                   => 0
    )
    port map(
      sys_clk_i                               => clk_sys,
      sys_rst_n_i                             => clk_sys_rstn,
      sys_clk_200Mhz_i                        => clk_200mhz,

      -----------------------------
      -- Wishbone Control Interface signals
      -----------------------------
      wb_slv_i                                => cbar_master_o(c_slv_fmc_adc_1_id),
      wb_slv_o                                => cbar_master_i(c_slv_fmc_adc_1_id),

      -----------------------------
      -- External ports
      -----------------------------

      -- ADC clock (half of the sampling frequency) divider reset
      adc_clk_div_rst_p_o                     => fmc250_1_adc_clk_div_rst_p_o,
      adc_clk_div_rst_n_o                     => fmc250_1_adc_clk_div_rst_n_o,
      adc_ext_rst_n_o                         => fmc250_1_adc_ext_rst_n_o,
      adc_sleep_o                             => fmc250_1_adc_sleep_o,

      -- ADC clocks. One clock per ADC channel.
      -- Only ch1 clock is used as all data chains
      -- are sampled at the same frequency
      adc_clk0_p_i                            => fmc250_1_adc_clk0_p_i,
      adc_clk0_n_i                            => fmc250_1_adc_clk0_n_i,
      adc_clk1_p_i                            => fmc250_1_adc_clk1_p_i,
      adc_clk1_n_i                            => fmc250_1_adc_clk1_n_i,
      adc_clk2_p_i                            => fmc250_1_adc_clk2_p_i,
      adc_clk2_n_i                            => fmc250_1_adc_clk2_n_i,
      adc_clk3_p_i                            => fmc250_1_adc_clk3_p_i,
      adc_clk3_n_i                            => fmc250_1_adc_clk3_n_i,

      -- DDR ADC data channels.
      adc_data_ch0_p_i                        => fmc250_1_adc_data_ch0_p_i,
      adc_data_ch0_n_i                        => fmc250_1_adc_data_ch0_n_i,
      adc_data_ch1_p_i                        => fmc250_1_adc_data_ch1_p_i,
      adc_data_ch1_n_i                        => fmc250_1_adc_data_ch1_n_i,
      adc_data_ch2_p_i                        => fmc250_1_adc_data_ch2_p_i,
      adc_data_ch2_n_i                        => fmc250_1_adc_data_ch2_n_i,
      adc_data_ch3_p_i                        => fmc250_1_adc_data_ch3_p_i,
      adc_data_ch3_n_i                        => fmc250_1_adc_data_ch3_n_i,

      -- FMC General Status
      --fmc_prsnt_i                             => fmc250_1_prsnt_i,
      --fmc_pg_m2c_i                            => fmc250_1_pg_m2c_i,
      fmc_prsnt_i                             => '0', -- Connected to the CPU
      fmc_pg_m2c_i                            => '0', -- Connected to the CPU

      -- Trigger
      fmc_trig_dir_o                          => fmc250_1_trig_dir_o,
      fmc_trig_term_o                         => fmc250_1_trig_term_o,
      fmc_trig_val_p_b                        => fmc250_1_trig_val_p_b,
      fmc_trig_val_n_b                        => fmc250_1_trig_val_n_b,

      -- ADC SPI control interface.
      adc_spi_clk_o                           => fmc250_1_adc_spi_clk_o,
      adc_spi_mosi_o                          => fmc250_1_adc_spi_mosi_o,
      adc_spi_miso_i                          => fmc250_1_adc_spi_miso_i,
      adc_spi_cs_adc0_n_o                     => fmc250_1_adc_spi_cs_adc0_n_o,
      adc_spi_cs_adc1_n_o                     => fmc250_1_adc_spi_cs_adc1_n_o,
      adc_spi_cs_adc2_n_o                     => fmc250_1_adc_spi_cs_adc2_n_o,
      adc_spi_cs_adc3_n_o                     => fmc250_1_adc_spi_cs_adc3_n_o,

      -- Si571 clock gen
      si571_scl_pad_b                         => fmc250_1_si571_scl_pad_b,
      si571_sda_pad_b                         => fmc250_1_si571_sda_pad_b,
      fmc_si571_oe_o                          => fmc250_1_si571_oe_o,

      -- AD9510 clock distribution PLL
      spi_ad9510_cs_o                         => fmc250_1_spi_ad9510_cs_o,
      spi_ad9510_sclk_o                       => fmc250_1_spi_ad9510_sclk_o,
      spi_ad9510_mosi_o                       => fmc250_1_spi_ad9510_mosi_o,
      spi_ad9510_miso_i                       => fmc250_1_spi_ad9510_miso_i,

      fmc_pll_function_o                      => fmc250_1_pll_function_o,
      fmc_pll_status_i                        => fmc250_1_pll_status_i,

      -- AD9510 clock copy
      fmc_fpga_clk_p_i                        => fmc250_1_fpga_clk_p_i,
      fmc_fpga_clk_n_i                        => fmc250_1_fpga_clk_n_i,

      -- Clock reference selection (TS3USB221)
      fmc_clk_sel_o                           => fmc250_1_clk_sel_o,

      -- EEPROM (Connected to the CPU)
      --eeprom_scl_pad_b                        => eeprom_scl_pad_b,
      --eeprom_sda_pad_b                        => eeprom_sda_pad_b,
      eeprom_scl_pad_b                       => fmc250_1_eeprom_scl_pad_b,
      eeprom_sda_pad_b                       => fmc250_1_eeprom_sda_pad_b,

      -- AMC7823 temperature monitor
      amc7823_spi_cs_o                        => fmc250_1_amc7823_spi_cs_o,
      amc7823_spi_sclk_o                      => fmc250_1_amc7823_spi_sclk_o,
      amc7823_spi_mosi_o                      => fmc250_1_amc7823_spi_mosi_o,
      amc7823_spi_miso_i                      => fmc250_1_amc7823_spi_miso_i,
      amc7823_davn_i                          => fmc250_1_amc7823_davn_i,

      -- FMC LEDs
      fmc_led1_o                              => fmc1_led1_int,
      fmc_led2_o                              => fmc1_led2_int,
      fmc_led3_o                              => fmc1_led3_int,

      -----------------------------
      -- Optional external reference clock ports
      -----------------------------
      fmc_ext_ref_clk_i                       => '0',
      fmc_ext_ref_clk2x_i                     => '0',
      fmc_ext_ref_mmcm_locked_i               => '0',

      -----------------------------
      -- ADC output signals. Continuous flow
      -----------------------------
      adc_clk_o                               => fmc1_clk,
      adc_clk2x_o                             => fmc1_clk2x,
      adc_rst_n_o                             => fmc1_rst_n,
      adc_rst2x_n_o                           => fmc1_rst2x_n,
      adc_data_o                              => fmc1_data,
      adc_data_valid_o                        => fmc1_data_valid,

      -----------------------------
      -- General ADC output signals and status
      -----------------------------
      -- Trigger to other FPGA logic
      trig_hw_o                               => fmc1_trig_hw,
      trig_hw_i                               => fmc1_trig_hw_in,

      -- General board status
      fmc_mmcm_lock_o                         => fmc1_mmcm_lock_int,
      fmc_pll_status_o                        => fmc1_pll_status_int,

      -----------------------------
      -- Wishbone Streaming Interface Source
      -----------------------------
      wbs_source_i                            => wbs_fmc1_in_array,
      wbs_source_o                            => wbs_fmc1_out_array,

      adc_dly_debug_o                         => fmc1_adc_dly_debug_int,

      fifo_debug_valid_o                      => fmc1_debug_valid_int,
      fifo_debug_full_o                       => fmc1_debug_full_int,
      fifo_debug_empty_o                      => fmc1_debug_empty_int
    );

    gen_wbs1_dummy_signals : for i in 0 to c_num_adc_channels-1 generate
      wbs_fmc1_in_array(i)                    <= cc_dummy_src_com_in;
    end generate;

    --fmc250_1_mmcm_lock_led_o                   <= fmc1_mmcm_lock_int;
    --fmc250_1_pll_status_led_o                  <= fmc1_pll_status_int;

    fmc250_1_led1_o                            <= fmc1_led1_int;
    fmc250_1_led2_o                            <= fmc1_led2_int;
    fmc250_1_led3_o                            <= fmc1_led3_int;

    fmc1_adc_data_ch0                          <= fmc1_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb);
    fmc1_adc_data_ch1                          <= fmc1_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb);
    fmc1_adc_data_ch2                          <= fmc1_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb);
    fmc1_adc_data_ch3                          <= fmc1_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb);

    fmc1_adc_data_se_ch0                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb)),
                                                   fmc1_adc_data_se_ch0'length));
    fmc1_adc_data_se_ch1                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb)),
                                                   fmc1_adc_data_se_ch1'length));
    fmc1_adc_data_se_ch2                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb)),
                                                   fmc1_adc_data_se_ch2'length));
    fmc1_adc_data_se_ch3                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb)),
                                                   fmc1_adc_data_se_ch3'length));

    fmc1_adc_valid                             <= '1';

    fs1_clk                                    <= fmc1_clk(c_adc_ref_clk);
    fs1_rstn                                   <= fmc1_rst_n(c_adc_ref_clk);
    fs1_clk2x                                  <= fmc1_clk2x(c_adc_ref_clk);
    fs1_rst2xn                                 <= fmc1_rst2x_n(c_adc_ref_clk);

    -- Use ADC trigger for testing
    fmc1_trig_hw_in                            <= trig_pulse_rcv(c_trig_mux_0_id, c_trigger_sw_clk_id).pulse;

    -- Debug clock for chipscope
    fs_clk_dbg                                 <= fs1_clk;
    fs_rstn_dbg                                <= fs1_rstn;
    fs_clk2x_dbg                               <= fs1_clk2x;
    fs_rst2xn_dbg                              <= fs1_rst2xn;

    ----------------------------------------------------------------------
    --                      FMC 250M_4CH 2 Core                         --
    ----------------------------------------------------------------------

    cmp2_xwb_fmc250m_4ch : xwb_fmc250m_4ch
    generic map(
      g_fpga_device                           => "7SERIES",
      g_delay_type                            => "VAR_LOAD",
      g_interface_mode                        => PIPELINED,
      g_address_granularity                   => BYTE,
      g_with_extra_wb_reg                     => true,
      --g_adc_clk_period_values                 => default_adc_clk_period_values,
      g_adc_clk_period_values                 => (4.00, 4.00, 4.00, 4.00),
      --g_use_clk_chains                        => default_clk_use_chain,
      -- using clock1 from fmc250m_4ch (CLK2_ M2C_P, CLK2_ M2C_M pair)
      -- using clock0 from fmc250m_4ch.
      -- BUFIO can drive half-bank only, not the full IO bank
      g_use_clk_chains                        => "1111",
      g_with_bufio_clk_chains                 => "0000",
      g_with_bufr_clk_chains                  => "1111",
      g_with_idelayctrl                       => false,
      --g_with_idelayctrl                       => true,
      g_use_data_chains                       => "1111",
      --g_map_clk_data_chains                   => (-1,-1,-1,-1),
      -- Clock 1 is the adc reference clock
      g_ref_clk                               => c_adc_ref_clk,
      g_packet_size                           => 32,
      g_sim                                   => 0
    )
    port map(
      sys_clk_i                               => clk_sys,
      sys_rst_n_i                             => clk_sys_rstn,
      sys_clk_200Mhz_i                        => clk_200mhz,

      -----------------------------
      -- Wishbone Control Interface signals
      -----------------------------
      wb_slv_i                                => cbar_master_o(c_slv_fmc_adc_2_id),
      wb_slv_o                                => cbar_master_i(c_slv_fmc_adc_2_id),

      -----------------------------
      -- External ports
      -----------------------------
      -- ADC clock (half of the sampling frequency) divider reset
      adc_clk_div_rst_p_o                     => fmc250_2_adc_clk_div_rst_p_o,
      adc_clk_div_rst_n_o                     => fmc250_2_adc_clk_div_rst_n_o,
      adc_ext_rst_n_o                         => fmc250_2_adc_ext_rst_n_o,
      adc_sleep_o                             => fmc250_2_adc_sleep_o,

      -- ADC clocks. One clock per ADC channel.
      -- Only ch1 clock is used as all data chains
      -- are sampled at the same frequency
      adc_clk0_p_i                            => fmc250_2_adc_clk0_p_i,
      adc_clk0_n_i                            => fmc250_2_adc_clk0_n_i,
      adc_clk1_p_i                            => fmc250_2_adc_clk1_p_i,
      adc_clk1_n_i                            => fmc250_2_adc_clk1_n_i,
      adc_clk2_p_i                            => fmc250_2_adc_clk2_p_i,
      adc_clk2_n_i                            => fmc250_2_adc_clk2_n_i,
      adc_clk3_p_i                            => fmc250_2_adc_clk3_p_i,
      adc_clk3_n_i                            => fmc250_2_adc_clk3_n_i,

      -- DDR ADC data channels.
      adc_data_ch0_p_i                        => fmc250_2_adc_data_ch0_p_i,
      adc_data_ch0_n_i                        => fmc250_2_adc_data_ch0_n_i,
      adc_data_ch1_p_i                        => fmc250_2_adc_data_ch1_p_i,
      adc_data_ch1_n_i                        => fmc250_2_adc_data_ch1_n_i,
      adc_data_ch2_p_i                        => fmc250_2_adc_data_ch2_p_i,
      adc_data_ch2_n_i                        => fmc250_2_adc_data_ch2_n_i,
      adc_data_ch3_p_i                        => fmc250_2_adc_data_ch3_p_i,
      adc_data_ch3_n_i                        => fmc250_2_adc_data_ch3_n_i,

      -- FMC General Status
      --fmc_prsnt_i                             => fmc250_2_prsnt_i,
      --fmc_pg_m2c_i                            => fmc250_2_pg_m2c_i,
      fmc_prsnt_i                             => '0', -- Connected to the CPU
      fmc_pg_m2c_i                            => '0', -- Connected to the CPU

      -- Trigger
      fmc_trig_dir_o                          => fmc250_2_trig_dir_o,
      fmc_trig_term_o                         => fmc250_2_trig_term_o,
      fmc_trig_val_p_b                        => fmc250_2_trig_val_p_b,
      fmc_trig_val_n_b                        => fmc250_2_trig_val_n_b,

      -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
      adc_spi_clk_o                           => fmc250_2_adc_spi_clk_o,
      adc_spi_mosi_o                          => fmc250_2_adc_spi_mosi_o,
      adc_spi_miso_i                          => fmc250_2_adc_spi_miso_i,
      adc_spi_cs_adc0_n_o                     => fmc250_2_adc_spi_cs_adc0_n_o,
      adc_spi_cs_adc1_n_o                     => fmc250_2_adc_spi_cs_adc1_n_o,
      adc_spi_cs_adc2_n_o                     => fmc250_2_adc_spi_cs_adc2_n_o,
      adc_spi_cs_adc3_n_o                     => fmc250_2_adc_spi_cs_adc3_n_o,

      -- Si571 clock gen
      si571_scl_pad_b                         => fmc250_2_si571_scl_pad_b,
      si571_sda_pad_b                         => fmc250_2_si571_sda_pad_b,
      fmc_si571_oe_o                          => fmc250_2_si571_oe_o,

      -- AD9510 clock distribution PLL
      spi_ad9510_cs_o                         => fmc250_2_spi_ad9510_cs_o,
      spi_ad9510_sclk_o                       => fmc250_2_spi_ad9510_sclk_o,
      spi_ad9510_mosi_o                       => fmc250_2_spi_ad9510_mosi_o,
      spi_ad9510_miso_i                       => fmc250_2_spi_ad9510_miso_i,

      fmc_pll_function_o                      => fmc250_2_pll_function_o,
      fmc_pll_status_i                        => fmc250_2_pll_status_i,

      -- AD9510 clock copy
      fmc_fpga_clk_p_i                        => fmc250_2_fpga_clk_p_i,
      fmc_fpga_clk_n_i                        => fmc250_2_fpga_clk_n_i,

      -- Clock reference selection (TS3USB221)
      fmc_clk_sel_o                           => fmc250_2_clk_sel_o,

      -- EEPROM (Connected to the CPU)
      --eeprom_scl_pad_b                        => eeprom_scl_pad_b,
      --eeprom_sda_pad_b                        => eeprom_sda_pad_b,
      eeprom_scl_pad_b                        => open,
      eeprom_sda_pad_b                        => open,

      -- AMC7823 temperature monitor
      amc7823_spi_cs_o                        => fmc250_2_amc7823_spi_cs_o,
      amc7823_spi_sclk_o                      => fmc250_2_amc7823_spi_sclk_o,
      amc7823_spi_mosi_o                      => fmc250_2_amc7823_spi_mosi_o,
      amc7823_spi_miso_i                      => fmc250_2_amc7823_spi_miso_i,
      amc7823_davn_i                          => fmc250_2_amc7823_davn_i,

      -- FMC LEDs
      fmc_led1_o                              => fmc2_led1_int,
      fmc_led2_o                              => fmc2_led2_int,
      fmc_led3_o                              => fmc2_led3_int,

      -----------------------------
      -- Optional external reference clock ports
      -----------------------------
      fmc_ext_ref_clk_i                       => '0',
      fmc_ext_ref_clk2x_i                     => '0',
      fmc_ext_ref_mmcm_locked_i               => '0',

      -----------------------------
      -- ADC output signals. Continuous flow
      -----------------------------
      adc_clk_o                               => fmc2_clk,
      adc_clk2x_o                             => fmc2_clk2x,
      adc_rst_n_o                             => fmc2_rst_n,
      adc_rst2x_n_o                           => fmc2_rst2x_n,
      adc_data_o                              => fmc2_data,
      adc_data_valid_o                        => fmc2_data_valid,

      -----------------------------
      -- General ADC output signals and status
      -----------------------------
      -- Trigger to other FPGA logic
      trig_hw_o                               => fmc2_trig_hw,
      trig_hw_i                               => fmc2_trig_hw_in,

      -- General board status
      fmc_mmcm_lock_o                         => fmc2_mmcm_lock_int,
      fmc_pll_status_o                        => fmc2_pll_status_int,

      -----------------------------
      -- Wishbone Streaming Interface Source
      -----------------------------
      wbs_source_i                            => wbs_fmc2_in_array,
      wbs_source_o                            => wbs_fmc2_out_array,

      adc_dly_debug_o                         => fmc2_adc_dly_debug_int,

      fifo_debug_valid_o                      => fmc2_debug_valid_int,
      fifo_debug_full_o                       => fmc2_debug_full_int,
      fifo_debug_empty_o                      => fmc2_debug_empty_int
    );

    gen_wbs2_dummy_signals : for i in 0 to c_num_adc_channels-1 generate
      wbs_fmc2_in_array(i)                    <= cc_dummy_src_com_in;
    end generate;

    -- Only FMC 1 is connected for now
    --fmc250_2_mmcm_lock_led_o                   <= fmc2_mmcm_lock_int;
    --fmc250_2_pll_status_led_o                  <= fmc2_pll_status_int;

    fmc250_2_led1_o                            <= fmc2_led1_int;
    fmc250_2_led2_o                            <= fmc2_led2_int;
    fmc250_2_led3_o                            <= fmc2_led3_int;

    fmc2_adc_data_ch0                          <= fmc2_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb);
    fmc2_adc_data_ch1                          <= fmc2_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb);
    fmc2_adc_data_ch2                          <= fmc2_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb);
    fmc2_adc_data_ch3                          <= fmc2_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb);

    fmc2_adc_data_se_ch0                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb)),
                                                   fmc2_adc_data_se_ch0'length));
    fmc2_adc_data_se_ch1                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb)),
                                                   fmc2_adc_data_se_ch1'length));
    fmc2_adc_data_se_ch2                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb)),
                                                   fmc2_adc_data_se_ch2'length));
    fmc2_adc_data_se_ch3                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb)),
                                                   fmc2_adc_data_se_ch3'length));

    fmc2_adc_valid                             <= '1';

    fs2_clk                                    <= fmc2_clk(c_adc_ref_clk);
    fs2_rstn                                   <= fmc2_rst_n(c_adc_ref_clk);
    fs2_clk2x                                  <= fmc2_clk2x(c_adc_ref_clk);
    fs2_rst2xn                                 <= fmc2_rst2x_n(c_adc_ref_clk);

    -- Use ADC trigger for testing
    fmc2_trig_hw_in                            <= trig_pulse_rcv(c_trig_mux_1_id, c_trigger_sw_clk_id).pulse;

  end generate;

  gen_fmcpico_1m : if (g_fmc_adc_type = "FMCPICO_1M") generate

    ----------------------------------------------------------------------
    --                      FMC PICO 1M_4CH 1 Core                         --
    ----------------------------------------------------------------------

    cmp1_xwb_fmcpico1m_4ch : xwb_fmcpico1m_4ch
    generic map
    (
      g_interface_mode                          => PIPELINED,
      g_address_granularity                     => BYTE
      -- g_num_adc_bits                             natural := 20;
      -- g_num_adc_channels                         natural := 4;
      -- g_clk_freq                                 natural := 300000000; -- Hz
      -- g_sclk_freq                                natural := 75000000 --Hz
    )
    port map
    (
      sys_clk_i                               => clk_sys,
      sys_rst_n_i                             => clk_sys_rstn,
      sys_clk_200Mhz_i                        => clk_200mhz,

      -----------------------------
      -- Wishbone Control Interface signals
      -----------------------------
      wb_slv_i                                => cbar_master_o(c_slv_fmc_adc_1_id),
      wb_slv_o                                => cbar_master_i(c_slv_fmc_adc_1_id),

      -----------------------------
      -- External ports
      -----------------------------

      adc_fast_spi_clk_i                      => clk_300mhz,
      adc_fast_spi_rstn_i                     => clk_300mhz_rstn,

      -- Control signals
      adc_start_i                             => '1',

      -- SPI bus
      adc_sdo1_i                              => fmcpico_1_adc_sdo1_i,
      adc_sdo2_i                              => fmcpico_1_adc_sdo2_i,
      adc_sdo3_i                              => fmcpico_1_adc_sdo3_i,
      adc_sdo4_i                              => fmcpico_1_adc_sdo4_i,
      adc_sck_o                               => fmcpico_1_adc_sck_o,
      adc_sck_rtrn_i                          => fmcpico_1_adc_sck_rtrn_i,
      adc_busy_cmn_i                          => fmcpico_1_adc_busy_cmn_i,
      adc_cnv_out_o                           => fmcpico_1_adc_cnv_o,

      -- Range selection
      adc_rng_r1_o                            => fmcpico_1_rng_r1_o,
      adc_rng_r2_o                            => fmcpico_1_rng_r2_o,
      adc_rng_r3_o                            => fmcpico_1_rng_r3_o,
      adc_rng_r4_o                            => fmcpico_1_rng_r4_o,

      -- Board LEDs
      fmc_led1_o                              => fmcpico_1_led1_o,
      fmc_led2_o                              => fmcpico_1_led2_o,

      -----------------------------
      -- ADC output signals. Continuous flow
      -----------------------------
      -- clock to CDC. This must be g_sclk_freq/g_num_adc_bits. A regular 100MHz should
      -- suffice in all cases
      adc_clk_i                               => fs1_clk,
      adc_data_o                              => fmc1_data,
      adc_data_valid_o                        => fmc1_data_valid,
      adc_out_busy_o                          => fmc1_adc_busy
    );

    fmc1_adc_data_ch0                         <= fmc1_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb);
    fmc1_adc_data_ch1                         <= fmc1_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb);
    fmc1_adc_data_ch2                         <= fmc1_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb);
    fmc1_adc_data_ch3                         <= fmc1_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb);

    fmc1_adc_data_se_ch0                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb)),
                                                   fmc1_adc_data_se_ch0'length));
    fmc1_adc_data_se_ch1                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb)),
                                                   fmc1_adc_data_se_ch1'length));
    fmc1_adc_data_se_ch2                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb)),
                                                   fmc1_adc_data_se_ch2'length));
    fmc1_adc_data_se_ch3                       <= std_logic_vector(resize(signed(
                                                   fmc1_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb)),
                                                   fmc1_adc_data_se_ch3'length));

    fmc1_adc_valid                             <= fmc1_data_valid(0);

    fmc1_clk                                   <= (others => clk_sys);
    fmc1_clk2x                                 <= (others => clk_sys);
    fmc1_rst_n                                 <= (others => clk_sys_rstn);
    fmc1_rst2x_n                               <= (others => clk_sys_rstn);

    fs1_clk                                    <= fmc1_clk(c_adc_ref_clk);
    fs1_clk2x                                  <= fmc1_clk2x(c_adc_ref_clk);
    fs1_rstn                                   <= fmc1_rst_n(c_adc_ref_clk);
    fs1_rst2xn                                 <= fmc1_rst2x_n(c_adc_ref_clk);

    -- Temporary assignemnts
    fmcpico_1_sm_scl_o                         <= '0';
    fmcpico_1_a_scl_o                          <= '0';

    ----------------------------------------------------------------------
    --                      FMC PICO 1M_4CH 2 Core                         --
    ----------------------------------------------------------------------

    cmp2_xwb_fmcpico1m_4ch : xwb_fmcpico1m_4ch
    generic map
    (
      g_interface_mode                          => PIPELINED,
      g_address_granularity                     => BYTE
      -- g_num_adc_bits                             natural := 20;
      -- g_num_adc_channels                         natural := 4;
      -- g_clk_freq                                 natural := 300000000; -- Hz
      -- g_sclk_freq                                natural := 75000000 --Hz
    )
    port map
    (
      sys_clk_i                               => clk_sys,
      sys_rst_n_i                             => clk_sys_rstn,
      sys_clk_200Mhz_i                        => clk_200mhz,

      -----------------------------
      -- Wishbone Control Interface signals
      -----------------------------
      wb_slv_i                                => cbar_master_o(c_slv_fmc_adc_2_id),
      wb_slv_o                                => cbar_master_i(c_slv_fmc_adc_2_id),

      -----------------------------
      -- External ports
      -----------------------------

      adc_fast_spi_clk_i                      => clk_300mhz,
      adc_fast_spi_rstn_i                     => clk_300mhz_rstn,

      -- Control signals
      adc_start_i                             => '1',

      -- SPI bus
      adc_sdo1_i                              => fmcpico_2_adc_sdo1_i,
      adc_sdo2_i                              => fmcpico_2_adc_sdo2_i,
      adc_sdo3_i                              => fmcpico_2_adc_sdo3_i,
      adc_sdo4_i                              => fmcpico_2_adc_sdo4_i,
      adc_sck_o                               => fmcpico_2_adc_sck_o,
      adc_sck_rtrn_i                          => fmcpico_2_adc_sck_rtrn_i,
      adc_busy_cmn_i                          => fmcpico_2_adc_busy_cmn_i,
      adc_cnv_out_o                           => fmcpico_2_adc_cnv_o,

      -- Range selection
      adc_rng_r1_o                            => fmcpico_2_rng_r1_o,
      adc_rng_r2_o                            => fmcpico_2_rng_r2_o,
      adc_rng_r3_o                            => fmcpico_2_rng_r3_o,
      adc_rng_r4_o                            => fmcpico_2_rng_r4_o,

      -- Board LEDs
      fmc_led1_o                              => fmcpico_2_led1_o,
      fmc_led2_o                              => fmcpico_2_led2_o,

      -----------------------------
      -- ADC output signals. Continuous flow
      -----------------------------
      -- clock to CDC. This must be g_sclk_freq/g_num_adc_bits. A regular 100MHz should
      -- suffice in all cases
      adc_clk_i                               => fs2_clk,
      adc_data_o                              => fmc2_data,
      adc_data_valid_o                        => fmc2_data_valid,
      adc_out_busy_o                          => fmc2_adc_busy
    );

    fmc2_adc_data_ch0                          <= fmc2_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb);
    fmc2_adc_data_ch1                          <= fmc2_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb);
    fmc2_adc_data_ch2                          <= fmc2_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb);
    fmc2_adc_data_ch3                          <= fmc2_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb);

    fmc2_adc_data_se_ch0                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb)),
                                                   fmc2_adc_data_se_ch0'length));
    fmc2_adc_data_se_ch1                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb)),
                                                   fmc2_adc_data_se_ch1'length));
    fmc2_adc_data_se_ch2                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb)),
                                                   fmc2_adc_data_se_ch2'length));
    fmc2_adc_data_se_ch3                       <= std_logic_vector(resize(signed(
                                                   fmc2_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb)),
                                                   fmc2_adc_data_se_ch3'length));

    fmc2_adc_valid                             <= fmc2_data_valid(0);

    fmc2_clk                                   <= (others => clk_sys);
    fmc2_clk2x                                 <= (others => clk_sys);
    fmc2_rst_n                                 <= (others => clk_sys_rstn);
    fmc2_rst2x_n                               <= (others => clk_sys_rstn);

    fs2_clk                                    <= fmc2_clk(c_adc_ref_clk);
    fs2_clk2x                                  <= fmc2_clk2x(c_adc_ref_clk);
    fs2_rstn                                   <= fmc2_rst_n(c_adc_ref_clk);
    fs2_rst2xn                                 <= fmc2_rst2x_n(c_adc_ref_clk);

    ---- Connected through FPGA MUX
    ---- Temporary assignemnts
    --fmcpico_2_sm_scl_o                         <= '0';
    --fmcpico_2_a_scl_o                          <= '0';

  end generate;

  ----------------------------------------------------------------------
  --                      DSP Chain 1 Core                            --
  ----------------------------------------------------------------------

  cmp1_xwb_position_calc_core : xwb_position_calc_core
  generic map (
    g_interface_mode                        => PIPELINED,
    g_address_granularity                   => BYTE,
    g_with_extra_wb_reg                     => true,

    -- selection of position_calc stages
    g_with_downconv                         => c_pos_calc_with_downconv,

    -- input sizes
    g_input_width                           => c_num_unprocessed_bits,
    g_mixed_width                           => c_pos_calc_mixed_width,
    g_adc_ratio                             => c_pos_calc_adc_ratio,

    -- mixer
    g_dds_width                             => c_pos_calc_dds_width,
    g_dds_points                            => c_pos_calc_dds_points,
    g_sin_file                              => c_pos_calc_sin_file,
    g_cos_file                              => c_pos_calc_cos_file,

    -- CIC setup
    g_tbt_cic_delay                         => c_pos_calc_tbt_cic_delay,
    g_tbt_cic_stages                        => c_pos_calc_tbt_cic_stages,
    g_tbt_ratio                             => c_pos_calc_tbt_ratio,
    g_tbt_decim_width                       => c_pos_calc_tbt_decim_width,

    g_fofb_cic_delay                        => c_pos_calc_fofb_cic_delay,
    g_fofb_cic_stages                       => c_pos_calc_fofb_cic_stages,
    g_fofb_ratio                            => c_pos_calc_fofb_ratio,
    g_fofb_decim_width                      => c_pos_calc_fofb_decim_width,

    g_monit1_cic_delay                      => c_pos_calc_monit1_cic_delay,
    g_monit1_cic_stages                     => c_pos_calc_monit1_cic_stages,
    g_monit1_ratio                          => c_pos_calc_monit1_ratio,
    g_monit1_cic_ratio                      => c_pos_calc_monit1_cic_ratio,

    g_monit2_cic_delay                      => c_pos_calc_monit2_cic_delay,
    g_monit2_cic_stages                     => c_pos_calc_monit2_cic_stages,
    g_monit2_ratio                          => c_pos_calc_monit2_ratio,
    g_monit2_cic_ratio                      => c_pos_calc_monit2_cic_ratio,

    -- Cordic setup
    g_tbt_cordic_stages                     => c_pos_calc_tbt_cordic_stages,
    g_tbt_cordic_iter_per_clk               => c_pos_calc_tbt_cordic_iter_per_clk,
    g_tbt_cordic_ratio                      => c_pos_calc_tbt_cordic_ratio,

    g_fofb_cordic_stages                    => c_pos_calc_fofb_cordic_stages,
    g_fofb_cordic_iter_per_clk              => c_pos_calc_fofb_cordic_iter_per_clk,
    g_fofb_cordic_ratio                     => c_pos_calc_fofb_cordic_ratio,

    g_monit_decim_width                     => c_pos_calc_monit_decim_width,

    -- width of K constants
    g_k_width                               => c_pos_calc_k_width,

    --width for IQ output
    g_IQ_width                              => c_pos_calc_IQ_width,

    -- Swap/de-swap setup
    g_delay_vec_width                       => c_pos_calc_delay_vec_width,
    g_swap_div_freq_vec_width               => c_pos_calc_swap_div_freq_vec_width
  )
  port map (
    rst_n_i                                 => clk_sys_rstn,
    clk_i                                   => clk_sys,  -- Wishbone clock
    fs_rst_n_i                              => fs1_rstn,
    fs_rst2x_n_i                            => fs1_rst2xn,
    fs_clk_i                                => fs1_clk,
    fs_clk2x_i                              => fs1_clk2x,

    -----------------------------
    -- Wishbone signals
    -----------------------------
    wb_slv_i                                => cbar_master_o(c_slv_pos_calc_1_id),
    wb_slv_o                                => cbar_master_i(c_slv_pos_calc_1_id),

    -----------------------------
    -- Raw ADC signals
    -----------------------------
    adc_ch0_i                               => fmc1_adc_data_ch0,
    adc_ch1_i                               => fmc1_adc_data_ch1,
    adc_ch2_i                               => fmc1_adc_data_ch2,
    adc_ch3_i                               => fmc1_adc_data_ch3,
    adc_valid_i                             => fmc1_adc_valid,

    -----------------------------
    -- Position calculation at various rates
    -----------------------------
    adc_ch0_swap_o                          => dsp1_adc_ch0_data,
    adc_ch1_swap_o                          => dsp1_adc_ch1_data,
    adc_ch2_swap_o                          => dsp1_adc_ch2_data,
    adc_ch3_swap_o                          => dsp1_adc_ch3_data,
    adc_swap_valid_o                        => dsp1_adc_valid,

    mix_ch0_i_o                             => dsp1_mixi_ch0,
    mix_ch0_q_o                             => dsp1_mixq_ch0,
    mix_ch1_i_o                             => dsp1_mixi_ch1,
    mix_ch1_q_o                             => dsp1_mixq_ch1,
    mix_ch2_i_o                             => dsp1_mixi_ch2,
    mix_ch2_q_o                             => dsp1_mixq_ch2,
    mix_ch3_i_o                             => dsp1_mixi_ch3,
    mix_ch3_q_o                             => dsp1_mixq_ch3,
    mix_valid_o                             => dsp1_mix_valid,

    tbt_decim_ch0_i_o                       => dsp1_tbtdecimi_ch0,
    tbt_decim_ch0_q_o                       => dsp1_tbtdecimq_ch0,
    tbt_decim_ch1_i_o                       => dsp1_tbtdecimi_ch1,
    tbt_decim_ch1_q_o                       => dsp1_tbtdecimq_ch1,
    tbt_decim_ch2_i_o                       => dsp1_tbtdecimi_ch2,
    tbt_decim_ch2_q_o                       => dsp1_tbtdecimq_ch2,
    tbt_decim_ch3_i_o                       => dsp1_tbtdecimi_ch3,
    tbt_decim_ch3_q_o                       => dsp1_tbtdecimq_ch3,
    tbt_decim_valid_o                       => dsp1_tbtdecim_valid,

    tbt_amp_ch0_o                           => dsp1_tbt_amp_ch0,
    tbt_amp_ch1_o                           => dsp1_tbt_amp_ch1,
    tbt_amp_ch2_o                           => dsp1_tbt_amp_ch2,
    tbt_amp_ch3_o                           => dsp1_tbt_amp_ch3,
    tbt_amp_valid_o                         => dsp1_tbt_amp_valid,

    tbt_pha_ch0_o                           => dsp1_tbt_pha_ch0,
    tbt_pha_ch1_o                           => dsp1_tbt_pha_ch1,
    tbt_pha_ch2_o                           => dsp1_tbt_pha_ch2,
    tbt_pha_ch3_o                           => dsp1_tbt_pha_ch3,
    tbt_pha_valid_o                         => dsp1_tbt_pha_valid,

    fofb_decim_ch0_i_o                      => dsp1_fofbdecimi_ch0,
    fofb_decim_ch0_q_o                      => dsp1_fofbdecimq_ch0,
    fofb_decim_ch1_i_o                      => dsp1_fofbdecimi_ch1,
    fofb_decim_ch1_q_o                      => dsp1_fofbdecimq_ch1,
    fofb_decim_ch2_i_o                      => dsp1_fofbdecimi_ch2,
    fofb_decim_ch2_q_o                      => dsp1_fofbdecimq_ch2,
    fofb_decim_ch3_i_o                      => dsp1_fofbdecimi_ch3,
    fofb_decim_ch3_q_o                      => dsp1_fofbdecimq_ch3,
    fofb_decim_valid_o                      => dsp1_fofbdecim_valid,

    fofb_amp_ch0_o                          => dsp1_fofb_amp_ch0,
    fofb_amp_ch1_o                          => dsp1_fofb_amp_ch1,
    fofb_amp_ch2_o                          => dsp1_fofb_amp_ch2,
    fofb_amp_ch3_o                          => dsp1_fofb_amp_ch3,
    fofb_amp_valid_o                        => dsp1_fofb_amp_valid,

    fofb_pha_ch0_o                          => dsp1_fofb_pha_ch0,
    fofb_pha_ch1_o                          => dsp1_fofb_pha_ch1,
    fofb_pha_ch2_o                          => dsp1_fofb_pha_ch2,
    fofb_pha_ch3_o                          => dsp1_fofb_pha_ch3,
    fofb_pha_valid_o                        => dsp1_fofb_pha_valid,

    monit_amp_ch0_o                         => dsp1_monit_amp_ch0,
    monit_amp_ch1_o                         => dsp1_monit_amp_ch1,
    monit_amp_ch2_o                         => dsp1_monit_amp_ch2,
    monit_amp_ch3_o                         => dsp1_monit_amp_ch3,
    monit_amp_valid_o                       => dsp1_monit_amp_valid,

    tbt_pos_x_o                             => dsp1_tbt_pos_x,
    tbt_pos_y_o                             => dsp1_tbt_pos_y,
    tbt_pos_q_o                             => dsp1_tbt_pos_q,
    tbt_pos_sum_o                           => dsp1_tbt_pos_sum,
    tbt_pos_valid_o                         => dsp1_tbt_pos_valid,

    fofb_pos_x_o                            => dsp1_fofb_pos_x,
    fofb_pos_y_o                            => dsp1_fofb_pos_y,
    fofb_pos_q_o                            => dsp1_fofb_pos_q,
    fofb_pos_sum_o                          => dsp1_fofb_pos_sum,
    fofb_pos_valid_o                        => dsp1_fofb_pos_valid,

    monit_pos_x_o                           => dsp1_monit_pos_x,
    monit_pos_y_o                           => dsp1_monit_pos_y,
    monit_pos_q_o                           => dsp1_monit_pos_q,
    monit_pos_sum_o                         => dsp1_monit_pos_sum,
    monit_pos_valid_o                       => dsp1_monit_pos_valid,

    -----------------------------
    -- Output to RFFE board
    -----------------------------
    rffe_swclk_o                            => dsp1_clk_rffe_swap,

    -----------------------------
    -- Debug signals
    -----------------------------

    dbg_cur_address_o                       => dsp1_dbg_cur_address,
    dbg_adc_ch0_cond_o                      => dsp1_dbg_adc_ch0_cond,
    dbg_adc_ch1_cond_o                      => dsp1_dbg_adc_ch1_cond,
    dbg_adc_ch2_cond_o                      => dsp1_dbg_adc_ch2_cond,
    dbg_adc_ch3_cond_o                      => dsp1_dbg_adc_ch3_cond
  );

  -- Sign-extension to acquisition core
  dsp1_adc_se_ch0_data                       <= std_logic_vector(resize(signed(
                                                 dsp1_adc_ch0_data),
                                                 dsp1_adc_se_ch0_data'length));
  dsp1_adc_se_ch1_data                       <= std_logic_vector(resize(signed(
                                                 dsp1_adc_ch1_data),
                                                 dsp1_adc_se_ch1_data'length));
  dsp1_adc_se_ch2_data                       <= std_logic_vector(resize(signed(
                                                 dsp1_adc_ch2_data),
                                                 dsp1_adc_se_ch2_data'length));
  dsp1_adc_se_ch3_data                       <= std_logic_vector(resize(signed(
                                                 dsp1_adc_ch3_data),
                                                 dsp1_adc_se_ch3_data'length));

  ----------------------------------------------------------------------
  --                      DSP Chain 2 Core                            --
  ----------------------------------------------------------------------

  cmp2_xwb_position_calc_core : xwb_position_calc_core
  generic map (
    g_interface_mode                        => PIPELINED,
    g_address_granularity                   => BYTE,
    g_with_extra_wb_reg                     => true,

    -- selection of position_calc stages
    g_with_downconv                         => c_pos_calc_with_downconv,

    -- input sizes
    g_input_width                           => c_num_unprocessed_bits,
    g_mixed_width                           => c_pos_calc_mixed_width,
    g_adc_ratio                             => c_pos_calc_adc_ratio,

    -- mixer
    g_dds_width                             => c_pos_calc_dds_width,
    g_dds_points                            => c_pos_calc_dds_points,
    g_sin_file                              => c_pos_calc_sin_file,
    g_cos_file                              => c_pos_calc_cos_file,

    -- CIC setup
    g_tbt_cic_delay                         => c_pos_calc_tbt_cic_delay,
    g_tbt_cic_stages                        => c_pos_calc_tbt_cic_stages,
    g_tbt_ratio                             => c_pos_calc_tbt_ratio,
    g_tbt_decim_width                       => c_pos_calc_tbt_decim_width,

    g_fofb_cic_delay                        => c_pos_calc_fofb_cic_delay,
    g_fofb_cic_stages                       => c_pos_calc_fofb_cic_stages,
    g_fofb_ratio                            => c_pos_calc_fofb_ratio,
    g_fofb_decim_width                      => c_pos_calc_fofb_decim_width,

    g_monit1_cic_delay                      => c_pos_calc_monit1_cic_delay,
    g_monit1_cic_stages                     => c_pos_calc_monit1_cic_stages,
    g_monit1_ratio                          => c_pos_calc_monit1_ratio,
    g_monit1_cic_ratio                      => c_pos_calc_monit1_cic_ratio,

    g_monit2_cic_delay                      => c_pos_calc_monit2_cic_delay,
    g_monit2_cic_stages                     => c_pos_calc_monit2_cic_stages,
    g_monit2_ratio                          => c_pos_calc_monit2_ratio,
    g_monit2_cic_ratio                      => c_pos_calc_monit2_cic_ratio,

    g_monit_decim_width                     => c_pos_calc_monit_decim_width,

    -- Cordic setup
    g_tbt_cordic_stages                     => c_pos_calc_tbt_cordic_stages,
    g_tbt_cordic_iter_per_clk               => c_pos_calc_tbt_cordic_iter_per_clk,
    g_tbt_cordic_ratio                      => c_pos_calc_tbt_cordic_ratio,

    g_fofb_cordic_stages                    => c_pos_calc_fofb_cordic_stages,
    g_fofb_cordic_iter_per_clk              => c_pos_calc_fofb_cordic_iter_per_clk,
    g_fofb_cordic_ratio                     => c_pos_calc_fofb_cordic_ratio,

    -- width of K constants
    g_k_width                               => c_pos_calc_k_width,

    --width for IQ output
    g_IQ_width                              => c_pos_calc_IQ_width,

    -- Swap/de-swap setup
    g_delay_vec_width                       => c_pos_calc_delay_vec_width,
    g_swap_div_freq_vec_width               => c_pos_calc_swap_div_freq_vec_width
  )
  port map (
    rst_n_i                                 => clk_sys_rstn,
    clk_i                                   => clk_sys,  -- Wishbone clock
    fs_rst_n_i                              => fs2_rstn,
    fs_rst2x_n_i                            => fs2_rst2xn,
    fs_clk_i                                => fs2_clk,
    fs_clk2x_i                              => fs2_clk2x,

    -----------------------------
    -- Wishbone signals
    -----------------------------
    wb_slv_i                                => cbar_master_o(c_slv_pos_calc_2_id),
    wb_slv_o                                => cbar_master_i(c_slv_pos_calc_2_id),

    -----------------------------
    -- Raw ADC signals
    -----------------------------
    adc_ch0_i                               => fmc2_adc_data_ch0,
    adc_ch1_i                               => fmc2_adc_data_ch1,
    adc_ch2_i                               => fmc2_adc_data_ch2,
    adc_ch3_i                               => fmc2_adc_data_ch3,
    adc_valid_i                             => fmc2_adc_valid,

    -----------------------------
    -- Position calculation at various rates
    -----------------------------
    adc_ch0_swap_o                          => dsp2_adc_ch0_data,
    adc_ch1_swap_o                          => dsp2_adc_ch1_data,
    adc_ch2_swap_o                          => dsp2_adc_ch2_data,
    adc_ch3_swap_o                          => dsp2_adc_ch3_data,
    adc_swap_valid_o                        => dsp2_adc_valid,

    mix_ch0_i_o                             => dsp2_mixi_ch0,
    mix_ch0_q_o                             => dsp2_mixq_ch0,
    mix_ch1_i_o                             => dsp2_mixi_ch1,
    mix_ch1_q_o                             => dsp2_mixq_ch1,
    mix_ch2_i_o                             => dsp2_mixi_ch2,
    mix_ch2_q_o                             => dsp2_mixq_ch2,
    mix_ch3_i_o                             => dsp2_mixi_ch3,
    mix_ch3_q_o                             => dsp2_mixq_ch3,
    mix_valid_o                             => dsp2_mix_valid,

    tbt_decim_ch0_i_o                       => dsp2_tbtdecimi_ch0,
    tbt_decim_ch0_q_o                       => dsp2_tbtdecimq_ch0,
    tbt_decim_ch1_i_o                       => dsp2_tbtdecimi_ch1,
    tbt_decim_ch1_q_o                       => dsp2_tbtdecimq_ch1,
    tbt_decim_ch2_i_o                       => dsp2_tbtdecimi_ch2,
    tbt_decim_ch2_q_o                       => dsp2_tbtdecimq_ch2,
    tbt_decim_ch3_i_o                       => dsp2_tbtdecimi_ch3,
    tbt_decim_ch3_q_o                       => dsp2_tbtdecimq_ch3,
    tbt_decim_valid_o                       => dsp2_tbtdecim_valid,

    tbt_amp_ch0_o                           => dsp2_tbt_amp_ch0,
    tbt_amp_ch1_o                           => dsp2_tbt_amp_ch1,
    tbt_amp_ch2_o                           => dsp2_tbt_amp_ch2,
    tbt_amp_ch3_o                           => dsp2_tbt_amp_ch3,
    tbt_amp_valid_o                         => dsp2_tbt_amp_valid,

    tbt_pha_ch0_o                           => dsp2_tbt_pha_ch0,
    tbt_pha_ch1_o                           => dsp2_tbt_pha_ch1,
    tbt_pha_ch2_o                           => dsp2_tbt_pha_ch2,
    tbt_pha_ch3_o                           => dsp2_tbt_pha_ch3,
    tbt_pha_valid_o                         => dsp2_tbt_pha_valid,

    fofb_decim_ch0_i_o                      => dsp2_fofbdecimi_ch0,
    fofb_decim_ch0_q_o                      => dsp2_fofbdecimq_ch0,
    fofb_decim_ch1_i_o                      => dsp2_fofbdecimi_ch1,
    fofb_decim_ch1_q_o                      => dsp2_fofbdecimq_ch1,
    fofb_decim_ch2_i_o                      => dsp2_fofbdecimi_ch2,
    fofb_decim_ch2_q_o                      => dsp2_fofbdecimq_ch2,
    fofb_decim_ch3_i_o                      => dsp2_fofbdecimi_ch3,
    fofb_decim_ch3_q_o                      => dsp2_fofbdecimq_ch3,
    fofb_decim_valid_o                      => dsp2_fofbdecim_valid,

    fofb_amp_ch0_o                          => dsp2_fofb_amp_ch0,
    fofb_amp_ch1_o                          => dsp2_fofb_amp_ch1,
    fofb_amp_ch2_o                          => dsp2_fofb_amp_ch2,
    fofb_amp_ch3_o                          => dsp2_fofb_amp_ch3,
    fofb_amp_valid_o                        => dsp2_fofb_amp_valid,

    fofb_pha_ch0_o                          => dsp2_fofb_pha_ch0,
    fofb_pha_ch1_o                          => dsp2_fofb_pha_ch1,
    fofb_pha_ch2_o                          => dsp2_fofb_pha_ch2,
    fofb_pha_ch3_o                          => dsp2_fofb_pha_ch3,
    fofb_pha_valid_o                        => dsp2_fofb_pha_valid,

    monit_amp_ch0_o                         => dsp2_monit_amp_ch0,
    monit_amp_ch1_o                         => dsp2_monit_amp_ch1,
    monit_amp_ch2_o                         => dsp2_monit_amp_ch2,
    monit_amp_ch3_o                         => dsp2_monit_amp_ch3,
    monit_amp_valid_o                       => dsp2_monit_amp_valid,

    tbt_pos_x_o                             => dsp2_tbt_pos_x,
    tbt_pos_y_o                             => dsp2_tbt_pos_y,
    tbt_pos_q_o                             => dsp2_tbt_pos_q,
    tbt_pos_sum_o                           => dsp2_tbt_pos_sum,
    tbt_pos_valid_o                         => dsp2_tbt_pos_valid,

    fofb_pos_x_o                            => dsp2_fofb_pos_x,
    fofb_pos_y_o                            => dsp2_fofb_pos_y,
    fofb_pos_q_o                            => dsp2_fofb_pos_q,
    fofb_pos_sum_o                          => dsp2_fofb_pos_sum,
    fofb_pos_valid_o                        => dsp2_fofb_pos_valid,

    monit_pos_x_o                           => dsp2_monit_pos_x,
    monit_pos_y_o                           => dsp2_monit_pos_y,
    monit_pos_q_o                           => dsp2_monit_pos_q,
    monit_pos_sum_o                         => dsp2_monit_pos_sum,
    monit_pos_valid_o                       => dsp2_monit_pos_valid,

    -----------------------------
    -- Output to RFFE board
    -----------------------------
    rffe_swclk_o                            => dsp2_clk_rffe_swap,

    -----------------------------
    -- Debug signals
    -----------------------------

    dbg_cur_address_o                       => dsp2_dbg_cur_address,
    dbg_adc_ch0_cond_o                      => dsp2_dbg_adc_ch0_cond,
    dbg_adc_ch1_cond_o                      => dsp2_dbg_adc_ch1_cond,
    dbg_adc_ch2_cond_o                      => dsp2_dbg_adc_ch2_cond,
    dbg_adc_ch3_cond_o                      => dsp2_dbg_adc_ch3_cond
  );

  -- Sign-extension to acquisition core
  dsp2_adc_se_ch0_data                       <= std_logic_vector(resize(signed(
                                                 dsp2_adc_ch0_data),
                                                 dsp2_adc_se_ch0_data'length));
  dsp2_adc_se_ch1_data                       <= std_logic_vector(resize(signed(
                                                 dsp2_adc_ch1_data),
                                                 dsp2_adc_se_ch1_data'length));
  dsp2_adc_se_ch2_data                       <= std_logic_vector(resize(signed(
                                                 dsp2_adc_ch2_data),
                                                 dsp2_adc_se_ch2_data'length));
  dsp2_adc_se_ch3_data                       <= std_logic_vector(resize(signed(
                                                 dsp2_adc_ch3_data),
                                                 dsp2_adc_se_ch3_data'length));

  ----------------------------------------------------------------------
  --                      Peripherals Core                            --
  ----------------------------------------------------------------------

  cmp_xwb_dbe_periph : xwb_dbe_periph
  generic map(
    -- NOT used!
    --g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    -- NOT used!
    --g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_cntr_period                             => c_tics_cntr_period,
    g_num_leds                                => c_leds_num_pins,
    g_with_led_heartbeat                      => c_with_leds_heartbeat,
    g_num_buttons                             => c_buttons_num_pins
  )
  port map(
    clk_sys_i                                 => clk_sys,
    rst_n_i                                   => clk_sys_rstn,

    -- UART
    --uart_rxd_i                                => uart_rxd_i,
    --uart_txd_o                                => uart_txd_o,
    uart_rxd_i                                => '1',
    uart_txd_o                                => open,

    -- LEDs
    led_out_o                                 => gpio_leds_out_int,
    led_in_i                                  => gpio_leds_in_int,
    led_oen_o                                 => open,

    -- Buttons
    button_out_o                              => open,
    --button_in_i                               => buttons_i,
    button_in_i                               => buttons_dummy,
    button_oen_o                              => open,

    -- Wishbone
    slave_i                                   => cbar_master_o(c_slv_periph_id),
    slave_o                                   => cbar_master_i(c_slv_periph_id)
  );

  -- LED Red, LED Green, LED Blue
  leds_o <= gpio_leds_out_int;

  ----------------------------------------------------------------------
  --                      AFC Diagnostics                             --
  ----------------------------------------------------------------------

  cmp_xwb_afc_diag : xwb_afc_diag
  generic map(
    g_interface_mode                          => PIPELINED,
    g_address_granularity                     => BYTE
  )
  port map(
    sys_clk_i                                 => clk_sys,
    sys_rst_n_i                               => clk_sys_rstn,

    -- Fast SPI clock. Same as Wishbone clock.
    spi_clk_i                                 => clk_sys,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                  => cbar_master_o(c_slv_afc_diag_id),
    wb_slv_o                                  => cbar_master_i(c_slv_afc_diag_id),

    dbg_spi_clk_o                             => dbg_spi_clk,
    dbg_spi_valid_o                           => dbg_spi_valid,
    dbg_en_o                                  => dbg_en,
    dbg_addr_o                                => dbg_addr,
    dbg_serial_data_o                         => dbg_serial_data,
    dbg_spi_data_o                            => dbg_spi_data,

    -----------------------------
    -- SPI interface
    -----------------------------

    spi_cs                                    => diag_spi_cs_i,
    spi_si                                    => diag_spi_si_i,
    spi_so                                    => diag_spi_so_o,
    spi_clk                                   => diag_spi_clk_i
  );

  ----------------------------------------------------------------------
  --                      Acquisition Core                            --
  ----------------------------------------------------------------------

  --------------------
  -- ADC 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_adc_id).val           <= fmc1_adc_data_se_ch3 &
                                                                 fmc1_adc_data_se_ch2 &
                                                                 fmc1_adc_data_se_ch1 &
                                                                 fmc1_adc_data_se_ch0;
  acq_chan_array(c_acq_core_0_id, c_acq_adc_id).dvalid        <= fmc1_adc_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_adc_id).trig          <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_adc_id).pulse;

  --------------------
  -- ADC SWAP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_adc_swap_id).val      <= dsp1_adc_se_ch3_data &
                                                                 dsp1_adc_se_ch2_data &
                                                                 dsp1_adc_se_ch1_data &
                                                                 dsp1_adc_se_ch0_data;
  acq_chan_array(c_acq_core_0_id, c_acq_adc_swap_id).dvalid   <= dsp1_adc_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_adc_swap_id).trig     <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_adc_swap_id).pulse;

  --------------------
  -- MIXER I/Q 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_mixiq_id).val         <= dsp1_mixq_ch3 &
                                                                 dsp1_mixi_ch3 &
                                                                 dsp1_mixq_ch2 &
                                                                 dsp1_mixi_ch2 &
                                                                 dsp1_mixq_ch1 &
                                                                 dsp1_mixi_ch1 &
                                                                 dsp1_mixq_ch0 &
                                                                 dsp1_mixi_ch0;
  acq_chan_array(c_acq_core_0_id, c_acq_mixiq_id).dvalid      <= dsp1_mix_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_mixiq_id).trig        <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_mixiq_id).pulse;

  --------------------
  -- DUMMY 0 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_0_id, c_dummy0_id).val            <= (others => '0');
  acq_chan_array(c_acq_core_0_id, c_dummy0_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_0_id, c_dummy0_id).trig           <= trig_pulse_rcv(c_trig_mux_0_id, c_dummy0_id).pulse;

  --------------------
  -- TBT I/Q 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_tbtdecimiq_id).val    <= std_logic_vector(resize(signed(dsp1_tbtdecimq_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch0), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_tbtdecimiq_id).dvalid <= dsp1_tbtdecim_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_tbtdecimiq_id).trig   <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_tbtdecimiq_id).pulse;

  --------------------
  -- DUMMY 1 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_0_id, c_dummy1_id).val            <= (others => '0');
  acq_chan_array(c_acq_core_0_id, c_dummy1_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_0_id, c_dummy1_id).trig           <= trig_pulse_rcv(c_trig_mux_0_id, c_dummy1_id).pulse;

  --------------------
  -- TBT AMP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_amp_id).val       <= std_logic_vector(resize(signed(dsp1_tbt_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_amp_id).dvalid    <= dsp1_tbt_amp_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_amp_id).trig      <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_tbt_amp_id).pulse;

  --------------------
  -- TBT PHASE 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_phase_id).val     <= std_logic_vector(resize(signed(dsp1_tbt_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_phase_id).dvalid  <= dsp1_tbt_pha_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_phase_id).trig    <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_tbt_phase_id).pulse;

  --------------------
  -- TBT POS 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_pos_id).val       <= std_logic_vector(resize(signed(dsp1_tbt_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_x), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_pos_id).dvalid    <= dsp1_tbt_pos_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_pos_id).trig      <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_tbt_pos_id).pulse;

  --------------------
  -- FOFB I/Q 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_fofbdecimiq_id).val    <= std_logic_vector(resize(signed(dsp1_fofbdecimq_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch0), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_fofbdecimiq_id).dvalid <= dsp1_fofbdecim_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_fofbdecimiq_id).trig   <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_fofbdecimiq_id).pulse;

  --------------------
  -- DUMMY 2 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_0_id, c_dummy2_id).val             <= (others => '0');
  acq_chan_array(c_acq_core_0_id, c_dummy2_id).dvalid          <= '0';
  acq_chan_array(c_acq_core_0_id, c_dummy2_id).trig            <= trig_pulse_rcv(c_trig_mux_0_id, c_dummy1_id).pulse;

  --------------------
  -- FOFB AMP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_amp_id).val      <= std_logic_vector(resize(signed(dsp1_fofb_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_amp_id).dvalid   <= dsp1_fofb_amp_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_amp_id).trig     <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_fofb_amp_id).pulse;

  --------------------
  -- FOFB PHASE 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_phase_id).val    <= std_logic_vector(resize(signed(dsp1_fofb_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_phase_id).dvalid <= dsp1_fofb_pha_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_phase_id).trig   <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_fofb_phase_id).pulse;

  --------------------
  -- FOFB POS 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_pos_id).val      <= std_logic_vector(resize(signed(dsp1_fofb_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_x), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_pos_id).dvalid   <= dsp1_fofb_pos_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_pos_id).trig     <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_fofb_pos_id).pulse;

  --------------------
  -- MONIT AMP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_monit_amp_id).val     <= std_logic_vector(resize(signed(dsp1_monit_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_monit_amp_id).dvalid  <= dsp1_monit_amp_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_monit_amp_id).trig    <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_monit_amp_id).pulse;

  --------------------
  -- MONIT POS 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_monit_pos_id).val     <= std_logic_vector(resize(signed(dsp1_monit_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_x), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_monit_pos_id).dvalid  <= dsp1_monit_pos_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_monit_pos_id).trig    <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_monit_pos_id).pulse;

  --------------------
  -- MONIT1 POS 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_monit_1_pos_id).val    <= (others => '0');
  acq_chan_array(c_acq_core_0_id, c_acq_monit_1_pos_id).dvalid <= '0';
  acq_chan_array(c_acq_core_0_id, c_acq_monit_1_pos_id).trig   <= trig_pulse_rcv(c_trig_mux_0_id, c_acq_monit_1_pos_id).pulse;

  --------------------
  -- ADC 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_adc_id).val           <= fmc2_adc_data_se_ch3 &
                                                                 fmc2_adc_data_se_ch2 &
                                                                 fmc2_adc_data_se_ch1 &
                                                                 fmc2_adc_data_se_ch0;
  acq_chan_array(c_acq_core_1_id, c_acq_adc_id).dvalid        <= fmc2_adc_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_adc_id).trig          <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_adc_id).pulse;

  --------------------
  -- ADC SWAP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_adc_swap_id).val      <= dsp2_adc_se_ch3_data &
                                                                 dsp2_adc_se_ch2_data &
                                                                 dsp2_adc_se_ch1_data &
                                                                 dsp2_adc_se_ch0_data;
  acq_chan_array(c_acq_core_1_id, c_acq_adc_swap_id).dvalid   <= dsp2_adc_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_adc_swap_id).trig     <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_adc_swap_id).pulse;

  --------------------
  -- MIXER I/Q 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_mixiq_id).val         <= dsp2_mixq_ch3 &
                                                                 dsp2_mixi_ch3 &
                                                                 dsp2_mixq_ch2 &
                                                                 dsp2_mixi_ch2 &
                                                                 dsp2_mixq_ch1 &
                                                                 dsp2_mixi_ch1 &
                                                                 dsp2_mixq_ch0 &
                                                                 dsp2_mixi_ch0;
  acq_chan_array(c_acq_core_1_id, c_acq_mixiq_id).dvalid      <= dsp2_mix_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_mixiq_id).trig        <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_mixiq_id).pulse;

  --------------------
  -- DUMMY 0 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_1_id, c_dummy0_id).val            <= (others => '0');
  acq_chan_array(c_acq_core_1_id, c_dummy0_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_1_id, c_dummy0_id).trig           <= trig_pulse_rcv(c_trig_mux_1_id, c_dummy0_id).pulse;

  --------------------
  -- TBT I/Q 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_tbtdecimiq_id).val    <= std_logic_vector(resize(signed(dsp2_tbtdecimq_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch0), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_tbtdecimiq_id).dvalid <= dsp2_tbtdecim_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_tbtdecimiq_id).trig   <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_tbtdecimiq_id).pulse;

  --------------------
  -- DUMMY 1 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_1_id, c_dummy1_id).val            <= (others => '0');
  acq_chan_array(c_acq_core_1_id, c_dummy1_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_1_id, c_dummy1_id).trig           <= trig_pulse_rcv(c_trig_mux_1_id, c_dummy1_id).pulse;

  --------------------
  -- TBT AMP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_amp_id).val       <= std_logic_vector(resize(signed(dsp2_tbt_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_amp_id).dvalid    <= dsp2_tbt_amp_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_amp_id).trig      <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_tbt_amp_id).pulse;

  --------------------
  -- TBT PHASE 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_phase_id).val     <= std_logic_vector(resize(signed(dsp2_tbt_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_phase_id).dvalid  <= dsp2_tbt_pha_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_phase_id).trig    <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_tbt_phase_id).pulse;

  --------------------
  -- TBT POS 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_pos_id).val       <= std_logic_vector(resize(signed(dsp2_tbt_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_x), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_pos_id).dvalid    <= dsp2_tbt_pos_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_pos_id).trig      <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_tbt_pos_id).pulse;

  --------------------
  -- FOFB I/Q 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_fofbdecimiq_id).val    <= std_logic_vector(resize(signed(dsp2_fofbdecimq_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch0), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_fofbdecimiq_id).dvalid <= dsp2_fofbdecim_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_fofbdecimiq_id).trig   <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_fofbdecimiq_id).pulse;

  --------------------
  -- DUMMY 2 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_1_id, c_dummy2_id).val             <= (others => '0');
  acq_chan_array(c_acq_core_1_id, c_dummy2_id).dvalid          <= '0';
  acq_chan_array(c_acq_core_1_id, c_dummy2_id).trig            <= trig_pulse_rcv(c_trig_mux_1_id, c_dummy1_id).pulse;

  --------------------
  -- FOFB AMP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_amp_id).val      <= std_logic_vector(resize(signed(dsp2_fofb_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_amp_id).dvalid   <= dsp2_fofb_amp_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_amp_id).trig     <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_fofb_amp_id).pulse;

  --------------------
  -- FOFB PHASE 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_phase_id).val    <= std_logic_vector(resize(signed(dsp2_fofb_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_phase_id).dvalid <= dsp2_fofb_pha_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_phase_id).trig   <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_fofb_phase_id).pulse;

  --------------------
  -- FOFB POS 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_pos_id).val      <= std_logic_vector(resize(signed(dsp2_fofb_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_x), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_pos_id).dvalid   <= dsp2_fofb_pos_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_pos_id).trig     <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_fofb_pos_id).pulse;

  --------------------
  -- MONIT AMP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_monit_amp_id).val     <= std_logic_vector(resize(signed(dsp2_monit_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_monit_amp_id).dvalid  <= dsp2_monit_amp_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_monit_amp_id).trig    <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_monit_amp_id).pulse;

  --------------------
  -- MONIT POS 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_monit_pos_id).val     <= std_logic_vector(resize(signed(dsp2_monit_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_x), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_monit_pos_id).dvalid  <= dsp2_monit_pos_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_monit_pos_id).trig    <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_monit_pos_id).pulse;

  --------------------
  -- MONIT1 POS 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_monit_1_pos_id).val    <= (others => '0');
  acq_chan_array(c_acq_core_1_id, c_acq_monit_1_pos_id).dvalid <= '0';
  acq_chan_array(c_acq_core_1_id, c_acq_monit_1_pos_id).trig   <= trig_pulse_rcv(c_trig_mux_1_id, c_acq_monit_1_pos_id).pulse;

  --------------------
  -- ADC 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_adc_id).val           <= fmc1_adc_data_se_ch3 &
                                                                 fmc1_adc_data_se_ch2 &
                                                                 fmc1_adc_data_se_ch1 &
                                                                 fmc1_adc_data_se_ch0;
  acq_chan_array(c_acq_core_2_id, c_acq_adc_id).dvalid        <= fmc1_adc_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_adc_id).trig          <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_adc_id).pulse;

  --------------------
  -- ADC SWAP 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_adc_swap_id).val      <= dsp1_adc_se_ch3_data &
                                                                 dsp1_adc_se_ch2_data &
                                                                 dsp1_adc_se_ch1_data &
                                                                 dsp1_adc_se_ch0_data;
  acq_chan_array(c_acq_core_2_id, c_acq_adc_swap_id).dvalid   <= dsp1_adc_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_adc_swap_id).trig     <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_adc_swap_id).pulse;

  --------------------
  -- MIXER I/Q 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_mixiq_id).val         <= dsp1_mixq_ch3 &
                                                                 dsp1_mixi_ch3 &
                                                                 dsp1_mixq_ch2 &
                                                                 dsp1_mixi_ch2 &
                                                                 dsp1_mixq_ch1 &
                                                                 dsp1_mixi_ch1 &
                                                                 dsp1_mixq_ch0 &
                                                                 dsp1_mixi_ch0;
  acq_chan_array(c_acq_core_2_id, c_acq_mixiq_id).dvalid      <= dsp1_mix_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_mixiq_id).trig        <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_mixiq_id).pulse;

  --------------------
  -- DUMMY 0 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_2_id, c_dummy0_id).val            <= (others => '0');
  acq_chan_array(c_acq_core_2_id, c_dummy0_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_2_id, c_dummy0_id).trig           <= trig_pulse_rcv(c_trig_mux_2_id, c_dummy0_id).pulse;

  --------------------
  -- TBT I/Q 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_tbtdecimiq_id).val    <= std_logic_vector(resize(signed(dsp1_tbtdecimq_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch0), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_tbtdecimiq_id).dvalid <= dsp1_tbtdecim_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_tbtdecimiq_id).trig   <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_tbtdecimiq_id).pulse;

  --------------------
  -- DUMMY 1 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_2_id, c_dummy1_id).val            <= (others => '0');
  acq_chan_array(c_acq_core_2_id, c_dummy1_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_2_id, c_dummy1_id).trig           <= trig_pulse_rcv(c_trig_mux_2_id, c_dummy1_id).pulse;

  --------------------
  -- TBT AMP 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_amp_id).val       <= std_logic_vector(resize(signed(dsp1_tbt_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_amp_id).dvalid    <= dsp1_tbt_amp_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_amp_id).trig      <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_tbt_amp_id).pulse;

  --------------------
  -- TBT PHASE 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_phase_id).val     <= std_logic_vector(resize(signed(dsp1_tbt_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_phase_id).dvalid  <= dsp1_tbt_pha_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_phase_id).trig    <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_tbt_phase_id).pulse;

  --------------------
  -- TBT POS 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_pos_id).val       <= std_logic_vector(resize(signed(dsp1_tbt_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_x), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_pos_id).dvalid    <= dsp1_tbt_pos_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_pos_id).trig      <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_tbt_pos_id).pulse;

  --------------------
  -- FOFB I/Q 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_fofbdecimiq_id).val    <= std_logic_vector(resize(signed(dsp1_fofbdecimq_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch0), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_fofbdecimiq_id).dvalid <= dsp1_fofbdecim_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_fofbdecimiq_id).trig   <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_fofbdecimiq_id).pulse;

  --------------------
  -- DUMMY 2 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_2_id, c_dummy2_id).val             <= (others => '0');
  acq_chan_array(c_acq_core_2_id, c_dummy2_id).dvalid          <= '0';
  acq_chan_array(c_acq_core_2_id, c_dummy2_id).trig            <= trig_pulse_rcv(c_trig_mux_2_id, c_dummy1_id).pulse;

  --------------------
  -- FOFB AMP 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_amp_id).val      <= std_logic_vector(resize(signed(dsp1_fofb_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_amp_id).dvalid   <= dsp1_fofb_amp_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_amp_id).trig     <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_fofb_amp_id).pulse;

  --------------------
  -- FOFB PHASE 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_phase_id).val    <= std_logic_vector(resize(signed(dsp1_fofb_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_phase_id).dvalid <= dsp1_fofb_pha_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_phase_id).trig   <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_fofb_phase_id).pulse;

  --------------------
  -- FOFB POS 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_pos_id).val      <= std_logic_vector(resize(signed(dsp1_fofb_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_x), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_pos_id).dvalid   <= dsp1_fofb_pos_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_pos_id).trig     <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_fofb_pos_id).pulse;

  --------------------
  -- MONIT AMP 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_monit_amp_id).val     <= std_logic_vector(resize(signed(dsp1_monit_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_monit_amp_id).dvalid  <= dsp1_monit_amp_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_monit_amp_id).trig    <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_monit_amp_id).pulse;

  --------------------
  -- MONIT POS 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_monit_pos_id).val     <= std_logic_vector(resize(signed(dsp1_monit_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_x), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_monit_pos_id).dvalid  <= dsp1_monit_pos_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_monit_pos_id).trig    <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_monit_pos_id).pulse;

  --------------------
  -- MONIT1 POS 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_monit_1_pos_id).val    <= (others => '0');
  acq_chan_array(c_acq_core_2_id, c_acq_monit_1_pos_id).dvalid <= '0';
  acq_chan_array(c_acq_core_2_id, c_acq_monit_1_pos_id).trig   <= trig_pulse_rcv(c_trig_mux_2_id, c_acq_monit_1_pos_id).pulse;

  --------------------
  -- ADC 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_adc_id).val           <= fmc2_adc_data_se_ch3 &
                                                                 fmc2_adc_data_se_ch2 &
                                                                 fmc2_adc_data_se_ch1 &
                                                                 fmc2_adc_data_se_ch0;
  acq_chan_array(c_acq_core_3_id, c_acq_adc_id).dvalid        <= fmc2_adc_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_adc_id).trig          <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_adc_id).pulse;

  --------------------
  -- ADC SWAP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_adc_swap_id).val      <= dsp2_adc_se_ch3_data &
                                                                 dsp2_adc_se_ch2_data &
                                                                 dsp2_adc_se_ch1_data &
                                                                 dsp2_adc_se_ch0_data;
  acq_chan_array(c_acq_core_3_id, c_acq_adc_swap_id).dvalid   <= dsp2_adc_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_adc_swap_id).trig     <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_adc_swap_id).pulse;

  --------------------
  -- MIXER I/Q 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_mixiq_id).val         <= dsp2_mixq_ch3 &
                                                                 dsp2_mixi_ch3 &
                                                                 dsp2_mixq_ch2 &
                                                                 dsp2_mixi_ch2 &
                                                                 dsp2_mixq_ch1 &
                                                                 dsp2_mixi_ch1 &
                                                                 dsp2_mixq_ch0 &
                                                                 dsp2_mixi_ch0;
  acq_chan_array(c_acq_core_3_id, c_acq_mixiq_id).dvalid      <= dsp2_mix_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_mixiq_id).trig        <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_mixiq_id).pulse;

  --------------------
  -- DUMMY 0 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_3_id, c_dummy0_id).val            <= (others => '0');
  acq_chan_array(c_acq_core_3_id, c_dummy0_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_3_id, c_dummy0_id).trig           <= trig_pulse_rcv(c_trig_mux_3_id, c_dummy0_id).pulse;

  --------------------
  -- TBT I/Q 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_tbtdecimiq_id).val    <= std_logic_vector(resize(signed(dsp2_tbtdecimq_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch0), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_tbtdecimiq_id).dvalid <= dsp2_tbtdecim_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_tbtdecimiq_id).trig   <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_tbtdecimiq_id).pulse;

  --------------------
  -- DUMMY 1 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_3_id, c_dummy1_id).val            <= (others => '0');
  acq_chan_array(c_acq_core_3_id, c_dummy1_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_3_id, c_dummy1_id).trig           <= trig_pulse_rcv(c_trig_mux_3_id, c_dummy1_id).pulse;

  --------------------
  -- TBT AMP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_amp_id).val       <= std_logic_vector(resize(signed(dsp2_tbt_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_amp_id).dvalid    <= dsp2_tbt_amp_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_amp_id).trig      <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_tbt_amp_id).pulse;

  --------------------
  -- TBT PHASE 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_phase_id).val     <= std_logic_vector(resize(signed(dsp2_tbt_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_phase_id).dvalid  <= dsp2_tbt_pha_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_phase_id).trig    <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_tbt_phase_id).pulse;

  --------------------
  -- TBT POS 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_pos_id).val       <= std_logic_vector(resize(signed(dsp2_tbt_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_x), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_pos_id).dvalid    <= dsp2_tbt_pos_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_pos_id).trig      <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_tbt_pos_id).pulse;

  --------------------
  -- FOFB I/Q 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_fofbdecimiq_id).val    <= std_logic_vector(resize(signed(dsp2_fofbdecimq_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch0), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_fofbdecimiq_id).dvalid <= dsp2_fofbdecim_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_fofbdecimiq_id).trig   <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_fofbdecimiq_id).pulse;

  --------------------
  -- DUMMY 2 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_3_id, c_dummy2_id).val             <= (others => '0');
  acq_chan_array(c_acq_core_3_id, c_dummy2_id).dvalid          <= '0';
  acq_chan_array(c_acq_core_3_id, c_dummy2_id).trig            <= trig_pulse_rcv(c_trig_mux_3_id, c_dummy2_id).pulse;

  --------------------
  -- FOFB AMP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_amp_id).val      <= std_logic_vector(resize(signed(dsp2_fofb_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_amp_id).dvalid   <= dsp2_fofb_amp_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_amp_id).trig     <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_fofb_amp_id).pulse;

  --------------------
  -- FOFB PHASE 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_phase_id).val    <= std_logic_vector(resize(signed(dsp2_fofb_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_phase_id).dvalid <= dsp2_fofb_pha_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_phase_id).trig   <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_fofb_phase_id).pulse;

  --------------------
  -- FOFB POS 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_pos_id).val      <= std_logic_vector(resize(signed(dsp2_fofb_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_x), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_pos_id).dvalid   <= dsp2_fofb_pos_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_pos_id).trig     <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_fofb_pos_id).pulse;

  --------------------
  -- MONIT AMP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_monit_amp_id).val     <= std_logic_vector(resize(signed(dsp2_monit_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_monit_amp_id).dvalid  <= dsp2_monit_amp_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_monit_amp_id).trig    <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_monit_amp_id).pulse;

  --------------------
  -- MONIT POS 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_monit_pos_id).val     <= std_logic_vector(resize(signed(dsp2_monit_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_x), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_monit_pos_id).dvalid  <= dsp2_monit_pos_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_monit_pos_id).trig    <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_monit_pos_id).pulse;

  --------------------
  -- MONIT1 POS 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_monit_1_pos_id).val    <= (others => '0');
  acq_chan_array(c_acq_core_3_id, c_acq_monit_1_pos_id).dvalid <= '0';
  acq_chan_array(c_acq_core_3_id, c_acq_monit_1_pos_id).trig   <= trig_pulse_rcv(c_trig_mux_3_id, c_acq_monit_1_pos_id).pulse;

  cmp_xwb_facq_core_mux : xwb_facq_core_mux
  generic map
  (
    g_interface_mode                          => PIPELINED,
    g_address_granularity                     => BYTE,
    g_acq_addr_width                          => c_acq_addr_width,
    g_acq_num_channels                        => c_acq_num_channels,
    g_facq_channels                           => c_facq_channels,
    g_ddr_payload_width                       => c_ddr_payload_width,
    g_ddr_dq_width                            => c_ddr_dq_width,
    g_ddr_addr_width                          => c_ddr_addr_width,
    --g_multishot_ram_size                      => 2048,
    g_fifo_fc_size                            => c_acq_fifo_size,
    --g_sim_readback                            => false
    g_acq_num_cores                           => c_acq_num_cores,
    g_ddr_interface_type                      => c_ddr_interface_type,
    g_max_burst_size                          => c_ddr_datamover_bpm_burst_size
  )
  port map
  (
    fs_clk_array_i                            => fs_clk_array,
    fs_ce_array_i                             => fs_ce_array,
    fs_rst_n_array_i                          => fs_rst_n_array,

    -- Clock signals for Wishbone
    sys_clk_i                                 => clk_sys,
    sys_rst_n_i                               => clk_sys_rstn,

    -- From DDR3 Controller
    ext_clk_i                                 => ddr_aximm_clk,
    ext_rst_n_i                               => ddr_aximm_rstn,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                  => acq_core_slave_i,
    wb_slv_o                                  => acq_core_slave_o,

    -----------------------------
    -- External Interface
    -----------------------------
    acq_chan_array_i                           => acq_chan_array,

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_array_o                         => bpm_acq_dpram_dout_array, -- to chipscope
    dpram_valid_array_o                        => bpm_acq_dpram_valid_array, -- to chipscope

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_array_o                           => bpm_acq_ext_dout_array, -- to chipscope
    ext_valid_array_o                          => bpm_acq_ext_valid_array, -- to chipscope
    ext_addr_array_o                           => bpm_acq_ext_addr_array, -- to chipscope
    ext_sof_array_o                            => bpm_acq_ext_sof_array, -- to chipscope
    ext_eof_array_o                            => bpm_acq_ext_eof_array, -- to chipscope
    ext_dreq_array_o                           => bpm_acq_ext_dreq_array, -- to chipscope
    ext_stall_array_o                          => bpm_acq_ext_stall_array, -- to chipscope

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_array_i                => (others => '0'),
    dbg_ddr_rb_rdy_array_o                    => open,
    dbg_ddr_rb_data_array_o                   => open,
    dbg_ddr_rb_addr_array_o                   => open,
    dbg_ddr_rb_valid_array_o                  => open,

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    -- AXIMM Read Channel
    ddr_aximm_r_ma_i                          => ddr_aximm_r_ma_in,
    ddr_aximm_r_ma_o                          => ddr_aximm_r_ma_out,
    -- AXIMM Write Channel
    ddr_aximm_w_ma_i                          => ddr_aximm_w_ma_in,
    ddr_aximm_w_ma_o                          => ddr_aximm_w_ma_out
  );

  fs_clk_array   <= fs2_clk & fs1_clk & fs2_clk & fs1_clk;
  fs_ce_array    <= "1111";
  fs_rst_n_array <= fs2_rstn & fs1_rstn & fs2_rstn & fs1_rstn;

  -- c_slv_acq_core_*_id is Wishbone slave index
  -- c_acq_core_*_id is Acquisition core index
  acq_core_slave_i <= cbar_master_o(c_slv_acq_core_pm_1_id) &
                      cbar_master_o(c_slv_acq_core_pm_0_id) &
                      cbar_master_o(c_slv_acq_core_1_id) &
                      cbar_master_o(c_slv_acq_core_0_id);
  cbar_master_i(c_slv_acq_core_0_id) <= acq_core_slave_o(c_acq_core_0_id);
  cbar_master_i(c_slv_acq_core_1_id) <= acq_core_slave_o(c_acq_core_1_id);
  cbar_master_i(c_slv_acq_core_pm_0_id) <= acq_core_slave_o(c_acq_core_2_id);
  cbar_master_i(c_slv_acq_core_pm_1_id) <= acq_core_slave_o(c_acq_core_3_id);

  ----------------------------------------------------------------------
  --                          Trigger                                 --
  ----------------------------------------------------------------------
  trig_ref_clk <= clk_sys;
  trig_ref_rst_n <= clk_sys_rstn;

  cmp_xwb_trigger : xwb_trigger
    generic map (
      g_address_granularity                => BYTE,
      g_interface_mode                     => PIPELINED,
      g_sync_edge                          => c_trig_sync_edge,
      g_trig_num                           => c_trig_trig_num,
      g_intern_num                         => c_trig_intern_num,
      g_rcv_intern_num                     => c_trig_rcv_intern_num,
      g_num_mux_interfaces                 => c_trig_num_mux_interfaces,
      g_out_resolver                       => c_trig_out_resolver,
      g_in_resolver                        => c_trig_in_resolver,
      g_with_input_sync                    => c_trig_with_input_sync,
      g_with_output_sync                   => c_trig_with_output_sync
    )
    port map (
      clk_i                                => clk_sys,
      rst_n_i                              => clk_sys_rstn,

      ref_clk_i                            => trig_ref_clk,
      ref_rst_n_i                          => trig_ref_rst_n,

      fs_clk_array_i                       => fs_clk_array,
      fs_rst_n_array_i                     => fs_rst_n_array,

      wb_slv_trigger_iface_i               => cbar_master_o(c_slv_trig_iface_id),
      wb_slv_trigger_iface_o               => cbar_master_i(c_slv_trig_iface_id),

      wb_slv_trigger_mux_i                 => trig_core_slave_i,
      wb_slv_trigger_mux_o                 => trig_core_slave_o,

      trig_dir_o                           => trig_dir_int,
      trig_rcv_intern_i                    => trig_rcv_intern,
      trig_pulse_transm_i                  => trig_pulse_transm,
      trig_pulse_rcv_o                     => trig_pulse_rcv,
      trig_b                               => trig_b,
      trig_dbg_o                           => trig_dbg
  );

  trig_core_slave_i <= cbar_master_o(c_slv_trig_mux_pm_1_id) &
                       cbar_master_o(c_slv_trig_mux_pm_0_id) &
                       cbar_master_o(c_slv_trig_mux_1_id) &
                       cbar_master_o(c_slv_trig_mux_0_id);
  cbar_master_i(c_slv_trig_mux_0_id)    <= trig_core_slave_o(c_trig_mux_0_id);
  cbar_master_i(c_slv_trig_mux_1_id)    <= trig_core_slave_o(c_trig_mux_1_id);
  cbar_master_i(c_slv_trig_mux_pm_0_id) <= trig_core_slave_o(c_trig_mux_2_id);
  cbar_master_i(c_slv_trig_mux_pm_1_id) <= trig_core_slave_o(c_trig_mux_3_id);

  -- Assign FMCs trigger pulses to trigger channel interfaces
  trig_fmc1_channel_1.pulse <= fmc1_trig_hw;
  trig_fmc1_channel_2.pulse <= dsp1_clk_rffe_swap;

  trig_fmc2_channel_1.pulse <= fmc2_trig_hw;
  trig_fmc2_channel_2.pulse <= dsp2_clk_rffe_swap;

  -- Post-Mortem triggers (mainly for testing. The real trigger would come from the
  -- Backplane MLVDS triggers)
  trig_fmc1_pm_channel_1.pulse <= '0';
  trig_fmc1_pm_channel_2.pulse <= fmc1_trig_hw;

  trig_fmc2_pm_channel_1.pulse <= '0';
  trig_fmc2_pm_channel_2.pulse <= fmc2_trig_hw;

  -- Assign intern triggers to trigger module
  trig_rcv_intern(c_trig_mux_0_id, c_trig_rcv_intern_chan_1_id) <= trig_fmc1_channel_1;
  trig_rcv_intern(c_trig_mux_0_id, c_trig_rcv_intern_chan_2_id) <= trig_fmc1_channel_2;
  trig_rcv_intern(c_trig_mux_1_id, c_trig_rcv_intern_chan_1_id) <= trig_fmc2_channel_1;
  trig_rcv_intern(c_trig_mux_1_id, c_trig_rcv_intern_chan_2_id) <= trig_fmc2_channel_2;

  -- Post-Mortem triggers
  trig_rcv_intern(c_trig_mux_2_id, c_trig_rcv_intern_chan_1_id) <= trig_fmc1_pm_channel_1;
  trig_rcv_intern(c_trig_mux_2_id, c_trig_rcv_intern_chan_2_id) <= trig_fmc1_pm_channel_2;
  trig_rcv_intern(c_trig_mux_3_id, c_trig_rcv_intern_chan_1_id) <= trig_fmc2_pm_channel_1;
  trig_rcv_intern(c_trig_mux_3_id, c_trig_rcv_intern_chan_2_id) <= trig_fmc2_pm_channel_2;

  trig_dir_o <= trig_dir_int;

  ----------------------------------------------------------------------
  --                      Triggers Chipscope                          --
  ----------------------------------------------------------------------
  --cmp_chipscope_icon_0 : chipscope_icon_1_port
  --port map (
  --  CONTROL0                                => CONTROL0
  --);

  --cmp_chipscope_ila_0 : chipscope_ila
  --port map (
  --  CONTROL                                => CONTROL0,
  --  CLK                                    => fs_clk_array(0),
  --  TRIG0                                  => TRIG_ILA0_0,
  --  TRIG1                                  => TRIG_ILA0_1,
  --  TRIG2                                  => TRIG_ILA0_2,
  --  TRIG3                                  => TRIG_ILA0_3
  --);

  --TRIG_ILA0_0(31 downto 30)                 <= (others => '0');
  --TRIG_ILA0_0(29 downto 12)                 <= trig_pulse_transm(c_trig_mux_0_id, 0 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 1 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 2 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 3 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 4 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 5 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 6 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 7 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 8 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 9 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 10).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 11).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 12).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 13).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 14).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 15).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 16).pulse &
  --                                             trig_pulse_transm(c_trig_mux_0_id, 17).pulse;

  --TRIG_ILA0_0(11 downto 8)                  <= trig_rcv_intern(c_trig_mux_0_id, c_trig_rcv_intern_chan_1_id).pulse &
  --                                             trig_rcv_intern(c_trig_mux_0_id, c_trig_rcv_intern_chan_2_id).pulse &
  --                                             trig_rcv_intern(c_trig_mux_1_id, c_trig_rcv_intern_chan_1_id).pulse &
  --                                             trig_rcv_intern(c_trig_mux_1_id, c_trig_rcv_intern_chan_2_id).pulse;
  --TRIG_ILA0_0(7 downto 0)                   <= trig_dir_int;

  --TRIG_ILA0_1(31 downto 26)                 <= (others => '0');
  --TRIG_ILA0_1(25 downto 18)                 <= trig_dbg;
  --TRIG_ILA0_1(17 downto 0)                  <= trig_pulse_transm(c_trig_mux_1_id, 0 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 1 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 2 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 3 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 4 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 5 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 6 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 7 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 8 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 9 ).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 10).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 11).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 12).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 13).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 14).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 15).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 16).pulse &
  --                                             trig_pulse_transm(c_trig_mux_1_id, 17).pulse;
  --TRIG_ILA0_2 (31 downto 18)                <= (others => '0');
  --TRIG_ILA0_2 (17 downto 0)                 <= trig_pulse_rcv(c_trig_mux_0_id, 0 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 1 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 2 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 3 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 4 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 5 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 6 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 7 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 8 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 9 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 10).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 11).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 12).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 13).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 14).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 15).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 16).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_0_id, 17).pulse;
  --TRIG_ILA0_3 (31 downto 18)                <= (others => '0');
  --TRIG_ILA0_3 (17 downto 0)                 <= trig_pulse_rcv(c_trig_mux_1_id, 0 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 1 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 2 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 3 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 4 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 5 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 6 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 7 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 8 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 9 ).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 10).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 11).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 12).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 13).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 14).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 15).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 16).pulse &
  --                                             trig_pulse_rcv(c_trig_mux_1_id, 17).pulse;

  ----------------------------------------------------------------------
  --                      DSP Chipscope                               --
  ----------------------------------------------------------------------

  ---- Chipscope Analysis
  --cmp_chipscope_icon_13 : chipscope_icon_13_port
  --port map (
  --   CONTROL0                               => CONTROL0,
  --   CONTROL1                               => CONTROL1,
  --   CONTROL2                               => CONTROL2,
  --   CONTROL3                               => CONTROL3,
  --   CONTROL4                               => CONTROL4,
  --   CONTROL5                               => CONTROL5,
  --   CONTROL6                               => CONTROL6,
  --   CONTROL7                               => CONTROL7,
  --   CONTROL8                               => CONTROL8,
  --   CONTROL9                               => CONTROL9,
  --   CONTROL10                              => CONTROL10,
  --   CONTROL11                              => CONTROL11,
  --   CONTROL12                              => CONTROL12
  --);

  ----cmp_chipscope_ila_0_adc : chipscope_ila
  --cmp_chipscope_ila_adc : chipscope_ila_8192_5_port
  --port map (
  --  CONTROL                                => CONTROL0,
  --  CLK                                    => fs_clk,
  --  TRIG0                                  => TRIG_ILA0_0,
  --  TRIG1                                  => TRIG_ILA0_1,
  --  TRIG2                                  => TRIG_ILA0_2,
  --  TRIG3                                  => TRIG_ILA0_3,
  --  TRIG4                                  => TRIG_ILA0_4
  --);

  ---- ADC Data
  --TRIG_ILA0_0                               <= dsp_adc_ch1_data & dsp_adc_ch0_data;
  --TRIG_ILA0_1                               <= dsp_adc_ch3_data & dsp_adc_ch2_data;

  --TRIG_ILA0_2                               <= dbg_adc_ch1_cond & dbg_adc_ch0_cond;
  --TRIG_ILA0_3                               <= dbg_adc_ch3_cond & dbg_adc_ch2_cond;
  --TRIG_ILA0_4(dbg_cur_address'left downto 0)
  --	                                    <= dbg_cur_address;

  ---- Mix and BPF data
  --cmp_chipscope_ila_1024_bpf_mix : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL1,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA1_0,
  --  TRIG1                                   => TRIG_ILA1_1,
  --  TRIG2                                   => TRIG_ILA1_2,
  --  TRIG3                                   => TRIG_ILA1_3,
  --  TRIG4                                   => TRIG_ILA1_4
  --);

  --TRIG_ILA1_0(0)                            <= dsp_bpf_valid;
  --TRIG_ILA1_0(1)                            <= '0';
  --TRIG_ILA1_0(2)                            <= '0';
  --TRIG_ILA1_0(3)                            <= '0';
  --TRIG_ILA1_0(4)                            <= '0';
  --TRIG_ILA1_0(5)                            <= '0';
  --TRIG_ILA1_0(6)                            <= '0';

  --TRIG_ILA1_1(dsp_bpf_ch0'left downto 0)    <= dsp_bpf_ch0;
  --TRIG_ILA1_2(dsp_bpf_ch2'left downto 0)    <= dsp_bpf_ch2;
  --TRIG_ILA1_3(dsp_mix_ch0'left downto 0)    <= dsp_mix_ch0;
  --TRIG_ILA1_4(dsp_mix_ch2'left downto 0)    <= dsp_mix_ch2;

  ----TBT amplitudes data
  --cmp_chipscope_ila_1024_tbt_amp : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL2,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA2_0,
  --  TRIG1                                   => TRIG_ILA2_1,
  --  TRIG2                                   => TRIG_ILA2_2,
  --  TRIG3                                   => TRIG_ILA2_3,
  --  TRIG4                                   => TRIG_ILA2_4
  --);

  --TRIG_ILA2_0(0)                            <= dsp_tbt_amp_valid;
  --TRIG_ILA2_0(1)                            <= '0';
  --TRIG_ILA2_0(2)                            <= '0';
  --TRIG_ILA2_0(3)                            <= '0';
  --TRIG_ILA2_0(4)                            <= '0';
  --TRIG_ILA2_0(5)                            <= '0';
  --TRIG_ILA2_0(6)                            <= '0';

  --TRIG_ILA2_1(dsp_tbt_amp_ch0'left downto 0) <= dsp_tbt_amp_ch0;
  --TRIG_ILA2_2(dsp_tbt_amp_ch1'left downto 0) <= dsp_tbt_amp_ch1;
  --TRIG_ILA2_3(dsp_tbt_amp_ch2'left downto 0) <= dsp_tbt_amp_ch2;
  --TRIG_ILA2_4(dsp_tbt_amp_ch3'left downto 0) <= dsp_tbt_amp_ch3;

  ---- TBT position data
  --cmp_chipscope_ila_1024_tbt_pos : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL3,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA3_0,
  --  TRIG1                                   => TRIG_ILA3_1,
  --  TRIG2                                   => TRIG_ILA3_2,
  --  TRIG3                                   => TRIG_ILA3_3,
  --  TRIG4                                   => TRIG_ILA3_4
  --);

  --TRIG_ILA3_0(0)                            <= dsp_tbt_pos_valid;
  --TRIG_ILA3_0(1)                            <= '0';
  --TRIG_ILA3_0(2)                            <= '0';
  --TRIG_ILA3_0(3)                            <= '0';
  --TRIG_ILA3_0(4)                            <= '0';
  --TRIG_ILA3_0(5)                            <= '0';
  --TRIG_ILA3_0(6)                            <= '0';

  --TRIG_ILA3_1(dsp_tbt_pos_x'left downto 0)       <= dsp_tbt_pos_x;
  --TRIG_ILA3_2(dsp_tbt_pos_y'left downto 0)       <= dsp_tbt_pos_y;
  --TRIG_ILA3_3(dsp_tbt_pos_q'left downto 0)       <= dsp_tbt_pos_q;
  --TRIG_ILA3_4(dsp_tbt_pos_sum'left downto 0)     <= dsp_tbt_pos_sum;

  ---- FOFB amplitudes data

  --cmp_chipscope_ila_1024_fofb_amp : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL4,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA4_0,
  --  TRIG1                                   => TRIG_ILA4_1,
  --  TRIG2                                   => TRIG_ILA4_2,
  --  TRIG3                                   => TRIG_ILA4_3,
  --  TRIG4                                   => TRIG_ILA4_4
  --);

  --TRIG_ILA4_0(0)                            <= dsp_fofb_amp_valid;
  --TRIG_ILA4_0(1)                            <= '0';
  --TRIG_ILA4_0(2)                            <= '0';
  --TRIG_ILA4_0(3)                            <= '0';
  --TRIG_ILA4_0(4)                            <= '0';
  --TRIG_ILA4_0(5)                            <= '0';
  --TRIG_ILA4_0(6)                            <= '0';

  --TRIG_ILA4_1(dsp_fofb_amp_ch0'left downto 0)  <= dsp_fofb_amp_ch0;
  --TRIG_ILA4_2(dsp_fofb_amp_ch1'left downto 0)  <= dsp_fofb_amp_ch1;
  --TRIG_ILA4_3(dsp_fofb_amp_ch2'left downto 0)  <= dsp_fofb_amp_ch2;
  --TRIG_ILA4_4(dsp_fofb_amp_ch3'left downto 0)  <= dsp_fofb_amp_ch3;

  ---- FOFB position data
  --cmp_chipscope_ila_1024_fofb_pos : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL5,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA5_0,
  --  TRIG1                                   => TRIG_ILA5_1,
  --  TRIG2                                   => TRIG_ILA5_2,
  --  TRIG3                                   => TRIG_ILA5_3,
  --  TRIG4                                   => TRIG_ILA5_4
  --);

  --TRIG_ILA5_0(0)                            <= dsp_fofb_pos_valid;
  --TRIG_ILA5_0(1)                            <= '0';
  --TRIG_ILA5_0(2)                            <= '0';
  --TRIG_ILA5_0(3)                            <= '0';
  --TRIG_ILA5_0(4)                            <= '0';
  --TRIG_ILA5_0(5)                            <= '0';
  --TRIG_ILA5_0(6)                            <= '0';

  --TRIG_ILA5_1(dsp_fofb_pos_x'left downto 0)        <= dsp_fofb_pos_x;
  --TRIG_ILA5_2(dsp_fofb_pos_y'left downto 0)        <= dsp_fofb_pos_y;
  --TRIG_ILA5_3(dsp_fofb_pos_q'left downto 0)        <= dsp_fofb_pos_q;
  --TRIG_ILA5_4(dsp_fofb_pos_sum'left downto 0)      <= dsp_fofb_pos_sum;

  ---- Monitoring position amplitude
  --cmp_chipscope_ila_1024_monit_amp : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL6,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA6_0,
  --  TRIG1                                   => TRIG_ILA6_1,
  --  TRIG2                                   => TRIG_ILA6_2,
  --  TRIG3                                   => TRIG_ILA6_3,
  --  TRIG4                                   => TRIG_ILA6_4
  --);

  --TRIG_ILA6_0(0)                            <= dsp_monit_amp_valid;
  --TRIG_ILA6_0(1)                            <= '0';
  --TRIG_ILA6_0(2)                            <= '0';
  --TRIG_ILA6_0(3)                            <= '0';
  --TRIG_ILA6_0(4)                            <= '0';
  --TRIG_ILA6_0(5)                            <= '0';
  --TRIG_ILA6_0(6)                            <= '0';

  --TRIG_ILA6_1(dsp_monit_amp_ch0'left downto 0)  <= dsp_monit_amp_ch0;
  --TRIG_ILA6_2(dsp_monit_amp_ch1'left downto 0)  <= dsp_monit_amp_ch1;
  --TRIG_ILA6_3(dsp_monit_amp_ch2'left downto 0)  <= dsp_monit_amp_ch2;
  --TRIG_ILA6_4(dsp_monit_amp_ch3'left downto 0)  <= dsp_monit_amp_ch3;

  ---- Monitoring position data

  ---- cmp_chipscope_ila_4096_monit_pos : chipscope_ila_4096
  --cmp_chipscope_ila_1024_monit_pos : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL7,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA7_0,
  --  TRIG1                                   => TRIG_ILA7_1,
  --  TRIG2                                   => TRIG_ILA7_2,
  --  TRIG3                                   => TRIG_ILA7_3,
  --  TRIG4                                   => TRIG_ILA7_4
  --);

  --TRIG_ILA7_0(0)                            <= dsp_monit_pos_valid;
  --TRIG_ILA7_0(1)                            <= '0';
  --TRIG_ILA7_0(2)                            <= '0';
  --TRIG_ILA7_0(3)                            <= '0';
  --TRIG_ILA7_0(4)                            <= '0';
  --TRIG_ILA7_0(5)                            <= '0';
  --TRIG_ILA7_0(6)                            <= '0';

  --TRIG_ILA7_1(dsp_monit_pos_x'left downto 0)      <= dsp_monit_pos_x;
  --TRIG_ILA7_2(dsp_monit_pos_y'left downto 0)      <= dsp_monit_pos_y;
  --TRIG_ILA7_3(dsp_monit_pos_q'left downto 0)      <= dsp_monit_pos_q;
  --TRIG_ILA7_4(dsp_monit_pos_sum'left downto 0)    <= dsp_monit_pos_sum;

  ---- Monitoring 1 position data
  --cmp_chipscope_ila_1024_monit_pos_1 : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL8,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA8_0,
  --  TRIG1                                   => TRIG_ILA8_1,
  --  TRIG2                                   => TRIG_ILA8_2,
  --  TRIG3                                   => TRIG_ILA8_3,
  --  TRIG4                                   => TRIG_ILA8_4
  --);

  --TRIG_ILA8_0(0)                            <= dsp_monit_pos_1_valid;
  --TRIG_ILA8_0(1)                            <= '0';
  --TRIG_ILA8_0(2)                            <= '0';
  --TRIG_ILA8_0(3)                            <= '0';
  --TRIG_ILA8_0(4)                            <= '0';
  --TRIG_ILA8_0(5)                            <= '0';
  --TRIG_ILA8_0(6)                            <= '0';

  --TRIG_ILA8_1(dsp_monit_pos_x_1'left downto 0)     <= dsp_monit_pos_x_1;
  --TRIG_ILA8_2(dsp_monit_pos_y_1'left downto 0)     <= dsp_monit_pos_y_1;
  --TRIG_ILA8_3(dsp_monit_pos_q_1'left downto 0)     <= dsp_monit_pos_q_1;
  --TRIG_ILA8_4(dsp_monit_pos_sum_1'left downto 0)   <= dsp_monit_pos_sum_1;

  ---- TBT Phase data
  --cmp_chipscope_ila_1024_tbt_pha : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL9,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA9_0,
  --  TRIG1                                   => TRIG_ILA9_1,
  --  TRIG2                                   => TRIG_ILA9_2,
  --  TRIG3                                   => TRIG_ILA9_3,
  --  TRIG4                                   => TRIG_ILA9_4
  --);

  --TRIG_ILA9_0(0)                            <= dsp_tbt_pha_valid;
  --TRIG_ILA9_0(1)                            <= '0';
  --TRIG_ILA9_0(2)                            <= '0';
  --TRIG_ILA9_0(3)                            <= '0';
  --TRIG_ILA9_0(4)                            <= '0';
  --TRIG_ILA9_0(5)                            <= '0';
  --TRIG_ILA9_0(6)                            <= '0';

  --TRIG_ILA9_1(dsp_tbt_pha_ch0'left downto 0)      <= dsp_tbt_pha_ch0;
  --TRIG_ILA9_2(dsp_tbt_pha_ch1'left downto 0)      <= dsp_tbt_pha_ch1;
  --TRIG_ILA9_3(dsp_tbt_pha_ch2'left downto 0)      <= dsp_tbt_pha_ch2;
  --TRIG_ILA9_4(dsp_tbt_pha_ch3'left downto 0)      <= dsp_tbt_pha_ch3;

  ---- FOFB Phase data
  --cmp_chipscope_ila_1024_fofb_pha : chipscope_ila_1024
  --port map (
  --  CONTROL                                 => CONTROL10,
  --  CLK                                     => fs_clk,
  --  TRIG0                                   => TRIG_ILA10_0,
  --  TRIG1                                   => TRIG_ILA10_1,
  --  TRIG2                                   => TRIG_ILA10_2,
  --  TRIG3                                   => TRIG_ILA10_3,
  --  TRIG4                                   => TRIG_ILA10_4
  --);

  --TRIG_ILA10_0(0)                           <= dsp_fofb_pha_valid;
  --TRIG_ILA10_0(1)                           <= '0';
  --TRIG_ILA10_0(2)                           <= '0';
  --TRIG_ILA10_0(3)                           <= '0';
  --TRIG_ILA10_0(4)                           <= '0';
  --TRIG_ILA10_0(5)                           <= '0';
  --TRIG_ILA10_0(6)                           <= '0';

  --TRIG_ILA10_1(dsp_fofb_pha_ch0'left downto 0)    <= dsp_fofb_pha_ch0;
  --TRIG_ILA10_2(dsp_fofb_pha_ch1'left downto 0)    <= dsp_fofb_pha_ch1;
  --TRIG_ILA10_3(dsp_fofb_pha_ch2'left downto 0)    <= dsp_fofb_pha_ch2;
  --TRIG_ILA10_4(dsp_fofb_pha_ch3'left downto 0)    <= dsp_fofb_pha_ch3;

  ----------------------------------------------------------------------
  --                AFC Diagnostics Chipscope                         --
  ----------------------------------------------------------------------

  -- Xilinx Chipscope
  --cmp_chipscope_icon_0 : chipscope_icon_4_port
  --port map (
  --  CONTROL0                                => CONTROL0,
  --  CONTROL1                                => CONTROL1,
  --  CONTROL2                                => CONTROL2,
  --  CONTROL3                                => CONTROL3
  --);

  --cmp_chipscope_ila_1 : chipscope_ila
  --port map (
  --  CONTROL                                => CONTROL1,
  --  CLK                                    => clk_sys,
  --  TRIG0                                  => TRIG_ILA1_0,
  --  TRIG1                                  => TRIG_ILA1_1,
  --  TRIG2                                  => TRIG_ILA1_2,
  --  TRIG3                                  => TRIG_ILA1_3
  --);

  --TRIG_ILA1_0                               <= cbar_master_o(c_slv_afc_diag_id).dat;
  --TRIG_ILA1_1                               <= cbar_master_i(c_slv_afc_diag_id).dat;
  --TRIG_ILA1_2                               <= cbar_master_o(c_slv_afc_diag_id).adr;
  --TRIG_ILA1_3(31 downto 8)                  <= (others => '0');
  --TRIG_ILA1_3(7 downto 0)                   <= cbar_master_i(c_slv_afc_diag_id).ack &
  --                                              cbar_master_o(c_slv_afc_diag_id).we &
  --                                              cbar_master_o(c_slv_afc_diag_id).stb &
  --                                              cbar_master_o(c_slv_afc_diag_id).sel &
  --                                              cbar_master_o(c_slv_afc_diag_id).cyc;

  --cmp_chipscope_ila_2 : chipscope_ila
  --port map (
  --  CONTROL                                => CONTROL2,
  --  CLK                                    => clk_sys,
  --  TRIG0                                  => TRIG_ILA2_0,
  --  TRIG1                                  => TRIG_ILA2_1,
  --  TRIG2                                  => TRIG_ILA2_2,
  --  TRIG3                                  => TRIG_ILA2_3
  --);

  --TRIG_ILA2_0(31 downto 4)                  <= (others => '0');
  --TRIG_ILA2_0(3 downto 0)                   <= diag_spi_so_o & diag_spi_clk_i & diag_spi_si_i & diag_spi_cs_i;
  --TRIG_ILA2_1                               <= (others => '0');
  --TRIG_ILA2_2                               <= (others => '0');
  --TRIG_ILA2_3                               <= (others => '0');

  --cmp_chipscope_ila_3 : chipscope_ila
  --port map (
  --  CONTROL                                => CONTROL3,
  --  CLK                                    => clk_sys,
  --  TRIG0                                  => TRIG_ILA3_0,
  --  TRIG1                                  => TRIG_ILA3_1,
  --  TRIG2                                  => TRIG_ILA3_2,
  --  TRIG3                                  => TRIG_ILA3_3
  --);

  --TRIG_ILA3_0(31 downto 4)                  <= (others => '0');
  --TRIG_ILA3_0(3 downto 0)                   <= diag_spi_so_o & diag_spi_clk_i & diag_spi_si_i & diag_spi_cs_i;
  --TRIG_ILA3_1                               <= (others => '0');
  --TRIG_ILA3_2                               <= (others => '0');
  --TRIG_ILA3_3                               <= (others => '0');

  --cmp_chipscope_ila_0_fmc_adc_clk0 : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL0,
  --  CLK                                     => fs1_clk,
  --  TRIG0                                   => TRIG_ILA0_0,
  --  TRIG1                                   => TRIG_ILA0_1,
  --  TRIG2                                   => TRIG_ILA0_2,
  --  TRIG3                                   => TRIG_ILA0_3
  --);

  ---- fmc_adc WBS master output data
  ----TRIG_ILA0_0                               <= wbs_fmc_adc_out_array(3).dat &
  ----                                               wbs_fmc_adc_out_array(2).dat;
  --TRIG_ILA0_0                               <= fmc1_data(31 downto 16) &
  --                                               fmc1_data(47 downto 32);

  ---- fmc_adc WBS master output data
  --TRIG_ILA0_1(11 downto 0)                   <= fmc1_adc_dly_debug_int(1).clk_chain.idelay.pulse &
  --                                              fmc1_adc_dly_debug_int(1).data_chain.idelay.pulse &
  --                                              fmc1_adc_dly_debug_int(1).clk_chain.idelay.val &
  --                                              fmc1_adc_dly_debug_int(1).data_chain.idelay.val;
  --TRIG_ILA0_1(31 downto 12)                  <= (others => '0');

  ---- fmc_adc WBS master output control signals
  --TRIG_ILA0_2(17 downto 0)                   <=  wbs_fmc1_out_array(1).cyc &
  --                                               wbs_fmc1_out_array(1).stb &
  --                                               wbs_fmc1_out_array(1).adr &
  --                                               wbs_fmc1_out_array(1).sel &
  --                                               wbs_fmc1_out_array(1).we &
  --                                               wbs_fmc1_out_array(2).cyc &
  --                                               wbs_fmc1_out_array(2).stb &
  --                                               wbs_fmc1_out_array(2).adr &
  --                                               wbs_fmc1_out_array(2).sel &
  --                                               wbs_fmc1_out_array(2).we;
  --TRIG_ILA0_2(18)                            <= '0';
  --TRIG_ILA0_2(22 downto 19)                  <= fmc1_data_valid;
  --TRIG_ILA0_2(23)                            <= fmc1_mmcm_lock_int;
  --TRIG_ILA0_2(24)                            <= fmc1_pll_status_int;
  --TRIG_ILA0_2(25)                            <= fmc1_debug_valid_int(1);
  --TRIG_ILA0_2(26)                            <= fmc1_debug_full_int(1);
  --TRIG_ILA0_2(27)                            <= fmc1_debug_empty_int(1);
  --TRIG_ILA0_2(31 downto 28)                  <= (others => '0');

  --TRIG_ILA0_3                                <= (others => '0');

  --cmp_chipscope_ila_1_ddr_acq : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL1,
  --  CLK                                     => ddr_aximm_clk,
  --  TRIG0                                   => TRIG_ILA1_0,
  --  TRIG1                                   => TRIG_ILA1_1,
  --  TRIG2                                   => TRIG_ILA1_2,
  --  TRIG3                                   => TRIG_ILA1_3
  --);

  --TRIG_ILA1_0                               <= memc_wr_data(207 downto 192) &
  --                                               memc_wr_data(143 downto 128);
  --TRIG_ILA1_1                               <= memc_wr_data(79 downto 64) &
  --                                               memc_wr_data(15 downto 0);

  --TRIG_ILA1_2                               <= memc_cmd_addr_resized;
  --TRIG_ILA1_3(31 downto 30)                 <= (others => '0');
  --TRIG_ILA1_3(27 downto 0)                  <= ddr_aximm_rstn &
  --                                               clk_200mhz_rstn &
  --                                               memc_cmd_instr & -- std_logic_vector(2 downto 0);
  --                                               memc_cmd_en &
  --                                               memc_cmd_rdy &
  --                                               memc_wr_end &
  --                                               memc_wr_mask(15 downto 0) & -- std_logic_vector(31 downto 0);
  --                                               memc_wr_en &
  --                                               memc_wr_rdy &
  --                                               memarb_acc_req &
  --                                               memarb_acc_gnt;

  --cmp_chipscope_ila_2_generic : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL2,
  --  CLK                                     => clk_sys,
  --  TRIG0                                   => TRIG_ILA2_0,
  --  TRIG1                                   => TRIG_ILA2_1,
  --  TRIG2                                   => TRIG_ILA2_2,
  --  TRIG3                                   => TRIG_ILA2_3
  --);

  --TRIG_ILA2_0(5 downto 0)                   <= clk_sys_rst &
  --                                              clk_sys_rstn &
  --                                              rst_button_sys_n &
  --                                              rst_button_sys &
  --                                              rst_button_sys_pp &
  --                                              sys_rst_button_n_i;

  --TRIG_ILA2_0(31 downto 6)                  <= (others => '0');
  --TRIG_ILA2_1                               <= (others => '0');
  --TRIG_ILA2_2                               <= (others => '0');
  --TRIG_ILA2_3                               <= (others => '0');

  ---- The clocks to/from peripherals are derived from the bus clock.
  ---- Therefore we don't have to worry about synchronization here, just
  ---- keep in mind that the data/ss lines will appear longer than normal
  --cmp_chipscope_ila_3_pcie : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL3,
  --  CLK                                     => clk_sys, -- Wishbone clock
  --  TRIG0                                   => TRIG_ILA3_0,
  --  TRIG1                                   => TRIG_ILA3_1,
  --  TRIG2                                   => TRIG_ILA3_2,
  --  TRIG3                                   => TRIG_ILA3_3
  --);

  --TRIG_ILA3_0                               <= wb_ma_pcie_dat_in(31 downto 0);
  --TRIG_ILA3_1                               <= wb_ma_pcie_dat_out(31 downto 0);
  --TRIG_ILA3_2(31 downto wb_ma_pcie_addr_out'left + 1) <= (others => '0');
  --TRIG_ILA3_2(wb_ma_pcie_addr_out'left downto 0)
  --                                          <= wb_ma_pcie_addr_out(wb_ma_pcie_addr_out'left downto 0);
  --TRIG_ILA3_3(31 downto 5)                  <= (others => '0');
  --TRIG_ILA3_3(4 downto 0)                   <= wb_ma_pcie_ack_in &
  --                                              wb_ma_pcie_we_out &
  --                                              wb_ma_pcie_stb_out &
  --                                              wb_ma_pcie_sel_out &
  --                                              wb_ma_pcie_cyc_out;

  --cmp_chipscope_ila_3_pcie_ddr_read : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL3,
  --  CLK                                     => ddr_aximm_clk, -- DDR3 controller clk
  --  TRIG0                                   => TRIG_ILA3_0,
  --  TRIG1                                   => TRIG_ILA3_1,
  --  TRIG2                                   => TRIG_ILA3_2,
  --  TRIG3                                   => TRIG_ILA3_3
  --);

  --TRIG_ILA3_0                               <= dbg_app_rd_data(207 downto 192) &
  --                                              dbg_app_rd_data(143 downto 128);
  --TRIG_ILA3_1                               <= dbg_app_rd_data(79 downto 64) &
  --                                              dbg_app_rd_data(15 downto 0);

  --TRIG_ILA3_2                               <= dbg_app_addr;

  --TRIG_ILA3_3(31 downto 11)                 <= (others => '0');
  --TRIG_ILA3_3(10 downto 0)                  <=  dbg_app_rd_data_end &
  --                                               dbg_app_rd_data_valid &
  --                                               dbg_app_cmd & -- std_logic_vector(2 downto 0);
  --                                               dbg_app_en &
  --                                               dbg_app_rdy &
  --                                               dbg_arb_req &
  --                                               dbg_arb_gnt;

  --cmp_chipscope_ila_5_pcie_ddr_write : chipscope_ila
  --port map (
  --  CONTROL                                 => CONTROL4,
  --  CLK                                     => ddr_aximm_clk, -- DDR3 controller clk
  --  TRIG0                                   => TRIG_ILA4_0,
  --  TRIG1                                   => TRIG_ILA4_1,
  --  TRIG2                                   => TRIG_ILA4_2,
  --  TRIG3                                   => TRIG_ILA4_3
  --);

  --TRIG_ILA4_0                               <= dbg_app_wdf_data(207 downto 192) &
  --                                               dbg_app_wdf_data(143 downto 128);
  --TRIG_ILA4_1                               <= dbg_app_wdf_data(79 downto 64) &
  --                                               dbg_app_wdf_data(15 downto 0);

  --TRIG_ILA4_2                               <= dbg_app_addr;
  --TRIG_ILA4_3(31 downto 30)                 <= (others => '0');
  --TRIG_ILA4_3(29 downto 0)                  <= ddr_aximm_rstn &
  --                                               clk_200mhz_rstn &
  --                                               dbg_app_cmd & -- std_logic_vector(2 downto 0);
  --                                               dbg_app_en &
  --                                               dbg_app_rdy &
  --                                               dbg_app_wdf_end &
  --                                               dbg_app_wdf_mask(15 downto 0) & -- std_logic_vector(31 downto 0);
  --                                               dbg_app_wdf_wren &
  --                                               dbg_app_wdf_rdy &
  --                                               dbg_arb_req &
  --                                               dbg_arb_gnt;

end rtl;
