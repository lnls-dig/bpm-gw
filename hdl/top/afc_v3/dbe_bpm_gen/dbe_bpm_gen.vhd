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
-- Generic cores
use work.ifc_generic_pkg.all;
-- Wishbone stream modules and interface
use work.wb_stream_generic_pkg.all;
-- FMC ADC definitions
use work.fmc_adc_pkg.all;
-- DSP definitions
use work.dsp_cores_pkg.all;
-- BPM definitions
use work.bpm_cores_pkg.all;
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
-- Trigger Common Modules
use work.trigger_common_pkg.all;
-- AFC definitions
use work.afc_base_pkg.all;
-- AFC Acq definitions
use work.afc_base_acq_pkg.all;
-- Orbit interlock
use work.orbit_intlk_pkg.all;
-- DCC
use work.fofb_cc_pkg.all;
-- DCC wrappers
use work.fofb_ctrl_pkg.all;

entity dbe_bpm_gen is
generic(
  g_fmc_adc_type                             : string := "FMC250M";
  -- Enable RTM SFP module or not
  g_WITH_RTM_SFP                             : boolean := false;
  -- Number of RTM SFP GTs
  g_NUM_SFPS                                 : integer := 0;
  -- Start index of the RTM SFP GTs
  g_SFP_START_ID                             : integer := 4;
  -- enables RTM 8SFP FOFB DCC. Is this is "true", g_WITH_P2P_FOFB_DCC is
  -- automatically true, as well
  g_WITH_RTM_SFP_FOFB_DCC                    : boolean := false;
  -- Number of P2P GTs
  g_NUM_P2P_GTS                              : integer range 1 to 8 := 4;
  -- Start index of the P2P GTs
  g_P2P_GT_START_ID                          : integer := 0;
  -- Enable P2P FOFB DCC or not
  g_WITH_P2P_FOFB_DCC                        : boolean := false
);
port(
  ---------------------------------------------------------------------------
  -- Clocking pins
  ---------------------------------------------------------------------------
  sys_clk_p_i                                : in std_logic;
  sys_clk_n_i                                : in std_logic;

  aux_clk_p_i                                : in std_logic;
  aux_clk_n_i                                : in std_logic;

  afc_fp2_clk1_p_i                           : in std_logic;
  afc_fp2_clk1_n_i                           : in std_logic;

  ---------------------------------------------------------------------------
  -- Reset Button
  ---------------------------------------------------------------------------
  sys_rst_button_n_i                         : in std_logic := '1';

  ---------------------------------------------------------------------------
  -- UART pins
  ---------------------------------------------------------------------------

  uart_rxd_i                                 : in  std_logic := '1';
  uart_txd_o                                 : out std_logic;

  ---------------------------------------------------------------------------
  -- Trigger pins
  ---------------------------------------------------------------------------
  trig_dir_o                                 : out   std_logic_vector(c_NUM_TRIG-1 downto 0);
  trig_b                                     : inout std_logic_vector(c_NUM_TRIG-1 downto 0);

  ---------------------------------------------------------------------------
  -- AFC Diagnostics
  ---------------------------------------------------------------------------

  diag_spi_cs_i                              : in std_logic := '0';
  diag_spi_si_i                              : in std_logic := '0';
  diag_spi_so_o                              : out std_logic;
  diag_spi_clk_i                             : in std_logic := '0';

  ---------------------------------------------------------------------------
  -- ADN4604ASVZ
  ---------------------------------------------------------------------------
  adn4604_vadj2_clk_updt_n_o                 : out std_logic;

  ---------------------------------------------------------------------------
  -- AFC I2C.
  ---------------------------------------------------------------------------
  -- Si57x oscillator
  afc_si57x_scl_b                            : inout std_logic;
  afc_si57x_sda_b                            : inout std_logic;

  -- Si57x oscillator output enable
  afc_si57x_oe_o                             : out   std_logic;

  ---------------------------------------------------------------------------
  -- PCIe pins
  ---------------------------------------------------------------------------

  -- DDR3 memory pins
  ddr3_dq_b                                  : inout std_logic_vector(c_DDR_DQ_WIDTH-1 downto 0);
  ddr3_dqs_p_b                               : inout std_logic_vector(c_DDR_DQS_WIDTH-1 downto 0);
  ddr3_dqs_n_b                               : inout std_logic_vector(c_DDR_DQS_WIDTH-1 downto 0);
  ddr3_addr_o                                : out   std_logic_vector(c_DDR_ROW_WIDTH-1 downto 0);
  ddr3_ba_o                                  : out   std_logic_vector(c_DDR_BANK_WIDTH-1 downto 0);
  ddr3_cs_n_o                                : out   std_logic_vector(0 downto 0);
  ddr3_ras_n_o                               : out   std_logic;
  ddr3_cas_n_o                               : out   std_logic;
  ddr3_we_n_o                                : out   std_logic;
  ddr3_reset_n_o                             : out   std_logic;
  ddr3_ck_p_o                                : out   std_logic_vector(c_DDR_CK_WIDTH-1 downto 0);
  ddr3_ck_n_o                                : out   std_logic_vector(c_DDR_CK_WIDTH-1 downto 0);
  ddr3_cke_o                                 : out   std_logic_vector(c_DDR_CKE_WIDTH-1 downto 0);
  ddr3_dm_o                                  : out   std_logic_vector(c_DDR_DM_WIDTH-1 downto 0);
  ddr3_odt_o                                 : out   std_logic_vector(c_DDR_ODT_WIDTH-1 downto 0);

  -- PCIe transceivers
  pci_exp_rxp_i                              : in  std_logic_vector(c_PCIELANES - 1 downto 0);
  pci_exp_rxn_i                              : in  std_logic_vector(c_PCIELANES - 1 downto 0);
  pci_exp_txp_o                              : out std_logic_vector(c_PCIELANES - 1 downto 0);
  pci_exp_txn_o                              : out std_logic_vector(c_PCIELANES - 1 downto 0);

  -- PCI clock and reset signals
  pcie_clk_p_i                               : in std_logic;
  pcie_clk_n_i                               : in std_logic;

  ---------------------------------------------------------------------------
  -- User LEDs
  ---------------------------------------------------------------------------
  leds_o                                     : out std_logic_vector(2 downto 0);

  ---------------------------------------------------------------------------
  -- FMC interface
  ---------------------------------------------------------------------------

  board_i2c_scl_b                            : inout std_logic;
  board_i2c_sda_b                            : inout std_logic;

  ---------------------------------------------------------------------------
  -- Flash memory SPI interface
  ---------------------------------------------------------------------------
  --
  -- spi_sclk_o                              : out std_logic;
  -- spi_cs_n_o                              : out std_logic;
  -- spi_mosi_o                              : out std_logic;
  -- spi_miso_i                              : in  std_logic := '0';

  ---------------------------------------------------------------------------
  -- P2P GT pins
  ---------------------------------------------------------------------------
  -- P2P
  p2p_gt_rx_p_i                              : in    std_logic_vector(g_NUM_P2P_GTS+g_P2P_GT_START_ID-1 downto g_P2P_GT_START_ID) := (others => '0');
  p2p_gt_rx_n_i                              : in    std_logic_vector(g_NUM_P2P_GTS+g_P2P_GT_START_ID-1 downto g_P2P_GT_START_ID) := (others => '1');
  p2p_gt_tx_p_o                              : out   std_logic_vector(g_NUM_P2P_GTS+g_P2P_GT_START_ID-1 downto g_P2P_GT_START_ID);
  p2p_gt_tx_n_o                              : out   std_logic_vector(g_NUM_P2P_GTS+g_P2P_GT_START_ID-1 downto g_P2P_GT_START_ID);

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

  ---------------------------------------------------------------------------
  -- RTM board pins
  ---------------------------------------------------------------------------
  -- SFP
  rtm_sfp_rx_p_i                             : in    std_logic_vector(g_NUM_SFPS+g_SFP_START_ID-1 downto g_SFP_START_ID) := (others => '0');
  rtm_sfp_rx_n_i                             : in    std_logic_vector(g_NUM_SFPS+g_SFP_START_ID-1 downto g_SFP_START_ID) := (others => '1');
  rtm_sfp_tx_p_o                             : out   std_logic_vector(g_NUM_SFPS+g_SFP_START_ID-1 downto g_SFP_START_ID);
  rtm_sfp_tx_n_o                             : out   std_logic_vector(g_NUM_SFPS+g_SFP_START_ID-1 downto g_SFP_START_ID);

  -- RTM I2C.
  -- SFP configuration pins, behind a I2C MAX7356. I2C addr = 1110_100 & '0' = 0xE8
  -- Si570 oscillator. Input 0 of CDCLVD1212. I2C addr = 1010101 & '0' = 0x55
  rtm_scl_b                                  : inout std_logic;
  rtm_sda_b                                  : inout std_logic;

  -- Si570 oscillator output enable
  rtm_si570_oe_o                             : out   std_logic;

  ---- Clock to RTM connector. Input 1 of CDCLVD1212. Not connected directly to
  -- AFC
  --rtm_rtm_sync_clk_p_o                       : out   std_logic;
  --rtm_rtm_sync_clk_n_o                       : out   std_logic;

  -- Select between input 0 or 1 or CDCLVD1212. 0 is Si570, 1 is RTM sync clock
  rtm_clk_in_sel_o                           : out   std_logic;

  -- FPGA clocks from CDCLVD1212
  rtm_fpga_clk1_p_i                          : in    std_logic := '0';
  rtm_fpga_clk1_n_i                          : in    std_logic := '0';
  rtm_fpga_clk2_p_i                          : in    std_logic := '0';
  rtm_fpga_clk2_n_i                          : in    std_logic := '0';

  -- SFP status bits. Behind 4 74HC165, 8-parallel-in/serial-out. 4 x 8 bits.
  -- The PISO chips are organized like this:
  --
  -- Parallel load
  rtm_sfp_status_reg_pl_o                    : out   std_logic;
  -- Clock N
  rtm_sfp_status_reg_clk_n_o                 : out   std_logic;
  -- Serial output
  rtm_sfp_status_reg_out_i                   : in    std_logic   := '0';

  -- SFP control bits. Behind 4 74HC4094D, serial-in/8-parallel-out. 5 x 8 bits.
  -- The SIPO chips are organized like this:
  --
  -- Strobe
  rtm_sfp_ctl_str_n_o                        : out   std_logic;
  -- Data input
  rtm_sfp_ctl_din_n_o                        : out   std_logic;
  -- Parallel output enable
  rtm_sfp_ctl_oe_n_o                         : out   std_logic;

  -- External clock from RTM to FPGA
  rtm_ext_clk_p_i                            : in    std_logic  := '0';
  rtm_ext_clk_n_i                            : in    std_logic  := '0'
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

  type t_gt_cfg is record
    with_fp_p2p    : boolean;
    num_p2p_gts    : integer;
    max_p2p_gts    : integer;
    num_fp_p2p_gts : integer;
    max_fp_p2p_gts : integer;
  end record;

  function f_extract_gt_cfg(num_p2p : integer) return t_gt_cfg is
    variable rv : t_gt_cfg;
  begin
    rv.max_p2p_gts       := 4;           -- maximum
    rv.max_fp_p2p_gts    := 4;           -- maximum

    if num_p2p > 4 then
      rv.with_fp_p2p     := true;
      rv.num_p2p_gts     := 4;           -- maximum
      rv.max_p2p_gts     := 4;           -- maximum
      rv.num_fp_p2p_gts  := num_p2p - 4; -- remaining, up to 4
      rv.max_fp_p2p_gts  := 4;           -- maximum
    else
      rv.with_fp_p2p     := false;
      rv.num_p2p_gts     := num_p2p; -- up to 4
      rv.num_fp_p2p_gts  := 0;       -- no FP GT
    end if;

    return rv;
  end function;

  -----------------------------------------------------------------------------
  -- General constants
  -----------------------------------------------------------------------------

  constant c_SYS_CLOCK_FREQ                  : natural := 100000000;
  constant c_REF_CLOCK_FREQ                  : natural := 69306000; -- RF*5/36
  -- number of the ADC reference clock used for all downstream
  -- FPGA logic
  constant c_ADC_REF_CLK                     : natural := 2;

  constant c_NUM_USER_IRQ                    : natural := 1;

  -- Swap/de-swap settings
  constant c_POS_CALC_DELAY_VEC_WIDTH         : natural := 8;
  constant c_POS_CALC_SWAP_DIV_FREQ_VEC_WIDTH : natural := 16;

  constant c_AFC_SI57x_I2C_FREQ              : natural := 400000;
  constant c_AFC_SI57x_INIT_OSC              : boolean := true;
  constant c_AFC_SI57x_INIT_RFREQ_VALUE      : std_logic_vector(37 downto 0) := "00" & x"2bc0af3b8";
  constant c_AFC_SI57x_INIT_N1_VALUE         : std_logic_vector(6 downto 0) := "0000111";
  constant c_AFC_SI57x_INIT_HS_VALUE         : std_logic_vector(2 downto 0) := "000";

  -----------------------------------------------------------------------------
  -- AFC Si57x signals
  -----------------------------------------------------------------------------

  signal afc_si57x_sta_reconfig_done         : std_logic;
  signal afc_si57x_sta_reconfig_done_pp      : std_logic;
  signal afc_si57x_reconfig_rst              : std_logic;
  signal afc_si57x_reconfig_rst_n            : std_logic;

  signal afc_si57x_ext_wr                    : std_logic;
  signal afc_si57x_ext_rfreq_value           : std_logic_vector(37 downto 0);
  signal afc_si57x_ext_n1_value              : std_logic_vector(6 downto 0);
  signal afc_si57x_ext_hs_value              : std_logic_vector(2 downto 0);

  -----------------------------------------------------------------------------
  -- RTM SFP signals
  -----------------------------------------------------------------------------

  -- RTM 8SFP IDs
  constant c_NUM_SFPS_FOFB                   : integer := g_NUM_SFPS;
  constant c_RTM_8SFP_NUM_CORES              : natural := 1;

  constant c_RTM_8SFP_0_ID                   : natural := 0;

  constant c_SLV_RTM_8SFP_CORE_IDS           : t_num_array(c_RTM_8SFP_NUM_CORES-1 downto 0) :=
    f_gen_ramp(0, c_RTM_8SFP_NUM_CORES);

  constant c_RTM_SI57x_I2C_FREQ              : integer := 400000;
  constant c_RTM_SI57x_INIT_OSC              : boolean := true;
  constant c_RTM_SI57x_INIT_RFREQ_VALUE      : std_logic_vector(37 downto 0) := "00" & x"2bc0af3b8";
  constant c_RTM_SI57x_INIT_N1_VALUE         : std_logic_vector(6 downto 0) := "0000111";
  constant c_RTM_SI57x_INIT_HS_VALUE         : std_logic_vector(2 downto 0) := "000";

  -- Wishbone bus from user afc_base_acq to RTM
  signal wb_rtm_master_out                   : t_wishbone_master_out_array(c_RTM_8SFP_NUM_CORES-1 downto 0);
  signal wb_rtm_master_in                    : t_wishbone_master_in_array(c_RTM_8SFP_NUM_CORES-1 downto 0);

  -- Fix SFP inversion from 1 to 8 to 8 to 1
  signal rtm_sfp_fix_rx_p                    : std_logic_vector(c_NUM_SFPS_FOFB-1 downto 0);
  signal rtm_sfp_fix_rx_n                    : std_logic_vector(c_NUM_SFPS_FOFB-1 downto 0);
  signal rtm_sfp_fix_tx_p                    : std_logic_vector(c_NUM_SFPS_FOFB-1 downto 0);
  signal rtm_sfp_fix_tx_n                    : std_logic_vector(c_NUM_SFPS_FOFB-1 downto 0);

  -- SFPs to FOFB controller
  signal rtm_sfp_rx_p                        : std_logic_vector(c_NUM_SFPS_FOFB-1 downto 0);
  signal rtm_sfp_rx_n                        : std_logic_vector(c_NUM_SFPS_FOFB-1 downto 0);
  signal rtm_sfp_tx_p                        : std_logic_vector(c_NUM_SFPS_FOFB-1 downto 0);
  signal rtm_sfp_tx_n                        : std_logic_vector(c_NUM_SFPS_FOFB-1 downto 0);

  signal rtm_clk1_p                          : std_logic;
  signal rtm_clk1_n                          : std_logic;
  signal rtm_clk2_p                          : std_logic;
  signal rtm_clk2_n                          : std_logic;

  signal rtm_ext_clk_p                       : std_logic;
  signal rtm_ext_clk_n                       : std_logic;
  signal rtm_sta_reconfig_done               : std_logic;
  signal rtm_sta_reconfig_done_pp            : std_logic;
  signal rtm_reconfig_rst                    : std_logic;
  signal rtm_reconfig_rst_n                  : std_logic;

  signal rtm_ext_wr                          : std_logic;
  signal rtm_ext_rfreq_value                 : std_logic_vector(37 downto 0);
  signal rtm_ext_n1_value                    : std_logic_vector(6 downto 0);
  signal rtm_ext_hs_value                    : std_logic_vector(2 downto 0);

  signal sfp_txdisable                       : std_logic_vector(7 downto 0) := (others => '0');
  signal sfp_rs0                             : std_logic_vector(7 downto 0) := (others => '0');
  signal sfp_rs1                             : std_logic_vector(7 downto 0) := (others => '0');

  signal sfp_led1                            : std_logic_vector(7 downto 0);
  signal sfp_los                             : std_logic_vector(7 downto 0);
  signal sfp_txfault                         : std_logic_vector(7 downto 0);
  signal sfp_detect_n                        : std_logic_vector(7 downto 0);

  signal sfp_fix_txdisable                   : std_logic_vector(7 downto 0) := (others => '0');
  signal sfp_fix_rs0                         : std_logic_vector(7 downto 0) := (others => '0');
  signal sfp_fix_rs1                         : std_logic_vector(7 downto 0) := (others => '0');

  signal sfp_fix_led1                        : std_logic_vector(7 downto 0);
  signal sfp_fix_los                         : std_logic_vector(7 downto 0);
  signal sfp_fix_txfault                     : std_logic_vector(7 downto 0);
  signal sfp_fix_detect_n                    : std_logic_vector(7 downto 0);

  -----------------------------------------------------------------------------
  -- FOFB DCC signals
  -----------------------------------------------------------------------------

  -- FOFB CC
  constant c_NUM_FOFB_CC_CORES               : natural := 2; -- Max of RTM SFP + P2P

  -- P2P GT IDs
  constant c_GT_CFG                          : t_gt_cfg := f_extract_gt_cfg(g_NUM_P2P_GTS);
  constant c_NUM_P2P_GTS                     : integer := c_GT_CFG.num_p2p_gts + c_GT_CFG.num_fp_p2p_gts;

  constant c_FOFB_CC_P2P_ID                  : natural := 0;
  constant c_FOFB_CC_RTM_ID                  : natural := 1;

  constant c_BPMS                            : integer := 2;
  constant c_FAI_DW                          : integer := 16;
  constant c_DMUX                            : integer := 2;
  constant c_MAX_LANE_COUNT                  : integer := 8;
  constant c_USE_CHIPSCOPE                   : boolean := false;
  constant c_FOFB_DCC_DATA_WIDTH             : natural := 32*PacketSize;

  type t_fofb_cc_logic_array is array (natural range <>) of std_logic;
  type t_fofb_cc_data_fai_array is array (natural range <>) of std_logic_vector(c_FAI_DW-1 downto 0);
  type t_fofb_cc_buf_addr_array is array (natural range <>) of std_logic_vector(NodeW downto 0);
  type t_fofb_cc_buf_data_array is array (natural range <>) of std_logic_vector(63 downto 0);
  type t_fofb_cc_node_mask_array is array (natural range <>) of std_logic_vector(NodeNum-1 downto 0);
  type t_fofb_cc_std32_array is array (natural range <>) of std_logic_vector(31 downto 0);
  type t_fofb_cc_std4_array is array (natural range <>) of std_logic_vector(3 downto 0);
  type t_fofb_cc_fod_data_array is array (natural range <>) of std_logic_vector(c_FOFB_DCC_DATA_WIDTH-1 downto 0);
  type t_fofb_cc_fod_val_array is array (natural range <>) of std_logic_vector(c_MAX_LANE_COUNT-1 downto 0);
  type t_fofb_cc_rio_array is array (natural range <>) of std_logic_vector(c_MAX_LANE_COUNT-1 downto 0);
  type t_fai_fa_pl_state is (IDLE, WAIT_TRIGGER, SEND_BPM_DATA);

  signal fai_fa_block_start                  : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal fai_fa_data_valid                   : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal fai_fa_d                            : t_fofb_cc_data_fai_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => (others => '0'));

  signal fai_fa_pl_data_valid_r              : std_logic := '0';
  signal fai_fa_pl_d_x_r                     : std_logic_2d_32(c_BPMS-1 downto 0) := (others => (others => '0'));
  signal fai_fa_pl_d_y_r                     : std_logic_2d_32(c_BPMS-1 downto 0) := (others => (others => '0'));
  signal fai_fa_pl_state                     : t_fai_fa_pl_state;

  signal fai_sim_data_sel                    : t_fofb_cc_std4_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => (others => '0'));
  signal fai_sim_enable                      : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '1');
  signal fai_sim_trigger                     : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal fai_sim_trigger_internal            : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal fai_sim_armed                       : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0);

   signal fai_cfg_clk                        : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
   signal fai_cfg_val                        : t_fofb_cc_std32_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => (others => '0'));


  signal fofb_userclk                        : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal fofb_userrst                        : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal fofb_userrst_n                      : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal timeframe_start                     : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal timeframe_end                       : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal fofb_dma_ok                         : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');
  signal fofb_node_mask                      : t_fofb_cc_node_mask_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => (others => '0'));
  signal fofb_timestamp_val                  : t_fofb_cc_std32_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => (others => '0'));
  signal fofb_link_status                    : t_fofb_cc_std32_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => (others => '0'));
  signal fofb_cc_enable                      : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
                                                    (others => '0');

  signal fofb_fod_dat                        : t_fofb_cc_fod_data_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_fod_dat_val                    : t_fofb_cc_fod_val_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_fod_dat_fs_sync                : t_fofb_cc_fod_data_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_fod_dat_val_fs_sync            : t_fofb_cc_fod_val_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_rio_rx_p                       : t_fofb_cc_rio_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_rio_rx_n                       : t_fofb_cc_rio_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_rio_tx_p                       : t_fofb_cc_rio_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_rio_tx_n                       : t_fofb_cc_rio_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_rio_tx_disable                 : t_fofb_cc_rio_array(c_NUM_FOFB_CC_CORES-1 downto 0);

  signal fofb_ref_clk_p                      : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0);
  signal fofb_ref_clk_n                      : t_fofb_cc_logic_array(c_NUM_FOFB_CC_CORES-1 downto 0);

  signal fofb_sysreset_n                     : std_logic_vector(c_NUM_FOFB_CC_CORES-1 downto 0);

  -----------------------------------------------------------------------------
  -- Acquisition signals
  -----------------------------------------------------------------------------

  constant c_ACQ_FIFO_SIZE                   : natural := 256;

  -- Type of DDR3 core interface
  constant c_DDR_INTERFACE_TYPE              : string := "AXIS";

  constant c_ACQ_ADC_ID                     : natural := 0;
  constant c_ACQ_ADC_SWAP_ID                : natural := 1;
  constant c_ACQ_MIXIQ_ID                   : natural := 2;
  constant c_DUMMY0_ID                      : natural := 3;
  constant c_ACQ_TBTDECIMIQ_ID              : natural := 4;
  constant c_DUMMY1_ID                      : natural := 5;
  constant c_ACQ_TBT_AMP_ID                 : natural := 6;
  constant c_ACQ_TBT_PHASE_ID               : natural := 7;
  constant c_ACQ_TBT_POS_ID                 : natural := 8;
  constant c_ACQ_FOFBDECIMIQ_ID             : natural := 9;
  constant c_DUMMY2_ID                      : natural := 10;
  constant c_ACQ_FOFB_AMP_ID                : natural := 11;
  constant c_ACQ_FOFB_PHASE_ID              : natural := 12;
  constant c_ACQ_FOFB_POS_ID                : natural := 13;
  constant c_ACQ_MONIT1_AMP_ID              : natural := 14;
  constant c_ACQ_MONIT1_POS_ID              : natural := 15;
  constant c_ACQ_MONIT_AMP_ID               : natural := 16;
  constant c_ACQ_MONIT_POS_ID               : natural := 17;
  constant c_TRIGGER_SW_CLK_ID              : natural := 18;
  constant c_PHASE_SYNC_TRIGGER_SLOW_ID     : natural := 19;
  constant c_ACQ_DCC_ID                     : natural := 20;

  -- Number of channels per acquisition core
  constant c_ACQ_NUM_CHANNELS               : natural := 21; -- ADC + ADC SWAP + MIXER + TBT AMP + TBT POS +
                                                            -- FOFB AMP + FOFB POS + MONIT AMP + MONIT POS + MONIT1 AMP +
                                                            -- MONIT1 POS for each FMC + trigger ID + DCC

  constant c_ACQ_POS_DDR3_WIDTH             : natural := 32;

  -- Acquisition core IDs
  constant c_ACQ_CORE_0_ID                  : natural := 0;
  constant c_ACQ_CORE_1_ID                  : natural := 1;
  constant c_ACQ_CORE_2_ID                  : natural := 2;
  constant c_ACQ_CORE_3_ID                  : natural := 3;
  -- Number of acquisition cores. Same as the number of RTM_LAMP
  -- Number of acquisition cores (FMC1, FMC2, Post Mortem 1, Post Mortem 2)
  constant c_ACQ_NUM_CORES                  : natural := 4;

  constant c_ACQ_ADDR_WIDTH                 : natural := c_DDR_ADDR_WIDTH;
  -- Post-Mortem Acq Cores dont need Multishot. So, set them to 0
  constant c_ACQ_MULTISHOT_RAM_SIZE         : t_property_value_array(c_ACQ_NUM_CORES-1 downto 0) := (0, 0, 4096, 4096);
  constant c_ACQ_DDR_ADDR_RES_WIDTH         : natural := 32;
  constant c_ACQ_DDR_ADDR_DIFF              : natural := c_ACQ_DDR_ADDR_RES_WIDTH-c_DDR_ADDR_WIDTH;

  constant c_ACQ_WIDTH_U64                  : unsigned(c_ACQ_CHAN_CMPLT_WIDTH_LOG2-1 downto 0) :=
                                                to_unsigned(64, c_ACQ_CHAN_CMPLT_WIDTH_LOG2);
  constant c_ACQ_WIDTH_U128                 : unsigned(c_ACQ_CHAN_CMPLT_WIDTH_LOG2-1 downto 0) :=
                                                to_unsigned(128, c_ACQ_CHAN_CMPLT_WIDTH_LOG2);
  constant c_ACQ_WIDTH_U256                 : unsigned(c_ACQ_CHAN_CMPLT_WIDTH_LOG2-1 downto 0) :=
                                                to_unsigned(256, c_ACQ_CHAN_CMPLT_WIDTH_LOG2);
  constant c_ACQ_NUM_ATOMS_U4               : unsigned(c_ACQ_NUM_ATOMS_WIDTH_LOG2-1 downto 0) :=
                                                to_unsigned(4, c_ACQ_NUM_ATOMS_WIDTH_LOG2);
  constant c_ACQ_NUM_ATOMS_U8               : unsigned(c_ACQ_NUM_ATOMS_WIDTH_LOG2-1 downto 0) :=
                                                to_unsigned(8, c_ACQ_NUM_ATOMS_WIDTH_LOG2);
  constant c_ACQ_ATOM_WIDTH_U16              : unsigned(c_ACQ_ATOM_WIDTH_LOG2-1 downto 0) :=
                                                to_unsigned(16, c_ACQ_ATOM_WIDTH_LOG2);
  constant c_ACQ_ATOM_WIDTH_U32             : unsigned(c_ACQ_ATOM_WIDTH_LOG2-1 downto 0) :=
                                                to_unsigned(32, c_ACQ_ATOM_WIDTH_LOG2);

  constant c_FACQ_PARAMS_ADC                : t_facq_chan_param := f_acq_channel_adc_param(g_FMC_ADC_TYPE);
  constant c_FACQ_PARAMS_MIX                : t_facq_chan_param := f_acq_channel_mix_param(g_FMC_ADC_TYPE);

  constant c_FACQ_PARAMS_DCC                 : t_facq_chan_param := (
    width                                    => to_unsigned(128, c_ACQ_CHAN_CMPLT_WIDTH_LOG2),
    num_atoms                                => to_unsigned(4, c_ACQ_NUM_ATOMS_WIDTH_LOG2),
    atom_width                               => to_unsigned(32, c_ACQ_ATOM_WIDTH_LOG2)
  );

  constant c_FACQ_CHANNELS                  : t_facq_chan_param_array(c_ACQ_NUM_CHANNELS-1 downto 0) :=
  (
     c_ACQ_ADC_ID            => c_FACQ_PARAMS_ADC,
     c_ACQ_ADC_SWAP_ID       => c_FACQ_PARAMS_ADC,
     c_ACQ_MIXIQ_ID          => c_FACQ_PARAMS_MIX,
     c_DUMMY0_ID             => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_TBTDECIMIQ_ID     => (width => c_ACQ_WIDTH_U256, num_atoms => c_ACQ_NUM_ATOMS_U8, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_DUMMY1_ID             => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_TBT_AMP_ID        => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_TBT_PHASE_ID      => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_TBT_POS_ID        => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_FOFBDECIMIQ_ID    => (width => c_ACQ_WIDTH_U256, num_atoms => c_ACQ_NUM_ATOMS_U8, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_DUMMY2_ID             => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_FOFB_AMP_ID       => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_FOFB_PHASE_ID     => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_FOFB_POS_ID       => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_MONIT1_AMP_ID     => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_MONIT1_POS_ID     => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_MONIT_AMP_ID      => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_MONIT_POS_ID      => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     -- Unused channel, for compatibility
     c_TRIGGER_SW_CLK_ID     => (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     -- Unused channel, for compatibility
     c_PHASE_SYNC_TRIGGER_SLOW_ID =>
                                (width => c_ACQ_WIDTH_U128, num_atoms => c_ACQ_NUM_ATOMS_U4, atom_width => c_ACQ_ATOM_WIDTH_U32),
     c_ACQ_DCC_ID            => c_FACQ_PARAMS_DCC
  );

  signal acq_chan_array                      : t_facq_chan_array2d(c_ACQ_NUM_CORES-1 downto 0, c_ACQ_NUM_CHANNELS-1 downto 0);

  -- Acquisition clocks
  -- ADC clock
  signal fs1_clk                             : std_logic;
  signal fs1_clk2x                           : std_logic;
  signal fs_ref_clk                          : std_logic;
  signal fs_ref_clk2x                        : std_logic;
  signal fs2_clk                             : std_logic;
  signal fs2_clk2x                           : std_logic;
  signal fs1_rstn                            : std_logic;
  signal fs1_rst2xn                          : std_logic;
  signal fs_ref_rstn                         : std_logic;
  signal fs_ref_rst                          : std_logic;
  signal fs_ref_rst2xn                       : std_logic;
  signal fs2_rstn                            : std_logic;
  signal fs2_rst2xn                          : std_logic;
  signal fs_rstn_dbg                         : std_logic;
  signal fs_rst2xn_dbg                       : std_logic;
  signal fs_clk_dbg                          : std_logic;
  signal fs_clk2x_dbg                        : std_logic;
  signal fs_clk_array                        : std_logic_vector(c_ACQ_NUM_CORES-1 downto 0);
  signal fs_rst_n_array                      : std_logic_vector(c_ACQ_NUM_CORES-1 downto 0);
  signal fs_rst_array                        : std_logic_vector(c_ACQ_NUM_CORES-1 downto 0);
  signal fs_ce_array                         : std_logic_vector(c_ACQ_NUM_CORES-1 downto 0);

  -----------------------------------------------------------------------------
  -- Trigger signals
  -----------------------------------------------------------------------------

  -- Trigger core IDs
  constant c_TRIG_MUX_SYNC_EDGE              : string   := "positive";

  constant c_TRIG_MUX_NUM_CHANNELS           : natural  := 3;

  constant c_TRIG_MUX_INTERN_NUM             : positive := c_TRIG_MUX_NUM_CHANNELS + c_ACQ_NUM_CHANNELS;
  constant c_TRIG_MUX_OUT_RESOLVER           : string   := "fanout";
  constant c_TRIG_MUX_IN_RESOLVER            : string   := "or";
  constant c_TRIG_MUX_WITH_INPUT_SYNC        : boolean  := true;
  constant c_TRIG_MUX_WITH_OUTPUT_SYNC       : boolean  := true;

  -- Trigger RCV intern IDs
  constant c_TRIG_RCV_INTERN_CHAN_1_ID       : natural := 0; -- Internal Channel 1
  constant c_TRIG_RCV_INTERN_CHAN_2_ID       : natural := 1; -- Internal Channel 2
  constant c_TRIG_RCV_INTERN_CHAN_INTLK_ID   : natural := 2; -- Internal Channel 3, Interlock
  constant c_TRIG_MUX_RCV_INTERN_NUM         : positive := 3; -- 2 FMCs + 1 Interlock

  -- Trigger core IDs
  constant c_TRIG_MUX_0_ID                   : natural := 0;
  constant c_TRIG_MUX_1_ID                   : natural := 1;
  constant c_TRIG_MUX_2_ID                   : natural := 2;
  constant c_TRIG_MUX_3_ID                   : natural := 3;
  constant c_TRIG_MUX_NUM_CORES              : natural := c_ACQ_NUM_CORES;

  signal trig_rcv_intern                     : t_trig_channel_array2d(c_TRIG_MUX_NUM_CORES-1 downto 0, c_TRIG_MUX_RCV_INTERN_NUM-1 downto 0);
  signal trig_pulse_transm                   : t_trig_channel_array2d(c_TRIG_MUX_NUM_CORES-1 downto 0, c_TRIG_MUX_INTERN_NUM-1 downto 0);
  signal trig_pulse_rcv                      : t_trig_channel_array2d(c_TRIG_MUX_NUM_CORES-1 downto 0, c_TRIG_MUX_INTERN_NUM-1 downto 0);

  signal trig_fmc1_channel_1                 : t_trig_channel;
  signal trig_fmc1_channel_2                 : t_trig_channel;
  signal trig_fmc2_channel_1                 : t_trig_channel;
  signal trig_fmc2_channel_2                 : t_trig_channel;
  signal trig_1_channel_intlk                : t_trig_channel;
  signal trig_2_channel_intlk                : t_trig_channel;

  -- Post-Mortem triggers
  signal trig_fmc1_pm_channel_1              : t_trig_channel;
  signal trig_fmc1_pm_channel_2              : t_trig_channel;
  signal trig_fmc2_pm_channel_1              : t_trig_channel;
  signal trig_fmc2_pm_channel_2              : t_trig_channel;
  signal trig_1_pm_channel_intlk             : t_trig_channel;
  signal trig_2_pm_channel_intlk             : t_trig_channel;

  -----------------------------------------------------------------------------
  -- User Signals
  -----------------------------------------------------------------------------

  constant c_WITH_RTM_SFP_FOFB_DCC           : boolean := g_WITH_RTM_SFP_FOFB_DCC;
  constant c_WITH_P2P_FOFB_DCC               : boolean := g_WITH_P2P_FOFB_DCC or
                                                            c_WITH_RTM_SFP_FOFB_DCC;

  -- FMC_ADC_1, FMC_ADC_2,
  -- Position_calc_1, Posiotion_calc_2,
  -- Orbit Interlock
  constant c_SLV_POS_CALC_1_ID               : natural := 0;
  constant c_SLV_FMC_ADC_1_ID                : natural := 1;
  constant c_SLV_POS_CALC_2_ID               : natural := 2;
  constant c_SLV_FMC_ADC_2_ID                : natural := 3;
  constant c_SLV_ORBIT_INTLK_ID              : natural := 4;

  constant c_SLV_FOFB_START                  : natural := 5;
  constant c_SLV_FOFB_CC_CORE_IDS           : t_num_array(c_NUM_FOFB_CC_CORES-1 downto 0) :=
    f_gen_ramp(c_SLV_FOFB_START, c_SLV_FOFB_START+c_NUM_FOFB_CC_CORES);

  -- Because VHDL doesn't like non-globally static things...
  --constant c_SLV_FOFB_CC_P2P_ID              : natural := c_SLV_FOFB_CC_CORE_IDS(c_FOFB_CC_P2P_ID);
  --constant c_SLV_FOFB_CC_RTM_ID              : natural := c_SLV_FOFB_CC_CORE_IDS(c_FOFB_CC_RTM_ID);
  constant c_SLV_FOFB_CC_P2P_ID              : natural := 5;
  constant c_SLV_FOFB_CC_RTM_ID              : natural := 6;

  constant c_USER_NUM_CORES                  : natural := 7;

  -- FMC_ADC layout. Size (0x00000FFF) is larger than needed. Just to be sure
  -- no address overlaps will occur
  constant c_FMC_ADC_BRIDGE_SDB : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"0000FFFF", x"00006000");

  -- Position CAlC. layout. Regs, SWAP
  constant c_POS_CALC_CORE_BRIDGE_SDB : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000600");

  constant c_USER_SDB_RECORD_ARRAY           : t_sdb_record_array(c_USER_NUM_CORES-1 downto 0) :=
  (
    c_SLV_POS_CALC_1_ID             => f_sdb_auto_bridge(c_POS_CALC_CORE_BRIDGE_SDB,  true),
    c_SLV_FMC_ADC_1_ID              => f_sdb_auto_bridge(c_FMC_ADC_BRIDGE_SDB,        true),
    c_SLV_POS_CALC_2_ID             => f_sdb_auto_bridge(c_POS_CALC_CORE_BRIDGE_SDB,  true),
    c_SLV_FMC_ADC_2_ID              => f_sdb_auto_bridge(c_FMC_ADC_BRIDGE_SDB,        true),
    c_SLV_ORBIT_INTLK_ID            => f_sdb_auto_device(c_XWB_ORBIT_INTLK_SDB,       true),
    c_SLV_FOFB_CC_P2P_ID            => f_sdb_auto_device(c_XWB_FOFB_CC_REGS_SDB,      c_WITH_P2P_FOFB_DCC),
    c_SLV_FOFB_CC_RTM_ID            => f_sdb_auto_device(c_XWB_FOFB_CC_REGS_SDB,      c_WITH_RTM_SFP_FOFB_DCC)
  );

  signal clk_sys                             : std_logic;
  signal clk_sys_rstn                        : std_logic;
  signal clk_sys_rst                         : std_logic;
  signal clk_aux                             : std_logic;
  signal clk_aux_rstn                        : std_logic;
  signal clk_aux_rst                         : std_logic;
  signal clk_aux_raw                         : std_logic;
  signal clk_aux_raw_rstn                    : std_logic;
  signal clk_aux_raw_rst                     : std_logic;
  signal clk_fp2_clk1_p                      : std_logic;
  signal clk_fp2_clk1_n                      : std_logic;
  signal clk_200mhz                          : std_logic;
  signal clk_200mhz_rstn                     : std_logic;
  signal clk_300mhz                          : std_logic;
  signal clk_300mhz_rstn                     : std_logic;
  signal clk_master                          : std_logic;
  signal clk_master_rstn                     : std_logic;
  signal clk_pcie                            : std_logic;
  signal clk_pcie_rstn                       : std_logic;
  signal clk_trig_ref                        : std_logic;
  signal clk_trig_ref_rstn                   : std_logic;

  signal pcb_rev_id                          : std_logic_vector(3 downto 0);

  signal irq_user                            : std_logic_vector(c_NUM_USER_IRQ + 5 downto 6) := (others => '0');

  signal trig_out                            : t_trig_channel_array(c_NUM_TRIG-1 downto 0);
  signal trig_in                             : t_trig_channel_array(c_NUM_TRIG-1 downto 0) := (others => c_TRIG_CHANNEL_DUMMY);

  signal trig_dbg                            : std_logic_vector(c_NUM_TRIG-1 downto 0);
  signal trig_dbg_data_sync                  : std_logic_vector(c_NUM_TRIG-1 downto 0);
  signal trig_dbg_data_degliteched           : std_logic_vector(c_NUM_TRIG-1 downto 0);

  signal user_wb_out                         : t_wishbone_master_out_array(c_USER_NUM_CORES-1 downto 0);
  signal user_wb_in                          : t_wishbone_master_in_array(c_USER_NUM_CORES-1 downto 0) := (others => c_DUMMY_WB_MASTER_IN);

  -----------------------------------------------------------------------------
  -- DSP Signals
  -----------------------------------------------------------------------------

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

  -- FMC_ADC 2 Signals
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
  signal dsp1_adc_tag                        : std_logic_vector(0 downto 0);
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

  signal dsp1_monit1_amp_ch0                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit1_amp_ch1                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit1_amp_ch2                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit1_amp_ch3                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit1_amp_valid               : std_logic;

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

  signal dsp1_monit1_pos_x                   : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit1_pos_y                   : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit1_pos_q                   : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit1_pos_sum                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp1_monit1_pos_valid               : std_logic;

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
  signal dsp2_adc_tag                        : std_logic_vector(0 downto 0);
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

  signal dsp2_monit1_amp_ch0                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit1_amp_ch1                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit1_amp_ch2                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit1_amp_ch3                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit1_amp_valid               : std_logic;

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

  signal dsp2_monit1_pos_x                   : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit1_pos_y                   : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit1_pos_q                   : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit1_pos_sum                 : std_logic_vector(c_pos_calc_monit_decim_width-1 downto 0);
  signal dsp2_monit1_pos_valid               : std_logic;

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

  -- DSP DCC signal

  subtype t_pos_calc_fofb_data is std_logic_vector(c_pos_calc_fofb_decim_width-1 downto 0);
  type t_pos_calc_fofb_data_array is array(natural range <>) of t_pos_calc_fofb_data;

  signal dsp1_fofb_pos_xy_in_fifo            : t_pos_calc_fofb_data_array(c_BPMS-1 downto 0);
  signal dsp1_fofb_pos_valid_in_fifo         : std_logic;
  signal dsp1_fofb_pos_xy_out_fifo_slv       : std_logic_vector(c_BPMS*t_pos_calc_fofb_data'length-1 downto 0);
  signal dsp1_fofb_pos_xy_out_fifo           : t_pos_calc_fofb_data_array(c_BPMS-1 downto 0);
  signal dsp1_fofb_pos_x_out_fifo            : t_pos_calc_fofb_data;
  signal dsp1_fofb_pos_y_out_fifo            : t_pos_calc_fofb_data;
  signal dsp1_fofb_pos_valid_out_fifo        : std_logic;

  signal dsp2_fofb_pos_xy_in_fifo            : t_pos_calc_fofb_data_array(c_BPMS-1 downto 0);
  signal dsp2_fofb_pos_valid_in_fifo         : std_logic;
  signal dsp2_fofb_pos_xy_out_fifo_slv       : std_logic_vector(c_BPMS*t_pos_calc_fofb_data'length-1 downto 0);
  signal dsp2_fofb_pos_xy_out_fifo           : t_pos_calc_fofb_data_array(c_BPMS-1 downto 0);
  signal dsp2_fofb_pos_x_out_fifo            : t_pos_calc_fofb_data;
  signal dsp2_fofb_pos_y_out_fifo            : t_pos_calc_fofb_data;
  signal dsp2_fofb_pos_valid_out_fifo        : std_logic;

  signal dsp_fofb_pos_fifo_rden              : std_logic;
  signal dsp_fofb_pos_rstn                   : std_logic;
  signal dsp_fofb_pos_enable_bpm_data        : std_logic;

  -- Interlock signals
  signal intlk_ltc                          : std_logic;
  signal intlk                              : std_logic;

  function f_to_slv(fofb_array : t_pos_calc_fofb_data_array) return std_logic_vector is
    constant c_FOFB_ARRAY_ELEM_LENGTH : natural := fofb_array(0)'length;
    variable ret : std_logic_vector((fofb_array'length * c_FOFB_ARRAY_ELEM_LENGTH) - 1 downto 0);
  begin
    for i in fofb_array'range loop
      ret((i+1)*c_FOFB_ARRAY_ELEM_LENGTH-1 downto (i*c_FOFB_ARRAY_ELEM_LENGTH)) :=
        fofb_array(i);
    end loop;

    return ret;
  end function;

  function f_to_fofb_array(fofb_slv : std_logic_vector) return t_pos_calc_fofb_data_array is
    constant c_FOFB_SLV_LENGTH : natural := fofb_slv'length;
    constant c_FOFB_ARRAY_LENGTH : natural := (c_FOFB_SLV_LENGTH + t_pos_calc_fofb_data'length -1)/t_pos_calc_fofb_data'length;
    variable ret : t_pos_calc_fofb_data_array(c_FOFB_ARRAY_LENGTH-1 downto 0);
  begin
    for i in ret'range loop
      ret(i) := fofb_slv((i+1)*t_pos_calc_fofb_data'length-1 downto (i*t_pos_calc_fofb_data'length));
    end loop;

    return ret;
  end function;

begin

  cmp_afc_base_acq : afc_base_acq
    generic map (
      g_DIVCLK_DIVIDE                          => 1,
      g_CLKBOUT_MULT_F                         => 8,
      g_CLK0_DIVIDE_F                          => 8, -- 100 MHz
      g_CLK1_DIVIDE                            => 5, -- Must be 200 MHz
      g_SYS_CLOCK_FREQ                         => c_SYS_CLOCK_FREQ,
      -- AFC Si57x parameters
      g_AFC_SI57x_I2C_FREQ                     => c_AFC_SI57x_I2C_FREQ,
      -- Whether or not to initialize oscilator with the specified values
      g_AFC_SI57x_INIT_OSC                     => c_AFC_SI57x_INIT_OSC,
      -- Init Oscillator values
      g_AFC_SI57x_INIT_RFREQ_VALUE             => c_AFC_SI57x_INIT_RFREQ_VALUE,
      g_AFC_SI57x_INIT_N1_VALUE                => c_AFC_SI57x_INIT_N1_VALUE,
      g_AFC_SI57x_INIT_HS_VALUE                => c_AFC_SI57x_INIT_HS_VALUE,
      --  If true, instantiate a VIC/UART/DIAG/SPI.
      g_WITH_VIC                               => true,
      g_WITH_UART_MASTER                       => true,
      g_WITH_DIAG                              => true,
      g_WITH_TRIGGER                           => true,
      g_WITH_SPI                               => false,
      g_WITH_AFC_SI57x                         => true,
      g_WITH_BOARD_I2C                         => true,
      g_ACQ_NUM_CORES                          => c_ACQ_NUM_CORES,
      g_TRIG_MUX_NUM_CORES                     => c_TRIG_MUX_NUM_CORES,
      g_USER_NUM_CORES                         => c_USER_NUM_CORES,
      -- Acquisition module generics
      g_ACQ_NUM_CHANNELS                       => c_ACQ_NUM_CHANNELS,
      g_ACQ_MULTISHOT_RAM_SIZE                 => c_ACQ_MULTISHOT_RAM_SIZE,
      g_ACQ_FIFO_FC_SIZE                       => c_ACQ_FIFO_SIZE,
      g_FACQ_CHANNELS                          => c_FACQ_CHANNELS,
      -- Trigger Mux generic
      g_TRIG_MUX_SYNC_EDGE                     => c_TRIG_MUX_SYNC_EDGE,
      g_TRIG_MUX_INTERN_NUM                    => c_TRIG_MUX_INTERN_NUM,
      g_TRIG_MUX_RCV_INTERN_NUM                => c_TRIG_MUX_RCV_INTERN_NUM,
      g_TRIG_MUX_OUT_RESOLVER                  => c_TRIG_MUX_OUT_RESOLVER,
      g_TRIG_MUX_IN_RESOLVER                   => c_TRIG_MUX_IN_RESOLVER,
      g_TRIG_MUX_WITH_INPUT_SYNC               => c_TRIG_MUX_WITH_INPUT_SYNC,
      g_TRIG_MUX_WITH_OUTPUT_SYNC              => c_TRIG_MUX_WITH_OUTPUT_SYNC,
      -- User generic. Must be g_USER_NUM_CORES length
      g_USER_SDB_RECORD_ARRAY                  => c_USER_SDB_RECORD_ARRAY,
      -- Auxiliary clock used to sync incoming triggers in the trigger module.
      -- If false, trigger will be synch'ed with clk_sys
      g_WITH_AUX_CLK                           => true,
      -- Number of user interrupts
      g_NUM_USER_IRQ                           => c_NUM_USER_IRQ
    )
    port map (
      ---------------------------------------------------------------------------
      -- Clocking pins
      ---------------------------------------------------------------------------
      sys_clk_p_i                              => sys_clk_p_i,
      sys_clk_n_i                              => sys_clk_n_i,

      aux_clk_p_i                              => aux_clk_p_i,
      aux_clk_n_i                              => aux_clk_n_i,

      afc_fp2_clk1_p_i                         => afc_fp2_clk1_p_i,
      afc_fp2_clk1_n_i                         => afc_fp2_clk1_n_i,

      ---------------------------------------------------------------------------
      -- Reset Button
      ---------------------------------------------------------------------------
      sys_rst_button_n_i                       => sys_rst_button_n_i,

      ---------------------------------------------------------------------------
      -- UART pins
      ---------------------------------------------------------------------------

      uart_rxd_i                               => uart_rxd_i,
      uart_txd_o                               => uart_txd_o,

      ---------------------------------------------------------------------------
      -- Trigger pins
      ---------------------------------------------------------------------------
      trig_dir_o                               => trig_dir_o,
      trig_b                                   => trig_b,

      ---------------------------------------------------------------------------
      -- AFC Diagnostics
      ---------------------------------------------------------------------------

      diag_spi_cs_i                            => diag_spi_cs_i,
      diag_spi_si_i                            => diag_spi_si_i,
      diag_spi_so_o                            => diag_spi_so_o,
      diag_spi_clk_i                           => diag_spi_clk_i,

      ---------------------------------------------------------------------------
      -- ADN4604ASVZ
      ---------------------------------------------------------------------------
      adn4604_vadj2_clk_updt_n_o               => adn4604_vadj2_clk_updt_n_o,

      ---------------------------------------------------------------------------
      -- AFC I2C.
      ---------------------------------------------------------------------------
      -- Si57x oscillator
      afc_si57x_scl_b                          => afc_si57x_scl_b,
      afc_si57x_sda_b                          => afc_si57x_sda_b,

      -- Si57x oscillator output enable
      afc_si57x_oe_o                           => afc_si57x_oe_o,

      ---------------------------------------------------------------------------
      -- PCIe pins
      ---------------------------------------------------------------------------

      -- DDR3 memory pins
      ddr3_dq_b                                => ddr3_dq_b,
      ddr3_dqs_p_b                             => ddr3_dqs_p_b,
      ddr3_dqs_n_b                             => ddr3_dqs_n_b,
      ddr3_addr_o                              => ddr3_addr_o,
      ddr3_ba_o                                => ddr3_ba_o,
      ddr3_cs_n_o                              => ddr3_cs_n_o,
      ddr3_ras_n_o                             => ddr3_ras_n_o,
      ddr3_cas_n_o                             => ddr3_cas_n_o,
      ddr3_we_n_o                              => ddr3_we_n_o,
      ddr3_reset_n_o                           => ddr3_reset_n_o,
      ddr3_ck_p_o                              => ddr3_ck_p_o,
      ddr3_ck_n_o                              => ddr3_ck_n_o,
      ddr3_cke_o                               => ddr3_cke_o,
      ddr3_dm_o                                => ddr3_dm_o,
      ddr3_odt_o                               => ddr3_odt_o,

      -- PCIe transceivers
      pci_exp_rxp_i                            => pci_exp_rxp_i,
      pci_exp_rxn_i                            => pci_exp_rxn_i,
      pci_exp_txp_o                            => pci_exp_txp_o,
      pci_exp_txn_o                            => pci_exp_txn_o,

      -- PCI clock and reset signals
      pcie_clk_p_i                             => pcie_clk_p_i,
      pcie_clk_n_i                             => pcie_clk_n_i,

      ---------------------------------------------------------------------------
      -- User LEDs
      ---------------------------------------------------------------------------
      leds_o                                   => leds_o,

      ---------------------------------------------------------------------------
      -- FMC interface
      ---------------------------------------------------------------------------

      board_i2c_scl_b                          => board_i2c_scl_b,
      board_i2c_sda_b                          => board_i2c_sda_b,

      ---------------------------------------------------------------------------
      -- Flash memory SPI interface
      ---------------------------------------------------------------------------
     --
     -- spi_sclk_o                               => spi_sclk_o,
     -- spi_cs_n_o                               => spi_cs_n_o,
     -- spi_mosi_o                               => spi_mosi_o,
     -- spi_miso_i                               => spi_miso_i,
     --
      ---------------------------------------------------------------------------
      -- Miscellanous AFC pins
      ---------------------------------------------------------------------------

      -- PCB version
      pcb_rev_id_i                             => pcb_rev_id,

      ---------------------------------------------------------------------------
      --  User part
      ---------------------------------------------------------------------------

      --  Clocks and reset.
      clk_sys_o                                => clk_sys,
      rst_sys_n_o                              => clk_sys_rstn,

      clk_aux_o                                => clk_aux,
      rst_aux_n_o                              => clk_aux_rstn,

      clk_aux_raw_o                            => clk_aux_raw,
      rst_aux_raw_n_o                          => clk_aux_raw_rstn,

      clk_200mhz_o                             => clk_200mhz,
      rst_200mhz_n_o                           => clk_200mhz_rstn,

      clk_pcie_o                               => clk_pcie,
      rst_pcie_n_o                             => clk_pcie_rstn,

      clk_300mhz_o                             => clk_300mhz,
      rst_300mhz_n_o                           => clk_300mhz_rstn,

      clk_trig_ref_o                           => clk_trig_ref,
      rst_trig_ref_n_o                         => clk_trig_ref_rstn,

      clk_fp2_clk1_p_o                         => clk_fp2_clk1_p,
      clk_fp2_clk1_n_o                         => clk_fp2_clk1_n,

      --  Interrupts
      irq_user_i                               => irq_user,

      -- Acquisition
      fs_clk_array_i                           => fs_clk_array,
      fs_ce_array_i                            => fs_ce_array,
      fs_rst_n_array_i                         => fs_rst_n_array,

      acq_chan_array_i                         => acq_chan_array,

      -- Triggers                                 -- Triggers
      trig_rcv_intern_i                        => trig_rcv_intern,
      trig_pulse_transm_i                      => trig_pulse_transm,
      trig_pulse_rcv_o                         => trig_pulse_rcv,

      trig_dbg_o                               => trig_dbg,
      trig_dbg_data_sync_o                     => trig_dbg_data_sync,
      trig_dbg_data_degliteched_o              => trig_dbg_data_degliteched,

      -- AFC Si57x
      afc_si57x_ext_wr_i                       => afc_si57x_ext_wr,
      afc_si57x_ext_rfreq_value_i              => afc_si57x_ext_rfreq_value,
      afc_si57x_ext_n1_value_i                 => afc_si57x_ext_n1_value,
      afc_si57x_ext_hs_value_i                 => afc_si57x_ext_hs_value,
      afc_si57x_sta_reconfig_done_o            => afc_si57x_sta_reconfig_done,

      afc_si57x_oe_i                           => '1',
      afc_si57x_addr_i                         => "10101010",

      --  The wishbone bus from the pcie/host to the application
      --  LSB addresses are not available (used by the carrier).
      --  For the exact used addresses see SDB Description.
      --  This is a pipelined wishbone with byte granularity.
      user_wb_o                                 => user_wb_out,
      user_wb_i                                 => user_wb_in
    );

  pcb_rev_id <= (others => '0');
  clk_aux_rst <= not clk_aux_rstn;
  clk_aux_raw_rst <= not clk_aux_raw_rstn;

  ----------------------------------------------------------------------
  --                          AFC Si57x                               --
  ----------------------------------------------------------------------

  -- Generate large pulse for reset
  cmp_afc_si57x_gc_posedge : gc_posedge
  port map (
    clk_i                                      => clk_sys,
    rst_n_i                                    => clk_sys_rstn,
    data_i                                     => afc_si57x_sta_reconfig_done,
    pulse_o                                    => afc_si57x_sta_reconfig_done_pp
  );

  cmp_afc_si57x_gc_extend_pulse : gc_extend_pulse
  generic map (
    g_width                                    => 50000
  )
  port map (
    clk_i                                      => clk_sys,
    rst_n_i                                    => clk_sys_rstn,
    pulse_i                                    => afc_si57x_sta_reconfig_done_pp,
    extended_o                                 => afc_si57x_reconfig_rst
  );

  afc_si57x_reconfig_rst_n <= not afc_si57x_reconfig_rst;

  ----------------------------------------------------------------------
  --                      FMC ADCs                                    --
  ----------------------------------------------------------------------

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
      g_ref_clk                               => c_ADC_REF_CLK,
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
      wb_slv_i                                => user_wb_out(c_SLV_FMC_ADC_1_ID),
      wb_slv_o                                => user_wb_in(c_SLV_FMC_ADC_1_ID),

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

    fs1_clk                                    <= fmc1_clk(c_ADC_REF_CLK);
    fs1_rstn                                   <= fmc1_rst_n(c_ADC_REF_CLK);
    fs1_clk2x                                  <= fmc1_clk2x(c_ADC_REF_CLK);
    fs1_rst2xn                                 <= fmc1_rst2x_n(c_ADC_REF_CLK);

    -- Use ADC trigger for testing
    fmc1_trig_hw_in                            <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_TRIGGER_SW_CLK_ID).pulse;

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
      g_ref_clk                               => c_ADC_REF_CLK,
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
      wb_slv_i                                => user_wb_out(c_SLV_FMC_ADC_2_ID),
      wb_slv_o                                => user_wb_in(c_SLV_FMC_ADC_2_ID),

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

    fs2_clk                                    <= fmc2_clk(c_ADC_REF_CLK);
    fs2_rstn                                   <= fmc2_rst_n(c_ADC_REF_CLK);
    fs2_clk2x                                  <= fmc2_clk2x(c_ADC_REF_CLK);
    fs2_rst2xn                                 <= fmc2_rst2x_n(c_ADC_REF_CLK);

    -- Use ADC trigger for testing
    fmc2_trig_hw_in                            <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_TRIGGER_SW_CLK_ID).pulse;

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
      g_ref_clk                               => c_ADC_REF_CLK,
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
      wb_slv_i                                => user_wb_out(c_SLV_FMC_ADC_1_ID),
      wb_slv_o                                => user_wb_in(c_SLV_FMC_ADC_1_ID),

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

    fs1_clk                                    <= fmc1_clk(c_ADC_REF_CLK);
    fs1_rstn                                   <= fmc1_rst_n(c_ADC_REF_CLK);
    fs1_clk2x                                  <= fmc1_clk2x(c_ADC_REF_CLK);
    fs1_rst2xn                                 <= fmc1_rst2x_n(c_ADC_REF_CLK);

    -- Use ADC trigger for testing
    fmc1_trig_hw_in                            <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_TRIGGER_SW_CLK_ID).pulse;

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
      g_ref_clk                               => c_ADC_REF_CLK,
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
      wb_slv_i                                => user_wb_out(c_SLV_FMC_ADC_2_ID),
      wb_slv_o                                => user_wb_in(c_SLV_FMC_ADC_2_ID),

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

    fs2_clk                                    <= fmc2_clk(c_ADC_REF_CLK);
    fs2_rstn                                   <= fmc2_rst_n(c_ADC_REF_CLK);
    fs2_clk2x                                  <= fmc2_clk2x(c_ADC_REF_CLK);
    fs2_rst2xn                                 <= fmc2_rst2x_n(c_ADC_REF_CLK);

    -- Use ADC trigger for testing
    fmc2_trig_hw_in                            <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_TRIGGER_SW_CLK_ID).pulse;

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
      wb_slv_i                                => user_wb_out(c_SLV_FMC_ADC_1_ID),
      wb_slv_o                                => user_wb_in(c_SLV_FMC_ADC_1_ID),

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

    fs1_clk                                    <= fmc1_clk(c_ADC_REF_CLK);
    fs1_clk2x                                  <= fmc1_clk2x(c_ADC_REF_CLK);
    fs1_rstn                                   <= fmc1_rst_n(c_ADC_REF_CLK);
    fs1_rst2xn                                 <= fmc1_rst2x_n(c_ADC_REF_CLK);

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
      wb_slv_i                                => user_wb_out(c_SLV_FMC_ADC_2_ID),
      wb_slv_o                                => user_wb_in(c_SLV_FMC_ADC_2_ID),

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

    fs2_clk                                    <= fmc2_clk(c_ADC_REF_CLK);
    fs2_clk2x                                  <= fmc2_clk2x(c_ADC_REF_CLK);
    fs2_rstn                                   <= fmc2_rst_n(c_ADC_REF_CLK);
    fs2_rst2xn                                 <= fmc2_rst2x_n(c_ADC_REF_CLK);

    ---- Connected through FPGA MUX
    ---- Temporary assignemnts
    --fmcpico_2_sm_scl_o                         <= '0';
    --fmcpico_2_a_scl_o                          <= '0';

  end generate;

  -- Reference FMC ADC clock
  fs_ref_clk <= fs1_clk;
  fs_ref_clk2x <= fs1_clk2x;
  fs_ref_rstn <= fs1_rstn;
  fs_ref_rst2xn <= fs1_rst2xn;

  fs_ref_rst <= not fs_ref_rstn;

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

    -- width of offset constants
    g_offset_width                          => c_pos_calc_offset_width,

    --width for IQ output
    g_IQ_width                              => c_pos_calc_IQ_width,

    -- Swap/de-swap setup
    g_delay_vec_width                       => c_POS_CALC_DELAY_VEC_WIDTH,
    g_swap_div_freq_vec_width               => c_POS_CALC_SWAP_DIV_FREQ_VEC_WIDTH
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
    wb_slv_i                                => user_wb_out(c_SLV_POS_CALC_1_ID),
    wb_slv_o                                => user_wb_in(c_SLV_POS_CALC_1_ID),

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
    adc_tag_o                               => dsp1_adc_tag,
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

    monit1_amp_ch0_o                        => dsp1_monit1_amp_ch0,
    monit1_amp_ch1_o                        => dsp1_monit1_amp_ch1,
    monit1_amp_ch2_o                        => dsp1_monit1_amp_ch2,
    monit1_amp_ch3_o                        => dsp1_monit1_amp_ch3,
    monit1_amp_valid_o                      => dsp1_monit1_amp_valid,

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

    monit1_pos_x_o                          => dsp1_monit1_pos_x,
    monit1_pos_y_o                          => dsp1_monit1_pos_y,
    monit1_pos_q_o                          => dsp1_monit1_pos_q,
    monit1_pos_sum_o                        => dsp1_monit1_pos_sum,
    monit1_pos_valid_o                      => dsp1_monit1_pos_valid,

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
    -- Synchronization trigger for all rates. Slow clock
    -----------------------------

    sync_trig_slow_i                        => trig_pulse_rcv(c_TRIG_MUX_0_ID, c_PHASE_SYNC_TRIGGER_SLOW_ID).pulse,

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

    -- width of offset constants
    g_offset_width                          => c_pos_calc_offset_width,

    --width for IQ output
    g_IQ_width                              => c_pos_calc_IQ_width,

    -- Swap/de-swap setup
    g_delay_vec_width                       => c_POS_CALC_DELAY_VEC_WIDTH,
    g_swap_div_freq_vec_width               => c_POS_CALC_SWAP_DIV_FREQ_VEC_WIDTH
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
    wb_slv_i                                => user_wb_out(c_SLV_POS_CALC_2_ID),
    wb_slv_o                                => user_wb_in(c_SLV_POS_CALC_2_ID),

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
    adc_tag_o                               => dsp2_adc_tag,
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

    monit1_amp_ch0_o                        => dsp2_monit1_amp_ch0,
    monit1_amp_ch1_o                        => dsp2_monit1_amp_ch1,
    monit1_amp_ch2_o                        => dsp2_monit1_amp_ch2,
    monit1_amp_ch3_o                        => dsp2_monit1_amp_ch3,
    monit1_amp_valid_o                      => dsp2_monit1_amp_valid,

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

    monit1_pos_x_o                          => dsp2_monit1_pos_x,
    monit1_pos_y_o                          => dsp2_monit1_pos_y,
    monit1_pos_q_o                          => dsp2_monit1_pos_q,
    monit1_pos_sum_o                        => dsp2_monit1_pos_sum,
    monit1_pos_valid_o                      => dsp2_monit1_pos_valid,

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
    -- Synchronization trigger for all rates. Slow clock
    -----------------------------

    sync_trig_slow_i                        => trig_pulse_rcv(c_TRIG_MUX_1_ID, c_PHASE_SYNC_TRIGGER_SLOW_ID).pulse,

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
  --                          RTM 8SFP OHWR                           --
  ----------------------------------------------------------------------

  gen_fix_inv_sfps: for i in 0 to c_NUM_SFPS_FOFB-1 generate

    rtm_sfp_fix_rx_p(c_NUM_SFPS_FOFB-1-i)  <= rtm_sfp_rx_p_i(g_SFP_START_ID+i);
    rtm_sfp_fix_rx_n(c_NUM_SFPS_FOFB-1-i)  <= rtm_sfp_rx_n_i(g_SFP_START_ID+i);
    rtm_sfp_tx_p_o(g_SFP_START_ID+i) <= rtm_sfp_fix_tx_p(c_NUM_SFPS_FOFB-1-i);
    rtm_sfp_tx_n_o(g_SFP_START_ID+i) <= rtm_sfp_fix_tx_n(c_NUM_SFPS_FOFB-1-i);

  end generate;

  gen_with_rtm_8sfp : if g_WITH_RTM_SFP generate

    cmp_rtm8sfp_ohwr : rtm8sfp_ohwr
    generic map (
      g_NUM_SFPS                                 => c_NUM_SFPS_FOFB,
      g_SYS_CLOCK_FREQ                           => c_SYS_CLOCK_FREQ,
      g_SI57x_I2C_FREQ                           => c_RTM_SI57x_I2C_FREQ,
      -- Whether or not to initialize oscilator with the specified values
      g_SI57x_INIT_OSC                           => c_RTM_SI57x_INIT_OSC,
      -- Init Oscillator values
      g_SI57x_INIT_RFREQ_VALUE                   => c_RTM_SI57x_INIT_RFREQ_VALUE,
      g_SI57x_INIT_N1_VALUE                      => c_RTM_SI57x_INIT_N1_VALUE,
      g_SI57x_INIT_HS_VALUE                      => c_RTM_SI57x_INIT_HS_VALUE
    )
    port map (
      ---------------------------------------------------------------------------
      -- clock and reset interface
      ---------------------------------------------------------------------------
      clk_sys_i                                  => clk_sys,
      rst_n_i                                    => clk_sys_rstn,

      ---------------------------------------------------------------------------
      -- RTM board pins
      ---------------------------------------------------------------------------
      -- SFP
      sfp_rx_p_i                                 => rtm_sfp_fix_rx_p,
      sfp_rx_n_i                                 => rtm_sfp_fix_rx_n,
      sfp_tx_p_o                                 => rtm_sfp_fix_tx_p,
      sfp_tx_n_o                                 => rtm_sfp_fix_tx_n,

      -- RTM I2C.
      -- SFP configuration pins, behind a I2C MAX7356. I2C addr = 1110_100 & '0' = 0xE8
      -- Si570 oscillator. Input 0 of CDCLVD1212. I2C addr = 1010101 & '0' = 0x55
      rtm_scl_b                                  => rtm_scl_b,
      rtm_sda_b                                  => rtm_sda_b,

      -- Si570 oscillator output enable
      si570_oe_o                                 => rtm_si570_oe_o,

      ---- Clock to RTM connector. Input 1 of CDCLVD1212. Not connected to FPGA
      -- rtm_sync_clk_p_o                           => rtm_sync_clk_p_o,
      -- rtm_sync_clk_n_o                           => rtm_sync_clk_n_o,

      -- Select between input 0 or 1 or CDCLVD1212. 0 is Si570, 1 is RTM sync clock
      clk_in_sel_o                               => rtm_clk_in_sel_o,

      -- FPGA clocks from CDCLVD1212
      fpga_clk1_p_i                              => rtm_fpga_clk1_p_i,
      fpga_clk1_n_i                              => rtm_fpga_clk1_n_i,
      fpga_clk2_p_i                              => rtm_fpga_clk2_p_i,
      fpga_clk2_n_i                              => rtm_fpga_clk2_n_i,

      -- SFP status bits. Behind 4 74HC165, 8-parallel-in/serial-out. 4 x 8 bits.
      --
      -- Parallel load
      sfp_status_reg_pl_o                        => rtm_sfp_status_reg_pl_o,
      -- Clock N
      sfp_status_reg_clk_n_o                     => rtm_sfp_status_reg_clk_n_o,
      -- Serial output
      sfp_status_reg_out_i                       => rtm_sfp_status_reg_out_i,

      -- SFP control bits. Behind 4 74HC4094D, serial-in/8-parallel-out. 5 x 8 bits.
      --
      -- Strobe
      sfp_ctl_reg_str_n_o                        => rtm_sfp_ctl_str_n_o,
      -- Data input
      sfp_ctl_reg_din_n_o                        => rtm_sfp_ctl_din_n_o,
      -- Parallel output enable
      sfp_ctl_reg_oe_n_o                         => rtm_sfp_ctl_oe_n_o,

      -- External clock from RTM to FPGA
      ext_clk_p_i                                => rtm_ext_clk_p_i,
      ext_clk_n_i                                => rtm_ext_clk_n_i,

      ---------------------------------------------------------------------------
      -- Optional external RFFREQ interface
      ---------------------------------------------------------------------------
      ext_wr_i                                   => rtm_ext_wr,
      ext_rfreq_value_i                          => rtm_ext_rfreq_value,
      ext_n1_value_i                             => rtm_ext_n1_value,
      ext_hs_value_i                             => rtm_ext_hs_value,

      ---------------------------------------------------------------------------
      -- Status pins
      ---------------------------------------------------------------------------
      sta_reconfig_done_o                        => rtm_sta_reconfig_done,

      ---------------------------------------------------------------------------
      -- FPGA side
      ---------------------------------------------------------------------------
      sfp_txdisable_i                            => sfp_txdisable,
      sfp_rs0_i                                  => sfp_rs0,
      sfp_rs1_i                                  => sfp_rs1,

      sfp_led1_o                                 => sfp_led1,
      sfp_los_o                                  => sfp_los,
      sfp_txfault_o                              => sfp_txfault,
      sfp_detect_n_o                             => sfp_detect_n,

      fpga_sfp_rx_p_o                            => rtm_sfp_rx_p,
      fpga_sfp_rx_n_o                            => rtm_sfp_rx_n,
      fpga_sfp_tx_p_i                            => rtm_sfp_tx_p,
      fpga_sfp_tx_n_i                            => rtm_sfp_tx_n,

      fpga_si570_oe_i                            => '1',
      fpga_si57x_addr_i                          => "10101010",

      fpga_clk_in_sel_i                          => '0',

      fpga_clk1_p_o                              => rtm_clk1_p,
      fpga_clk1_n_o                              => rtm_clk1_n,
      fpga_clk2_p_o                              => rtm_clk2_p,
      fpga_clk2_n_o                              => rtm_clk2_n,

      fpga_ext_clk_p_o                           => rtm_ext_clk_p,
      fpga_ext_clk_n_o                           => rtm_ext_clk_n
    );

  end generate;

  gen_without_rtm_8sfp : if (not g_WITH_RTM_SFP) generate

    -- default assignmentes for unused pins
    rtm_si570_oe_o             <= '0';
    rtm_clk_in_sel_o           <= '0';
    rtm_sfp_status_reg_pl_o    <= '0';
    rtm_sfp_status_reg_clk_n_o <= '1';
    rtm_sfp_ctl_str_n_o        <= '1';
    rtm_sfp_ctl_din_n_o        <= '1';
    rtm_sfp_ctl_oe_n_o         <= '1';

  end generate;

  gen_fix_sfp_ctl_status: for i in 0 to 7 generate

    sfp_txdisable(i)      <=  sfp_fix_txdisable(7-i);
    sfp_rs0(i)            <=  sfp_fix_rs0(7-i);
    sfp_rs1(i)            <=  sfp_fix_rs1(7-i);

    sfp_fix_led1(7-i)         <=  sfp_led1(i);
    sfp_fix_los(7-i)          <=  sfp_los(i);
    sfp_fix_txfault(7-i)      <=  sfp_txfault(i);
    sfp_fix_detect_n(7-i)     <=  sfp_detect_n(i);

  end generate;

  -- Generate large pulse for reset
  cmp_gc_posedge : gc_posedge
  port map (
    clk_i                                      => clk_sys,
    rst_n_i                                    => clk_sys_rstn,
    data_i                                     => rtm_sta_reconfig_done,
    pulse_o                                    => rtm_sta_reconfig_done_pp
  );

  cmp_gc_extend_pulse : gc_extend_pulse
  generic map (
    g_width                                    => 50000
  )
  port map (
    clk_i                                      => clk_sys,
    rst_n_i                                    => clk_sys_rstn,
    pulse_i                                    => rtm_sta_reconfig_done_pp,
    extended_o                                 => rtm_reconfig_rst
  );

  rtm_reconfig_rst_n <= not rtm_reconfig_rst;

  ----------------------------------------------------------------------
  --                          FOFB DCC RTM                            --
  ----------------------------------------------------------------------

  gen_fofb_sfps: for i in 0 to c_NUM_SFPS_FOFB-1 generate

    -- assign SFPs if WITH_RTM_SFP is false will likely generate
    -- placer errors
    assert (g_WITH_RTM_SFP)
      report "[dbe_bpm_gen] g_WITH_RTM_SFP must be true to use rtm_sfp_rx/tx ports."
      severity Failure;

    -- RX lines
    fofb_rio_rx_p(c_FOFB_CC_RTM_ID)(i) <= rtm_sfp_rx_p(i);
    fofb_rio_rx_n(c_FOFB_CC_RTM_ID)(i) <= rtm_sfp_rx_n(i);

    -- TX lines
    rtm_sfp_tx_p(i) <= fofb_rio_tx_p(c_FOFB_CC_RTM_ID)(i);
    rtm_sfp_tx_n(i) <= fofb_rio_tx_n(c_FOFB_CC_RTM_ID)(i);

  end generate;

  -- Clocks. Use rtm_clk1_p as this goes to the same bank as SFP 0, 1, 2, 3
  -- transceivers
  fofb_ref_clk_p(c_FOFB_CC_RTM_ID) <= rtm_clk1_p;
  fofb_ref_clk_n(c_FOFB_CC_RTM_ID) <= rtm_clk1_n;

  -- if RTM_SFP_FOFB_DCC is selected, then WITH_RTM_SFP also needs to be selected
  assert ((c_WITH_RTM_SFP_FOFB_DCC and g_WITH_RTM_SFP) or
            (not c_WITH_RTM_SFP_FOFB_DCC and not g_WITH_RTM_SFP))
    report "[dbe_bpm_gen] if g_WITH_RTM_SFP_FOFB_DCC is selected then g_WITH_RTM_SFP must also be seletected"
    severity Failure;

  gen_with_rtm_sfp_fofb_dcc : if c_WITH_RTM_SFP_FOFB_DCC generate

    cmp_fofb_ctrl_wrapper_0 : xwb_fofb_ctrl_wrapper
    generic map
    (
      g_INTERFACE_MODE                          => PIPELINED,
      g_ADDRESS_GRANULARITY                     => BYTE,
      g_ID                                      => 0,
      g_DEVICE                                  => DISTRIBUTOR,
      g_PHYSICAL_INTERFACE                      => "SFP",
      g_REFCLK_INPUT                            => "REFCLK0",
      g_LANE_COUNT                              => c_NUM_SFPS_FOFB,
      g_USE_CHIPSCOPE                           => c_USE_CHIPSCOPE,
      -- Data from another DCC
      g_USE_EXT_CC_IF                           => true,
      -- BPM synthetic data
      g_SIM_BPM_DATA                            => false
    )
    port map
    (
      ---------------------------------------------------------------------------
      -- differential MGT/GTP clock inputs
      ---------------------------------------------------------------------------
      refclk_p_i                                 => fofb_ref_clk_p(c_FOFB_CC_RTM_ID),
      refclk_n_i                                 => fofb_ref_clk_n(c_FOFB_CC_RTM_ID),

      ---------------------------------------------------------------------------
      -- clock and reset interface
      ---------------------------------------------------------------------------
      adcclk_i                                   => fs_clk_array(c_FOFB_CC_RTM_ID),
      adcreset_i                                 => fs_rst_array(c_FOFB_CC_RTM_ID),
      sysclk_i                                   => clk_sys,
      sysreset_n_i                               => fofb_sysreset_n(c_FOFB_CC_RTM_ID),

      ---------------------------------------------------------------------------
      -- Wishbone Control Interface signals
      ---------------------------------------------------------------------------
      wb_slv_i                                   => user_wb_out(c_SLV_FOFB_CC_RTM_ID),
      wb_slv_o                                   => user_wb_in(c_SLV_FOFB_CC_RTM_ID),

      ---------------------------------------------------------------------------
      -- external CC interface for data from another DCC. Used
      -- when the other DCC is typically in a DISTRIBUTOR mode and
      -- the other one (using this inteface) is part of another DCC
      -- network that receives data from both externl GT links and
      -- DCC. Used when USE_EXT_CC_IF = true. Overrides USE_PARALLEL_FA_IF
      ---------------------------------------------------------------------------
      ext_cc_clk_i                               => fofb_userclk(c_FOFB_CC_P2P_ID),
      ext_cc_rst_n_i                             => fofb_userrst_n(c_FOFB_CC_P2P_ID),
      ext_cc_dat_i                               => fofb_fod_dat(c_FOFB_CC_P2P_ID),
      ext_cc_dat_val_i                           => fofb_fod_dat_val(c_FOFB_CC_P2P_ID)(0),

      ---------------------------------------------------------------------------
      -- serial I/Os for eight RocketIOs on the Libera
      ---------------------------------------------------------------------------
      fai_rio_rdp_i                              => fofb_rio_rx_p(c_FOFB_CC_RTM_ID)(c_NUM_SFPS_FOFB-1 downto 0),
      fai_rio_rdn_i                              => fofb_rio_rx_n(c_FOFB_CC_RTM_ID)(c_NUM_SFPS_FOFB-1 downto 0),
      fai_rio_tdp_o                              => fofb_rio_tx_p(c_FOFB_CC_RTM_ID)(c_NUM_SFPS_FOFB-1 downto 0),
      fai_rio_tdn_o                              => fofb_rio_tx_n(c_FOFB_CC_RTM_ID)(c_NUM_SFPS_FOFB-1 downto 0),
      fai_rio_tdis_o                             => fofb_rio_tx_disable(c_FOFB_CC_RTM_ID)(c_NUM_SFPS_FOFB-1 downto 0),

      ---------------------------------------------------------------------------
      -- Higher-level integration interface (PMC, SNIFFER_V5)
      ---------------------------------------------------------------------------
      fofb_userclk_o                             => fofb_userclk(c_FOFB_CC_RTM_ID),
      fofb_userrst_o                             => fofb_userrst(c_FOFB_CC_RTM_ID),
      timeframe_start_o                          => timeframe_start(c_FOFB_CC_RTM_ID),
      timeframe_end_o                            => timeframe_end(c_FOFB_CC_RTM_ID),
      fofb_dma_ok_i                              => fofb_dma_ok(c_FOFB_CC_RTM_ID),
      fofb_node_mask_o                           => fofb_node_mask(c_FOFB_CC_RTM_ID),
      fofb_timestamp_val_o                       => fofb_timestamp_val(c_FOFB_CC_RTM_ID),
      fofb_link_status_o                         => fofb_link_status(c_FOFB_CC_RTM_ID),
      fofb_cc_enable_o                           => fofb_cc_enable(c_FOFB_CC_RTM_ID),
      fofb_fod_dat_o                             => fofb_fod_dat(c_FOFB_CC_RTM_ID),
      fofb_fod_dat_val_o                         => fofb_fod_dat_val(c_FOFB_CC_RTM_ID)(c_NUM_SFPS_FOFB-1 downto 0)
    );

    fofb_sysreset_n(c_FOFB_CC_RTM_ID) <= clk_sys_rstn and rtm_reconfig_rst_n;
    fofb_userrst_n(c_FOFB_CC_RTM_ID) <= not fofb_userrst(c_FOFB_CC_RTM_ID);

    -- CDC between FOFB clock and ACQ clock
    cmp_inferred_async_fwft_fifo : inferred_async_fwft_fifo
    generic map
    (
      g_data_width                              => c_FOFB_DCC_DATA_WIDTH,
      g_size                                    => 8,
      g_almost_empty_threshold                  => 1,
      g_almost_full_threshold                   => 7,
      g_async                                   => true
    )
    port map
    (
      -- Write clock
      wr_clk_i                                  => fofb_userclk(c_FOFB_CC_RTM_ID),
      wr_rst_n_i                                => fofb_userrst_n(c_FOFB_CC_RTM_ID),

      wr_data_i                                 => fofb_fod_dat(c_FOFB_CC_RTM_ID),
      wr_en_i                                   => fofb_fod_dat_val(c_FOFB_CC_RTM_ID)(0),

      -- Read clock
      rd_clk_i                                  => fs1_clk,
      rd_rst_n_i                                => fs1_rstn,

      rd_data_o                                 => fofb_fod_dat_fs_sync(c_FOFB_CC_RTM_ID),
      rd_valid_o                                => fofb_fod_dat_val_fs_sync(c_FOFB_CC_RTM_ID)(0),
      rd_en_i                                   => '1'
    );

  end generate;

  ----------------------------------------------------------------------
  --                          FOFB DCC P2P                            --
  ----------------------------------------------------------------------

  gen_fofb_p2p_gts: for i in 0 to c_GT_CFG.num_p2p_gts-1 generate

    -- RX lines
    fofb_rio_rx_p(c_FOFB_CC_P2P_ID)(i) <= p2p_gt_rx_p_i(g_P2P_GT_START_ID+i);
    fofb_rio_rx_n(c_FOFB_CC_P2P_ID)(i) <= p2p_gt_rx_n_i(g_P2P_GT_START_ID+i);

    -- TX lines
    p2p_gt_tx_p_o(g_P2P_GT_START_ID+i) <= fofb_rio_tx_p(c_FOFB_CC_P2P_ID)(i);
    p2p_gt_tx_n_o(g_P2P_GT_START_ID+i) <= fofb_rio_tx_n(c_FOFB_CC_P2P_ID)(i);

  end generate;

  gen_unused_fofb_p2p_gts: for i in c_GT_CFG.num_p2p_gts to c_GT_CFG.max_p2p_gts-1 generate

    -- TX lines
    p2p_gt_tx_p_o(g_P2P_GT_START_ID+i) <= '0';
    p2p_gt_tx_n_o(g_P2P_GT_START_ID+i) <= '1';

  end generate;

  gen_with_fofb_fp : if c_GT_CFG.with_fp_p2p generate
    gen_fofb_fp_p2p_gts: for i in 0 to c_GT_CFG.num_fp_p2p_gts-1 generate

      -- RX lines. Starts after all possible P2P GTs
      fofb_rio_rx_p(c_FOFB_CC_P2P_ID)(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i) <=
          p2p_gt_rx_p_i(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i);
      fofb_rio_rx_n(c_FOFB_CC_P2P_ID)(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i) <=
          p2p_gt_rx_n_i(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i);

      -- TX lines. Starts after all possible P2P GTs
      p2p_gt_tx_p_o(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i) <=
          fofb_rio_tx_p(c_FOFB_CC_P2P_ID)(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i);
      p2p_gt_tx_n_o(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i) <=
          fofb_rio_tx_n(c_FOFB_CC_P2P_ID)(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i);

    end generate;

    gen_unused_fofb_fp_p2p_gts: for i in c_GT_CFG.num_fp_p2p_gts to c_GT_CFG.max_fp_p2p_gts-1 generate

      -- TX lines
      p2p_gt_tx_p_o(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i) <= '0';
      p2p_gt_tx_n_o(g_P2P_GT_START_ID+c_GT_CFG.max_p2p_gts+i) <= '1';

    end generate;
  end generate;

  -- Only used if FP P2P is not used.
  fofb_ref_clk_p(c_FOFB_CC_P2P_ID) <= clk_fp2_clk1_p;
  fofb_ref_clk_n(c_FOFB_CC_P2P_ID) <= clk_fp2_clk1_n;

  gen_with_p2p_fofb_dcc : if c_WITH_P2P_FOFB_DCC generate

    -----------------------------------------
    -- CDC DSP 1 between ACQ clock and FOFB clock
    -----------------------------------------
    dsp1_fofb_pos_xy_in_fifo    <= (dsp1_fofb_pos_x, dsp1_fofb_pos_y);
    dsp1_fofb_pos_valid_in_fifo <= dsp1_fofb_pos_valid;

    cmp_dsp_1_fofb_fifo : inferred_async_fwft_fifo
    generic map
    (
      g_data_width                              => dsp1_fofb_pos_xy_out_fifo_slv'length,
      g_size                                    => 8,
      g_almost_empty_threshold                  => 1,
      g_almost_full_threshold                   => 7,
      g_async                                   => true
    )
    port map
    (
      -- Write clock
      wr_clk_i                                  => fs1_clk,
      wr_rst_n_i                                => dsp_fofb_pos_rstn,

      wr_data_i                                 => f_to_slv(dsp1_fofb_pos_xy_in_fifo),
      wr_en_i                                   => dsp1_fofb_pos_valid_in_fifo,

      -- Read clock
      rd_clk_i                                  => fs_ref_clk,
      rd_rst_n_i                                => fs_ref_rstn,

      rd_data_o                                 => dsp1_fofb_pos_xy_out_fifo_slv,
      rd_valid_o                                => dsp1_fofb_pos_valid_out_fifo,
      rd_en_i                                   => dsp_fofb_pos_fifo_rden
    );

    dsp1_fofb_pos_xy_out_fifo <= f_to_fofb_array(dsp1_fofb_pos_xy_out_fifo_slv);
    (dsp1_fofb_pos_x_out_fifo, dsp1_fofb_pos_y_out_fifo) <= dsp1_fofb_pos_xy_out_fifo;

    -----------------------------------------
    -- CDC DSP 1 between ACQ clock and FOFB clock
    -----------------------------------------
    dsp2_fofb_pos_xy_in_fifo    <= (dsp2_fofb_pos_x, dsp2_fofb_pos_y);
    dsp2_fofb_pos_valid_in_fifo <= dsp2_fofb_pos_valid;

    cmp_dsp_2_fofb_fifo : inferred_async_fwft_fifo
    generic map
    (
      g_data_width                              => dsp2_fofb_pos_xy_out_fifo_slv'length,
      g_size                                    => 8,
      g_almost_empty_threshold                  => 1,
      g_almost_full_threshold                   => 7,
      g_async                                   => true
    )
    port map
    (
      -- Write clock
      wr_clk_i                                  => fs2_clk,
      wr_rst_n_i                                => dsp_fofb_pos_rstn,

      wr_data_i                                 => f_to_slv(dsp2_fofb_pos_xy_in_fifo),
      wr_en_i                                   => dsp2_fofb_pos_valid_in_fifo,

      -- Read clock
      rd_clk_i                                  => fs_ref_clk,
      rd_rst_n_i                                => fs_ref_rstn,

      rd_data_o                                 => dsp2_fofb_pos_xy_out_fifo_slv,
      rd_valid_o                                => dsp2_fofb_pos_valid_out_fifo,
      rd_en_i                                   => dsp_fofb_pos_fifo_rden
    );

    dsp2_fofb_pos_xy_out_fifo <= f_to_fofb_array(dsp2_fofb_pos_xy_out_fifo_slv);
    (dsp2_fofb_pos_x_out_fifo, dsp2_fofb_pos_y_out_fifo) <= dsp2_fofb_pos_xy_out_fifo;

    -----------------------------------------
    -- FIFO read logic
    -----------------------------------------
    dsp_fofb_pos_rstn <= fs_ref_rstn and dsp_fofb_pos_enable_bpm_data;
    dsp_fofb_pos_fifo_rden <= '1' when dsp1_fofb_pos_valid_out_fifo = '1' and
                                       dsp2_fofb_pos_valid_out_fifo = '1' else '0';

    -----------------------------------------
    -- Send data to DCC
    -----------------------------------------

    -- Trigger signal for DCC timeframe_start.
    -- Trigger pulses are synch'ed with the respective fs_clk
    p_sync_start_fofb_dcc : process(fs_ref_clk)
    begin
      if rising_edge(fs_ref_clk) then
        if fs_ref_rstn = '0' then
          fai_fa_pl_state <= IDLE;
          fai_fa_pl_data_valid_r <= '0';
          dsp_fofb_pos_enable_bpm_data <= '0';
        else
          case fai_fa_pl_state is

            when IDLE =>
              fai_fa_pl_data_valid_r <= '0';

              -- we cross domains here, but fofb_cc_enable is pretty much
              -- static, controlled by software.
              if fofb_cc_enable(c_FOFB_CC_P2P_ID) = '1' then
                fai_fa_pl_state <= WAIT_TRIGGER;
              end if;

            when WAIT_TRIGGER =>
              if fofb_cc_enable(c_FOFB_CC_P2P_ID) = '0' then
                fai_fa_pl_state <= IDLE;
              -- use FOFB CC ID as the TRIGGER_MUX ID
              elsif trig_pulse_rcv(c_FOFB_CC_P2P_ID, c_ACQ_DCC_ID).pulse = '1' then
                dsp_fofb_pos_enable_bpm_data <= '1';
                fai_fa_pl_state <= SEND_BPM_DATA;
              end if;

            when SEND_BPM_DATA =>
              fai_fa_pl_data_valid_r <= dsp_fofb_pos_fifo_rden;
              fai_fa_pl_d_x_r        <= dsp2_fofb_pos_x_out_fifo & dsp1_fofb_pos_x_out_fifo;
              fai_fa_pl_d_y_r        <= dsp2_fofb_pos_y_out_fifo & dsp1_fofb_pos_y_out_fifo;

              if fofb_cc_enable(c_FOFB_CC_P2P_ID) = '0' then
                fai_fa_pl_data_valid_r <= '0';
                dsp_fofb_pos_enable_bpm_data <= '0';
                fai_fa_pl_state <= IDLE;
              end if;

            when others =>
              fai_fa_pl_data_valid_r <= '0';
              dsp_fofb_pos_enable_bpm_data <= '0';
              fai_fa_pl_state <= IDLE;

          end case;
        end if;
      end if;
    end process;

    cmp_fofb_ctrl_wrapper_1 : xwb_fofb_ctrl_wrapper
    generic map
    (
      g_INTERFACE_MODE                          => PIPELINED,
      g_ADDRESS_GRANULARITY                     => BYTE,
      g_ID                                      => 0,
      g_DEVICE                                  => BPM,
      g_PHYSICAL_INTERFACE                      => "BACKPLANE",
      -- clock from right-side GTP
      g_REFCLK_INPUT                            => "REFCLK1",
      -- if FP P2P is used we take ref. clock from it, if not we instantiate
      -- the clock buffers ourselves
      g_CLK_BUFFERS                             => true,
      g_USE_PARALLEL_FA_IF                      => true,
      g_LANE_COUNT                              => c_NUM_P2P_GTS,
      g_BPMS                                    => c_BPMS,
      g_USE_CHIPSCOPE                           => c_USE_CHIPSCOPE,
      -- BPM synthetic data
      g_SIM_BPM_DATA                            => false
    )
    port map
    (
      -- Only used when CLK_BUFFERS := false
      ---------------------------------------------------------------------------
      -- differential MGT/GTP clock inputs
      ---------------------------------------------------------------------------
      refclk_p_i                                 => fofb_ref_clk_p(c_FOFB_CC_P2P_ID),
      refclk_n_i                                 => fofb_ref_clk_n(c_FOFB_CC_P2P_ID),

      ---------------------------------------------------------------------------
      -- clock and reset interface
      ---------------------------------------------------------------------------
      adcclk_i                                   => fs_ref_clk,
      adcreset_i                                 => fs_ref_rst,
      sysclk_i                                   => clk_sys,
      sysreset_n_i                               => fofb_sysreset_n(c_FOFB_CC_P2P_ID),

      fai_fa_pl_data_valid_i                     => fai_fa_pl_data_valid_r,
      fai_fa_pl_d_x_i                            => fai_fa_pl_d_x_r,
      fai_fa_pl_d_y_i                            => fai_fa_pl_d_y_r,

      ---------------------------------------------------------------------------
      -- Wishbone Control Interface signals
      ---------------------------------------------------------------------------
      wb_slv_i                                   => user_wb_out(c_SLV_FOFB_CC_P2P_ID),
      wb_slv_o                                   => user_wb_in(c_SLV_FOFB_CC_P2P_ID),

      ---------------------------------------------------------------------------
      -- serial I/Os for eight RocketIOs on the Libera
      ---------------------------------------------------------------------------
      fai_rio_rdp_i                              => fofb_rio_rx_p(c_FOFB_CC_P2P_ID)(c_NUM_P2P_GTS-1 downto 0),
      fai_rio_rdn_i                              => fofb_rio_rx_n(c_FOFB_CC_P2P_ID)(c_NUM_P2P_GTS-1 downto 0),
      fai_rio_tdp_o                              => fofb_rio_tx_p(c_FOFB_CC_P2P_ID)(c_NUM_P2P_GTS-1 downto 0),
      fai_rio_tdn_o                              => fofb_rio_tx_n(c_FOFB_CC_P2P_ID)(c_NUM_P2P_GTS-1 downto 0),
      fai_rio_tdis_o                             => fofb_rio_tx_disable(c_FOFB_CC_P2P_ID)(c_NUM_P2P_GTS-1 downto 0),

      ---------------------------------------------------------------------------
      -- Higher-level integration interface (PMC, SNIFFER_V5)
      ---------------------------------------------------------------------------
      fofb_userclk_o                             => fofb_userclk(c_FOFB_CC_P2P_ID),
      fofb_userrst_o                             => fofb_userrst(c_FOFB_CC_P2P_ID),
      timeframe_start_o                          => timeframe_start(c_FOFB_CC_P2P_ID),
      timeframe_end_o                            => timeframe_end(c_FOFB_CC_P2P_ID),
      fofb_dma_ok_i                              => fofb_dma_ok(c_FOFB_CC_P2P_ID),
      fofb_node_mask_o                           => fofb_node_mask(c_FOFB_CC_P2P_ID),
      fofb_timestamp_val_o                       => fofb_timestamp_val(c_FOFB_CC_P2P_ID),
      fofb_link_status_o                         => fofb_link_status(c_FOFB_CC_P2P_ID),
      fofb_cc_enable_o                           => fofb_cc_enable(c_FOFB_CC_P2P_ID),
      fofb_fod_dat_o                             => fofb_fod_dat(c_FOFB_CC_P2P_ID),
      fofb_fod_dat_val_o                         => fofb_fod_dat_val(c_FOFB_CC_P2P_ID)(c_NUM_P2P_GTS-1 downto 0)
    );

    fofb_sysreset_n(c_FOFB_CC_P2P_ID) <= clk_sys_rstn and afc_si57x_reconfig_rst_n;
    fofb_userrst_n(c_FOFB_CC_P2P_ID) <= not fofb_userrst(c_FOFB_CC_P2P_ID);

    -- CDC between FOFB clock and ACQ clock
    cmp_inferred_async_fwft_fifo : inferred_async_fwft_fifo
    generic map
    (
      g_data_width                              => c_FOFB_DCC_DATA_WIDTH,
      g_size                                    => 8,
      g_almost_empty_threshold                  => 1,
      g_almost_full_threshold                   => 7,
      g_async                                   => true
    )
    port map
    (
      -- Write clock
      wr_clk_i                                  => fofb_userclk(c_FOFB_CC_P2P_ID),
      wr_rst_n_i                                => fofb_userrst_n(c_FOFB_CC_P2P_ID),

      wr_data_i                                 => fofb_fod_dat(c_FOFB_CC_P2P_ID),
      wr_en_i                                   => fofb_fod_dat_val(c_FOFB_CC_P2P_ID)(0),

      -- Read clock
      rd_clk_i                                  => fs1_clk,
      rd_rst_n_i                                => fs1_rstn,

      rd_data_o                                 => fofb_fod_dat_fs_sync(c_FOFB_CC_P2P_ID),
      rd_valid_o                                => fofb_fod_dat_val_fs_sync(c_FOFB_CC_P2P_ID)(0),
      rd_en_i                                   => '1'
    );

  end generate;

  gen_without_p2p_fofb_dcc: if (not c_WITH_P2P_FOFB_DCC) generate

    fofb_fod_dat_fs_sync(c_FOFB_CC_P2P_ID) <= (others => '0');
    fofb_fod_dat_val_fs_sync(c_FOFB_CC_P2P_ID) <= (others => '0');

  end generate;

  -- If only P2P FOFB is available use its acquisition channel so it's easier
  -- for software, if not, P2P data will be forwarded to the RTM DCC. So, that
  -- will be eventually stored as well.
  gen_only_p2p_fofb_dcc : if (not c_WITH_RTM_SFP_FOFB_DCC) generate

    gen_p2p_fofb_dcc : if c_WITH_P2P_FOFB_DCC generate
      fofb_fod_dat_fs_sync(c_FOFB_CC_RTM_ID)     <= fofb_fod_dat_fs_sync(c_FOFB_CC_P2P_ID);
      fofb_fod_dat_val_fs_sync(c_FOFB_CC_RTM_ID) <= fofb_fod_dat_val_fs_sync(c_FOFB_CC_P2P_ID);
    end generate;

    gen_no_fofb_dcc : if (not c_WITH_P2P_FOFB_DCC) generate
      fofb_fod_dat_fs_sync(c_FOFB_CC_RTM_ID) <= (others => '0');
      fofb_fod_dat_val_fs_sync(c_FOFB_CC_RTM_ID) <= (others => '0');
    end generate;

  end generate;

  ----------------------------------------------------------------------
  --                      Acquisition Core                            --
  ----------------------------------------------------------------------

  fs_clk_array   <= fs2_clk & fs1_clk & fs2_clk & fs1_clk;
  fs_ce_array    <= "1111";
  fs_rst_n_array <= fs2_rstn & fs1_rstn & fs2_rstn & fs1_rstn;

  --------------------
  -- ADC 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_adc_id).val(to_integer(c_facq_channels(c_acq_adc_id).width)-1 downto 0) <=
                                                                 fmc1_adc_data_se_ch3 &
                                                                 fmc1_adc_data_se_ch2 &
                                                                 fmc1_adc_data_se_ch1 &
                                                                 fmc1_adc_data_se_ch0;
  acq_chan_array(c_acq_core_0_id, c_acq_adc_id).dvalid        <= fmc1_adc_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_adc_id).trig          <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_adc_id).pulse;

  --------------------
  -- ADC SWAP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_adc_swap_id).val(to_integer(c_facq_channels(c_acq_adc_swap_id).width)-1 downto 0) <=
                                                                 dsp1_adc_se_ch3_data &
                                                                 dsp1_adc_se_ch2_data &
                                                                 dsp1_adc_se_ch1_data &
                                                                 dsp1_adc_se_ch0_data;
  acq_chan_array(c_acq_core_0_id, c_acq_adc_swap_id).dvalid   <= dsp1_adc_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_adc_swap_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_adc_swap_id).pulse;

  --------------------
  -- MIXER I/Q 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_mixiq_id).val(to_integer(c_facq_channels(c_acq_mixiq_id).width)-1 downto 0) <=
                                                                 dsp1_mixq_ch3 &
                                                                 dsp1_mixi_ch3 &
                                                                 dsp1_mixq_ch2 &
                                                                 dsp1_mixi_ch2 &
                                                                 dsp1_mixq_ch1 &
                                                                 dsp1_mixi_ch1 &
                                                                 dsp1_mixq_ch0 &
                                                                 dsp1_mixi_ch0;
  acq_chan_array(c_acq_core_0_id, c_acq_mixiq_id).dvalid      <= dsp1_mix_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_mixiq_id).trig        <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_mixiq_id).pulse;

  --------------------
  -- DUMMY 0 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_0_id, c_dummy0_id).val(to_integer(c_facq_channels(c_dummy0_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_0_id, c_dummy0_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_0_id, c_dummy0_id).trig           <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_dummy0_id).pulse;

  --------------------
  -- TBT I/Q 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_tbtdecimiq_id).val(to_integer(c_facq_channels(c_acq_tbtdecimiq_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch0), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_tbtdecimiq_id).dvalid <= dsp1_tbtdecim_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_tbtdecimiq_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_tbtdecimiq_id).pulse;

  --------------------
  -- DUMMY 1 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_0_id, c_dummy1_id).val(to_integer(c_facq_channels(c_dummy1_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_0_id, c_dummy1_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_0_id, c_dummy1_id).trig           <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_dummy1_id).pulse;

  --------------------
  -- TBT AMP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_amp_id).val(to_integer(c_facq_channels(c_acq_tbt_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_amp_id).dvalid    <= dsp1_tbt_amp_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_amp_id).trig      <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_tbt_amp_id).pulse;

  --------------------
  -- TBT PHASE 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_phase_id).val(to_integer(c_facq_channels(c_acq_tbt_phase_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_phase_id).dvalid  <= dsp1_tbt_pha_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_phase_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_tbt_phase_id).pulse;

  --------------------
  -- TBT POS 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_pos_id).val(to_integer(c_facq_channels(c_acq_tbt_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_x), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_pos_id).dvalid    <= dsp1_tbt_pos_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_tbt_pos_id).trig      <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_tbt_pos_id).pulse;

  --------------------
  -- FOFB I/Q 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_fofbdecimiq_id).val(to_integer(c_facq_channels(c_acq_fofbdecimiq_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_fofbdecimq_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch0), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_fofbdecimiq_id).dvalid <= dsp1_fofbdecim_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_fofbdecimiq_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_fofbdecimiq_id).pulse;

  --------------------
  -- DUMMY 2 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_0_id, c_dummy2_id).val(to_integer(c_facq_channels(c_dummy2_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_0_id, c_dummy2_id).dvalid          <= '0';
  acq_chan_array(c_acq_core_0_id, c_dummy2_id).trig            <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_dummy1_id).pulse;

  --------------------
  -- FOFB AMP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_amp_id).val(to_integer(c_facq_channels(c_acq_fofb_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_amp_id).dvalid   <= dsp1_fofb_amp_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_amp_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_fofb_amp_id).pulse;

  --------------------
  -- FOFB PHASE 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_phase_id).val(to_integer(c_facq_channels(c_acq_fofb_phase_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_phase_id).dvalid <= dsp1_fofb_pha_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_phase_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_fofb_phase_id).pulse;

  --------------------
  -- FOFB POS 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_pos_id).val(to_integer(c_facq_channels(c_acq_fofb_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_x), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_pos_id).dvalid   <= dsp1_fofb_pos_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_fofb_pos_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_fofb_pos_id).pulse;

  --------------------
  -- MONIT1 AMP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_monit1_amp_id).val(to_integer(c_facq_channels(c_acq_monit1_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_monit1_amp_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_monit1_amp_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_monit1_amp_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_monit1_amp_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_monit1_amp_id).dvalid  <= dsp1_monit1_amp_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_monit1_amp_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_monit1_amp_id).pulse;

  --------------------
  -- MONIT1 POS 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_monit1_pos_id).val(to_integer(c_facq_channels(c_acq_monit1_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_monit1_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit1_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit1_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit1_pos_x), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_monit1_pos_id).dvalid <= dsp1_monit1_pos_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_monit1_pos_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_monit1_pos_id).pulse;

  --------------------
  -- MONIT AMP 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_monit_amp_id).val(to_integer(c_facq_channels(c_acq_monit_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch0), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_monit_amp_id).dvalid  <= dsp1_monit_amp_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_monit_amp_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_monit_amp_id).pulse;

  --------------------
  -- MONIT POS 1 data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_acq_monit_pos_id).val(to_integer(c_facq_channels(c_acq_monit_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_x), 32));
  acq_chan_array(c_acq_core_0_id, c_acq_monit_pos_id).dvalid  <= dsp1_monit_pos_valid;
  acq_chan_array(c_acq_core_0_id, c_acq_monit_pos_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_acq_monit_pos_id).pulse;

  --------------------
  -- FOFB DCC data
  --------------------
  acq_chan_array(c_acq_core_0_id, c_ACQ_DCC_ID).val(to_integer(c_facq_channels(c_ACQ_DCC_ID).width)-1 downto 0) <=
                                                              fofb_fod_dat_fs_sync(c_FOFB_CC_RTM_ID);
  acq_chan_array(c_acq_core_0_id, c_ACQ_DCC_ID).dvalid  <= fofb_fod_dat_val_fs_sync(c_FOFB_CC_RTM_ID)(0);
  acq_chan_array(c_acq_core_0_id, c_ACQ_DCC_ID).trig    <= trig_pulse_rcv(c_TRIG_MUX_0_ID, c_ACQ_DCC_ID).pulse;

  --------------------
  -- ADC 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_adc_id).val(to_integer(c_facq_channels(c_acq_adc_id).width)-1 downto 0) <=
                                                                 fmc2_adc_data_se_ch3 &
                                                                 fmc2_adc_data_se_ch2 &
                                                                 fmc2_adc_data_se_ch1 &
                                                                 fmc2_adc_data_se_ch0;
  acq_chan_array(c_acq_core_1_id, c_acq_adc_id).dvalid        <= fmc2_adc_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_adc_id).trig          <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_adc_id).pulse;

  --------------------
  -- ADC SWAP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_adc_swap_id).val(to_integer(c_facq_channels(c_acq_adc_swap_id).width)-1 downto 0) <=
                                                                 dsp2_adc_se_ch3_data &
                                                                 dsp2_adc_se_ch2_data &
                                                                 dsp2_adc_se_ch1_data &
                                                                 dsp2_adc_se_ch0_data;
  acq_chan_array(c_acq_core_1_id, c_acq_adc_swap_id).dvalid   <= dsp2_adc_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_adc_swap_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_adc_swap_id).pulse;

  --------------------
  -- MIXER I/Q 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_mixiq_id).val(to_integer(c_facq_channels(c_acq_mixiq_id).width)-1 downto 0) <=
                                                                 dsp2_mixq_ch3 &
                                                                 dsp2_mixi_ch3 &
                                                                 dsp2_mixq_ch2 &
                                                                 dsp2_mixi_ch2 &
                                                                 dsp2_mixq_ch1 &
                                                                 dsp2_mixi_ch1 &
                                                                 dsp2_mixq_ch0 &
                                                                 dsp2_mixi_ch0;
  acq_chan_array(c_acq_core_1_id, c_acq_mixiq_id).dvalid      <= dsp2_mix_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_mixiq_id).trig        <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_mixiq_id).pulse;

  --------------------
  -- DUMMY 0 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_1_id, c_dummy0_id).val(to_integer(c_facq_channels(c_dummy0_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_1_id, c_dummy0_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_1_id, c_dummy0_id).trig           <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_dummy0_id).pulse;

  --------------------
  -- TBT I/Q 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_tbtdecimiq_id).val(to_integer(c_facq_channels(c_acq_tbtdecimiq_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch0), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_tbtdecimiq_id).dvalid <= dsp2_tbtdecim_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_tbtdecimiq_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_tbtdecimiq_id).pulse;

  --------------------
  -- DUMMY 1 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_1_id, c_dummy1_id).val(to_integer(c_facq_channels(c_dummy1_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_1_id, c_dummy1_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_1_id, c_dummy1_id).trig           <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_dummy1_id).pulse;

  --------------------
  -- TBT AMP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_amp_id).val(to_integer(c_facq_channels(c_acq_tbt_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_amp_id).dvalid    <= dsp2_tbt_amp_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_amp_id).trig      <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_tbt_amp_id).pulse;

  --------------------
  -- TBT PHASE 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_phase_id).val(to_integer(c_facq_channels(c_acq_tbt_phase_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_phase_id).dvalid  <= dsp2_tbt_pha_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_phase_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_tbt_phase_id).pulse;

  --------------------
  -- TBT POS 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_pos_id).val(to_integer(c_facq_channels(c_acq_tbt_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_x), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_pos_id).dvalid    <= dsp2_tbt_pos_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_tbt_pos_id).trig      <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_tbt_pos_id).pulse;

  --------------------
  -- FOFB I/Q 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_fofbdecimiq_id).val(to_integer(c_facq_channels(c_acq_fofbdecimiq_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_fofbdecimq_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch0), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_fofbdecimiq_id).dvalid <= dsp2_fofbdecim_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_fofbdecimiq_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_fofbdecimiq_id).pulse;

  --------------------
  -- DUMMY 2 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_1_id, c_dummy2_id).val(to_integer(c_facq_channels(c_dummy2_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_1_id, c_dummy2_id).dvalid          <= '0';
  acq_chan_array(c_acq_core_1_id, c_dummy2_id).trig            <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_dummy1_id).pulse;

  --------------------
  -- FOFB AMP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_amp_id).val(to_integer(c_facq_channels(c_acq_fofb_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_amp_id).dvalid   <= dsp2_fofb_amp_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_amp_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_fofb_amp_id).pulse;

  --------------------
  -- FOFB PHASE 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_phase_id).val(to_integer(c_facq_channels(c_acq_fofb_phase_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_phase_id).dvalid <= dsp2_fofb_pha_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_phase_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_fofb_phase_id).pulse;

  --------------------
  -- FOFB POS 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_pos_id).val(to_integer(c_facq_channels(c_acq_fofb_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_x), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_pos_id).dvalid   <= dsp2_fofb_pos_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_fofb_pos_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_fofb_pos_id).pulse;

  --------------------
  -- MONIT1 AMP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_monit1_amp_id).val(to_integer(c_facq_channels(c_acq_monit1_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_monit1_amp_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_monit1_amp_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_monit1_amp_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_monit1_amp_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_monit1_amp_id).dvalid  <= dsp2_monit1_amp_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_monit1_amp_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_monit1_amp_id).pulse;

  --------------------
  -- MONIT1 POS 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_monit1_pos_id).val(to_integer(c_facq_channels(c_acq_monit1_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_monit1_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit1_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit1_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit1_pos_x), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_monit1_pos_id).dvalid <= dsp2_monit1_pos_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_monit1_pos_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_monit1_pos_id).pulse;

  --------------------
  -- MONIT AMP 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_monit_amp_id).val(to_integer(c_facq_channels(c_acq_monit_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch0), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_monit_amp_id).dvalid  <= dsp2_monit_amp_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_monit_amp_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_monit_amp_id).pulse;

  --------------------
  -- MONIT POS 2 data
  --------------------
  acq_chan_array(c_acq_core_1_id, c_acq_monit_pos_id).val(to_integer(c_facq_channels(c_acq_monit_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_x), 32));
  acq_chan_array(c_acq_core_1_id, c_acq_monit_pos_id).dvalid  <= dsp2_monit_pos_valid;
  acq_chan_array(c_acq_core_1_id, c_acq_monit_pos_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_1_ID, c_acq_monit_pos_id).pulse;

  --------------------
  -- ADC 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_adc_id).val(to_integer(c_facq_channels(c_acq_adc_id).width)-1 downto 0) <=
                                                                 fmc1_adc_data_se_ch3 &
                                                                 fmc1_adc_data_se_ch2 &
                                                                 fmc1_adc_data_se_ch1 &
                                                                 fmc1_adc_data_se_ch0;
  acq_chan_array(c_acq_core_2_id, c_acq_adc_id).dvalid        <= fmc1_adc_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_adc_id).trig          <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_adc_id).pulse;

  --------------------
  -- ADC SWAP 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_adc_swap_id).val(to_integer(c_facq_channels(c_acq_adc_swap_id).width)-1 downto 0) <=
                                                                 dsp1_adc_se_ch3_data &
                                                                 dsp1_adc_se_ch2_data &
                                                                 dsp1_adc_se_ch1_data &
                                                                 dsp1_adc_se_ch0_data;
  acq_chan_array(c_acq_core_2_id, c_acq_adc_swap_id).dvalid   <= dsp1_adc_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_adc_swap_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_adc_swap_id).pulse;

  --------------------
  -- MIXER I/Q 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_mixiq_id).val(to_integer(c_facq_channels(c_acq_mixiq_id).width)-1 downto 0) <=
                                                                 dsp1_mixq_ch3 &
                                                                 dsp1_mixi_ch3 &
                                                                 dsp1_mixq_ch2 &
                                                                 dsp1_mixi_ch2 &
                                                                 dsp1_mixq_ch1 &
                                                                 dsp1_mixi_ch1 &
                                                                 dsp1_mixq_ch0 &
                                                                 dsp1_mixi_ch0;
  acq_chan_array(c_acq_core_2_id, c_acq_mixiq_id).dvalid      <= dsp1_mix_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_mixiq_id).trig        <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_mixiq_id).pulse;

  --------------------
  -- DUMMY 0 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_2_id, c_dummy0_id).val(to_integer(c_facq_channels(c_dummy0_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_2_id, c_dummy0_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_2_id, c_dummy0_id).trig           <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_dummy0_id).pulse;

  --------------------
  -- TBT I/Q 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_tbtdecimiq_id).val(to_integer(c_facq_channels(c_acq_tbtdecimiq_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimq_ch0), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbtdecimi_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_tbtdecimiq_id).dvalid <= dsp1_tbtdecim_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_tbtdecimiq_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_tbtdecimiq_id).pulse;

  --------------------
  -- DUMMY 1 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_2_id, c_dummy1_id).val(to_integer(c_facq_channels(c_dummy1_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_2_id, c_dummy1_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_2_id, c_dummy1_id).trig           <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_dummy1_id).pulse;

  --------------------
  -- TBT AMP 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_amp_id).val(to_integer(c_facq_channels(c_acq_tbt_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_amp_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_amp_id).dvalid    <= dsp1_tbt_amp_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_amp_id).trig      <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_tbt_amp_id).pulse;

  --------------------
  -- TBT PHASE 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_phase_id).val(to_integer(c_facq_channels(c_acq_tbt_phase_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pha_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_phase_id).dvalid  <= dsp1_tbt_pha_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_phase_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_tbt_phase_id).pulse;

  --------------------
  -- TBT POS 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_pos_id).val(to_integer(c_facq_channels(c_acq_tbt_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_tbt_pos_x), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_pos_id).dvalid    <= dsp1_tbt_pos_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_tbt_pos_id).trig      <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_tbt_pos_id).pulse;

  --------------------
  -- FOFB I/Q 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_fofbdecimiq_id).val(to_integer(c_facq_channels(c_acq_fofbdecimiq_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_fofbdecimq_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimq_ch0), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_fofbdecimi_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_fofbdecimiq_id).dvalid <= dsp1_fofbdecim_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_fofbdecimiq_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_fofbdecimiq_id).pulse;

  --------------------
  -- DUMMY 2 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_2_id, c_dummy2_id).val(to_integer(c_facq_channels(c_dummy2_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_2_id, c_dummy2_id).dvalid          <= '0';
  acq_chan_array(c_acq_core_2_id, c_dummy2_id).trig            <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_dummy1_id).pulse;

  --------------------
  -- FOFB AMP 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_amp_id).val(to_integer(c_facq_channels(c_acq_fofb_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_amp_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_amp_id).dvalid   <= dsp1_fofb_amp_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_amp_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_fofb_amp_id).pulse;

  --------------------
  -- FOFB PHASE 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_phase_id).val(to_integer(c_facq_channels(c_acq_fofb_phase_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pha_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_phase_id).dvalid <= dsp1_fofb_pha_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_phase_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_fofb_phase_id).pulse;

  --------------------
  -- FOFB POS 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_pos_id).val(to_integer(c_facq_channels(c_acq_fofb_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_fofb_pos_x), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_pos_id).dvalid   <= dsp1_fofb_pos_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_fofb_pos_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_fofb_pos_id).pulse;

  --------------------
  -- MONIT1 AMP 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_monit1_amp_id).val(to_integer(c_facq_channels(c_acq_monit1_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_monit1_amp_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_monit1_amp_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_monit1_amp_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp1_monit1_amp_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_monit1_amp_id).dvalid  <= dsp1_monit1_amp_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_monit1_amp_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_monit1_amp_id).pulse;

  --------------------
  -- MONIT1 POS 3 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_monit1_pos_id).val(to_integer(c_facq_channels(c_acq_monit1_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_monit1_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit1_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit1_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit1_pos_x), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_monit1_pos_id).dvalid <= dsp1_monit1_pos_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_monit1_pos_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_monit1_pos_id).pulse;

  --------------------
  -- MONIT AMP 1 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_monit_amp_id).val(to_integer(c_facq_channels(c_acq_monit_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_amp_ch0), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_monit_amp_id).dvalid  <= dsp1_monit_amp_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_monit_amp_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_monit_amp_id).pulse;

  --------------------
  -- MONIT POS 1 data
  --------------------
  acq_chan_array(c_acq_core_2_id, c_acq_monit_pos_id).val(to_integer(c_facq_channels(c_acq_monit_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp1_monit_pos_x), 32));
  acq_chan_array(c_acq_core_2_id, c_acq_monit_pos_id).dvalid  <= dsp1_monit_pos_valid;
  acq_chan_array(c_acq_core_2_id, c_acq_monit_pos_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_2_ID, c_acq_monit_pos_id).pulse;

  --------------------
  -- ADC 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_adc_id).val(to_integer(c_facq_channels(c_acq_adc_id).width)-1 downto 0) <=
                                                                 fmc2_adc_data_se_ch3 &
                                                                 fmc2_adc_data_se_ch2 &
                                                                 fmc2_adc_data_se_ch1 &
                                                                 fmc2_adc_data_se_ch0;
  acq_chan_array(c_acq_core_3_id, c_acq_adc_id).dvalid        <= fmc2_adc_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_adc_id).trig          <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_adc_id).pulse;

  --------------------
  -- ADC SWAP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_adc_swap_id).val(to_integer(c_facq_channels(c_acq_adc_swap_id).width)-1 downto 0) <=
                                                                 dsp2_adc_se_ch3_data &
                                                                 dsp2_adc_se_ch2_data &
                                                                 dsp2_adc_se_ch1_data &
                                                                 dsp2_adc_se_ch0_data;
  acq_chan_array(c_acq_core_3_id, c_acq_adc_swap_id).dvalid   <= dsp2_adc_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_adc_swap_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_adc_swap_id).pulse;

  --------------------
  -- MIXER I/Q 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_mixiq_id).val(to_integer(c_facq_channels(c_acq_mixiq_id).width)-1 downto 0) <=
                                                                 dsp2_mixq_ch3 &
                                                                 dsp2_mixi_ch3 &
                                                                 dsp2_mixq_ch2 &
                                                                 dsp2_mixi_ch2 &
                                                                 dsp2_mixq_ch1 &
                                                                 dsp2_mixi_ch1 &
                                                                 dsp2_mixq_ch0 &
                                                                 dsp2_mixi_ch0;
  acq_chan_array(c_acq_core_3_id, c_acq_mixiq_id).dvalid      <= dsp2_mix_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_mixiq_id).trig        <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_mixiq_id).pulse;

  --------------------
  -- DUMMY 0 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_3_id, c_dummy0_id).val(to_integer(c_facq_channels(c_dummy0_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_3_id, c_dummy0_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_3_id, c_dummy0_id).trig           <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_dummy0_id).pulse;

  --------------------
  -- TBT I/Q 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_tbtdecimiq_id).val(to_integer(c_facq_channels(c_acq_tbtdecimiq_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimq_ch0), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbtdecimi_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_tbtdecimiq_id).dvalid <= dsp2_tbtdecim_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_tbtdecimiq_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_tbtdecimiq_id).pulse;

  --------------------
  -- DUMMY 1 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_3_id, c_dummy1_id).val(to_integer(c_facq_channels(c_dummy1_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_3_id, c_dummy1_id).dvalid         <= '0';
  acq_chan_array(c_acq_core_3_id, c_dummy1_id).trig           <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_dummy1_id).pulse;

  --------------------
  -- TBT AMP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_amp_id).val(to_integer(c_facq_channels(c_acq_tbt_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_amp_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_amp_id).dvalid    <= dsp2_tbt_amp_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_amp_id).trig      <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_tbt_amp_id).pulse;

  --------------------
  -- TBT PHASE 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_phase_id).val(to_integer(c_facq_channels(c_acq_tbt_phase_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pha_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_phase_id).dvalid  <= dsp2_tbt_pha_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_phase_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_tbt_phase_id).pulse;

  --------------------
  -- TBT POS 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_pos_id).val(to_integer(c_facq_channels(c_acq_tbt_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_tbt_pos_x), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_pos_id).dvalid    <= dsp2_tbt_pos_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_tbt_pos_id).trig      <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_tbt_pos_id).pulse;

  --------------------
  -- FOFB I/Q 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_fofbdecimiq_id).val(to_integer(c_facq_channels(c_acq_fofbdecimiq_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_fofbdecimq_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimq_ch0), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_fofbdecimi_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_fofbdecimiq_id).dvalid <= dsp2_fofbdecim_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_fofbdecimiq_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_fofbdecimiq_id).pulse;

  --------------------
  -- DUMMY 2 (for compatibility)
  --------------------
  acq_chan_array(c_acq_core_3_id, c_dummy2_id).val(to_integer(c_facq_channels(c_dummy2_id).width)-1 downto 0) <=
                                                                 (others => '0');
  acq_chan_array(c_acq_core_3_id, c_dummy2_id).dvalid          <= '0';
  acq_chan_array(c_acq_core_3_id, c_dummy2_id).trig            <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_dummy2_id).pulse;

  --------------------
  -- FOFB AMP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_amp_id).val(to_integer(c_facq_channels(c_acq_fofb_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_amp_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_amp_id).dvalid   <= dsp2_fofb_amp_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_amp_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_fofb_amp_id).pulse;

  --------------------
  -- FOFB PHASE 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_phase_id).val(to_integer(c_facq_channels(c_acq_fofb_phase_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pha_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_phase_id).dvalid <= dsp2_fofb_pha_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_phase_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_fofb_phase_id).pulse;

  --------------------
  -- FOFB POS 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_pos_id).val(to_integer(c_facq_channels(c_acq_fofb_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_fofb_pos_x), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_pos_id).dvalid   <= dsp2_fofb_pos_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_fofb_pos_id).trig     <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_fofb_pos_id).pulse;

  --------------------
  -- MONIT1 AMP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_monit1_amp_id).val(to_integer(c_facq_channels(c_acq_monit1_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_monit1_amp_ch3), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_monit1_amp_ch2), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_monit1_amp_ch1), 32)) &
                                                                  std_logic_vector(resize(signed(dsp2_monit1_amp_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_monit1_amp_id).dvalid  <= dsp2_monit1_amp_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_monit1_amp_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_monit1_amp_id).pulse;

  --------------------
  -- MONIT1 POS 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_monit1_pos_id).val(to_integer(c_facq_channels(c_acq_monit1_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_monit1_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit1_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit1_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit1_pos_x), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_monit1_pos_id).dvalid <= dsp2_monit1_pos_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_monit1_pos_id).trig   <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_monit1_pos_id).pulse;

  --------------------
  -- MONIT AMP 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_monit_amp_id).val(to_integer(c_facq_channels(c_acq_monit_amp_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch3), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch2), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch1), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_amp_ch0), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_monit_amp_id).dvalid  <= dsp2_monit_amp_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_monit_amp_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_monit_amp_id).pulse;

  --------------------
  -- MONIT POS 4 data
  --------------------
  acq_chan_array(c_acq_core_3_id, c_acq_monit_pos_id).val(to_integer(c_facq_channels(c_acq_monit_pos_id).width)-1 downto 0) <=
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_sum), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_q), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_y), 32)) &
                                                                 std_logic_vector(resize(signed(dsp2_monit_pos_x), 32));
  acq_chan_array(c_acq_core_3_id, c_acq_monit_pos_id).dvalid  <= dsp2_monit_pos_valid;
  acq_chan_array(c_acq_core_3_id, c_acq_monit_pos_id).trig    <= trig_pulse_rcv(c_TRIG_MUX_3_ID, c_acq_monit_pos_id).pulse;

  ----------------------------------------------------------------------
  --                        Orbit Interlock                           --
  ----------------------------------------------------------------------
  cmp_xwb_orbit_intlk : xwb_orbit_intlk
  generic map
  (
    -- Wishbone
    g_ADDRESS_GRANULARITY                      => BYTE,
    g_INTERFACE_MODE                           => PIPELINED,
    -- Position
    g_ADC_WIDTH                                => c_num_unprocessed_se_bits,
    g_DECIM_WIDTH                              => c_pos_calc_fofb_decim_width
  )
  port map
  (
    -----------------------------
    -- Clocks and resets
    -----------------------------

    clk_i                                      => clk_sys,
    rst_n_i                                    => clk_sys_rstn,
    ref_clk_i                                  => fs1_clk,
    ref_rst_n_i                                => fs1_rstn,

    -----------------------------
    -- Wishbone signals
    -----------------------------

    wb_slv_i                                   => user_wb_out(c_SLV_ORBIT_INTLK_ID),
    wb_slv_o                                   => user_wb_in(c_SLV_ORBIT_INTLK_ID),

    -----------------------------
    -- Downstream ADC and position signals
    -----------------------------

    fs_clk_ds_i                                => fs1_clk,

    adc_ds_ch0_swap_i                          => dsp1_adc_se_ch0_data,
    adc_ds_ch1_swap_i                          => dsp1_adc_se_ch1_data,
    adc_ds_ch2_swap_i                          => dsp1_adc_se_ch2_data,
    adc_ds_ch3_swap_i                          => dsp1_adc_se_ch3_data,
    adc_ds_tag_i                               => dsp1_adc_tag,
    adc_ds_swap_valid_i                        => dsp1_adc_valid,

    decim_ds_pos_x_i                           => dsp1_monit1_pos_x,
    decim_ds_pos_y_i                           => dsp1_monit1_pos_y,
    decim_ds_pos_q_i                           => dsp1_monit1_pos_q,
    decim_ds_pos_sum_i                         => dsp1_monit1_pos_sum,
    decim_ds_pos_valid_i                       => dsp1_monit1_pos_valid,

    -----------------------------
    -- Upstream ADC and position signals
    -----------------------------

    fs_clk_us_i                                => fs2_clk,

    adc_us_ch0_swap_i                          => dsp2_adc_se_ch0_data,
    adc_us_ch1_swap_i                          => dsp2_adc_se_ch1_data,
    adc_us_ch2_swap_i                          => dsp2_adc_se_ch2_data,
    adc_us_ch3_swap_i                          => dsp2_adc_se_ch3_data,
    adc_us_tag_i                               => dsp2_adc_tag,
    adc_us_swap_valid_i                        => dsp2_adc_valid,

    decim_us_pos_x_i                           => dsp2_monit1_pos_x,
    decim_us_pos_y_i                           => dsp2_monit1_pos_y,
    decim_us_pos_q_i                           => dsp2_monit1_pos_q,
    decim_us_pos_sum_i                         => dsp2_monit1_pos_sum,
    decim_us_pos_valid_i                       => dsp2_monit1_pos_valid,

    -----------------------------
    -- Interlock outputs
    -----------------------------

    -- only cleared when intlk_clr_i is asserted
    intlk_ltc_o                                => intlk_ltc,
    -- conditional to intlk_en_i
    intlk_o                                    => intlk
  );

  ----------------------------------------------------------------------
  --                          Trigger                                 --
  ----------------------------------------------------------------------

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

  -- Interlock
  trig_1_channel_intlk.pulse <= intlk;
  trig_2_channel_intlk.pulse <= intlk;

  trig_1_pm_channel_intlk.pulse <= '0';
  trig_2_pm_channel_intlk.pulse <= '0';

  -- Assign intern triggers to trigger module
  trig_rcv_intern(c_TRIG_MUX_0_ID, c_TRIG_RCV_INTERN_CHAN_1_ID)     <= trig_fmc1_channel_1;
  trig_rcv_intern(c_TRIG_MUX_0_ID, c_TRIG_RCV_INTERN_CHAN_2_ID)     <= trig_fmc1_channel_2;
  trig_rcv_intern(c_TRIG_MUX_0_ID, c_TRIG_RCV_INTERN_CHAN_INTLK_ID) <= trig_1_channel_intlk;
  trig_rcv_intern(c_TRIG_MUX_1_ID, c_TRIG_RCV_INTERN_CHAN_1_ID)     <= trig_fmc2_channel_1;
  trig_rcv_intern(c_TRIG_MUX_1_ID, c_TRIG_RCV_INTERN_CHAN_2_ID)     <= trig_fmc2_channel_2;
  trig_rcv_intern(c_TRIG_MUX_1_ID, c_TRIG_RCV_INTERN_CHAN_INTLK_ID) <= trig_2_channel_intlk;

  -- Post-Mortem triggers
  trig_rcv_intern(c_TRIG_MUX_2_ID, c_TRIG_RCV_INTERN_CHAN_1_ID)     <= trig_fmc1_pm_channel_1;
  trig_rcv_intern(c_TRIG_MUX_2_ID, c_TRIG_RCV_INTERN_CHAN_2_ID)     <= trig_fmc1_pm_channel_2;
  trig_rcv_intern(c_TRIG_MUX_2_ID, c_TRIG_RCV_INTERN_CHAN_INTLK_ID) <= trig_1_pm_channel_intlk;
  trig_rcv_intern(c_TRIG_MUX_3_ID, c_TRIG_RCV_INTERN_CHAN_1_ID)     <= trig_fmc2_pm_channel_1;
  trig_rcv_intern(c_TRIG_MUX_3_ID, c_TRIG_RCV_INTERN_CHAN_2_ID)     <= trig_fmc2_pm_channel_2;
  trig_rcv_intern(c_TRIG_MUX_3_ID, c_TRIG_RCV_INTERN_CHAN_INTLK_ID) <= trig_2_pm_channel_intlk;

end rtl;
