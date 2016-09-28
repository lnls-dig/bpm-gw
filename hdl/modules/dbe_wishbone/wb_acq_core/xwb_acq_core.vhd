------------------------------------------------------------------------------
-- Title      : BPM Data Acquisition
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-22-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top Module for the BPM Data Acquisition
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-22-10  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

-- Based on FMC-ADC-100M (http://www.ohwr.org/projects/fmc-adc-100m14b4cha/repository)

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
-- AXI cores
use work.bpm_axi_pkg.all;

entity xwb_acq_core is
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
  wb_slv_i                                  : in t_wishbone_slave_in;
  wb_slv_o                                  : out t_wishbone_slave_out;

  -----------------------------
  -- External Interface
  -----------------------------
  acq_chan_array_i                          : in t_acq_chan_array(g_acq_num_channels-1 downto 0);

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
  -- Xilinx UI DDR3 SDRAM Interface (choose between UI and AXIS with g_ddr_interface_type)
  -----------------------------
  ui_app_addr_o                             : out std_logic_vector(g_ddr_addr_width-1 downto 0);
  ui_app_cmd_o                              : out std_logic_vector(2 downto 0);
  ui_app_en_o                               : out std_logic;
  ui_app_rdy_i                              : in std_logic := '0';

  ui_app_wdf_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  ui_app_wdf_end_o                          : out std_logic;
  ui_app_wdf_mask_o                         : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
  ui_app_wdf_wren_o                         : out std_logic;
  ui_app_wdf_rdy_i                          : in std_logic := '0';

  ui_app_rd_data_i                          : in std_logic_vector(g_ddr_payload_width-1 downto 0) := (others => '0');
  ui_app_rd_data_end_i                      : in std_logic := '0';
  ui_app_rd_data_valid_i                    : in std_logic := '0';

  ui_app_req_o                              : out std_logic;
  ui_app_gnt_i                              : in std_logic := '0';

  -----------------------------
  -- AXIS DDR3 SDRAM Interface (choose between UI and AXIS with g_ddr_interface_type)
  -----------------------------
  -- AXIS Read Channel
  axis_mm2s_cmd_ma_i                        : in t_axis_cmd_master_in := cc_dummy_axis_cmd_master_in;
  axis_mm2s_cmd_ma_o                        : out t_axis_cmd_master_out;
  axis_mm2s_pld_sl_i                        : in t_axis_pld_slave_in := cc_dummy_axis_pld_slave_in;
  axis_mm2s_pld_sl_o                        : out t_axis_pld_slave_out;
  -- AXIMM Write Channel
  axis_s2mm_cmd_ma_i                        : in t_axis_cmd_master_in := cc_dummy_axis_cmd_master_in;
  axis_s2mm_cmd_ma_o                        : out t_axis_cmd_master_out;
  axis_s2mm_pld_ma_i                        : in t_axis_pld_master_in := cc_dummy_axis_pld_master_in;
  axis_s2mm_pld_ma_o                        : out t_axis_pld_master_out;

  -----------------------------
  -- Debug Interface
  -----------------------------
  dbg_ddr_rb_start_p_i                      : in std_logic;
  dbg_ddr_rb_rdy_o                          : out std_logic;
  dbg_ddr_rb_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  dbg_ddr_rb_addr_o                         : out std_logic_vector(g_acq_addr_width-1 downto 0);
  dbg_ddr_rb_valid_o                        : out std_logic
);
end xwb_acq_core;

architecture rtl of xwb_acq_core is

  signal acq_val_low_array                  : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq_val_high_array                 : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq_id_array                       : t_acq_id_array(g_acq_num_channels-1 downto 0);
  signal acq_dvalid_array                   : std_logic_vector(g_acq_num_channels-1 downto 0);
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
    -- Xilinx UI DDR3 SDRAM Interface
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
    -- AXIS UI DDR3 SDRAM Interface
    -----------------------------
    axis_mm2s_cmd_tdata_o                     => axis_mm2s_cmd_ma_o.tdata,
    axis_mm2s_cmd_tvalid_o                    => axis_mm2s_cmd_ma_o.tvalid,
    axis_mm2s_cmd_tready_i                    => axis_mm2s_cmd_ma_i.tready,

    axis_mm2s_pld_tdata_i                     => axis_mm2s_pld_sl_i.tdata,
    axis_mm2s_pld_tkeep_i                     => axis_mm2s_pld_sl_i.tkeep,
    axis_mm2s_pld_tlast_i                     => axis_mm2s_pld_sl_i.tlast,
    axis_mm2s_pld_tvalid_i                    => axis_mm2s_pld_sl_i.tvalid,
    axis_mm2s_pld_tready_o                    => axis_mm2s_pld_sl_o.tready,

    axis_s2mm_cmd_tdata_o                     => axis_s2mm_cmd_ma_o.tdata,
    axis_s2mm_cmd_tvalid_o                    => axis_s2mm_cmd_ma_o.tvalid,
    axis_s2mm_cmd_tready_i                    => axis_s2mm_cmd_ma_i.tready,

    axis_s2mm_rstn_o                          => axis_s2mm_cmd_ma_o.rstn,
    axis_s2mm_halt_o                          => axis_s2mm_cmd_ma_o.halt,
    axis_s2mm_halt_cmplt_i                    => axis_s2mm_cmd_ma_i.halt_cmplt,
    axis_s2mm_allow_addr_req_o                => axis_s2mm_cmd_ma_o.allow_addr_req,
    axis_s2mm_addr_req_posted_i               => axis_s2mm_cmd_ma_i.addr_req_posted,
    axis_s2mm_wr_xfer_cmplt_i                 => axis_s2mm_cmd_ma_i.wr_xfer_cmplt,
    axis_s2mm_ld_nxt_len_i                    => axis_s2mm_cmd_ma_i.ld_nxt_len,
    axis_s2mm_wr_len_i                        => axis_s2mm_cmd_ma_i.wr_len,

    axis_s2mm_pld_tdata_o                     => axis_s2mm_pld_ma_o.tdata,
    axis_s2mm_pld_tkeep_o                     => axis_s2mm_pld_ma_o.tkeep,
    axis_s2mm_pld_tlast_o                     => axis_s2mm_pld_ma_o.tlast,
    axis_s2mm_pld_tvalid_o                    => axis_s2mm_pld_ma_o.tvalid,
    axis_s2mm_pld_tready_i                    => axis_s2mm_pld_ma_i.tready,

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

    acq_val_low_array(i)      <= acq_chan_array_i(i).val_low;
    acq_val_high_array(i)     <= acq_chan_array_i(i).val_high;
    acq_dvalid_array(i)       <= acq_chan_array_i(i).dvalid;
    acq_trig_array(i)         <= acq_chan_array_i(i).trig;
    acq_id_array(i)           <= acq_chan_array_i(i).id;

  end generate;

end rtl;
