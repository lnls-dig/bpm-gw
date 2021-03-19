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

library work;
-- FMC516 definitions
use work.fmc_adc_pkg.all;
-- IP cores constants
use work.ipcores_pkg.all;
-- AFC definitions
use work.afc_base_pkg.all;

entity dbe_bpm2_with_dcc is
generic (
  g_NUM_SFPS                                 : integer := 4;
  g_SFP_START_ID                             : integer := 4
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

  -- EEPROM (Connected to the CPU). Use board I2C pins if needed as they are
  -- behind a I2C switch that can access FMC I2C bus
  --eeprom_scl_pad_b                          : inout std_logic;
  --eeprom_sda_pad_b                          : inout std_logic;

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
end dbe_bpm2_with_dcc;

architecture rtl of dbe_bpm2_with_dcc is

  ---------------------------
  --      Components       --
  ---------------------------

  component dbe_bpm_gen
  generic(
    g_fmc_adc_type                             : string := "FMC250M";
    g_WITH_RTM_SFP                             : boolean := false;
    g_NUM_SFPS                                 : integer := 4;
    g_SFP_START_ID                             : integer := 4;
    g_WITH_FOFB_DCC                            : boolean := false
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
  end component;

begin

  cmp_dbe_bpm_gen : dbe_bpm_gen
  generic map (
    g_fmc_adc_type                            => "FMC250M",
    g_WITH_RTM_SFP                            => true,
    g_NUM_SFPS                                => g_NUM_SFPS,
    g_SFP_START_ID                            => g_SFP_START_ID,
    g_WITH_FOFB_DCC                           => true
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

    -----------------------------
    -- FMC1_250m_4ch ports
    -----------------------------

    -- ADC clock (half of the sampling frequency) divider reset
    fmc250_1_adc_clk_div_rst_p_o              => fmc1_adc_clk_div_rst_p_o,
    fmc250_1_adc_clk_div_rst_n_o              => fmc1_adc_clk_div_rst_n_o,
    fmc250_1_adc_ext_rst_n_o                  => fmc1_adc_ext_rst_n_o,
    fmc250_1_adc_sleep_o                      => fmc1_adc_sleep_o,

    -- ADC clocks. One clock per ADC channel.
    -- Only ch1 clock is used as all data chains
    -- are sampled at the same frequency
    fmc250_1_adc_clk0_p_i                     => fmc1_adc_clk0_p_i,
    fmc250_1_adc_clk0_n_i                     => fmc1_adc_clk0_n_i,
    fmc250_1_adc_clk1_p_i                     => fmc1_adc_clk1_p_i,
    fmc250_1_adc_clk1_n_i                     => fmc1_adc_clk1_n_i,
    fmc250_1_adc_clk2_p_i                     => fmc1_adc_clk2_p_i,
    fmc250_1_adc_clk2_n_i                     => fmc1_adc_clk2_n_i,
    fmc250_1_adc_clk3_p_i                     => fmc1_adc_clk3_p_i,
    fmc250_1_adc_clk3_n_i                     => fmc1_adc_clk3_n_i,

    -- DDR ADC data channels.
    fmc250_1_adc_data_ch0_p_i                 => fmc1_adc_data_ch0_p_i,
    fmc250_1_adc_data_ch0_n_i                 => fmc1_adc_data_ch0_n_i,
    fmc250_1_adc_data_ch1_p_i                 => fmc1_adc_data_ch1_p_i,
    fmc250_1_adc_data_ch1_n_i                 => fmc1_adc_data_ch1_n_i,
    fmc250_1_adc_data_ch2_p_i                 => fmc1_adc_data_ch2_p_i,
    fmc250_1_adc_data_ch2_n_i                 => fmc1_adc_data_ch2_n_i,
    fmc250_1_adc_data_ch3_p_i                 => fmc1_adc_data_ch3_p_i,
    fmc250_1_adc_data_ch3_n_i                 => fmc1_adc_data_ch3_n_i,

    ---- FMC General Status
    --fmc250_1_prsnt_i                          : in std_logic := '0';
    --fmc250_1_pg_m2c_i                         : in std_logic := '0';
    --fmc250_1_clk_dir_i                        : in std_logic := '0';

    -- Trigger
    fmc250_1_trig_dir_o                       => fmc1_trig_dir_o,
    fmc250_1_trig_term_o                      => fmc1_trig_term_o,
    fmc250_1_trig_val_p_b                     => fmc1_trig_val_p_b,
    fmc250_1_trig_val_n_b                     => fmc1_trig_val_n_b,

    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    fmc250_1_adc_spi_clk_o                    => fmc1_adc_spi_clk_o,
    fmc250_1_adc_spi_mosi_o                   => fmc1_adc_spi_mosi_o,
    fmc250_1_adc_spi_miso_i                   => fmc1_adc_spi_miso_i,
    fmc250_1_adc_spi_cs_adc0_n_o              => fmc1_adc_spi_cs_adc0_n_o,
    fmc250_1_adc_spi_cs_adc1_n_o              => fmc1_adc_spi_cs_adc1_n_o,
    fmc250_1_adc_spi_cs_adc2_n_o              => fmc1_adc_spi_cs_adc2_n_o,
    fmc250_1_adc_spi_cs_adc3_n_o              => fmc1_adc_spi_cs_adc3_n_o,

    -- Si571 clock gen
    fmc250_1_si571_scl_pad_b                  => fmc1_si571_scl_pad_b,
    fmc250_1_si571_sda_pad_b                  => fmc1_si571_sda_pad_b,
    fmc250_1_si571_oe_o                       => fmc1_si571_oe_o,

    -- AD9510 clock distribution PLL
    fmc250_1_spi_ad9510_cs_o                  => fmc1_spi_ad9510_cs_o,
    fmc250_1_spi_ad9510_sclk_o                => fmc1_spi_ad9510_sclk_o,
    fmc250_1_spi_ad9510_mosi_o                => fmc1_spi_ad9510_mosi_o,
    fmc250_1_spi_ad9510_miso_i                => fmc1_spi_ad9510_miso_i,

    fmc250_1_pll_function_o                   => fmc1_pll_function_o,
    fmc250_1_pll_status_i                     => fmc1_pll_status_i,

    -- AD9510 clock copy
    fmc250_1_fpga_clk_p_i                     => fmc1_fpga_clk_p_i,
    fmc250_1_fpga_clk_n_i                     => fmc1_fpga_clk_n_i,

    -- Clock reference selection (TS3USB221)
    fmc250_1_clk_sel_o                        => fmc1_clk_sel_o,

    -- EEPROM (Connected to the CPU). Use board I2C pins if needed as they are
    -- behind a I2C switch that can access FMC I2C bus
    --eeprom_scl_pad_b                         : inout std_logic;
    --eeprom_sda_pad_b                         : inout std_logic;

    -- AMC7823 temperature monitor
    fmc250_1_amc7823_spi_cs_o                 => fmc1_amc7823_spi_cs_o,
    fmc250_1_amc7823_spi_sclk_o               => fmc1_amc7823_spi_sclk_o,
    fmc250_1_amc7823_spi_mosi_o               => fmc1_amc7823_spi_mosi_o,
    fmc250_1_amc7823_spi_miso_i               => fmc1_amc7823_spi_miso_i,
    fmc250_1_amc7823_davn_i                   => fmc1_amc7823_davn_i,

    -- FMC LEDs
    fmc250_1_led1_o                           => fmc1_led1_o,
    fmc250_1_led2_o                           => fmc1_led2_o,
    fmc250_1_led3_o                           => fmc1_led3_o,

    -----------------------------
    -- FMC2_250m_4ch ports
    -----------------------------
    -- ADC clock (half of the sampling frequency) divider reset
    fmc250_2_adc_clk_div_rst_p_o              => fmc2_adc_clk_div_rst_p_o,
    fmc250_2_adc_clk_div_rst_n_o              => fmc2_adc_clk_div_rst_n_o,
    fmc250_2_adc_ext_rst_n_o                  => fmc2_adc_ext_rst_n_o,
    fmc250_2_adc_sleep_o                      => fmc2_adc_sleep_o,

    -- ADC clocks. One clock per ADC channel.
    -- Only ch1 clock is used as all data chains
    -- are sampled at the same frequency
    fmc250_2_adc_clk0_p_i                     => fmc2_adc_clk0_p_i,
    fmc250_2_adc_clk0_n_i                     => fmc2_adc_clk0_n_i,
    fmc250_2_adc_clk1_p_i                     => fmc2_adc_clk1_p_i,
    fmc250_2_adc_clk1_n_i                     => fmc2_adc_clk1_n_i,
    fmc250_2_adc_clk2_p_i                     => fmc2_adc_clk2_p_i,
    fmc250_2_adc_clk2_n_i                     => fmc2_adc_clk2_n_i,
    fmc250_2_adc_clk3_p_i                     => fmc2_adc_clk3_p_i,
    fmc250_2_adc_clk3_n_i                     => fmc2_adc_clk3_n_i,

    -- DDR ADC data channels.
    fmc250_2_adc_data_ch0_p_i                 => fmc2_adc_data_ch0_p_i,
    fmc250_2_adc_data_ch0_n_i                 => fmc2_adc_data_ch0_n_i,
    fmc250_2_adc_data_ch1_p_i                 => fmc2_adc_data_ch1_p_i,
    fmc250_2_adc_data_ch1_n_i                 => fmc2_adc_data_ch1_n_i,
    fmc250_2_adc_data_ch2_p_i                 => fmc2_adc_data_ch2_p_i,
    fmc250_2_adc_data_ch2_n_i                 => fmc2_adc_data_ch2_n_i,
    fmc250_2_adc_data_ch3_p_i                 => fmc2_adc_data_ch3_p_i,
    fmc250_2_adc_data_ch3_n_i                 => fmc2_adc_data_ch3_n_i,

    ---- FMC General Status
    --fmc250_2_prsnt_i                          : in std_logic := '0';
    --fmc250_2_pg_m2c_i                         : in std_logic := '0';
    --fmc250_2_clk_dir_i                        : in std_logic := '0';

    -- Trigger
    fmc250_2_trig_dir_o                       => fmc2_trig_dir_o,
    fmc250_2_trig_term_o                      => fmc2_trig_term_o,
    fmc250_2_trig_val_p_b                     => fmc2_trig_val_p_b,
    fmc250_2_trig_val_n_b                     => fmc2_trig_val_n_b,

    -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
    fmc250_2_adc_spi_clk_o                    => fmc2_adc_spi_clk_o,
    fmc250_2_adc_spi_mosi_o                   => fmc2_adc_spi_mosi_o,
    fmc250_2_adc_spi_miso_i                   => fmc2_adc_spi_miso_i,
    fmc250_2_adc_spi_cs_adc0_n_o              => fmc2_adc_spi_cs_adc0_n_o,
    fmc250_2_adc_spi_cs_adc1_n_o              => fmc2_adc_spi_cs_adc1_n_o,
    fmc250_2_adc_spi_cs_adc2_n_o              => fmc2_adc_spi_cs_adc2_n_o,
    fmc250_2_adc_spi_cs_adc3_n_o              => fmc2_adc_spi_cs_adc3_n_o,

    -- Si571 clock gen
    fmc250_2_si571_scl_pad_b                  => fmc2_si571_scl_pad_b,
    fmc250_2_si571_sda_pad_b                  => fmc2_si571_sda_pad_b,
    fmc250_2_si571_oe_o                       => fmc2_si571_oe_o,

    -- AD9510 clock distribution PLL
    fmc250_2_spi_ad9510_cs_o                  => fmc2_spi_ad9510_cs_o,
    fmc250_2_spi_ad9510_sclk_o                => fmc2_spi_ad9510_sclk_o,
    fmc250_2_spi_ad9510_mosi_o                => fmc2_spi_ad9510_mosi_o,
    fmc250_2_spi_ad9510_miso_i                => fmc2_spi_ad9510_miso_i,

    fmc250_2_pll_function_o                   => fmc2_pll_function_o,
    fmc250_2_pll_status_i                     => fmc2_pll_status_i,

    -- AD9510 clock copy
    fmc250_2_fpga_clk_p_i                     => fmc2_fpga_clk_p_i,
    fmc250_2_fpga_clk_n_i                     => fmc2_fpga_clk_n_i,

    -- Clock reference selection (TS3USB221)
    fmc250_2_clk_sel_o                        => fmc2_clk_sel_o,

    -- EEPROM (Connected to the CPU)
    --eeprom_scl_pad_b                         : inout std_logic;
    --eeprom_sda_pad_b                         : inout std_logic;

    -- AMC7823 temperature monitor
    fmc250_2_amc7823_spi_cs_o                 => fmc2_amc7823_spi_cs_o,
    fmc250_2_amc7823_spi_sclk_o               => fmc2_amc7823_spi_sclk_o,
    fmc250_2_amc7823_spi_mosi_o               => fmc2_amc7823_spi_mosi_o,
    fmc250_2_amc7823_spi_miso_i               => fmc2_amc7823_spi_miso_i,
    fmc250_2_amc7823_davn_i                   => fmc2_amc7823_davn_i,

    -- FMC LEDs
    fmc250_2_led1_o                           => fmc2_led1_o,
    fmc250_2_led2_o                           => fmc2_led2_o,
    fmc250_2_led3_o                           => fmc2_led3_o,

    ---------------------------------------------------------------------------
    -- RTM board pins
    ---------------------------------------------------------------------------

    -- SFP
    rtm_sfp_rx_p_i                             => rtm_sfp_rx_p_i,
    rtm_sfp_rx_n_i                             => rtm_sfp_rx_n_i,
    rtm_sfp_tx_p_o                             => rtm_sfp_tx_p_o,
    rtm_sfp_tx_n_o                             => rtm_sfp_tx_n_o,

    -- RTM I2C.
    -- SFP configuration pins, behind a I2C MAX7356. I2C addr = 1110_100 & '0' = 0xE8
    -- Si570 oscillator. Input 0 of CDCLVD1212. I2C addr = 1010101 & '0' = 0x55
    rtm_scl_b                                  => rtm_scl_b,
    rtm_sda_b                                  => rtm_sda_b,

    -- Si570 oscillator output enable
    rtm_si570_oe_o                             => rtm_si570_oe_o,

    ---- Clock to RTM connector. Input 1 of CDCLVD1212. Not connected to FPGA
    -- rtm_sync_clk_p_o                           => rtm_sync_clk_p_o,
    -- rtm_sync_clk_n_o                           => rtm_sync_clk_n_o,

    -- Select between input 0 or 1 or CDCLVD1212. 0 is Si570, 1 is RTM sync clock
    rtm_clk_in_sel_o                           => rtm_clk_in_sel_o,

    -- FPGA clocks from CDCLVD1212
    rtm_fpga_clk1_p_i                          => rtm_fpga_clk1_p_i,
    rtm_fpga_clk1_n_i                          => rtm_fpga_clk1_n_i,
    rtm_fpga_clk2_p_i                          => rtm_fpga_clk2_p_i,
    rtm_fpga_clk2_n_i                          => rtm_fpga_clk2_n_i,

    -- SFP status bits. Behind 4 74HC165, 8-parallel-in/serial-out. 4 x 8 bits.
    --
    -- Parallel load
    rtm_sfp_status_reg_pl_o                    => rtm_sfp_status_reg_pl_o,
    -- Clock N
    rtm_sfp_status_reg_clk_n_o                 => rtm_sfp_status_reg_clk_n_o,
    -- Serial output
    rtm_sfp_status_reg_out_i                   => rtm_sfp_status_reg_out_i,

    -- SFP control bits. Behind 4 74HC4094D, serial-in/8-parallel-out. 5 x 8 bits.
    --
    -- Strobe
    rtm_sfp_ctl_str_n_o                        => rtm_sfp_ctl_str_n_o,
    -- Data input
    rtm_sfp_ctl_din_n_o                        => rtm_sfp_ctl_din_n_o,
    -- Parallel output enable
    rtm_sfp_ctl_oe_n_o                         => rtm_sfp_ctl_oe_n_o,

    -- External clock from RTM to FPGA
    rtm_ext_clk_p_i                            => rtm_ext_clk_p_i,
    rtm_ext_clk_n_i                            => rtm_ext_clk_n_i
  );

end rtl;
