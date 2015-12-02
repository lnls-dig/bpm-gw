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
use work.dbe_wishbone_pkg.all;
use work.ipcores_pkg.all;
use work.bpm_axi_pkg.all;

entity xwb_bpm_pcie is
generic (
  g_ma_interface_mode                       : t_wishbone_interface_mode := PIPELINED;
  g_ma_address_granularity                  : t_wishbone_address_granularity := BYTE;
  g_simulation                              : string  := "FALSE"
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
  pci_exp_rxp_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_rxn_i                             : in  std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_txp_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);
  pci_exp_txn_o                             : out std_logic_vector(c_pcielanes - 1 downto 0);

  -- Necessity signals
  ddr_clk_i                                 : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
  ddr_rst_i                                 : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
  pcie_clk_p_i                              : in std_logic; --100 MHz PCIe Clock (connect directly to input pin)
  pcie_clk_n_i                              : in std_logic; --100 MHz PCIe Clock
  pcie_rst_n_i                              : in std_logic; --Reset to PCIe core

  -- DDR memory controller interface --
  ddr_aximm_sl_aclk_o                       : out std_logic;
  ddr_aximm_sl_aresetn_o                    : out std_logic;
  -- AXIMM Read Channel
  ddr_aximm_r_sl_i                          : in t_aximm_r_slave_in := cc_dummy_aximm_r_slave_in;
  ddr_aximm_r_sl_o                          : out t_aximm_r_slave_out;
  -- AXIMM Write Channel
  ddr_aximm_w_sl_i                          : in t_aximm_w_slave_in := cc_dummy_aximm_w_slave_in;
  ddr_aximm_w_sl_o                          : out t_aximm_w_slave_out;

  -- Wishbone interface --
  wb_clk_i                                  : in std_logic;
  wb_rst_i                                  : in std_logic;
  wb_ma_i                                   : in  t_wishbone_master_in := cc_dummy_slave_out;
  wb_ma_o                                   : out t_wishbone_master_out;

  -- Additional exported signals for instantiation
  wb_ma_pcie_rst_o                          : out std_logic
);
end entity xwb_bpm_pcie;

architecture rtl of xwb_bpm_pcie is

begin

  cmp_wb_bpm_pcie : wb_bpm_pcie
  generic map (
    g_ma_interface_mode                      => g_ma_interface_mode,
    g_ma_address_granularity                 => g_ma_address_granularity,
    g_simulation                             => g_simulation
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
    ddr_clk_i                                => ddr_clk_i,
    ddr_rst_i                                => ddr_rst_i,
    pcie_clk_p_i                             => pcie_clk_p_i,
    pcie_clk_n_i                             => pcie_clk_n_i,
    pcie_rst_n_i                             => pcie_rst_n_i,

    -- DDR memory controller interface
    ddr_aximm_sl_aclk_o                      => ddr_aximm_sl_aclk_o,
    ddr_aximm_sl_aresetn_o                   => ddr_aximm_sl_aresetn_o,
    ddr_aximm_w_sl_awid_i                    => ddr_aximm_w_sl_i.awid,
    ddr_aximm_w_sl_awaddr_i                  => ddr_aximm_w_sl_i.awaddr,
    ddr_aximm_w_sl_awlen_i                   => ddr_aximm_w_sl_i.awlen,
    ddr_aximm_w_sl_awsize_i                  => ddr_aximm_w_sl_i.awsize,
    ddr_aximm_w_sl_awburst_i                 => ddr_aximm_w_sl_i.awburst,
    ddr_aximm_w_sl_awlock_i                  => ddr_aximm_w_sl_i.awlock,
    ddr_aximm_w_sl_awcache_i                 => ddr_aximm_w_sl_i.awcache,
    ddr_aximm_w_sl_awprot_i                  => ddr_aximm_w_sl_i.awprot,
    ddr_aximm_w_sl_awqos_i                   => ddr_aximm_w_sl_i.awqos,
    ddr_aximm_w_sl_awvalid_i                 => ddr_aximm_w_sl_i.awvalid,
    ddr_aximm_w_sl_awready_o                 => ddr_aximm_w_sl_o.awready,
    ddr_aximm_w_sl_wdata_i                   => ddr_aximm_w_sl_i.wdata,
    ddr_aximm_w_sl_wstrb_i                   => ddr_aximm_w_sl_i.wstrb,
    ddr_aximm_w_sl_wlast_i                   => ddr_aximm_w_sl_i.wlast,
    ddr_aximm_w_sl_wvalid_i                  => ddr_aximm_w_sl_i.wvalid,
    ddr_aximm_w_sl_wready_o                  => ddr_aximm_w_sl_o.wready,
    ddr_aximm_w_sl_bready_i                  => ddr_aximm_w_sl_i.bready,
    ddr_aximm_w_sl_bid_o                     => ddr_aximm_w_sl_o.bid,
    ddr_aximm_w_sl_bresp_o                   => ddr_aximm_w_sl_o.bresp,
    ddr_aximm_w_sl_bvalid_o                  => ddr_aximm_w_sl_o.bvalid,
    ddr_aximm_r_sl_arid_i                    => ddr_aximm_r_sl_i.arid,
    ddr_aximm_r_sl_araddr_i                  => ddr_aximm_r_sl_i.araddr,
    ddr_aximm_r_sl_arlen_i                   => ddr_aximm_r_sl_i.arlen,
    ddr_aximm_r_sl_arsize_i                  => ddr_aximm_r_sl_i.arsize,
    ddr_aximm_r_sl_arburst_i                 => ddr_aximm_r_sl_i.arburst,
    ddr_aximm_r_sl_arlock_i                  => ddr_aximm_r_sl_i.arlock,
    ddr_aximm_r_sl_arcache_i                 => ddr_aximm_r_sl_i.arcache,
    ddr_aximm_r_sl_arprot_i                  => ddr_aximm_r_sl_i.arprot,
    ddr_aximm_r_sl_arqos_i                   => ddr_aximm_r_sl_i.arqos,
    ddr_aximm_r_sl_arvalid_i                 => ddr_aximm_r_sl_i.arvalid,
    ddr_aximm_r_sl_arready_o                 => ddr_aximm_r_sl_o.arready,
    ddr_aximm_r_sl_rready_i                  => ddr_aximm_r_sl_i.rready,
    ddr_aximm_r_sl_rid_o                     => ddr_aximm_r_sl_o.rid,
    ddr_aximm_r_sl_rdata_o                   => ddr_aximm_r_sl_o.rdata,
    ddr_aximm_r_sl_rresp_o                   => ddr_aximm_r_sl_o.rresp,
    ddr_aximm_r_sl_rlast_o                   => ddr_aximm_r_sl_o.rlast,
    ddr_aximm_r_sl_rvalid_o                  => ddr_aximm_r_sl_o.rvalid,

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
    wb_ma_pcie_rst_o                         => wb_ma_pcie_rst_o
  );

end rtl;
