------------------------------------------------------------------------------
-- Title      : Wishbone FMC130m_4ch Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-29-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top Module with records for the FMC516 ADC board interface from
--  Curtis Wright.
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
use work.wb_stream_generic_pkg.all;
-- FMC ADC package
use work.fmc_adc_pkg.all;

entity xwb_fmc130m_4ch is
generic
(
  -- The only supported values are VIRTEX6 and 7SERIES
  g_fpga_device                             : string := "VIRTEX6";
  g_delay_type                              : string := "VARIABLE";
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_with_extra_wb_reg                       : boolean := false;
  g_adc_clk_period_values                   : t_clk_values_array := default_adc_clk_period_values;
  g_use_clk_chains                          : t_clk_use_chain := default_clk_use_chain;
  g_with_bufio_clk_chains                   : t_clk_use_bufio_chain := default_clk_use_bufio_chain;
  g_with_bufr_clk_chains                    : t_clk_use_bufr_chain := default_clk_use_bufr_chain;
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

  wb_slv_i                                  : in t_wishbone_slave_in;
  wb_slv_o                                  : out t_wishbone_slave_out;

  -----------------------------
  -- External ports
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
  adc_rst2x_n_o                             : out std_logic_vector(c_num_adc_channels-1 downto 0);
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
  fmc_pll_status_o                          : out std_logic;

  -----------------------------
  -- Wishbone Streaming Interface Source
  -----------------------------
  wbs_source_i                              : in t_wbs_source_in16_array(c_num_adc_channels-1 downto 0);
  wbs_source_o                              : out t_wbs_source_out16_array(c_num_adc_channels-1 downto 0);

  adc_dly_debug_o                          : out t_adc_fn_dly_array(c_num_adc_channels-1 downto 0);

  fifo_debug_valid_o                       : out std_logic_vector(c_num_adc_channels-1 downto 0);
  fifo_debug_full_o                        : out std_logic_vector(c_num_adc_channels-1 downto 0);
  fifo_debug_empty_o                       : out std_logic_vector(c_num_adc_channels-1 downto 0)
);
end xwb_fmc130m_4ch;

architecture rtl of xwb_fmc130m_4ch is

  signal wbs_adr_int                        : std_logic_vector(c_num_adc_channels*c_wbs_adr4_width-1 downto 0);
  signal wbs_dat_int                        : std_logic_vector(c_num_adc_channels*c_wbs_dat16_width-1 downto 0);
  signal wbs_cyc_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_stb_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_we_int                         : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_sel_int                        : std_logic_vector(c_num_adc_channels*c_wbs_sel16_width-1 downto 0);
  signal wbs_ack_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_stall_int                      : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_err_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);
  signal wbs_rty_int                        : std_logic_vector(c_num_adc_channels-1 downto 0);

begin

  cmp_wb_fmc130m_4ch : wb_fmc130m_4ch
  generic map (
      -- The only supported values are VIRTEX6 and 7SERIES
    g_fpga_device                             => g_fpga_device,
    g_delay_type                              => g_delay_type,
    g_interface_mode                          => g_interface_mode,
    g_address_granularity                     => g_address_granularity,
    g_with_extra_wb_reg                       => g_with_extra_wb_reg,
    g_adc_clk_period_values                   => g_adc_clk_period_values,
    g_use_clk_chains                          => g_use_clk_chains,
    g_with_bufio_clk_chains                   => g_with_bufio_clk_chains,
    g_with_bufr_clk_chains                    => g_with_bufr_clk_chains,
    g_use_data_chains                         => g_use_data_chains,
    g_map_clk_data_chains                     => g_map_clk_data_chains,
    g_ref_clk                                 => g_ref_clk,
    g_packet_size                             => g_packet_size,
    g_with_idelayctrl                         => g_with_idelayctrl,
    g_sim                                     => g_sim
  )
  port map
  (
    sys_clk_i                                 => sys_clk_i,
    sys_rst_n_i                               => sys_rst_n_i,
    sys_clk_200Mhz_i                          => sys_clk_200Mhz_i,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  => wb_slv_i.adr,
    wb_dat_i                                  => wb_slv_i.dat,
    wb_dat_o                                  => wb_slv_o.dat,
    wb_sel_i                                  => wb_slv_i.sel,
    wb_we_i                                   => wb_slv_i.we,
    wb_cyc_i                                  => wb_slv_i.cyc,
    wb_stb_i                                  => wb_slv_i.stb,
    wb_ack_o                                  => wb_slv_o.ack,
    wb_err_o                                  => wb_slv_o.err,
    wb_rty_o                                  => wb_slv_o.rty,
    wb_stall_o                                => wb_slv_o.stall,

    -----------------------------
    -- External ports
    -----------------------------

    -- ADC LTC2208 interface
    fmc_adc_pga_o                             => fmc_adc_pga_o,
    fmc_adc_shdn_o                            => fmc_adc_shdn_o,
    fmc_adc_dith_o                            => fmc_adc_dith_o,
    fmc_adc_rand_o                            => fmc_adc_rand_o,

    -- ADC0 LTC2208
    fmc_adc0_clk_i                            => fmc_adc0_clk_i,
    fmc_adc0_data_i                           => fmc_adc0_data_i,
    fmc_adc0_of_i                             => fmc_adc0_of_i,

    -- ADC1 LTC2208
    fmc_adc1_clk_i                            => fmc_adc1_clk_i,
    fmc_adc1_data_i                           => fmc_adc1_data_i,
    fmc_adc1_of_i                             => fmc_adc1_of_i,

    -- ADC2 LTC2208
    fmc_adc2_clk_i                            => fmc_adc2_clk_i,
    fmc_adc2_data_i                           => fmc_adc2_data_i,
    fmc_adc2_of_i                             => fmc_adc2_of_i,

    -- ADC3 LTC2208
    fmc_adc3_clk_i                            => fmc_adc3_clk_i,
    fmc_adc3_data_i                           => fmc_adc3_data_i,
    fmc_adc3_of_i                             => fmc_adc3_of_i,

    -- FMC General Status
    fmc_prsnt_i                               => fmc_prsnt_i,
    fmc_pg_m2c_i                              => fmc_pg_m2c_i,
    --fmc_clk_dir_i                           : in std_logic, -- not supported on Kintex7 KC705 board

    -- Trigger
    fmc_trig_dir_o                            => fmc_trig_dir_o,
    fmc_trig_term_o                           => fmc_trig_term_o,
    fmc_trig_val_p_b                          => fmc_trig_val_p_b,
    fmc_trig_val_n_b                          => fmc_trig_val_n_b,

    -- Si571 clock gen
    si571_scl_pad_b                           => si571_scl_pad_b,
    si571_sda_pad_b                           => si571_sda_pad_b,
    fmc_si571_oe_o                            => fmc_si571_oe_o,

    -- AD9510 clock distribution PLL
    spi_ad9510_cs_o                           => spi_ad9510_cs_o,
    spi_ad9510_sclk_o                         => spi_ad9510_sclk_o,
    spi_ad9510_mosi_o                         => spi_ad9510_mosi_o,
    spi_ad9510_miso_i                         => spi_ad9510_miso_i,

    fmc_pll_function_o                        => fmc_pll_function_o,
    fmc_pll_status_i                          => fmc_pll_status_i,

    -- AD9510 clock copy
    fmc_fpga_clk_p_i                          => fmc_fpga_clk_p_i,
    fmc_fpga_clk_n_i                          => fmc_fpga_clk_n_i,

    -- Clock reference selection (TS3USB221)
    fmc_clk_sel_o                             => fmc_clk_sel_o,

    -- EEPROM
    eeprom_scl_pad_b                          => eeprom_scl_pad_b,
    eeprom_sda_pad_b                          => eeprom_sda_pad_b,

    -- Temperature monitor
    -- LM75AIMM
    lm75_scl_pad_b                            => lm75_scl_pad_b,
    lm75_sda_pad_b                            => lm75_sda_pad_b,

    fmc_lm75_temp_alarm_i                     => fmc_lm75_temp_alarm_i,

    -- FMC LEDs
    fmc_led1_o                                => fmc_led1_o,
    fmc_led2_o                                => fmc_led2_o,
    fmc_led3_o                                => fmc_led3_o,

    -----------------------------
    -- Optional external reference clock ports
    -----------------------------
    fmc_ext_ref_clk_i                        => fmc_ext_ref_clk_i,
    fmc_ext_ref_clk2x_i                      => fmc_ext_ref_clk2x_i,
    fmc_ext_ref_mmcm_locked_i                => fmc_ext_ref_mmcm_locked_i,

    -----------------------------
    -- ADC output signals. Continuous flow
    -----------------------------
    adc_clk_o                                 => adc_clk_o,
    adc_clk2x_o                               => adc_clk2x_o,
    adc_rst_n_o                               => adc_rst_n_o,
    adc_rst2x_n_o                             => adc_rst2x_n_o,
    adc_data_o                                => adc_data_o,
    adc_data_valid_o                          => adc_data_valid_o,

    -----------------------------
    -- General ADC output signals and status
    -----------------------------
    -- Trigger to other FPGA logic
    trig_hw_o                                 => trig_hw_o,
    trig_hw_i                                 => trig_hw_i,

    -- General board status
    fmc_mmcm_lock_o                           => fmc_mmcm_lock_o,
    fmc_pll_status_o                          => fmc_pll_status_o,

    -----------------------------
    -- Wishbone Streaming Interface Source
    -----------------------------
    wbs_adr_o                                => wbs_adr_int,
    wbs_dat_o                                => wbs_dat_int,
    wbs_cyc_o                                => wbs_cyc_int,
    wbs_stb_o                                => wbs_stb_int,
    wbs_we_o                                 => wbs_we_int,
    wbs_sel_o                                => wbs_sel_int,
    wbs_ack_i                                => wbs_ack_int,
    wbs_stall_i                              => wbs_stall_int,
    wbs_err_i                                => wbs_err_int,
    wbs_rty_i                                => wbs_rty_int,

    adc_dly_debug_o                          => adc_dly_debug_o,

    fifo_debug_valid_o                       => fifo_debug_valid_o,
    fifo_debug_full_o                        => fifo_debug_full_o,
    fifo_debug_empty_o                       => fifo_debug_empty_o
  );

  gen_wbs_interfaces : for i in 0 to c_num_adc_channels-1 generate
    gen_wbs_interfaces_ch : if g_use_data_chains(i) = '1' generate
      wbs_ack_int(i)                            <=  wbs_source_i(i).ack;
      wbs_stall_int(i)                          <=  wbs_source_i(i).stall;
      wbs_err_int(i)                            <=  wbs_source_i(i).err;
      wbs_rty_int(i)                            <=  wbs_source_i(i).rty;

      wbs_source_o(i).adr                       <= wbs_adr_int(c_wbs_adr4_width*(i+1)-1 downto
                                                      c_wbs_adr4_width*i);
      wbs_source_o(i).dat                       <= wbs_dat_int(c_wbs_dat16_width*(i+1)-1 downto
                                                      c_wbs_dat16_width*i);
      wbs_source_o(i).sel                       <= wbs_sel_int(c_wbs_sel16_width*(i+1)-1 downto
                                                      c_wbs_sel16_width*i);
      wbs_source_o(i).cyc                       <= wbs_cyc_int(i);
      wbs_source_o(i).stb                       <= wbs_stb_int(i);
      wbs_source_o(i).we                        <= wbs_we_int(i);
    end generate;
  end generate;

end rtl;
