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
use work.bpm_pcie_a7_pkg.all;
use work.bpm_pcie_a7_const_pkg.all;

entity xwb_bpm_pcie_a7 is
generic (
  g_ma_interface_mode                       : t_wishbone_interface_mode := PIPELINED;
  g_ma_address_granularity                  : t_wishbone_address_granularity := BYTE;
  g_ext_rst_pin                             : boolean := true;
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
  ddr_core_rst_i                            : in  std_logic;
  memc_ui_clk_o                             : out std_logic;
  memc_ui_rst_o                             : out std_logic;
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
  wb_ma_i                                   : in  t_wishbone_master_in := cc_dummy_slave_out;
  wb_ma_o                                   : out t_wishbone_master_out;

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
end entity xwb_bpm_pcie_a7;

architecture rtl of xwb_bpm_pcie_a7 is

begin

  cmp_wb_bpm_pcie_a7 : wb_bpm_pcie_a7
  generic map (
    g_ma_interface_mode                      => g_ma_interface_mode,
    g_ma_address_granularity                 => g_ma_address_granularity,
    g_ext_rst_pin                            => g_ext_rst_pin,
    g_sim_bypass_init_cal                    => g_sim_bypass_init_cal
  )
  port map (
    -- DDR3 memory pins
    ddr3_dq_b                                => ddr3_dq_b,
    ddr3_dqs_p_b                             => ddr3_dqs_p_b,
    ddr3_dqs_n_b                             => ddr3_dqs_n_b,
    ddr3_addr_o                              => ddr3_addr_o,
    ddr3_ba_o                                => ddr3_ba_o,
    ddr3_cs_n_o                              => ddr3_cs_n_o,
    ddr3_ras_n_o                             => ddr3_ras_n_o,
    ddr3_cas_n_o                             => ddr3_cas_n_o,
    ddr3_we_n_o                              => ddr3_we_n_o,
    ddr3_reset_n_o                           => ddr3_reset_n_o,
    ddr3_ck_p_o                              => ddr3_ck_p_o,
    ddr3_ck_n_o                              => ddr3_ck_n_o,
    ddr3_cke_o                               => ddr3_cke_o,
    ddr3_dm_o                                => ddr3_dm_o,
    ddr3_odt_o                               => ddr3_odt_o,

    -- PCIe transceivers
    pci_exp_rxp_i                            => pci_exp_rxp_i,
    pci_exp_rxn_i                            => pci_exp_rxn_i,
    pci_exp_txp_o                            => pci_exp_txp_o,
    pci_exp_txn_o                            => pci_exp_txn_o,

    -- Necessity signals
    ddr_clk_p_i                              => ddr_clk_p_i,
    ddr_clk_n_i                              => ddr_clk_n_i,
    pcie_clk_p_i                             => pcie_clk_p_i,
    pcie_clk_n_i                             => pcie_clk_n_i,
    pcie_rst_n_i                             => pcie_rst_n_i,

    -- DDR memory controller interface
    ddr_core_rst_i                           => ddr_core_rst_i,
    memc_ui_clk_o                            => memc_ui_clk_o,
    memc_ui_rst_o                            => memc_ui_rst_o,
    memc_cmd_rdy_o                           => memc_cmd_rdy_o,
    memc_cmd_en_i                            => memc_cmd_en_i,
    memc_cmd_instr_i                         => memc_cmd_instr_i,
    memc_cmd_addr_i                          => memc_cmd_addr_i,
    memc_wr_en_i                             => memc_wr_en_i,
    memc_wr_end_i                            => memc_wr_end_i,
    memc_wr_mask_i                           => memc_wr_mask_i,
    memc_wr_data_i                           => memc_wr_data_i,
    memc_wr_rdy_o                            => memc_wr_rdy_o,
    memc_rd_data_o                           => memc_rd_data_o,
    memc_rd_valid_o                          => memc_rd_valid_o,
    ---- memory arbiter interface
    memarb_acc_req_i                         => memarb_acc_req_i,
    memarb_acc_gnt_o                         => memarb_acc_gnt_o,

    -- Wishbone interface --
    wb_clk_i                                 => wb_clk_i,
    wb_rst_i                                 => wb_rst_i,
    wb_ma_adr_o                              => wb_ma_o.adr,
    wb_ma_dat_o                              => wb_ma_o.dat,
    wb_ma_sel_o                              => wb_ma_o.sel,
    wb_ma_cyc_o                              => wb_ma_o.cyc,
    wb_ma_stb_o                              => wb_ma_o.stb,
    wb_ma_we_o                               => wb_ma_o.we,
    wb_ma_dat_i                              => wb_ma_i.dat,
    wb_ma_err_i                              => wb_ma_i.err,
    wb_ma_rty_i                              => wb_ma_i.rty,
    wb_ma_ack_i                              => wb_ma_i.ack,
    wb_ma_stall_i                            => wb_ma_i.stall,
    -- Additional exported signals for instantiation
    wb_ma_pcie_rst_o                         => wb_ma_pcie_rst_o,

    -- Debug signals
    dbg_app_addr_o                           => dbg_app_addr_o,
    dbg_app_cmd_o                            => dbg_app_cmd_o,
    dbg_app_en_o                             => dbg_app_en_o,
    dbg_app_wdf_data_o                       => dbg_app_wdf_data_o,
    dbg_app_wdf_end_o                        => dbg_app_wdf_end_o,
    dbg_app_wdf_wren_o                       => dbg_app_wdf_wren_o,
    dbg_app_wdf_mask_o                       => dbg_app_wdf_mask_o,
    dbg_app_rd_data_o                        => dbg_app_rd_data_o,
    dbg_app_rd_data_end_o                    => dbg_app_rd_data_end_o,
    dbg_app_rd_data_valid_o                  => dbg_app_rd_data_valid_o,
    dbg_app_rdy_o                            => dbg_app_rdy_o,
    dbg_app_wdf_rdy_o                        => dbg_app_wdf_rdy_o,
    dbg_ddr_ui_clk_o                         => dbg_ddr_ui_clk_o,
    dbg_ddr_ui_reset_o                       => dbg_ddr_ui_reset_o,

    dbg_arb_req_o                            => dbg_arb_req_o,
    dbg_arb_gnt_o                            => dbg_arb_gnt_o
  );

end rtl;
