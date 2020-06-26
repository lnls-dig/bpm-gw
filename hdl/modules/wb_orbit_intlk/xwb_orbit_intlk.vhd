------------------------------------------------------------------------------
-- Title      : Wishbone Orbit Interlock Core
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2022-06-12
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Wishbone wrapper for orbit interlock
-------------------------------------------------------------------------------
-- Copyright (c) 2020 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2020-06-02  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Orbit interlock cores
use work.orbit_intlk_pkg.all;
-- BPM cores
use work.bpm_cores_pkg.all;

entity xwb_orbit_intlk is
generic
(
  -- Wishbone
  g_INTERFACE_MODE                           : t_wishbone_interface_mode      := CLASSIC;
  g_ADDRESS_GRANULARITY                      : t_wishbone_address_granularity := WORD;
  g_WITH_EXTRA_WB_REG                        : boolean := false;
  -- Position
  g_ADC_WIDTH                                : natural := 16;
  g_DECIM_WIDTH                              : natural := 32
);
port
(
  -----------------------------
  -- Clocks and resets
  -----------------------------

  rst_n_i                                    : in std_logic;
  clk_i                                      : in std_logic; -- Wishbone clock
  ref_rst_n_i                                : in std_logic;
  ref_clk_i                                  : in std_logic;

  -----------------------------
  -- Wishbone signals
  -----------------------------

  wb_slv_i                                   : in t_wishbone_slave_in;
  wb_slv_o                                   : out t_wishbone_slave_out;

  -----------------------------
  -- Downstream ADC and position signals
  -----------------------------

  fs_clk_ds_i                                : in std_logic;

  adc_ds_ch0_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch1_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch2_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_ch3_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_ds_tag_i                               : in std_logic_vector(0 downto 0) := (others => '0');
  adc_ds_swap_valid_i                        : in std_logic := '0';

  decim_ds_pos_x_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_y_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_q_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_sum_i                         : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_ds_pos_valid_i                       : in std_logic;

  -----------------------------
  -- Upstream ADC and position signals
  -----------------------------

  fs_clk_us_i                                : in std_logic;

  adc_us_ch0_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch1_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch2_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_ch3_swap_i                          : in std_logic_vector(g_ADC_WIDTH-1 downto 0) := (others => '0');
  adc_us_tag_i                               : in std_logic_vector(0 downto 0) := (others => '0');
  adc_us_swap_valid_i                        : in std_logic := '0';

  decim_us_pos_x_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_y_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_q_i                           : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_sum_i                         : in std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  decim_us_pos_valid_i                       : in std_logic;

  -----------------------------
  -- Interlock outputs
  -----------------------------
  intlk_trans_bigger_x_o                     : out std_logic;
  intlk_trans_bigger_y_o                     : out std_logic;

  intlk_trans_bigger_ltc_x_o                 : out std_logic;
  intlk_trans_bigger_ltc_y_o                 : out std_logic;

  intlk_trans_bigger_o                       : out std_logic;

  -- only cleared when intlk_trans_clr_i is asserted
  intlk_trans_ltc_o                          : out std_logic;
  -- conditional to intlk_trans_en_i
  intlk_trans_o                              : out std_logic;

  intlk_ang_bigger_x_o                       : out std_logic;
  intlk_ang_bigger_y_o                       : out std_logic;

  intlk_ang_bigger_ltc_x_o                   : out std_logic;
  intlk_ang_bigger_ltc_y_o                   : out std_logic;

  intlk_ang_bigger_o                         : out std_logic;

  -- only cleared when intlk_ang_clr_i is asserted
  intlk_ang_ltc_o                            : out std_logic;
  -- conditional to intlk_ang_en_i
  intlk_ang_o                                : out std_logic;

  -- only cleared when intlk_clr_i is asserted
  intlk_ltc_o                                : out std_logic;
  -- conditional to intlk_en_i
  intlk_o                                    : out std_logic
);
end xwb_orbit_intlk;

architecture rtl of xwb_orbit_intlk is

begin

  cmp_wb_orbit_intlk : wb_orbit_intlk
  generic map
  (
    -- Wishbone
    g_INTERFACE_MODE                           => g_INTERFACE_MODE,
    g_ADDRESS_GRANULARITY                      => g_ADDRESS_GRANULARITY,
    g_WITH_EXTRA_WB_REG                        => g_WITH_EXTRA_WB_REG,
    -- Position
    g_ADC_WIDTH                                => g_ADC_WIDTH,
    g_DECIM_WIDTH                              => g_DECIM_WIDTH
  )
  port map
  (
    -----------------------------
    -- Clocks and resets
    -----------------------------

    rst_n_i                                   => rst_n_i,
    clk_i                                     => clk_i,
    ref_rst_n_i                               => ref_rst_n_i,
    ref_clk_i                                 => ref_clk_i,

    -----------------------------
    -- Wishbone signals
    -----------------------------

    wb_adr_i                                  => wb_slv_i.adr,
    wb_dat_i                                  => wb_slv_i.dat,
    wb_dat_o                                  => wb_slv_o.dat,
    wb_sel_i                                  => wb_slv_i.sel,
    wb_we_i                                   => wb_slv_i.we,
    wb_cyc_i                                  => wb_slv_i.cyc,
    wb_stb_i                                  => wb_slv_i.stb,
    wb_ack_o                                  => wb_slv_o.ack,
    wb_stall_o                                => wb_slv_o.stall,

    -----------------------------
    -- Downstream ADC and position signals
    -----------------------------

    fs_clk_ds_i                               => fs_clk_ds_i,

    adc_ds_ch0_swap_i                         => adc_ds_ch0_swap_i,
    adc_ds_ch1_swap_i                         => adc_ds_ch1_swap_i,
    adc_ds_ch2_swap_i                         => adc_ds_ch2_swap_i,
    adc_ds_ch3_swap_i                         => adc_ds_ch3_swap_i,
    adc_ds_tag_i                              => adc_ds_tag_i,
    adc_ds_swap_valid_i                       => adc_ds_swap_valid_i,

    decim_ds_pos_x_i                          => decim_ds_pos_x_i,
    decim_ds_pos_y_i                          => decim_ds_pos_y_i,
    decim_ds_pos_q_i                          => decim_ds_pos_q_i,
    decim_ds_pos_sum_i                        => decim_ds_pos_sum_i,
    decim_ds_pos_valid_i                      => decim_ds_pos_valid_i,

    -----------------------------
    -- Upstream ADC and position signals
    -----------------------------

    fs_clk_us_i                               => fs_clk_us_i,

    adc_us_ch0_swap_i                         => adc_us_ch0_swap_i,
    adc_us_ch1_swap_i                         => adc_us_ch1_swap_i,
    adc_us_ch2_swap_i                         => adc_us_ch2_swap_i,
    adc_us_ch3_swap_i                         => adc_us_ch3_swap_i,
    adc_us_tag_i                              => adc_us_tag_i,
    adc_us_swap_valid_i                       => adc_us_swap_valid_i,

    decim_us_pos_x_i                          => decim_us_pos_x_i,
    decim_us_pos_y_i                          => decim_us_pos_y_i,
    decim_us_pos_q_i                          => decim_us_pos_q_i,
    decim_us_pos_sum_i                        => decim_us_pos_sum_i,
    decim_us_pos_valid_i                      => decim_us_pos_valid_i,

    -----------------------------
    -- Interlock outputs
    -----------------------------
    intlk_trans_bigger_x_o                    => intlk_trans_bigger_x_o,
    intlk_trans_bigger_y_o                    => intlk_trans_bigger_y_o,

    intlk_trans_bigger_ltc_x_o                => intlk_trans_bigger_ltc_x_o,
    intlk_trans_bigger_ltc_y_o                => intlk_trans_bigger_ltc_y_o,

    intlk_trans_bigger_o                      => intlk_trans_bigger_o,

    -- only cleared when intlk_trans_clr_i is
    intlk_trans_ltc_o                         => intlk_trans_ltc_o,
    -- conditional to intlk_trans_en_i
    intlk_trans_o                             => intlk_trans_o,

    intlk_ang_bigger_x_o                      => intlk_ang_bigger_x_o,
    intlk_ang_bigger_y_o                      => intlk_ang_bigger_y_o,

    intlk_ang_bigger_ltc_x_o                  => intlk_ang_bigger_ltc_x_o,
    intlk_ang_bigger_ltc_y_o                  => intlk_ang_bigger_ltc_y_o,

    intlk_ang_bigger_o                        => intlk_ang_bigger_o,

    -- only cleared when intlk_ang_clr_i is as
    intlk_ang_ltc_o                           => intlk_ang_ltc_o,
    -- conditional to intlk_ang_en_i
    intlk_ang_o                               => intlk_ang_o,

    -- only cleared when intlk_clr_i is assert
    intlk_ltc_o                               => intlk_ltc_o,
    -- conditional to intlk_en_i
    intlk_o                                   => intlk_o
  );

end rtl;
