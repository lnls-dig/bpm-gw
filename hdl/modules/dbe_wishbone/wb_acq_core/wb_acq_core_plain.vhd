------------------------------------------------------------------------------
-- Title      : BPM Data Acquisition Wrapper for Verilog Simualtions
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-22-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top Module for the BPM Data Acquisition Simulations
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-05-12  1.0      lucas.russo        Created
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

entity wb_acq_core_plain is
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
  g_sim_readback                            : boolean := false;
  g_ddr_interface_type                      : string  := "AXIS";
  g_max_burst_size                          : natural := 4
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
  -- External Interface
  -----------------------------
  acq_val_low_i                             : in std_logic_vector(g_acq_num_channels*c_acq_chan_width-1 downto 0);
  acq_val_high_i                            : in std_logic_vector(g_acq_num_channels*c_acq_chan_width-1 downto 0);
  acq_dvalid_i                              : in std_logic_vector(g_acq_num_channels-1 downto 0);
  acq_id_i                                  : in unsigned(g_acq_num_channels*c_acq_id_width-1 downto 0);
  acq_trig_i                                : in std_logic_vector(g_acq_num_channels-1 downto 0);

  -----------------------------
  -- DRRAM Interface
  -----------------------------
  dpram_dout_o                              : out std_logic_vector(f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
  dpram_valid_o                             : out std_logic;

  -----------------------------
  -- External Interface (w/ FLow Control)
  -----------------------------
  ext_dout_o                                : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  ext_valid_o                               : out std_logic;
  ext_addr_o                                : out std_logic_vector(g_ddr_addr_width-1 downto 0);
  ext_sof_o                                 : out std_logic;
  ext_eof_o                                 : out std_logic;
  ext_dreq_o                                : out std_logic; -- for debbuging purposes
  ext_stall_o                               : out std_logic; -- for debbuging purposes

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
  dbg_ddr_rb_start_p_i                      : in std_logic;
  dbg_ddr_rb_rdy_o                          : out std_logic;
  dbg_ddr_rb_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  dbg_ddr_rb_addr_o                         : out std_logic_vector(g_acq_addr_width-1 downto 0);
  dbg_ddr_rb_valid_o                        : out std_logic
);
end wb_acq_core_plain;

architecture rtl of wb_acq_core_plain is

  signal acq_val_low_array                  : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq_val_high_array                 : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq_dvalid_array                   : std_logic_vector(g_acq_num_channels-1 downto 0);
  signal acq_id_array                       : t_acq_id_array(g_acq_num_channels-1 downto 0);
  signal acq_trig_array                     : std_logic_vector(g_acq_num_channels-1 downto 0);

begin

  cmp_wb_acq_core : wb_acq_core
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
    g_sim_readback                            => g_sim_readback,
    g_ddr_interface_type                      => g_ddr_interface_type,
    g_max_burst_size                          => g_max_burst_size
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

    wb_adr_i                                  => wb_adr_i,
    wb_dat_i                                  => wb_dat_i,
    wb_dat_o                                  => wb_dat_o,
    wb_sel_i                                  => wb_sel_i,
    wb_we_i                                   => wb_we_i,
    wb_cyc_i                                  => wb_cyc_i,
    wb_stb_i                                  => wb_stb_i,
    wb_ack_o                                  => wb_ack_o,
    wb_err_o                                  => wb_err_o,
    wb_rty_o                                  => wb_rty_o,
    wb_stall_o                                => wb_stall_o,

    -----------------------------
    -- External Interface
    -----------------------------
    acq_val_low_i                             => acq_val_low_array,
    acq_val_high_i                            => acq_val_high_array,
    acq_dvalid_i                              => acq_dvalid_array,
    acq_id_i                                  => acq_id_array,
    acq_trig_i                                => acq_trig_array,

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_o                              => dpram_dout_o,
    dpram_valid_o                             => dpram_valid_o,

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_o                                => ext_dout_o,
    ext_valid_o                               => ext_valid_o,
    ext_addr_o                                => ext_addr_o,
    ext_sof_o                                 => ext_sof_o,
    ext_eof_o                                 => ext_eof_o,
    ext_dreq_o                                => ext_dreq_o,
    ext_stall_o                               => ext_stall_o,

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ui_app_addr_o                             => ui_app_addr_o,
    ui_app_cmd_o                              => ui_app_cmd_o,
    ui_app_en_o                               => ui_app_en_o,
    ui_app_rdy_i                              => ui_app_rdy_i,

    ui_app_wdf_data_o                         => ui_app_wdf_data_o,
    ui_app_wdf_end_o                          => ui_app_wdf_end_o,
    ui_app_wdf_mask_o                         => ui_app_wdf_mask_o,
    ui_app_wdf_wren_o                         => ui_app_wdf_wren_o,
    ui_app_wdf_rdy_i                          => ui_app_wdf_rdy_i,

    ui_app_rd_data_i                          => ui_app_rd_data_i,
    ui_app_rd_data_end_i                      => ui_app_rd_data_end_i,
    ui_app_rd_data_valid_i                    => ui_app_rd_data_valid_i,

    ui_app_req_o                              => ui_app_req_o,
    ui_app_gnt_i                              => ui_app_gnt_i,

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_i                      => dbg_ddr_rb_start_p_i,
    dbg_ddr_rb_rdy_o                          => dbg_ddr_rb_rdy_o,
    dbg_ddr_rb_data_o                         => dbg_ddr_rb_data_o,
    dbg_ddr_rb_addr_o                         => dbg_ddr_rb_addr_o,
    dbg_ddr_rb_valid_o                        => dbg_ddr_rb_valid_o
  );

  gen_wb_acq_core_plain_inputs : for i in 0 to g_acq_num_channels - 1 generate

    acq_val_low_array(i)      <=
                acq_val_low_i(c_acq_chan_width*(i+1)-1 downto c_acq_chan_width*i);
    acq_val_high_array(i)     <=
                acq_val_high_i(c_acq_chan_width*(i+1)-1 downto c_acq_chan_width*i);
    acq_dvalid_array(i)       <= acq_dvalid_i(i);
    acq_id_array(i)      <=
                acq_id_i(c_acq_id_width*(i+1)-1 downto c_acq_id_width*i);
    acq_trig_array(i)         <= acq_trig_i(i);

  end generate;

end rtl;
