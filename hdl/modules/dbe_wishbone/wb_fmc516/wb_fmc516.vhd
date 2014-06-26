------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-29-10
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
use work.dbe_wishbone_pkg.all;
-- Wishbone Stream Interface
--use work.wb_stream_pkg.all;
use work.wb_stream_generic_pkg.all;
-- Wishbone Register Interface
use work.fmc516_wbgen2_pkg.all;
-- FMC ADC package
use work.fmc_adc_pkg.all;
-- Reset Synch
use work.dbe_common_pkg.all;
-- General common cores
use work.gencores_pkg.all;

-- For Xilinx primitives
library unisim;
use unisim.vcomponents.all;

--package wb_stream_64_pkg is new wb_stream_generic_pkg
--   generic map (type => std_logic_vector(63 downto 0));

entity wb_fmc516 is
generic
(
    -- The only supported values are VIRTEX6 and 7SERIES
  g_fpga_device                             : string := "VIRTEX6";
  g_delay_type                              : string := "VARIABLE";
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_adc_clk_period_values                   : t_clk_values_array := default_adc_clk_period_values;
  g_use_clk_chains                          : t_clk_use_chain := default_clk_use_chain;
  g_use_data_chains                         : t_data_use_chain := default_data_use_chain;
  g_map_clk_data_chains                     : t_map_clk_data_chain := default_map_clk_data_chain;
  g_ref_clk                                 : t_ref_adc_clk := default_ref_adc_clk;
  g_packet_size                             : natural := 32;
  g_with_idelayctrl                         : boolean := true;
  g_sim                                     : integer := 0
);
port
(
  sys_clk_i                                 : in std_logic;
  sys_rst_n_i                               : in std_logic;
  sys_clk_200Mhz_i                          : in std_logic;

  -----------------------------
  -- Wishbone Control Interface signals
  -----------------------------

  wb_adr_i                                  : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
  wb_dat_i                                  : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
  wb_dat_o                                  : out std_logic_vector(c_wishbone_data_width-1 downto 0);
  wb_sel_i                                  : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
  wb_we_i                                   : in  std_logic := '0';
  wb_cyc_i                                  : in  std_logic := '0';
  wb_stb_i                                  : in  std_logic := '0';
  wb_ack_o                                  : out std_logic;
  wb_err_o                                  : out std_logic;
  wb_rty_o                                  : out std_logic;
  wb_stall_o                                : out std_logic;

  -----------------------------
  -- External ports
  -----------------------------
  -- System I2C Bus. Slaves: Atmel AT24C512B Serial EEPROM,
  -- AD7417 temperature diodes and AD7417 supply rails
  sys_i2c_scl_b                             : inout std_logic;
  sys_i2c_sda_b                             : inout std_logic;

  -- ADC clocks. One clock per ADC channel.
  -- Only ch1 clock is used as all data chains
  -- are sampled at the same frequency
  adc_clk0_p_i                              : in std_logic := '0';
  adc_clk0_n_i                              : in std_logic := '0';
  adc_clk1_p_i                              : in std_logic := '0';
  adc_clk1_n_i                              : in std_logic := '0';
  adc_clk2_p_i                              : in std_logic := '0';
  adc_clk2_n_i                              : in std_logic := '0';
  adc_clk3_p_i                              : in std_logic := '0';
  adc_clk3_n_i                              : in std_logic := '0';

  -- DDR ADC data channels.
  adc_data_ch0_p_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  adc_data_ch0_n_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  adc_data_ch1_p_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  adc_data_ch1_n_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  adc_data_ch2_p_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  adc_data_ch2_n_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  adc_data_ch3_p_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');
  adc_data_ch3_n_i                          : in std_logic_vector(c_num_adc_bits/2-1 downto 0) := (others => '0');

  -- ADC clock (half of the sampling frequency) divider reset
  adc_clk_div_rst_p_o                       : out std_logic;
  adc_clk_div_rst_n_o                       : out std_logic;

  -- FMC Front leds. Typical uses: Over Range or Full Scale
  -- condition.
  fmc_leds_o                                : out std_logic_vector(1 downto 0);

  -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
  sys_spi_clk_o                             : out std_logic;
  sys_spi_data_b                            : inout std_logic;
  --sys_spi_dout_o                            : out std_logic;
  --sys_spi_din_i                             : in std_logic;
  sys_spi_cs_adc0_n_o                       : out std_logic;  -- SPI ADC CS channel 0
  sys_spi_cs_adc1_n_o                       : out std_logic;  -- SPI ADC CS channel 1
  sys_spi_cs_adc2_n_o                       : out std_logic;  -- SPI ADC CS channel 2
  sys_spi_cs_adc3_n_o                       : out std_logic;  -- SPI ADC CS channel 3
  --sys_spi_miosio_oe_n_o                     : out std_logic;

  -- External Trigger To/From FMC
  m2c_trig_p_i                              : in std_logic := '0';
  m2c_trig_n_i                              : in std_logic := '0';
  c2m_trig_p_o                              : out std_logic;
  c2m_trig_n_o                              : out std_logic;

  -- LMK (National Semiconductor) is the clock and distribution IC,
  -- programmable via Microwire Interface
  lmk_lock_i                                : in std_logic := '0';
  lmk_sync_o                                : out std_logic;
  lmk_uwire_latch_en_o                      : out std_logic;
  lmk_uwire_data_o                          : out std_logic;
  lmk_uwire_clock_o                         : out std_logic;

  -- Programable VCXO via I2C
  vcxo_i2c_sda_b                            : inout std_logic;
  vcxo_i2c_scl_b                            : inout std_logic;
  vcxo_pd_l_o                               : out std_logic;

  -- One-wire To/From DS2431 (VMETRO Data)
  fmc_id_dq_b                               : inout std_logic;
  -- One-wire To/From DS2432 SHA-1 (SP-Devices key)
  fmc_key_dq_b                              : inout std_logic;

  -- General board pins
  fmc_pwr_good_i                            : in std_logic;
  -- Internal/External clock distribution selection
  fmc_clk_sel_o                             : out std_logic;
  -- Reset ADCs
  fmc_reset_adcs_n_o                        : out std_logic;
  --FMC Present status
  fmc_prsnt_m2c_l_i                         : in  std_logic := '0';

  -----------------------------
  -- Optional external reference clock ports
  -----------------------------
  fmc_ext_ref_clk_i                        : in std_logic := '0';
  fmc_ext_ref_clk2x_i                      : in std_logic := '0';
  fmc_ext_ref_mmcm_locked_i                : in std_logic := '0';

  -----------------------------
  -- ADC output signals. Continuous flow
  -----------------------------
  adc_clk_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
  adc_clk2x_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
  adc_rst_n_o                               : out std_logic_vector(c_num_adc_channels-1 downto 0);
  adc_data_o                                : out std_logic_vector(c_num_adc_channels*c_num_adc_bits-1 downto 0);
  adc_data_valid_o                          : out std_logic_vector(c_num_adc_channels-1 downto 0);

  -----------------------------
  -- General ADC output signals and status
  -----------------------------
  -- Trigger to other FPGA logic
  trig_hw_o                                 : out std_logic;
  trig_hw_i                                 : in std_logic := '0';

  -- General board status
  fmc_mmcm_lock_o                           : out std_logic;
  fmc_lmk_lock_o                            : out std_logic;

  -----------------------------
  -- Wishbone Streaming Interface Source
  -----------------------------
  wbs_adr_o                                : out std_logic_vector(c_num_adc_channels*c_wbs_adr4_width-1 downto 0);
  wbs_dat_o                                : out std_logic_vector(c_num_adc_channels*c_wbs_dat16_width-1 downto 0);
  wbs_cyc_o                                : out std_logic_vector(c_num_adc_channels-1 downto 0);
  wbs_stb_o                                : out std_logic_vector(c_num_adc_channels-1 downto 0);
  wbs_we_o                                 : out std_logic_vector(c_num_adc_channels-1 downto 0);
  wbs_sel_o                                : out std_logic_vector(c_num_adc_channels*c_wbs_sel16_width-1 downto 0);
  wbs_ack_i                                : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
  wbs_stall_i                              : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
  wbs_err_i                                : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');
  wbs_rty_i                                : in std_logic_vector(c_num_adc_channels-1 downto 0) := (others => '0');

  adc_dly_debug_o                          : out t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

  fifo_debug_valid_o                       : out std_logic_vector(c_num_adc_channels-1 downto 0);
  fifo_debug_full_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0);
  fifo_debug_empty_o                       : out std_logic_vector(c_num_adc_channels-1 downto 0)
);
end wb_fmc516;

architecture rtl of wb_fmc516 is

  -- Slightly different behaviour than the one located at wishbone_pkg.vhd.
  -- The original f_ceil_log2 returns 0 for x <= 1. We cannot allow this,
  -- as we must have at least one bit size, for x > 0
  function f_ceil_log2(x : natural) return natural is
  begin
    if x <= 2
    then return 1;
    else return f_ceil_log2((x+1)/2) +1;
    end if;
  end f_ceil_log2;

  -----------------------------
  -- General Contants
  -----------------------------
  -- Number packet size counter bits
  constant c_packet_num_bits                : natural := f_packet_num_bits(g_packet_size);
  -- Numbert of bits in Wishbone register interface. Plus 2 to account for BYTE addressing
  constant c_periph_addr_size               : natural := 5+2;
  constant c_first_used_clk                 : natural := f_first_used_clk(g_use_clk_chains);
  constant c_ref_clk                        : natural := f_adc_ref_clk(g_ref_clk);
  constant c_with_clk_single_ended          : boolean := false;
  constant c_with_data_single_ended         : boolean := false;
  constant c_with_data_sdr                  : boolean := false;
  constant c_with_fn_dly_select             : boolean := false;
  constant c_with_idelay_var_loadable       : boolean := true;
  constant c_with_idelay_variable           : boolean := true;

  -----------------------------
  -- Wishbone fanout component (xwb_bus_fanout) constants
  -----------------------------
  -- Number of internal wishbone slaves
  --constant c_num_int_slaves                 : natural := 7;
  --constant c_num_int_slaves_log2            : natural := f_ceil_log2(c_num_int_slaves);
  ---- Number of each addressing bits for each internal slave (word addressed)
  --constant c_num_bits_per_slave             : natural := 6;
  ---- Number of bits of the address space of this peripheral
  --constant c_periph_addr_size               : natural :=
  --          c_num_bits_per_slave+c_num_int_slaves_log2;

  -----------------------------
  -- Crossbar component constants
  -----------------------------
    -- Internal crossbar layout
  -- 0 -> FMC516 Register Wishbone Interface
  -- 1 -> System I2C Bus. Slaves: Atmel AT24C512B Serial EEPROM, AD7417
  --        temperature diodes and AD7417 supply rails
  -- 2 -> ADC SPI control interface. Three-wire mode. Tri-stated data pin
  -- 3 -> Microwire (SPI dialect) for LMK (National Semiconductor) clock and
  --        distribution IC.
  -- 4 -> VCXO I2C Bus.
  -- 5 -> One-wire To/From DS2431 (VMETRO Data)
  -- 6 -> One-wire To/From DS2432 SHA-1 (SP-Devices key)
  -- Number of slaves
  constant c_slaves                         : natural := 7;
  -- Number of masters
  constant c_masters                        : natural := 1;            -- Top master.

  -- WB SDB (Self describing bus) layout
  constant c_layout : t_sdb_record_array(c_slaves-1 downto 0) :=
  ( 0 => f_sdb_embed_device(c_xwb_fmc516_regs_sdb,      x"00000000"),   -- Register interface
    1 => f_sdb_embed_device(c_xwb_i2c_master_sdb,       x"00000100"),   -- SYS I2C
    2 => f_sdb_embed_device(c_xwb_spi_sdb,              x"00000200"),   -- ADC SPI
    3 => f_sdb_embed_device(c_xwb_spi_sdb,              x"00000300"),   -- LMK SPI
    4 => f_sdb_embed_device(c_xwb_i2c_master_sdb,       x"00000400"),   -- VCXO Si571 I2C
    5 => f_sdb_embed_device(c_xwb_onewire_master_sdb,    x"00000500"),   -- One-wire DS2431
    6 => f_sdb_embed_device(c_xwb_onewire_master_sdb,    x"00000600")    -- One-wire DS2432
  );

  -- Self Describing Bus ROM Address. It will be an addressed slave as well.
  constant c_sdb_address                    : t_wishbone_address := x"00000800";

  -----------------------------
  -- Clock and reset signals
  -----------------------------
  signal sys_rst_n                          : std_logic;
  signal sys_rst_sync_n                     : std_logic;
  --signal adc_clk_chain_rst                  : std_logic;

  -----------------------------
  -- Wishbone Register Interface signals
  -----------------------------
  -- FMC516 reg structure
  signal regs_out                           : t_fmc516_out_registers;
  signal regs_in                            : t_fmc516_in_registers;

  -----------------------------
  -- ADC Interface signals
  -----------------------------
  --signal fs_clk                             : std_logic;
  signal fs_rst_n                           : std_logic;
  signal fs_rst_sync_n                      : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal mmcm_adc_locked                    : std_logic;

  -- ADC clock + data single ended inputs
  signal adc_in                             : t_adc_in_array(c_num_adc_channels-1 downto 0);
  signal adc_in_sdr_dummy                   : t_adc_sdr_in_array(c_num_adc_channels-1 downto 0) :=
                                                (0 => ('0', '0', (others => '0')),
                                                 1 => ('0', '0', (others => '0')),
                                                 2 => ('0', '0', (others => '0')),
                                                 3 => ('0', '0', (others => '0'))
                                                 );

  signal adc_clk0                           : std_logic;
  signal adc_clk1                           : std_logic;
  signal adc_clk2                           : std_logic;
  signal adc_clk3                           : std_logic;

  signal adc_data_ch0                       : std_logic_vector(f_num_adc_pins(c_with_data_sdr)-1 downto 0);
  signal adc_data_ch1                       : std_logic_vector(f_num_adc_pins(c_with_data_sdr)-1 downto 0);
  signal adc_data_ch2                       : std_logic_vector(f_num_adc_pins(c_with_data_sdr)-1 downto 0);
  signal adc_data_ch3                       : std_logic_vector(f_num_adc_pins(c_with_data_sdr)-1 downto 0);

  -- ADC fine delay signals.
  signal adc_fn_dly_in                      : t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);
  --signal adc_fn_dly_in_int                  : t_adc_fn_dly_int_array(c_num_adc_channels-1 downto 0);
  signal adc_fn_dly_wb_ctl_out              : t_adc_fn_dly_wb_ctl_array(c_num_adc_channels-1 downto 0);
  signal adc_fn_dly_out                     : t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);
  -- ADC coarse delay signals.
  signal adc_cs_dly_in                      : t_adc_cs_dly_array(c_num_adc_channels-1 downto 0);
  signal adc_cs_dly_in_int                  : t_adc_cs_dly_array(c_num_adc_channels-1 downto 0);
  -- ADC output signals.
  signal adc_out                            : t_adc_out_array(c_num_adc_channels-1 downto 0);

  -- ADC Clock/Data variable delay interface internal structure
  --signal adc_dly_pulse_clk_int              : std_logic_vector(c_num_adc_channels-1 downto 0);
  --signal adc_dly_pulse_data_int             : std_logic_vector(c_num_adc_channels-1 downto 0);

  -- Signals for adc internal use
  --signal adc_clk_int                        : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal fs_clk                             : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal fs_clk2x                           : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal adc_valid                          : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal adc_data                           : std_logic_vector(c_num_adc_bits*c_num_adc_channels-1 downto 0);

  -- Optional reference clock
  signal adc_ext_glob_clk_int               : t_adc_clk_chain_glob;

  -- ADC Reset signals
  signal adc_clk_div_rst_int                : std_logic;
  signal adc_clk_div_rst_int_p              : std_logic;
  signal fmc_reset_adcs_int                 : std_logic;

  -----------------------------
  -- Test data signals and constants
  -----------------------------
  -- Counter width. It willl count up to 2^32 clock cycles
  constant c_counter_width                  : natural := 16;
  -- 100MHz period or 1 second
  constant c_counter_full                   : natural := 1000000;
  -- Offset between adjacent test data channels
  constant c_offset_test_data               : natural := 10;
  -- Counter signal
  type t_wbs_test_data_array is array(natural range<>) of unsigned(c_counter_width-1 downto 0);

  signal wbs_test_data                      : t_wbs_test_data_array(c_num_adc_channels-1 downto 0);

  -----------------------------
  -- Wishbone Streaming control signals
  -----------------------------
  type t_wbs_dat16_array is array(natural range<>) of std_logic_vector(c_wbs_dat16_width-1 downto 0);
  type t_wbs_valid16_array is array(natural range<>) of std_logic;

  signal wbs_dat                            : t_wbs_dat16_array(c_num_adc_channels-1 downto 0);
  signal wbs_valid                          : t_wbs_valid16_array(c_num_adc_channels-1 downto 0);
  signal wbs_adr                            : std_logic_vector(c_wbs_adr4_width-1 downto 0);
  --signal wbs_dat                            : std_logic_vector(c_wbs_dat16_width-1 downto 0);
  --signal wbs_dvalid                         : std_logic;
  signal wbs_sof                            : std_logic;
  signal wbs_eof                            : std_logic;
  signal wbs_error                          : std_logic;
  signal wbs_sel                            : std_logic_vector(c_wbs_sel16_width-1 downto 0);

  -- Wishbone Streaming interface structure
  signal wbs_stream_out                     : t_wbs_source_out16_array(c_num_adc_channels-1 downto 0);
  signal wbs_stream_in                      : t_wbs_source_in16_array(c_num_adc_channels-1 downto 0);

  -----------------------------
  -- Wishbone slave adapter signals/structures
  -----------------------------
  signal wb_slv_adp_out                     : t_wishbone_master_out;
  signal wb_slv_adp_in                      : t_wishbone_master_in;
  signal resized_addr                       : std_logic_vector(c_wishbone_address_width-1 downto 0);

  -----------------------------
  -- Wishbone fanout signals
  -----------------------------
  --signal wb_out                           : t_wishbone_master_in_array(0 to c_num_int_slaves-1);
  --signal wb_in                            : t_wishbone_master_out_array(0 to c_num_int_slaves-1);
  -- Crossbar master/slave arrays
  signal cbar_slave_in                      : t_wishbone_slave_in_array (c_masters-1 downto 0);
  signal cbar_slave_out                     : t_wishbone_slave_out_array(c_masters-1 downto 0);
  signal cbar_master_in                     : t_wishbone_master_in_array(c_slaves-1 downto 0);
  signal cbar_master_out                    : t_wishbone_master_out_array(c_slaves-1 downto 0);

  -----------------------------
  -- System I2C signals
  -----------------------------
  signal sys_i2c_scl_in                     : std_logic;
  signal sys_i2c_scl_out                    : std_logic;
  signal sys_i2c_scl_oe_n                   : std_logic;
  signal sys_i2c_sda_in                     : std_logic;
  signal sys_i2c_sda_out                    : std_logic;
  signal sys_i2c_sda_oe_n                   : std_logic;

  -----------------------------
  -- System SPI signals
  -----------------------------
  signal sys_spi_din                        : std_logic;
  signal sys_spi_dout                       : std_logic;
  signal sys_spi_ss_int                     : std_logic_vector(7 downto 0);
  signal sys_spi_clk                        : std_logic;
  signal sys_spi_miosio_oe_n                : std_logic;

  -----------------------------
  -- LMK SPI (microwire) signals
  -----------------------------
  signal fmc_lmk_uwire_ss_int               : std_logic_vector(7 downto 0);
  signal fmc_lmk_uwire_clk                  : std_logic;

  -----------------------------
  -- VCXO I2C signals
  -----------------------------
  signal vcxo_i2c_scl_in                    : std_logic;
  signal vcxo_i2c_scl_out                   : std_logic;
  signal vcxo_i2c_scl_oe_n                  : std_logic;
  signal vcxo_i2c_sda_in                    : std_logic;
  signal vcxo_i2c_sda_out                   : std_logic;
  signal vcxo_i2c_sda_oe_n                  : std_logic;

  -----------------------------
  -- One Wire DS2431 (VMETRO Data) signals
  -----------------------------
  signal owr_id_pwren                       : std_logic_vector(0 downto 0);
  signal owr_id_en                          : std_logic_vector(0 downto 0);
  signal owr_id_i                           : std_logic_vector(0 downto 0);

  -----------------------------
  -- One Wire DS2432 SHA-1 (SP-Devices key) signals
  -----------------------------
  signal owr_key_pwren                      : std_logic_vector(0 downto 0);
  signal owr_key_en                         : std_logic_vector(0 downto 0);
  signal owr_key_i                          : std_logic_vector(0 downto 0);

  -----------------------------
  -- Trigger signals
  -----------------------------
  signal m2c_trig                           : std_logic;
  signal m2c_trig_sync                      : std_logic;
  signal c2m_trig                           : std_logic;

  -----------------------------
  -- Led signals
  -----------------------------
  signal led0_extd_p                        : std_logic;
  signal led1_extd_p                        : std_logic;

  -----------------------------
  -- Dummy signals
  -----------------------------
  signal dummy_bit_low                      : std_logic := '0';
  signal dummy_adc_vector_low               : std_logic_vector(f_num_adc_pins(c_with_data_sdr)-1 downto 0) :=
                                                 (others => '0');

  -----------------------------
  -- Components
  -----------------------------

  component wb_fmc516_regs
  port (
    rst_n_i                                  : in     std_logic;
    clk_sys_i                                : in     std_logic;
    wb_adr_i                                 : in     std_logic_vector(4 downto 0);
    wb_dat_i                                 : in     std_logic_vector(31 downto 0);
    wb_dat_o                                 : out    std_logic_vector(31 downto 0);
    wb_cyc_i                                 : in     std_logic;
    wb_sel_i                                 : in     std_logic_vector(3 downto 0);
    wb_stb_i                                 : in     std_logic;
    wb_we_i                                  : in     std_logic;
    wb_ack_o                                 : out    std_logic;
    wb_stall_o                               : out    std_logic;
    fs_clk_i                                 : in     std_logic;
    regs_i                                   : in     t_fmc516_in_registers;
    regs_o                                   : out    t_fmc516_out_registers
  );
  end component;

begin
  -- Reset signals and sychronization with positive edge of
  -- respective clock
  --sys_rst_n <= sys_rst_n_i and mmcm_adc_locked;
  sys_rst_n <= sys_rst_n_i;
  fs_rst_n <= sys_rst_n and mmcm_adc_locked;

  -- Reset synchronization with SYS clock domain
  -- Align the reset deassertion to the next clock edge
  cmp_reset_sys_synch : reset_synch
  port map(
    clk_i                                   => sys_clk_i,
    arst_n_i                                => sys_rst_n,
    rst_n_o                                 => sys_rst_sync_n
  );

  --sys_rst_sync_n <= sys_rst_n;

  -- Reset synchronization with FS clock domain (just clock 1
  -- is used for now). Align the reset deassertion to the next
  -- clock edge
  gen_adc_reset_synch : for i in 0 to c_num_adc_channels-1 generate
    gen_adc_reset_synch_ch : if g_use_data_chains(i) = '1' generate
      cmp_reset_fs_synch : reset_synch
      port map(
        clk_i                                       => fs_clk(i),
        arst_n_i                                    => fs_rst_n,
        --rst_n_o                                      => fs_rst_sync_n
        rst_n_o                                      => fs_rst_sync_n(i)
      );

      -- Output adc sync'ed reset to downstream FPGA logic
      adc_rst_n_o(i) <= fs_rst_sync_n(i);
      --fs_rst_sync_n(i) <= fs_rst_n;
    end generate;
  end generate;

  -----------------------------
  -- General status board pins
  -----------------------------
  -- LMK CI lock detec available through a regular core pin
  fmc_lmk_lock_o                            <= lmk_lock_i;

  -----------------------------
  -- FMC516 Address decoder for SPI/I2C/Onewire Wishbone interfaces modules
  -----------------------------
  -- We need 7 outputs, as in the same wishbone addressing range, 7
  -- other wishbone peripherals must be driven:
  --
  -- 0 -> FMC516 Register Wishbone Interface
  -- 1 -> System I2C Bus. Slaves: Atmel AT24C512B Serial EEPROM, AD7417
  --        temperature diodes and AD7417 supply rails
  -- 2 -> ADC SPI control interface. Three-wire mode. Tri-stated data pin
  -- 3 -> Microwire (SPI dialect) for LMK (National Semiconductor) clock and
  --        distribution IC.
  -- 4 -> VCXO I2C Bus.
  -- 5 -> One-wire To/From DS2431 (VMETRO Data)
  -- 6 -> One-wire To/From DS2432 SHA-1 (SP-Devices key)

  -- The Internal Wishbone B.4 crossbar
  cmp_interconnect : xwb_sdb_crossbar
  generic map(
    g_num_masters                             => c_masters,
    g_num_slaves                              => c_slaves,
    g_registered                              => true,
    g_wraparound                              => true, -- Should be true for nested buses
    g_layout                                  => c_layout,
    g_sdb_addr                                => c_sdb_address
  )
  port map(
    clk_sys_i                                 => sys_clk_i,
    rst_n_i                                   => sys_rst_sync_n,
    -- Master connections (INTERCON is a slave)
    slave_i                                   => cbar_slave_in,
    slave_o                                   => cbar_slave_out,
    -- Slave connections (INTERCON is a master)
    master_i                                  => cbar_master_in,
    master_o                                  => cbar_master_out
  );

  -- External master connection
  cbar_slave_in(0).adr                        <= wb_adr_i;
  cbar_slave_in(0).dat                        <= wb_dat_i;
  cbar_slave_in(0).sel                        <= wb_sel_i;
  cbar_slave_in(0).we                         <= wb_we_i;
  cbar_slave_in(0).cyc                        <= wb_cyc_i;
  cbar_slave_in(0).stb                        <= wb_stb_i;

  wb_dat_o                                    <= cbar_slave_out(0).dat;
  wb_ack_o                                    <= cbar_slave_out(0).ack;
  wb_err_o                                    <= cbar_slave_out(0).err;
  wb_rty_o                                    <= cbar_slave_out(0).rty;
  wb_stall_o                                  <= cbar_slave_out(0).stall;

  -----------------------------
  -- Slave adapter for Wishbone Register Interface
  -----------------------------
  cmp_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => true,
    g_master_mode                           => PIPELINED,
    g_master_granularity                    => WORD,
    g_slave_use_struct                      => false,
    g_slave_mode                            => g_interface_mode,
    g_slave_granularity                     => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_sync_n,
    master_i                                => wb_slv_adp_in,
    master_o                                => wb_slv_adp_out,
    sl_adr_i                                => resized_addr,
    sl_dat_i                                => cbar_master_out(0).dat,
    sl_sel_i                                => cbar_master_out(0).sel,
    sl_cyc_i                                => cbar_master_out(0).cyc,
    sl_stb_i                                => cbar_master_out(0).stb,
    sl_we_i                                 => cbar_master_out(0).we,
    sl_dat_o                                => cbar_master_in(0).dat,
    sl_ack_o                                => cbar_master_in(0).ack,
    sl_rty_o                                => cbar_master_in(0).rty,
    sl_err_o                                => cbar_master_in(0).err,
    sl_int_o                                => cbar_master_in(0).int,
    sl_stall_o                              => cbar_master_in(0).stall
  );

  -- By doing this zeroing we avoid the issue related to BYTE -> WORD  conversion
  -- slave addressing (possibly performed by the slave adapter component)
  -- in which a bit in the MSB of the peripheral addressing part (31 - 5 in our case)
  -- is shifted to the internal register adressing part (4 - 0 in our case).
  -- Therefore, possibly changing the these bits!
  -- See wb_fmc516_port.vhd for register bank addresses and.
  resized_addr(c_periph_addr_size-1 downto 0)
                                            <= cbar_master_out(0).adr(c_periph_addr_size-1 downto 0);
  resized_addr(c_wishbone_address_width-1 downto c_periph_addr_size)
                                            <= (others => '0');

  -----------------------------
  -- FMC516 Register Wishbone Interface. Word addressed!
  -----------------------------
  --FMC516 register interface is the slave number 0, word addressed
  cmp_wb_fmc516_port : wb_fmc516_regs
  port map(
    rst_n_i                                 => sys_rst_sync_n,
    clk_sys_i                               => sys_clk_i,
    wb_adr_i                                => wb_slv_adp_out.adr(4 downto 0),
    wb_dat_i                                => wb_slv_adp_out.dat,
    wb_dat_o                                => wb_slv_adp_in.dat,
    wb_cyc_i                                => wb_slv_adp_out.cyc,
    wb_sel_i                                => wb_slv_adp_out.sel,
    wb_stb_i                                => wb_slv_adp_out.stb,
    wb_we_i                                 => wb_slv_adp_out.we,
    wb_ack_o                                => wb_slv_adp_in.ack,
    wb_stall_o                              => wb_slv_adp_in.stall,
    fs_clk_i                                => fs_clk(c_ref_clk),
    -- Check if this clock is necessary!
    --wb_clk_i                                => sys_clk_i,
    regs_i                                  => regs_in,
    regs_o                                  => regs_out
  );

  -- Unused wishbone signals
  wb_slv_adp_in.int                         <= '0';
  wb_slv_adp_in.err                         <= '0';
  wb_slv_adp_in.rty                         <= '0';

  -- Wishbone Interface Register input assignments. There are others registers
  -- not assigned here.
  regs_in.fmc_sta_lmk_locked_i              <= lmk_lock_i;
  regs_in.fmc_sta_mmcm_locked_i             <= mmcm_adc_locked;
  regs_in.fmc_sta_pwr_good_i                <= fmc_pwr_good_i;
  regs_in.fmc_sta_prst_i                    <= fmc_prsnt_m2c_l_i;
  regs_in.fmc_sta_reserved_i                <= (others => '0');
  regs_in.adc_sta_clk_chains_i              <= g_use_clk_chains;
  regs_in.adc_sta_reserved_clk_chains_i     <= (others => '0');
  regs_in.adc_sta_data_chains_i             <= g_use_data_chains;
  regs_in.adc_sta_reserved_data_chains_i    <= (others => '0');
  regs_in.adc_sta_adc_pkt_size_i            <=
    std_logic_vector(to_unsigned(g_packet_size, regs_in.adc_sta_adc_pkt_size_i'length));
  regs_in.adc_ctl_reserved_i                <= (others => '0');
  regs_in.ch0_sta_val_i                     <= adc_out(0).adc_data;
  regs_in.ch0_sta_reserved_i                <= (others => '0');
  regs_in.ch0_fn_dly_reserved_clk_chain_dly_i
                                            <= (others => '0');
  regs_in.ch0_fn_dly_reserved_data_chain_dly_i
                                            <= (others => '0');
  regs_in.ch1_sta_val_i                     <= adc_out(1).adc_data;
  regs_in.ch1_sta_reserved_i                <= (others => '0');
  regs_in.ch1_fn_dly_reserved_clk_chain_dly_i
                                            <= (others => '0');
  regs_in.ch1_fn_dly_reserved_data_chain_dly_i
                                            <= (others => '0');
  regs_in.ch2_sta_val_i                     <= adc_out(2).adc_data;
  regs_in.ch2_sta_reserved_i                <= (others => '0');
  regs_in.ch2_fn_dly_reserved_clk_chain_dly_i
                                            <= (others => '0');
  regs_in.ch2_fn_dly_reserved_data_chain_dly_i
                                            <= (others => '0');
  regs_in.ch3_sta_val_i                     <= adc_out(3).adc_data;
  regs_in.ch3_sta_reserved_i                <= (others => '0');
  regs_in.ch3_fn_dly_reserved_clk_chain_dly_i
                                            <= (others => '0');
  regs_in.ch3_fn_dly_reserved_data_chain_dly_i
                                            <= (others => '0');

  -- ADC delay registers out
  regs_in.ch0_fn_dly_clk_chain_dly_i        <= adc_fn_dly_out(0).clk_chain.idelay.val;
  regs_in.ch0_fn_dly_data_chain_dly_i       <= adc_fn_dly_out(0).data_chain.idelay.val;
  regs_in.ch1_fn_dly_clk_chain_dly_i        <= adc_fn_dly_out(1).clk_chain.idelay.val;
  regs_in.ch1_fn_dly_data_chain_dly_i       <= adc_fn_dly_out(1).data_chain.idelay.val;
  regs_in.ch2_fn_dly_clk_chain_dly_i        <= adc_fn_dly_out(2).clk_chain.idelay.val;
  regs_in.ch2_fn_dly_data_chain_dly_i       <= adc_fn_dly_out(2).data_chain.idelay.val;
  regs_in.ch3_fn_dly_clk_chain_dly_i        <= adc_fn_dly_out(3).clk_chain.idelay.val;
  regs_in.ch3_fn_dly_data_chain_dly_i       <= adc_fn_dly_out(3).data_chain.idelay.val;

  -- ADC delay registers in
  --adc_fn_dly_in_int(0).adc_clk_load         <= regs_out.ch0_fn_dly_clk_chain_dly_load_o;
  --adc_fn_dly_in_int(0).adc_data_load        <= regs_out.ch0_fn_dly_data_chain_dly_load_o;
  --adc_fn_dly_in_int(0).adc_clk_dly          <= regs_out.ch0_fn_dly_clk_chain_dly_o;
  --adc_fn_dly_in_int(0).adc_data_dly         <= regs_out.ch0_fn_dly_data_chain_dly_o;
  --adc_fn_dly_in_int(0).adc_clk_dly_inc      <= regs_out.ch0_fn_dly_inc_clk_chain_dly_o;
  --adc_fn_dly_in_int(0).adc_data_dly_inc     <= regs_out.ch0_fn_dly_inc_data_chain_dly_o;
  --adc_fn_dly_in_int(0).adc_clk_dly_dec      <= regs_out.ch0_fn_dly_dec_clk_chain_dly_o;
  --adc_fn_dly_in_int(0).adc_data_dly_dec     <= regs_out.ch0_fn_dly_dec_data_chain_dly_o;
  --adc_fn_dly_in_int(1).adc_clk_load         <= regs_out.ch1_fn_dly_clk_chain_dly_load_o;
  --adc_fn_dly_in_int(1).adc_data_load        <= regs_out.ch1_fn_dly_data_chain_dly_load_o;
  --adc_fn_dly_in_int(1).adc_clk_dly          <= regs_out.ch1_fn_dly_clk_chain_dly_o;
  --adc_fn_dly_in_int(1).adc_data_dly         <= regs_out.ch1_fn_dly_data_chain_dly_o;
  --adc_fn_dly_in_int(1).adc_clk_dly_inc      <= regs_out.ch1_fn_dly_inc_clk_chain_dly_o;
  --adc_fn_dly_in_int(1).adc_data_dly_inc     <= regs_out.ch1_fn_dly_inc_data_chain_dly_o;
  --adc_fn_dly_in_int(1).adc_clk_dly_dec      <= regs_out.ch1_fn_dly_dec_clk_chain_dly_o;
  --adc_fn_dly_in_int(1).adc_data_dly_dec     <= regs_out.ch1_fn_dly_dec_data_chain_dly_o;
  --adc_fn_dly_in_int(2).adc_clk_load         <= regs_out.ch2_fn_dly_clk_chain_dly_load_o;
  --adc_fn_dly_in_int(2).adc_data_load        <= regs_out.ch2_fn_dly_data_chain_dly_load_o;
  --adc_fn_dly_in_int(2).adc_clk_dly          <= regs_out.ch2_fn_dly_clk_chain_dly_o;
  --adc_fn_dly_in_int(2).adc_data_dly         <= regs_out.ch2_fn_dly_data_chain_dly_o;
  --adc_fn_dly_in_int(2).adc_clk_dly_inc      <= regs_out.ch2_fn_dly_inc_clk_chain_dly_o;
  --adc_fn_dly_in_int(2).adc_data_dly_inc     <= regs_out.ch2_fn_dly_inc_data_chain_dly_o;
  --adc_fn_dly_in_int(2).adc_clk_dly_dec      <= regs_out.ch2_fn_dly_dec_clk_chain_dly_o;
  --adc_fn_dly_in_int(2).adc_data_dly_dec     <= regs_out.ch2_fn_dly_dec_data_chain_dly_o;
  --adc_fn_dly_in_int(3).adc_clk_load         <= regs_out.ch3_fn_dly_clk_chain_dly_load_o;
  --adc_fn_dly_in_int(3).adc_data_load        <= regs_out.ch3_fn_dly_data_chain_dly_load_o;
  --adc_fn_dly_in_int(3).adc_clk_dly          <= regs_out.ch3_fn_dly_clk_chain_dly_o;
  --adc_fn_dly_in_int(3).adc_data_dly         <= regs_out.ch3_fn_dly_data_chain_dly_o;
  --adc_fn_dly_in_int(3).adc_clk_dly_inc      <= regs_out.ch3_fn_dly_inc_clk_chain_dly_o;
  --adc_fn_dly_in_int(3).adc_data_dly_inc     <= regs_out.ch3_fn_dly_inc_data_chain_dly_o;
  --adc_fn_dly_in_int(3).adc_clk_dly_dec      <= regs_out.ch3_fn_dly_dec_clk_chain_dly_o;
  --adc_fn_dly_in_int(3).adc_data_dly_dec     <= regs_out.ch3_fn_dly_dec_data_chain_dly_o;

  adc_fn_dly_wb_ctl_out(0).clk_chain.loadable.load     <= regs_out.ch0_fn_dly_clk_chain_dly_load_o;
  adc_fn_dly_wb_ctl_out(0).data_chain.loadable.load    <= regs_out.ch0_fn_dly_data_chain_dly_load_o;
  adc_fn_dly_wb_ctl_out(0).clk_chain.loadable.val      <= regs_out.ch0_fn_dly_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(0).data_chain.loadable.val     <= regs_out.ch0_fn_dly_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(0).clk_chain.loadable.pulse    <= regs_out.adc_ctl_update_clk_dly_o;
  adc_fn_dly_wb_ctl_out(0).data_chain.loadable.pulse   <= regs_out.adc_ctl_update_data_dly_o;
  adc_fn_dly_wb_ctl_out(0).clk_chain.var.inc           <= regs_out.ch0_fn_dly_inc_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(0).data_chain.var.inc          <= regs_out.ch0_fn_dly_inc_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(0).clk_chain.var.dec           <= regs_out.ch0_fn_dly_dec_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(0).data_chain.var.dec          <= regs_out.ch0_fn_dly_dec_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(1).clk_chain.loadable.load     <= regs_out.ch1_fn_dly_clk_chain_dly_load_o;
  adc_fn_dly_wb_ctl_out(1).data_chain.loadable.load    <= regs_out.ch1_fn_dly_data_chain_dly_load_o;
  adc_fn_dly_wb_ctl_out(1).clk_chain.loadable.val      <= regs_out.ch1_fn_dly_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(1).data_chain.loadable.val     <= regs_out.ch1_fn_dly_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(1).clk_chain.loadable.pulse    <= regs_out.adc_ctl_update_clk_dly_o;
  adc_fn_dly_wb_ctl_out(1).data_chain.loadable.pulse   <= regs_out.adc_ctl_update_data_dly_o;
  adc_fn_dly_wb_ctl_out(1).clk_chain.var.inc           <= regs_out.ch1_fn_dly_inc_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(1).data_chain.var.inc          <= regs_out.ch1_fn_dly_inc_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(1).clk_chain.var.dec           <= regs_out.ch1_fn_dly_dec_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(1).data_chain.var.dec          <= regs_out.ch1_fn_dly_dec_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(2).clk_chain.loadable.load     <= regs_out.ch2_fn_dly_clk_chain_dly_load_o;
  adc_fn_dly_wb_ctl_out(2).data_chain.loadable.load    <= regs_out.ch2_fn_dly_data_chain_dly_load_o;
  adc_fn_dly_wb_ctl_out(2).clk_chain.loadable.val      <= regs_out.ch2_fn_dly_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(2).data_chain.loadable.val     <= regs_out.ch2_fn_dly_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(2).clk_chain.loadable.pulse    <= regs_out.adc_ctl_update_clk_dly_o;
  adc_fn_dly_wb_ctl_out(2).data_chain.loadable.pulse   <= regs_out.adc_ctl_update_data_dly_o;
  adc_fn_dly_wb_ctl_out(2).clk_chain.var.inc           <= regs_out.ch2_fn_dly_inc_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(2).data_chain.var.inc          <= regs_out.ch2_fn_dly_inc_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(2).clk_chain.var.dec           <= regs_out.ch2_fn_dly_dec_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(2).data_chain.var.dec          <= regs_out.ch2_fn_dly_dec_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(3).clk_chain.loadable.load     <= regs_out.ch3_fn_dly_clk_chain_dly_load_o;
  adc_fn_dly_wb_ctl_out(3).data_chain.loadable.load    <= regs_out.ch3_fn_dly_data_chain_dly_load_o;
  adc_fn_dly_wb_ctl_out(3).clk_chain.loadable.val      <= regs_out.ch3_fn_dly_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(3).data_chain.loadable.val     <= regs_out.ch3_fn_dly_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(3).clk_chain.loadable.pulse    <= regs_out.adc_ctl_update_clk_dly_o;
  adc_fn_dly_wb_ctl_out(3).data_chain.loadable.pulse   <= regs_out.adc_ctl_update_data_dly_o;
  adc_fn_dly_wb_ctl_out(3).clk_chain.var.inc           <= regs_out.ch3_fn_dly_inc_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(3).data_chain.var.inc          <= regs_out.ch3_fn_dly_inc_data_chain_dly_o;
  adc_fn_dly_wb_ctl_out(3).clk_chain.var.dec           <= regs_out.ch3_fn_dly_dec_clk_chain_dly_o;
  adc_fn_dly_wb_ctl_out(3).data_chain.var.dec          <= regs_out.ch3_fn_dly_dec_data_chain_dly_o;

  -- ADC delay falling edge control
  adc_cs_dly_in_int(0).adc_data_fe_d1_en    <= regs_out.ch0_cs_dly_fe_dly_o(0);
  adc_cs_dly_in_int(0).adc_data_fe_d2_en    <= regs_out.ch0_cs_dly_fe_dly_o(1);
  adc_cs_dly_in_int(1).adc_data_fe_d1_en    <= regs_out.ch1_cs_dly_fe_dly_o(0);
  adc_cs_dly_in_int(1).adc_data_fe_d2_en    <= regs_out.ch1_cs_dly_fe_dly_o(1);
  adc_cs_dly_in_int(2).adc_data_fe_d1_en    <= regs_out.ch2_cs_dly_fe_dly_o(0);
  adc_cs_dly_in_int(2).adc_data_fe_d2_en    <= regs_out.ch2_cs_dly_fe_dly_o(1);
  adc_cs_dly_in_int(3).adc_data_fe_d1_en    <= regs_out.ch3_cs_dly_fe_dly_o(0);
  adc_cs_dly_in_int(3).adc_data_fe_d2_en    <= regs_out.ch3_cs_dly_fe_dly_o(1);

  -- ADC regular delay control
  adc_cs_dly_in_int(0).adc_data_rg_d1_en    <= regs_out.ch0_cs_dly_rg_dly_o(0);
  adc_cs_dly_in_int(0).adc_data_rg_d2_en    <= regs_out.ch0_cs_dly_rg_dly_o(1);
  adc_cs_dly_in_int(1).adc_data_rg_d1_en    <= regs_out.ch1_cs_dly_rg_dly_o(0);
  adc_cs_dly_in_int(1).adc_data_rg_d2_en    <= regs_out.ch1_cs_dly_rg_dly_o(1);
  adc_cs_dly_in_int(2).adc_data_rg_d1_en    <= regs_out.ch2_cs_dly_rg_dly_o(0);
  adc_cs_dly_in_int(2).adc_data_rg_d2_en    <= regs_out.ch2_cs_dly_rg_dly_o(1);
  adc_cs_dly_in_int(3).adc_data_rg_d1_en    <= regs_out.ch3_cs_dly_rg_dly_o(0);
  adc_cs_dly_in_int(3).adc_data_rg_d2_en    <= regs_out.ch3_cs_dly_rg_dly_o(1);

  -- Wishbone Interface Register output assignments. There are others registers
  -- not assigned here.
  fmc_clk_sel_o                             <= regs_out.fmc_ctl_clk_sel_o;

  -----------------------------
  -- Pins connections for ADC interface structures
  -----------------------------
  -- The hardcoded part here is innevitable as we have to mannualy connect
  -- the external ports to the structures.
  --
  -- WARNING: just clock 1 is is used for now. If more clocks are used,
  -- we would have to synchronise the other resets (adc_in(x).adc_rst_n)
  -- to it and map them below!

  -- ADC in signal mangling
  adc_in(0).adc_clk                         <= adc_clk0;
  adc_in(0).adc_data                        <= adc_data_ch0;
  adc_in(1).adc_clk                         <= adc_clk1;
  adc_in(1).adc_data                        <= adc_data_ch1;
  adc_in(2).adc_clk                         <= adc_clk2;
  adc_in(2).adc_data                        <= adc_data_ch2;
  adc_in(3).adc_clk                         <= adc_clk3;
  adc_in(3).adc_data                        <= adc_data_ch3;

  gen_fs_rst_in : for i in 0 to c_num_adc_channels-1 generate
    adc_in(i).adc_rst_n                     <= fs_rst_sync_n(i);
  end generate;

  -- ADC fine delay signal mangling
  --gen_adc_dly_in : for i in 0 to c_num_adc_channels-1 generate
  --  adc_fn_dly_in(i).clk_chain.idelay.pulse <=
  --               regs_out.adc_ctl_update_clk_dly_o or adc_dly_pulse_clk_int(i);
  --  adc_fn_dly_in(i).data_chain.idelay.pulse <=
  --               regs_out.adc_ctl_update_data_dly_o or adc_dly_pulse_data_int(i);
  --end generate;

  -- ADC coarse delay signal mangling
  gen_adc_dly_ctl : for i in 0 to c_num_adc_channels-1 generate
    adc_cs_dly_in(i).adc_data_fe_d1_en <= adc_cs_dly_in_int(i).adc_data_fe_d1_en;
    adc_cs_dly_in(i).adc_data_fe_d2_en <= adc_cs_dly_in_int(i).adc_data_fe_d2_en;
    adc_cs_dly_in(i).adc_data_rg_d1_en <= adc_cs_dly_in_int(i).adc_data_rg_d1_en;
    adc_cs_dly_in(i).adc_data_rg_d2_en <= adc_cs_dly_in_int(i).adc_data_rg_d2_en;
  end generate;

  -----------------------------
  -- Wishbone Delay Register Interface <-> ADC interface (clock + data delays).
  -----------------------------
  -- Clock/Data Chain delays

  -- Capture delay signals (clock + data chains) coming from the Wishbone
  -- Register Interface.
  -- Idelay "var_loadable" interface
  --gen_adc_dly_var_loadable : for i in 0 to c_num_adc_channels-1 generate
  gen_adc_idlay_iface : for i in 0 to c_num_adc_channels-1 generate

    cmp_fmc_adc_dly_iface : fmc_adc_dly_iface
    generic map(
      g_with_var_loadable                     => c_with_idelay_var_loadable,
      g_with_variable                         => c_with_idelay_variable,
      g_with_fn_dly_select                    => c_with_fn_dly_select
    )
    port map(
      rst_n_i                                 => sys_rst_sync_n,
      clk_sys_i                               => sys_clk_i,

      adc_fn_dly_wb_ctl_i                     => adc_fn_dly_wb_ctl_out(i),
      adc_fn_dly_o                            => adc_fn_dly_in(i)
    );

    --p_adc_dly : process (sys_clk_i)
    --begin
    --  if rising_edge(sys_clk_i) then
    --    if sys_rst_sync_n = '0' then
    --      adc_fn_dly_in(i).clk_chain.idelay.val <= (others => '0');
    --      adc_fn_dly_in(i).data_chain.idelay.val <= (others => '0');
    --    else
    --      -- write to clock register delay
    --      if adc_fn_dly_in_int(i).adc_clk_load = '1' then
    --        adc_fn_dly_in(i).clk_chain.idelay.val <= adc_fn_dly_in_int(i).adc_clk_dly;
    --      end if;
    --
    --      -- write to data register delay
    --      if adc_fn_dly_in_int(i).adc_data_load = '1' then
    --        adc_fn_dly_in(i).data_chain.idelay.val <= adc_fn_dly_in_int(i).adc_data_dly;
    --      end if;
    --
    --    end if;
    --  end if;
    --end process;

    -- Debug interface
    adc_dly_debug_o(i) <= adc_fn_dly_in(i);
  end generate;

  -- Idelay "variable" interface
  --gen_adc_dly_variable : for i in 0 to c_num_adc_channels-1 generate
  --  p_adc_dly : process (sys_clk_i)
  --  begin
  --    if rising_edge(sys_clk_i) then
  --      if sys_rst_sync_n = '0' then
  --        adc_dly_pulse_clk_int(i) <= '0';
  --        adc_dly_pulse_data_int(i) <= '0';
  --        adc_fn_dly_in(i).clk_chain.idelay.incdec <= '0';
  --        adc_fn_dly_in(i).data_chain.idelay.incdec <= '0';
  --      else
  --
  --        --adc_dly_pulse_clk_int(i) <= '1';
  --
  --        -- Increment/Decrement clk delays
  --        if adc_fn_dly_in_int(i).adc_clk_dly_inc = '1' then
  --          adc_fn_dly_in(i).clk_chain.idelay.incdec <= '1';
  --        elsif adc_fn_dly_in_int(i).adc_clk_dly_dec = '1' then
  --          adc_fn_dly_in(i).clk_chain.idelay.incdec <= '0';
  --        end if;
  --
  --        --adc_dly_pulse_data_int(i) <= '1';
  --
  --        -- Increment/Decrement data delays
  --        if adc_fn_dly_in_int(i).adc_data_dly_inc = '1' then
  --          adc_fn_dly_in(i).data_chain.idelay.incdec <= '1';
  --        elsif adc_fn_dly_in_int(i).adc_data_dly_dec = '1' then
  --          adc_fn_dly_in(i).data_chain.idelay.incdec <= '0';
  --        end if;
  --
  --        -- Enable pulse when increment or decrement data delay
  --        if adc_fn_dly_in_int(i).adc_clk_dly_inc = '1' or
  --                            adc_fn_dly_in_int(i).adc_clk_dly_dec = '1' then
  --          adc_dly_pulse_data_int(i) <= '1';
  --        else
  --          adc_dly_pulse_data_int(i) <= '0';
  --        end if;
  --
  --        -- Enable pulse when increment or decrement clock delay
  --        if adc_fn_dly_in_int(i).adc_data_dly_inc = '1' or
  --                            adc_fn_dly_in_int(i).adc_data_dly_dec = '1' then
  --          adc_dly_pulse_data_int(i) <= '1';
  --        else
  --          adc_dly_pulse_data_int(i) <= '0';
  --        end if;
  --
  --      end if;
  --    end if;
  --  end process;
  --
  --end generate;

  -------------------------------
  ---- ADC Interface
  -------------------------------
  cmp_fmc516_adc_buf : fmc_adc_buf
  generic map (
    g_with_clk_single_ended                 => c_with_clk_single_ended,
    g_with_data_single_ended                => c_with_data_single_ended,
    g_with_data_sdr                         => c_with_data_sdr
  )
  port map (
    -----------------------------
    -- External ports
    -----------------------------
    -- ADC clocks. One clock per ADC channel
    adc_clk0_p_i                            => adc_clk0_p_i,
    adc_clk0_n_i                            => adc_clk0_n_i,
    adc_clk1_p_i                            => adc_clk1_p_i,
    adc_clk1_n_i                            => adc_clk1_n_i,
    adc_clk2_p_i                            => adc_clk2_p_i,
    adc_clk2_n_i                            => adc_clk2_n_i,
    adc_clk3_p_i                            => adc_clk3_p_i,
    adc_clk3_n_i                            => adc_clk3_n_i,

    adc_clk0_i                              => dummy_bit_low,
    adc_clk1_i                              => dummy_bit_low,
    adc_clk2_i                              => dummy_bit_low,
    adc_clk3_i                              => dummy_bit_low,

    -- DDR ADC data channels.
    adc_data_ch0_p_i                        => adc_data_ch0_p_i,
    adc_data_ch0_n_i                        => adc_data_ch0_n_i,
    adc_data_ch1_p_i                        => adc_data_ch1_p_i,
    adc_data_ch1_n_i                        => adc_data_ch1_n_i,
    adc_data_ch2_p_i                        => adc_data_ch2_p_i,
    adc_data_ch2_n_i                        => adc_data_ch2_n_i,
    adc_data_ch3_p_i                        => adc_data_ch3_p_i,
    adc_data_ch3_n_i                        => adc_data_ch3_n_i,

    adc_data_ch0_i                          => dummy_adc_vector_low,
    adc_data_ch1_i                          => dummy_adc_vector_low,
    adc_data_ch2_i                          => dummy_adc_vector_low,
    adc_data_ch3_i                          => dummy_adc_vector_low,

    adc_clk0_o                              => adc_clk0,
    adc_clk1_o                              => adc_clk1,
    adc_clk2_o                              => adc_clk2,
    adc_clk3_o                              => adc_clk3,

    adc_data_ch0_o                          => adc_data_ch0,
    adc_data_ch1_o                          => adc_data_ch1,
    adc_data_ch2_o                          => adc_data_ch2,
    adc_data_ch3_o                          => adc_data_ch3
  );

  cmp_fmc516_adc_iface : fmc_adc_iface
  generic map(
      -- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                           => g_fpga_device,
    g_delay_type                            => g_delay_type,
    g_adc_clk_period_values                 => g_adc_clk_period_values,
    g_use_clk_chains                        => g_use_clk_chains,
    g_use_data_chains                       => g_use_data_chains,
    g_map_clk_data_chains                   => g_map_clk_data_chains,
    g_ref_clk                               => g_ref_clk,
    g_with_data_sdr                         => c_with_data_sdr,
    g_with_fn_dly_select                    => c_with_fn_dly_select,
    g_with_idelayctrl                       => g_with_idelayctrl,
    g_sim                                   => g_sim
  )
  port map(
    sys_clk_i                               => sys_clk_i,
    -- System Reset
    sys_rst_n_i                             => sys_rst_sync_n,
    -- ADC clock generation reset. Just a regular asynchronous reset.
    sys_clk_200Mhz_i                        => sys_clk_200Mhz_i,

    -----------------------------
    -- External ports
    -----------------------------
    adc_in_i                                => adc_in,
    adc_in_sdr_i                            => adc_in_sdr_dummy,

    -----------------------------
    -- Optional External Global Clock ports
    -----------------------------
    adc_ext_glob_clk_i                      => adc_ext_glob_clk_int,

    -----------------------------
    -- ADC Delay signals
    -----------------------------

    adc_fn_dly_i                            => adc_fn_dly_in,
    adc_fn_dly_o                            => adc_fn_dly_out,

    adc_cs_dly_i                            => adc_cs_dly_in,

    -----------------------------
    -- ADC output signals
    -----------------------------
    adc_out_o                               => adc_out,

    -----------------------------
    -- MMCM general signals
    -----------------------------
    mmcm_adc_locked_o                       => mmcm_adc_locked,
    -- Idelay ready signal
    idelay_rdy_o                            => open,

    fifo_debug_valid_o                      => fifo_debug_valid_o,
    fifo_debug_full_o                       => fifo_debug_full_o,
    fifo_debug_empty_o                      => fifo_debug_empty_o
  );

  -- Clock and reset assignments
  -- General status board pins
  fmc_mmcm_lock_o                           <= mmcm_adc_locked;

  -- Optional reference clock
  adc_ext_glob_clk_int.adc_clk_bufg         <= fmc_ext_ref_clk_i;
  adc_ext_glob_clk_int.adc_clk2x_bufg       <= fmc_ext_ref_clk2x_i;
  adc_ext_glob_clk_int.mmcm_adc_locked      <= fmc_ext_ref_mmcm_locked_i;

  -- ADC data for internal use
  gen_adc_data_int : for i in 0 to c_num_adc_channels-1 generate
    --adc_clk_int(i)                          <= adc_out(i).adc_clk;
    fs_clk(i)                               <= adc_out(i).adc_clk;
    fs_clk2x(i)                             <= adc_out(i).adc_clk2x;
    adc_data(c_num_adc_bits*(i+1)-1 downto c_num_adc_bits*i)
                                            <= adc_out(i).adc_data;
    adc_valid(i)                            <= adc_out(i).adc_data_valid;
  end generate;

  -- Output ADC signals to external FPGA
  adc_clk_o                                <= fs_clk;
  adc_clk2x_o                              <= fs_clk2x;
  adc_data_o                               <= adc_data;
  adc_data_valid_o                         <= adc_valid;

  -- Synchronize the adc reset to the first available clock.
  -- The ISLA216P25 equires them to be sunchronous to the input sample
  -- clock. Thus, we need to double the fs clock to match it.
  gen_adc_rsts : if c_ref_clk /= -1 generate
    cmp_adc_clk_div_rst_n_extd_pulse : gc_extend_pulse
    generic map (
      g_width                                 => 64
    )
    port map (
      --clk_i                                   => fs_clk2x(c_ref_clk),
      clk_i                                   => fs_clk(c_ref_clk),
      rst_n_i                                 => fs_rst_sync_n(c_ref_clk),
      -- input pulse (synchronous to clk_i)
      pulse_i                                 => regs_out.adc_ctl_rst_div_adcs_o,
      -- extended output pulse
      extended_o                              => adc_clk_div_rst_int
    );

    -- ADC div resets logic
    cmp_clk_div_rst_obufds : obufds
    generic map(
      IOSTANDARD                              => "LVDS_25"
    )
    port map (
      O                                       => adc_clk_div_rst_p_o,
      OB                                      => adc_clk_div_rst_n_o,
      I                                       => adc_clk_div_rst_int
    );

    cmp_fmc_reset_adcs_n_extd_pulse : gc_extend_pulse
    generic map (
      g_width                                 => 64
    )
    port map (
      --clk_i                                   => fs_clk2x(c_ref_clk),
      clk_i                                   => fs_clk(c_ref_clk),
      rst_n_i                                 => fs_rst_sync_n(c_ref_clk),
      -- input pulse (synchronous to clk_i)
      pulse_i                                 => regs_out.adc_ctl_rst_adcs_o,
      -- extended output pulse
      extended_o                              => fmc_reset_adcs_int
    );

    fmc_reset_adcs_n_o                        <= not fmc_reset_adcs_int;
  end generate;

  -----------------------------
  -- System I2C Bus
  -----------------------------
  -- Slaves: Atmel AT24C512B Serial EEPROM, AD7417
  --          temperature diodes and AD7417 supply rails
  -- System I2C Bus is lave number 1, word addressed
  --
  -- Note: I2C registers are 8-bit wide, but accessed as 32-bit registers.
  -- Note2: On the ML605 Kit GA0 = 0 and GA1 = 0. This geographical adrresses
  -- are carrier specific. Check this before addressing I2C slaves on this bus!
  cmp_fmc_sys_i2c : xwb_i2c_master
  generic map(
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_sync_n,

    slave_i                                 => cbar_master_out(1),
    slave_o                                 => cbar_master_in(1),
    desc_o                                  => open,

    scl_pad_i                               => sys_i2c_scl_in,
    scl_pad_o                               => sys_i2c_scl_out,
    scl_padoen_o                            => sys_i2c_scl_oe_n,
    sda_pad_i                               => sys_i2c_sda_in,
    sda_pad_o                               => sys_i2c_sda_out,
    sda_padoen_o                            => sys_i2c_sda_oe_n
  );

  -- Tri-state buffer for SDA and SCL
  sys_i2c_scl_b  <= sys_i2c_scl_out when sys_i2c_scl_oe_n = '0' else 'Z';
  sys_i2c_scl_in <= sys_i2c_scl_b;

  sys_i2c_sda_b  <= sys_i2c_sda_out when sys_i2c_sda_oe_n = '0' else 'Z';
  sys_i2c_sda_in <= sys_i2c_sda_b;

  -- Not used wishbone signals
  cbar_master_in(1).err                     <= '0';
  cbar_master_in(1).rty                     <= '0';

  -----------------------------
  -- SPI Bus
  -----------------------------
  -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
  -- ADC SPI is slave number 2, word addressed

  cmp_fmc_spi : xwb_spi
  generic map(
    g_three_wire_mode                       => 1,
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_sync_n,

    slave_i                                 => cbar_master_out(2),
    slave_o                                 => cbar_master_in(2),
    desc_o                                  => open,

    pad_cs_o                                => sys_spi_ss_int,
    pad_sclk_o                              => sys_spi_clk,
    pad_mosi_o                              => sys_spi_dout,
    pad_miso_i                              => sys_spi_din,
    pad_oen_o                               => sys_spi_miosio_oe_n
  );

  -- Output SPI clock
  sys_spi_clk_o <= sys_spi_clk;
  --sys_spi_dout_o <= sys_spi_dout;
  --sys_spi_din <= sys_spi_din_i;
  sys_spi_data_b  <= sys_spi_dout when sys_spi_miosio_oe_n = '0' else 'Z';
  sys_spi_din <= sys_spi_data_b;
  --sys_spi_miosio_oe_n_o <= sys_spi_miosio_oe_n;

  -- Assign slave select lines
  sys_spi_cs_adc0_n_o <= sys_spi_ss_int(0);           -- SPI ADC CS channel 0
  sys_spi_cs_adc1_n_o <= sys_spi_ss_int(1);           -- SPI ADC CS channel 1
  sys_spi_cs_adc2_n_o <= sys_spi_ss_int(2);           -- SPI ADC CS channel 2
  sys_spi_cs_adc3_n_o <= sys_spi_ss_int(3);           -- SPI ADC CS channel 3

  -- Not used wishbone signals
  cbar_master_in(2).rty                     <= '0';

  -----------------------------
  -- Microwire FMC LMK
  -----------------------------
  -- Microwire FMC LMK control interface. Four-wire mode.
  -- Microwire FMC LMK is slave number 3, word addressed
  --
  -- Note: No readback from the LMK CI is available. Hence,
  -- pad_miso_i is fixed logic '0'
  cmp_fmc_lmk_uwire : xwb_spi
  generic map(
    g_three_wire_mode                       => 0,
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_sync_n,

    slave_i                                 => cbar_master_out(3),
    slave_o                                 => cbar_master_in(3),
    desc_o                                  => open,

    pad_cs_o                                => fmc_lmk_uwire_ss_int,
    pad_sclk_o                              => fmc_lmk_uwire_clk,
    pad_mosi_o                              => lmk_uwire_data_o,
    pad_miso_i                              => '0',
    pad_oen_o                               => open
  );
  --
  -- Output Microwire LMK clock
  lmk_uwire_clock_o <= fmc_lmk_uwire_clk;

  -- Output latch enable signal
  lmk_uwire_latch_en_o <= fmc_lmk_uwire_ss_int(0);

  -- Deprecated
  lmk_sync_o <= '0';

  -- Not used wishbone signals
  cbar_master_in(3).rty                     <= '0';

  -----------------------------
  -- I2C Programmable VCXO
  -----------------------------
  -- I2C Programmable VCXO control interface.
  -- I2C Programmable VCXO is slave number 4, word addressed
  -- Note: I2C registers are 8-bit wide, but accessed as 32-bit registers
  cmp_vcxo_i2c : xwb_i2c_master
  generic map(
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_sync_n,

    slave_i                                 => cbar_master_out(4),
    slave_o                                 => cbar_master_in(4),
    desc_o                                  => open,

    scl_pad_i                               => vcxo_i2c_scl_in,
    scl_pad_o                               => vcxo_i2c_scl_out,
    scl_padoen_o                            => vcxo_i2c_scl_oe_n,
    sda_pad_i                               => vcxo_i2c_sda_in,
    sda_pad_o                               => vcxo_i2c_sda_out,
    sda_padoen_o                            => vcxo_i2c_sda_oe_n
  );

  vcxo_i2c_scl_b  <= vcxo_i2c_scl_out when vcxo_i2c_scl_oe_n = '0' else 'Z';
  vcxo_i2c_scl_in <= vcxo_i2c_scl_b;
  --vcxo_i2c_scl_o <= sys_i2c_scl_out when vcxo_i2c_scl_oe_n = '0' else 'Z';

  vcxo_i2c_sda_b  <= vcxo_i2c_sda_out when vcxo_i2c_sda_oe_n = '0' else 'Z';
  vcxo_i2c_sda_in <= vcxo_i2c_sda_b;

  -- VCXO output enable. Controllable from the Wishbone Register Interface
  vcxo_pd_l_o                               <= regs_out.fmc_ctl_vcxo_out_en_o;

  -- Not used wishbone signals
  cbar_master_in(4).err                     <= '0';
  cbar_master_in(4).rty                     <= '0';

  -----------------------------
  -- DS2431 (VMETRO Data) One-Wire Interface
  -----------------------------
  -- DS2431 One-Wire control interface.
  -- DS2431 One-Wire is slave number 5, word addressed

  cmp_ds2431_onewire : xwb_onewire_master
  generic map(
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity,
    g_num_ports                             => 1,
    g_ow_btp_normal                         => "5.0",
    g_ow_btp_overdrive                      => "1.0"
  )
  port map(
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_sync_n,

    slave_i                                 => cbar_master_out(5),
    slave_o                                 => cbar_master_in(5),
    desc_o                                  => open,

    owr_pwren_o                             => owr_id_pwren,
    owr_en_o                                => owr_id_en,
    owr_i                                   => owr_id_i
  );

  fmc_id_dq_b <= '0' when owr_id_en(0) = '1' else 'Z';
  owr_id_i(0) <= fmc_id_dq_b;

  -- Not used wishbone signals
  cbar_master_in(5).err                     <= '0';
  cbar_master_in(5).rty                     <= '0';

  -----------------------------
  -- DS2432 SHA-1 (SP-Devices key) One-Wire Interface
  -----------------------------
  -- DS2432 One-Wire control interface.
  -- DS2432 One-Wire is slave number 6, word addressed
  cmp_ds2432_onewire : xwb_onewire_master
  generic map(
    g_interface_mode                        => g_interface_mode,
    g_address_granularity                   => g_address_granularity,
    g_num_ports                             => 1,
    g_ow_btp_normal                         => "5.0",
    g_ow_btp_overdrive                      => "1.0"
  )
  port map(
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_sync_n,

    slave_i                                 => cbar_master_out(6),
    slave_o                                 => cbar_master_in(6),
    desc_o                                  => open,

    owr_pwren_o                             => owr_key_pwren,
    owr_en_o                                => owr_key_en,
    owr_i                                   => owr_key_i
  );

  fmc_key_dq_b <= '0' when owr_key_en(0) = '1' else 'Z';
  owr_key_i(0) <= fmc_key_dq_b;

  -- Not used wishbone signals
  cbar_master_in(6).err                     <= '0';
  cbar_master_in(6).rty                     <= '0';

  -----------------------------
  -- Wishbone Streaming Interface
  -----------------------------
  -- This stream source is in ADC clock domain
  gen_wbs_interfaces : for i in 0 to c_num_adc_channels-1 generate
    gen_wbs_interfaces_ch : if g_use_data_chains(i) = '1' generate
      -- Generate 16-bit wishbone streaming interface
      cmp_wb_stream_source_gen : wb_stream_source_gen
      generic map (
        g_wbs_interface_width                   => NARROW2
      )
      port map(
        --clk_i                                   => fs_clk,
        clk_i                                   => fs_clk(i),
        rst_n_i                                 => fs_rst_sync_n(i),

        ---- Wishbone Fabric Interface I/O
        -- 16-bit interface
        src_adr16_o                             => wbs_adr_o(c_wbs_adr4_width*(i+1)-1 downto
                                                    c_wbs_adr4_width*i),
        src_dat16_o                             => wbs_dat_o(c_wbs_dat16_width*(i+1)-1 downto
                                                    c_wbs_dat16_width*i),
        src_sel16_o                             => wbs_sel_o(c_wbs_sel16_width*(i+1)-1 downto
                                                    c_wbs_sel16_width*i),

        -- Common Wishbone Streaming lines
        src_cyc_o                               => wbs_cyc_o(i),
        src_stb_o                               => wbs_stb_o(i),
        src_we_o                                => wbs_we_o(i),
        src_ack_i                               => wbs_ack_i(i),
        src_stall_i                             => wbs_stall_i(i),
        src_err_i                               => wbs_err_i(i),
        src_rty_i                               => wbs_rty_i(i),

        -- Decoded & buffered logic
        -- 16-bit interface
        adr16_i                                 => wbs_adr,
        dat16_i                                 => wbs_dat(i),
        sel16_i                                 => wbs_sel,

        dvalid_i                                => wbs_valid(i),
        sof_i                                   => '1',
        eof_i                                   => '0',
        error_i                                 => wbs_error,
        dreq_o                                  => open
      );

      -- Generate test data
      p_gen_test_data : process(fs_clk(i))
      --p_gen_test_data : process(fs_clk2x(c_ref_clk), fs_rst_sync_n(c_ref_clk))
      begin
        if rising_edge(fs_clk(i)) then
          if fs_rst_sync_n(i) = '0' then
            wbs_test_data(i) <= (others => '0');
          else
            wbs_test_data(i) <= wbs_test_data(i) + 1;
          end if;
        end if;
      end process;

      wbs_dat(i) <= adc_out(i).adc_data when regs_out.fmc_ctl_test_data_en_o = '0'
                      else std_logic_vector(wbs_test_data(i));
      wbs_valid(i) <= adc_out(i).adc_data_valid when regs_out.fmc_ctl_test_data_en_o = '0'
                        else '1';
    end generate;
  end generate;

  -- Write always to addr c_WBS_DATA (meaning we are transmiting data)
  wbs_adr                                   <= std_logic_vector(resize(c_WBS_DATA, wbs_adr'length));
  wbs_error                                 <= '0';
  wbs_sel                                   <= (others => '1');

  -- generate SOF and EOF signals
  --p_gen_wbs_sof_eof : process(fs_clk, fs_rst_sync_n)
  --begin
  --  if fs_rst_sync_n = '0' then
  --    wbs_packet_counter <= (others => '0');
  --    wbs_sof <= '0';
  --    wbs_eof <= '0';
  --  elsif rising_edge(fs_clk) then
  --    -- Increment counter if data is valid
  --    if wbs_dvalid = '1' then
  --      wbs_packet_counter <= wbs_packet_counter + 1;
  --    end if;
  --
  --    if wbs_packet_counter = to_unsigned(0, g_packet_size) then
  --      wbs_sof <= '1';
  --    else
  --      wbs_sof <= '0';
  --    end if;
  --
  --    if wbs_packet_counter = g_packet_size-2 and wbs_dvalid = '1' then
  --      wbs_eof <= '1';
  --    else
  --      wbs_eof <= '0';
  --    end if;
  --  end if;
  --end process;

  -- Generate SOF and EOF signals based on counter
  --wbs_sof <= '1' when wbs_packet_counter = to_unsigned(0, g_packet_size) else '0';
  --wbs_eof <= '1' when wbs_packet_counter = g_packet_size-1 else '0';

  -----------------------------
  -- Trigger Interface.
  -----------------------------
  -- Trigger buffers and Synchronization
  cmp_ext_trig_ibufds : ibufds
  generic map(
    IOSTANDARD                               => "LVDS_25",
    DIFF_TERM                             => TRUE
  )
  port map (
    O                                     => m2c_trig,
    I                                     => m2c_trig_p_i,
    IB                                    => m2c_trig_n_i
  );

  -- External hardware trigger synchronization
  cmp_trig_sync : gc_ext_pulse_sync
  generic map(
    g_min_pulse_width                       => 1,     -- clk_i ticks
    g_clk_frequency                         => 100,   -- MHz
    g_output_polarity                       => '0',   -- positive pulse
    g_output_retrig                         => false,
    g_output_length                         => 1      -- clk_i tick
  )
  port map(
    rst_n_i                                 => fs_rst_sync_n(c_ref_clk),
    clk_i                                   => fs_clk(c_ref_clk),
    input_polarity_i                        => regs_out.trig_cfg_hw_trig_pol_o,
    pulse_i                                 => m2c_trig,
    pulse_o                                 => m2c_trig_sync
  );

  -- Output external trigger to other logic. Hardware trigger enable
  trig_hw_o                                 <= m2c_trig_sync and regs_out.trig_cfg_hw_trig_en_o;

  cmp_ext_trig_obufds : obufds
  generic map(
    IOSTANDARD                                 => "LVDS_25"
  )
  port map (
    O                                       => c2m_trig_p_o,
    OB                                      => c2m_trig_n_o,
    I                                       => c2m_trig
  );

  -- Input external trigger to FPGA pin
  c2m_trig                                  <= trig_hw_i;

  -----------------------------
  -- LEDs Interface. Output extended pulses of important commands
  -----------------------------

  -- Red FMC front led
  --cmp_led0_extende_pulse : gc_extend_pulse
  --generic map (
  --  -- Input clock = 100MHz
  --  -- 20000000 clock pulses =  0.2s pulse
  --  g_width => 20000000
  --)
  --port (
  --  clk_i                                   => sys_clk_i
  --  rst_n_i                                 => sys_rst_n,
  --  -- input pulse (synchronous to clk_i)
  --  pulse_i                                 => ?,
  --  -- extended output pulse
  --  extended_o                              => led0_extd_p
  --);

  -- Output extended pulse led from FMC power good signal or register interface
  -- manual led control
  -- fmc_leds_o(0) <= led0_extd_p or regs_out.fmc_ctl_led_0_o;
  fmc_leds_o(0) <= not(fmc_pwr_good_i) or regs_out.fmc_ctl_led_0_o;

  -- Green FMC front led
  cmp_led1_extende_pulse : gc_extend_pulse
  generic map (
    -- Input clock = 100MHz
    -- 20000000 clock pulses =  0.2s pulse
    g_width => 20000000
  )
  port map (
    clk_i                                   => sys_clk_i,
    rst_n_i                                 => sys_rst_sync_n,
    -- input pulse (synchronous to clk_i)
    pulse_i                                 => m2c_trig_sync,
    -- extended output pulse
    extended_o                              => led1_extd_p
  );

  -- Output extended pulse led from m2c_trig_sync or register interface manual led control
  fmc_leds_o(1) <= led1_extd_p or regs_out.fmc_ctl_led_1_o;

end rtl;
