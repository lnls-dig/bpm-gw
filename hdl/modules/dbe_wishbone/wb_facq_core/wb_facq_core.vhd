------------------------------------------------------------------------------
-- Title      : BPM Flexible Data Acquisition Wrapper
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2016-05-07
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Flexible Data Acquisition Wrapper. It just wraps the data input interface
--              into a more flexible one: independent input data width and rate
-------------------------------------------------------------------------------
-- Copyright (c) 2016 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2016-05-07  1.0      lucas.russo        Created
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
-- AXI cores
use work.bpm_axi_pkg.all;
-- Platform ipcores
use work.ipcores_pkg.all;

entity wb_facq_core is
generic
(
  g_interface_mode                          : t_wishbone_interface_mode      := CLASSIC;
  g_address_granularity                     : t_wishbone_address_granularity := WORD;
  g_acq_addr_width                          : natural := 32;
  g_acq_num_channels                        : natural := c_default_acq_num_channels;
  g_facq_channels                           : t_facq_chan_param_array := c_default_facq_chan_param_array;
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
  acq_val_i                                 : in t_acq_val_cmplt_array(g_acq_num_channels-1 downto 0);
  acq_dvalid_i                              : in std_logic_vector(g_acq_num_channels-1 downto 0);
  acq_trig_i                                : in std_logic_vector(g_acq_num_channels-1 downto 0);

  -----------------------------
  -- DRRAM Interface
  -----------------------------
  dpram_dout_o                              : out std_logic_vector(f_acq_chan_find_widest(f_conv_facq_to_acq_chan_array(g_facq_channels))-1 downto 0);
  dpram_valid_o                             : out std_logic;

  -----------------------------
  -- External Interface (w/ FLow Control)
  -----------------------------
  ext_dout_o                                : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  ext_valid_o                               : out std_logic;
  ext_addr_o                                : out std_logic_vector(g_acq_addr_width-1 downto 0);
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
  axis_s2mm_cmd_tdata_o                     : out std_logic_vector(71 downto 0);
  axis_s2mm_cmd_tvalid_o                    : out std_logic;
  axis_s2mm_cmd_tready_i                    : in std_logic := '0';

  axis_s2mm_pld_tdata_o                     : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  axis_s2mm_pld_tkeep_o                     : out std_logic_vector(g_ddr_payload_width/8-1 downto 0);
  axis_s2mm_pld_tlast_o                     : out std_logic;
  axis_s2mm_pld_tvalid_o                    : out std_logic;
  axis_s2mm_pld_tready_i                    : in std_logic := '0';

  axis_s2mm_rstn_o                          : out std_logic;
  axis_s2mm_halt_o                          : out std_logic;
  axis_s2mm_halt_cmplt_i                    : in  std_logic := '0';
  axis_s2mm_allow_addr_req_o                : out std_logic;
  axis_s2mm_addr_req_posted_i               : in  std_logic := '0';
  axis_s2mm_wr_xfer_cmplt_i                 : in  std_logic := '0';
  axis_s2mm_ld_nxt_len_i                    : in  std_logic := '0';
  axis_s2mm_wr_len_i                        : in  std_logic_vector(7 downto 0) := (others => '0');

  axis_mm2s_cmd_tdata_o                     : out std_logic_vector(71 downto 0);
  axis_mm2s_cmd_tvalid_o                    : out std_logic;
  axis_mm2s_cmd_tready_i                    : in std_logic := '0';

  axis_mm2s_pld_tdata_i                     : in std_logic_vector(g_ddr_payload_width-1 downto 0) := (others => '0');
  axis_mm2s_pld_tkeep_i                     : in std_logic_vector(g_ddr_payload_width/8-1 downto 0) := (others => '0');
  axis_mm2s_pld_tlast_i                     : in std_logic := '0';
  axis_mm2s_pld_tvalid_i                    : in std_logic := '0';
  axis_mm2s_pld_tready_o                    : out std_logic;

  -----------------------------
  -- Debug Interface
  -----------------------------
  dbg_ddr_rb_start_p_i                      : in std_logic;
  dbg_ddr_rb_rdy_o                          : out std_logic;
  dbg_ddr_rb_data_o                         : out std_logic_vector(g_ddr_payload_width-1 downto 0);
  dbg_ddr_rb_addr_o                         : out std_logic_vector(g_acq_addr_width-1 downto 0);
  dbg_ddr_rb_valid_o                        : out std_logic
);
end wb_facq_core;

architecture rtl of wb_facq_core is

  constant c_acq_channels                   : t_acq_chan_param_array(g_acq_num_channels-1 downto 0) :=
                                                  f_conv_facq_to_acq_chan_array(g_facq_channels);
  constant c_narrowest_channel_width        : natural := f_acq_chan_find_narrowest(c_acq_channels);
  constant c_widest_channel_width           : natural := f_acq_chan_find_widest(c_acq_channels);
  constant c_min_channel_width              : natural := c_acq_chan_width;
  constant c_max_channel_width              : natural := c_acq_chan_max_w;
  constant c_curr_acq_id_width              : natural := f_log2_size(c_widest_channel_width/c_narrowest_channel_width + 1);

  signal acq_val_plain_low_unpack_array      : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq_val_plain_high_unpack_array     : t_acq_val_half_array(g_acq_num_channels-1 downto 0);
  signal acq_val_full_unpack_array           : t_acq_val_full_plain_array(g_acq_num_channels-1 downto 0);
  signal acq_dvalid_unpack                   : std_logic_vector(g_acq_num_channels-1 downto 0);
  signal acq_val_id_unpack                   : t_acq_id_array(g_acq_num_channels-1 downto 0) := (others => (others => '0'));
  signal acq_trig_unpack                     : std_logic_vector(g_acq_num_channels-1 downto 0);

begin

  assert (c_widest_channel_width <= c_acq_chan_cmplt_width)
  report "[wb_facq_core] Found channel width of " &
    Integer'image(c_widest_channel_width) &
    ", but channels' width must not exceed maximum channel width of " &
    Integer'image(c_acq_chan_cmplt_width)
  severity failure;

  assert (c_narrowest_channel_width >= c_min_channel_width)
  report "[wb_facq_core] Found channel width of " &
    Integer'image(c_narrowest_channel_width) &
    ", but channels' width must be at least " &
    Integer'image(c_min_channel_width)
  severity failure;

  gen_word_packer : for i in 0 to g_acq_num_channels-1 generate

    gen_packer_narrow : if g_facq_channels(i).width < c_max_channel_width generate

      -- If we are narrower than c_max_channel_width we must at least divide
      -- c_min_channel_width
      assert (g_facq_channels(i).width mod c_min_channel_width = 0)
      report "[wb_facq_core] g_facq_channels(" & Integer'image(i) &
      ").width must divide c_min_channel_width (" & Integer'image(c_min_channel_width) &
      ")"
      severity failure;

      cmp_gc_word_packer : gc_word_packer
      generic map (
        g_input_width                        => to_integer(g_facq_channels(i).width),
        g_output_width                       => c_min_channel_width
      )
      port map (
        clk_i                                => fs_clk_i,
        rst_n_i                              => fs_rst_n_i,

        d_i                                  => acq_val_i(i)(to_integer(g_facq_channels(i).width)-1 downto 0),
        d_valid_i                            => acq_dvalid_i(i),
        d_req_o                              => open,

        q_o                                  => acq_val_full_unpack_array(i)(c_min_channel_width-1 downto 0),
        q_id_o                               => acq_val_id_unpack(i)(f_log2_size(to_integer(g_facq_channels(i).width)/c_min_channel_width + 1) -1 downto 0),
        q_valid_o                            => acq_dvalid_unpack(i),
        q_req_i                              => '1'
      );

    end generate;

    gen_packer_wider : if g_facq_channels(i).width >= c_max_channel_width generate

      assert (g_facq_channels(i).width mod c_max_channel_width = 0)
      report "[wb_facq_core] g_facq_channels(" & Integer'image(i) &
      ").width must divide c_max_channel_width (" & Integer'image(c_max_channel_width) &
      ")"
      severity failure;

      cmp_gc_word_packer : gc_word_packer
      generic map (
        g_input_width                        => to_integer(g_facq_channels(i).width),
        g_output_width                       => c_max_channel_width
      )
      port map (
        clk_i                                => fs_clk_i,
        rst_n_i                              => fs_rst_n_i,

        d_i                                  => acq_val_i(i)(to_integer(g_facq_channels(i).width)-1 downto 0),
        d_valid_i                            => acq_dvalid_i(i),
        d_req_o                              => open,

        q_o                                  => acq_val_full_unpack_array(i)(c_max_channel_width-1 downto 0),
        q_id_o                               => acq_val_id_unpack(i)(f_log2_size(to_integer(g_facq_channels(i).width)/c_max_channel_width + 1) -1 downto 0),
        q_valid_o                            => acq_dvalid_unpack(i),
        q_req_i                              => '1'
      );

    end generate;

    acq_val_plain_low_unpack_array(i)   <= acq_val_full_unpack_array(i)(c_acq_chan_width-1 downto 0);
    acq_val_plain_high_unpack_array(i)  <= acq_val_full_unpack_array(i)(c_acq_chan_max_w-1 downto c_acq_chan_width);

    -- Simple trigger bypass. FIXME: normalize latency between data and trigger channels?
    acq_trig_unpack(i) <= acq_trig_i(i);

  end generate;

  -----------------------------------------------------------------------------
  -- ACQ CORE
  -----------------------------------------------------------------------------
  cmp_wb_acq_core : wb_acq_core
  generic map
  (
    g_interface_mode                          => g_interface_mode,
    g_address_granularity                     => g_address_granularity,
    g_acq_addr_width                          => g_acq_addr_width,
    g_acq_num_channels                        => g_acq_num_channels,
    g_acq_channels                            => c_acq_channels,
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
    acq_val_low_i                             => acq_val_plain_low_unpack_array,
    acq_val_high_i                            => acq_val_plain_high_unpack_array,
    acq_dvalid_i                              => acq_dvalid_unpack,
    acq_id_i                                  => acq_val_id_unpack,
    acq_trig_i                                => acq_trig_unpack,

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
    axis_mm2s_cmd_tdata_o                     => axis_mm2s_cmd_tdata_o,
    axis_mm2s_cmd_tvalid_o                    => axis_mm2s_cmd_tvalid_o,
    axis_mm2s_cmd_tready_i                    => axis_mm2s_cmd_tready_i,

    axis_mm2s_pld_tdata_i                     => axis_mm2s_pld_tdata_i,
    axis_mm2s_pld_tkeep_i                     => axis_mm2s_pld_tkeep_i,
    axis_mm2s_pld_tlast_i                     => axis_mm2s_pld_tlast_i,
    axis_mm2s_pld_tvalid_i                    => axis_mm2s_pld_tvalid_i,
    axis_mm2s_pld_tready_o                    => axis_mm2s_pld_tready_o,

    axis_s2mm_cmd_tdata_o                     => axis_s2mm_cmd_tdata_o,
    axis_s2mm_cmd_tvalid_o                    => axis_s2mm_cmd_tvalid_o,
    axis_s2mm_cmd_tready_i                    => axis_s2mm_cmd_tready_i,

    axis_s2mm_rstn_o                          => axis_s2mm_rstn_o,
    axis_s2mm_halt_o                          => axis_s2mm_halt_o,
    axis_s2mm_halt_cmplt_i                    => axis_s2mm_halt_cmplt_i,
    axis_s2mm_allow_addr_req_o                => axis_s2mm_allow_addr_req_o,
    axis_s2mm_addr_req_posted_i               => axis_s2mm_addr_req_posted_i,
    axis_s2mm_wr_xfer_cmplt_i                 => axis_s2mm_wr_xfer_cmplt_i,
    axis_s2mm_ld_nxt_len_i                    => axis_s2mm_ld_nxt_len_i,
    axis_s2mm_wr_len_i                        => axis_s2mm_wr_len_i,

    axis_s2mm_pld_tdata_o                     => axis_s2mm_pld_tdata_o,
    axis_s2mm_pld_tkeep_o                     => axis_s2mm_pld_tkeep_o,
    axis_s2mm_pld_tlast_o                     => axis_s2mm_pld_tlast_o,
    axis_s2mm_pld_tvalid_o                    => axis_s2mm_pld_tvalid_o,
    axis_s2mm_pld_tready_i                    => axis_s2mm_pld_tready_i,

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_i                      => dbg_ddr_rb_start_p_i,
    dbg_ddr_rb_rdy_o                          => dbg_ddr_rb_rdy_o,
    dbg_ddr_rb_data_o                         => dbg_ddr_rb_data_o,
    dbg_ddr_rb_addr_o                         => dbg_ddr_rb_addr_o,
    dbg_ddr_rb_valid_o                        => dbg_ddr_rb_valid_o
  );

end rtl;
