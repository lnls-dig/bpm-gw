------------------------------------------------------------------------------
-- Title      : Top DSP design
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-09-01
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top design for testing the integration/control of the DSP with
-- FMC130M_4ch board
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-09-01  1.0      lucas.russo        Created
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
-- Custom common cores
use work.dbe_common_pkg.all;
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
-- DSP definitions
use work.dsp_cores_pkg.all;
-- Genrams
use work.genram_pkg.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dbe_bpm_dsp is
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
  --uart_txd_o                                : out std_logic;
  --uart_rxd_i                                : in std_logic;

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

  -- Temperature monitor (LM75AIMM)
  lm75_scl_pad_b                            : inout std_logic;
  lm75_sda_pad_b                            : inout std_logic;

  fmc_lm75_temp_alarm_i                     : in std_logic;

  -- FMC LEDs
  fmc_led1_o                                : out std_logic;
  fmc_led2_o                                : out std_logic;
  fmc_led3_o                                : out std_logic;

  -----------------------------------------
  -- Position Calc signals
  -----------------------------------------

   -- Uncross signals
  clk_swap_o                                 : out std_logic;
  clk_swap2x_o                               : out std_logic;
  flag1_o                                    : out std_logic;
  flag2_o                                    : out std_logic;

  -----------------------------------------
  -- General board status
  -----------------------------------------
  fmc_mmcm_lock_led_o                       : out std_logic;
  fmc_pll_status_led_o                      : out std_logic;

  -----------------------------------------
  -- Button pins
  -----------------------------------------
  buttons_i                                 : in std_logic_vector(7 downto 0);

  -----------------------------------------
  -- User LEDs
  -----------------------------------------
  leds_o                                    : out std_logic_vector(7 downto 0)
);
end dbe_bpm_dsp;

architecture rtl of dbe_bpm_dsp is

  -- Top crossbar layout
  -- Number of slaves
  constant c_slaves                         : natural := 10;
  -- General Dual-port memory, Buffer Single-port memory, DMA control port, MAC,
  --Etherbone, FMC516, Peripherals
  -- Number of masters
  --DMA read+write master, Ethernet MAC, Ethernet MAC adapter read+write master, Etherbone, RS232-Syscon
  constant c_masters                        : natural := 7;            -- RS232-Syscon,
  --DMA read+write master, Ethernet MAC, Ethernet MAC adapter read+write master, Etherbone

  --constant c_dpram_size                     : natural := 131072/4; -- in 32-bit words (128KB)
  constant c_dpram_size                       : natural := 90112/4; -- in 32-bit words (90KB)
  --constant c_dpram_ethbuf_size              : natural := 32768/4; -- in 32-bit words (32KB)
  --constant c_dpram_ethbuf_size              : natural := 65536/4; -- in 32-bit words (64KB)
  constant c_dpram_ethbuf_size                : natural := 16384/4; -- in 32-bit words (16KB)

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

  -- DSP constants
  --constant c_dsp_ref_num_bits               : natural := 24;
  --constant c_dsp_pos_num_bits               : natural := 26;

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
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
    ( 0 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size),  x"00000000"),   -- 128KB RAM
      1 => f_sdb_embed_device(f_xwb_dpram(c_dpram_size),  x"10000000"),   -- Second port to the same memory
      2 => f_sdb_embed_device(f_xwb_dpram(c_dpram_ethbuf_size),
                                                          x"20000000"),   -- 64KB RAM
      3 => f_sdb_embed_device(c_xwb_dma_sdb,              x"30004000"),   -- DMA control port
      4 => f_sdb_embed_device(c_xwb_ethmac_sdb,           x"30005000"),   -- Ethernet MAC control port
      5 => f_sdb_embed_device(c_xwb_ethmac_adapter_sdb,   x"30006000"),   -- Ethernet Adapter control port
      6 => f_sdb_embed_device(c_xwb_etherbone_sdb,        x"30007000"),   -- Etherbone control port
      7 => f_sdb_embed_device(c_xwb_position_calc_core_sdb,
                                                          x"30008000"),   -- Position Calc Core control port
      8 => f_sdb_embed_bridge(c_fmc130m_4ch_bridge_sdb,   x"30010000"),   -- FMC130m_4ch control port
      9 => f_sdb_embed_bridge(c_periph_bridge_sdb,        x"30020000")    -- General peripherals control port
    );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well
  constant c_sdb_address                    : t_wishbone_address := x"30000000";

  -- FMC ADC data constants
  constant c_adc_data_ch0_lsb               : natural := 0;
  constant c_adc_data_ch0_msb               : natural := c_num_adc_bits-1 + c_adc_data_ch0_lsb;

  constant c_adc_data_ch1_lsb               : natural := c_adc_data_ch0_msb + 1;
  constant c_adc_data_ch1_msb               : natural := c_num_adc_bits-1 + c_adc_data_ch1_lsb;

  constant c_adc_data_ch2_lsb               : natural := c_adc_data_ch1_msb + 1;
  constant c_adc_data_ch2_msb               : natural := c_num_adc_bits-1 + c_adc_data_ch2_lsb;

  constant c_adc_data_ch3_lsb               : natural := c_adc_data_ch2_msb + 1;
  constant c_adc_data_ch3_msb               : natural := c_num_adc_bits-1 + c_adc_data_ch3_lsb;

  -- Crossbar master/slave arrays
  signal cbar_slave_i                       : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_o                       : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_i                      : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_o                      : t_wishbone_master_out_array(c_slaves-1 downto 0);

  -- LM32 signals
  signal clk_sys                            : std_logic;
  signal lm32_interrupt                     : std_logic_vector(31 downto 0);
  signal lm32_rstn                          : std_logic;

  -- Clocks and resets signals
  signal locked                             : std_logic;
  signal clk_sys_rstn                       : std_logic;
  signal clk_sys_rst                        : std_logic;

  signal rst_button_sys_pp                  : std_logic;
  signal rst_button_sys                     : std_logic;
  signal rst_button_sys_n                   : std_logic;

  -- Only one clock domain
  signal reset_clks                         : std_logic_vector(0 downto 0);
  signal reset_rstn                         : std_logic_vector(0 downto 0);

  signal rs232_rstn                         : std_logic;
  signal fs_rstn                            : std_logic;

  -- 200 Mhz clocck for iodelay_ctrl
  signal clk_200mhz                         : std_logic;

  -- ADC clock
  signal fs_clk                             : std_logic;
  signal fs_clk2x                           : std_logic;

  -- Global Clock Single ended
  signal sys_clk_gen                        : std_logic;

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

  signal adc_data_ch0                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ch1                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ch2                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ch3                       : std_logic_vector(c_num_adc_bits-1 downto 0);

  signal fmc_debug                          : std_logic;
  signal reset_adc_counter                  : unsigned(6 downto 0) := (others => '0');
  signal fmc_130m_4ch_rst_n                 : std_logic_vector(c_num_adc_channels-1 downto 0);

  -- fmc130m_4ch Debug
  signal fmc130m_4ch_debug_valid_int        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc130m_4ch_debug_full_int         : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fmc130m_4ch_debug_empty_int        : std_logic_vector(c_num_adc_channels-1 downto 0);

  signal adc_dly_debug_int                  : t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

  -- Uncross signals
  signal un_cross_gain_aa                   : std_logic_vector(15 downto 0);
  signal un_cross_gain_bb                   : std_logic_vector(15 downto 0);
  signal un_cross_gain_cc                   : std_logic_vector(15 downto 0);
  signal un_cross_gain_dd                   : std_logic_vector(15 downto 0);
  signal un_cross_gain_ac                   : std_logic_vector(15 downto 0);
  signal un_cross_gain_bd                   : std_logic_vector(15 downto 0);
  signal un_cross_gain_ca                   : std_logic_vector(15 downto 0);
  signal un_cross_gain_db                   : std_logic_vector(15 downto 0);

  signal un_cross_delay_1                   : std_logic_vector(15 downto 0);
  signal un_cross_delay_2                   : std_logic_vector(15 downto 0);

  signal adc_ch0_data_uncross               : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_ch1_data_uncross               : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_ch2_data_uncross               : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_ch3_data_uncross               : std_logic_vector(c_num_adc_bits-1 downto 0);

  signal un_cross_mode_1                    : std_logic_vector(1 downto 0);
  signal un_cross_mode_2                    : std_logic_vector(1 downto 0);

  signal un_cross_div_f                     : std_logic_vector(15 downto 0);

  signal flag1_int                          : std_logic;
  signal flag2_int                          : std_logic;

  -- DSP signals
  signal dsp_kx                             : std_logic_vector(24 downto 0);
  signal dsp_ky                             : std_logic_vector(24 downto 0);
  signal dsp_ksum                           : std_logic_vector(24 downto 0);

  signal dsp_kx_in                          : std_logic_vector(24 downto 0);
  signal dsp_ky_in                          : std_logic_vector(24 downto 0);
  signal dsp_ksum_in                        : std_logic_vector(24 downto 0);

  signal dsp_del_sig_div_thres_sel          : std_logic_vector(1 downto 0);
  signal dsp_kx_sel                         : std_logic_vector(1 downto 0);
  signal dsp_ky_sel                         : std_logic_vector(1 downto 0);
  signal dsp_ksum_sel                       : std_logic_vector(1 downto 0);

  signal dsp_del_sig_div_thres              : std_logic_vector(25 downto 0);
  signal dsp_del_sig_div_thres_in           : std_logic_vector(25 downto 0);

  signal dsp_dds_config_valid_ch0           : std_logic;
  signal dsp_dds_config_valid_ch1           : std_logic;
  signal dsp_dds_config_valid_ch2           : std_logic;
  signal dsp_dds_config_valid_ch3           : std_logic;
  signal dsp_dds_pinc_ch0                   : std_logic_vector(29 downto 0);
  signal dsp_dds_pinc_ch1                   : std_logic_vector(29 downto 0);
  signal dsp_dds_pinc_ch2                   : std_logic_vector(29 downto 0);
  signal dsp_dds_pinc_ch3                   : std_logic_vector(29 downto 0);
  signal dsp_dds_poff_ch0                   : std_logic_vector(29 downto 0);
  signal dsp_dds_poff_ch1                   : std_logic_vector(29 downto 0);
  signal dsp_dds_poff_ch2                   : std_logic_vector(29 downto 0);
  signal dsp_dds_poff_ch3                   : std_logic_vector(29 downto 0);

  signal dsp_adc_ch0_dbg_data               : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal dsp_adc_ch1_dbg_data               : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal dsp_adc_ch2_dbg_data               : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal dsp_adc_ch3_dbg_data               : std_logic_vector(c_num_adc_bits-1 downto 0);

  signal dsp_adc_ch0_data                   : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal dsp_adc_ch1_data                   : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal dsp_adc_ch2_data                   : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal dsp_adc_ch3_data                   : std_logic_vector(c_num_adc_bits-1 downto 0);

  signal adc_ch0_data                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_ch1_data                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_ch2_data                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_ch3_data                       : std_logic_vector(c_num_adc_bits-1 downto 0);

  signal dsp_bpf_ch0                        : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_bpf_ch2                        : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_bpf_valid                      : std_logic;

  signal dsp_mix_ch0                        : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_mix_ch2                        : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_mix_valid                      : std_logic;

  signal dsp_poly35_ch0                     : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_poly35_ch2                     : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);

  signal dsp_cic_fofb_ch0                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_cic_fofb_ch2                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);

  signal dsp_tbt_amp_ch0                    : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_tbt_amp_ch0_valid              : std_logic;
  signal dsp_tbt_amp_ch1                    : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_tbt_amp_ch1_valid              : std_logic;
  signal dsp_tbt_amp_ch2                    : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_tbt_amp_ch2_valid              : std_logic;
  signal dsp_tbt_amp_ch3                    : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_tbt_amp_ch3_valid              : std_logic;

  signal dsp_tbt_pha_ch0                    : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_tbt_pha_ch0_valid              : std_logic;
  signal dsp_tbt_pha_ch1                    : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_tbt_pha_ch1_valid              : std_logic;
  signal dsp_tbt_pha_ch2                    : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_tbt_pha_ch2_valid              : std_logic;
  signal dsp_tbt_pha_ch3                    : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_tbt_pha_ch3_valid              : std_logic;

  signal dsp_fofb_amp_ch0                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_fofb_amp_ch0_valid             : std_logic;
  signal dsp_fofb_amp_ch1                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_fofb_amp_ch1_valid             : std_logic;
  signal dsp_fofb_amp_ch2                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_fofb_amp_ch2_valid             : std_logic;
  signal dsp_fofb_amp_ch3                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_fofb_amp_ch3_valid             : std_logic;

  signal dsp_fofb_pha_ch0                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_fofb_pha_ch0_valid             : std_logic;
  signal dsp_fofb_pha_ch1                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_fofb_pha_ch1_valid             : std_logic;
  signal dsp_fofb_pha_ch2                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_fofb_pha_ch2_valid             : std_logic;
  signal dsp_fofb_pha_ch3                   : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_fofb_pha_ch3_valid             : std_logic;

  signal dsp_monit_amp_ch0                  : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_monit_amp_ch0_valid            : std_logic;
  signal dsp_monit_amp_ch1                  : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_monit_amp_ch1_valid            : std_logic;
  signal dsp_monit_amp_ch2                  : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_monit_amp_ch2_valid            : std_logic;
  signal dsp_monit_amp_ch3                  : std_logic_vector(c_dsp_ref_num_bits-1 downto 0);
  signal dsp_monit_amp_ch3_valid            : std_logic;

  signal dsp_x_tbt                          : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_x_tbt_valid                    : std_logic;
  signal dsp_y_tbt                          : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_y_tbt_valid                    : std_logic;
  signal dsp_q_tbt                          : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_q_tbt_valid                    : std_logic;
  signal dsp_sum_tbt                        : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_sum_tbt_valid                  : std_logic;

  signal dsp_x_fofb                         : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_x_fofb_valid                   : std_logic;
  signal dsp_y_fofb                         : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_y_fofb_valid                   : std_logic;
  signal dsp_q_fofb                         : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_q_fofb_valid                   : std_logic;
  signal dsp_sum_fofb                       : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_sum_fofb_valid                 : std_logic;

  signal dsp_x_monit                        : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_x_monit_valid                  : std_logic;
  signal dsp_y_monit                        : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_y_monit_valid                  : std_logic;
  signal dsp_q_monit                        : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_q_monit_valid                  : std_logic;
  signal dsp_sum_monit                      : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_sum_monit_valid                : std_logic;

  signal dsp_x_monit_1                      : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_x_monit_1_valid                : std_logic;
  signal dsp_y_monit_1                      : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_y_monit_1_valid                : std_logic;
  signal dsp_q_monit_1                      : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_q_monit_1_valid                : std_logic;
  signal dsp_sum_monit_1                    : std_logic_vector(c_dsp_pos_num_bits-1 downto 0);
  signal dsp_sum_monit_1_valid              : std_logic;

  signal dsp_tbt_decim_q_ch01_incorrect     : std_logic;
  signal dsp_tbt_decim_q_ch23_incorrect     : std_logic;
  signal dsp_fofb_decim_q_01_missing        : std_logic;
  signal dsp_fofb_decim_q_23_missing        : std_logic;
  signal dsp_monit_cic_unexpected           : std_logic;
  signal dsp_monit_cfir_incorrect           : std_logic;
  signal dsp_monit_pfir_incorrect           : std_logic;
  signal dsp_monit_pos_1_incorrect          : std_logic;

  signal dsp_clk_ce_1                       : std_logic;
  signal dsp_clk_ce_2                       : std_logic;
  signal dsp_clk_ce_35                      : std_logic;
  signal dsp_clk_ce_70                      : std_logic;
  signal dsp_clk_ce_1390000                 : std_logic;
  signal dsp_clk_ce_1112                    : std_logic;
  signal dsp_clk_ce_2224                    : std_logic;
  signal dsp_clk_ce_11120000                : std_logic;
  signal dsp_clk_ce_111200000               : std_logic;
  signal dsp_clk_ce_22240000                : std_logic;
  signal dsp_clk_ce_222400000               : std_logic;
  signal dsp_clk_ce_5000                    : std_logic;
  signal dsp_clk_ce_556                     : std_logic;
  signal dsp_clk_ce_2780000                 : std_logic;
  signal dsp_clk_ce_5560000                 : std_logic;

  -- DDS test
  signal dds_data                           : std_logic_vector(2*c_num_adc_bits-1 downto 0); -- cosine + sine
  signal dds_sine                           : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal dds_cosine                         : std_logic_vector(c_num_adc_bits-1 downto 0);

  signal synth_adc0                         : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal synth_adc1                         : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal synth_adc2                         : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal synth_adc3                         : std_logic_vector(c_num_adc_bits-1 downto 0);

  signal synth_adc0_full                    : std_logic_vector(25 downto 0);
  signal synth_adc1_full                    : std_logic_vector(25 downto 0);
  signal synth_adc2_full                    : std_logic_vector(25 downto 0);
  signal synth_adc3_full                    : std_logic_vector(25 downto 0);

  signal dds_sine_gain_ch0                  : std_logic_vector(9 downto 0);
  signal dds_sine_gain_ch1                  : std_logic_vector(9 downto 0);
  signal dds_sine_gain_ch2                  : std_logic_vector(9 downto 0);
  signal dds_sine_gain_ch3                  : std_logic_vector(9 downto 0);
  signal adc_synth_data_en                  : std_logic;

  signal clk_rffe_swap                      : std_logic;

  -- GPIO LED signals
  signal gpio_slave_led_o                   : t_wishbone_slave_out;
  signal gpio_slave_led_i                   : t_wishbone_slave_in;
  signal gpio_leds_int                      : std_logic_vector(c_leds_num_pins-1 downto 0);
  -- signal leds_gpio_dummy_in                : std_logic_vector(c_leds_num_pins-1 downto 0);

  -- GPIO Button signals
  signal gpio_slave_button_o                : t_wishbone_slave_out;
  signal gpio_slave_button_i                : t_wishbone_slave_in;

  -- Chipscope control signals
  signal CONTROL0                           : std_logic_vector(35 downto 0);
  signal CONTROL1                           : std_logic_vector(35 downto 0);
  signal CONTROL2                           : std_logic_vector(35 downto 0);
  signal CONTROL3                           : std_logic_vector(35 downto 0);
  signal CONTROL4                           : std_logic_vector(35 downto 0);
  signal CONTROL5                           : std_logic_vector(35 downto 0);
  signal CONTROL6                           : std_logic_vector(35 downto 0);
  signal CONTROL7                           : std_logic_vector(35 downto 0);
  signal CONTROL8                           : std_logic_vector(35 downto 0);
  signal CONTROL9                           : std_logic_vector(35 downto 0);
  signal CONTROL10                          : std_logic_vector(35 downto 0);
  signal CONTROL11                          : std_logic_vector(35 downto 0);
  signal CONTROL12                          : std_logic_vector(35 downto 0);

  -- Chipscope ILA 0 signals
  signal TRIG_ILA0_0                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA0_3                        : std_logic_vector(31 downto 0);

  -- Chipscope ILA 1 signals
  signal TRIG_ILA1_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA1_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA1_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila1                       : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_out_ila1                      : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_ila1_rd                       : std_logic;
  signal fifo_ila1_empty                    : std_logic;
  signal fifo_ila1_valid                    : std_logic;

  -- Chipscope ILA 2 signals
  signal TRIG_ILA2_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA2_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA2_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila2                       : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_out_ila2                      : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_ila2_rd                       : std_logic;
  signal fifo_ila2_empty                    : std_logic;
  signal fifo_ila2_valid                    : std_logic;

  -- Chipscope ILA 3 signals
  signal TRIG_ILA3_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA3_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA3_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila3                       : std_logic_vector(4*c_dsp_pos_num_bits-1 downto 0);
  signal fifo_out_ila3                      : std_logic_vector(4*c_dsp_pos_num_bits-1 downto 0);
  signal fifo_ila3_rd                       : std_logic;
  signal fifo_ila3_empty                    : std_logic;
  signal fifo_ila3_valid                    : std_logic;

  -- Chipscope ILA 4 signals
  signal TRIG_ILA4_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA4_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA4_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila4                       : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_out_ila4                      : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_ila4_rd                       : std_logic;
  signal fifo_ila4_empty                    : std_logic;
  signal fifo_ila4_valid                    : std_logic;

  -- Chipscope ILA 5 signals
  signal TRIG_ILA5_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA5_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA5_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA5_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA5_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila5                       : std_logic_vector(4*c_dsp_pos_num_bits-1 downto 0);
  signal fifo_out_ila5                      : std_logic_vector(4*c_dsp_pos_num_bits-1 downto 0);
  signal fifo_ila5_rd                       : std_logic;
  signal fifo_ila5_empty                    : std_logic;
  signal fifo_ila5_valid                    : std_logic;

  -- Chipscope ILA 6 signals
  signal TRIG_ILA6_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA6_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA6_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA6_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA6_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila6                       : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_out_ila6                      : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_ila6_rd                       : std_logic;
  signal fifo_ila6_empty                    : std_logic;
  signal fifo_ila6_valid                    : std_logic;

  -- Chipscope ILA 7 signals
  signal TRIG_ILA7_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA7_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA7_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA7_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA7_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila7                       : std_logic_vector(4*c_dsp_pos_num_bits-1 downto 0);
  signal fifo_out_ila7                      : std_logic_vector(4*c_dsp_pos_num_bits-1 downto 0);
  signal fifo_ila7_rd                       : std_logic;
  signal fifo_ila7_empty                    : std_logic;
  signal fifo_ila7_valid                    : std_logic;

  -- Chipscope ILA 8 signals
  signal TRIG_ILA8_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA8_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA8_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA8_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA8_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila8                       : std_logic_vector(4*c_dsp_pos_num_bits-1 downto 0);
  signal fifo_out_ila8                      : std_logic_vector(4*c_dsp_pos_num_bits-1 downto 0);
  signal fifo_ila8_rd                       : std_logic;
  signal fifo_ila8_empty                    : std_logic;
  signal fifo_ila8_valid                    : std_logic;

  -- Chipscope ILA 9 signals
  signal TRIG_ILA9_0                        : std_logic_vector(7 downto 0);
  signal TRIG_ILA9_1                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA9_2                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA9_3                        : std_logic_vector(31 downto 0);
  signal TRIG_ILA9_4                        : std_logic_vector(31 downto 0);

  signal fifo_in_ila9                       : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_out_ila9                      : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_ila9_rd                       : std_logic;
  signal fifo_ila9_empty                    : std_logic;
  signal fifo_ila9_valid                    : std_logic;

  -- Chipscope ILA 10 signals
  signal TRIG_ILA10_0                       : std_logic_vector(7 downto 0);
  signal TRIG_ILA10_1                       : std_logic_vector(31 downto 0);
  signal TRIG_ILA10_2                       : std_logic_vector(31 downto 0);
  signal TRIG_ILA10_3                       : std_logic_vector(31 downto 0);
  signal TRIG_ILA10_4                       : std_logic_vector(31 downto 0);

  signal fifo_in_ila10                      : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_out_ila10                     : std_logic_vector(4*c_dsp_ref_num_bits-1 downto 0);
  signal fifo_ila10_rd                      : std_logic;
  signal fifo_ila10_empty                   : std_logic;
  signal fifo_ila10_valid                    : std_logic;

  -- Chipscope VIO signals
 signal vio_out                             : std_logic_vector(255 downto 0);
 signal vio_out_dsp_config                  : std_logic_vector(255 downto 0);

  ---------------------------
  --      Components       --
  ---------------------------

  -- Clock generation
  component clk_gen is
  port(
    sys_clk_p_i                             : in std_logic;
    sys_clk_n_i                             : in std_logic;
    sys_clk_o                               : out std_logic
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

  component un_cross_top
  generic(
    g_delay_vec_width         : natural range 0 to 16 := 16;
    g_swap_div_freq_vec_width : natural range 0 to 16 := 16
  );
  port(
    -- Commom signals
    clk_i        :  in   std_logic;
    rst_n_i      :  in   std_logic;

    -- inv_chs_top core signal
    const_aa_i   :  in   std_logic_vector(15 downto 0);
    const_bb_i   :  in   std_logic_vector(15 downto 0);
    const_cc_i   :  in   std_logic_vector(15 downto 0);
    const_dd_i   :  in   std_logic_vector(15 downto 0);
    const_ac_i   :  in   std_logic_vector(15 downto 0);
    const_bd_i   :  in   std_logic_vector(15 downto 0);
    const_ca_i   :  in   std_logic_vector(15 downto 0);
    const_db_i   :  in   std_logic_vector(15 downto 0);

    delay1_i     :  in   std_logic_vector(g_delay_vec_width-1 downto 0);
    delay2_i     :  in   std_logic_vector(g_delay_vec_width-1 downto 0);

    flag1_o      :  out   std_logic;
    flag2_o      :  out   std_logic;

    -- Input from ADC FMC board
    cha_i        :  in   std_logic_vector(15 downto 0);
    chb_i        :  in   std_logic_vector(15 downto 0);
    chc_i        :  in   std_logic_vector(15 downto 0);
    chd_i        :  in   std_logic_vector(15 downto 0);

    -- Output to data processing level
    cha_o        :  out  std_logic_vector(15 downto 0);
    chb_o        :  out  std_logic_vector(15 downto 0);
    chc_o        :  out  std_logic_vector(15 downto 0);
    chd_o        :  out  std_logic_vector(15 downto 0);

    -- Swap clock for RFFE
    clk_swap_o   : out std_logic;

    -- swap_cnt_top signal
    mode1_i      :  in    std_logic_vector(1 downto 0);
    mode2_i      :  in    std_logic_vector(1 downto 0);

    swap_div_f_i :  in    std_logic_vector(g_swap_div_freq_vec_width-1 downto 0);

    -- Output to RFFE board
    ctrl1_o      :  out   std_logic_vector(7 downto 0);
    ctrl2_o      :  out   std_logic_vector(7 downto 0)
  );
  end component;

  -- Xilinx Chipscope Controller
  component chipscope_icon_1_port
  port (
    CONTROL0                                : inout std_logic_vector(35 downto 0)
  );
  end component;

  component multiplier_16x10_DSP
  port (
    clk                                     : in std_logic;
    a                                       : in std_logic_vector(15 downto 0);
    b                                       : in std_logic_vector(9 downto 0);
    p                                       : out std_logic_vector(25 downto 0)
  );
  end component;

  component dds_adc_input
  port (
    aclk                                    : in std_logic;
    m_axis_data_tvalid                      : out std_logic;
    m_axis_data_tdata                       : out std_logic_vector(31 downto 0)
  );
  end component;

  component chipscope_icon_13_port
  port (
    CONTROL0                                : inout std_logic_vector(35 downto 0);
    CONTROL1                                : inout std_logic_vector(35 downto 0);
    CONTROL2                                : inout std_logic_vector(35 downto 0);
    CONTROL3                                : inout std_logic_vector(35 downto 0);
    CONTROL4                                : inout std_logic_vector(35 downto 0);
    CONTROL5                                : inout std_logic_vector(35 downto 0);
    CONTROL6                                : inout std_logic_vector(35 downto 0);
    CONTROL7                                : inout std_logic_vector(35 downto 0);
    CONTROL8                                : inout std_logic_vector(35 downto 0);
    CONTROL9                                : inout std_logic_vector(35 downto 0);
    CONTROL10                               : inout std_logic_vector(35 downto 0);
    CONTROL11                               : inout std_logic_vector(35 downto 0);
    CONTROL12                               : inout std_logic_vector(35 downto 0)
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
  component chipscope_ila_1024
  port (
    control                                 : inout std_logic_vector(35 downto 0);
    clk                                     : in std_logic;
    trig0                                   : in std_logic_vector(7 downto 0);
    trig1                                   : in std_logic_vector(31 downto 0);
    trig2                                   : in std_logic_vector(31 downto 0);
    trig3                                   : in std_logic_vector(31 downto 0);
    trig4                                   : in std_logic_vector(31 downto 0));
  end component;

  component chipscope_ila_65536
  port (
    control                                 : inout std_logic_vector(35 downto 0);
    clk                                     : in std_logic;
    trig0                                   : in std_logic_vector(7 downto 0);
    trig1                                   : in std_logic_vector(31 downto 0);
    trig2                                   : in std_logic_vector(31 downto 0);
    trig3                                   : in std_logic_vector(31 downto 0);
    trig4                                   : in std_logic_vector(31 downto 0));
  end component;

  component chipscope_ila_131072
  port (
    control                                 : inout std_logic_vector(35 downto 0);
    clk                                     : in std_logic;
    trig0                                   : in std_logic_vector(7 downto 0);
    trig1                                   : in std_logic_vector(15 downto 0);
    trig2                                   : in std_logic_vector(15 downto 0);
    trig3                                   : in std_logic_vector(15 downto 0);
    trig4                                   : in std_logic_vector(15 downto 0));
  end component;

  component chipscope_vio_256 is
  port (
    control                                 : inout std_logic_vector(35 downto 0);
    async_out                               : out std_logic_vector(255 downto 0)
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
    sys_clk_o                               => sys_clk_gen
  );

  -- Obtain core locking and generate necessary clocks
  cmp_sys_pll_inst : sys_pll
  port map (
    rst_i                                   => '0',
    clk_i                                   => sys_clk_gen,
    clk0_o                                  => clk_sys,     -- 100MHz locked clock
    clk1_o                                  => clk_200mhz,  -- 200MHz locked clock
    locked_o                                => locked        -- '1' when the PLL has locked
  );

  -- Reset synchronization. Hold reset line until few locked cycles have passed.
  cmp_reset : gc_reset
  generic map(
    g_clocks                                => 1    -- CLK_SYS
  )
  port map(
    free_clk_i                              => sys_clk_gen,
    locked_i                                => locked,
    clks_i                                  => reset_clks,
    rstn_o                                  => reset_rstn
  );

  reset_clks(0)                             <= clk_sys;
  clk_sys_rstn                              <= reset_rstn(0) and rst_button_sys_n and rs232_rstn;
  clk_sys_rst                               <= not clk_sys_rstn;
  mrstn_o                                   <= clk_sys_rstn;

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
  lm32_rstn                                 <= clk_sys_rstn;

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

  lm32_interrupt <= (0 => ethmac_int, 1 => dma_int, 2 => not buttons_i(0), 3 => irq_rx_done,
                      4 => irq_tx_done, others => '0');

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
    wb_master_i                               => cbar_slave_o(0),
    wb_master_o                               => cbar_slave_i(0)
  );

  -- A DMA controller is master 2+3, slave 3, and interrupt 1
  cmp_dma : xwb_dma
  port map(
    clk_i                                   => clk_sys,
    rst_n_i                                 => clk_sys_rstn,
    slave_i                                 => cbar_master_o(3),
    slave_o                                 => cbar_master_i(3),
    r_master_i                              => cbar_slave_o(1),
    r_master_o                              => cbar_slave_i(1),
    w_master_i                              => cbar_slave_o(2),
    w_master_o                              => cbar_slave_i(2),
    interrupt_o                             => dma_int
  );

  -- Slave 0+1 is the RAM. Load a input file containing the embedded software
  cmp_ram : xwb_dpram
  generic map(
    g_size                                  => c_dpram_size, -- must agree with sw/target/lm32/ram.ld:LENGTH / 4
    --g_init_file                             => "../../../embedded-sw/dbe.ram",
    --"../../top/ml_605/dbe_bpm_simple/sw/main.ram",
    --g_must_have_init_file                   => true,
    g_must_have_init_file                   => false,
    g_slave1_interface_mode                 => PIPELINED,
    g_slave2_interface_mode                 => PIPELINED,
    g_slave1_granularity                    => BYTE,
    g_slave2_granularity                    => BYTE
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
    wb_master_in                            => cbar_slave_o(3),
    wb_master_out                           => cbar_slave_i(3),

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

  ---- Tri-state buffer for MII config
  md_pad_b <= ethmac_md_out when ethmac_md_oe = '1' else 'Z';
  ethmac_md_in <= md_pad_b;

  mtxd_pad_o                                <=  mtxd_pad_int;
  mtxen_pad_o                               <=  mtxen_pad_int;
  mtxerr_pad_o                              <=  mtxerr_pad_int;
  mdc_pad_o                                 <=  mdc_pad_int;

  --The Ethernet MAC Adapter is master 5+6, slave 5
  cmp_xwb_ethmac_adapter : xwb_ethmac_adapter
  port map(
    clk_i                                   => clk_sys,
    rstn_i                                  => clk_sys_rstn,

    wb_slave_o                              => cbar_master_i(5),
    wb_slave_i                              => cbar_master_o(5),

    tx_ram_o                                => cbar_slave_i(4),
    tx_ram_i                                => cbar_slave_o(4),

    rx_ram_o                                => cbar_slave_i(5),
    rx_ram_i                                => cbar_slave_o(5),

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

  cbar_slave_i(6)                           <= wb_ebone_out;
  wb_ebone_in                               <= cbar_slave_o(6);

  -- The FMC130M_4CH is slave 8
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
    wb_slv_i                                => cbar_master_o(8),
    wb_slv_o                                => cbar_master_i(8),

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

  adc_data_ch0                              <= fmc_130m_4ch_data(c_adc_data_ch0_msb downto c_adc_data_ch0_lsb);
  adc_data_ch1                              <= fmc_130m_4ch_data(c_adc_data_ch1_msb downto c_adc_data_ch1_lsb);
  adc_data_ch2                              <= fmc_130m_4ch_data(c_adc_data_ch2_msb downto c_adc_data_ch2_lsb);
  adc_data_ch3                              <= fmc_130m_4ch_data(c_adc_data_ch3_msb downto c_adc_data_ch3_lsb);

  fs_clk                                    <= fmc_130m_4ch_clk(c_adc_ref_clk);
  fs_rstn                                   <= fmc_130m_4ch_rst_n(c_adc_ref_clk);
  fs_clk2x                                  <= fmc_130m_4ch_clk2x(c_adc_ref_clk);

  --led_south_o                               <= fmc_led1_int;
  --led_east_o                                <= fmc_led2_int;
  --led_north_o                               <= fmc_led3_int;

  ----------------------------------------------------------------------
  --                      DSP Chain Core                              --
  ----------------------------------------------------------------------

  -- Testing with internal DDS
  cmp_dds_adc_input : dds_adc_input
  port map (
    aclk                                    => fs_clk,
    m_axis_data_tvalid                      => open,
    m_axis_data_tdata                       => dds_data
  );

  dds_sine                                  <= dds_data(31 downto 16);
  dds_cosine                                <= dds_data(15 downto 0);

  cmp_multiplier_16x10_DSP_ch0 : multiplier_16x10_DSP
  port map (
    clk                                     => fs_clk,
    a                                       => dds_sine,
    b                                       => dds_sine_gain_ch0,
    p                                       => synth_adc0_full
  );

  synth_adc0                                <= synth_adc0_full(25 downto 10);

  cmp_multiplier_16x10_DSP_ch1 : multiplier_16x10_DSP
  port map(
    clk                                     => fs_clk,
    a                                       => dds_sine,
    b                                       => dds_sine_gain_ch1,
    p                                       => synth_adc1_full
  );

  synth_adc1                                <= synth_adc1_full(25 downto 10);

  cmp_multiplier_16x10_DSP_ch2 : multiplier_16x10_DSP
  port map(
    clk                                     => fs_clk,
    a                                       => dds_sine,
    b                                       => dds_sine_gain_ch2,
    p                                       => synth_adc2_full
  );

  synth_adc2                                <= synth_adc2_full(25 downto 10);

  cmp_multiplier_16x10_DSP_ch3 : multiplier_16x10_DSP
  port map (
    clk                                     => fs_clk,
    a                                       => dds_sine,
    b                                       => dds_sine_gain_ch3,
    p                                       => synth_adc3_full
  );

  synth_adc3                                <= synth_adc3_full(25 downto 10);

  -- MUX between sinthetic data and real ADC data

  adc_ch0_data                              <= synth_adc0 when adc_synth_data_en = '1' else adc_data_ch0;
  adc_ch1_data                              <= synth_adc1 when adc_synth_data_en = '1' else adc_data_ch1;
  adc_ch2_data                              <= synth_adc2 when adc_synth_data_en = '1' else adc_data_ch2;
  adc_ch3_data                              <= synth_adc3 when adc_synth_data_en = '1' else adc_data_ch3;

  -- Switch testing. This should be inside position calc core!!!!
  cmp_un_cross_top : un_cross_top
  generic map (
    g_delay_vec_width                       => 16,
    g_swap_div_freq_vec_width               => 16
  )
  port map (
    -- Commom signals
    clk_i                                   => fs_clk,
    rst_n_i                                 => fs_rstn,

    -- inv_chs_top core signal
    const_aa_i                              => un_cross_gain_aa,
    const_bb_i                              => un_cross_gain_bb,
    const_cc_i                              => un_cross_gain_cc,
    const_dd_i                              => un_cross_gain_dd,
    const_ac_i                              => un_cross_gain_ac,
    const_bd_i                              => un_cross_gain_bd,
    const_ca_i                              => un_cross_gain_ca,
    const_db_i                              => un_cross_gain_db,

    delay1_i                                => un_cross_delay_1,
    delay2_i                                => un_cross_delay_2,

    --flag1_o                                 => flag1_int,
    --flag2_o                                 => flag2_int,

    -- Input from ADC FMC board
    cha_i                                   => adc_ch0_data,
    chb_i                                   => adc_ch1_data,
    chc_i                                   => adc_ch2_data,
    chd_i                                   => adc_ch3_data,

    -- Output to data processing level
    cha_o                                   => adc_ch0_data_uncross,
    chb_o                                   => adc_ch1_data_uncross,
    chc_o                                   => adc_ch2_data_uncross,
    chd_o                                   => adc_ch3_data_uncross,

    -- Swap clock for RFFE
    clk_swap_o                              => clk_rffe_swap,

    -- swap_cnt_top signal
    mode1_i                                 => un_cross_mode_1,
    mode2_i                                 => un_cross_mode_2,

    swap_div_f_i                            => un_cross_div_f,

    -- Output to RFFE board
    ctrl1_o                                 => open,
    ctrl2_o                                 => open
  );

  --clk_swap_o                                <= clk_rffe_swap;
  clk_swap_o                                <= fs_clk; -- FIXME!!!!
  clk_swap2x_o                              <= fs_clk2x; -- FIXME!!!!

  -- Position calc core is slave 7
  cmp_xwb_position_calc_core : xwb_position_calc_core
  generic map (
    g_interface_mode                        => PIPELINED,
    g_address_granularity                   => WORD,
    g_with_switching                        => 0
  )
  port map (
    rst_n_i                                 => clk_sys_rstn,
    clk_i                                   => clk_sys,  -- Wishbone clock
    fs_rst_n_i                              => fs_rstn,
    fs_clk_i                                => fs_clk,   -- clock period = 8.8823218389287 ns (112.583175675676 Mhz)
    fs_clk2x_i                              => fs_clk2x, -- clock period = 4.44116091946435 ns (225.16635135135124 Mhz)

    -----------------------------
    -- Wishbone signals
    -----------------------------
    wb_slv_i                                => cbar_master_o(7),
    wb_slv_o                                => cbar_master_i(7),

    -----------------------------
    -- Raw ADC signals
    -----------------------------
    adc_ch0_i                               => adc_ch0_data_uncross,
    adc_ch1_i                               => adc_ch1_data_uncross,
    adc_ch2_i                               => adc_ch2_data_uncross,
    adc_ch3_i                               => adc_ch3_data_uncross,

    -----------------------------
    -- DSP config parameter signals
    -----------------------------
    kx_i                                    => dsp_kx,
    ky_i                                    => dsp_ky,
    ksum_i                                  => dsp_ksum,

    del_sig_div_fofb_thres_i                => dsp_del_sig_div_thres,
    del_sig_div_tbt_thres_i                 => dsp_del_sig_div_thres,
    del_sig_div_monit_thres_i               => dsp_del_sig_div_thres,

    dds_config_valid_ch0_i                  => dsp_dds_config_valid_ch0,
    dds_config_valid_ch1_i                  => dsp_dds_config_valid_ch1,
    dds_config_valid_ch2_i                  => dsp_dds_config_valid_ch2,
    dds_config_valid_ch3_i                  => dsp_dds_config_valid_ch3,
    dds_pinc_ch0_i                          => dsp_dds_pinc_ch0,
    dds_pinc_ch1_i                          => dsp_dds_pinc_ch1,
    dds_pinc_ch2_i                          => dsp_dds_pinc_ch2,
    dds_pinc_ch3_i                          => dsp_dds_pinc_ch3,
    dds_poff_ch0_i                          => dsp_dds_poff_ch0,
    dds_poff_ch1_i                          => dsp_dds_poff_ch1,
    dds_poff_ch2_i                          => dsp_dds_poff_ch2,
    dds_poff_ch3_i                          => dsp_dds_poff_ch3,

    -----------------------------
    -- Position calculation at various rates
    -----------------------------
    adc_ch0_dbg_data_o                      => dsp_adc_ch0_data,
    adc_ch1_dbg_data_o                      => dsp_adc_ch1_data,
    adc_ch2_dbg_data_o                      => dsp_adc_ch2_data,
    adc_ch3_dbg_data_o                      => dsp_adc_ch3_data,

    bpf_ch0_o                               => dsp_bpf_ch0,
    --bpf_ch1_o                               => out std_logic_vector(23 downto 0);
    bpf_ch2_o                               => dsp_bpf_ch2,
    --bpf_ch3_o                               => out std_logic_vector(23 downto 0);
    bpf_valid_o                             => dsp_bpf_valid,

    mix_ch0_i_o                             => dsp_mix_ch0,
    --mix_ch0_q_o                             => out std_logic_vector(23 downto 0);
    --mix_ch1_i_o                             => out std_logic_vector(23 downto 0);
    --mix_ch1_q_o                             => out std_logic_vector(23 downto 0);
    mix_ch2_i_o                             => dsp_mix_ch2,
    --mix_ch2_q_o                             => out std_logic_vector(23 downto 0);
    --mix_ch3_i_o                             => out std_logic_vector(23 downto 0);
    --mix_ch3_q_o                             => out std_logic_vector(23 downto 0);
    mix_valid_o                             => dsp_mix_valid,

    tbt_decim_ch0_i_o                       => dsp_poly35_ch0,
    --tbt_decim_ch0_i_o                       => open,
    --poly35_ch0_q_o                          => out std_logic_vector(23 downto 0);
    --poly35_ch1_i_o                          => out std_logic_vector(23 downto 0);
    --poly35_ch1_q_o                          => out std_logic_vector(23 downto 0);
    tbt_decim_ch2_i_o                       => dsp_poly35_ch2,
    --tbt_decim_ch2_i_o                       => open,
    --poly35_ch2_q_o                          => out std_logic_vector(23 downto 0);
    --poly35_ch3_i_o                          => out std_logic_vector(23 downto 0);
    --poly35_ch3_q_o                          => out std_logic_vector(23 downto 0);

    tbt_decim_q_ch01_incorrect_o            => dsp_tbt_decim_q_ch01_incorrect,
    tbt_decim_q_ch23_incorrect_o            => dsp_tbt_decim_q_ch23_incorrect,

    tbt_amp_ch0_o                           => dsp_tbt_amp_ch0,
    tbt_amp_ch0_valid_o                     => dsp_tbt_amp_ch0_valid,
    tbt_amp_ch1_o                           => dsp_tbt_amp_ch1,
    tbt_amp_ch1_valid_o                     => dsp_tbt_amp_ch1_valid,
    tbt_amp_ch2_o                           => dsp_tbt_amp_ch2,
    tbt_amp_ch2_valid_o                     => dsp_tbt_amp_ch2_valid,
    tbt_amp_ch3_o                           => dsp_tbt_amp_ch3,
    tbt_amp_ch3_valid_o                     => dsp_tbt_amp_ch3_valid,

    tbt_pha_ch0_o                           => dsp_tbt_pha_ch0,
    tbt_pha_ch0_valid_o                     => dsp_tbt_pha_ch0_valid,
    tbt_pha_ch1_o                           => dsp_tbt_pha_ch1,
    tbt_pha_ch1_valid_o                     => dsp_tbt_pha_ch1_valid,
    tbt_pha_ch2_o                           => dsp_tbt_pha_ch2,
    tbt_pha_ch2_valid_o                     => dsp_tbt_pha_ch2_valid,
    tbt_pha_ch3_o                           => dsp_tbt_pha_ch3,
    tbt_pha_ch3_valid_o                     => dsp_tbt_pha_ch3_valid,

    fofb_decim_ch0_i_o                      => dsp_cic_fofb_ch0, --out std_logic_vector(23 downto 0);
    --cic_fofb_ch0_q_o                        => out std_logic_vector(24 downto 0);
    --cic_fofb_ch1_i_o                        => out std_logic_vector(24 downto 0);
    --cic_fofb_ch1_q_o                        => out std_logic_vector(24 downto 0);
    fofb_decim_ch2_i_o                      => dsp_cic_fofb_ch2, --out std_logic_vector(23 downto 0);
    --cic_fofb_ch2_q_o                        => out std_logic_vector(24 downto 0);
    --cic_fofb_ch3_i_o                        => out std_logic_vector(24 downto 0);
    --cic_fofb_ch3_q_o                        => out std_logic_vector(24 downto 0);

    fofb_decim_q_01_missing_o               => dsp_fofb_decim_q_01_missing,
    fofb_decim_q_23_missing_o               => dsp_fofb_decim_q_23_missing,

    fofb_amp_ch0_o                          => dsp_fofb_amp_ch0,
    fofb_amp_ch0_valid_o                    => dsp_fofb_amp_ch0_valid,
    fofb_amp_ch1_o                          => dsp_fofb_amp_ch1,
    fofb_amp_ch1_valid_o                    => dsp_fofb_amp_ch1_valid,
    fofb_amp_ch2_o                          => dsp_fofb_amp_ch2,
    fofb_amp_ch2_valid_o                    => dsp_fofb_amp_ch2_valid,
    fofb_amp_ch3_o                          => dsp_fofb_amp_ch3,
    fofb_amp_ch3_valid_o                    => dsp_fofb_amp_ch3_valid,

    fofb_pha_ch0_o                          => dsp_fofb_pha_ch0,
    fofb_pha_ch0_valid_o                    => dsp_fofb_pha_ch0_valid,
    fofb_pha_ch1_o                          => dsp_fofb_pha_ch1,
    fofb_pha_ch1_valid_o                    => dsp_fofb_pha_ch1_valid,
    fofb_pha_ch2_o                          => dsp_fofb_pha_ch2,
    fofb_pha_ch2_valid_o                    => dsp_fofb_pha_ch2_valid,
    fofb_pha_ch3_o                          => dsp_fofb_pha_ch3,
    fofb_pha_ch3_valid_o                    => dsp_fofb_pha_ch3_valid,

    monit_amp_ch0_o                         => dsp_monit_amp_ch0,
    monit_amp_ch0_valid_o                   => dsp_monit_amp_ch0_valid,
    monit_amp_ch1_o                         => dsp_monit_amp_ch1,
    monit_amp_ch1_valid_o                   => dsp_monit_amp_ch1_valid,
    monit_amp_ch2_o                         => dsp_monit_amp_ch2,
    monit_amp_ch2_valid_o                   => dsp_monit_amp_ch2_valid,
    monit_amp_ch3_o                         => dsp_monit_amp_ch3,
    monit_amp_ch3_valid_o                   => dsp_monit_amp_ch3_valid,

    x_tbt_o                                 => dsp_x_tbt,
    x_tbt_valid_o                           => dsp_x_tbt_valid,
    y_tbt_o                                 => dsp_y_tbt,
    y_tbt_valid_o                           => dsp_y_tbt_valid,
    q_tbt_o                                 => dsp_q_tbt,
    q_tbt_valid_o                           => dsp_q_tbt_valid,
    sum_tbt_o                               => dsp_sum_tbt,
    sum_tbt_valid_o                         => dsp_sum_tbt_valid,

    x_fofb_o                                => dsp_x_fofb,
    x_fofb_valid_o                          => dsp_x_fofb_valid,
    y_fofb_o                                => dsp_y_fofb,
    y_fofb_valid_o                          => dsp_y_fofb_valid,
    q_fofb_o                                => dsp_q_fofb,
    q_fofb_valid_o                          => dsp_q_fofb_valid,
    sum_fofb_o                              => dsp_sum_fofb,
    sum_fofb_valid_o                        => dsp_sum_fofb_valid,

    x_monit_o                               => dsp_x_monit,
    x_monit_valid_o                         => dsp_x_monit_valid,
    y_monit_o                               => dsp_y_monit,
    y_monit_valid_o                         => dsp_y_monit_valid,
    q_monit_o                               => dsp_q_monit,
    q_monit_valid_o                         => dsp_q_monit_valid,
    sum_monit_o                             => dsp_sum_monit,
    sum_monit_valid_o                       => dsp_sum_monit_valid,

    x_monit_1_o                             => dsp_x_monit_1,
    x_monit_1_valid_o                       => dsp_x_monit_1_valid,
    y_monit_1_o                             => dsp_y_monit_1,
    y_monit_1_valid_o                       => dsp_y_monit_1_valid,
    q_monit_1_o                             => dsp_q_monit_1,
    q_monit_1_valid_o                       => dsp_q_monit_1_valid,
    sum_monit_1_o                           => dsp_sum_monit_1,
    sum_monit_1_valid_o                     => dsp_sum_monit_1_valid,

    monit_cic_unexpected_o                  => dsp_monit_cic_unexpected,
    monit_cfir_incorrect_o                  => dsp_monit_cfir_incorrect,
    monit_pfir_incorrect_o                  => dsp_monit_pfir_incorrect,

    -----------------------------
    -- Output to RFFE board
    -----------------------------
    clk_swap_o                              => open,
    ctrl1_o                                 => open,
    ctrl2_o                                 => open,

  -----------------------------
  -- Clock drivers for various rates
  -----------------------------
    clk_ce_1_o                              => dsp_clk_ce_1,
    clk_ce_1112_o                           => dsp_clk_ce_1112,
    clk_ce_11120000_o                       => dsp_clk_ce_11120000,
    clk_ce_1390000_o                        => dsp_clk_ce_1390000,
    clk_ce_2_o                              => dsp_clk_ce_2,
    clk_ce_2224_o                           => dsp_clk_ce_2224,
    clk_ce_22240000_o                       => dsp_clk_ce_22240000,
    clk_ce_2780000_o                        => dsp_clk_ce_2780000,
    clk_ce_35_o                             => dsp_clk_ce_35,
    clk_ce_5000_o                           => dsp_clk_ce_5000,
    clk_ce_556_o                            => dsp_clk_ce_556,
    clk_ce_5560000_o                        => dsp_clk_ce_5560000,
    clk_ce_70_o                             => dsp_clk_ce_70
  );

  --dsp_poly35_ch0 <= (others => '0');
  --dsp_poly35_ch2 <= (others => '0');
  --
  --dsp_monit_amp_ch0 <= (others => '0');
  --dsp_monit_amp_ch1 <= (others => '0');
  --dsp_monit_amp_ch2 <= (others => '0');
  --dsp_monit_amp_ch3 <= (others => '0');

  -- Signals for the DSP chain
  --dsp_del_sig_div_thres                     <= "00000000000000001000000000"; -- aprox 1.22e-4 FIX26_22

  -- register DSP parameters
  p_register_in_dsp_param : process(fs_clk2x)
  begin
    if rising_edge(fs_clk2x) then
      if fs_rstn = '0' then
        dsp_del_sig_div_thres  <= (others => '0');
        dsp_kx                 <= (others => '0');
        dsp_ky                 <= (others => '0');
        dsp_ksum               <= (others => '0');
      else
        dsp_del_sig_div_thres  <=  dsp_del_sig_div_thres_in;
        dsp_kx                 <=  dsp_kx_in;
        dsp_ky                 <=  dsp_ky_in;
        dsp_ksum               <=  dsp_ksum_in;
      end if;
    end if;
  end process;

  -- Division Threshold selection
  with dsp_del_sig_div_thres_sel select
    dsp_del_sig_div_thres_in <= "00000000000000001000000000" when "00", -- aprox 1.2207e-04 FIX26_22
                             "00000000000000000001000000" when "01", -- aprox 1.5259e-05 FIX26_22
                             "00000000000000000000001000" when "10", -- aprox 1.9073e-06 FIX26_22
                             "00000000000000000000000000" when "11", -- 0 FIX26_22
                             "00000000000000001000000000" when others;

  -- Kx selection
  with dsp_kx_sel select
    dsp_kx_in                <= "0100110001001011010000000" when "00",   -- 10000000 UFIX25_0
                             "0010011000100101101000000" when "01",   -- 5000000 UFIX25_0
                             "0001001100010010110100000" when "10",   -- 2500000 UFIX25_0
                             "1000000000000000000000000" when "11",   -- 33554432 UFIX25_0 for testing bit truncation
                             "0100110001001011010000000" when others; -- 10000000 UFIX25_0

  -- Ky selection
  with dsp_ky_sel select
    dsp_ky_in                <= "0100110001001011010000000" when "00",   -- 10000000 UFIX25_0
                             "0010011000100101101000000" when "01",   -- 5000000 UFIX25_0
                             "0001001100010010110100000" when "10",   -- 2500000 UFIX25_0
                             "1000000000000000000000000" when "11",   -- 33554432 UFIX25_0 for testing bit truncation
                             "0100110001001011010000000" when others; -- 10000000 UFIX25_0

  -- Ksum selection
  with dsp_ksum_sel select
    dsp_ksum_in              <= "0111111111111111111111111" when "00",   -- 1.0 FIX25_24
                             "0011111111111111111111111" when "01",   -- 0.5 FIX25_24
                             "0001111111111111111111111" when "10",  -- 0.25 FIX25_24
                             "0000111111111111111111111" when "11",  -- 0.125 FIX25_24
                             "0111111111111111111111111" when others; -- 1.0 FIX25_24

  --dsp_kx                                    <= "0100110001001011010000000"; -- 10000000 UFIX25_0
  --dsp_kx                                    <= "0100000000000000000000000"; -- ??? UFIX25_0
  --dsp_kx                                    <= "00100110001001011010000000"; -- 10000000 UFIX26_0
  --dsp_ky                                    <= "100110001001011010000000"; -- 10000000 UFIX24_0
  --dsp_ky                                    <= "0100000000000000000000000"; -- ??? UFIX25_0
  --dsp_ky                                    <= "00100110001001011010000000"; -- 10000000 UFIX26_0
  --dsp_ksum                                  <= "0111111111111111111111111"; -- 1.0 FIX25_24
  --dsp_ksum                                  <= "10000000000000000000000000"; -- 1.0 FIX26_25
  --dsp_ksum                                  <= "100000000000000000000000"; -- 1.0 FIX24_23
  --dsp_ksum                                  <= "10000000000000000000000000"; -- 1.0 FIX26_25

  --flag1_int                                 <= fs_clk;
  flag1_int                                 <= dsp_clk_ce_35;     -- FIXME!!
  flag2_int                                 <= dsp_clk_ce_70;     -- FIXME!!

  flag1_o                                   <= flag1_int;
  flag2_o                                   <= flag2_int;

  -- The board peripherals components is slave 9
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
    --uart_rxd_i                                => uart_rxd_i,
    --uart_txd_o                                => uart_txd_o,
    uart_rxd_i                                => '1',
    uart_txd_o                                => open,

    -- LEDs
    led_out_o                                 => gpio_leds_int,
    led_in_i                                  => gpio_leds_int,
    led_oen_o                                 => open,

    -- Buttons
    button_out_o                              => open,
    button_in_i                               => buttons_i,
    button_oen_o                              => open,

    -- Wishbone
    slave_i                                   => cbar_master_o(9),
    slave_o                                   => cbar_master_i(9)
  );

  leds_o <= gpio_leds_int;

  -- Chipscope Analysis
  cmp_chipscope_icon_13 : chipscope_icon_13_port
  port map (
     CONTROL0                               => CONTROL0,
     CONTROL1                               => CONTROL1,
     CONTROL2                               => CONTROL2,
     CONTROL3                               => CONTROL3,
     CONTROL4                               => CONTROL4,
     CONTROL5                               => CONTROL5,
     CONTROL6                               => CONTROL6,
     CONTROL7                               => CONTROL7,
     CONTROL8                               => CONTROL8,
     CONTROL9                               => CONTROL9,
     CONTROL10                              => CONTROL10,
     CONTROL11                              => CONTROL11,
     CONTROL12                              => CONTROL12
  );

  cmp_chipscope_ila_0_adc : chipscope_ila
  port map (
    CONTROL                                => CONTROL0,
    CLK                                    => fs_clk,
    TRIG0                                  => TRIG_ILA0_0,
    TRIG1                                  => TRIG_ILA0_1,
    TRIG2                                  => TRIG_ILA0_2,
    TRIG3                                  => TRIG_ILA0_3
  );

  -- ADC Data
  TRIG_ILA0_0                               <= dsp_adc_ch1_data & dsp_adc_ch0_data;
  TRIG_ILA0_1                               <= dsp_adc_ch3_data & dsp_adc_ch2_data;

  TRIG_ILA0_2                               <= (others => '0');
  TRIG_ILA0_3                               <= (others => '0');

  -- Mix and BPF data

  --cmp_chipscope_ila_4096_bpf_mix : chipscope_ila_4096  (
  cmp_chipscope_ila_1024_bpf_mix : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL1,
    --CLK                                    => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA1_0,
    TRIG1                                   => TRIG_ILA1_1,
    TRIG2                                   => TRIG_ILA1_2,
    TRIG3                                   => TRIG_ILA1_3,
    TRIG4                                   => TRIG_ILA1_4
  );

  TRIG_ILA1_0(0)                            <= dsp_bpf_valid; -- or dsp_mix_valid
  TRIG_ILA1_0(1)                            <= '0';
  TRIG_ILA1_0(2)                            <= '0';
  TRIG_ILA1_0(3)                            <= '0';
  TRIG_ILA1_0(4)                            <= '0';
  TRIG_ILA1_0(5)                            <= '0';
  TRIG_ILA1_0(6)                            <= '0';

  TRIG_ILA1_1(dsp_bpf_ch0'left downto 0)    <= dsp_bpf_ch0;
  TRIG_ILA1_2(dsp_bpf_ch2'left downto 0)    <= dsp_bpf_ch2;
  TRIG_ILA1_3(dsp_mix_ch0'left downto 0)    <= dsp_mix_ch0;
  TRIG_ILA1_4(dsp_mix_ch2'left downto 0)    <= dsp_mix_ch2;

  --TBT amplitudes data

  --cmp_chipscope_ila_4096_tbt_amp : chipscope_ila_4096  (
  cmp_chipscope_ila_1024_tbt_amp : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL2,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA2_0,
    TRIG1                                   => TRIG_ILA2_1,
    TRIG2                                   => TRIG_ILA2_2,
    TRIG3                                   => TRIG_ILA2_3,
    TRIG4                                   => TRIG_ILA2_4
  );

  TRIG_ILA2_0(0)                            <= dsp_tbt_amp_ch0_valid;
  TRIG_ILA2_0(1)                            <= '0';
  TRIG_ILA2_0(2)                            <= '0';
  TRIG_ILA2_0(3)                            <= '0';
  TRIG_ILA2_0(4)                            <= '0';
  TRIG_ILA2_0(5)                            <= '0';
  TRIG_ILA2_0(6)                            <= '0';

  TRIG_ILA2_1(dsp_tbt_amp_ch0'left downto 0) <= dsp_tbt_amp_ch0;
  TRIG_ILA2_2(dsp_tbt_amp_ch1'left downto 0) <= dsp_tbt_amp_ch1;
  TRIG_ILA2_3(dsp_tbt_amp_ch2'left downto 0) <= dsp_tbt_amp_ch2;
  TRIG_ILA2_4(dsp_tbt_amp_ch3'left downto 0) <= dsp_tbt_amp_ch3;

  -- TBT position data

  --cmp_chipscope_ila_4096_tbt_pos : chipscope_ila_4096
  cmp_chipscope_ila_1024_tbt_pos : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL3,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA3_0,
    TRIG1                                   => TRIG_ILA3_1,
    TRIG2                                   => TRIG_ILA3_2,
    TRIG3                                   => TRIG_ILA3_3,
    TRIG4                                   => TRIG_ILA3_4
  );

  TRIG_ILA3_0(0)                            <= dsp_x_tbt_valid;
  TRIG_ILA3_0(1)                            <= '0';
  TRIG_ILA3_0(2)                            <= '0';
  TRIG_ILA3_0(3)                            <= '0';
  TRIG_ILA3_0(4)                            <= '0';
  TRIG_ILA3_0(5)                            <= '0';
  TRIG_ILA3_0(6)                            <= '0';

  TRIG_ILA3_1(dsp_x_tbt'left downto 0)       <= dsp_x_tbt;
  TRIG_ILA3_2(dsp_y_tbt'left downto 0)       <= dsp_y_tbt;
  TRIG_ILA3_3(dsp_q_tbt'left downto 0)       <= dsp_q_tbt;
  TRIG_ILA3_4(dsp_sum_tbt'left downto 0)     <= dsp_sum_tbt;

  -- FOFB amplitudes data

  --cmp_chipscope_ila_4096_fofb_amp : chipscope_ila_4096
  cmp_chipscope_ila_1024_fofb_amp : chipscope_ila_1024 -- TESTING SYNTHESIS TIME!
  --cmp_chipscope_ila_65536_fofb_amp : chipscope_ila_65536
  port map (
    CONTROL                                 => CONTROL4,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA4_0,
    TRIG1                                   => TRIG_ILA4_1,
    TRIG2                                   => TRIG_ILA4_2,
    TRIG3                                   => TRIG_ILA4_3,
    TRIG4                                   => TRIG_ILA4_4
  );

  TRIG_ILA4_0(0)                            <= dsp_fofb_amp_ch0_valid;
  TRIG_ILA4_0(1)                            <= '0';
  TRIG_ILA4_0(2)                            <= '0';
  TRIG_ILA4_0(3)                            <= '0';
  TRIG_ILA4_0(4)                            <= '0';
  TRIG_ILA4_0(5)                            <= '0';
  TRIG_ILA4_0(6)                            <= '0';

  TRIG_ILA4_1(dsp_fofb_amp_ch0'left downto 0)  <= dsp_fofb_amp_ch0;
  TRIG_ILA4_2(dsp_fofb_amp_ch1'left downto 0)  <= dsp_fofb_amp_ch1;
  TRIG_ILA4_3(dsp_fofb_amp_ch2'left downto 0)  <= dsp_fofb_amp_ch2;
  TRIG_ILA4_4(dsp_fofb_amp_ch3'left downto 0)  <= dsp_fofb_amp_ch3;

  -- FOFB position data

  --cmp_chipscope_ila_4096_fofb_pos : chipscope_ila_4096
  --cmp_chipscope_ila_131072_fofb_pos : chipscope_ila_131072
  --cmp_chipscope_ila_65536_fofb_pos : chipscope_ila_65536
  cmp_chipscope_ila_1024_fofb_pos : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL5,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA5_0,
    TRIG1                                   => TRIG_ILA5_1,
    TRIG2                                   => TRIG_ILA5_2,
    TRIG3                                   => TRIG_ILA5_3,
    TRIG4                                   => TRIG_ILA5_4
  );

  TRIG_ILA5_0(0)                            <= dsp_x_fofb_valid;
  TRIG_ILA5_0(1)                            <= '0';
  TRIG_ILA5_0(2)                            <= '0';
  TRIG_ILA5_0(3)                            <= '0';
  TRIG_ILA5_0(4)                            <= '0';
  TRIG_ILA5_0(5)                            <= '0';
  TRIG_ILA5_0(6)                            <= '0';

  TRIG_ILA5_1(dsp_x_fofb'left downto 0)        <= dsp_x_fofb;
  TRIG_ILA5_2(dsp_y_fofb'left downto 0)        <= dsp_y_fofb;
  TRIG_ILA5_3(dsp_q_fofb'left downto 0)        <= dsp_q_fofb;
  TRIG_ILA5_4(dsp_sum_fofb'left downto 0)      <= dsp_sum_fofb;

  -- Monitoring position amplitude

  --chipscope_ila_4096 cmp_chipscope_ila_4096_monit_amp_i
  cmp_chipscope_ila_1024_monit_amp : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL6,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA6_0,
    TRIG1                                   => TRIG_ILA6_1,
    TRIG2                                   => TRIG_ILA6_2,
    TRIG3                                   => TRIG_ILA6_3,
    TRIG4                                   => TRIG_ILA6_4
  );

  TRIG_ILA6_0(0)                            <= dsp_monit_amp_ch0_valid;
  TRIG_ILA6_0(1)                            <= '0';
  TRIG_ILA6_0(2)                            <= '0';
  TRIG_ILA6_0(3)                            <= '0';
  TRIG_ILA6_0(4)                            <= '0';
  TRIG_ILA6_0(5)                            <= '0';
  TRIG_ILA6_0(6)                            <= '0';

  TRIG_ILA6_1(dsp_monit_amp_ch0'left downto 0)  <= dsp_monit_amp_ch0;
  TRIG_ILA6_2(dsp_monit_amp_ch1'left downto 0)  <= dsp_monit_amp_ch1;
  TRIG_ILA6_3(dsp_monit_amp_ch2'left downto 0)  <= dsp_monit_amp_ch2;
  TRIG_ILA6_4(dsp_monit_amp_ch3'left downto 0)  <= dsp_monit_amp_ch3;

  -- Monitoring position data

  -- cmp_chipscope_ila_4096_monit_pos : chipscope_ila_4096
  cmp_chipscope_ila_1024_monit_pos : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL7,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA7_0,
    TRIG1                                   => TRIG_ILA7_1,
    TRIG2                                   => TRIG_ILA7_2,
    TRIG3                                   => TRIG_ILA7_3,
    TRIG4                                   => TRIG_ILA7_4
  );

  TRIG_ILA7_0(0)                            <= dsp_x_monit_valid;
  TRIG_ILA7_0(1)                            <= '0';
  TRIG_ILA7_0(2)                            <= '0';
  TRIG_ILA7_0(3)                            <= '0';
  TRIG_ILA7_0(4)                            <= '0';
  TRIG_ILA7_0(5)                            <= '0';
  TRIG_ILA7_0(6)                            <= '0';

  TRIG_ILA7_1(dsp_x_monit'left downto 0)      <= dsp_x_monit;
  TRIG_ILA7_2(dsp_y_monit'left downto 0)      <= dsp_y_monit;
  TRIG_ILA7_3(dsp_q_monit'left downto 0)      <= dsp_q_monit;
  TRIG_ILA7_4(dsp_sum_monit'left downto 0)    <= dsp_sum_monit;

  -- Monitoring 1 position data

  --cmp_chipscope_ila_32768_monit_pos_1 : chipscope_ila_32768
  cmp_chipscope_ila_1024_monit_pos_1 : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL8,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA8_0,
    TRIG1                                   => TRIG_ILA8_1,
    TRIG2                                   => TRIG_ILA8_2,
    TRIG3                                   => TRIG_ILA8_3,
    TRIG4                                   => TRIG_ILA8_4
  );

  TRIG_ILA8_0(0)                            <= dsp_x_monit_1_valid;
  TRIG_ILA8_0(1)                            <= '0';
  TRIG_ILA8_0(2)                            <= '0';
  TRIG_ILA8_0(3)                            <= '0';
  TRIG_ILA8_0(4)                            <= '0';
  TRIG_ILA8_0(5)                            <= '0';
  TRIG_ILA8_0(6)                            <= '0';

  TRIG_ILA8_1(dsp_x_monit_1'left downto 0)     <= dsp_x_monit_1;
  TRIG_ILA8_2(dsp_y_monit_1'left downto 0)     <= dsp_y_monit_1;
  TRIG_ILA8_3(dsp_q_monit_1'left downto 0)     <= dsp_q_monit_1;
  TRIG_ILA8_4(dsp_sum_monit_1'left downto 0)   <= dsp_sum_monit_1;

  -- TBT Phase data

  --cmp_chipscope_ila_4096_tbt_pha : chipscope_ila_4096
  cmp_chipscope_ila_1024_tbt_pha : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL9,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA9_0,
    TRIG1                                   => TRIG_ILA9_1,
    TRIG2                                   => TRIG_ILA9_2,
    TRIG3                                   => TRIG_ILA9_3,
    TRIG4                                   => TRIG_ILA9_4
  );

  TRIG_ILA9_0(0)                            <= dsp_tbt_pha_ch0_valid;
  TRIG_ILA9_0(1)                            <= '0';
  TRIG_ILA9_0(2)                            <= '0';
  TRIG_ILA9_0(3)                            <= '0';
  TRIG_ILA9_0(4)                            <= '0';
  TRIG_ILA9_0(5)                            <= '0';
  TRIG_ILA9_0(6)                            <= '0';

  TRIG_ILA9_1(dsp_tbt_pha_ch0'left downto 0)      <= dsp_tbt_pha_ch0;
  TRIG_ILA9_2(dsp_tbt_pha_ch1'left downto 0)      <= dsp_tbt_pha_ch1;
  TRIG_ILA9_3(dsp_tbt_pha_ch2'left downto 0)      <= dsp_tbt_pha_ch2;
  TRIG_ILA9_4(dsp_tbt_pha_ch3'left downto 0)      <= dsp_tbt_pha_ch3;

  -- FOFB Phase data

  --cmp_chipscope_ila_4096_fofb_pha : chipscope_ila_4096
  cmp_chipscope_ila_1024_fofb_pha : chipscope_ila_1024
  port map (
    CONTROL                                 => CONTROL10,
    --CLK                                     => fs_clk2x,
    CLK                                     => fs_clk,
    TRIG0                                   => TRIG_ILA10_0,
    TRIG1                                   => TRIG_ILA10_1,
    TRIG2                                   => TRIG_ILA10_2,
    TRIG3                                   => TRIG_ILA10_3,
    TRIG4                                   => TRIG_ILA10_4
  );

  TRIG_ILA10_0(0)                           <= dsp_fofb_pha_ch0_valid;
  TRIG_ILA10_0(1)                           <= '0';
  TRIG_ILA10_0(2)                           <= '0';
  TRIG_ILA10_0(3)                           <= '0';
  TRIG_ILA10_0(4)                           <= '0';
  TRIG_ILA10_0(5)                           <= '0';
  TRIG_ILA10_0(6)                           <= '0';

  TRIG_ILA10_1(dsp_fofb_pha_ch0'left downto 0)    <= dsp_fofb_pha_ch0;
  TRIG_ILA10_2(dsp_fofb_pha_ch1'left downto 0)    <= dsp_fofb_pha_ch1;
  TRIG_ILA10_3(dsp_fofb_pha_ch2'left downto 0)    <= dsp_fofb_pha_ch2;
  TRIG_ILA10_4(dsp_fofb_pha_ch3'left downto 0)    <= dsp_fofb_pha_ch3;

  -- Controllable gain for test data
  cmp_chipscope_vio_256 : chipscope_vio_256
  port map (
    CONTROL                                 => CONTROL11,
    ASYNC_OUT                               => vio_out
  );

  dds_sine_gain_ch0                         <= vio_out(10-1 downto 0);
  dds_sine_gain_ch1                         <= vio_out(20-1 downto 10);
  dds_sine_gain_ch2                         <= vio_out(30-1 downto 20);
  dds_sine_gain_ch3                         <= vio_out(40-1 downto 30);
  adc_synth_data_en                         <= vio_out(40);

  un_cross_gain_aa                          <= vio_out(65 downto 50);
  un_cross_gain_bb                          <= vio_out(81 downto 66);
  un_cross_gain_cc                          <= vio_out(97 downto 82);
  un_cross_gain_dd                          <= vio_out(113 downto 98);
  un_cross_gain_ac                          <= vio_out(129 downto 114);
  un_cross_gain_bd                          <= vio_out(145 downto 130);
  un_cross_gain_ca                          <= vio_out(161 downto 146);
  un_cross_gain_db                          <= vio_out(177 downto 162);

  un_cross_delay_1                          <= vio_out(193 downto 178);
  un_cross_delay_2                          <= vio_out(209 downto 194);

  un_cross_mode_1                           <= vio_out(211 downto 210);
  un_cross_mode_2                           <= vio_out(213 downto 212);

  un_cross_div_f                            <= vio_out(229 downto 214);

  dsp_del_sig_div_thres_sel                 <= vio_out(231 downto 230);
  dsp_kx_sel                                <= vio_out(233 downto 232);
  dsp_ky_sel                                <= vio_out(235 downto 234);
  dsp_ksum_sel                              <= vio_out(237 downto 236);

  -- Controllable DDS frequency and phase
  cmp_chipscope_vio_256_dsp_config : chipscope_vio_256
  port map (
    CONTROL                                 => CONTROL12,
    ASYNC_OUT                               => vio_out_dsp_config
  );

  dsp_dds_pinc_ch0                          <= vio_out_dsp_config(29 downto 0);
  dsp_dds_pinc_ch1                          <= vio_out_dsp_config(59 downto 30);
  dsp_dds_pinc_ch2                          <= vio_out_dsp_config(89 downto 60);
  dsp_dds_pinc_ch3                          <= vio_out_dsp_config(119 downto 90);
  dsp_dds_poff_ch0                          <= vio_out_dsp_config(149 downto 120);
  dsp_dds_poff_ch1                          <= vio_out_dsp_config(179 downto 150);
  dsp_dds_poff_ch2                          <= vio_out_dsp_config(209 downto 180);
  dsp_dds_poff_ch3                          <= vio_out_dsp_config(239 downto 210);

  dsp_dds_config_valid_ch0                  <= vio_out_dsp_config(240);
  dsp_dds_config_valid_ch1                  <= vio_out_dsp_config(241);
  dsp_dds_config_valid_ch2                  <= vio_out_dsp_config(242);
  dsp_dds_config_valid_ch3                  <= vio_out_dsp_config(243);

-- edge detect for dds config.... not actually needed as
-- long as we deassert valid not too much after
end rtl;
