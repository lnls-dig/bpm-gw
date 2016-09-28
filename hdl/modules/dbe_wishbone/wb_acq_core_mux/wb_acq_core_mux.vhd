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
-- AXI cores
use work.bpm_axi_pkg.all;
-- Platform ipcores
use work.ipcores_pkg.all;

entity wb_acq_core_mux is
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
  g_acq_num_cores                           : natural := 2;
  g_ddr_interface_type                      : string  := "AXIS";
  g_max_burst_size                          : natural := 4
);
port
(
  -- Clock signals
  fs_clk_array_i                            : in std_logic_vector(g_acq_num_cores-1 downto 0);
  fs_ce_array_i                             : in std_logic_vector(g_acq_num_cores-1 downto 0);
  fs_rst_n_array_i                          : in std_logic_vector(g_acq_num_cores-1 downto 0);

  -- Clock signals for Wishbone
  sys_clk_i                                 : in std_logic;
  sys_rst_n_i                               : in std_logic;

  -- Clock signals for External Memory
  ext_clk_i                                 : in std_logic;
  ext_rst_n_i                               : in std_logic;

  -----------------------------
  -- Wishbone Control Interface signals
  -----------------------------

  wb_adr_array_i                            : in  std_logic_vector(g_acq_num_cores*c_wishbone_address_width-1 downto 0) := (others => '0');
  wb_dat_array_i                            : in  std_logic_vector(g_acq_num_cores*c_wishbone_data_width-1 downto 0) := (others => '0');
  wb_dat_array_o                            : out std_logic_vector(g_acq_num_cores*c_wishbone_data_width-1 downto 0);
  wb_sel_array_i                            : in  std_logic_vector(g_acq_num_cores*c_wishbone_data_width/8-1 downto 0) := (others => '0');
  wb_we_array_i                             : in  std_logic_vector(g_acq_num_cores-1 downto 0) := (others => '0');
  wb_cyc_array_i                            : in  std_logic_vector(g_acq_num_cores-1 downto 0) := (others => '0');
  wb_stb_array_i                            : in  std_logic_vector(g_acq_num_cores-1 downto 0) := (others => '0');
  wb_ack_array_o                            : out std_logic_vector(g_acq_num_cores-1 downto 0);
  wb_err_array_o                            : out std_logic_vector(g_acq_num_cores-1 downto 0);
  wb_rty_array_o                            : out std_logic_vector(g_acq_num_cores-1 downto 0);
  wb_stall_array_o                          : out std_logic_vector(g_acq_num_cores-1 downto 0);

  -----------------------------
  -- External Interface
  -----------------------------
  acq_val_low_array_i                       : in t_acq_val_half_array(g_acq_num_cores*g_acq_num_channels-1 downto 0);
  acq_val_high_array_i                      : in t_acq_val_half_array(g_acq_num_cores*g_acq_num_channels-1 downto 0);
  acq_dvalid_array_i                        : in std_logic_vector(g_acq_num_cores*g_acq_num_channels-1 downto 0);
  acq_id_array_i                            : in t_acq_id_array(g_acq_num_cores*g_acq_num_channels-1 downto 0);
  acq_trig_array_i                          : in std_logic_vector(g_acq_num_cores*g_acq_num_channels-1 downto 0);

  -----------------------------
  -- DRRAM Interface
  -----------------------------
  dpram_dout_array_o                        : out std_logic_vector(g_acq_num_cores*f_acq_chan_find_widest(g_acq_channels)-1 downto 0);
  dpram_valid_array_o                       : out std_logic_vector(g_acq_num_cores-1 downto 0);

  -----------------------------
  -- External Interface (w/ FLow Control)
  -----------------------------
  ext_dout_array_o                          : out std_logic_vector(g_acq_num_cores*g_ddr_payload_width-1 downto 0);
  ext_valid_array_o                         : out std_logic_vector(g_acq_num_cores-1 downto 0);
  ext_addr_array_o                          : out std_logic_vector(g_acq_num_cores*g_acq_addr_width-1 downto 0);
  ext_sof_array_o                           : out std_logic_vector(g_acq_num_cores-1 downto 0);
  ext_eof_array_o                           : out std_logic_vector(g_acq_num_cores-1 downto 0);
  ext_dreq_array_o                          : out std_logic_vector(g_acq_num_cores-1 downto 0); -- for debbuging purposes
  ext_stall_array_o                         : out std_logic_vector(g_acq_num_cores-1 downto 0); -- for debbuging purposes

  -----------------------------
  -- Debug Interface
  -----------------------------
  dbg_ddr_rb_start_p_array_i                : in std_logic_vector(g_acq_num_cores-1 downto 0);
  dbg_ddr_rb_rdy_array_o                    : out std_logic_vector(g_acq_num_cores-1 downto 0);
  dbg_ddr_rb_data_array_o                   : out std_logic_vector(g_acq_num_cores*g_ddr_payload_width-1 downto 0);
  dbg_ddr_rb_addr_array_o                   : out std_logic_vector(g_acq_num_cores*g_acq_addr_width-1 downto 0);
  dbg_ddr_rb_valid_array_o                  : out std_logic_vector(g_acq_num_cores-1 downto 0);

  -----------------------------
  -- DDR3 SDRAM Interface
  -----------------------------
  ddr_aximm_ma_awid_o                       : out std_logic_vector (3 downto 0);
  ddr_aximm_ma_awaddr_o                     : out std_logic_vector (31 downto 0);
  ddr_aximm_ma_awlen_o                      : out std_logic_vector (7 downto 0);
  ddr_aximm_ma_awsize_o                     : out std_logic_vector (2 downto 0);
  ddr_aximm_ma_awburst_o                    : out std_logic_vector (1 downto 0);
  ddr_aximm_ma_awlock_o                     : out std_logic;
  ddr_aximm_ma_awcache_o                    : out std_logic_vector (3 downto 0);
  ddr_aximm_ma_awprot_o                     : out std_logic_vector (2 downto 0);
  ddr_aximm_ma_awqos_o                      : out std_logic_vector (3 downto 0);
  ddr_aximm_ma_awvalid_o                    : out std_logic;
  ddr_aximm_ma_awready_i                    : in std_logic;
  ddr_aximm_ma_wdata_o                      : out std_logic_vector (g_ddr_payload_width-1 downto 0);
  ddr_aximm_ma_wstrb_o                      : out std_logic_vector (g_ddr_payload_width/8-1 downto 0);
  ddr_aximm_ma_wlast_o                      : out std_logic;
  ddr_aximm_ma_wvalid_o                     : out std_logic;
  ddr_aximm_ma_wready_i                     : in std_logic;
  ddr_aximm_ma_bready_o                     : out std_logic;
  ddr_aximm_ma_bid_i                        : in std_logic_vector (3 downto 0);
  ddr_aximm_ma_bresp_i                      : in std_logic_vector (1 downto 0);
  ddr_aximm_ma_bvalid_i                     : in std_logic;
  ddr_aximm_ma_arid_o                       : out std_logic_vector (3 downto 0);
  ddr_aximm_ma_araddr_o                     : out std_logic_vector (31 downto 0);
  ddr_aximm_ma_arlen_o                      : out std_logic_vector (7 downto 0);
  ddr_aximm_ma_arsize_o                     : out std_logic_vector (2 downto 0);
  ddr_aximm_ma_arburst_o                    : out std_logic_vector (1 downto 0);
  ddr_aximm_ma_arlock_o                     : out std_logic;
  ddr_aximm_ma_arcache_o                    : out std_logic_vector (3 downto 0);
  ddr_aximm_ma_arprot_o                     : out std_logic_vector (2 downto 0);
  ddr_aximm_ma_arqos_o                      : out std_logic_vector (3 downto 0);
  ddr_aximm_ma_arvalid_o                    : out std_logic;
  ddr_aximm_ma_arready_i                    : in std_logic;
  ddr_aximm_ma_rready_o                     : out std_logic;
  ddr_aximm_ma_rid_i                        : in std_logic_vector (3 downto 0);
  ddr_aximm_ma_rdata_i                      : in std_logic_vector (g_ddr_payload_width-1 downto 0);
  ddr_aximm_ma_rresp_i                      : in std_logic_vector (1 downto 0);
  ddr_aximm_ma_rlast_i                      : in std_logic;
  ddr_aximm_ma_rvalid_i                     : in std_logic
);
end wb_acq_core_mux;

architecture rtl of wb_acq_core_mux is

  constant c_num_max_acq_cores              : natural := 8;

  -- AXI Data mover signals
  signal axi_rst_n_array                    : std_logic_vector(c_num_max_acq_cores-1 downto 0);
  signal axis_s2mm_rst_n_array_or           : std_logic_vector(c_num_max_acq_cores-1 downto 0);
  signal axis_mm2s_rst_n_array_or           : std_logic_vector(c_num_max_acq_cores-1 downto 0);

  signal axis_mm2s_cmd_mo_array             : t_axis_cmd_master_out_array(g_acq_num_cores-1 downto 0);
  signal axis_mm2s_cmd_mi_array             : t_axis_cmd_master_in_array(g_acq_num_cores-1 downto 0);

  signal axis_mm2s_sts_mo_array             : t_axis_sts_master_out_array(g_acq_num_cores-1 downto 0);
  signal axis_mm2s_sts_mi_array             : t_axis_sts_master_in_array(g_acq_num_cores-1 downto 0);

  signal axi_mm2s_r_mo_array                : t_aximm_r_master_out_array(c_num_max_acq_cores-1 downto 0);
  signal axi_mm2s_r_mi_array                : t_aximm_r_master_in_array(c_num_max_acq_cores-1 downto 0);

  signal axis_mm2s_pld_mo_array             : t_axis_pld_master_out_array(g_acq_num_cores-1 downto 0);
  signal axis_mm2s_pld_mi_array             : t_axis_pld_master_in_array(g_acq_num_cores-1 downto 0);

  signal axis_s2mm_cmd_mo_array             : t_axis_cmd_master_out_array(g_acq_num_cores-1 downto 0);
  signal axis_s2mm_cmd_mi_array             : t_axis_cmd_master_in_array(g_acq_num_cores-1 downto 0);

  signal axis_s2mm_sts_mo_array             : t_axis_sts_master_out_array(g_acq_num_cores-1 downto 0);
  signal axis_s2mm_sts_mi_array             : t_axis_sts_master_in_array(g_acq_num_cores-1 downto 0);

  signal axi_s2mm_w_mo_array                : t_aximm_w_master_out_array(c_num_max_acq_cores-1 downto 0);
  signal axi_s2mm_w_mi_array                : t_aximm_w_master_in_array(c_num_max_acq_cores-1 downto 0);

  signal axis_s2mm_pld_mo_array             : t_axis_pld_master_out_array(g_acq_num_cores-1 downto 0);
  signal axis_s2mm_pld_mi_array             : t_axis_pld_master_in_array(g_acq_num_cores-1 downto 0);

  type t_aximm_delay_array is array(natural range <>) of std_logic_vector(7 downto 0);
  signal axis_s2mm_ready_d_array            : t_aximm_delay_array(g_acq_num_cores-1 downto 0);
  type t_aximm_last_array is array(natural range <>) of std_logic;
  signal axis_s2mm_last_array               : t_aximm_last_array(g_acq_num_cores-1 downto 0);
  type t_aximm_valid_cnt_array is array(natural range <>) of unsigned(1 downto 0);
  signal axis_s2mm_valid_cnt_array            : t_aximm_valid_cnt_array(g_acq_num_cores-1 downto 0);
  signal axis_mm2s_valid_cnt_array            : t_aximm_valid_cnt_array(g_acq_num_cores-1 downto 0);

begin

  assert (g_acq_num_cores <= c_num_max_acq_cores)
    report "[wb_acq_core_mux] Number of acqsition cores exceeded (8)"
    severity Failure;

  assert (g_ddr_interface_type = "AXIS")
    report "[wb_acq_core_mux] Currently, we only support AXIS interface type"
    severity Failure;

  -----------------------------------------------------------------------------
  -- ACQ CORE
  -----------------------------------------------------------------------------
  gen_acq_core : for i in g_acq_num_cores-1 downto 0 generate

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
      fs_clk_i                                  => fs_clk_array_i(i),
      fs_ce_i                                   => fs_ce_array_i(i),
      fs_rst_n_i                                => fs_rst_n_array_i(i),

      sys_clk_i                                 => sys_clk_i,
      sys_rst_n_i                               => sys_rst_n_i,

      ext_clk_i                                 => ext_clk_i,
      ext_rst_n_i                               => ext_rst_n_i,

      -----------------------------
      -- Wishbone Control Interface signals
      -----------------------------

      wb_adr_i                                  => wb_adr_array_i((i+1)*c_wishbone_address_width-1 downto i*c_wishbone_address_width),
      wb_dat_i                                  => wb_dat_array_i((i+1)*c_wishbone_data_width-1 downto i*c_wishbone_data_width),
      wb_dat_o                                  => wb_dat_array_o((i+1)*c_wishbone_data_width-1 downto i*c_wishbone_data_width),
      wb_sel_i                                  => wb_sel_array_i((i+1)*c_wishbone_data_width/8-1 downto i*c_wishbone_data_width/8),
      wb_we_i                                   => wb_we_array_i(i),
      wb_cyc_i                                  => wb_cyc_array_i(i),
      wb_stb_i                                  => wb_stb_array_i(i),
      wb_ack_o                                  => wb_ack_array_o(i),
      wb_err_o                                  => wb_err_array_o(i),
      wb_rty_o                                  => wb_rty_array_o(i),
      wb_stall_o                                => wb_stall_array_o(i),

      -----------------------------
      -- External Interface
      -----------------------------
      acq_val_low_i                             => acq_val_low_array_i((i+1)*g_acq_num_channels-1 downto i*g_acq_num_channels),
      acq_val_high_i                            => acq_val_high_array_i((i+1)*g_acq_num_channels-1 downto i*g_acq_num_channels),
      acq_dvalid_i                              => acq_dvalid_array_i((i+1)*g_acq_num_channels-1 downto i*g_acq_num_channels),
      acq_id_i                                  => acq_id_array_i((i+1)*g_acq_num_channels-1 downto i*g_acq_num_channels),
      acq_trig_i                                => acq_trig_array_i((i+1)*g_acq_num_channels-1 downto i*g_acq_num_channels),

      -----------------------------
      -- DRRAM Interface
      -----------------------------
      dpram_dout_o                              => dpram_dout_array_o((i+1)*f_acq_chan_find_widest(g_acq_channels)-1 downto
                                                     i*f_acq_chan_find_widest(g_acq_channels)),
      dpram_valid_o                             => dpram_valid_array_o(i),

      -----------------------------
      -- External Interface (w/ FLow Control)
      -----------------------------
      ext_dout_o                                => ext_dout_array_o((i+1)*g_ddr_payload_width-1 downto i*g_ddr_payload_width),
      ext_valid_o                               => ext_valid_array_o(i),
      ext_addr_o                                => ext_addr_array_o((i+1)*g_acq_addr_width-1 downto i*g_acq_addr_width),
      ext_sof_o                                 => ext_sof_array_o(i),
      ext_eof_o                                 => ext_eof_array_o(i),
      ext_dreq_o                                => ext_dreq_array_o(i),
      ext_stall_o                               => ext_stall_array_o(i),

    -----------------------------
    -- AXIS DDR3 SDRAM Interface (choose between UI and AXIS with g_ddr_interface_type)
    -----------------------------

      axis_s2mm_cmd_tdata_o                     => axis_s2mm_cmd_mo_array(i).tdata,
      axis_s2mm_cmd_tvalid_o                    => axis_s2mm_cmd_mo_array(i).tvalid,
      axis_s2mm_cmd_tready_i                    => axis_s2mm_cmd_mi_array(i).tready,

      axis_s2mm_rstn_o                          => axis_s2mm_cmd_mo_array(i).rstn,
      axis_s2mm_halt_o                          => axis_s2mm_cmd_mo_array(i).halt,
      axis_s2mm_halt_cmplt_i                    => axis_s2mm_cmd_mi_array(i).halt_cmplt,
      axis_s2mm_allow_addr_req_o                => axis_s2mm_cmd_mo_array(i).allow_addr_req,
      axis_s2mm_addr_req_posted_i               => axis_s2mm_cmd_mi_array(i).addr_req_posted,
      axis_s2mm_wr_xfer_cmplt_i                 => axis_s2mm_cmd_mi_array(i).wr_xfer_cmplt,
      axis_s2mm_ld_nxt_len_i                    => axis_s2mm_cmd_mi_array(i).ld_nxt_len,
      axis_s2mm_wr_len_i                        => axis_s2mm_cmd_mi_array(i).wr_len,

      axis_s2mm_pld_tdata_o                     => axis_s2mm_pld_mo_array(i).tdata,
      axis_s2mm_pld_tkeep_o                     => axis_s2mm_pld_mo_array(i).tkeep,
      axis_s2mm_pld_tlast_o                     => axis_s2mm_pld_mo_array(i).tlast,
      axis_s2mm_pld_tvalid_o                    => axis_s2mm_pld_mo_array(i).tvalid,
      axis_s2mm_pld_tready_i                    => axis_s2mm_pld_mi_array(i).tready,

      axis_mm2s_cmd_tdata_o                     => axis_mm2s_cmd_mo_array(i).tdata,
      axis_mm2s_cmd_tvalid_o                    => axis_mm2s_cmd_mo_array(i).tvalid,
      axis_mm2s_cmd_tready_i                    => axis_mm2s_cmd_mi_array(i).tready,

      axis_mm2s_pld_tdata_i                     => axis_mm2s_pld_mo_array(i).tdata,
      axis_mm2s_pld_tkeep_i                     => axis_mm2s_pld_mo_array(i).tkeep,
      axis_mm2s_pld_tlast_i                     => axis_mm2s_pld_mo_array(i).tlast,
      axis_mm2s_pld_tvalid_i                    => axis_mm2s_pld_mo_array(i).tvalid,
      axis_mm2s_pld_tready_o                    => axis_mm2s_pld_mi_array(i).tready,

      -----------------------------
      -- Debug Interface
      -----------------------------
      dbg_ddr_rb_start_p_i                      => dbg_ddr_rb_start_p_array_i(i),
      dbg_ddr_rb_rdy_o                          => dbg_ddr_rb_rdy_array_o(i),
      dbg_ddr_rb_data_o                         => dbg_ddr_rb_data_array_o((i+1)*g_ddr_payload_width-1 downto i*g_ddr_payload_width),
      dbg_ddr_rb_addr_o                         => dbg_ddr_rb_addr_array_o((i+1)*g_acq_addr_width-1 downto i*g_acq_addr_width),
      dbg_ddr_rb_valid_o                        => dbg_ddr_rb_valid_array_o(i)
    );

  end generate;

  -----------------------------------------------------------------------------
  -- AXIS Datamover
  -----------------------------------------------------------------------------
  gen_axis_data_mover : for i in g_acq_num_cores-1 downto 0 generate
    cmp_axi_s2mm_bridge : axi_datamover_bpm
    port map (
      -- Memory Mapped to Stream
      m_axi_mm2s_aclk                          => ext_clk_i,
      m_axi_mm2s_aresetn                       => axis_mm2s_rst_n_array_or(i),
      mm2s_err                                 => open,
      m_axis_mm2s_cmdsts_aclk                  => ext_clk_i,
      m_axis_mm2s_cmdsts_aresetn               => axis_mm2s_rst_n_array_or(i),

      s_axis_mm2s_cmd_tvalid                   => axis_mm2s_cmd_mo_array(i).tvalid,
      s_axis_mm2s_cmd_tready                   => axis_mm2s_cmd_mi_array(i).tready,
      s_axis_mm2s_cmd_tdata                    => axis_mm2s_cmd_mo_array(i).tdata,

      s2mm_halt                                => axis_s2mm_cmd_mo_array(i).halt,
      s2mm_halt_cmplt                          => axis_s2mm_cmd_mi_array(i).halt_cmplt,
      s2mm_allow_addr_req                      => axis_s2mm_cmd_mo_array(i).allow_addr_req,
      s2mm_addr_req_posted                     => axis_s2mm_cmd_mi_array(i).addr_req_posted,
      s2mm_wr_xfer_cmplt                       => axis_s2mm_cmd_mi_array(i).wr_xfer_cmplt,
      s2mm_ld_nxt_len                          => axis_s2mm_cmd_mi_array(i).ld_nxt_len,
      s2mm_wr_len                              => axis_s2mm_cmd_mi_array(i).wr_len,
      s2mm_dbg_sel                             => c_axi_dbg_sel_zeros,
      s2mm_dbg_data                            => open,

      m_axis_mm2s_sts_tvalid                   => open,
      m_axis_mm2s_sts_tready                   => c_axi_sl_one,
      m_axis_mm2s_sts_tdata                    => open,
      m_axis_mm2s_sts_tkeep                    => open,
      m_axis_mm2s_sts_tlast                    => open,

      m_axi_mm2s_araddr                        => axi_mm2s_r_mo_array(i).araddr,
      m_axi_mm2s_arlen                         => axi_mm2s_r_mo_array(i).arlen,
      m_axi_mm2s_arsize                        => axi_mm2s_r_mo_array(i).arsize,
      m_axi_mm2s_arburst                       => axi_mm2s_r_mo_array(i).arburst,
      m_axi_mm2s_arprot                        => axi_mm2s_r_mo_array(i).arprot,
      m_axi_mm2s_arcache                       => axi_mm2s_r_mo_array(i).arcache,
      m_axi_mm2s_aruser                        => open,
      m_axi_mm2s_arvalid                       => axi_mm2s_r_mo_array(i).arvalid,
      m_axi_mm2s_arready                       => axi_mm2s_r_mi_array(i).arready,
      m_axi_mm2s_rdata                         => axi_mm2s_r_mi_array(i).rdata,
      m_axi_mm2s_rresp                         => axi_mm2s_r_mi_array(i).rresp,
      m_axi_mm2s_rlast                         => axi_mm2s_r_mi_array(i).rlast,
      m_axi_mm2s_rvalid                        => axi_mm2s_r_mi_array(i).rvalid,
      m_axi_mm2s_rready                        => axi_mm2s_r_mo_array(i).rready,

      m_axis_mm2s_tdata                        => axis_mm2s_pld_mo_array(i).tdata,
      m_axis_mm2s_tkeep                        => axis_mm2s_pld_mo_array(i).tkeep,
      m_axis_mm2s_tlast                        => axis_mm2s_pld_mo_array(i).tlast,
      m_axis_mm2s_tvalid                       => axis_mm2s_pld_mo_array(i).tvalid,
      m_axis_mm2s_tready                       => axis_mm2s_pld_mi_array(i).tready,

      -- Stream to Memory Mapped
      m_axi_s2mm_aclk                          => ext_clk_i,
      m_axi_s2mm_aresetn                       => axis_s2mm_rst_n_array_or(i),
      s2mm_err                                 => open,
      m_axis_s2mm_cmdsts_awclk                 => ext_clk_i,
      m_axis_s2mm_cmdsts_aresetn               => axis_s2mm_rst_n_array_or(i),

      s_axis_s2mm_cmd_tvalid                   => axis_s2mm_cmd_mo_array(i).tvalid,
      s_axis_s2mm_cmd_tready                   => axis_s2mm_cmd_mi_array(i).tready,
      s_axis_s2mm_cmd_tdata                    => axis_s2mm_cmd_mo_array(i).tdata,

      m_axis_s2mm_sts_tvalid                   => open,
      m_axis_s2mm_sts_tready                   => c_axi_sl_one,
      m_axis_s2mm_sts_tdata                    => open,
      m_axis_s2mm_sts_tkeep                    => open,
      m_axis_s2mm_sts_tlast                    => open,

      m_axi_s2mm_awaddr                        => axi_s2mm_w_mo_array(i).awaddr,
      m_axi_s2mm_awlen                         => axi_s2mm_w_mo_array(i).awlen,
      m_axi_s2mm_awsize                        => axi_s2mm_w_mo_array(i).awsize,
      m_axi_s2mm_awburst                       => axi_s2mm_w_mo_array(i).awburst,
      m_axi_s2mm_awprot                        => axi_s2mm_w_mo_array(i).awprot,
      m_axi_s2mm_awcache                       => axi_s2mm_w_mo_array(i).awcache,
      m_axi_s2mm_awuser                        => open,
      m_axi_s2mm_awvalid                       => axi_s2mm_w_mo_array(i).awvalid,
      m_axi_s2mm_awready                       => axi_s2mm_w_mi_array(i).awready,
      m_axi_s2mm_wdata                         => axi_s2mm_w_mo_array(i).wdata,
      m_axi_s2mm_wstrb                         => axi_s2mm_w_mo_array(i).wstrb,
      m_axi_s2mm_wlast                         => axi_s2mm_w_mo_array(i).wlast,
      m_axi_s2mm_wvalid                        => axi_s2mm_w_mo_array(i).wvalid,
      m_axi_s2mm_wready                        => axi_s2mm_w_mi_array(i).wready,
      m_axi_s2mm_bresp                         => axi_s2mm_w_mi_array(i).bresp,
      m_axi_s2mm_bvalid                        => axi_s2mm_w_mi_array(i).bvalid,
      m_axi_s2mm_bready                        => axi_s2mm_w_mo_array(i).bready,

      s_axis_s2mm_tdata                        => axis_s2mm_pld_mo_array(i).tdata,
      s_axis_s2mm_tkeep                        => axis_s2mm_pld_mo_array(i).tkeep,
      s_axis_s2mm_tlast                        => axis_s2mm_pld_mo_array(i).tlast,
      s_axis_s2mm_tvalid                       => axis_s2mm_pld_mo_array(i).tvalid,
      s_axis_s2mm_tready                       => axis_s2mm_pld_mi_array(i).tready
    );

    axis_s2mm_rst_n_array_or(i) <= axi_rst_n_array(i) and axis_s2mm_cmd_mo_array(i).rstn;
    axis_mm2s_rst_n_array_or(i) <= axi_rst_n_array(i);
  end generate;

  -- Assign dummy data to other unassigned records. We just need to assign signals
  -- going to AXI interface. The other ones are not assigned anywhere, so we are
  -- safe
  gen_axis_data_mover_unused : for i in c_num_max_acq_cores-1 downto g_acq_num_cores generate
    axi_mm2s_r_mo_array(i)                       <= cc_dummy_aximm_r_slave_in;
    axi_s2mm_w_mo_array(i)                       <= cc_dummy_aximm_w_slave_in;
  end generate;

  -----------------------------------------------------------------------------
  -- AXIMM Interconnect 8x1
  -----------------------------------------------------------------------------
  cmp_axi_interconnect_bpm : axi_interconnect_bpm
  port map (
    interconnect_aclk                        => ext_clk_i,                      -- in std_logic;
    interconnect_aresetn                     => ext_rst_n_i,                    -- in std_logic;
    s00_axi_areset_out_n                     => axi_rst_n_array(0),             -- out std_logic;
    s00_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    s00_axi_awid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s00_axi_awaddr                           => axi_s2mm_w_mo_array(0).awaddr,  -- in std_logic_vector ( 31 downto 0 );
    s00_axi_awlen                            => axi_s2mm_w_mo_array(0).awlen,   -- in std_logic_vector ( 7 downto 0 );
    s00_axi_awsize                           => axi_s2mm_w_mo_array(0).awsize,  -- in std_logic_vector ( 2 downto 0 );
    s00_axi_awburst                          => axi_s2mm_w_mo_array(0).awburst, -- in std_logic_vector ( 1 downto 0 );
    s00_axi_awlock                           => c_axi_sl_zero,                  -- in std_logic;
    s00_axi_awcache                          => axi_s2mm_w_mo_array(0).awcache, -- in std_logic_vector ( 3 downto 0 );
    s00_axi_awprot                           => axi_s2mm_w_mo_array(0).awprot,  -- in std_logic_vector ( 2 downto 0 );
    s00_axi_awqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s00_axi_awvalid                          => axi_s2mm_w_mo_array(0).awvalid, -- in std_logic;
    s00_axi_awready                          => axi_s2mm_w_mi_array(0).awready, -- out std_logic;
    s00_axi_wdata                            => axi_s2mm_w_mo_array(0).wdata,   -- in std_logic_vector ( 255 downto 0 );
    s00_axi_wstrb                            => axi_s2mm_w_mo_array(0).wstrb,   -- in std_logic_vector ( 31 downto 0 );
    s00_axi_wlast                            => axi_s2mm_w_mo_array(0).wlast,   -- in std_logic;
    s00_axi_wvalid                           => axi_s2mm_w_mo_array(0).wvalid,  -- in std_logic;
    s00_axi_wready                           => axi_s2mm_w_mi_array(0).wready,  -- out std_logic;
    s00_axi_bid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s00_axi_bresp                            => axi_s2mm_w_mi_array(0).bresp,   -- out std_logic_vector ( 1 downto 0 );
    s00_axi_bvalid                           => axi_s2mm_w_mi_array(0).bvalid,  -- out std_logic;
    s00_axi_bready                           => axi_s2mm_w_mo_array(0).bready,  -- in std_logic;
    s00_axi_arid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s00_axi_araddr                           => axi_mm2s_r_mo_array(0).araddr,  -- in std_logic_vector ( 31 downto 0 );
    s00_axi_arlen                            => axi_mm2s_r_mo_array(0).arlen,   -- in std_logic_vector ( 7 downto 0 );
    s00_axi_arsize                           => axi_mm2s_r_mo_array(0).arsize,  -- in std_logic_vector ( 2 downto 0 );
    s00_axi_arburst                          => axi_mm2s_r_mo_array(0).arburst, -- in std_logic_vector ( 1 downto 0 );
    s00_axi_arlock                           => c_axi_sl_zero,                  -- in std_logic;
    s00_axi_arcache                          => axi_mm2s_r_mo_array(0).arcache, -- in std_logic_vector ( 3 downto 0 );
    s00_axi_arprot                           => axi_mm2s_r_mo_array(0).arprot,  -- in std_logic_vector ( 2 downto 0 );
    s00_axi_arqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s00_axi_arvalid                          => axi_mm2s_r_mo_array(0).arvalid, -- in std_logic;
    s00_axi_arready                          => axi_mm2s_r_mi_array(0).arready, -- out std_logic;
    s00_axi_rid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s00_axi_rdata                            => axi_mm2s_r_mi_array(0).rdata,   -- out std_logic_vector ( 255 downto 0 );
    s00_axi_rresp                            => axi_mm2s_r_mi_array(0).rresp,   -- out std_logic_vector ( 1 downto 0 );
    s00_axi_rlast                            => axi_mm2s_r_mi_array(0).rlast,   -- out std_logic;
    s00_axi_rvalid                           => axi_mm2s_r_mi_array(0).rvalid,  -- out std_logic;
    s00_axi_rready                           => axi_mm2s_r_mo_array(0).rready,  -- in std_logic;
    s01_axi_areset_out_n                     => axi_rst_n_array(1),             -- out std_logic;
    s01_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    s01_axi_awid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s01_axi_awaddr                           => axi_s2mm_w_mo_array(1).awaddr,  -- in std_logic_vector ( 31 downto 0 );
    s01_axi_awlen                            => axi_s2mm_w_mo_array(1).awlen,   -- in std_logic_vector ( 7 downto 0 );
    s01_axi_awsize                           => axi_s2mm_w_mo_array(1).awsize,  -- in std_logic_vector ( 2 downto 0 );
    s01_axi_awburst                          => axi_s2mm_w_mo_array(1).awburst, -- in std_logic_vector ( 1 downto 0 );
    s01_axi_awlock                           => c_axi_sl_zero,                  -- in std_logic;
    s01_axi_awcache                          => axi_s2mm_w_mo_array(1).awcache, -- in std_logic_vector ( 3 downto 0 );
    s01_axi_awprot                           => axi_s2mm_w_mo_array(1).awprot,  -- in std_logic_vector ( 2 downto 0 );
    s01_axi_awqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s01_axi_awvalid                          => axi_s2mm_w_mo_array(1).awvalid, -- in std_logic;
    s01_axi_awready                          => axi_s2mm_w_mi_array(1).awready, -- out std_logic;
    s01_axi_wdata                            => axi_s2mm_w_mo_array(1).wdata,   -- in std_logic_vector ( 255 downto 0 );
    s01_axi_wstrb                            => axi_s2mm_w_mo_array(1).wstrb,   -- in std_logic_vector ( 31 downto 0 );
    s01_axi_wlast                            => axi_s2mm_w_mo_array(1).wlast,   -- in std_logic;
    s01_axi_wvalid                           => axi_s2mm_w_mo_array(1).wvalid,  -- in std_logic;
    s01_axi_wready                           => axi_s2mm_w_mi_array(1).wready,  -- out std_logic;
    s01_axi_bid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s01_axi_bresp                            => axi_s2mm_w_mi_array(1).bresp,   -- out std_logic_vector ( 1 downto 0 );
    s01_axi_bvalid                           => axi_s2mm_w_mi_array(1).bvalid,  -- out std_logic;
    s01_axi_bready                           => axi_s2mm_w_mo_array(1).bready,  -- in std_logic;
    s01_axi_arid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s01_axi_araddr                           => axi_mm2s_r_mo_array(1).araddr,  -- in std_logic_vector ( 31 downto 0 );
    s01_axi_arlen                            => axi_mm2s_r_mo_array(1).arlen,   -- in std_logic_vector ( 7 downto 0 );
    s01_axi_arsize                           => axi_mm2s_r_mo_array(1).arsize,  -- in std_logic_vector ( 2 downto 0 );
    s01_axi_arburst                          => axi_mm2s_r_mo_array(1).arburst, -- in std_logic_vector ( 1 downto 0 );
    s01_axi_arlock                           => c_axi_sl_zero,                  -- in std_logic;
    s01_axi_arcache                          => axi_mm2s_r_mo_array(1).arcache, -- in std_logic_vector ( 3 downto 0 );
    s01_axi_arprot                           => axi_mm2s_r_mo_array(1).arprot,  -- in std_logic_vector ( 2 downto 0 );
    s01_axi_arqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s01_axi_arvalid                          => axi_mm2s_r_mo_array(1).arvalid, -- in std_logic;
    s01_axi_arready                          => axi_mm2s_r_mi_array(1).arready, -- out std_logic;
    s01_axi_rid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s01_axi_rdata                            => axi_mm2s_r_mi_array(1).rdata,   -- out std_logic_vector ( 255 downto 0 );
    s01_axi_rresp                            => axi_mm2s_r_mi_array(1).rresp,   -- out std_logic_vector ( 1 downto 0 );
    s01_axi_rlast                            => axi_mm2s_r_mi_array(1).rlast,   -- out std_logic;
    s01_axi_rvalid                           => axi_mm2s_r_mi_array(1).rvalid,  -- out std_logic;
    s01_axi_rready                           => axi_mm2s_r_mo_array(1).rready,  -- in std_logic;
    s02_axi_areset_out_n                     => axi_rst_n_array(2),             -- out std_logic;
    s02_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    s02_axi_awid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s02_axi_awaddr                           => axi_s2mm_w_mo_array(2).awaddr,  -- in std_logic_vector ( 31 downto 0 );
    s02_axi_awlen                            => axi_s2mm_w_mo_array(2).awlen,   -- in std_logic_vector ( 7 downto 0 );
    s02_axi_awsize                           => axi_s2mm_w_mo_array(2).awsize,  -- in std_logic_vector ( 2 downto 0 );
    s02_axi_awburst                          => axi_s2mm_w_mo_array(2).awburst, -- in std_logic_vector ( 1 downto 0 );
    s02_axi_awlock                           => c_axi_sl_zero,                  -- in std_logic;
    s02_axi_awcache                          => axi_s2mm_w_mo_array(2).awcache, -- in std_logic_vector ( 3 downto 0 );
    s02_axi_awprot                           => axi_s2mm_w_mo_array(2).awprot,  -- in std_logic_vector ( 2 downto 0 );
    s02_axi_awqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s02_axi_awvalid                          => axi_s2mm_w_mo_array(2).awvalid, -- in std_logic;
    s02_axi_awready                          => axi_s2mm_w_mi_array(2).awready, -- out std_logic;
    s02_axi_wdata                            => axi_s2mm_w_mo_array(2).wdata,   -- in std_logic_vector ( 255 downto 0 );
    s02_axi_wstrb                            => axi_s2mm_w_mo_array(2).wstrb,   -- in std_logic_vector ( 31 downto 0 );
    s02_axi_wlast                            => axi_s2mm_w_mo_array(2).wlast,   -- in std_logic;
    s02_axi_wvalid                           => axi_s2mm_w_mo_array(2).wvalid,  -- in std_logic;
    s02_axi_wready                           => axi_s2mm_w_mi_array(2).wready,  -- out std_logic;
    s02_axi_bid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s02_axi_bresp                            => axi_s2mm_w_mi_array(2).bresp,   -- out std_logic_vector ( 1 downto 0 );
    s02_axi_bvalid                           => axi_s2mm_w_mi_array(2).bvalid,  -- out std_logic;
    s02_axi_bready                           => axi_s2mm_w_mo_array(2).bready,  -- in std_logic;
    s02_axi_arid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s02_axi_araddr                           => axi_mm2s_r_mo_array(2).araddr,  -- in std_logic_vector ( 31 downto 0 );
    s02_axi_arlen                            => axi_mm2s_r_mo_array(2).arlen,   -- in std_logic_vector ( 7 downto 0 );
    s02_axi_arsize                           => axi_mm2s_r_mo_array(2).arsize,  -- in std_logic_vector ( 2 downto 0 );
    s02_axi_arburst                          => axi_mm2s_r_mo_array(2).arburst, -- in std_logic_vector ( 1 downto 0 );
    s02_axi_arlock                           => c_axi_sl_zero,                  -- in std_logic;
    s02_axi_arcache                          => axi_mm2s_r_mo_array(2).arcache, -- in std_logic_vector ( 3 downto 0 );
    s02_axi_arprot                           => axi_mm2s_r_mo_array(2).arprot,  -- in std_logic_vector ( 2 downto 0 );
    s02_axi_arqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s02_axi_arvalid                          => axi_mm2s_r_mo_array(2).arvalid, -- in std_logic;
    s02_axi_arready                          => axi_mm2s_r_mi_array(2).arready, -- out std_logic;
    s02_axi_rid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s02_axi_rdata                            => axi_mm2s_r_mi_array(2).rdata,   -- out std_logic_vector ( 255 downto 0 );
    s02_axi_rresp                            => axi_mm2s_r_mi_array(2).rresp,   -- out std_logic_vector ( 1 downto 0 );
    s02_axi_rlast                            => axi_mm2s_r_mi_array(2).rlast,   -- out std_logic;
    s02_axi_rvalid                           => axi_mm2s_r_mi_array(2).rvalid,  -- out std_logic;
    s02_axi_rready                           => axi_mm2s_r_mo_array(2).rready,  -- in std_logic;
    s03_axi_areset_out_n                     => axi_rst_n_array(3),             -- out std_logic;
    s03_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    s03_axi_awid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s03_axi_awaddr                           => axi_s2mm_w_mo_array(3).awaddr,  -- in std_logic_vector ( 31 downto 0 );
    s03_axi_awlen                            => axi_s2mm_w_mo_array(3).awlen,   -- in std_logic_vector ( 7 downto 0 );
    s03_axi_awsize                           => axi_s2mm_w_mo_array(3).awsize,  -- in std_logic_vector ( 2 downto 0 );
    s03_axi_awburst                          => axi_s2mm_w_mo_array(3).awburst, -- in std_logic_vector ( 1 downto 0 );
    s03_axi_awlock                           => c_axi_sl_zero,                  -- in std_logic;
    s03_axi_awcache                          => axi_s2mm_w_mo_array(3).awcache, -- in std_logic_vector ( 3 downto 0 );
    s03_axi_awprot                           => axi_s2mm_w_mo_array(3).awprot,  -- in std_logic_vector ( 2 downto 0 );
    s03_axi_awqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s03_axi_awvalid                          => axi_s2mm_w_mo_array(3).awvalid, -- in std_logic;
    s03_axi_awready                          => axi_s2mm_w_mi_array(3).awready, -- out std_logic;
    s03_axi_wdata                            => axi_s2mm_w_mo_array(3).wdata,   -- in std_logic_vector ( 255 downto 0 );
    s03_axi_wstrb                            => axi_s2mm_w_mo_array(3).wstrb,   -- in std_logic_vector ( 31 downto 0 );
    s03_axi_wlast                            => axi_s2mm_w_mo_array(3).wlast,   -- in std_logic;
    s03_axi_wvalid                           => axi_s2mm_w_mo_array(3).wvalid,  -- in std_logic;
    s03_axi_wready                           => axi_s2mm_w_mi_array(3).wready,  -- out std_logic;
    s03_axi_bid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s03_axi_bresp                            => axi_s2mm_w_mi_array(3).bresp,   -- out std_logic_vector ( 1 downto 0 );
    s03_axi_bvalid                           => axi_s2mm_w_mi_array(3).bvalid,  -- out std_logic;
    s03_axi_bready                           => axi_s2mm_w_mo_array(3).bready,  -- in std_logic;
    s03_axi_arid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s03_axi_araddr                           => axi_mm2s_r_mo_array(3).araddr,  -- in std_logic_vector ( 31 downto 0 );
    s03_axi_arlen                            => axi_mm2s_r_mo_array(3).arlen,   -- in std_logic_vector ( 7 downto 0 );
    s03_axi_arsize                           => axi_mm2s_r_mo_array(3).arsize,  -- in std_logic_vector ( 2 downto 0 );
    s03_axi_arburst                          => axi_mm2s_r_mo_array(3).arburst, -- in std_logic_vector ( 1 downto 0 );
    s03_axi_arlock                           => c_axi_sl_zero,                  -- in std_logic;
    s03_axi_arcache                          => axi_mm2s_r_mo_array(3).arcache, -- in std_logic_vector ( 3 downto 0 );
    s03_axi_arprot                           => axi_mm2s_r_mo_array(3).arprot,  -- in std_logic_vector ( 2 downto 0 );
    s03_axi_arqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s03_axi_arvalid                          => axi_mm2s_r_mo_array(3).arvalid, -- in std_logic;
    s03_axi_arready                          => axi_mm2s_r_mi_array(3).arready, -- out std_logic;
    s03_axi_rid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s03_axi_rdata                            => axi_mm2s_r_mi_array(3).rdata,   -- out std_logic_vector ( 255 downto 0 );
    s03_axi_rresp                            => axi_mm2s_r_mi_array(3).rresp,   -- out std_logic_vector ( 1 downto 0 );
    s03_axi_rlast                            => axi_mm2s_r_mi_array(3).rlast,   -- out std_logic;
    s03_axi_rvalid                           => axi_mm2s_r_mi_array(3).rvalid,  -- out std_logic;
    s03_axi_rready                           => axi_mm2s_r_mo_array(3).rready,  -- in std_logic;
    s04_axi_areset_out_n                     => axi_rst_n_array(4),             -- out std_logic;
    s04_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    s04_axi_awid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s04_axi_awaddr                           => axi_s2mm_w_mo_array(4).awaddr,  -- in std_logic_vector ( 31 downto 0 );
    s04_axi_awlen                            => axi_s2mm_w_mo_array(4).awlen,   -- in std_logic_vector ( 7 downto 0 );
    s04_axi_awsize                           => axi_s2mm_w_mo_array(4).awsize,  -- in std_logic_vector ( 2 downto 0 );
    s04_axi_awburst                          => axi_s2mm_w_mo_array(4).awburst, -- in std_logic_vector ( 1 downto 0 );
    s04_axi_awlock                           => c_axi_sl_zero,                  -- in std_logic;
    s04_axi_awcache                          => axi_s2mm_w_mo_array(4).awcache, -- in std_logic_vector ( 3 downto 0 );
    s04_axi_awprot                           => axi_s2mm_w_mo_array(4).awprot,  -- in std_logic_vector ( 2 downto 0 );
    s04_axi_awqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s04_axi_awvalid                          => axi_s2mm_w_mo_array(4).awvalid, -- in std_logic;
    s04_axi_awready                          => axi_s2mm_w_mi_array(4).awready, -- out std_logic;
    s04_axi_wdata                            => axi_s2mm_w_mo_array(4).wdata,   -- in std_logic_vector ( 255 downto 0 );
    s04_axi_wstrb                            => axi_s2mm_w_mo_array(4).wstrb,   -- in std_logic_vector ( 31 downto 0 );
    s04_axi_wlast                            => axi_s2mm_w_mo_array(4).wlast,   -- in std_logic;
    s04_axi_wvalid                           => axi_s2mm_w_mo_array(4).wvalid,  -- in std_logic;
    s04_axi_wready                           => axi_s2mm_w_mi_array(4).wready,  -- out std_logic;
    s04_axi_bid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s04_axi_bresp                            => axi_s2mm_w_mi_array(4).bresp,   -- out std_logic_vector ( 1 downto 0 );
    s04_axi_bvalid                           => axi_s2mm_w_mi_array(4).bvalid,  -- out std_logic;
    s04_axi_bready                           => axi_s2mm_w_mo_array(4).bready,  -- in std_logic;
    s04_axi_arid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s04_axi_araddr                           => axi_mm2s_r_mo_array(4).araddr,  -- in std_logic_vector ( 31 downto 0 );
    s04_axi_arlen                            => axi_mm2s_r_mo_array(4).arlen,   -- in std_logic_vector ( 7 downto 0 );
    s04_axi_arsize                           => axi_mm2s_r_mo_array(4).arsize,  -- in std_logic_vector ( 2 downto 0 );
    s04_axi_arburst                          => axi_mm2s_r_mo_array(4).arburst, -- in std_logic_vector ( 1 downto 0 );
    s04_axi_arlock                           => c_axi_sl_zero,                  -- in std_logic;
    s04_axi_arcache                          => axi_mm2s_r_mo_array(4).arcache, -- in std_logic_vector ( 3 downto 0 );
    s04_axi_arprot                           => axi_mm2s_r_mo_array(4).arprot,  -- in std_logic_vector ( 2 downto 0 );
    s04_axi_arqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s04_axi_arvalid                          => axi_mm2s_r_mo_array(4).arvalid, -- in std_logic;
    s04_axi_arready                          => axi_mm2s_r_mi_array(4).arready, -- out std_logic;
    s04_axi_rid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s04_axi_rdata                            => axi_mm2s_r_mi_array(4).rdata,   -- out std_logic_vector ( 255 downto 0 );
    s04_axi_rresp                            => axi_mm2s_r_mi_array(4).rresp,   -- out std_logic_vector ( 1 downto 0 );
    s04_axi_rlast                            => axi_mm2s_r_mi_array(4).rlast,   -- out std_logic;
    s04_axi_rvalid                           => axi_mm2s_r_mi_array(4).rvalid,  -- out std_logic;
    s04_axi_rready                           => axi_mm2s_r_mo_array(4).rready,  -- in std_logic;
    s05_axi_areset_out_n                     => axi_rst_n_array(5),             -- out std_logic;
    s05_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    s05_axi_awid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s05_axi_awaddr                           => axi_s2mm_w_mo_array(5).awaddr,  -- in std_logic_vector ( 31 downto 0 );
    s05_axi_awlen                            => axi_s2mm_w_mo_array(5).awlen,   -- in std_logic_vector ( 7 downto 0 );
    s05_axi_awsize                           => axi_s2mm_w_mo_array(5).awsize,  -- in std_logic_vector ( 2 downto 0 );
    s05_axi_awburst                          => axi_s2mm_w_mo_array(5).awburst, -- in std_logic_vector ( 1 downto 0 );
    s05_axi_awlock                           => c_axi_sl_zero,                  -- in std_logic;
    s05_axi_awcache                          => axi_s2mm_w_mo_array(5).awcache, -- in std_logic_vector ( 3 downto 0 );
    s05_axi_awprot                           => axi_s2mm_w_mo_array(5).awprot,  -- in std_logic_vector ( 2 downto 0 );
    s05_axi_awqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s05_axi_awvalid                          => axi_s2mm_w_mo_array(5).awvalid, -- in std_logic;
    s05_axi_awready                          => axi_s2mm_w_mi_array(5).awready, -- out std_logic;
    s05_axi_wdata                            => axi_s2mm_w_mo_array(5).wdata,   -- in std_logic_vector ( 255 downto 0 );
    s05_axi_wstrb                            => axi_s2mm_w_mo_array(5).wstrb,   -- in std_logic_vector ( 31 downto 0 );
    s05_axi_wlast                            => axi_s2mm_w_mo_array(5).wlast,   -- in std_logic;
    s05_axi_wvalid                           => axi_s2mm_w_mo_array(5).wvalid,  -- in std_logic;
    s05_axi_wready                           => axi_s2mm_w_mi_array(5).wready,  -- out std_logic;
    s05_axi_bid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s05_axi_bresp                            => axi_s2mm_w_mi_array(5).bresp,   -- out std_logic_vector ( 1 downto 0 );
    s05_axi_bvalid                           => axi_s2mm_w_mi_array(5).bvalid,  -- out std_logic;
    s05_axi_bready                           => axi_s2mm_w_mo_array(5).bready,  -- in std_logic;
    s05_axi_arid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s05_axi_araddr                           => axi_mm2s_r_mo_array(5).araddr,  -- in std_logic_vector ( 31 downto 0 );
    s05_axi_arlen                            => axi_mm2s_r_mo_array(5).arlen,   -- in std_logic_vector ( 7 downto 0 );
    s05_axi_arsize                           => axi_mm2s_r_mo_array(5).arsize,  -- in std_logic_vector ( 2 downto 0 );
    s05_axi_arburst                          => axi_mm2s_r_mo_array(5).arburst, -- in std_logic_vector ( 1 downto 0 );
    s05_axi_arlock                           => c_axi_sl_zero,                  -- in std_logic;
    s05_axi_arcache                          => axi_mm2s_r_mo_array(5).arcache, -- in std_logic_vector ( 3 downto 0 );
    s05_axi_arprot                           => axi_mm2s_r_mo_array(5).arprot,  -- in std_logic_vector ( 2 downto 0 );
    s05_axi_arqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s05_axi_arvalid                          => axi_mm2s_r_mo_array(5).arvalid, -- in std_logic;
    s05_axi_arready                          => axi_mm2s_r_mi_array(5).arready, -- out std_logic;
    s05_axi_rid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s05_axi_rdata                            => axi_mm2s_r_mi_array(5).rdata,   -- out std_logic_vector ( 255 downto 0 );
    s05_axi_rresp                            => axi_mm2s_r_mi_array(5).rresp,   -- out std_logic_vector ( 1 downto 0 );
    s05_axi_rlast                            => axi_mm2s_r_mi_array(5).rlast,   -- out std_logic;
    s05_axi_rvalid                           => axi_mm2s_r_mi_array(5).rvalid,  -- out std_logic;
    s05_axi_rready                           => axi_mm2s_r_mo_array(5).rready,  -- in std_logic;
    s06_axi_areset_out_n                     => axi_rst_n_array(6),             -- out std_logic;
    s06_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    s06_axi_awid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s06_axi_awaddr                           => axi_s2mm_w_mo_array(6).awaddr,  -- in std_logic_vector ( 31 downto 0 );
    s06_axi_awlen                            => axi_s2mm_w_mo_array(6).awlen,   -- in std_logic_vector ( 7 downto 0 );
    s06_axi_awsize                           => axi_s2mm_w_mo_array(6).awsize,  -- in std_logic_vector ( 2 downto 0 );
    s06_axi_awburst                          => axi_s2mm_w_mo_array(6).awburst, -- in std_logic_vector ( 1 downto 0 );
    s06_axi_awlock                           => c_axi_sl_zero,                  -- in std_logic;
    s06_axi_awcache                          => axi_s2mm_w_mo_array(6).awcache, -- in std_logic_vector ( 3 downto 0 );
    s06_axi_awprot                           => axi_s2mm_w_mo_array(6).awprot,  -- in std_logic_vector ( 2 downto 0 );
    s06_axi_awqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s06_axi_awvalid                          => axi_s2mm_w_mo_array(6).awvalid, -- in std_logic;
    s06_axi_awready                          => axi_s2mm_w_mi_array(6).awready, -- out std_logic;
    s06_axi_wdata                            => axi_s2mm_w_mo_array(6).wdata,   -- in std_logic_vector ( 255 downto 0 );
    s06_axi_wstrb                            => axi_s2mm_w_mo_array(6).wstrb,   -- in std_logic_vector ( 31 downto 0 );
    s06_axi_wlast                            => axi_s2mm_w_mo_array(6).wlast,   -- in std_logic;
    s06_axi_wvalid                           => axi_s2mm_w_mo_array(6).wvalid,  -- in std_logic;
    s06_axi_wready                           => axi_s2mm_w_mi_array(6).wready,  -- out std_logic;
    s06_axi_bid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s06_axi_bresp                            => axi_s2mm_w_mi_array(6).bresp,   -- out std_logic_vector ( 1 downto 0 );
    s06_axi_bvalid                           => axi_s2mm_w_mi_array(6).bvalid,  -- out std_logic;
    s06_axi_bready                           => axi_s2mm_w_mo_array(6).bready,  -- in std_logic;
    s06_axi_arid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s06_axi_araddr                           => axi_mm2s_r_mo_array(6).araddr,  -- in std_logic_vector ( 31 downto 0 );
    s06_axi_arlen                            => axi_mm2s_r_mo_array(6).arlen,   -- in std_logic_vector ( 7 downto 0 );
    s06_axi_arsize                           => axi_mm2s_r_mo_array(6).arsize,  -- in std_logic_vector ( 2 downto 0 );
    s06_axi_arburst                          => axi_mm2s_r_mo_array(6).arburst, -- in std_logic_vector ( 1 downto 0 );
    s06_axi_arlock                           => c_axi_sl_zero,                  -- in std_logic;
    s06_axi_arcache                          => axi_mm2s_r_mo_array(6).arcache, -- in std_logic_vector ( 3 downto 0 );
    s06_axi_arprot                           => axi_mm2s_r_mo_array(6).arprot,  -- in std_logic_vector ( 2 downto 0 );
    s06_axi_arqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s06_axi_arvalid                          => axi_mm2s_r_mo_array(6).arvalid, -- in std_logic;
    s06_axi_arready                          => axi_mm2s_r_mi_array(6).arready, -- out std_logic;
    s06_axi_rid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s06_axi_rdata                            => axi_mm2s_r_mi_array(6).rdata,   -- out std_logic_vector ( 255 downto 0 );
    s06_axi_rresp                            => axi_mm2s_r_mi_array(6).rresp,   -- out std_logic_vector ( 1 downto 0 );
    s06_axi_rlast                            => axi_mm2s_r_mi_array(6).rlast,   -- out std_logic;
    s06_axi_rvalid                           => axi_mm2s_r_mi_array(6).rvalid,  -- out std_logic;
    s06_axi_rready                           => axi_mm2s_r_mo_array(6).rready,  -- in std_logic;
    s07_axi_areset_out_n                     => axi_rst_n_array(7),             -- out std_logic;
    s07_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    s07_axi_awid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s07_axi_awaddr                           => axi_s2mm_w_mo_array(7).awaddr,  -- in std_logic_vector ( 31 downto 0 );
    s07_axi_awlen                            => axi_s2mm_w_mo_array(7).awlen,   -- in std_logic_vector ( 7 downto 0 );
    s07_axi_awsize                           => axi_s2mm_w_mo_array(7).awsize,  -- in std_logic_vector ( 2 downto 0 );
    s07_axi_awburst                          => axi_s2mm_w_mo_array(7).awburst, -- in std_logic_vector ( 1 downto 0 );
    s07_axi_awlock                           => c_axi_sl_zero,                  -- in std_logic;
    s07_axi_awcache                          => axi_s2mm_w_mo_array(7).awcache, -- in std_logic_vector ( 3 downto 0 );
    s07_axi_awprot                           => axi_s2mm_w_mo_array(7).awprot,  -- in std_logic_vector ( 2 downto 0 );
    s07_axi_awqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s07_axi_awvalid                          => axi_s2mm_w_mo_array(7).awvalid, -- in std_logic;
    s07_axi_awready                          => axi_s2mm_w_mi_array(7).awready, -- out std_logic;
    s07_axi_wdata                            => axi_s2mm_w_mo_array(7).wdata,   -- in std_logic_vector ( 255 downto 0 );
    s07_axi_wstrb                            => axi_s2mm_w_mo_array(7).wstrb,   -- in std_logic_vector ( 31 downto 0 );
    s07_axi_wlast                            => axi_s2mm_w_mo_array(7).wlast,   -- in std_logic;
    s07_axi_wvalid                           => axi_s2mm_w_mo_array(7).wvalid,  -- in std_logic;
    s07_axi_wready                           => axi_s2mm_w_mi_array(7).wready,  -- out std_logic;
    s07_axi_bid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s07_axi_bresp                            => axi_s2mm_w_mi_array(7).bresp,   -- out std_logic_vector ( 1 downto 0 );
    s07_axi_bvalid                           => axi_s2mm_w_mi_array(7).bvalid,  -- out std_logic;
    s07_axi_bready                           => axi_s2mm_w_mo_array(7).bready,  -- in std_logic;
    s07_axi_arid                             => c_axi_slv_zero,                 -- in std_logic_vector ( 0 to 0 );
    s07_axi_araddr                           => axi_mm2s_r_mo_array(7).araddr,  -- in std_logic_vector ( 31 downto 0 );
    s07_axi_arlen                            => axi_mm2s_r_mo_array(7).arlen,   -- in std_logic_vector ( 7 downto 0 );
    s07_axi_arsize                           => axi_mm2s_r_mo_array(7).arsize,  -- in std_logic_vector ( 2 downto 0 );
    s07_axi_arburst                          => axi_mm2s_r_mo_array(7).arburst, -- in std_logic_vector ( 1 downto 0 );
    s07_axi_arlock                           => c_axi_sl_zero,                  -- in std_logic;
    s07_axi_arcache                          => axi_mm2s_r_mo_array(7).arcache, -- in std_logic_vector ( 3 downto 0 );
    s07_axi_arprot                           => axi_mm2s_r_mo_array(7).arprot,  -- in std_logic_vector ( 2 downto 0 );
    s07_axi_arqos                            => c_axi_qos_zeros,                -- in std_logic_vector ( 3 downto 0 );
    s07_axi_arvalid                          => axi_mm2s_r_mo_array(7).arvalid, -- in std_logic;
    s07_axi_arready                          => axi_mm2s_r_mi_array(7).arready, -- out std_logic;
    s07_axi_rid                              => open,                           -- out std_logic_vector ( 0 to 0 );
    s07_axi_rdata                            => axi_mm2s_r_mi_array(7).rdata,   -- out std_logic_vector ( 255 downto 0 );
    s07_axi_rresp                            => axi_mm2s_r_mi_array(7).rresp,   -- out std_logic_vector ( 1 downto 0 );
    s07_axi_rlast                            => axi_mm2s_r_mi_array(7).rlast,   -- out std_logic;
    s07_axi_rvalid                           => axi_mm2s_r_mi_array(7).rvalid,  -- out std_logic;
    s07_axi_rready                           => axi_mm2s_r_mo_array(7).rready,  -- in std_logic;
    m00_axi_areset_out_n                     => open,                           -- out std_logic;
    m00_axi_aclk                             => ext_clk_i,                      -- in std_logic;
    m00_axi_awid                             => ddr_aximm_ma_awid_o,            -- out std_logic_vector ( 3 downto 0 );
    m00_axi_awaddr                           => ddr_aximm_ma_awaddr_o,          -- out std_logic_vector ( 31 downto 0 );
    m00_axi_awlen                            => ddr_aximm_ma_awlen_o,           -- out std_logic_vector ( 7 downto 0 );
    m00_axi_awsize                           => ddr_aximm_ma_awsize_o,          -- out std_logic_vector ( 2 downto 0 );
    m00_axi_awburst                          => ddr_aximm_ma_awburst_o,         -- out std_logic_vector ( 1 downto 0 );
    m00_axi_awlock                           => ddr_aximm_ma_awlock_o,          -- out std_logic;
    m00_axi_awcache                          => ddr_aximm_ma_awcache_o,         -- out std_logic_vector ( 3 downto 0 );
    m00_axi_awprot                           => ddr_aximm_ma_awprot_o,          -- out std_logic_vector ( 2 downto 0 );
    m00_axi_awqos                            => ddr_aximm_ma_awqos_o,           -- out std_logic_vector ( 3 downto 0 );
    m00_axi_awvalid                          => ddr_aximm_ma_awvalid_o,         -- out std_logic;
    m00_axi_awready                          => ddr_aximm_ma_awready_i,         -- in std_logic;
    m00_axi_wdata                            => ddr_aximm_ma_wdata_o,           -- out std_logic_vector ( 255 downto 0 );
    m00_axi_wstrb                            => ddr_aximm_ma_wstrb_o,           -- out std_logic_vector ( 31 downto 0 );
    m00_axi_wlast                            => ddr_aximm_ma_wlast_o,           -- out std_logic;
    m00_axi_wvalid                           => ddr_aximm_ma_wvalid_o,          -- out std_logic;
    m00_axi_wready                           => ddr_aximm_ma_wready_i,          -- in std_logic;
    m00_axi_bid                              => ddr_aximm_ma_bid_i,             -- in std_logic_vector ( 3 downto 0 );
    m00_axi_bresp                            => ddr_aximm_ma_bresp_i,           -- in std_logic_vector ( 1 downto 0 );
    m00_axi_bvalid                           => ddr_aximm_ma_bvalid_i,          -- in std_logic;
    m00_axi_bready                           => ddr_aximm_ma_bready_o,          -- out std_logic;
    m00_axi_arid                             => ddr_aximm_ma_arid_o,            -- out std_logic_vector ( 3 downto 0 );
    m00_axi_araddr                           => ddr_aximm_ma_araddr_o,          -- out std_logic_vector ( 31 downto 0 );
    m00_axi_arlen                            => ddr_aximm_ma_arlen_o,           -- out std_logic_vector ( 7 downto 0 );
    m00_axi_arsize                           => ddr_aximm_ma_arsize_o,          -- out std_logic_vector ( 2 downto 0 );
    m00_axi_arburst                          => ddr_aximm_ma_arburst_o,         -- out std_logic_vector ( 1 downto 0 );
    m00_axi_arlock                           => ddr_aximm_ma_arlock_o,          -- out std_logic;
    m00_axi_arcache                          => ddr_aximm_ma_arcache_o,         -- out std_logic_vector ( 3 downto 0 );
    m00_axi_arprot                           => ddr_aximm_ma_arprot_o,          -- out std_logic_vector ( 2 downto 0 );
    m00_axi_arqos                            => ddr_aximm_ma_arqos_o,           -- out std_logic_vector ( 3 downto 0 );
    m00_axi_arvalid                          => ddr_aximm_ma_arvalid_o,         -- out std_logic;
    m00_axi_arready                          => ddr_aximm_ma_arready_i,         -- in std_logic;
    m00_axi_rid                              => ddr_aximm_ma_rid_i,             -- in std_logic_vector ( 3 downto 0 );
    m00_axi_rdata                            => ddr_aximm_ma_rdata_i,           -- in std_logic_vector ( 255 downto 0 );
    m00_axi_rresp                            => ddr_aximm_ma_rresp_i,           -- in std_logic_vector ( 1 downto 0 );
    m00_axi_rlast                            => ddr_aximm_ma_rlast_i,           -- in std_logic;
    m00_axi_rvalid                           => ddr_aximm_ma_rvalid_i,          -- in std_logic;
    m00_axi_rready                           => ddr_aximm_ma_rready_o           -- out std_logic
  );

end rtl;
