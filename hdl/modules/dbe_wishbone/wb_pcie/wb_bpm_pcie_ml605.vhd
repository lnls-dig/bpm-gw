------------------------------------------------------------------------------
-- Title      : Top DSP design
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2014-04-30
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Wishbone Wrapper for PCI Core
-------------------------------------------------------------------------------
-- Copyright (c) 2014 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-04-30  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.bpm_pcie_ml605_priv_pkg.all;
use work.bpm_pcie_ml605_const_pkg.all;

entity wb_bpm_pcie_ml605 is
generic (
  g_ma_interface_mode                       : t_wishbone_interface_mode := PIPELINED;
  g_ma_address_granularity                  : t_wishbone_address_granularity := BYTE;
  g_sim_bypass_init_cal                     : string  := "FAST"
);
port (
  -- DDR3 memory pins
  ddr3_dq_b                                 : inout std_logic_vector(c_ddr_dq_width-1 downto 0);
  ddr3_dqs_p_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
  ddr3_dqs_n_b                              : inout std_logic_vector(c_ddr_dqs_width-1 downto 0);
  ddr3_addr_o                               : out   std_logic_vector(c_ddr_row_width-1 downto 0);
  ddr3_ba_o                                 : out   std_logic_vector(c_ddr_bank_width-1 downto 0);
  ddr3_cs_n_o                               : out   std_logic_vector(0 downto 0);
  ddr3_ras_n_o                              : out   std_logic;
  ddr3_cas_n_o                              : out   std_logic;
  ddr3_we_n_o                               : out   std_logic;
  ddr3_reset_n_o                            : out   std_logic;
  ddr3_ck_p_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
  ddr3_ck_n_o                               : out   std_logic_vector(c_ddr_ck_width-1 downto 0);
  ddr3_cke_o                                : out   std_logic_vector(c_ddr_cke_width-1 downto 0);
  ddr3_dm_o                                 : out   std_logic_vector(c_ddr_dm_width-1 downto 0);
  ddr3_odt_o                                : out   std_logic_vector(c_ddr_odt_width-1 downto 0);

  -- PCIe transceivers
  pci_exp_rxp_i                             : in  std_logic_vector(c_pcie_lanes - 1 downto 0);
  pci_exp_rxn_i                             : in  std_logic_vector(c_pcie_lanes - 1 downto 0);
  pci_exp_txp_o                             : out std_logic_vector(c_pcie_lanes - 1 downto 0);
  pci_exp_txn_o                             : out std_logic_vector(c_pcie_lanes - 1 downto 0);

  -- Necessity signals
  ddr_clk_p_i                               : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
  ddr_clk_n_i                               : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
  pcie_clk_p_i                              : in std_logic; --100 MHz PCIe Clock (connect directly to input pin)
  pcie_clk_n_i                              : in std_logic; --100 MHz PCIe Clock
  pcie_rst_n_i                              : in std_logic; --Reset to PCIe core

  -- DDR memory controller interface --
  -- uncomment when instantiating in another project
  ddr_core_rst_i                            : in  std_logic;
  memc_ui_clk_o                             : out  std_logic;
  memc_ui_rst_o                             : out  std_logic;
  memc_cmd_rdy_o                            : out std_logic;
  memc_cmd_en_i                             : in  std_logic;
  memc_cmd_instr_i                          : in  std_logic_vector(2 downto 0);
  memc_cmd_addr_i                           : in  std_logic_vector(31 downto 0);
  memc_wr_en_i                              : in  std_logic;
  memc_wr_end_i                             : in  std_logic;
  memc_wr_mask_i                            : in  std_logic_vector(c_ddr_payload_width/8-1 downto 0);
  memc_wr_data_i                            : in  std_logic_vector(c_ddr_payload_width-1 downto 0);
  memc_wr_rdy_o                             : out std_logic;
  memc_rd_data_o                            : out std_logic_vector(c_ddr_payload_width-1 downto 0);
  memc_rd_valid_o                           : out std_logic;
  ---- memory arbiter interface
  memarb_acc_req_i                          : in  std_logic;
  memarb_acc_gnt_o                          : out std_logic;

  -- Wishbone interface --
  wb_clk_i                                  : in std_logic;
  wb_rst_i                                  : in std_logic;
  wb_ma_adr_o                               : out std_logic_vector(c_wishbone_address_width-1 downto 0);
  wb_ma_dat_o                               : out std_logic_vector(c_wishbone_data_width-1 downto 0);
  wb_ma_sel_o                               : out std_logic_vector(c_wishbone_data_width/8-1 downto 0);
  wb_ma_cyc_o                               : out std_logic;
  wb_ma_stb_o                               : out std_logic;
  wb_ma_we_o                                : out std_logic;
  wb_ma_dat_i                               : in  std_logic_vector(c_wishbone_data_width-1 downto 0)    := cc_dummy_data;
  wb_ma_err_i                               : in  std_logic                                             := '0';
  wb_ma_rty_i                               : in  std_logic                                             := '0';
  wb_ma_ack_i                               : in  std_logic                                             := '0';
  wb_ma_stall_i                             : in  std_logic                                             := '0';
  -- Additional exported signals for instantiation
  wb_ma_pcie_rst_o                          : out std_logic;

  -- Debug signals
  dbg_app_addr_o                            : out   std_logic_vector(31 downto 0);
  dbg_app_cmd_o                             : out   std_logic_vector(2 downto 0);
  dbg_app_en_o                              : out   std_logic;
  dbg_app_wdf_data_o                        : out   std_logic_vector(c_ddr_payload_width-1 downto 0);
  dbg_app_wdf_end_o                         : out   std_logic;
  dbg_app_wdf_wren_o                        : out   std_logic;
  dbg_app_wdf_mask_o                        : out   std_logic_vector(c_ddr_payload_width/8-1 downto 0);
  dbg_app_rd_data_o                         : out   std_logic_vector(c_ddr_payload_width-1 downto 0);
  dbg_app_rd_data_end_o                     : out   std_logic;
  dbg_app_rd_data_valid_o                   : out   std_logic;
  dbg_app_rdy_o                             : out   std_logic;
  dbg_app_wdf_rdy_o                         : out   std_logic;
  dbg_ddr_ui_clk_o                          : out   std_logic;
  dbg_ddr_ui_reset_o                        : out   std_logic;

  dbg_arb_req_o                             : out std_logic_vector(1 downto 0);
  dbg_arb_gnt_o                             : out std_logic_vector(1 downto 0)
);
end entity wb_bpm_pcie_ml605;

architecture rtl of wb_bpm_pcie_ml605 is

  signal wb_rstn                            : std_logic;

  -- PCIe signals
  signal wb_ma_pcie_ack_in                  : std_logic;
  signal wb_ma_pcie_dat_in                  : std_logic_vector(63 downto 0);
  signal wb_ma_pcie_addr_out                : std_logic_vector(28 downto 0);
  signal wb_ma_pcie_dat_out                 : std_logic_vector(63 downto 0);
  signal wb_ma_pcie_we_out                  : std_logic;
  signal wb_ma_pcie_stb_out                 : std_logic;
  signal wb_ma_pcie_sel_out                 : std_logic;
  signal wb_ma_pcie_cyc_out                 : std_logic;

  signal wb_ma_sladp_pcie_ack_in            : std_logic;
  signal wb_ma_sladp_pcie_dat_in            : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_addr_out          : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_dat_out           : std_logic_vector(31 downto 0);
  signal wb_ma_sladp_pcie_we_out            : std_logic;
  signal wb_ma_sladp_pcie_stb_out           : std_logic;
  signal wb_ma_sladp_pcie_sel_out           : std_logic_vector(3 downto 0);
  signal wb_ma_sladp_pcie_cyc_out           : std_logic;

begin

  ----------------------------------
  --         PCIe Core            --
  ----------------------------------
  cmp_bpm_pcie_ml605 : bpm_pcie_ml605
  generic map (
    SIM_BYPASS_INIT_CAL                     => g_sim_bypass_init_cal
  )
  port map (
    --DDR3 memory pins
    ddr3_dq                                 => ddr3_dq_b,
    ddr3_dqs_p                              => ddr3_dqs_p_b,
    ddr3_dqs_n                              => ddr3_dqs_n_b,
    ddr3_addr                               => ddr3_addr_o,
    ddr3_ba                                 => ddr3_ba_o,
    ddr3_cs_n                               => ddr3_cs_n_o,
    ddr3_ras_n                              => ddr3_ras_n_o,
    ddr3_cas_n                              => ddr3_cas_n_o,
    ddr3_we_n                               => ddr3_we_n_o,
    ddr3_reset_n                            => ddr3_reset_n_o,
    ddr3_ck_p                               => ddr3_ck_p_o,
    ddr3_ck_n                               => ddr3_ck_n_o,
    ddr3_cke                                => ddr3_cke_o,
    ddr3_dm                                 => ddr3_dm_o,
    ddr3_odt                                => ddr3_odt_o,
    -- PCIe transceivers
    pci_exp_rxp                             => pci_exp_rxp_i,
    pci_exp_rxn                             => pci_exp_rxn_i,
    pci_exp_txp                             => pci_exp_txp_o,
    pci_exp_txn                             => pci_exp_txn_o,
    -- Necessity signals
    ddr_sys_clk_p                           => ddr_clk_p_i,   --200 MHz DDR core clock (connect through BUFG or PLL)
    sys_clk_p                               => pcie_clk_p_i,  --100 MHz PCIe Clock (connect directly to input pin)
    sys_clk_n                               => pcie_clk_n_i,  --100 MHz PCIe Clock
    sys_rst_n                               => pcie_rst_n_i,  -- PCIe core reset

    -- DDR memory controller interface --
    ddr_core_rst                            => wb_rst_i,
    memc_ui_clk                             => memc_ui_clk_o,
    memc_ui_rst                             => memc_ui_rst_o,
    memc_cmd_rdy                            => memc_cmd_rdy_o,
    memc_cmd_en                             => memc_cmd_en_i,
    memc_cmd_instr                          => memc_cmd_instr_i,
    memc_cmd_addr                           => memc_cmd_addr_i,
    memc_wr_en                              => memc_wr_en_i,
    memc_wr_end                             => memc_wr_end_i,
    memc_wr_mask                            => memc_wr_mask_i,
    memc_wr_data                            => memc_wr_data_i,
    memc_wr_rdy                             => memc_wr_rdy_o,
    memc_rd_data                            => memc_rd_data_o,
    memc_rd_valid                           => memc_rd_valid_o,
    -- memory arbiter interface
    memarb_acc_req                          => memarb_acc_req_i,
    memarb_acc_gnt                          => memarb_acc_gnt_o,

    -- Wishbone interface --
    clk_i                                   => wb_clk_i,
    rst_i                                   => wb_rst_i,
    ack_i                                   => wb_ma_pcie_ack_in,
    dat_i                                   => wb_ma_pcie_dat_in,
    addr_o                                  => wb_ma_pcie_addr_out,
    dat_o                                   => wb_ma_pcie_dat_out,
    we_o                                    => wb_ma_pcie_we_out,
    stb_o                                   => wb_ma_pcie_stb_out,
    sel_o                                   => wb_ma_pcie_sel_out,
    cyc_o                                   => wb_ma_pcie_cyc_out,
    -- Additional exported signals for instantiation
    ext_rst_o                               => wb_ma_pcie_rst_o,

    -- Debug signals
    dbg_app_addr_o                          => dbg_app_addr_o,
    dbg_app_cmd_o                           => dbg_app_cmd_o,
    dbg_app_en_o                            => dbg_app_en_o,
    dbg_app_wdf_data_o                      => dbg_app_wdf_data_o,
    dbg_app_wdf_end_o                       => dbg_app_wdf_end_o,
    dbg_app_wdf_wren_o                      => dbg_app_wdf_wren_o,
    dbg_app_wdf_mask_o                      => dbg_app_wdf_mask_o,
    dbg_app_rd_data_o                       => dbg_app_rd_data_o,
    dbg_app_rd_data_end_o                   => dbg_app_rd_data_end_o,
    dbg_app_rd_data_valid_o                 => dbg_app_rd_data_valid_o,
    dbg_app_rdy_o                           => dbg_app_rdy_o,
    dbg_app_wdf_rdy_o                       => dbg_app_wdf_rdy_o,
    dbg_ddr_ui_clk_o                        => dbg_ddr_ui_clk_o,
    dbg_ddr_ui_reset_o                      => dbg_ddr_ui_reset_o,

    dbg_arb_req_o                           => dbg_arb_req_o,
    dbg_arb_gnt_o                           => dbg_arb_gnt_o
  );

  -- Connect PCIe to the Wishbone Crossbar
  wb_ma_sladp_pcie_addr_out(wb_ma_sladp_pcie_addr_out'left downto wb_ma_pcie_addr_out'left+1)
                                              <= (others => '0');
  wb_ma_sladp_pcie_addr_out(wb_ma_pcie_addr_out'left downto 0)
                                              <= wb_ma_pcie_addr_out;
  wb_ma_sladp_pcie_dat_out                    <= wb_ma_pcie_dat_out(wb_ma_sladp_pcie_dat_out'left downto 0);
  wb_ma_sladp_pcie_sel_out                    <= wb_ma_pcie_sel_out & wb_ma_pcie_sel_out &
                                                 wb_ma_pcie_sel_out & wb_ma_pcie_sel_out;
  wb_ma_sladp_pcie_cyc_out                    <= wb_ma_pcie_cyc_out;
  wb_ma_sladp_pcie_stb_out                    <= wb_ma_pcie_stb_out;
  wb_ma_sladp_pcie_we_out                     <= wb_ma_pcie_we_out;
  wb_ma_pcie_dat_in(wb_ma_pcie_dat_in'left downto wb_ma_sladp_pcie_dat_in'left+1)
                                              <= (others => '0');
  wb_ma_pcie_dat_in(wb_ma_sladp_pcie_dat_in'left downto 0)
                                              <= wb_ma_sladp_pcie_dat_in;

  wb_ma_pcie_ack_in                           <= wb_ma_sladp_pcie_ack_in;

  cmp_pcie_ma_iface_slave_adapter : wb_slave_adapter
  generic map (
    g_master_use_struct                       => false,
    g_master_mode                             => g_ma_interface_mode,
    g_master_granularity                      => g_ma_address_granularity,
    g_slave_use_struct                        => false,
    g_slave_mode                              => CLASSIC,
    g_slave_granularity                       => BYTE
  )
  port map (
    clk_sys_i                                 => wb_clk_i,
    rst_n_i                                   => wb_rstn,

    sl_adr_i                                  => wb_ma_sladp_pcie_addr_out,
    sl_dat_i                                  => wb_ma_sladp_pcie_dat_out,
    sl_sel_i                                  => wb_ma_sladp_pcie_sel_out,
    sl_cyc_i                                  => wb_ma_sladp_pcie_cyc_out,
    sl_stb_i                                  => wb_ma_sladp_pcie_stb_out,
    sl_we_i                                   => wb_ma_sladp_pcie_we_out,
    sl_dat_o                                  => wb_ma_sladp_pcie_dat_in,
    sl_ack_o                                  => wb_ma_sladp_pcie_ack_in,
    sl_stall_o                                => open,
    sl_int_o                                  => open,
    sl_rty_o                                  => open,
    sl_err_o                                  => open,

    ma_adr_o                                  => wb_ma_adr_o,
    ma_dat_o                                  => wb_ma_dat_o,
    ma_sel_o                                  => wb_ma_sel_o,
    ma_cyc_o                                  => wb_ma_cyc_o,
    ma_stb_o                                  => wb_ma_stb_o,
    ma_we_o                                   => wb_ma_we_o,
    ma_dat_i                                  => wb_ma_dat_i,
    ma_err_i                                  => wb_ma_err_i,
    ma_rty_i                                  => wb_ma_rty_i,
    ma_ack_i                                  => wb_ma_ack_i,
    ma_stall_i                                => wb_ma_stall_i
  );

  wb_rstn                                     <= not wb_rst_i;

end rtl;
