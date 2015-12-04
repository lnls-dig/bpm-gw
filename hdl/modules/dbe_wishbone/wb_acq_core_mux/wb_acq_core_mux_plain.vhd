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
-- DBE wishbone cores
use work.dbe_wishbone_pkg.all;
-- AXI cores
use work.bpm_axi_pkg.all;
-- Platform ipcores
use work.ipcores_pkg.all;

entity wb_acq_core_mux_plain is
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
  g_acq_num_cores                           : natural := 2
);
port
(
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
  acq_val_low_array_i                       : in std_logic_vector(g_acq_num_cores*g_acq_num_channels*c_acq_chan_width-1 downto 0);
  acq_val_high_array_i                      : in std_logic_vector(g_acq_num_cores*g_acq_num_channels*c_acq_chan_width-1 downto 0);
  acq_dvalid_array_i                        : in std_logic_vector(g_acq_num_cores*g_acq_num_channels-1 downto 0);
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
  ddr_aximm_ma_awid_o                       : out std_logic_vector (0 downto 0);
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
  ddr_aximm_ma_bid_i                        : in std_logic_vector (0 downto 0);
  ddr_aximm_ma_bresp_i                      : in std_logic_vector (1 downto 0);
  ddr_aximm_ma_bvalid_i                     : in std_logic;
  ddr_aximm_ma_arid_o                       : out std_logic_vector (0 downto 0);
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
  ddr_aximm_ma_rid_i                        : in std_logic_vector (0 downto 0);
  ddr_aximm_ma_rdata_i                      : in std_logic_vector (g_ddr_payload_width-1 downto 0);
  ddr_aximm_ma_rresp_i                      : in std_logic_vector (1 downto 0);
  ddr_aximm_ma_rlast_i                      : in std_logic;
  ddr_aximm_ma_rvalid_i                     : in std_logic
);
end wb_acq_core_mux_plain;

architecture rtl of wb_acq_core_mux_plain is

  signal acq_val_low_array                  : t_acq_val_half_array(g_acq_num_cores*g_acq_num_channels-1 downto 0);
  signal acq_val_high_array                 : t_acq_val_half_array(g_acq_num_cores*g_acq_num_channels-1 downto 0);
  signal acq_dvalid_array                   : std_logic_vector(g_acq_num_cores*g_acq_num_channels-1 downto 0);
  signal acq_trig_array                     : std_logic_vector(g_acq_num_cores*g_acq_num_channels-1 downto 0);

begin

  cmp_wb_acq_core_mux : wb_acq_core_mux
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
    g_sim_readback                           => g_sim_readback,
    g_acq_num_cores                          => g_acq_num_cores
  )
  port map
  (
    -- Clock signals
    fs_clk_array_i                            => fs_clk_array_i,
    fs_ce_array_i                             => fs_ce_array_i,
    fs_rst_n_array_i                          => fs_rst_n_array_i,

    -- Clock signals for Wishbone
    sys_clk_i                                 => sys_clk_i,
    sys_rst_n_i                               => sys_rst_n_i,

    -- Clock signals for External Memory
    ext_clk_i                                 => ext_clk_i,
    ext_rst_n_i                               => ext_rst_n_i,

    -----------------------------
    -- Wishbone Control Interface signals
    -----------------------------
    wb_adr_array_i                            => wb_adr_array_i,
    wb_dat_array_i                            => wb_dat_array_i,
    wb_dat_array_o                            => wb_dat_array_o,
    wb_sel_array_i                            => wb_sel_array_i,
    wb_we_array_i                             => wb_we_array_i,
    wb_cyc_array_i                            => wb_cyc_array_i,
    wb_stb_array_i                            => wb_stb_array_i,
    wb_ack_array_o                            => wb_ack_array_o,
    wb_err_array_o                            => wb_err_array_o,
    wb_rty_array_o                            => wb_rty_array_o,
    wb_stall_array_o                          => wb_stall_array_o,

    -----------------------------
    -- External Interface
    -----------------------------
    acq_val_low_array_i                       => acq_val_low_array,
    acq_val_high_array_i                      => acq_val_high_array,
    acq_dvalid_array_i                        => acq_dvalid_array,
    acq_trig_array_i                          => acq_trig_array,

    -----------------------------
    -- DRRAM Interface
    -----------------------------
    dpram_dout_array_o                        => dpram_dout_array_o,
    dpram_valid_array_o                       => dpram_valid_array_o,

    -----------------------------
    -- External Interface (w/ FLow Control)
    -----------------------------
    ext_dout_array_o                          => ext_dout_array_o,
    ext_valid_array_o                         => ext_valid_array_o,
    ext_addr_array_o                          => ext_addr_array_o,
    ext_sof_array_o                           => ext_sof_array_o,
    ext_eof_array_o                           => ext_eof_array_o,
    ext_dreq_array_o                          => ext_dreq_array_o,
    ext_stall_array_o                         => ext_stall_array_o,

    -----------------------------
    -- Debug Interface
    -----------------------------
    dbg_ddr_rb_start_p_array_i                => dbg_ddr_rb_start_p_array_i,
    dbg_ddr_rb_rdy_array_o                    => dbg_ddr_rb_rdy_array_o,
    dbg_ddr_rb_data_array_o                   => dbg_ddr_rb_data_array_o,
    dbg_ddr_rb_addr_array_o                   => dbg_ddr_rb_addr_array_o,
    dbg_ddr_rb_valid_array_o                  => dbg_ddr_rb_valid_array_o,

    -----------------------------
    -- DDR3 SDRAM Interface
    -----------------------------
    ddr_aximm_ma_awid_o                       => ddr_aximm_ma_awid_o,
    ddr_aximm_ma_awaddr_o                     => ddr_aximm_ma_awaddr_o,
    ddr_aximm_ma_awlen_o                      => ddr_aximm_ma_awlen_o,
    ddr_aximm_ma_awsize_o                     => ddr_aximm_ma_awsize_o,
    ddr_aximm_ma_awburst_o                    => ddr_aximm_ma_awburst_o,
    ddr_aximm_ma_awlock_o                     => ddr_aximm_ma_awlock_o,
    ddr_aximm_ma_awcache_o                    => ddr_aximm_ma_awcache_o,
    ddr_aximm_ma_awprot_o                     => ddr_aximm_ma_awprot_o,
    ddr_aximm_ma_awqos_o                      => ddr_aximm_ma_awqos_o,
    ddr_aximm_ma_awvalid_o                    => ddr_aximm_ma_awvalid_o,
    ddr_aximm_ma_awready_i                    => ddr_aximm_ma_awready_i,
    ddr_aximm_ma_wdata_o                      => ddr_aximm_ma_wdata_o,
    ddr_aximm_ma_wstrb_o                      => ddr_aximm_ma_wstrb_o,
    ddr_aximm_ma_wlast_o                      => ddr_aximm_ma_wlast_o,
    ddr_aximm_ma_wvalid_o                     => ddr_aximm_ma_wvalid_o,
    ddr_aximm_ma_wready_i                     => ddr_aximm_ma_wready_i,
    ddr_aximm_ma_bready_o                     => ddr_aximm_ma_bready_o,
    ddr_aximm_ma_bid_i                        => ddr_aximm_ma_bid_i,
    ddr_aximm_ma_bresp_i                      => ddr_aximm_ma_bresp_i,
    ddr_aximm_ma_bvalid_i                     => ddr_aximm_ma_bvalid_i,
    ddr_aximm_ma_arid_o                       => ddr_aximm_ma_arid_o,
    ddr_aximm_ma_araddr_o                     => ddr_aximm_ma_araddr_o,
    ddr_aximm_ma_arlen_o                      => ddr_aximm_ma_arlen_o,
    ddr_aximm_ma_arsize_o                     => ddr_aximm_ma_arsize_o,
    ddr_aximm_ma_arburst_o                    => ddr_aximm_ma_arburst_o,
    ddr_aximm_ma_arlock_o                     => ddr_aximm_ma_arlock_o,
    ddr_aximm_ma_arcache_o                    => ddr_aximm_ma_arcache_o,
    ddr_aximm_ma_arprot_o                     => ddr_aximm_ma_arprot_o,
    ddr_aximm_ma_arqos_o                      => ddr_aximm_ma_arqos_o,
    ddr_aximm_ma_arvalid_o                    => ddr_aximm_ma_arvalid_o,
    ddr_aximm_ma_arready_i                    => ddr_aximm_ma_arready_i,
    ddr_aximm_ma_rready_o                     => ddr_aximm_ma_rready_o,
    ddr_aximm_ma_rid_i                        => ddr_aximm_ma_rid_i,
    ddr_aximm_ma_rdata_i                      => ddr_aximm_ma_rdata_i,
    ddr_aximm_ma_rresp_i                      => ddr_aximm_ma_rresp_i,
    ddr_aximm_ma_rlast_i                      => ddr_aximm_ma_rlast_i,
    ddr_aximm_ma_rvalid_i                     => ddr_aximm_ma_rvalid_i
  );

  gen_wb_acq_core_plain_mux_plain_inputs_cores : for i in 0 to g_acq_num_cores - 1 generate
    gen_wb_acq_core_plain_mux_plain_inputs_chan : for j in 0 to g_acq_num_channels - 1 generate

      acq_val_low_array(i*g_acq_num_channels+j)      <=
              acq_val_low_array_i(i*g_acq_num_channels*c_acq_chan_width + c_acq_chan_width*(j+1)-1 downto i*g_acq_num_channels*c_acq_chan_width + c_acq_chan_width*j);
      acq_val_high_array(i*g_acq_num_channels+j)     <=
              acq_val_high_array_i(i*g_acq_num_channels*c_acq_chan_width + c_acq_chan_width*(j+1)-1 downto i*g_acq_num_channels*c_acq_chan_width + c_acq_chan_width*j);
      acq_dvalid_array(i*g_acq_num_channels+j)       <= acq_dvalid_array_i(i*g_acq_num_channels+j);
      acq_trig_array(i*g_acq_num_channels+j)         <= acq_trig_array_i(i*g_acq_num_channels+j);

    end generate;
  end generate;

end rtl;
