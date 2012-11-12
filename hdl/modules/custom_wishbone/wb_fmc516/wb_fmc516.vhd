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
-- Wishbone Register Interface
use work.fmc516_wbgen2_pkg.all;
-- Reset Synch
use work.custom_common_pkg.all;

entity wb_fmc516 is
generic
(
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_adc_clock_period_values                 : t_clock_values_array(3 downto 0) := dummy_clocks;
  g_use_clock_chains                        : std_logic_vector(3 downto 0) := "0010";
  g_use_data_chains                         : std_logic_vector(3 downto 0) := "1111";
  g_adc_bits                                : natural := 16;
  g_packet_size                             : natural := 32;
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
  -- Only ch0 clock is used as all data chains
  -- are sampled at the same frequency
  adc_clk0_p_i                              : in std_logic;
  adc_clk0_n_i                              : in std_logic;
  adc_clk1_p_i                              : in std_logic;
  adc_clk1_n_i                              : in std_logic;
  adc_clk2_p_i                              : in std_logic;
  adc_clk2_n_i                              : in std_logic;
  adc_clk3_p_i                              : in std_logic;
  adc_clk3_n_i                              : in std_logic;

  -- DDR ADC data channels.
  adc_data_ch0_p_i                          : in std_logic_vector(7 downto 0);
  adc_data_ch0_n_i                          : in std_logic_vector(7 downto 0);
  adc_data_ch1_p_i                          : in std_logic_vector(7 downto 0);
  adc_data_ch1_n_i                          : in std_logic_vector(7 downto 0);
  adc_data_ch2_p_i                          : in std_logic_vector(7 downto 0);
  adc_data_ch2_n_i                          : in std_logic_vector(7 downto 0);
  adc_data_ch3_p_i                          : in std_logic_vector(7 downto 0);
  adc_data_ch3_n_i                          : in std_logic_vector(7 downto 0);

  -- ADC clock (half of the sampling frequency) divider reset
  adc_clk_div_rst_p_o                       : out std_logic;
  adc_clk_div_rst_n_o                       : out std_logic;

  -- FMC Front leds. Typical uses: Over Range or Full Scale
  -- condition.
  fmc_leds_o                                : out std_logic_vector(1 downto 0);

  -- ADC SPI control interface. Three-wire mode. Tri-stated data pin
  sys_spi_clk_o                             : out std_logic;
  sys_spi_data_b                            : inout std_logic;
  sys_spi_cs_adc1_n_o                       : out std_logic;  -- SPI ADC CS channel 0
  sys_spi_cs_adc2_n_o                       : out std_logic;  -- SPI ADC CS channel 1
  sys_spi_cs_adc3_n_o                       : out std_logic;  -- SPI ADC CS channel 2
  sys_spi_cs_adc4_n_o                       : out std_logic;  -- SPI ADC CS channel 3

  -- External Trigger To/From FMC
  m2c_trig_p_i                              : in std_logic;
  m2c_trig_n_i                              : in std_logic;
  c2m_trig_p_o                              : out std_logic;
  c2m_trig_n_o                              : out std_logic;

  -- LMK (National Semiconductor) is the clock and distribution IC.
  -- SPI interface?
  lmk_lock_i                                : in std_logic;
  lmk_sync_o                                : out std_logic;
  lmk_latch_en_o                            : out std_logic;
  lmk_data_o                                : out std_logic;
  lmk_clock_o                               : out std_logic;

  -- Programable VCXO via I2C?
  vcxo_sda_b                                : inout std_logic;
  vcxo_scl_o                                : out std_logic;
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
  fmc_prsnt_m2c_l_i                         : in  std_logic;

  -----------------------------
  -- ADC output signals. Continuous flow
  -----------------------------
  adc_clk_o                                 : out std_logic;
  adc_data_ch0_o                            : out std_logic_vector(15 downto 0);
  adc_data_ch1_o                            : out std_logic_vector(15 downto 0);
  adc_data_ch2_o                            : out std_logic_vector(15 downto 0);
  adc_data_ch3_o                            : out std_logic_vector(15 downto 0);
  adc_data_valid_o                          : out std_logic;

  -----------------------------
  -- General ADC output signals
  -----------------------------
  trig_hw_o                                 : out std_logic;
  trig_hw_i                                 : in std_logic;

  -----------------------------
  -- Wishbone Streaming Interface Source
  -----------------------------

  wbs_adr_o                                 : out std_logic_vector(c_wbs_address_width-1 downto 0);
  wbs_dat_o                                 : out std_logic_vector(c_wbs_data_width-1 downto 0);
  wbs_cyc_o                                 : out std_logic;
  wbs_stb_o                                 : out std_logic;
  wbs_we_o                                  : out std_logic;
  wbs_sel_o                                 : out std_logic_vector((c_wbs_data_width/8)-1 downto 0);
  wbs_ack_i                                 : in std_logic := '0';
  wbs_stall_i                               : in std_logic := '0';
  wbs_err_i                                 : in std_logic := '0';
  wbs_rty_i                                 : in std_logic := '0'
);
end wb_fmc516;

architecture rtl of wb_fmc516 is

  -- Number packet size counter bits
  constant c_counter_size                   : natural := f_ceil_log2(g_packet_size);
  -- Number of ADC channels
  constant c_num_channels                   : natural := 4;

  -- Wishbone fanout component (xwb_bus_fanout) constants
  -- Number of internal wishbone slaves
  constant c_num_int_slaves                 : natural := 7;
  -- Number of each addressing bits for each internal slave (word addressed)
  constant c_num_bits_per_slave             : natural := 8;

  -- Clock and reset signals
  signal sys_rst                            : std_logic;
  signal sys_rst_sync_n                     : std_logic;

  -- FMC516 reg structure
  signal regs_in                            : t_fmc516_out_registers;
  signal regs_out                           : t_fmc516_in_registers;

  -- ADC Interface signals
  signal fs_clk                             : std_logic;
  signal fs_rst_n                           : std_logic;
  signal fs_rst_sync_n                      : std_logic;
  signal mmcm_adc_locked                    : std_logic;

  -- FMC516 signals
  --signal cdce_pll_status                  : std_logic;
  signal s_mmcm_adc_locked                  : std_logic;

  -- Wishbone Streaming control signals
  signal s_wbs_packet_counter               : unsigned(c_counter_size-1 downto 0);
  signal s_addr                             : std_logic_vector(c_wbs_address_width-1 downto 0);
  signal s_data                             : std_logic_vector(c_wbs_data_width-1 downto 0);
  signal s_dvalid                           : std_logic;
  signal s_sof                              : std_logic;
  signal s_eof                              : std_logic;
  signal s_error                            : std_logic;
  signal s_bytesel                          : std_logic_vector((c_wbs_data_width/8)-1 downto 0);
  signal s_dreq                             : std_logic;

  -- Wishbone Streaming interface structure
  signal wbs_stream_out                     : t_wbs_source_out;
  signal wbs_stream_in                      : t_wbs_source_in;

  -- Wishbone slave adapter signals/structures
  signal wb_slv_adp_out                     : t_wishbone_slave_out;
  signal wb_slv_adp_in                      : t_wishbone_slave_in;
  signal resized_addr                       : std_logic_vector(c_wishbone_address_width-1 downto 0);

  -- Wishbone fanout signals
  --signal wb_out                             : t_wishbone_slave_out_array(0 to c_num_int_slaves-1);
  signal wb_out                             : t_wishbone_master_in_array(0 to c_num_int_slaves-1);
  --signal wb_in                              : t_wishbone_slave_in_array(0 to c_num_int_slaves-1);
  signal wb_in                              : t_wishbone_master_out_array(0 to c_num_int_slaves-1);

  -- Trigger signals
  signal m2c_trig                           : std_logic;
  signal m2c_trig_sync                      : std_logic;
  signal c2m_trig                           : std_logic;

  -- Led signals
  signal led0_extd_p                        : std_logic;
  --signal led0_reg                           : std_logic;
  signal led1_extd_p                        : std_logic;
  --signal led1_reg                           : std_logic;

  -- ADC Data/Clock delay registers for generate statements
  type t_adc_dly is record
    -- registers to signals coming from wishbone register interface
    -- ext_load mode
    clk_dly_reg : std_logic_vector(4 downto 0);
    data_dly_reg : std_logic_vector(4 downto 0);
    -- signals from wishbone register interface
    clk_dly : std_logic_vector(4 downto 0);
    data_dly : std_logic_vector(4 downto 0);
    clk_load : std_logic;
    data_load : std_logic;
  end record;

  type t_adc_dly_reg_array  is array (natural range<>) of t_adc_dly;

  -- 4 Channel ADC Clock/Data delay
  signal adc_dly_reg                        : t_adc_dly_reg_array(3 downto 0);

  -----------------------------
  -- Components declaration
  -----------------------------
  component fmc516_adc_iface
  generic
  (
    g_adc_bits                              : natural := 16;
    g_use_clock_chains                      : std_logic_vector(3 downto 0) := "0010";
    g_use_data_chains                       : std_logic_vector(3 downto 0) := "1111";
    g_sim                                   : integer := 0
  );
  port
  (
    sys_clk_i                               : in std_logic;
    sys_rst_n_i                             : in std_logic;
    sys_clk_200Mhz_i                        : in std_logic;

    -----------------------------
    -- External ports
    -----------------------------

    -- ADC clocks. One clock per ADC channel
    adc_clk0_p_i                            : in std_logic;
    adc_clk0_n_i                            : in std_logic;
    adc_clk1_p_i                            : in std_logic;
    adc_clk1_n_i                            : in std_logic;
    adc_clk2_p_i                            : in std_logic;
    adc_clk2_n_i                            : in std_logic;
    adc_clk3_p_i                            : in std_logic;
    adc_clk3_n_i                            : in std_logic;

    -- Do i need really to worry about the deassertion of async resets?
    -- Generate them outside this module, as this reset is needed by
    -- external logic
    adc_clk0_rst_n_i                        : in std_logic;
    adc_clk1_rst_n_i                        : in std_logic;
    adc_clk2_rst_n_i                        : in std_logic;
    adc_clk3_rst_n_i                        : in std_logic;

    -- DDR ADC data channels.
    adc_data_ch0_p_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch0_n_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch1_p_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch1_n_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch2_p_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch2_n_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch3_p_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);
    adc_data_ch3_n_i                        : in std_logic_vector(g_adc_bits/2 - 1 downto 0);

    -----------------------------
    -- ADC Delay signals.
    -----------------------------
    -- Pulse this to update all delay values to the corresponding adc_xxx_dly_val_i
    adc_dly_pulse_i                         : in std_logic;

    adc_clk0_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_clk0_dly_val_o                      : out std_logic_vector(4 downto 0);
    adc_clk1_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_clk1_dly_val_o                      : out std_logic_vector(4 downto 0);
    adc_clk2_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_clk2_dly_val_o                      : out std_logic_vector(4 downto 0);
    adc_clk3_dly_val_i                      : in std_logic_vector(4 downto 0);
    adc_clk3_dly_val_o                      : out std_logic_vector(4 downto 0);

    adc_data_ch0_dly_val_i                  : in std_logic_vector(4 downto 0);
    adc_data_ch0_dly_val_o                  : out std_logic_vector(4 downto 0);
    adc_data_ch1_dly_val_i                  : in std_logic_vector(4 downto 0);
    adc_data_ch1_dly_val_o                  : out std_logic_vector(4 downto 0);
    adc_data_ch2_dly_val_i                  : in std_logic_vector(4 downto 0);
    adc_data_ch2_dly_val_o                  : out std_logic_vector(4 downto 0);
    adc_data_ch3_dly_val_i                  : in std_logic_vector(4 downto 0);
    adc_data_ch3_dly_val_o                  : out std_logic_vector(4 downto 0);

    -----------------------------
    -- ADC output signals.
    -----------------------------
    adc_clk_o                               : out std_logic;
    adc_data_ch0_o                          : out std_logic_vector(g_adc_bits - 1 downto 0);
    adc_data_ch1_o                          : out std_logic_vector(g_adc_bits - 1 downto 0);
    adc_data_ch2_o                          : out std_logic_vector(g_adc_bits - 1 downto 0);
    adc_data_ch3_o                          : out std_logic_vector(g_adc_bits - 1 downto 0);
    adc_data_valid_o                        : out std_logic;

    -----------------------------
    -- MMCM general signals
    -----------------------------
    mmcm_adc_locked_o                       : out std_logic
  );
  end component;

  -- FMC516 Register Wishbone Interface
  component wb_fmc516_port
  port (
    rst_n_i                                 : in std_logic;
    wb_clk_i                                : in std_logic;
    wb_addr_i                               : in std_logic_vector(3 downto 0);
    wb_data_i                               : in std_logic_vector(31 downto 0);
    wb_data_o                               : out std_logic_vector(31 downto 0);
    wb_cyc_i                                : in std_logic;
    wb_sel_i                                : in std_logic_vector(3 downto 0);
    wb_stb_i                                : in std_logic;
    wb_we_i                                 : in std_logic;
    wb_ack_o                                : out std_logic;
    fs_clk_i                                : in std_logic;
    sys_clk_i                               : in std_logic;
    regs_i                                  : in  t_fmc516_in_registers;
    regs_o                                  : out t_fmc516_out_registers
  );
  end component;

begin

  -- Reset signals and sychronization with positive edge of
  -- respective clock
  sys_rst  <= not(sys_rst_n_i);
  fs_rst_n <= sys_rst_n_i and mmcm_adc_locked;
  --fs_rst   <= not(fs_rst_n);

  -- Reset synchronization with SYS clock domain
  -- Align the reset deassertion to the next clock edge
  cmp_reset_fs_synch : reset_synch
  port map(
    clk_i     		                          => sys_clk_i,
    arst_n_i		                            => sys_rst_n_i,
    rst_n_o      		                        => sys_rst_sync_n
  );

  -- Reset synchronization with FS clock domain (just clock 1
  -- is used for now). Align the reset deassertion to the next
  -- clock edge
  cmp_reset_sys_synch : reset_synch
  port map(
    clk_i     		                          => fs_clk,
    arst_n_i		                            => fs_rst_n,
    rst_n_o      		                        => fs_rst_sync_n
  );

  -----------------------------
  -- Slave adapter
  -----------------------------
  cmp_slave_Adapter : wb_slave_adapter
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
    rst_n_i                                 => sys_rst_n_i,
    master_i                                => wb_slv_adp_out,
    master_o                                => wb_slv_adp_in,
    sl_adr_i                                => resized_addr,
    sl_dat_i                                => wb_dat_i,
    sl_sel_i                                => wb_sel_i,
    sl_cyc_i                                => wb_cyc_i,
    sl_stb_i                                => wb_stb_i,
    sl_we_i                                 => wb_we_i,
    sl_dat_o                                => wb_dat_o,
    sl_ack_o                                => wb_ack_o,
    sl_stall_o                              => wb_stall_o
  );

  -- Decode only the LSB bits. In this case, at most, 13 LSB must be decoded
  -- (if byte addresses) or 11 LSB (if word addressed): 3 bits for internal
  -- wishbone peripheral addressing (register interface, I2C (2x), SPI (2x),
  -- One-Wire (2x)) + 8 bits for each register peripheral space (2^8 registers if
  -- word addressed or 2^6 if byte addressed). We have to consider the biggest
  -- value in order to be possible to select BYTE addressing to this wishbone slave.
  --
  -- By doing this zeroing we avoid the issue related to BYTE -> WORD  conversion
  -- slave addressing (possibly performed by the slave adapter component)
  -- in which a bit in the LSB of the peripheral addressing part (31 - 14 in our case)
  -- is shifted to the internal register adressing part (13 - 0 in our case).
  -- Therefore, possibly changing the these bits!
  -- See wb_fmc516_port.vhd for register bank addresses and.
  resized_addr(12 downto 0)                 <= wb_adr_i(12 downto 0);
  resized_addr(c_wishbone_address_width-1 downto 13)
                                            <= (others => '0');

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
  cmp_fmc516_bus_fanout : xwb_bus_fanout
  generic map (
    g_num_outputs                           => c_num_int_slaves,
    g_bits_per_slave                        => c_num_bits_per_slave, -- 8-bit slave word address slave address
    g_address_granularity                   => WORD,
    g_slave_interface_mode                  => PIPELINED
  )
  port map (
    clk_sys_i                               => sys_clk_i,
    rst_n_i                                 => sys_rst_n_i,
    slave_i                                 => wb_slv_adp_in,
    slave_o                                 => wb_slv_adp_out,
    master_i                                => wb_out,
    master_o                                => wb_in
  );

  -----------------------------
  -- FMC516 Register Wishbone Interface. Word addressed!
  -----------------------------
  --FMC516 register interface is the slave number 0, word addressed
  cmp_wb_fmc516_port : wb_fmc516_port
  port map(
    rst_n_i                                  => sys_rst_n_i,
    clk_sys_i                                => sys_clk_i,
    wb_adr_i                                 => wb_in(0).addr,
    wb_dat_i                                 => wb_in(0).dat,
    wb_dat_o                                 => wb_out(0).dat,
    wb_cyc_i                                 => wb_in(0).cyc,
    wb_sel_i                                 => wb_in(0).sel,
    wb_stb_i                                 => wb_in(0).stb,
    wb_we_i                                  => wb_in(0).we,
    wb_ack_o                                 => wb_out(0).ack,
    wb_stall_o                               => wb_out(0).stall,
    fs_clk_i                                 => fs_clk,
    -- Check if this clock is necessary!
    wb_clk_i                                 => sys_clk_i,
    regs_i                                   => regs_out,
    regs_o                                   => regs_in
  );

  -----------------------------
  -- ADC Interface
  -----------------------------
  cmp_fmc516_adc_iface : fmc516_adc_iface
  generic map(
    g_adc_bits                              => g_adc_bits,
    g_use_clock_chains                      => g_use_clock_chains,
    g_use_data_chains                       => g_use_data_chains,
    g_sim                                   => g_sim
  )
  port map(
    sys_clk_i                               => sys_clk_i,
    sys_rst_n_i                             => sys_rst_n_i,
    sys_clk_200Mhz_i                        => sys_clk_200Mhz_i,

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

    -- Do i need really to worry about the deassertion of async resets?
    -- Generate them outside this module, as this reset is needed by
    -- external logic.
    --
    -- WARNING: just clock 1 is is used for now. If more clocks are used,
    -- we would have to synchronise the other resets to it and map them
    -- here!
    adc_clk0_rst_n_i                        => fs_rst_sync_n,
    adc_clk1_rst_n_i                        => fs_rst_sync_n,
    adc_clk2_rst_n_i                        => fs_rst_sync_n,
    adc_clk3_rst_n_i                        => fs_rst_sync_n,

    -- DDR ADC data channels.
    adc_data_ch0_p_i                        => adc_data_ch0_p_i,
    adc_data_ch0_n_i                        => adc_data_ch0_n_i,
    adc_data_ch1_p_i                        => adc_data_ch1_p_i,
    adc_data_ch1_n_i                        => adc_data_ch1_n_i,
    adc_data_ch2_p_i                        => adc_data_ch2_p_i,
    adc_data_ch2_n_i                        => adc_data_ch2_n_i,
    adc_data_ch3_p_i                        => adc_data_ch3_p_i,
    adc_data_ch3_n_i                        => adc_data_ch3_n_i,

    -----------------------------
    -- ADC Delay signals.
    -----------------------------
    -- Pulse this to update all delay values to the corresponding adc_xxx_dly_val_i
    adc_dly_pulse_i                         => regs_in.adc_ctl_update_dly_o,

    adc_clk0_dly_val_i                      => adc_dly_reg(0).clk_dly_reg,
    adc_clk0_dly_val_o                      => regs_out.ch0_ctl_clk_chain_dly_i,  -- read from clock register delay
    adc_clk1_dly_val_i                      => radc_dly_reg(1).clk_dly_reg,
    adc_clk1_dly_val_o                      => regs_out.ch1_ctl_clk_chain_dly_i,  -- read from clock register delay
    adc_clk2_dly_val_i                      => adc_dly_reg(2).clk_dly_reg,
    adc_clk2_dly_val_o                      => regs_out.ch2_ctl_clk_chain_dly_i,  -- read from clock register delay
    adc_clk3_dly_val_i                      => adc_dly_reg(3).clk_dly_reg,
    adc_clk3_dly_val_o                      => regs_out.ch3_ctl_clk_chain_dly_i,  -- read from clock register delay

    adc_data_ch0_dly_val_i                  => adc_dly_reg(0).data_dly_reg,
    adc_data_ch0_dly_val_o                  => regs_out.ch0_ctl_data_chain_dly_i, -- read from data register delay
    adc_data_ch1_dly_val_i                  => adc_dly_reg(1).data_dly_reg,
    adc_data_ch1_dly_val_o                  => regs_out.ch1_ctl_data_chain_dly_i, -- read from data register delay
    adc_data_ch2_dly_val_i                  => adc_dly_reg(2).data_dly_reg,
    adc_data_ch2_dly_val_o                  => regs_out.ch2_ctl_data_chain_dly_i, -- read from data register delay
    adc_data_ch3_dly_val_i                  => adc_dly_reg(3).data_dly_reg,
    adc_data_ch3_dly_val_o                  => regs_out.ch3_ctl_data_chain_dly_i, -- read from data register delay

    -----------------------------
    -- ADC output signals.
    -----------------------------
    adc_clk_o                               => fs_clk,
    adc_data_ch0_o                          => adc_data_ch0_o,
    adc_data_ch1_o                          => adc_data_ch1_o,
    adc_data_ch2_o                          => adc_data_ch2_o,
    adc_data_ch3_o                          => adc_data_ch3_o,
    adc_data_valid_o                        => adc_data_valid_o,

    -----------------------------
    -- MMCM general signals
    -----------------------------
    mmcm_adc_locked_o                       => mmcm_adc_locked
  );

  adc_clk_o                                 <= fs_clk;

  -----------------------------
  -- Delay regs interface <-> ADC interface.
  -----------------------------
  -- Clock/Data Chain delays

  -- Signal mangling for generate statements
  adc_dly_reg(0).clk_load <= regs_in.ch0_ctl_clk_chain_dly_load_o;
  adc_dly_reg(0).data_load <= regs_in.ch0_ctl_data_chain_dly_load_o;
  adc_dly_reg(0).clk_dly <= regs_in.ch0_ctl_clk_chain_dly_o;
  adc_dly_reg(0).data_dly <= regs_in.ch0_ctl_data_chain_dly_o;

  adc_dly_reg(1).clk_load <= regs_in.ch1_ctl_clk_chain_dly_load_o;
  adc_dly_reg(1).data_load <= regs_in.ch1_ctl_data_chain_dly_load_o;
  adc_dly_reg(1).clk_dly <= regs_in.ch1_ctl_clk_chain_dly_o;
  adc_dly_reg(1).data_dly <= regs_in.ch1_ctl_data_chain_dly_o;

  adc_dly_reg(2).clk_load <= regs_in.ch2_ctl_clk_chain_dly_load_o;
  adc_dly_reg(2).data_load <= regs_in.ch2_ctl_data_chain_dly_load_o;
  adc_dly_reg(2).clk_dly <= regs_in.ch2_ctl_clk_chain_dly_o;
  adc_dly_reg(2).data_dly <= regs_in.ch2_ctl_data_chain_dly_o;

  adc_dly_reg(3).clk_load <= regs_in.ch3_ctl_clk_chain_dly_load_o;
  adc_dly_reg(3).data_load <= regs_in.ch3_ctl_data_chain_dly_load_o;
  adc_dly_reg(3).clk_dly <= regs_in.ch3_ctl_clk_chain_dly_o;
  adc_dly_reg(3).data_dly <= regs_in.ch3_ctl_data_chain_dly_o;

  -- Generate statements for all ADC channels (clock + data chains)
  gen_adc_dly : for i in c_num_channels-1 generate
    p_adc_dly : process (sys_clk_i, sys_rst_sync_n)
    begin
      if sys_rst_sync_n = '0' then
        adc_dly_reg(i).clk_dly_reg <= (others => '0');
        adc_dly_reg(i).data_dly_reg <= (others => '0');
      elsif rising_edge(sys_clk_i) then
        -- write to clock register delay
        if adc_dly_reg(i).clk_load = '1' then
          adc_dly_reg(i).clk_dly_reg <= adc_dly_reg(i).clk_dly;
        end if;

        -- write to data register delay
        if adc_dly_reg(i).data_load = '1' then
          adc_dly_reg(i).data_dly_reg <= adc_dly_reg(i).data_dly;
        end if;
      end if;
    end process;
  end generate;

  -----------------------------
  -- Trigger Interface. Does not do anything yet!
  -----------------------------
  -- Trigger buffers and Synchronization
  cmp_ext_trig_ibufds : ibufds
  generic map(
    IOSTANDARD                           	=> "LVDS_25",
    DIFF_TERM                             => TRUE
  )
  port map (
    O  => m2c_trig,
    I  => m2c_trig_p_i,
    IB => m2c_trig_n_i
  );

  -- External hardware trigger synchronization
  cmp_trig_sync : ext_pulse_sync
  generic map(
    g_min_pulse_width                       => 1,           -- clk_i ticks
    g_clk_frequency                         => 100,         -- MHz
    g_output_polarity                       => '0',         -- positive pulse
    g_output_retrig                         => false,
    g_output_length                         => 1            -- clk_i tick
  )
  port map(
    rst_n_i                                 => fs_rst_n,
    clk_i                                   => fs_clk,
    input_polarity_i                        => regs_in.trig_cfg_hw_trig_pol_o,
    pulse_i                                 => m2c_trig,
    pulse_o                                 => m2c_trig_sync
  );

  -- Output external trigger to other logic. Hardware trigger enable
  trig_hw_o                                 <= m2c_trig_sync and regs_in.trig_cfg_hw_trig_en_o;

  cmp_ext_trig_obufds : obufds
  generic map(
    IOSTANDARD                           	  => "LVDS_25"
  )
  port map (
    O                                       => c2m_trig_p_i,
    OB                                      => c2m_trig_n_i,
    I                                       => c2m_trig,
  );

  -- Input external trigger to FPGA pin
  c2m_trig                                  <= trig_hw_i;

  -----------------------------
  -- LEDs Interface. Output extended pulses of important commands
  -----------------------------

  cmp_led0_extende_pulse : gc_extend_pulse
  generic map (
    -- Input clock = 100MHz
    -- 20000000 clock pulses =  0.2s pulse
    g_width => 20000000
  )
  port (
    clk_i                                   => sys_clk_i
    rst_n_i                                 => sys_rst_n_i,
    -- input pulse (synchronous to clk_i)
    pulse_i                                 => ?,
    -- extended output pulse
    extended_o                              => led0_extd_p
  );

  -- Output extended pulse led from ... or register interface manual led control
  fmc_leds_o(0) <= led0_extd_p or regs_in.fmc_ctl_led_0_o;


  cmp_led1_extende_pulse : gc_extend_pulse
  generic map (
    -- Input clock = 100MHz
    -- 20000000 clock pulses =  0.2s pulse
    g_width => 20000000
  )
  port (
    clk_i                                   => sys_clk_i
    rst_n_i                                 => sys_rst_n_i,
    -- input pulse (synchronous to clk_i)
    pulse_i                                 => ?,
    -- extended output pulse
    extended_o                              => led1_extd_p fmc_leds_o(1)
  );

  -- Output extended pulse led from ... or register interface manual led control
  fmc_leds_o(1) <= led1_extd_p or regs_in.fmc_ctl_led_1_o;

end rtl;