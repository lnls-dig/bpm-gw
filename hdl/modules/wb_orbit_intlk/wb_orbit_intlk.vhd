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
-- Regs
use work.orbit_intlk_wbgen2_pkg.all;

entity wb_orbit_intlk is
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

  wb_adr_i                                   : in  std_logic_vector(c_WISHBONE_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  wb_dat_i                                   : in  std_logic_vector(c_WISHBONE_DATA_WIDTH-1 downto 0) := (others => '0');
  wb_dat_o                                   : out std_logic_vector(c_WISHBONE_DATA_WIDTH-1 downto 0);
  wb_sel_i                                   : in  std_logic_vector(c_WISHBONE_DATA_WIDTH/8-1 downto 0) := (others => '0');
  wb_we_i                                    : in  std_logic := '0';
  wb_cyc_i                                   : in  std_logic := '0';
  wb_stb_i                                   : in  std_logic := '0';
  wb_ack_o                                   : out std_logic;
  wb_stall_o                                 : out std_logic;

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

  -- only cleared when intlk_trans_clr_i is asserted
  intlk_trans_bigger_ltc_x_o                 : out std_logic;
  intlk_trans_bigger_ltc_y_o                 : out std_logic;

  intlk_trans_bigger_any_o                   : out std_logic;

  -- only cleared when intlk_trans_clr_i is asserted
  intlk_trans_bigger_ltc_o                   : out std_logic;
  -- conditional to intlk_trans_en_i
  intlk_trans_bigger_o                       : out std_logic;

  intlk_trans_smaller_x_o                    : out std_logic;
  intlk_trans_smaller_y_o                    : out std_logic;

  -- only cleared when intlk_trans_clr_i is asserted
  intlk_trans_smaller_ltc_x_o                : out std_logic;
  intlk_trans_smaller_ltc_y_o                : out std_logic;

  intlk_trans_smaller_any_o                  : out std_logic;

  -- only cleared when intlk_trans_clr_i is asserted
  intlk_trans_smaller_ltc_o                  : out std_logic;
  -- conditional to intlk_trans_en_i
  intlk_trans_smaller_o                      : out std_logic;

  intlk_ang_bigger_x_o                       : out std_logic;
  intlk_ang_bigger_y_o                       : out std_logic;

  intlk_ang_bigger_ltc_x_o                   : out std_logic;
  intlk_ang_bigger_ltc_y_o                   : out std_logic;

  intlk_ang_bigger_any_o                     : out std_logic;

  -- only cleared when intlk_ang_clr_i is asserted
  intlk_ang_bigger_ltc_o                     : out std_logic;
  -- conditional to intlk_ang_en_i
  intlk_ang_bigger_o                         : out std_logic;

  intlk_ang_smaller_x_o                      : out std_logic;
  intlk_ang_smaller_y_o                      : out std_logic;

  intlk_ang_smaller_ltc_x_o                  : out std_logic;
  intlk_ang_smaller_ltc_y_o                  : out std_logic;

  intlk_ang_smaller_any_o                    : out std_logic;

  -- only cleared when intlk_ang_clr_i is asserted
  intlk_ang_smaller_ltc_o                    : out std_logic;
  -- conditional to intlk_ang_en_i
  intlk_ang_smaller_o                        : out std_logic;

  -- only cleared when intlk_clr_i is asserted
  intlk_ltc_o                                : out std_logic;
  -- conditional to intlk_en_i
  intlk_o                                    : out std_logic
);
end wb_orbit_intlk;

architecture rtl of wb_orbit_intlk is

  ---------------------------------------------------------
  --                     Constants                       --
  ---------------------------------------------------------
  constant c_PERIPH_ADDR_SIZE               : natural := 4+2;

  constant c_INTLK_LMT_WIDTH                : natural := 32;

  -----------------------------
  -- Wishbone Register Interface signals
  -----------------------------
  -- wb_orbit_intlk reg structure
  signal regs_in                            : t_orbit_intlk_in_registers;
  signal regs_out                           : t_orbit_intlk_out_registers;

  -----------------------------
  -- Wishbone slave adapter signals/structures
  -----------------------------
  signal wb_slv_adp_out                     : t_wishbone_master_out;
  signal wb_slv_adp_in                      : t_wishbone_master_in;
  signal resized_addr                       : std_logic_vector(c_WISHBONE_ADDRESS_WIDTH-1 downto 0);

  -----------------------------
  -- Orbit Interlock signals
  -----------------------------
  signal intlk_en_reg                       : std_logic;
  signal intlk_clr_reg                      : std_logic;
  signal intlk_min_sum_en_reg               : std_logic;
  signal intlk_min_sum_reg                  : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);
  signal intlk_trans_en_reg                 : std_logic;
  signal intlk_trans_clr_reg                : std_logic;
  signal intlk_trans_max_x_reg              : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);
  signal intlk_trans_max_y_reg              : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);
  signal intlk_trans_min_x_reg              : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);
  signal intlk_trans_min_y_reg              : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);
  signal intlk_ang_en_reg                   : std_logic;
  signal intlk_ang_clr_reg                  : std_logic;
  signal intlk_ang_max_x_reg                : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);
  signal intlk_ang_max_y_reg                : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);
  signal intlk_ang_min_x_reg                : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);
  signal intlk_ang_min_y_reg                : std_logic_vector(c_INTLK_LMT_WIDTH-1 downto 0);

  signal intlk_trans_bigger_x               : std_logic;
  signal intlk_trans_bigger_y               : std_logic;
  signal intlk_trans_bigger_ltc_x           : std_logic;
  signal intlk_trans_bigger_ltc_y           : std_logic;
  signal intlk_trans_bigger_any             : std_logic;
  signal intlk_trans_bigger_ltc             : std_logic;
  signal intlk_trans_bigger                 : std_logic;

  signal intlk_trans_smaller_x              : std_logic;
  signal intlk_trans_smaller_y              : std_logic;
  signal intlk_trans_smaller_ltc_x          : std_logic;
  signal intlk_trans_smaller_ltc_y          : std_logic;
  signal intlk_trans_smaller_any            : std_logic;
  signal intlk_trans_smaller_ltc            : std_logic;
  signal intlk_trans_smaller                : std_logic;

  signal intlk_trans_x_diff                 : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal intlk_trans_y_diff                 : std_logic_vector(g_DECIM_WIDTH-1 downto 0);

  signal intlk_ang_bigger_x                 : std_logic;
  signal intlk_ang_bigger_y                 : std_logic;
  signal intlk_ang_bigger_ltc_x             : std_logic;
  signal intlk_ang_bigger_ltc_y             : std_logic;
  signal intlk_ang_bigger_any               : std_logic;
  signal intlk_ang_bigger_ltc               : std_logic;
  signal intlk_ang_bigger                   : std_logic;

  signal intlk_ang_smaller_x                : std_logic;
  signal intlk_ang_smaller_y                : std_logic;
  signal intlk_ang_smaller_ltc_x            : std_logic;
  signal intlk_ang_smaller_ltc_y            : std_logic;
  signal intlk_ang_smaller_any              : std_logic;
  signal intlk_ang_smaller_ltc              : std_logic;
  signal intlk_ang_smaller                  : std_logic;

  signal intlk_ang_x_diff                   : std_logic_vector(g_DECIM_WIDTH-1 downto 0);
  signal intlk_ang_y_diff                   : std_logic_vector(g_DECIM_WIDTH-1 downto 0);

  signal intlk                              : std_logic;
  signal intlk_ltc                          : std_logic;

  component wb_orbit_intlk_regs
  port (
    rst_n_i               : in     std_logic;
    clk_sys_i             : in     std_logic;
    wb_adr_i              : in     std_logic_vector(3 downto 0);
    wb_dat_i              : in     std_logic_vector(31 downto 0);
    wb_dat_o              : out    std_logic_vector(31 downto 0);
    wb_cyc_i              : in     std_logic;
    wb_sel_i              : in     std_logic_vector(3 downto 0);
    wb_stb_i              : in     std_logic;
    wb_we_i               : in     std_logic;
    wb_ack_o              : out    std_logic;
    wb_stall_o            : out    std_logic;
    fs_clk_i              : in     std_logic;
    regs_i                : in     t_orbit_intlk_in_registers;
    regs_o                : out    t_orbit_intlk_out_registers
  );
  end component;

begin

  -----------------------------
  -- Slave adapter for Wishbone Register Interface
  -----------------------------
  cmp_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                     => true,
    g_master_mode                           => PIPELINED,
    g_master_granularity                    => WORD,
    g_slave_use_struct                      => false,
    g_slave_mode                            => g_INTERFACE_MODE,
    g_slave_granularity                     => g_ADDRESS_GRANULARITY
  )
  port map (
    clk_sys_i                               => clk_i,
    rst_n_i                                 => rst_n_i,
    master_i                                => wb_slv_adp_in,
    master_o                                => wb_slv_adp_out,
    sl_adr_i                                => resized_addr,
    sl_dat_i                                => wb_dat_i,
    sl_sel_i                                => wb_sel_i,
    sl_cyc_i                                => wb_cyc_i,
    sl_stb_i                                => wb_stb_i,
    sl_we_i                                 => wb_we_i,
    sl_dat_o                                => wb_dat_o,
    sl_ack_o                                => wb_ack_o,
    sl_rty_o                                => open,
    sl_err_o                                => open,
    sl_stall_o                              => wb_stall_o
  );

  -- See wb_orbit_intlk_port.vhd for register bank addresses.
  resized_addr(c_periph_addr_size-1 downto 0) <= wb_adr_i(c_periph_addr_size-1 downto 0);
  resized_addr(c_wishbone_address_width-1 downto c_PERIPH_ADDR_SIZE) <= (others => '0');

  -- Register Bank / Wishbone Interface
  cmp_wb_orbit_intlk_regs : wb_orbit_intlk_regs
  port map (
    rst_n_i                                 => rst_n_i,
    clk_sys_i                               => clk_i,
    wb_adr_i                                => wb_slv_adp_out.adr(3 downto 0),
    wb_dat_i                                => wb_slv_adp_out.dat,
    wb_dat_o                                => wb_slv_adp_in.dat,
    wb_cyc_i                                => wb_slv_adp_out.cyc,
    wb_sel_i                                => wb_slv_adp_out.sel,
    wb_stb_i                                => wb_slv_adp_out.stb,
    wb_we_i                                 => wb_slv_adp_out.we,
    wb_ack_o                                => wb_slv_adp_in.ack,
    wb_stall_o                              => wb_slv_adp_in.stall,
    fs_clk_i                                => ref_clk_i,
    regs_i                                  => regs_in,
    regs_o                                  => regs_out
  );

  -- Registers assignment
  intlk_en_reg                  <= regs_out.ctrl_en_o;
  intlk_clr_reg                 <= regs_out.ctrl_clr_o;
  intlk_min_sum_en_reg          <= regs_out.ctrl_min_sum_en_o;
  intlk_min_sum_reg             <= regs_out.min_sum_o;

  intlk_trans_en_reg            <= regs_out.ctrl_trans_en_o;
  intlk_trans_clr_reg           <= regs_out.ctrl_trans_clr_o;
  intlk_trans_max_x_reg         <= regs_out.trans_max_x_o;
  intlk_trans_max_y_reg         <= regs_out.trans_max_y_o;
  intlk_trans_min_x_reg         <= regs_out.trans_min_x_o;
  intlk_trans_min_y_reg         <= regs_out.trans_min_y_o;
  intlk_ang_en_reg              <= regs_out.ctrl_ang_en_o;
  intlk_ang_clr_reg             <= regs_out.ctrl_ang_clr_o;
  intlk_ang_max_x_reg           <= regs_out.ang_max_x_o;
  intlk_ang_max_y_reg           <= regs_out.ang_max_y_o;
  intlk_ang_min_x_reg           <= regs_out.ang_min_x_o;
  intlk_ang_min_y_reg           <= regs_out.ang_min_y_o;

  regs_in.sts_trans_bigger_x_i      <= intlk_trans_bigger_x;
  regs_in.sts_trans_bigger_y_i      <= intlk_trans_bigger_y;
  regs_in.sts_trans_bigger_ltc_x_i  <= intlk_trans_bigger_ltc_x;
  regs_in.sts_trans_bigger_ltc_y_i  <= intlk_trans_bigger_ltc_y;
  regs_in.sts_trans_bigger_any_i    <= intlk_trans_bigger_any;
  regs_in.sts_trans_bigger_ltc_i    <= intlk_trans_bigger_ltc;
  regs_in.sts_trans_bigger_i        <= intlk_trans_bigger;

  regs_in.sts_trans_smaller_x_i     <= intlk_trans_smaller_x;
  regs_in.sts_trans_smaller_y_i     <= intlk_trans_smaller_y;
  regs_in.sts_trans_smaller_ltc_x_i <= intlk_trans_smaller_ltc_x;
  regs_in.sts_trans_smaller_ltc_y_i <= intlk_trans_smaller_ltc_y;
  regs_in.sts_trans_smaller_any_i   <= intlk_trans_smaller_any;
  regs_in.sts_trans_smaller_ltc_i   <= intlk_trans_smaller_ltc;
  regs_in.sts_trans_smaller_i       <= intlk_trans_smaller;

  regs_in.sts_ang_bigger_x_i        <= intlk_ang_bigger_x;
  regs_in.sts_ang_bigger_y_i        <= intlk_ang_bigger_y;
  regs_in.sts_ang_bigger_ltc_x_i    <= intlk_ang_bigger_ltc_x;
  regs_in.sts_ang_bigger_ltc_y_i    <= intlk_ang_bigger_ltc_y;
  regs_in.sts_ang_bigger_any_i      <= intlk_ang_bigger_any;
  regs_in.sts_ang_bigger_ltc_i      <= intlk_ang_bigger_ltc;
  regs_in.sts_ang_bigger_i          <= intlk_ang_bigger;

  regs_in.sts_ang_smaller_x_i       <= intlk_ang_smaller_x;
  regs_in.sts_ang_smaller_y_i       <= intlk_ang_smaller_y;
  regs_in.sts_ang_smaller_ltc_x_i   <= intlk_ang_smaller_ltc_x;
  regs_in.sts_ang_smaller_ltc_y_i   <= intlk_ang_smaller_ltc_y;
  regs_in.sts_ang_smaller_any_i     <= intlk_ang_smaller_any;
  regs_in.sts_ang_smaller_ltc_i     <= intlk_ang_smaller_ltc;
  regs_in.sts_ang_smaller_i         <= intlk_ang_smaller;

  regs_in.sts_intlk_i               <= intlk;
  regs_in.sts_intlk_ltc_i           <= intlk_ltc;

  regs_in.trans_x_diff_i            <= intlk_trans_x_diff;
  regs_in.trans_y_diff_i            <= intlk_trans_y_diff;
  regs_in.ang_x_diff_i              <= intlk_ang_x_diff;
  regs_in.ang_y_diff_i              <= intlk_ang_y_diff;

  -- Unused wishbone signals
  wb_slv_adp_in.err                         <= '0';
  wb_slv_adp_in.rty                         <= '0';

  cmp_orbit_intlk : orbit_intlk
  generic map
  (
    g_ADC_WIDTH                                => g_ADC_WIDTH,
    g_DECIM_WIDTH                              => g_DECIM_WIDTH,
    g_INTLK_LMT_WIDTH                          => c_INTLK_LMT_WIDTH
  )
  port map
  (
    -----------------------------
    -- Clocks and resets
    -----------------------------

    ref_rst_n_i                                => ref_rst_n_i,
    ref_clk_i                                  => ref_clk_i,

    -----------------------------
    -- Interlock enable and limits signals
    -----------------------------

    intlk_en_i                                 => intlk_en_reg,
    intlk_clr_i                                => intlk_clr_reg,
    -- Minimum threshold interlock on/off
    intlk_min_sum_en_i                         => intlk_min_sum_en_reg,
    -- Minimum threshold to interlock
    intlk_min_sum_i                            => intlk_min_sum_reg,
    -- Translation interlock on/off
    intlk_trans_en_i                           => intlk_trans_en_reg,
    -- Translation interlock clear
    intlk_trans_clr_i                          => intlk_trans_clr_reg,
    intlk_trans_max_x_i                        => intlk_trans_max_x_reg,
    intlk_trans_max_y_i                        => intlk_trans_max_y_reg,
    intlk_trans_min_x_i                        => intlk_trans_min_x_reg,
    intlk_trans_min_y_i                        => intlk_trans_min_y_reg,
    -- Angular interlock on/off
    intlk_ang_en_i                             => intlk_ang_en_reg,
    -- Angular interlock clear
    intlk_ang_clr_i                            => intlk_ang_clr_reg,
    intlk_ang_max_x_i                          => intlk_ang_max_x_reg,
    intlk_ang_max_y_i                          => intlk_ang_max_y_reg,
    intlk_ang_min_x_i                          => intlk_ang_min_x_reg,
    intlk_ang_min_y_i                          => intlk_ang_min_y_reg,

    -----------------------------
    -- Downstream ADC and position signals
    -----------------------------
    fs_clk_ds_i                                => fs_clk_ds_i,

    adc_ds_ch0_swap_i                          => adc_ds_ch0_swap_i,
    adc_ds_ch1_swap_i                          => adc_ds_ch1_swap_i,
    adc_ds_ch2_swap_i                          => adc_ds_ch2_swap_i,
    adc_ds_ch3_swap_i                          => adc_ds_ch3_swap_i,
    adc_ds_tag_i                               => adc_ds_tag_i,
    adc_ds_swap_valid_i                        => adc_ds_swap_valid_i,

    decim_ds_pos_x_i                           => decim_ds_pos_x_i,
    decim_ds_pos_y_i                           => decim_ds_pos_y_i,
    decim_ds_pos_q_i                           => decim_ds_pos_q_i,
    decim_ds_pos_sum_i                         => decim_ds_pos_sum_i,
    decim_ds_pos_valid_i                       => decim_ds_pos_valid_i,

    -----------------------------
    -- Upstream ADC and position signals
    -----------------------------

    fs_clk_us_i                                => fs_clk_us_i,

    adc_us_ch0_swap_i                          => adc_us_ch0_swap_i,
    adc_us_ch1_swap_i                          => adc_us_ch1_swap_i,
    adc_us_ch2_swap_i                          => adc_us_ch2_swap_i,
    adc_us_ch3_swap_i                          => adc_us_ch3_swap_i,
    adc_us_tag_i                               => adc_us_tag_i,
    adc_us_swap_valid_i                        => adc_us_swap_valid_i,

    decim_us_pos_x_i                           => decim_us_pos_x_i,
    decim_us_pos_y_i                           => decim_us_pos_y_i,
    decim_us_pos_q_i                           => decim_us_pos_q_i,
    decim_us_pos_sum_i                         => decim_us_pos_sum_i,
    decim_us_pos_valid_i                       => decim_us_pos_valid_i,

    -----------------------------
    -- Interlock outputs
    -----------------------------
    intlk_trans_bigger_x_o                     => intlk_trans_bigger_x,
    intlk_trans_bigger_y_o                     => intlk_trans_bigger_y,

    intlk_trans_bigger_ltc_x_o                 => intlk_trans_bigger_ltc_x,
    intlk_trans_bigger_ltc_y_o                 => intlk_trans_bigger_ltc_y,

    intlk_trans_bigger_any_o                   => intlk_trans_bigger_any,

    intlk_trans_x_diff_o                       => intlk_trans_x_diff,
    intlk_trans_y_diff_o                       => intlk_trans_y_diff,

    intlk_trans_bigger_ltc_o                   => intlk_trans_bigger_ltc,
    intlk_trans_bigger_o                       => intlk_trans_bigger,

    intlk_trans_smaller_x_o                    => intlk_trans_smaller_x,
    intlk_trans_smaller_y_o                    => intlk_trans_smaller_y,

    intlk_trans_smaller_ltc_x_o                => intlk_trans_smaller_ltc_x,
    intlk_trans_smaller_ltc_y_o                => intlk_trans_smaller_ltc_y,

    intlk_trans_smaller_any_o                  => intlk_trans_smaller_any,

    intlk_trans_smaller_ltc_o                  => intlk_trans_smaller_ltc,
    intlk_trans_smaller_o                      => intlk_trans_smaller,

    intlk_ang_bigger_x_o                       => intlk_ang_bigger_x,
    intlk_ang_bigger_y_o                       => intlk_ang_bigger_y,

    intlk_ang_bigger_ltc_x_o                   => intlk_ang_bigger_ltc_x,
    intlk_ang_bigger_ltc_y_o                   => intlk_ang_bigger_ltc_y,

    intlk_ang_bigger_any_o                     => intlk_ang_bigger_any,

    intlk_ang_x_diff_o                         => intlk_ang_x_diff,
    intlk_ang_y_diff_o                         => intlk_ang_y_diff,

    intlk_ang_bigger_ltc_o                     => intlk_ang_bigger_ltc,
    intlk_ang_bigger_o                         => intlk_ang_bigger,

    intlk_ang_smaller_x_o                      => intlk_ang_smaller_x,
    intlk_ang_smaller_y_o                      => intlk_ang_smaller_y,

    intlk_ang_smaller_ltc_x_o                  => intlk_ang_smaller_ltc_x,
    intlk_ang_smaller_ltc_y_o                  => intlk_ang_smaller_ltc_y,

    intlk_ang_smaller_any_o                    => intlk_ang_smaller_any,

    intlk_ang_smaller_ltc_o                    => intlk_ang_smaller_ltc,
    intlk_ang_smaller_o                        => intlk_ang_smaller,

    intlk_sum_bigger_any_o                     => regs_in.sts_min_sum_bigger_i,

    intlk_ltc_o                                => intlk_ltc,
    intlk_o                                    => intlk
  );

  -- Output assignments
  intlk_trans_bigger_x_o      <= intlk_trans_bigger_x;
  intlk_trans_bigger_y_o      <= intlk_trans_bigger_y;

  intlk_trans_bigger_ltc_x_o  <= intlk_trans_bigger_ltc_x;
  intlk_trans_bigger_ltc_y_o  <= intlk_trans_bigger_ltc_y;

  intlk_trans_bigger_any_o    <= intlk_trans_bigger_any;

  intlk_trans_bigger_ltc_o    <= intlk_trans_bigger_ltc;
  intlk_trans_bigger_o        <= intlk_trans_bigger;

  intlk_trans_smaller_x_o     <= intlk_trans_smaller_x;
  intlk_trans_smaller_y_o     <= intlk_trans_smaller_y;

  intlk_trans_smaller_ltc_x_o <= intlk_trans_smaller_ltc_x;
  intlk_trans_smaller_ltc_y_o <= intlk_trans_smaller_ltc_y;

  intlk_trans_smaller_any_o   <= intlk_trans_smaller_any;

  intlk_trans_smaller_ltc_o   <= intlk_trans_smaller_ltc;
  intlk_trans_smaller_o       <= intlk_trans_smaller;

  intlk_ang_bigger_x_o        <= intlk_ang_bigger_x;
  intlk_ang_bigger_y_o        <= intlk_ang_bigger_y;

  intlk_ang_bigger_ltc_x_o    <= intlk_ang_bigger_ltc_x;
  intlk_ang_bigger_ltc_y_o    <= intlk_ang_bigger_ltc_y;

  intlk_ang_bigger_any_o      <= intlk_ang_bigger_any;

  intlk_ang_bigger_ltc_o      <= intlk_ang_bigger_ltc;
  intlk_ang_bigger_o          <= intlk_ang_bigger;

  intlk_ang_smaller_x_o       <= intlk_ang_smaller_x;
  intlk_ang_smaller_y_o       <= intlk_ang_smaller_y;

  intlk_ang_smaller_ltc_x_o   <= intlk_ang_smaller_ltc_x;
  intlk_ang_smaller_ltc_y_o   <= intlk_ang_smaller_ltc_y;

  intlk_ang_smaller_any_o     <= intlk_ang_smaller_any;

  intlk_ang_smaller_ltc_o     <= intlk_ang_smaller_ltc;
  intlk_ang_smaller_o         <= intlk_ang_smaller;

  intlk_ltc_o                 <= intlk_ltc;
  intlk_o                     <= intlk;

end rtl;
