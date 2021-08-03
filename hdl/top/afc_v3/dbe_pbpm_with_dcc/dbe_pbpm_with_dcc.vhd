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

entity dbe_pbpm_with_dcc is
generic (
  -- Number of RTM SFP GTs
  g_NUM_SFPS                                 : integer := 1;
  -- Start index of the RTM SFP GTs
  g_SFP_START_ID                             : integer := 4;
  -- Number of P2P GTs
  g_NUM_P2P_GTS                              : integer := 8;
  -- Start index of the P2P GTs
  g_P2P_GT_START_ID                          : integer := 0
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

  -----------------------------------------
  -- FMC PICO 1M_4CH Ports
  -----------------------------------------

  fmc1_adc_cnv_o                             : out std_logic;
  fmc1_adc_sck_o                             : out std_logic;
  fmc1_adc_sck_rtrn_i                        : in std_logic;
  fmc1_adc_sdo1_i                            : in std_logic;
  fmc1_adc_sdo2_i                            : in std_logic;
  fmc1_adc_sdo3_i                            : in std_logic;
  fmc1_adc_sdo4_i                            : in std_logic;
  fmc1_adc_busy_cmn_i                        : in std_logic;

  fmc1_rng_r1_o                              : out std_logic;
  fmc1_rng_r2_o                              : out std_logic;
  fmc1_rng_r3_o                              : out std_logic;
  fmc1_rng_r4_o                              : out std_logic;

  fmc1_led1_o                                : out std_logic;
  fmc1_led2_o                                : out std_logic;

  -- EEPROM (Connected to the CPU). Use board I2C pins if needed as they are
  -- behind a I2C switch that can access FMC I2C bus
  -- fmc1_sm_scl_o                         : out std_logic;
  -- fmc1_sm_sda_b                         : inout std_logic;

  fmc1_a_scl_o                               : out std_logic;
  fmc1_a_sda_b                               : inout std_logic;

  -----------------------------------------
  -- FMC PICO 1M_4CH Ports
  -----------------------------------------

  fmc2_adc_cnv_o                             : out std_logic;
  fmc2_adc_sck_o                             : out std_logic;
  fmc2_adc_sck_rtrn_i                        : in std_logic;
  fmc2_adc_sdo1_i                            : in std_logic;
  fmc2_adc_sdo2_i                            : in std_logic;
  fmc2_adc_sdo3_i                            : in std_logic;
  fmc2_adc_sdo4_i                            : in std_logic;
  fmc2_adc_busy_cmn_i                        : in std_logic;

  fmc2_rng_r1_o                              : out std_logic;
  fmc2_rng_r2_o                              : out std_logic;
  fmc2_rng_r3_o                              : out std_logic;
  fmc2_rng_r4_o                              : out std_logic;

  fmc2_led1_o                                : out std_logic;
  fmc2_led2_o                                : out std_logic;

  -- Connected through FPGA MUX. Use board I2C pins if needed as they are
  -- behind a I2C switch that can access FMC I2C bus
  --fmc2_sm_scl_o                              : out std_logic;
  --fmc2_sm_sda_b                              : inout std_logic;

  fmc2_a_scl_o                               : out std_logic;
  fmc2_a_sda_b                               : inout std_logic
);
end dbe_pbpm_with_dcc;

architecture rtl of dbe_pbpm_with_dcc is

begin

  cmp_dbe_bpm_gen : entity work.dbe_bpm_gen
  generic map (
    g_fmc_adc_type                           => "FMCPICO_1M",
    g_WITH_RTM_SFP                           => false,
    g_NUM_SFPS                               => 1,
    g_SFP_START_ID                           => 4,
    g_WITH_RTM_SFP_FOFB_DCC                  => false,
    g_NUM_P2P_GTS                            => g_NUM_P2P_GTS,
    g_P2P_GT_START_ID                        => g_P2P_GT_START_ID,
    g_WITH_P2P_FOFB_DCC                      => true
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

    ---------------------------------------------------------------------------
    -- P2P GT pins
    ---------------------------------------------------------------------------
    -- P2P
    p2p_gt_rx_p_i                              => p2p_gt_rx_p_i,
    p2p_gt_rx_n_i                              => p2p_gt_rx_n_i,
    p2p_gt_tx_p_o                              => p2p_gt_tx_p_o,
    p2p_gt_tx_n_o                              => p2p_gt_tx_n_o,

    -----------------------------------------
    -- FMC PICO 1M_4CH Ports
    -----------------------------------------

    fmcpico_1_adc_cnv_o                        => fmc1_adc_cnv_o,
    fmcpico_1_adc_sck_o                        => fmc1_adc_sck_o,
    fmcpico_1_adc_sck_rtrn_i                   => fmc1_adc_sck_rtrn_i,
    fmcpico_1_adc_sdo1_i                       => fmc1_adc_sdo1_i,
    fmcpico_1_adc_sdo2_i                       => fmc1_adc_sdo2_i,
    fmcpico_1_adc_sdo3_i                       => fmc1_adc_sdo3_i,
    fmcpico_1_adc_sdo4_i                       => fmc1_adc_sdo4_i,
    fmcpico_1_adc_busy_cmn_i                   => fmc1_adc_busy_cmn_i,

    fmcpico_1_rng_r1_o                         => fmc1_rng_r1_o,
    fmcpico_1_rng_r2_o                         => fmc1_rng_r2_o,
    fmcpico_1_rng_r3_o                         => fmc1_rng_r3_o,
    fmcpico_1_rng_r4_o                         => fmc1_rng_r4_o,

    fmcpico_1_led1_o                           => fmc1_led1_o,
    fmcpico_1_led2_o                           => fmc1_led2_o,

    ---- Connected through FPGA MUX. Use board I2C, if needed
    --fmcpico_1_sm_scl_o                         => fmc1_sm_scl_o,
    --fmcpico_1_sm_sda_b                         => fmc1_sm_sda_b,

    fmcpico_1_a_scl_o                          => fmc1_a_scl_o,
    fmcpico_1_a_sda_b                          => fmc1_a_sda_b,

    -----------------------------------------
    -- FMC PICO 1M_4CH Ports
    -----------------------------------------
    fmcpico_2_adc_cnv_o                        => fmc2_adc_cnv_o,
    fmcpico_2_adc_sck_o                        => fmc2_adc_sck_o,
    fmcpico_2_adc_sck_rtrn_i                   => fmc2_adc_sck_rtrn_i,
    fmcpico_2_adc_sdo1_i                       => fmc2_adc_sdo1_i,
    fmcpico_2_adc_sdo2_i                       => fmc2_adc_sdo2_i,
    fmcpico_2_adc_sdo3_i                       => fmc2_adc_sdo3_i,
    fmcpico_2_adc_sdo4_i                       => fmc2_adc_sdo4_i,
    fmcpico_2_adc_busy_cmn_i                   => fmc2_adc_busy_cmn_i,

    fmcpico_2_rng_r1_o                         => fmc2_rng_r1_o,
    fmcpico_2_rng_r2_o                         => fmc2_rng_r2_o,
    fmcpico_2_rng_r3_o                         => fmc2_rng_r3_o,
    fmcpico_2_rng_r4_o                         => fmc2_rng_r4_o,

    fmcpico_2_led1_o                           => fmc2_led1_o,
    fmcpico_2_led2_o                           => fmc2_led2_o,

    -- Connected through FPGA MUX. Use board I2C, if needed
    --fmcpico_2_sm_scl_o                         => fmc2_sm_scl_o,
    --fmcpico_2_sm_sda_b                         => fmc2_sm_sda_b,

    fmcpico_2_a_scl_o                          => fmc2_a_scl_o,
    fmcpico_2_a_sda_b                          => fmc2_a_sda_b

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
