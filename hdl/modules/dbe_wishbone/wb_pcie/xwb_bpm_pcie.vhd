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
  ddr_aximm_sl_i                            : in t_aximm_in := cc_dummy_aximm_slave_in;
  ddr_aximm_sl_o                            : out t_aximm_out;

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
    ddr_clk_p_i                              => ddr_clk_p_i,
    ddr_clk_n_i                              => ddr_clk_n_i,
    pcie_clk_p_i                             => pcie_clk_p_i,
    pcie_clk_n_i                             => pcie_clk_n_i,
    pcie_rst_n_i                             => pcie_rst_n_i,

    -- DDR memory controller interface
    ddr_axi_aclk_o                          => ddr_aximm_sl_aclk_o,
    ddr_axi_aresetn_o                       => ddr_aximm_sl_aresetn_o,
    ddr_axi_awid_i                          => ddr_aximm_sl_i.awid,
    ddr_axi_awaddr_i                        => ddr_aximm_sl_i.awaddr,
    ddr_axi_awlen_i                         => ddr_aximm_sl_i.awlen,
    ddr_axi_awsize_i                        => ddr_aximm_sl_i.awsize,
    ddr_axi_awburst_i                       => ddr_aximm_sl_i.awburst,
    ddr_axi_awlock_i                        => ddr_aximm_sl_i.awlock,
    ddr_axi_awcache_i                       => ddr_aximm_sl_i.awcache,
    ddr_axi_awprot_i                        => ddr_aximm_sl_i.awprot,
    ddr_axi_awqos_i                         => ddr_aximm_sl_i.awqos,
    ddr_axi_awvalid_i                       => ddr_aximm_sl_i.awvalid,
    ddr_axi_awready_o                       => ddr_aximm_sl_o.awready,
    ddr_axi_wdata_i                         => ddr_aximm_sl_i.wdata,
    ddr_axi_wstrb_i                         => ddr_aximm_sl_i.wstrb,
    ddr_axi_wlast_i                         => ddr_aximm_sl_i.wlast,
    ddr_axi_wvalid_i                        => ddr_aximm_sl_i.wvalid,
    ddr_axi_wready_o                        => ddr_aximm_sl_o.wready,
    ddr_axi_bready_i                        => ddr_aximm_sl_i.bready,
    ddr_axi_bid_o                           => ddr_aximm_sl_o.bid,
    ddr_axi_bresp_o                         => ddr_aximm_sl_o.bresp,
    ddr_axi_bvalid_o                        => ddr_aximm_sl_o.bvalid,
    ddr_axi_arid_i                          => ddr_aximm_sl_i.arid,
    ddr_axi_araddr_i                        => ddr_aximm_sl_i.araddr,
    ddr_axi_arlen_i                         => ddr_aximm_sl_i.arlen,
    ddr_axi_arsize_i                        => ddr_aximm_sl_i.arsize,
    ddr_axi_arburst_i                       => ddr_aximm_sl_i.arburst,
    ddr_axi_arlock_i                        => ddr_aximm_sl_i.arlock,
    ddr_axi_arcache_i                       => ddr_aximm_sl_i.arcache,
    ddr_axi_arprot_i                        => ddr_aximm_sl_i.arprot,
    ddr_axi_arqos_i                         => ddr_aximm_sl_i.arqos,
    ddr_axi_arvalid_i                       => ddr_aximm_sl_i.arvalid,
    ddr_axi_arready_o                       => ddr_aximm_sl_o.arready,
    ddr_axi_rready_i                        => ddr_aximm_sl_i.rready,
    ddr_axi_rid_o                           => ddr_aximm_sl_o.rid,
    ddr_axi_rdata_o                         => ddr_aximm_sl_o.rdata,
    ddr_axi_rresp_o                         => ddr_aximm_sl_o.rresp,
    ddr_axi_rlast_o                         => ddr_aximm_sl_o.rlast,
    ddr_axi_rvalid_o                        => ddr_aximm_sl_o.rvalid,

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
