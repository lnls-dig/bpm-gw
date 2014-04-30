------------------------------------------------------------------------------
-- Title      : Top FMC516 design
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-09-26
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top design for testing the integration/control between pcie and
--               the crossbar
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-09-26  1.0      lucas.russo        Created
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
use work.dbe_wishbone_pkg.all;
-- Wishbone stream modules and interface
use work.wb_stream_generic_pkg.all;
-- Ethernet MAC Modules and SDB structure
use work.ethmac_pkg.all;
-- Wishbone Fabric interface
use work.wr_fabric_pkg.all;
-- Etherbone slave core
use work.etherbone_pkg.all;
-- FMC516 definitions
use work.fmc_adc_pkg.all;
-- Data Acquisition core
use work.acq_core_pkg.all;
-- PCIe Core
use work.bpm_pcie_ml605_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dbe_bpm_fmc130m_4ch_pcie is
generic(
  -- PCIe Lanes
  g_pcieLanes                               : integer := 4;
  -- PCIE Constants. TEMPORARY!
  constant pcieLanes                        : integer := 4;
  constant DDR_DQ_WIDTH                     : integer := 64;
  constant DDR_PAYLOAD_WIDTH                : integer := 256;
  constant DDR_DQS_WIDTH                    : integer := 8;
  constant DDR_DM_WIDTH                     : integer := 8;
  constant DDR_ROW_WIDTH                    : integer := 14;
  constant DDR_BANK_WIDTH                   : integer := 3;
  constant DDR_CK_WIDTH                     : integer := 1;
  constant DDR_CKE_WIDTH                    : integer := 1;
  constant DDR_ODT_WIDTH                    : integer := 1
);
port(
  -----------------------------------------
  -- Clocking pins
  -----------------------------------------
  sys_clk_p_i                               : in std_logic;
  sys_clk_n_i                               : in std_logic;

  -----------------------------------------
  -- Reset Button
  -----------------------------------------
  sys_rst_button_i                          : in std_logic;

  -----------------------------------------
  -- UART pins
  -----------------------------------------

  rs232_txd_o                                : out std_logic;
  rs232_rxd_i                                : in std_logic;

  -----------------------------------------
  -- PHY pins
  -----------------------------------------

  -- Clock and resets to PHY (GMII). Not used in MII mode (10/100)
  mgtx_clk_o                                : out std_logic;
  mrstn_o                                   : out std_logic;

  -- PHY TX
  mtx_clk_pad_i                             : in std_logic;
  mtxd_pad_o                                : out std_logic_vector(3 downto 0);
  mtxen_pad_o                               : out std_logic;
  mtxerr_pad_o                              : out std_logic;

  -- PHY RX
  mrx_clk_pad_i                             : in std_logic;
  mrxd_pad_i                                : in std_logic_vector(3 downto 0);
  mrxdv_pad_i                               : in std_logic;
  mrxerr_pad_i                              : in std_logic;
  mcoll_pad_i                               : in std_logic;
  mcrs_pad_i                                : in std_logic;

  -- MII
  mdc_pad_o                                 : out std_logic;
  md_pad_b                                  : inout std_logic;

  -----------------------------
  -- FMC130m_4ch ports
  -----------------------------

  -- ADC LTC2208 interface
  fmc_adc_pga_o                             : out std_logic;
  fmc_adc_shdn_o                            : out std_logic;
  fmc_adc_dith_o                            : out std_logic;
  fmc_adc_rand_o                            : out std_logic;

  -- ADC0 LTC2208
  fmc_adc0_clk_i                            : in std_logic;
  fmc_adc0_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0);
  fmc_adc0_of_i                             : in std_logic; -- Unused

  -- ADC1 LTC2208
  fmc_adc1_clk_i                            : in std_logic;
  fmc_adc1_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0);
  fmc_adc1_of_i                             : in std_logic; -- Unused

  -- ADC2 LTC2208
  fmc_adc2_clk_i                            : in std_logic;
  fmc_adc2_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0);
  fmc_adc2_of_i                             : in std_logic; -- Unused

  -- ADC3 LTC2208
  fmc_adc3_clk_i                            : in std_logic;
  fmc_adc3_data_i                           : in std_logic_vector(c_num_adc_bits-1 downto 0);
  fmc_adc3_of_i                             : in std_logic; -- Unused

  -- FMC General Status
  fmc_prsnt_i                               : in std_logic;
  fmc_pg_m2c_i                              : in std_logic;
  --fmc_clk_dir_i                           : in std_logic;, -- not supported on Kintex7 KC705 board

  -- Trigger
  fmc_trig_dir_o                            : out std_logic;
  fmc_trig_term_o                           : out std_logic;
  fmc_trig_val_p_b                          : inout std_logic;
  fmc_trig_val_n_b                          : inout std_logic;

  -- Si571 clock gen
  si571_scl_pad_b                           : inout std_logic;
  si571_sda_pad_b                           : inout std_logic;
  fmc_si571_oe_o                            : out std_logic;

  -- AD9510 clock distribution PLL
  spi_ad9510_cs_o                           : out std_logic;
  spi_ad9510_sclk_o                         : out std_logic;
  spi_ad9510_mosi_o                         : out std_logic;
  spi_ad9510_miso_i                         : in std_logic;

  fmc_pll_function_o                        : out std_logic;
  fmc_pll_status_i                          : in std_logic;

  -- AD9510 clock copy
  fmc_fpga_clk_p_i                          : in std_logic;
  fmc_fpga_clk_n_i                          : in std_logic;

  -- Clock reference selection (TS3USB221)
  fmc_clk_sel_o                             : out std_logic;

  -- EEPROM
  eeprom_scl_pad_b                          : inout std_logic;
  eeprom_sda_pad_b                          : inout std_logic;

  -- Temperature monitor
  -- LM75AIMM
  lm75_scl_pad_b                            : inout std_logic;
  lm75_sda_pad_b                            : inout std_logic;

  fmc_lm75_temp_alarm_i                     : in std_logic;

  -- FMC LEDs
  fmc_led1_o                                : out std_logic;
  fmc_led2_o                                : out std_logic;
  fmc_led3_o                                : out std_logic;

  -----------------------------------------
  -- General board status
  -----------------------------------------
  fmc_mmcm_lock_led_o                       : out std_logic;
  fmc_pll_status_led_o                      : out std_logic;

  -----------------------------------------
  -- PCIe pins
  -----------------------------------------

  -- DDR3 memory pins
  ddr3_dq_b                                 : inout std_logic_vector(DDR_DQ_WIDTH-1 downto 0);
  ddr3_dqs_p_b                              : inout std_logic_vector(DDR_DQS_WIDTH-1 downto 0);
  ddr3_dqs_n_b                              : inout std_logic_vector(DDR_DQS_WIDTH-1 downto 0);
  ddr3_addr_o                               : out   std_logic_vector(DDR_ROW_WIDTH-1 downto 0);
  ddr3_ba_o                                 : out   std_logic_vector(DDR_BANK_WIDTH-1 downto 0);
  ddr3_cs_n_o                               : out   std_logic_vector(0 downto 0);
  ddr3_ras_n_o                              : out   std_logic;
  ddr3_cas_n_o                              : out   std_logic;
  ddr3_we_n_o                               : out   std_logic;
  ddr3_reset_n_o                            : out   std_logic;
  ddr3_ck_p_o                               : out   std_logic_vector(DDR_CK_WIDTH-1 downto 0);
  ddr3_ck_n_o                               : out   std_logic_vector(DDR_CK_WIDTH-1 downto 0);
  ddr3_cke_o                                : out   std_logic_vector(DDR_CKE_WIDTH-1 downto 0);
  ddr3_dm_o                                 : out   std_logic_vector(DDR_DM_WIDTH-1 downto 0);
  ddr3_odt_o                                : out   std_logic_vector(DDR_ODT_WIDTH-1 downto 0);

  -- PCIe transceivers
  pci_exp_rxp_i                             : in  std_logic_vector(g_pcieLanes - 1 downto 0);
  pci_exp_rxn_i                             : in  std_logic_vector(g_pcieLanes - 1 downto 0);
  pci_exp_txp_o                             : out std_logic_vector(g_pcieLanes - 1 downto 0);
  pci_exp_txn_o                             : out std_logic_vector(g_pcieLanes - 1 downto 0);

  -- PCI clock and reset signals
  pcie_rst_n_i                              : in std_logic;
  pcie_clk_p_i                              : in std_logic;
  pcie_clk_n_i                              : in std_logic;

  -----------------------------------------
  -- Button pins
  -----------------------------------------
  --buttons_i                                 : in std_logic_vector(7 downto 0);

  -----------------------------------------
  -- User LEDs
  -----------------------------------------

  -- Directional leds
  --led_south_o                               : out std_logic;
  --led_east_o                                : out std_logic;
  --led_north_o                               : out std_logic;

  -- GPIO leds
  leds_o                                    : out std_logic_vector(7 downto 0)
);
end dbe_bpm_fmc130m_4ch_pcie;

architecture rtl of dbe_bpm_fmc130m_4ch_pcie is

  -- Top crossbar layout
  -- Number of slaves
  constant c_slaves                         : natural := 10;
  -- General Dual-port memory, Buffer Single-port memory, DMA control port, MAC,
  --Etherbone, FMC516, Peripherals
  -- Number of masters
  --constant c_masters                        : natural := 9;            -- LM32 master, Data + Instruction,
  --DMA read+write master, Ethernet MAC, Ethernet MAC adapter read+write master, Etherbone, RS232-Syscon
  constant c_masters                        : natural := 8;            -- RS232-Syscon,
  --DMA read+write master, Ethernet MAC, Ethernet MAC adapter read+write master, Etherbone, PCIe

  --constant c_dpram_size                     : natural := 131072/4; -- in 32-bit words (128KB)
  constant c_dpram_size                     : natural := 90112/4; -- in 32-bit words (90KB)
  --constant c_dpram_ethbuf_size              : natural := 32768/4; -- in 32-bit words (32KB)
  constant c_dpram_ethbuf_size              : natural := 65536/4; -- in 32-bit words (64KB)

  constant c_acq_fifo_size                  : natural := 256;

  -- TEMPORARY! DON'T TOUCH!
  --constant c_acq_data_width                 : natural := 64;
  constant c_acq_addr_width                 : natural := 28;
  constant c_acq_ddr_payload_width          : natural := DDR_PAYLOAD_WIDTH; -- DDR3 UI (256 bits)
  constant c_acq_ddr_addr_width             : natural := 28;
  constant c_acq_ddr_addr_res_width         : natural := 32;
  constant c_acq_ddr_addr_diff              : natural := c_acq_ddr_addr_res_width-c_acq_ddr_addr_width;
  constant c_acq_adc_id                     : natural := 0;
  constant c_acq_tbt_id                     : natural := 1;
  constant c_acq_fofb_id                    : natural := 2;
  constant c_acq_monit_id                   : natural := 3;
  constant c_acq_monit_1_id                 : natural := 4;
  constant c_acq_num_channels               : natural := 5; -- ADC + TBT + FOFB + MONIT + MONIT_1
  constant c_acq_channels                   : t_acq_chan_param_array(c_acq_num_channels-1 downto 0) :=
    ( c_acq_adc_id      => (width => to_unsigned(64, c_acq_chan_max_w_log2)),
      c_acq_tbt_id      => (width => to_unsigned(128, c_acq_chan_max_w_log2)),
      c_acq_fofb_id     => (width => to_unsigned(128, c_acq_chan_max_w_log2)),
      c_acq_monit_id    => (width => to_unsigned(128, c_acq_chan_max_w_log2)),
      c_acq_monit_1_id  => (width => to_unsigned(128, c_acq_chan_max_w_log2))
    );

  -- DDR3 constants
  constant c_ddr_dq_width                   : natural := 64;

  -- GPIO num pinscalc
  constant c_leds_num_pins                  : natural := 8;
  constant c_buttons_num_pins               : natural := 8;

  -- Counter width. It willl count up to 2^32 clock cycles
  constant c_counter_width                  : natural := 32;

  -- TICs counter period. 100MHz clock -> msec granularity
  constant c_tics_cntr_period               : natural := 100000;

  -- Number of reset clock cycles (FF)
  constant c_button_rst_width               : natural := 255;

  -- number of the ADC reference clock used for all downstream
  -- FPGA logic
  constant c_adc_ref_clk                    : natural := 1;

  -- Number of top level clocks
  constant c_num_tlvl_clks                  : natural := 2; -- CLK_SYS and CLK_200 MHz
  constant c_clk_sys_id                     : natural := 0; -- CLK_SYS and CLK_200 MHz
  constant c_clk_200mhz_id                  : natural := 1; -- CLK_SYS and CLK_200 MHz

  constant c_xwb_etherbone_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4", --32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000ff",
    product => (
    vendor_id     => x"0000000000000651", -- GSI
    device_id     => x"68202b22",
    version       => x"00000001",
    date          => x"20120912",
    name          => "GSI_ETHERBONE_CFG  ")));

  constant c_xwb_ethmac_adapter_sdb : t_sdb_device := (
    abi_class     => x"0000", -- undocumented device
    abi_ver_major => x"01",
    abi_ver_minor => x"01",
    wbd_endian    => c_sdb_endian_big,
    wbd_width     => x"4", --32-bit port granularity
    sdb_component => (
    addr_first    => x"0000000000000000",
    addr_last     => x"00000000000000ff",
    product => (
    vendor_id     => x"1000000000001215", -- LNLS
    device_id     => x"2ff9a28e",
    version       => x"00000001",
    date          => x"20130701",
    name          => "ETHMAC_ADAPTER     ")));

  -- FMC130m_4ch layout. Size (0x00000FFF) is larger than needed. Just to be sure
  -- no address overlaps will occur
  --constant c_fmc516_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000800");
  -- FMC130m_4ch
  constant c_fmc130m_4ch_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000800");

  -- General peripherals layout. UART, LEDs (GPIO), Buttons (GPIO) and Tics counter
  constant c_periph_bridge_sdb : t_sdb_bridge := f_xwb_bridge_manual_sdb(x"00000FFF", x"00000400");

  -- WB SDB (Self describing bus) layout
  --constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
  --  ( 0 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size),  x"00000000"),   -- 90KB RAM
  --    1 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size),  x"10000000"),   -- Second port to the same memory
  --    2 => f_sdb_embed_device(f_xwb_dpram(c_dpram_ethbuf_size),
  --                                                        x"20000000"),   -- 64KB RAM
  --    3 => f_sdb_embed_device(c_xwb_dma_sdb,              x"30004000"),   -- DMA control port
  --    4 => f_sdb_embed_device(c_xwb_ethmac_sdb,           x"30005000"),   -- Ethernet MAC control port
  --    5 => f_sdb_embed_device(c_xwb_ethmac_adapter_sdb,   x"30006000"),   -- Ethernet Adapter control port
  --    6 => f_sdb_embed_device(c_xwb_etherbone_sdb,        x"30007000"),   -- Etherbone control port
  --    7 => f_sdb_embed_bridge(c_fmc130m_4ch_bridge_sdb,   x"30010000"),   -- FMC130m_4ch control port
  --    8 => f_sdb_embed_bridge(c_periph_bridge_sdb,        x"30020000"),   -- General peripherals control port
  --    9 => f_sdb_embed_device(c_xwb_acq_core_sdb,         x"30030000")    -- Data Acquisition control port
  --  );
  -- Changed due to the limitation in PCIe addressing. Only up to 29 bits
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
    ( 0 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size),  x"00000000"),   -- 90KB RAM
      1 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size),  x"00100000"),   -- Second port to the same memory
      2 => f_sdb_embed_device(f_xwb_dpram(c_dpram_ethbuf_size),
                                                          x"00200000"),   -- 64KB RAM
      3 => f_sdb_embed_device(c_xwb_dma_sdb,              x"00304000"),   -- DMA control port
      4 => f_sdb_embed_device(c_xwb_ethmac_sdb,           x"00305000"),   -- Ethernet MAC control port
      5 => f_sdb_embed_device(c_xwb_ethmac_adapter_sdb,   x"00306000"),   -- Ethernet Adapter control port
      6 => f_sdb_embed_device(c_xwb_etherbone_sdb,        x"00307000"),   -- Etherbone control port
      7 => f_sdb_embed_bridge(c_fmc130m_4ch_bridge_sdb,   x"00310000"),   -- FMC130m_4ch control port
      8 => f_sdb_embed_bridge(c_periph_bridge_sdb,        x"00320000"),   -- General peripherals control port
      9 => f_sdb_embed_device(c_xwb_acq_core_sdb,         x"00330000")    -- Data Acquisition control port
    );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well
  constant c_sdb_address                    : t_wishbone_address := x"00300000";

  -- Crossbar master/slave arrays
  signal cbar_slave_i                       : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_o                       : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_i                      : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_o                      : t_wishbone_master_out_array(c_slaves-1 downto 0);

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
  signal dbg_app_wdf_data                   : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal dbg_app_wdf_end                    : std_logic;
  signal dbg_app_wdf_wren                   : std_logic;
  signal dbg_app_wdf_mask                   : std_logic_vector(DDR_PAYLOAD_WIDTH/8-1 downto 0);
  signal dbg_app_rd_data                    : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal dbg_app_rd_data_end                : std_logic;
  signal dbg_app_rd_data_valid              : std_logic;
  signal dbg_app_rdy                        : std_logic;
  signal dbg_app_wdf_rdy                    : std_logic;
  signal dbg_ddr_ui_clk                     : std_logic;
  signal dbg_ddr_ui_reset                   : std_logic;

  signal dbg_arb_req                        : std_logic_vector(1 downto 0);
  signal dbg_arb_gnt                        : std_logic_vector(1 downto 0);

  -- To/From Acquisition Core
  signal acq_chan_array                     : t_acq_chan_array(c_acq_num_channels-1 downto 0);

  signal bpm_acq_dpram_dout                 : std_logic_vector(f_acq_chan_find_widest(c_acq_channels)-1 downto 0);
  signal bpm_acq_dpram_valid                : std_logic;

  signal bpm_acq_ext_dout                   : std_logic_vector(f_acq_chan_find_widest(c_acq_channels)-1 downto 0);
  signal bpm_acq_ext_valid                  : std_logic;
  signal bpm_acq_ext_addr                   : std_logic_vector(c_acq_addr_width-1 downto 0);
  signal bpm_acq_ext_sof                    : std_logic;
  signal bpm_acq_ext_eof                    : std_logic;
  signal bpm_acq_ext_dreq                   : std_logic;
  signal bpm_acq_ext_stall                  : std_logic;

  signal memc_ui_clk                        : std_logic;
  signal memc_ui_rst                        : std_logic;
  signal memc_ui_rstn                       : std_logic;
  signal memc_cmd_rdy                       : std_logic;
  signal memc_cmd_en                        : std_logic;
  signal memc_cmd_instr                     : std_logic_vector(2 downto 0);
  signal memc_cmd_addr_resized              : std_logic_vector(c_acq_ddr_addr_res_width-1 downto 0);
  signal memc_cmd_addr                      : std_logic_vector(c_acq_ddr_addr_width-1 downto 0);
  signal memc_wr_en                         : std_logic;
  signal memc_wr_end                        : std_logic;
  signal memc_wr_mask                       : std_logic_vector(DDR_PAYLOAD_WIDTH/8-1 downto 0);
  signal memc_wr_data                       : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal memc_wr_rdy                        : std_logic;
  signal memc_rd_data                       : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal memc_rd_valid                      : std_logic;

  signal dbg_ddr_rb_data                    : std_logic_vector(f_acq_chan_find_widest(c_acq_channels)-1 downto 0);
  signal dbg_ddr_rb_addr                    : std_logic_vector(c_acq_addr_width-1 downto 0);
  signal dbg_ddr_rb_valid                   : std_logic;

  -- memory arbiter interface
  signal memarb_acc_req                     : std_logic;
  signal memarb_acc_gnt                     : std_logic;

  -- Clocks and resets signals
  signal locked                             : std_logic;
  signal clk_sys_rstn                       : std_logic;
  signal clk_sys_rst                        : std_logic;
  signal clk_200mhz_rst                     : std_logic;
  signal clk_200mhz_rstn                    : std_logic;

  signal rst_button_sys_pp                  : std_logic;
  signal rst_button_sys                     : std_logic;
  signal rst_button_sys_n                   : std_logic;

  signal rs232_rstn                         : std_logic;

  -- Only one clock domain
  signal reset_clks                         : std_logic_vector(c_num_tlvl_clks-1 downto 0);
  signal reset_rstn                         : std_logic_vector(c_num_tlvl_clks-1 downto 0);

  -- 200 Mhz clocck for iodelay_ctrl
  signal clk_200mhz                         : std_logic;

  -- Global Clock Single ended
  signal sys_clk_gen                        : std_logic;
  signal sys_clk_gen_bufg                   : std_logic;

  -- Ethernet MAC signals
  signal ethmac_int                         : std_logic;
  signal ethmac_md_in                       : std_logic;
  signal ethmac_md_out                      : std_logic;
  signal ethmac_md_oe                       : std_logic;

  signal mtxd_pad_int                       : std_logic_vector(3 downto 0);
  signal mtxen_pad_int                      : std_logic;
  signal mtxerr_pad_int                     : std_logic;
  signal mdc_pad_int                        : std_logic;

  -- Ethrnet MAC adapter signals
  signal irq_rx_done                        : std_logic;
  signal irq_tx_done                        : std_logic;

  -- Etherbone signals
  signal wb_ebone_out                       : t_wishbone_master_out;
  signal wb_ebone_in                        : t_wishbone_master_in;

  signal eb_src_i                           : t_wrf_source_in;
  signal eb_src_o                           : t_wrf_source_out;
  signal eb_snk_i                           : t_wrf_sink_in;
  signal eb_snk_o                           : t_wrf_sink_out;

  -- DMA signals
  signal dma_int                            : std_logic;

  -- FMC130m_4ch Signals
  signal wbs_fmc130m_4ch_in_array           : t_wbs_source_in16_array(c_num_adc_channels-1 downto 0);
  signal wbs_fmc130m_4ch_out_array          : t_wbs_source_out16_array(c_num_adc_channels-1 downto 0);

  signal fmc_mmcm_lock_int                  : std_logic;
  signal fmc_pll_status_int                 : std_logic;

  signal fmc_led1_int                       : std_logic;
  signal fmc_led2_int                       : std_logic;
  signal fmc_led3_int                       : std_logic;

  signal fmc_130m_4ch_clk                   : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc_130m_4ch_clk2x                 : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc_130m_4ch_data                  : std_logic_vector(c_num_adc_channels*c_num_adc_bits-1 downto 0);
  signal fmc_130m_4ch_data_valid            : std_logic_vector(c_num_adc_channels-1 downto 0);

  signal fmc_debug                          : std_logic;
  signal reset_adc_counter                  : unsigned(6 downto 0) := (others => '0');
  signal fmc_130m_4ch_rst_n                 : std_logic_vector(c_num_adc_channels-1 downto 0);

  -- fmc130m_4ch Debug
  signal fmc130m_4ch_debug_valid_int        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc130m_4ch_debug_full_int         : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc130m_4ch_debug_empty_int        : std_logic_vector(c_num_adc_channels-1 downto 0);

  signal adc_dly_debug_int                  : t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

  signal sys_spi_clk_int                    : std_logic;
  --signal sys_spi_data_int                   : std_logic;
  signal sys_spi_dout_int                   : std_logic;
  signal sys_spi_din_int                    : std_logic;
  signal sys_spi_miosio_oe_n_int            : std_logic;
  signal sys_spi_cs_adc0_n_int              : std_logic;
  signal sys_spi_cs_adc1_n_int              : std_logic;
  signal sys_spi_cs_adc2_n_int              : std_logic;
  signal sys_spi_cs_adc3_n_int              : std_logic;

  signal lmk_lock_int                       : std_logic;
  signal lmk_sync_int                       : std_logic;
  signal lmk_uwire_latch_en_int             : std_logic;
  signal lmk_uwire_data_int                 : std_logic;
  signal lmk_uwire_clock_int                : std_logic;

  signal fmc_reset_adcs_n_int               : std_logic;
  signal fmc_reset_adcs_n_out               : std_logic;

  -- GPIO LED signals
  signal gpio_slave_led_o                   : t_wishbone_slave_out;
  signal gpio_slave_led_i                   : t_wishbone_slave_in;
  signal gpio_leds_int                      : std_logic_vector(c_leds_num_pins-1 downto 0);
  -- signal leds_gpio_dummy_in                : std_logic_vector(c_leds_num_pins-1 downto 0);

  -- GPIO Button signals
  signal gpio_slave_button_o                : t_wishbone_slave_out;
  signal gpio_slave_button_i                : t_wishbone_slave_in;

  signal buttons_dummy                      : std_logic_vector(7 downto 0);

  -- Counter signal
  --signal s_counter                          : unsigned(c_counter_width-1 downto 0);
  -- 100MHz period or 1 second
  --constant s_counter_full                   : integer := 100000000;

  -- Chipscope control signals
  signal CONTROL0                           : std_logic_vector(35 downto 0);
  signal CONTROL1                           : std_logic_vector(35 downto 0);
  signal CONTROL2                           : std_logic_vector(35 downto 0);
  signal CONTROL3                           : std_logic_vector(35 downto 0);
  signal CONTROL4                           : std_logic_vector(35 downto 0);
  signal CONTROL5                           : std_logic_vector(35 downto 0);

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

  -- Chipscope ILA 5 signals
  signal TRIG_ILA5_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA5_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA5_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA5_3                        : std_logic_vector(31 downto 0);

  ---------------------------
  --      Components       --
  ---------------------------

  -- Clock generation
  component clk_gen
  port(
    sys_clk_p_i                               : in std_logic;
    sys_clk_n_i                               : in std_logic;
    sys_clk_o                                 : out std_logic;
    sys_clk_bufg_o                            : out std_logic
  );
  end component;

  -- Xilinx Megafunction
  component sys_pll is
  port(
    rst_i                                   : in std_logic := '0';
    clk_i                                   : in std_logic := '0';
    clk0_o                                  : out std_logic;
    clk1_o                                  : out std_logic;
    locked_o                                : out std_logic
  );
  end component;

  -- Xilinx Chipscope Controller
  component chipscope_icon_1_port
  port (
    CONTROL0                                : inout std_logic_vector(35 downto 0)
  );
  end component;

  -- Xilinx Chipscope Controller 2 port
  --component chipscope_icon_2_port
  --port (
  --  CONTROL0                                : inout std_logic_vector(35 downto 0);
  --  CONTROL1                                : inout std_logic_vector(35 downto 0)
  --);
  --end component;

  --component chipscope_icon_4_port
  --port (
  --  CONTROL0                                : inout std_logic_vector(35 downto 0);
  --  CONTROL1                                : inout std_logic_vector(35 downto 0);
  --  CONTROL2                                : inout std_logic_vector(35 downto 0);
  --  CONTROL3                                : inout std_logic_vector(35 downto 0)
  --);
  --end component;

  component chipscope_icon_6_port
  port (
    CONTROL0                                : inout std_logic_vector(35 downto 0);
    CONTROL1                                : inout std_logic_vector(35 downto 0);
    CONTROL2                                : inout std_logic_vector(35 downto 0);
    CONTROL3                                : inout std_logic_vector(35 downto 0);
    CONTROL4                                : inout std_logic_vector(35 downto 0);
    CONTROL5                                : inout std_logic_vector(35 downto 0)
  );
  end component;

  -- Xilinx Chipscope Logic Analyser
  component chipscope_ila
  port (
    CONTROL                                 : inout std_logic_vector(35 downto 0);
    CLK                                     : in    std_logic;
    TRIG0                                   : in    std_logic_vector(31 downto 0);
    TRIG1                                   : in    std_logic_vector(31 downto 0);
    TRIG2                                   : in    std_logic_vector(31 downto 0);
    TRIG3                                   : in    std_logic_vector(31 downto 0)
  );
  end component;

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
  port map (
    rst_i                                   => '0',
    --clk_i                                   => sys_clk_gen,
    clk_i                                   => sys_clk_gen_bufg,
    clk0_o                                  => clk_sys,     -- 100MHz locked clock
    clk1_o                                  => clk_200mhz,  -- 200MHz locked clock
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
  clk_sys_rstn                              <= reset_rstn(c_clk_sys_id) and rst_button_sys_n and
                                                  rs232_rstn and wb_ma_pcie_rstn;
  clk_sys_rst                               <= not clk_sys_rstn;
  mrstn_o                                   <= clk_sys_rstn;
  clk_200mhz_rstn                           <= reset_rstn(c_clk_200mhz_id);
  clk_200mhz_rst                            <=  not(reset_rstn(c_clk_200mhz_id));

  -- Generate button reset synchronous to each clock domain
  -- Detect button positive edge of clk_sys
  cmp_button_sys_ffs : gc_sync_ffs
  port map (
    clk_i                                   => clk_sys,
    rst_n_i                                 => '1',
    data_i                                  => sys_rst_button_i,
    ppulse_o                                => rst_button_sys_pp
  );

  -- Generate the reset signal based on positive edge
  -- of synched sys_rst_button_i
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

  -- Interrupt '0' is Ethmac.
  -- Interrupt '1' is DMA completion.
  -- Interrupt '2' is Button(0).
  -- Interrupt '3' is Ethernet Adapter RX completion.
  -- Interrupt '4' is Ethernet Adapter TX completion.
  -- Interrupts 31 downto 5 are disabled

  --lm32_interrupt <= (0 => ethmac_int, 1 => dma_int, 2 => not buttons_i(0), 3 => irq_rx_done,
  --                    4 => irq_tx_done, others => '0');

  ----------------------------------
  --         PCIe Core            --
  ----------------------------------
  cmp_bpm_pcie_ml605 : bpm_pcie_ml605
  generic map (
    SIM_BYPASS_INIT_CAL                     => "OFF" -- Full calibration sequence
  )
  port map (
    --DDR3 memory pins
    ddr3_dq                                 => ddr3_dq_b,
    ddr3_dqs_p                              => ddr3_dqs_p_b,
    ddr3_dqs_n                              => ddr3_dqs_n_b,
    ddr3_addr                               => ddr3_addr_o,
    ddr3_ba                                 => ddr3_ba_o,
    ddr3_cs_n                               => ddr3_cs_n_o,
    ddr3_ras_n                              => ddr3_ras_n_o,
    ddr3_cas_n                              => ddr3_cas_n_o,
    ddr3_we_n                               => ddr3_we_n_o,
    ddr3_reset_n                            => ddr3_reset_n_o,
    ddr3_ck_p                               => ddr3_ck_p_o,
    ddr3_ck_n                               => ddr3_ck_n_o,
    ddr3_cke                                => ddr3_cke_o,
    ddr3_dm                                 => ddr3_dm_o,
    ddr3_odt                                => ddr3_odt_o,
    -- PCIe transceivers
    pci_exp_rxp                             => pci_exp_rxp_i,
    pci_exp_rxn                             => pci_exp_rxn_i,
    pci_exp_txp                             => pci_exp_txp_o,
    pci_exp_txn                             => pci_exp_txn_o,
    -- Necessity signals
    ddr_sys_clk_p                           => clk_200mhz,   --200 MHz DDR core clock (connect through BUFG or PLL)
    --ddr_sys_clk_p                           => sys_clk_gen_bufg, --200 MHz DDR core clock (connect through BUFG or PLL)
    sys_clk_p                               => pcie_clk_p_i,  --100 MHz PCIe Clock (connect directly to input pin)
    sys_clk_n                               => pcie_clk_n_i,  --100 MHz PCIe Clock
    sys_rst_n                               => pcie_rst_n_i, -- PCIe core reset

    -- DDR memory controller interface --
    ddr_core_rst                            => wb_ma_pcie_rst,
    memc_ui_clk                             => memc_ui_clk,
    memc_ui_rst                             => memc_ui_rst,
    memc_cmd_rdy                            => memc_cmd_rdy,
    memc_cmd_en                             => memc_cmd_en,
    memc_cmd_instr                          => memc_cmd_instr,
    --memc_cmd_addr                           => memc_cmd_addr,
    memc_cmd_addr                           => memc_cmd_addr_resized,
    memc_wr_en                              => memc_wr_en,
    memc_wr_end                             => memc_wr_end,
    memc_wr_mask                            => memc_wr_mask,
    memc_wr_data                            => memc_wr_data,
    memc_wr_rdy                             => memc_wr_rdy,
    memc_rd_data                            => memc_rd_data,
    memc_rd_valid                           => memc_rd_valid,
    -- memory arbiter interface
    memarb_acc_req                          => memarb_acc_req,
    memarb_acc_gnt                          => memarb_acc_gnt,
    --/ DDR memory controller interface

    -- Wishbone interface --
    -- uncomment when instantiating in another project
    clk_i                                   => clk_sys,
    rst_i                                   => clk_sys_rst,
    ack_i                                   => wb_ma_pcie_ack_in,
    dat_i                                   => wb_ma_pcie_dat_in,
    addr_o                                  => wb_ma_pcie_addr_out,
    dat_o                                   => wb_ma_pcie_dat_out,
    we_o                                    => wb_ma_pcie_we_out,
    stb_o                                   => wb_ma_pcie_stb_out,
    sel_o                                   => wb_ma_pcie_sel_out,
    cyc_o                                   => wb_ma_pcie_cyc_out,
    --/ Wishbone interface
    -- Additional exported signals for instantiation
    ext_rst_o                               => wb_ma_pcie_rst,

    -- Debug signals
    dbg_app_addr_o                          => dbg_app_addr,
    dbg_app_cmd_o                           => dbg_app_cmd,
    dbg_app_en_o                            => dbg_app_en,
    dbg_app_wdf_data_o                      => dbg_app_wdf_data,
    dbg_app_wdf_end_o                       => dbg_app_wdf_end,
    dbg_app_wdf_wren_o                      => dbg_app_wdf_wren,
    dbg_app_wdf_mask_o                      => dbg_app_wdf_mask,
    dbg_app_rd_data_o                       => dbg_app_rd_data,
    dbg_app_rd_data_end_o                   => dbg_app_rd_data_end,
    dbg_app_rd_data_valid_o                 => dbg_app_rd_data_valid,
    dbg_app_rdy_o                           => dbg_app_rdy,
    dbg_app_wdf_rdy_o                       => dbg_app_wdf_rdy,
    dbg_ddr_ui_clk_o                        => dbg_ddr_ui_clk,
    dbg_ddr_ui_reset_o                      => dbg_ddr_ui_reset,

    dbg_arb_req_o                           => dbg_arb_req,
    dbg_arb_gnt_o                           => dbg_arb_gnt
  );

  wb_ma_pcie_rstn                           <= not(wb_ma_pcie_rst);

  cmp_pcie_ma_iface_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => true,
    g_master_mode                           => PIPELINED,
    g_master_granularity                    => WORD,
    g_slave_use_struct                      => false,
    g_slave_mode                            => CLASSIC,
    g_slave_granularity                     => WORD
  )
  port map (
    clk_sys_i                               => clk_sys,
    rst_n_i                                 => clk_sys_rstn,

    sl_adr_i                                => wb_ma_sladp_pcie_addr_out,
    sl_dat_i                                => wb_ma_sladp_pcie_dat_out,
    sl_sel_i                                => wb_ma_sladp_pcie_sel_out,
    sl_cyc_i                                => wb_ma_sladp_pcie_cyc_out,
    sl_stb_i                                => wb_ma_sladp_pcie_stb_out,
    sl_we_i                                 => wb_ma_sladp_pcie_we_out,
    sl_dat_o                                => wb_ma_sladp_pcie_dat_in,
    sl_ack_o                                => wb_ma_sladp_pcie_ack_in,
    sl_stall_o                              => open,
    sl_int_o                                => open,
    sl_rty_o                                => open,
    sl_err_o                                => open,

    master_i                                => cbar_slave_o(0),
    master_o                                => cbar_slave_i(0)
  );

  -- Connect PCIe to the Wishbone Crossbar
  wb_ma_sladp_pcie_addr_out(wb_ma_sladp_pcie_addr_out'left downto wb_ma_pcie_addr_out'left+1)
                                              <= (others => '0');
  wb_ma_sladp_pcie_addr_out(wb_ma_pcie_addr_out'left downto 0)
                                              <= wb_ma_pcie_addr_out;
  wb_ma_sladp_pcie_dat_out                    <= wb_ma_pcie_dat_out(wb_ma_sladp_pcie_dat_out'left downto 0);
  wb_ma_sladp_pcie_sel_out                    <= wb_ma_pcie_sel_out & wb_ma_pcie_sel_out &
                                                 wb_ma_pcie_sel_out & wb_ma_pcie_sel_out;
  wb_ma_sladp_pcie_cyc_out                    <= wb_ma_pcie_cyc_out;
  wb_ma_sladp_pcie_stb_out                    <= wb_ma_pcie_stb_out;
  wb_ma_sladp_pcie_we_out                     <= wb_ma_pcie_we_out;
  wb_ma_pcie_dat_in(wb_ma_pcie_dat_in'left downto wb_ma_sladp_pcie_dat_in'left+1)
                                              <= (others => '0');
  wb_ma_pcie_dat_in(wb_ma_sladp_pcie_dat_in'left downto 0)
                                              <= wb_ma_sladp_pcie_dat_in;

  wb_ma_pcie_ack_in                           <= wb_ma_sladp_pcie_ack_in;

  cmp_xwb_rs232_syscon : xwb_rs232_syscon
  generic map (
    g_ma_interface_mode                       => PIPELINED,
    g_ma_address_granularity                  => BYTE
  )
  port map(
    -- WISHBONE common
    wb_clk_i                                  => clk_sys,
    wb_rstn_i                                 => '1', -- No need for resetting the controller

    -- External ports
    rs232_rxd_i                               => rs232_rxd_i,
    rs232_txd_o                               => rs232_txd_o,

    -- Reset to FPGA logic
    rstn_o                                    => rs232_rstn,

    -- WISHBONE master
    wb_master_i                               => cbar_slave_o(1),
    wb_master_o                               => cbar_slave_i(1)
  );

  -- A DMA controller is master 2+3, slave 3, and interrupt 1
  cmp_dma : xwb_dma
  port map(
    clk_i                                   => clk_sys,
    rst_n_i                                 => clk_sys_rstn,
    slave_i                                 => cbar_master_o(3),
    slave_o                                 => cbar_master_i(3),
    r_master_i                              => cbar_slave_o(2),
    r_master_o                              => cbar_slave_i(2),
    w_master_i                              => cbar_slave_o(3),
    w_master_o                              => cbar_slave_i(3),
    interrupt_o                             => dma_int
  );

  -- Slave 0+1 is the RAM. Load a input file containing the embedded software
  cmp_ram : xwb_dpram
  generic map(
    g_size                                  => c_dpram_size, -- must agree with sw/target/lm32/ram.ld:LENGTH / 4
    --g_init_file                             => "../../../../embedded-sw/rampdata.ram", -- Ramp Data for testing PCIe
    g_init_file                             => "",
    --g_must_have_init_file                   => true,
    g_must_have_init_file                   => false,
    --g_slave1_interface_mode                 => PIPELINED,
    --g_slave2_interface_mode                 => PIPELINED,
    --g_slave1_granularity                    => BYTE,
    --g_slave2_granularity                    => BYTE
    g_slave1_interface_mode                 => CLASSIC,
    g_slave2_interface_mode                 => CLASSIC,
    g_slave1_granularity                    => WORD,
    g_slave2_granularity                    => WORD
  )
  port map(
    clk_sys_i                               => clk_sys,
    rst_n_i                                 => clk_sys_rstn,
    -- First port connected to the crossbar
    slave1_i                                => cbar_master_o(0),
    slave1_o                                => cbar_master_i(0),
    -- Second port connected to the crossbar
    slave2_i                                => cbar_master_o(1),
    slave2_o                                => cbar_master_i(1)
  );

  -- Slave 2 is the RAM Buffer for Ethernet MAC.
  cmp_ethmac_buf_ram : xwb_dpram
  generic map(
    g_size                                  => c_dpram_ethbuf_size,
    g_init_file                             => "",
    g_must_have_init_file                   => false,
    g_slave1_interface_mode                 => CLASSIC,
    --g_slave2_interface_mode                 => PIPELINED,
    g_slave1_granularity                    => BYTE
    --g_slave2_granularity                    => BYTE
  )
  port map(
    clk_sys_i                               => clk_sys,
    rst_n_i                                 => clk_sys_rstn,
    -- First port connected to the crossbar
    slave1_i                                => cbar_master_o(2),
    slave1_o                                => cbar_master_i(2),
    -- Second port connected to the crossbar
    slave2_i                                => cc_dummy_slave_in, -- CYC always low
    slave2_o                                => open
  );

  -- The Ethernet MAC is master 4, slave 4
  cmp_xwb_ethmac : xwb_ethmac
  generic map (
    --g_ma_interface_mode                     => PIPELINED,
    g_ma_interface_mode                     => CLASSIC, -- NOT used for now
    --g_ma_address_granularity                => WORD,
    g_ma_address_granularity                => BYTE,    -- NOT used for now
    g_sl_interface_mode                     => PIPELINED,
    --g_sl_interface_mode                     => CLASSIC,
    --g_sl_address_granularity                => WORD
    g_sl_address_granularity                => BYTE
  )
  port map(
    -- WISHBONE common
    wb_clk_i                                => clk_sys,
    wb_rst_i                                => clk_sys_rst,

    -- WISHBONE slave
    wb_slave_in                             => cbar_master_o(4),
    wb_slave_out                            => cbar_master_i(4),

    -- WISHBONE master
    wb_master_in                            => cbar_slave_o(4),
    wb_master_out                           => cbar_slave_i(4),

    -- PHY TX
    mtx_clk_pad_i                           => mtx_clk_pad_i,
    --mtxd_pad_o                              => mtxd_pad_o,
    mtxd_pad_o                              => mtxd_pad_int,
    --mtxen_pad_o                             => mtxen_pad_o,
    mtxen_pad_o                             => mtxen_pad_int,
    --mtxerr_pad_o                            => mtxerr_pad_o,
    mtxerr_pad_o                            => mtxerr_pad_int,

    -- PHY RX
    mrx_clk_pad_i                           => mrx_clk_pad_i,
    mrxd_pad_i                              => mrxd_pad_i,
    mrxdv_pad_i                             => mrxdv_pad_i,
    mrxerr_pad_i                            => mrxerr_pad_i,
    mcoll_pad_i                             => mcoll_pad_i,
    mcrs_pad_i                              => mcrs_pad_i,

    -- MII
    --mdc_pad_o                               => mdc_pad_o,
    mdc_pad_o                               => mdc_pad_int,
    md_pad_i                                => ethmac_md_in,
    md_pad_o                                => ethmac_md_out,
    md_padoe_o                              => ethmac_md_oe,

    -- Interrupt
    int_o                                   => ethmac_int
  );

  -- Tri-state buffer for MII config
  md_pad_b <= ethmac_md_out when ethmac_md_oe = '1' else 'Z';
  ethmac_md_in <= md_pad_b;

  mtxd_pad_o                                <=  mtxd_pad_int;
  mtxen_pad_o                               <=  mtxen_pad_int;
  mtxerr_pad_o                              <=  mtxerr_pad_int;
  mdc_pad_o                                 <=  mdc_pad_int;

  -- The Ethernet MAC Adapter is master 5+6, slave 5
  cmp_xwb_ethmac_adapter : xwb_ethmac_adapter
  port map(
    clk_i                                   => clk_sys,
    rstn_i                                  => clk_sys_rstn,

    wb_slave_o                              => cbar_master_i(5),
    wb_slave_i                              => cbar_master_o(5),

    tx_ram_o                                => cbar_slave_i(5),
    tx_ram_i                                => cbar_slave_o(5),

    rx_ram_o                                => cbar_slave_i(6),
    rx_ram_i                                => cbar_slave_o(6),

    rx_eb_o                                 => eb_snk_i,
    rx_eb_i                                 => eb_snk_o,

    tx_eb_o                                 => eb_src_i,
    tx_eb_i                                 => eb_src_o,

    irq_tx_done_o                           => irq_tx_done,
    irq_rx_done_o                           => irq_rx_done
  );

  -- The Etherbone is slave 6
  cmp_eb_slave_core : eb_slave_core
  generic map(
    g_sdb_address                           => x"00000000" & c_sdb_address
  )
  port map
  (
    clk_i                                   => clk_sys,
    nRst_i                                  => clk_sys_rstn,

    -- EB streaming sink
    snk_i                                   => eb_snk_i,
    snk_o                                   => eb_snk_o,

    -- EB streaming source
    src_i                                   => eb_src_i,
    src_o                                   => eb_src_o,

    -- WB slave - Cfg IF
    cfg_slave_o                             => cbar_master_i(6),
    cfg_slave_i                             => cbar_master_o(6),

    -- WB master - Bus IF
    master_o                                => wb_ebone_out,
    master_i                                => wb_ebone_in
  );

  cbar_slave_i(7)                           <= wb_ebone_out;
  wb_ebone_in                               <= cbar_slave_o(7);

  -- The FMC130M_4CH is slave 7
  cmp_xwb_fmc130m_4ch : xwb_fmc130m_4ch
  generic map(
    g_fpga_device                           => "VIRTEX6",
    g_interface_mode                        => PIPELINED,
    --g_address_granularity                   => WORD,
    g_address_granularity                   => BYTE,
    --g_adc_clk_period_values                 => default_adc_clk_period_values,
    g_adc_clk_period_values                 => (8.88, 8.88, 8.88, 8.88),
    --g_use_clk_chains                        => default_clk_use_chain,
    -- using clock1 from fmc130m_4ch (CLK2_ M2C_P, CLK2_ M2C_M pair)
    -- using clock0 from fmc130m_4ch.
    -- BUFIO can drive half-bank only, not the full IO bank
    g_use_clk_chains                        => "1111",
    g_with_bufio_clk_chains                 => "0000",
    g_with_bufr_clk_chains                  => "1111",
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
    wb_slv_i                                => cbar_master_o(7),
    wb_slv_o                                => cbar_master_i(7),

    -----------------------------
    -- External ports
    -----------------------------

    -- ADC LTC2208 interface
    fmc_adc_pga_o                           => fmc_adc_pga_o,
    fmc_adc_shdn_o                          => fmc_adc_shdn_o,
    fmc_adc_dith_o                          => fmc_adc_dith_o,
    fmc_adc_rand_o                          => fmc_adc_rand_o,

    -- ADC0 LTC2208
    fmc_adc0_clk_i                          => fmc_adc0_clk_i,
    fmc_adc0_data_i                         => fmc_adc0_data_i,
    fmc_adc0_of_i                           => fmc_adc0_of_i,

    -- ADC1 LTC2208
    fmc_adc1_clk_i                          => fmc_adc1_clk_i,
    fmc_adc1_data_i                         => fmc_adc1_data_i,
    fmc_adc1_of_i                           => fmc_adc1_of_i,

    -- ADC2 LTC2208
    fmc_adc2_clk_i                          => fmc_adc2_clk_i,
    fmc_adc2_data_i                         => fmc_adc2_data_i,
    fmc_adc2_of_i                           => fmc_adc2_of_i,

    -- ADC3 LTC2208
    fmc_adc3_clk_i                          => fmc_adc3_clk_i,
    fmc_adc3_data_i                         => fmc_adc3_data_i,
    fmc_adc3_of_i                           => fmc_adc3_of_i,

    -- FMC General Status
    fmc_prsnt_i                             => fmc_prsnt_i,
    fmc_pg_m2c_i                            => fmc_pg_m2c_i,

    -- Trigger
    fmc_trig_dir_o                          => fmc_trig_dir_o,
    fmc_trig_term_o                         => fmc_trig_term_o,
    fmc_trig_val_p_b                        => fmc_trig_val_p_b,
    fmc_trig_val_n_b                        => fmc_trig_val_n_b,

    -- Si571 clock gen
    si571_scl_pad_b                         => si571_scl_pad_b,
    si571_sda_pad_b                         => si571_sda_pad_b,
    fmc_si571_oe_o                          => fmc_si571_oe_o,

    -- AD9510 clock distribution PLL
    spi_ad9510_cs_o                         => spi_ad9510_cs_o,
    spi_ad9510_sclk_o                       => spi_ad9510_sclk_o,
    spi_ad9510_mosi_o                       => spi_ad9510_mosi_o,
    spi_ad9510_miso_i                       => spi_ad9510_miso_i,

    fmc_pll_function_o                      => fmc_pll_function_o,
    fmc_pll_status_i                        => fmc_pll_status_i,

    -- AD9510 clock copy
    fmc_fpga_clk_p_i                        => fmc_fpga_clk_p_i,
    fmc_fpga_clk_n_i                        => fmc_fpga_clk_n_i,

    -- Clock reference selection (TS3USB221)
    fmc_clk_sel_o                           => fmc_clk_sel_o,

    -- EEPROM
    eeprom_scl_pad_b                        => eeprom_scl_pad_b,
    eeprom_sda_pad_b                        => eeprom_sda_pad_b,

    -- Temperature monitor
    -- LM75AIMM
    lm75_scl_pad_b                          => lm75_scl_pad_b,
    lm75_sda_pad_b                          => lm75_sda_pad_b,

    fmc_lm75_temp_alarm_i                   => fmc_lm75_temp_alarm_i,

    -- FMC LEDs
    fmc_led1_o                              => fmc_led1_int,
    fmc_led2_o                              => fmc_led2_int,
    fmc_led3_o                              => fmc_led3_int,

    -----------------------------
    -- ADC output signals. Continuous flow
    -----------------------------
    adc_clk_o                               => fmc_130m_4ch_clk,
    adc_clk2x_o                             => fmc_130m_4ch_clk2x,
    adc_rst_n_o                             => fmc_130m_4ch_rst_n,
    adc_data_o                              => fmc_130m_4ch_data,
    adc_data_valid_o                        => fmc_130m_4ch_data_valid,

    -----------------------------
    -- General ADC output signals and status
    -----------------------------
    -- Trigger to other FPGA logic
    trig_hw_o                               => open,
    trig_hw_i                               => '0',

    -- General board status
    fmc_mmcm_lock_o                         => fmc_mmcm_lock_int,
    fmc_pll_status_o                        => fmc_pll_status_int,

    -----------------------------
    -- Wishbone Streaming Interface Source
    -----------------------------
    wbs_source_i                            => wbs_fmc130m_4ch_in_array,
    wbs_source_o                            => wbs_fmc130m_4ch_out_array,

    adc_dly_debug_o                         => adc_dly_debug_int,

    fifo_debug_valid_o                      => fmc130m_4ch_debug_valid_int,
    fifo_debug_full_o                       => fmc130m_4ch_debug_full_int,
    fifo_debug_empty_o                      => fmc130m_4ch_debug_empty_int
  );

  gen_wbs_dummy_signals : for i in 0 to c_num_adc_channels-1 generate
    wbs_fmc130m_4ch_in_array(i)                    <= cc_dummy_src_com_in;
  end generate;

  fmc_mmcm_lock_led_o                       <= fmc_mmcm_lock_int;
  fmc_pll_status_led_o                      <= fmc_pll_status_int;

  fmc_led1_o                                <= fmc_led1_int;
  fmc_led2_o                                <= fmc_led2_int;
  fmc_led3_o                                <= fmc_led3_int;

  --led_south_o                               <= fmc_led1_int;
  --led_east_o                                <= fmc_led2_int;
  --led_north_o                               <= fmc_led3_int;

  -- The board peripherals components is slave 8
  cmp_xwb_dbe_periph : xwb_dbe_periph
  generic map(
    -- NOT used!
    --g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
    -- NOT used!
    --g_address_granularity                     : t_wishbone_address_granularity := WORD;
    g_cntr_period                             => c_tics_cntr_period,
    g_num_leds                                => c_leds_num_pins,
    g_num_buttons                             => c_buttons_num_pins
  )
  port map(
    clk_sys_i                                 => clk_sys,
    rst_n_i                                   => clk_sys_rstn,

    -- UART
    uart_rxd_i                                => '0',
    uart_txd_o                                => open,

    -- LEDs
    led_out_o                                 => gpio_leds_int,
    led_in_i                                  => gpio_leds_int,
    led_oen_o                                 => open,

    -- Buttons
    button_out_o                              => open,
    --button_in_i                               => buttons_i,
    button_in_i                               => buttons_dummy,
    button_oen_o                              => open,

    -- Wishbone
    slave_i                                   => cbar_master_o(8),
    slave_o                                   => cbar_master_i(8)
  );

  leds_o <= gpio_leds_int;

  acq_chan_array(c_acq_adc_id).val_low       <= fmc_130m_4ch_data(63 downto 48) &
                                                fmc_130m_4ch_data(47 downto 32) &
                                                fmc_130m_4ch_data(31 downto 16) &
                                                fmc_130m_4ch_data(15 downto 0);
  acq_chan_array(c_acq_adc_id).val_high      <= (others => '0');
  acq_chan_array(c_acq_adc_id).dvalid        <= fmc_130m_4ch_data_valid(c_adc_ref_clk);
  acq_chan_array(c_acq_adc_id).trig          <= '0';

  acq_chan_array(c_acq_tbt_id).val_low       <= fmc_130m_4ch_data(63 downto 48) &
                                                fmc_130m_4ch_data(47 downto 32) &
                                                fmc_130m_4ch_data(31 downto 16) &
                                                fmc_130m_4ch_data(15 downto 0);
  acq_chan_array(c_acq_tbt_id).val_high      <= std_logic_vector(unsigned(fmc_130m_4ch_data(63 downto 48)) + 100) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(47 downto 32)) + 100) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(31 downto 16)) + 100) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(15 downto 0))  + 100);
  acq_chan_array(c_acq_tbt_id).dvalid        <= fmc_130m_4ch_data_valid(c_adc_ref_clk);
  acq_chan_array(c_acq_tbt_id).trig          <= '0';

  acq_chan_array(c_acq_fofb_id).val_low      <= fmc_130m_4ch_data(63 downto 48) &
                                                fmc_130m_4ch_data(47 downto 32) &
                                                fmc_130m_4ch_data(31 downto 16) &
                                                fmc_130m_4ch_data(15 downto 0);
  acq_chan_array(c_acq_fofb_id).val_high     <= std_logic_vector(unsigned(fmc_130m_4ch_data(63 downto 48)) + 200) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(47 downto 32)) + 200) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(31 downto 16)) + 200) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(15 downto 0))  + 200) ;
  acq_chan_array(c_acq_fofb_id).dvalid       <= fmc_130m_4ch_data_valid(c_adc_ref_clk);
  acq_chan_array(c_acq_fofb_id).trig         <= '0';

  acq_chan_array(c_acq_monit_id).val_low     <= fmc_130m_4ch_data(63 downto 48) &
                                                fmc_130m_4ch_data(47 downto 32) &
                                                fmc_130m_4ch_data(31 downto 16) &
                                                fmc_130m_4ch_data(15 downto 0);
  acq_chan_array(c_acq_monit_id).val_high    <= std_logic_vector(unsigned(fmc_130m_4ch_data(63 downto 48)) + 300) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(47 downto 32)) + 300) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(31 downto 16)) + 300) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(15 downto 0))  + 300) ;
  acq_chan_array(c_acq_monit_id).dvalid      <= fmc_130m_4ch_data_valid(c_adc_ref_clk);
  acq_chan_array(c_acq_monit_id).trig        <= '0';

  acq_chan_array(c_acq_monit_1_id).val_low   <= fmc_130m_4ch_data(63 downto 48) &
                                                fmc_130m_4ch_data(47 downto 32) &
                                                fmc_130m_4ch_data(31 downto 16) &
                                                fmc_130m_4ch_data(15 downto 0);
  acq_chan_array(c_acq_monit_1_id).val_high  <= std_logic_vector(unsigned(fmc_130m_4ch_data(63 downto 48)) + 400) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(47 downto 32)) + 400) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(31 downto 16)) + 400) &
                                                std_logic_vector(unsigned(fmc_130m_4ch_data(15 downto 0))  + 400) ;
  acq_chan_array(c_acq_monit_1_id).dvalid    <= fmc_130m_4ch_data_valid(c_adc_ref_clk);
  acq_chan_array(c_acq_monit_1_id).trig      <= '0';

  -- The xwb_acq_core is slave 9
  cmp_xwb_acq_core : xwb_acq_core
  generic map
  (
    g_interface_mode                          => PIPELINED,
    g_address_granularity                     => WORD,
    g_acq_addr_width                          => c_acq_addr_width,
    g_acq_num_channels                        => c_acq_num_channels,
    g_acq_channels                            => c_acq_channels,
    g_ddr_payload_width                       => c_acq_ddr_payload_width,
    g_ddr_dq_width                            => c_ddr_dq_width,
    g_ddr_addr_width                          => c_acq_ddr_addr_width,
    --g_multishot_ram_size                      => 2048,
    g_fifo_fc_size                            => c_acq_fifo_size -- avoid fifo overflow
    --g_sim_readback                            => false
  )
  port map
  (
   -- assign to a better and shorter name
    fs_clk_i                                  => fmc_130m_4ch_clk(c_adc_ref_clk),
    fs_ce_i                                   => '1',
    -- assign to a better and shorter name
    fs_rst_n_i                                => fmc_130m_4ch_rst_n(c_adc_ref_clk),

    sys_clk_i                                 => clk_sys,
    sys_rst_n_i                               => clk_sys_rstn,

    -- From DDR3 Controller
    ext_clk_i                                 => memc_ui_clk,
    ext_rst_n_i                               => memc_ui_rstn,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_slv_i                                  => cbar_master_o(9),
    wb_slv_o                                  => cbar_master_i(9),

    -----------------------------
    -- External Interface
    -----------------------------
    --data_i                                    => fmc_130m_4ch_data, -- ch4 ch3 ch2 ch1
    --dvalid_i                                  => fmc_130m_4ch_data_valid(c_adc_ref_clk), -- Change this!!
    --ext_trig_i                                => '0',
    acq_chan_array_i                         => acq_chan_array,

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_o                              => bpm_acq_dpram_dout , -- to chipscope
    dpram_valid_o                             => bpm_acq_dpram_valid, -- to chipscope

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_o                                => bpm_acq_ext_dout, -- to chipscope
    ext_valid_o                               => bpm_acq_ext_valid, -- to chipscope
    ext_addr_o                                => bpm_acq_ext_addr, -- to chipscope
    ext_sof_o                                 => bpm_acq_ext_sof, -- to chipscope
    ext_eof_o                                 => bpm_acq_ext_eof, -- to chipscope
    ext_dreq_o                                => bpm_acq_ext_dreq, -- to chipscope
    ext_stall_o                               => bpm_acq_ext_stall, -- to chipscope

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                             => memc_cmd_addr,
    ui_app_cmd_o                              => memc_cmd_instr,
    ui_app_en_o                               => memc_cmd_en,
    ui_app_rdy_i                              => memc_cmd_rdy,

    ui_app_wdf_data_o                         => memc_wr_data,
    ui_app_wdf_end_o                          => memc_wr_end,
    ui_app_wdf_mask_o                         => memc_wr_mask,
    ui_app_wdf_wren_o                         => memc_wr_en,
    ui_app_wdf_rdy_i                          => memc_wr_rdy,

    ui_app_rd_data_i                          => memc_rd_data,  -- not used!
    ui_app_rd_data_end_i                      => '0',  -- not used!
    ui_app_rd_data_valid_i                    => memc_rd_valid,  -- not used!

    -- DDR3 arbitrer for multiple accesses
    ui_app_req_o                              => memarb_acc_req,
    ui_app_gnt_i                              => memarb_acc_gnt,

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_data_o                         => dbg_ddr_rb_data,
    dbg_ddr_rb_addr_o                         => dbg_ddr_rb_addr,
    dbg_ddr_rb_valid_o                        => dbg_ddr_rb_valid
  );

  memc_ui_rstn <= not(memc_ui_rst);

  memc_cmd_addr_resized <= f_gen_std_logic_vector(c_acq_ddr_addr_diff, '0') &
                               memc_cmd_addr;

  -- Xilinx Chipscope
  cmp_chipscope_icon_0 : chipscope_icon_6_port
  port map (
    CONTROL0                                => CONTROL0,
    CONTROL1                                => CONTROL1,
    CONTROL2                                => CONTROL2,
    CONTROL3                                => CONTROL3,
    CONTROL4                                => CONTROL4,
    CONTROL5                                => CONTROL5
  );

  cmp_chipscope_ila_0_fmc130m_4ch_clk0 : chipscope_ila
  port map (
    CONTROL                                 => CONTROL0,
    CLK                                     => fmc_130m_4ch_clk(c_adc_ref_clk),
    TRIG0                                   => TRIG_ILA0_0,
    TRIG1                                   => TRIG_ILA0_1,
    TRIG2                                   => TRIG_ILA0_2,
    TRIG3                                   => TRIG_ILA0_3
  );

  -- fmc130m_4ch WBS master output data
  --TRIG_ILA0_0                               <= wbs_fmc130m_4ch_out_array(3).dat &
  --                                               wbs_fmc130m_4ch_out_array(2).dat;
  TRIG_ILA0_0                               <= fmc_130m_4ch_data(31 downto 16) &
                                                 fmc_130m_4ch_data(47 downto 32);

  -- fmc130m_4ch WBS master output data
  TRIG_ILA0_1(11 downto 0)                   <= adc_dly_debug_int(1).clk_chain.idelay.pulse &
                                                adc_dly_debug_int(1).data_chain.idelay.pulse &
                                                adc_dly_debug_int(1).clk_chain.idelay.val &
                                                adc_dly_debug_int(1).data_chain.idelay.val;
  TRIG_ILA0_1(31 downto 12)                  <= (others => '0');

  -- fmc130m_4ch WBS master output control signals
  TRIG_ILA0_2(17 downto 0)                   <= wbs_fmc130m_4ch_out_array(1).cyc &
                                                 wbs_fmc130m_4ch_out_array(1).stb &
                                                 wbs_fmc130m_4ch_out_array(1).adr &
                                                 wbs_fmc130m_4ch_out_array(1).sel &
                                                 wbs_fmc130m_4ch_out_array(1).we &
                                                 wbs_fmc130m_4ch_out_array(2).cyc &
                                                 wbs_fmc130m_4ch_out_array(2).stb &
                                                 wbs_fmc130m_4ch_out_array(2).adr &
                                                 wbs_fmc130m_4ch_out_array(2).sel &
                                                 wbs_fmc130m_4ch_out_array(2).we;
  TRIG_ILA0_2(18)                            <= '0';
  TRIG_ILA0_2(22 downto 19)                  <= fmc_130m_4ch_data_valid;
  TRIG_ILA0_2(23)                            <= fmc_mmcm_lock_int;
  TRIG_ILA0_2(24)                            <= fmc_pll_status_int;
  TRIG_ILA0_2(25)                            <= fmc130m_4ch_debug_valid_int(1);
  TRIG_ILA0_2(26)                            <= fmc130m_4ch_debug_full_int(1);
  TRIG_ILA0_2(27)                            <= fmc130m_4ch_debug_empty_int(1);
  TRIG_ILA0_2(31 downto 28)                  <= (others => '0');

  TRIG_ILA0_3                                <= (others => '0');

  cmp_chipscope_ila_1_fmc130m_4ch_clk1 : chipscope_ila
  port map (
    CONTROL                                 => CONTROL1,
    --CLK                                     => fmc_130m_4ch_clk(1),
    CLK                                     => fmc_130m_4ch_clk(c_adc_ref_clk),
    TRIG0                                   => TRIG_ILA1_0,
    TRIG1                                   => TRIG_ILA1_1,
    TRIG2                                   => TRIG_ILA1_2,
    TRIG3                                   => TRIG_ILA1_3
  );

    -- fmc130m_4ch WBS master output data
  TRIG_ILA1_0                               <= fmc_130m_4ch_data(15 downto 0) &
                                                 fmc_130m_4ch_data(63 downto 48);

  -- fmc130m_4ch WBS master output data
  TRIG_ILA1_1                               <= (others => '0');

  -- fmc130m_4ch WBS master output control signals
  TRIG_ILA1_2(17 downto 0)                   <= wbs_fmc130m_4ch_out_array(0).cyc &
                                                 wbs_fmc130m_4ch_out_array(0).stb &
                                                 wbs_fmc130m_4ch_out_array(0).adr &
                                                 wbs_fmc130m_4ch_out_array(0).sel &
                                                 wbs_fmc130m_4ch_out_array(0).we &
                                                 wbs_fmc130m_4ch_out_array(3).cyc &
                                                 wbs_fmc130m_4ch_out_array(3).stb &
                                                 wbs_fmc130m_4ch_out_array(3).adr &
                                                 wbs_fmc130m_4ch_out_array(3).sel &
                                                 wbs_fmc130m_4ch_out_array(3).we;
  TRIG_ILA1_2(18)                            <= '0';
  TRIG_ILA1_2(22 downto 19)                  <= fmc_130m_4ch_data_valid;
  TRIG_ILA1_2(23)                            <= fmc_mmcm_lock_int;
  TRIG_ILA1_2(24)                            <= fmc_pll_status_int;
  TRIG_ILA1_2(25)                            <= fmc130m_4ch_debug_valid_int(0);
  TRIG_ILA1_2(26)                            <= fmc130m_4ch_debug_full_int(0);
  TRIG_ILA1_2(27)                            <= fmc130m_4ch_debug_empty_int(0);
  TRIG_ILA1_2(31 downto 28)                  <= (others => '0');

  TRIG_ILA1_3                                 <= (others => '0');


  cmp_chipscope_ila_2_ethmac_tx : chipscope_ila
  port map (
    CONTROL                                 => CONTROL2,
    CLK                                     => mtx_clk_pad_i,
    TRIG0                                   => TRIG_ILA2_0,
    TRIG1                                   => TRIG_ILA2_1,
    TRIG2                                   => TRIG_ILA2_2,
    TRIG3                                   => TRIG_ILA2_3
  );

  TRIG_ILA2_0(5 downto 0)                   <= mtxd_pad_int &
                                                mtxen_pad_int &
                                                mtxerr_pad_int;

  TRIG_ILA2_0(31 downto 6)                  <= (others => '0');
  TRIG_ILA2_1                               <= (others => '0');
  TRIG_ILA2_2                               <= (others => '0');
  TRIG_ILA2_3                               <= (others => '0');

  -- The clocks to/from peripherals are derived from the bus clock.
  -- Therefore we don't have to worry about synchronization here, just
  -- keep in mind that the data/ss lines will appear longer than normal
  cmp_chipscope_ila_3_fmc130m_4ch_periph : chipscope_ila
  port map (
    CONTROL                                 => CONTROL3,
    CLK                                     => clk_sys, -- Wishbone clock
    TRIG0                                   => TRIG_ILA3_0,
    TRIG1                                   => TRIG_ILA3_1,
    TRIG2                                   => TRIG_ILA3_2,
    TRIG3                                   => TRIG_ILA3_3
  );

  TRIG_ILA3_0                               <= wb_ma_pcie_dat_in(31 downto 0);
  TRIG_ILA3_1                               <= wb_ma_pcie_dat_out(31 downto 0);
  TRIG_ILA3_2(31 downto wb_ma_pcie_addr_out'left + 1) <= (others => '0');
  TRIG_ILA3_2(wb_ma_pcie_addr_out'left downto 0)
                                            <= wb_ma_pcie_addr_out(wb_ma_pcie_addr_out'left downto 0);
  TRIG_ILA3_3(31 downto 5)                  <= (others => '0');
  TRIG_ILA3_3(4 downto 0)                   <= wb_ma_pcie_ack_in &
                                                wb_ma_pcie_we_out &
                                                wb_ma_pcie_stb_out &
                                                wb_ma_pcie_sel_out &
                                                wb_ma_pcie_cyc_out;

  cmp_chipscope_ila_4_bpm_acq : chipscope_ila
  port map (
    CONTROL                                 => CONTROL4,
    CLK                                     => memc_ui_clk, -- DDR3 controller clk
    TRIG0                                   => TRIG_ILA4_0,
    TRIG1                                   => TRIG_ILA4_1,
    TRIG2                                   => TRIG_ILA4_2,
    TRIG3                                   => TRIG_ILA4_3
  );

  TRIG_ILA4_0                               <= dbg_app_rd_data(207 downto 192) &
                                                 dbg_app_rd_data(143 downto 128);
  TRIG_ILA4_1                               <= dbg_app_rd_data(79 downto 64) &
                                                 dbg_app_rd_data(15 downto 0);

  TRIG_ILA4_2                               <= dbg_app_addr;

  TRIG_ILA4_3(31 downto 11)                  <= (others => '0');
  TRIG_ILA4_3(10 downto 0)                   <=  dbg_app_rd_data_end &
                                                 dbg_app_rd_data_valid &
                                                 dbg_app_cmd & -- std_logic_vector(2 downto 0);
                                                 dbg_app_en &
                                                 dbg_app_rdy &
                                                 dbg_arb_req &
                                                 dbg_arb_gnt;

  cmp_chipscope_ila_5_bpm_acq : chipscope_ila
  port map (
    CONTROL                                 => CONTROL5,
    CLK                                     => memc_ui_clk, -- DDR3 controller clk
    TRIG0                                   => TRIG_ILA5_0,
    TRIG1                                   => TRIG_ILA5_1,
    TRIG2                                   => TRIG_ILA5_2,
    TRIG3                                   => TRIG_ILA5_3
  );

  TRIG_ILA5_0                               <= dbg_app_wdf_data(207 downto 192) &
                                                 dbg_app_wdf_data(143 downto 128);
  TRIG_ILA5_1                               <= dbg_app_wdf_data(79 downto 64) &
                                                 dbg_app_wdf_data(15 downto 0);

  TRIG_ILA5_2                               <= dbg_app_addr;
  TRIG_ILA5_3(31 downto 30)                 <= (others => '0');
  TRIG_ILA5_3(29 downto 0)                  <= memc_ui_rst &
                                                 clk_200mhz_rstn &
                                                 dbg_app_cmd & -- std_logic_vector(2 downto 0);
                                                 dbg_app_en &
                                                 dbg_app_rdy &
                                                 dbg_app_wdf_end &
                                                 dbg_app_wdf_mask(15 downto 0) & -- std_logic_vector(31 downto 0);
                                                 dbg_app_wdf_wren &
                                                 dbg_app_wdf_rdy &
                                                 dbg_arb_req &
                                                 dbg_arb_gnt;
end rtl;
