------------------------------------------------------------------------------
-- Title      : BPM Data Acquisition
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-22-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: 2-port Acquisition Core. It supports up to 2 independent and
--              simultaneous groups of acquisition channels, muxing the DDR3
--              interface
--
-------------------------------------------------------------------------------
-- Copyright (c) 2014 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-28-10  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- General common cores
use work.gencores_pkg.all;
-- BPM acq core cores
use work.acq_core_pkg.all;
-- Genrams cores
use work.genram_pkg.all;
-- DBE wishbone cores
use work.dbe_wishbone_pkg.all;
-- DBE Common cores
use work.dbe_common_pkg.all;

entity wb_acq_core_2_to_1_mux is
generic
(
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_acq_addr_width                          : natural := 32;
  g_acq_num_channels                        : natural := c_default_acq_num_channels;
  g_acq_channels                            : t_acq_chan_param_array := c_default_acq_chan_param_array;
  g_ddr_payload_width                       : natural := 256;     -- be careful changing these!
  g_ddr_dq_width                            : natural := 64;      -- be careful changing these!
  g_ddr_addr_width                          : natural := 32;      -- be careful changing these!
  g_multishot_ram_size                      : natural := 2048;
  g_fifo_fc_size                            : natural := 64;
  g_sim_readback                            : boolean := false
);
port
(
  fs_clk_i                                  : in std_logic;
  fs_ce_i                                   : in std_logic;
  fs_rst_n_i                                : in std_logic;

  sys_clk_i                                 : in std_logic;
  sys_rst_n_i                               : in std_logic;

  ext_clk_i                                 : in std_logic;
  ext_rst_n_i                               : in std_logic;

  -----------------------------
  -- Wishbone Control Interface signals
  -----------------------------

  wb0_adr_i                                 : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
  wb0_dat_i                                 : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
  wb0_dat_o                                 : out std_logic_vector(c_wishbone_data_width-1 downto 0);
  wb0_sel_i                                 : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
  wb0_we_i                                  : in  std_logic := '0';
  wb0_cyc_i                                 : in  std_logic := '0';
  wb0_stb_i                                 : in  std_logic := '0';
  wb0_ack_o                                 : out std_logic;
  wb0_err_o                                 : out std_logic;
  wb0_rty_o                                 : out std_logic;
  wb0_stall_o                               : out std_logic;

  wb1_adr_i                                 : in  std_logic_vector(c_wishbone_address_width-1 downto 0) := (others => '0');
  wb1_dat_i                                 : in  std_logic_vector(c_wishbone_data_width-1 downto 0) := (others => '0');
  wb1_dat_o                                 : out std_logic_vector(c_wishbone_data_width-1 downto 0);
  wb1_sel_i                                 : in  std_logic_vector(c_wishbone_data_width/8-1 downto 0) := (others => '0');
  wb1_we_i                                  : in  std_logic := '0';
  wb1_cyc_i                                 : in  std_logic := '0';
  wb1_stb_i                                 : in  std_logic := '0';
  wb1_ack_o                                 : out std_logic;
  wb1_err_o                                 : out std_logic;
  wb1_rty_o                                 : out std_logic;
  wb1_stall_o                               : out std_logic;

  -----------------------------
  -- External Interface
  -----------------------------
  acq0_val_low_i                            : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  acq0_val_high_i                           : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  acq0_dvalid_i                             : in std_logic_vector(g_acq_num_channels-1 downto 0);
  acq0_trig_i                               : in std_logic_vector(g_acq_num_channels-1 downto 0);

  acq1_val_low_i                            : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  acq1_val_high_i                           : in t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  acq1_dvalid_i                             : in std_logic_vector(g_acq_num_channels-1 downto 0);
  acq1_trig_i                               : in std_logic_vector(g_acq_num_channels-1 downto 0);

  -----------------------------
  -- DRRAM Interface
  -----------------------------
  dpram0_dout_o                             : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
  dpram0_valid_o                            : out std_logic;

  dpram1_dout_o                             : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
  dpram1_valid_o                            : out std_logic;

  -----------------------------
  -- External Interface (w/ FLow Control)
  -----------------------------
  ext0_dout_o                               : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  ext0_valid_o                              : out std_logic;
  ext0_addr_o                               : out std_logic_vector(g_acq_addr_width-1 downto 0);
  ext0_sof_o                                : out std_logic;
  ext0_eof_o                                : out std_logic;
  ext0_dreq_o                               : out std_logic; -- for debbuging purposes
  ext0_stall_o                              : out std_logic; -- for debbuging purposes

  ext1_dout_o                               : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  ext1_valid_o                              : out std_logic;
  ext1_addr_o                               : out std_logic_vector(g_acq_addr_width-1 downto 0);
  ext1_sof_o                                : out std_logic;
  ext1_eof_o                                : out std_logic;
  ext1_dreq_o                               : out std_logic; -- for debbuging purposes
  ext1_stall_o                              : out std_logic; -- for debbuging purposes

  -----------------------------
  -- DDR3 SDRAM Interface
  -----------------------------
  ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
  ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
  ui_app_en_o                               : out std_logic;
  ui_app_rdy_i                              : in std_logic;

  ui_app_wdf_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  ui_app_wdf_end_o                          : out std_logic;
  ui_app_wdf_mask_o                         : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
  ui_app_wdf_wren_o                         : out std_logic;
  ui_app_wdf_rdy_i                          : in std_logic;

  ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0);
  ui_app_rd_data_end_i                      : in std_logic;
  ui_app_rd_data_valid_i                    : in std_logic;

  ui_app_req_o                              : out std_logic;
  ui_app_gnt_i                              : in std_logic;

  -----------------------------
  -- Debug Interface
  -----------------------------
  dbg_ddr_rb0_start_p_i                     : in std_logic;
  dbg_ddr_rb0_rdy_o                         : out std_logic;
  dbg_ddr_rb0_data_o                        : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  dbg_ddr_rb0_addr_o                        : out std_logic_vector(g_acq_addr_width-1 downto 0);
  dbg_ddr_rb0_valid_o                       : out std_logic;

  dbg_ddr_rb1_start_p_i                     : in std_logic;
  dbg_ddr_rb1_rdy_o                         : out std_logic;
  dbg_ddr_rb1_data_o                        : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  dbg_ddr_rb1_addr_o                        : out std_logic_vector(g_acq_addr_width-1 downto 0);
  dbg_ddr_rb1_valid_o                       : out std_logic
);
end wb_acq_core_2_to_1_mux;

architecture rtl of wb_acq_core_2_to_1_mux is

  -- ACQ core component 0 signals
  signal ui_app0_addr_int                   : std_logic_vector(g_ddr_addr_width-1 downto 0);
  signal ui_app0_cmd_int                    : std_logic_vector(2 downto 0);
  signal ui_app0_en_int                     : std_logic;
  signal ui_app0_rdy_int                    : std_logic;

  signal ui_wdf0_data_int                   : std_logic_vector(g_ddr_payload_width-1 downto 0);
  signal ui_wdf0_end_int                    : std_logic;
  signal ui_wdf0_mask_int                   : std_logic_vector(g_ddr_payload_width/8-1 downto 0);
  signal ui_wdf0_wren_int                   : std_logic;
  signal ui_wdf0_rdy_int                    : std_logic;

  signal ui_rd0_data_int                    : std_logic_vector(g_ddr_payload_width-1 downto 0);
  signal ui_rd0_data_end_int                : std_logic;
  signal ui_rd0_data_valid_int              : std_logic;

  signal ui_app0_req_int                    : std_logic;
  signal ui_app0_gnt_int                    : std_logic;

  -- ACQ core component 1 signals
  signal ui_app1_addr_int                   : std_logic_vector(g_ddr_addr_width-1 downto 0) := (others => '0');
  signal ui_app1_cmd_int                    : std_logic_vector(2 downto 0) := (others => '0');
  signal ui_app1_en_int                     : std_logic := '0';
  signal ui_app1_rdy_int                    : std_logic;

  signal ui_wdf1_data_int                   : std_logic_vector(g_ddr_payload_width-1 downto 0) := (others => '0');
  signal ui_wdf1_end_int                    : std_logic := '0';
  signal ui_wdf1_mask_int                   : std_logic_vector(g_ddr_payload_width/8-1 downto 0) := (others => '0');
  signal ui_wdf1_wren_int                   : std_logic := '0';
  signal ui_wdf1_rdy_int                    : std_logic;

  signal ui_rd1_data_int                    : std_logic_vector(g_ddr_payload_width-1 downto 0);
  signal ui_rd1_data_end_int                : std_logic;
  signal ui_rd1_data_valid_int              : std_logic;

  signal ui_app1_req_int                    : std_logic := '0';
  signal ui_app1_gnt_int                    : std_logic;

  -- AXIS 00 mux signals
  signal axis_app_s00_trdy                  : std_logic;
  signal axis_app_s00_valid                 : std_logic;
  signal axis_app_s00_data                  : std_logic_vector(255 downto 0);
  signal axis_app_s00_tuser                 : std_logic_vector(127 downto 0);

  signal axis_wdf_s00_trdy                  : std_logic;
  signal axis_wdf_s00_valid                 : std_logic;
  signal axis_wdf_s00_data                  : std_logic_vector(255 downto 0);
  signal axis_wdf_s00_tuser                 : std_logic_vector(127 downto 0);

  -- AXIS 01 mux signals
  signal axis_app_s01_trdy                  : std_logic;
  signal axis_app_s01_valid                 : std_logic;
  signal axis_app_s01_data                  : std_logic_vector(255 downto 0);
  signal axis_app_s01_tuser                 : std_logic_vector(127 downto 0);

  signal axis_wdf_s01_trdy                  : std_logic;
  signal axis_wdf_s01_valid                 : std_logic;
  signal axis_wdf_s01_data                  : std_logic_vector(255 downto 0);
  signal axis_wdf_s01_tuser                 : std_logic_vector(127 downto 0);

  -- AXIM 00 signals
  signal axis_app_m00_tready                  : std_logic;
  signal axis_app_m00_tvalid                : std_logic;
  signal axis_app_m00_tdata                 : std_logic_vector(255 downto 0);
  signal axis_app_m00_tuser                 : std_logic_vector(127 downto 0);

  -- AXIM 01 signals
  signal axis_wdf_m01_tready                  : std_logic;
  signal axis_wdf_m01_tvalid                : std_logic;
  signal axis_wdf_m01_tdata                 : std_logic_vector(255 downto 0);
  signal axis_wdf_m01_tuser                 : std_logic_vector(127 downto 0);

  component axis_mux_2_to_1
  port (
    aclk                                    : in std_logic;
    aresetn                                 : in std_logic;
    s00_axis_aclk                           : in std_logic;
    s01_axis_aclk                           : in std_logic;
    s00_axis_aresetn                        : in std_logic;
    s01_axis_aresetn                        : in std_logic;
    s00_axis_tvalid                         : in std_logic;
    s01_axis_tvalid                         : in std_logic;
    s00_axis_tready                         : out std_logic;
    s01_axis_tready                         : out std_logic;
    s00_axis_tdata                          : in std_logic_vector(255 downto 0);
    s01_axis_tdata                          : in std_logic_vector(255 downto 0);
    s00_axis_tuser                          : in std_logic_vector(127 downto 0);
    s01_axis_tuser                          : in std_logic_vector(127 downto 0);
    m00_axis_aclk                           : in std_logic;
    m00_axis_aresetn                        : in std_logic;
    m00_axis_tvalid                         : out std_logic;
    m00_axis_tready                         : in std_logic;
    m00_axis_tdata                          : out std_logic_vector(255 downto 0);
    m00_axis_tuser                          : out std_logic_vector(127 downto 0);
    s00_arb_req_suppress                    : in std_logic;
    s01_arb_req_suppress                    : in std_logic
  );
  end component;

begin

  cmp0_wb_acq_core : wb_acq_core
  generic map
  (
    g_interface_mode                          => g_interface_mode,
    g_address_granularity                     => g_address_granularity,
    g_acq_addr_width                          => g_acq_addr_width,
    g_acq_num_channels                        => g_acq_num_channels,
    g_acq_channels                            => g_acq_channels,
    g_ddr_payload_width                       => g_ddr_payload_width,
    g_ddr_addr_width                          => g_ddr_addr_width,
    g_ddr_dq_width                            => g_ddr_dq_width,
    g_multishot_ram_size                      => g_multishot_ram_size,
    g_fifo_fc_size                            => g_fifo_fc_size,
    g_sim_readback                            => g_sim_readback
  )
  port map
  (
    fs_clk_i                                  => fs_clk_i,
    fs_ce_i                                   => fs_ce_i,
    fs_rst_n_i                                => fs_rst_n_i,

    sys_clk_i                                 => sys_clk_i,
    sys_rst_n_i                               => sys_rst_n_i,

    ext_clk_i                                 => ext_clk_i,
    ext_rst_n_i                               => ext_rst_n_i,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  => wb0_adr_i,
    wb_dat_i                                  => wb0_dat_i,
    wb_dat_o                                  => wb0_dat_o,
    wb_sel_i                                  => wb0_sel_i,
    wb_we_i                                   => wb0_we_i,
    wb_cyc_i                                  => wb0_cyc_i,
    wb_stb_i                                  => wb0_stb_i,
    wb_ack_o                                  => wb0_ack_o,
    wb_err_o                                  => wb0_err_o,
    wb_rty_o                                  => wb0_rty_o,
    wb_stall_o                                => wb0_stall_o,

    -----------------------------
    -- External Interface
    -----------------------------
    acq_val_low_i                             => acq0_val_low_i,
    acq_val_high_i                            => acq0_val_high_i,
    acq_dvalid_i                              => acq0_dvalid_i,
    acq_trig_i                                => acq0_trig_i,

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_o                              => dpram0_dout_o,
    dpram_valid_o                             => dpram0_valid_o,

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_o                                => ext0_dout_o,
    ext_valid_o                               => ext0_valid_o,
    ext_addr_o                                => ext0_addr_o,
    ext_sof_o                                 => ext0_sof_o,
    ext_eof_o                                 => ext0_eof_o,
    ext_dreq_o                                => ext0_dreq_o,
    ext_stall_o                               => ext0_stall_o,

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                             => ui_app0_addr_int,
    ui_app_cmd_o                              => ui_app0_cmd_int,
    ui_app_en_o                               => ui_app0_en_int,
    ui_app_rdy_i                              => ui_app0_rdy_int,

    ui_app_wdf_data_o                         => ui_wdf0_data_int,
    ui_app_wdf_end_o                          => ui_wdf0_end_int,
    ui_app_wdf_mask_o                         => ui_wdf0_mask_int,
    ui_app_wdf_wren_o                         => ui_wdf0_wren_int,
    ui_app_wdf_rdy_i                          => ui_wdf0_rdy_int,

    ui_app_rd_data_i                          => ui_rd0_data_int,
    ui_app_rd_data_end_i                      => ui_rd0_data_end_int,
    ui_app_rd_data_valid_i                    => ui_rd0_data_valid_int,

    ui_app_req_o                              => ui_app0_req_int,
    ui_app_gnt_i                              => ui_app0_gnt_int,

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_i                      => dbg_ddr_rb0_start_p_i,
    dbg_ddr_rb_rdy_o                          => dbg_ddr_rb0_rdy_o,
    dbg_ddr_rb_data_o                         => dbg_ddr_rb0_data_o,
    dbg_ddr_rb_addr_o                         => dbg_ddr_rb0_addr_o,
    dbg_ddr_rb_valid_o                        => dbg_ddr_rb0_valid_o
  );

  -- ACQ core component 0 AXIS APP signals
  ui_app0_rdy_int                     <= axis_app_s00_trdy;
  ui_wdf0_rdy_int                     <= axis_app_s00_trdy;

  axis_app_s00_data                   <= ui_wdf0_data_int;
  axis_app_s00_tuser(127 downto 68)   <= (others => '0');
  axis_app_s00_tuser(67 downto 0)     <= ui_wdf0_mask_int & ui_wdf0_end_int &
                                            ui_app0_cmd_int & ui_app0_addr_int &
                                            ui_wdf0_wren_int & ui_app0_en_int;
  axis_app_s00_valid                  <= ui_app0_en_int or ui_wdf0_wren_int;

  cmp1_wb_acq_core : wb_acq_core
  generic map
  (
    g_interface_mode                          => g_interface_mode,
    g_address_granularity                     => g_address_granularity,
    g_acq_addr_width                          => g_acq_addr_width,
    g_acq_num_channels                        => g_acq_num_channels,
    g_acq_channels                            => g_acq_channels,
    g_ddr_payload_width                       => g_ddr_payload_width,
    g_ddr_addr_width                          => g_ddr_addr_width,
    g_ddr_dq_width                            => g_ddr_dq_width,
    g_multishot_ram_size                      => g_multishot_ram_size,
    g_fifo_fc_size                            => g_fifo_fc_size,
    g_sim_readback                            => g_sim_readback
  )
  port map
  (
    fs_clk_i                                  => fs_clk_i,
    fs_ce_i                                   => fs_ce_i,
    fs_rst_n_i                                => fs_rst_n_i,

    sys_clk_i                                 => sys_clk_i,
    sys_rst_n_i                               => sys_rst_n_i,

    ext_clk_i                                 => ext_clk_i,
    ext_rst_n_i                               => ext_rst_n_i,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb_adr_i                                  => wb1_adr_i,
    wb_dat_i                                  => wb1_dat_i,
    wb_dat_o                                  => wb1_dat_o,
    wb_sel_i                                  => wb1_sel_i,
    wb_we_i                                   => wb1_we_i,
    wb_cyc_i                                  => wb1_cyc_i,
    wb_stb_i                                  => wb1_stb_i,
    wb_ack_o                                  => wb1_ack_o,
    wb_err_o                                  => wb1_err_o,
    wb_rty_o                                  => wb1_rty_o,
    wb_stall_o                                => wb1_stall_o,

    -----------------------------
    -- External Interface
    -----------------------------
    acq_val_low_i                             => acq1_val_low_i,
    acq_val_high_i                            => acq1_val_high_i,
    acq_dvalid_i                              => acq1_dvalid_i,
    acq_trig_i                                => acq1_trig_i,

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_o                              => dpram1_dout_o,
    dpram_valid_o                             => dpram1_valid_o,

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_o                                => ext1_dout_o,
    ext_valid_o                               => ext1_valid_o,
    ext_addr_o                                => ext1_addr_o,
    ext_sof_o                                 => ext1_sof_o,
    ext_eof_o                                 => ext1_eof_o,
    ext_dreq_o                                => ext1_dreq_o,
    ext_stall_o                               => ext1_stall_o,

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                             => ui_app1_addr_int,
    ui_app_cmd_o                              => ui_app1_cmd_int,
    ui_app_en_o                               => ui_app1_en_int,
    ui_app_rdy_i                              => ui_app1_rdy_int,

    ui_app_wdf_data_o                         => ui_wdf1_data_int,
    ui_app_wdf_end_o                          => ui_wdf1_end_int,
    ui_app_wdf_mask_o                         => ui_wdf1_mask_int,
    ui_app_wdf_wren_o                         => ui_wdf1_wren_int,
    ui_app_wdf_rdy_i                          => ui_wdf1_rdy_int,

    ui_app_rd_data_i                          => ui_rd1_data_int,
    ui_app_rd_data_end_i                      => ui_rd1_data_end_int,
    ui_app_rd_data_valid_i                    => ui_rd1_data_valid_int,

    ui_app_req_o                              => ui_app1_req_int,
    ui_app_gnt_i                              => ui_app1_gnt_int,

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_i                      => dbg_ddr_rb1_start_p_i,
    dbg_ddr_rb_rdy_o                          => dbg_ddr_rb1_rdy_o,
    dbg_ddr_rb_data_o                         => dbg_ddr_rb1_data_o,
    dbg_ddr_rb_addr_o                         => dbg_ddr_rb1_addr_o,
    dbg_ddr_rb_valid_o                        => dbg_ddr_rb1_valid_o
  );

  -- ACQ core component 1 AXIS APP signals
  ui_app1_rdy_int                     <= axis_app_s01_trdy;
  ui_wdf1_rdy_int                     <= axis_app_s01_trdy;

  axis_app_s01_data                   <= ui_wdf1_data_int;
  axis_app_s01_tuser(127 downto 68)   <= (others => '0');
  axis_app_s01_tuser(67 downto 0)     <= ui_wdf1_mask_int & ui_wdf1_end_int &
                                            ui_app1_cmd_int & ui_app1_addr_int &
                                            ui_wdf1_wren_int & ui_app1_en_int;
  axis_app_s01_valid                  <= ui_app1_en_int or ui_wdf1_wren_int;

  -----------------------------------------------------------------------------
  -- AXIS Muxer
  -----------------------------------------------------------------------------

  cmp_ui_mux_2_to_1 : axis_mux_2_to_1
  port map
  (
    aclk                                      => ext_clk_i,
    aresetn                                   => ext_rst_n_i,

    s00_axis_aclk                             => ext_clk_i,
    s00_axis_aresetn                          => ext_rst_n_i,
    s00_axis_tvalid                           => axis_app_s00_valid,
    s00_axis_tready                           => axis_app_s00_trdy,
    s00_axis_tdata                            => axis_app_s00_data,
    s00_axis_tuser                            => axis_app_s00_tuser,
    s00_arb_req_suppress                      => '0',

    s01_axis_aclk                             => ext_clk_i,
    s01_axis_aresetn                          => ext_rst_n_i,
    s01_axis_tvalid                           => axis_app_s01_valid,
    s01_axis_tready                           => axis_app_s01_trdy,
    s01_axis_tdata                            => axis_app_s01_data,
    s01_axis_tuser                            => axis_app_s01_tuser,
    s01_arb_req_suppress                      => '0',

    m00_axis_aclk                             => ext_clk_i,
    m00_axis_aresetn                          => ext_rst_n_i,
    m00_axis_tvalid                           => axis_app_m00_tvalid,
    m00_axis_tready                           => axis_app_m00_tready,
    m00_axis_tdata                            => axis_app_m00_tdata,
    m00_axis_tuser                            => axis_app_m00_tuser
  );

  axis_app_m00_tready   <= ui_app_rdy_i and ui_app_wdf_rdy_i and ui_app_gnt_i;

  ui_app_addr_o         <= axis_app_m00_tuser(31 downto 2);
  ui_app_cmd_o          <= axis_app_m00_tuser(34 downto 32);
  ui_app_en_o           <= axis_app_m00_tuser(0) and ui_app_wdf_rdy_i when axis_app_m00_tvalid = '1' else '0';

  ui_app_wdf_data_o     <= axis_app_m00_tdata;
  ui_app_wdf_end_o      <= axis_app_m00_tuser(35);
  ui_app_wdf_mask_o     <= axis_app_m00_tuser(67 downto 36);
  ui_app_wdf_wren_o     <= axis_app_m00_tuser(1) and ui_app_rdy_i when axis_app_m00_tvalid = '1' else '0';

  -- Output assignments
  ui_app_req_o      <= ui_app0_req_int or ui_app1_req_int;
  ui_app0_gnt_int   <= ui_app_gnt_i;
  ui_app1_gnt_int   <= ui_app_gnt_i;

  ui_rd0_data_int        <= ui_app_rd_data_i;
  ui_rd0_data_end_int    <= ui_app_rd_data_end_i;
  ui_rd0_data_valid_int  <= ui_app_rd_data_valid_i;

  ui_rd1_data_int        <= ui_app_rd_data_i;
  ui_rd1_data_end_int    <= ui_app_rd_data_end_i;
  ui_rd1_data_valid_int  <= ui_app_rd_data_valid_i;

end rtl;
