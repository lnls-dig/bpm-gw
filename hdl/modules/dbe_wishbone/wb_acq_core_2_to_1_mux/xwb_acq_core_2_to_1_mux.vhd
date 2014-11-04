------------------------------------------------------------------------------
-- Title      : BPM Data Acquisition
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2014-03-11
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top Module for the BPM Data Acquisition Muxed
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-03-11  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- General common cores
use work.gencores_pkg.all;
-- Genrams cores
use work.genram_pkg.all;
-- BPM acq core cores
use work.acq_core_pkg.all;
-- BPM FSM Acq Regs
use work.acq_core_wbgen2_pkg.all;
-- DBE wishbone cores
use work.dbe_wishbone_pkg.all;

entity xwb_acq_core_2_to_1_mux is
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
  wb0_slv_i                                 : in t_wishbone_slave_in;
  wb0_slv_o                                 : out t_wishbone_slave_out;

  wb1_slv_i                                 : in t_wishbone_slave_in;
  wb1_slv_o                                 : out t_wishbone_slave_out;

  -----------------------------
  -- External Interface
  -----------------------------
  acq0_chan_array_i                         : in t_acq_chan_array(g_acq_num_channels-1 downto 0);

  acq1_chan_array_i                         : in t_acq_chan_array(g_acq_num_channels-1 downto 0);

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
end xwb_acq_core_2_to_1_mux;

architecture rtl of xwb_acq_core_2_to_1_mux is

  signal acq0_val_low_array                 : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq0_val_high_array                : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq0_dvalid_array                  : std_logic_vector(g_acq_num_channels-1 downto 0);
  signal acq0_trig_array                    : std_logic_vector(g_acq_num_channels-1 downto 0);

  signal acq1_val_low_array                 : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq1_val_high_array                : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq1_dvalid_array                  : std_logic_vector(g_acq_num_channels-1 downto 0);
  signal acq1_trig_array                    : std_logic_vector(g_acq_num_channels-1 downto 0);

begin

  cmp_wb_acq_core_2_to_1_mux : wb_acq_core_2_to_1_mux
  generic map
  (
    g_interface_mode                         => g_interface_mode,
    g_address_granularity                    => g_address_granularity,
    g_acq_addr_width                         => g_acq_addr_width,
    g_acq_num_channels                       => g_acq_num_channels,
    g_acq_channels                           => g_acq_channels,
    g_ddr_payload_width                      => g_ddr_payload_width,
    g_ddr_addr_width                         => g_ddr_addr_width,
    g_ddr_dq_width                           => g_ddr_dq_width,
    g_multishot_ram_size                     => g_multishot_ram_size,
    g_fifo_fc_size                           => g_fifo_fc_size,
    g_sim_readback                           => g_sim_readback
  )
  port map
  (
    fs_clk_i                                 => fs_clk_i,
    fs_ce_i                                  => fs_ce_i,
    fs_rst_n_i                               => fs_rst_n_i,

    sys_clk_i                                => sys_clk_i,
    sys_rst_n_i                              => sys_rst_n_i,

    ext_clk_i                                => ext_clk_i,
    ext_rst_n_i                              => ext_rst_n_i,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------

    wb0_adr_i                                => wb0_slv_i.adr,
    wb0_dat_i                                => wb0_slv_i.dat,
    wb0_dat_o                                => wb0_slv_o.dat,
    wb0_sel_i                                => wb0_slv_i.sel,
    wb0_we_i                                 => wb0_slv_i.we,
    wb0_cyc_i                                => wb0_slv_i.cyc,
    wb0_stb_i                                => wb0_slv_i.stb,
    wb0_ack_o                                => wb0_slv_o.ack,
    wb0_err_o                                => wb0_slv_o.err,
    wb0_rty_o                                => wb0_slv_o.rty,
    wb0_stall_o                              => wb0_slv_o.stall,

    wb1_adr_i                                => wb1_slv_i.adr,
    wb1_dat_i                                => wb1_slv_i.dat,
    wb1_dat_o                                => wb1_slv_o.dat,
    wb1_sel_i                                => wb1_slv_i.sel,
    wb1_we_i                                 => wb1_slv_i.we,
    wb1_cyc_i                                => wb1_slv_i.cyc,
    wb1_stb_i                                => wb1_slv_i.stb,
    wb1_ack_o                                => wb1_slv_o.ack,
    wb1_err_o                                => wb1_slv_o.err,
    wb1_rty_o                                => wb1_slv_o.rty,
    wb1_stall_o                              => wb1_slv_o.stall,

    -----------------------------
    -- External Interface
    -----------------------------
    acq0_val_low_i                           => acq0_val_low_array,
    acq0_val_high_i                          => acq0_val_high_array,
    acq0_dvalid_i                            => acq0_dvalid_array,
    acq0_trig_i                              => acq0_trig_array,

    acq1_val_low_i                           => acq1_val_low_array,
    acq1_val_high_i                          => acq1_val_high_array,
    acq1_dvalid_i                            => acq1_dvalid_array,
    acq1_trig_i                              => acq1_trig_array,

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram0_dout_o                            => dpram0_dout_o,
    dpram0_valid_o                           => dpram0_valid_o,

    dpram1_dout_o                            => dpram1_dout_o,
    dpram1_valid_o                           => dpram1_valid_o,

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext0_dout_o                              => ext0_dout_o,
    ext0_valid_o                             => ext0_valid_o,
    ext0_addr_o                              => ext0_addr_o,
    ext0_sof_o                               => ext0_sof_o,
    ext0_eof_o                               => ext0_eof_o,
    ext0_dreq_o                              => ext0_dreq_o,
    ext0_stall_o                             => ext0_stall_o,

    ext1_dout_o                              => ext1_dout_o,
    ext1_valid_o                             => ext1_valid_o,
    ext1_addr_o                              => ext1_addr_o,
    ext1_sof_o                               => ext1_sof_o,
    ext1_eof_o                               => ext1_eof_o,
    ext1_dreq_o                              => ext1_dreq_o,
    ext1_stall_o                             => ext1_stall_o,

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                            => ui_app_addr_o,
    ui_app_cmd_o                             => ui_app_cmd_o,
    ui_app_en_o                              => ui_app_en_o,
    ui_app_rdy_i                             => ui_app_rdy_i,

    ui_app_wdf_data_o                        => ui_app_wdf_data_o,
    ui_app_wdf_end_o                         => ui_app_wdf_end_o,
    ui_app_wdf_mask_o                        => ui_app_wdf_mask_o,
    ui_app_wdf_wren_o                        => ui_app_wdf_wren_o,
    ui_app_wdf_rdy_i                         => ui_app_wdf_rdy_i,

    ui_app_rd_data_i                         => ui_app_rd_data_i,
    ui_app_rd_data_end_i                     => ui_app_rd_data_end_i,
    ui_app_rd_data_valid_i                   => ui_app_rd_data_valid_i,

    ui_app_req_o                             => ui_app_req_o,
    ui_app_gnt_i                             => ui_app_gnt_i,

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb0_start_p_i                    => dbg_ddr_rb0_start_p_i,
    dbg_ddr_rb0_rdy_o                        => dbg_ddr_rb0_rdy_o,
    dbg_ddr_rb0_data_o                       => dbg_ddr_rb0_data_o,
    dbg_ddr_rb0_addr_o                       => dbg_ddr_rb0_addr_o,
    dbg_ddr_rb0_valid_o                      => dbg_ddr_rb0_valid_o,

    dbg_ddr_rb1_start_p_i                    => dbg_ddr_rb1_start_p_i,
    dbg_ddr_rb1_rdy_o                        => dbg_ddr_rb1_rdy_o,
    dbg_ddr_rb1_data_o                       => dbg_ddr_rb1_data_o,
    dbg_ddr_rb1_addr_o                       => dbg_ddr_rb1_addr_o,
    dbg_ddr_rb1_valid_o                      => dbg_ddr_rb1_valid_o
  );

  gen_wb_acq_core_plain0_inputs : for i in 0 to g_acq_num_channels - 1 generate

    acq0_val_low_array(i)      <= acq0_chan_array_i(i).val_low;
    acq0_val_high_array(i)     <= acq0_chan_array_i(i).val_high;
    acq0_dvalid_array(i)       <= acq0_chan_array_i(i).dvalid;
    acq0_trig_array(i)         <= acq0_chan_array_i(i).trig;

  end generate;

  gen_wb_acq_core_plain1_inputs : for i in 0 to g_acq_num_channels - 1 generate

    acq1_val_low_array(i)      <= acq1_chan_array_i(i).val_low;
    acq1_val_high_array(i)     <= acq1_chan_array_i(i).val_high;
    acq1_dvalid_array(i)       <= acq1_chan_array_i(i).dvalid;
    acq1_trig_array(i)         <= acq1_chan_array_i(i).trig;

  end generate;

end rtl;
