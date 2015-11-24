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

entity wb_bpm_pcie is
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
  ddr_aximm_sl_awid_i                       : in std_logic_vector (0 downto 0);
  ddr_aximm_sl_awaddr_i                     : in std_logic_vector (31 downto 0);
  ddr_aximm_sl_awlen_i                      : in std_logic_vector (7 downto 0);
  ddr_aximm_sl_awsize_i                     : in std_logic_vector (2 downto 0);
  ddr_aximm_sl_awburst_i                    : in std_logic_vector (1 downto 0);
  ddr_aximm_sl_awlock_i                     : in std_logic;
  ddr_aximm_sl_awcache_i                    : in std_logic_vector (3 downto 0);
  ddr_aximm_sl_awprot_i                     : in std_logic_vector (2 downto 0);
  ddr_aximm_sl_awqos_i                      : in std_logic_vector (3 downto 0);
  ddr_aximm_sl_awvalid_i                    : in std_logic;
  ddr_aximm_sl_awready_o                    : out std_logic;
  ddr_aximm_sl_wdata_i                      : in std_logic_vector (c_ddr_payload_width-1 downto 0);
  ddr_aximm_sl_wstrb_i                      : in std_logic_vector (c_ddr_payload_width/8-1 downto 0);
  ddr_aximm_sl_wlast_i                      : in std_logic;
  ddr_aximm_sl_wvalid_i                     : in std_logic;
  ddr_aximm_sl_wready_o                     : out std_logic;
  ddr_aximm_sl_bready_i                     : in std_logic;
  ddr_aximm_sl_bid_o                        : out std_logic_vector (0 downto 0);
  ddr_aximm_sl_bresp_o                      : out std_logic_vector (1 downto 0);
  ddr_aximm_sl_bvalid_o                     : out std_logic;
  ddr_aximm_sl_arid_i                       : in std_logic_vector (0 downto 0);
  ddr_aximm_sl_araddr_i                     : in std_logic_vector (31 downto 0);
  ddr_aximm_sl_arlen_i                      : in std_logic_vector (7 downto 0);
  ddr_aximm_sl_arsize_i                     : in std_logic_vector (2 downto 0);
  ddr_aximm_sl_arburst_i                    : in std_logic_vector (1 downto 0);
  ddr_aximm_sl_arlock_i                     : in std_logic;
  ddr_aximm_sl_arcache_i                    : in std_logic_vector (3 downto 0);
  ddr_aximm_sl_arprot_i                     : in std_logic_vector (2 downto 0);
  ddr_aximm_sl_arqos_i                      : in std_logic_vector (3 downto 0);
  ddr_aximm_sl_arvalid_i                    : in std_logic;
  ddr_aximm_sl_arready_o                    : out std_logic;
  ddr_aximm_sl_rready_i                     : in std_logic;
  ddr_aximm_sl_rid_o                        : out std_logic_vector (0 downto 0 );
  ddr_aximm_sl_rdata_o                      : out std_logic_vector (c_ddr_payload_width-1 downto 0);
  ddr_aximm_sl_rresp_o                      : out std_logic_vector (1 downto 0 );
  ddr_aximm_sl_rlast_o                      : out std_logic;
  ddr_aximm_sl_rvalid_o                     : out std_logic;

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
  wb_ma_pcie_rst_o                          : out std_logic
);
end entity wb_bpm_pcie;

architecture rtl of wb_bpm_pcie is

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

  component bpm_pcie
  generic (
    SIMULATION   : string := "FALSE"
    );
  port (
    --DDR3 memory pins
    ddr3_dq      : inout std_logic_vector(C_DDR_DQ_WIDTH-1 downto 0);
    ddr3_dqs_p   : inout std_logic_vector(C_DDR_DQS_WIDTH-1 downto 0);
    ddr3_dqs_n   : inout std_logic_vector(C_DDR_DQS_WIDTH-1 downto 0);
    ddr3_addr    : out   std_logic_vector(C_DDR_ROW_WIDTH-1 downto 0);
    ddr3_ba      : out   std_logic_vector(C_DDR_BANK_WIDTH-1 downto 0);
    ddr3_ras_n   : out   std_logic;
    ddr3_cas_n   : out   std_logic;
    ddr3_we_n    : out   std_logic;
    ddr3_reset_n : out   std_logic;
    ddr3_ck_p    : out   std_logic_vector(C_DDR_CK_WIDTH-1 downto 0);
    ddr3_ck_n    : out   std_logic_vector(C_DDR_CK_WIDTH-1 downto 0);
    ddr3_cke     : out   std_logic_vector(C_DDR_CKE_WIDTH-1 downto 0);
    ddr3_cs_n    : out   std_logic_vector(0 downto 0);
    ddr3_dm      : out   std_logic_vector(C_DDR_DM_WIDTH-1 downto 0);
    ddr3_odt     : out   std_logic_vector(C_DDR_ODT_WIDTH-1 downto 0);
    -- PCIe transceivers
    pci_exp_rxp : in  std_logic_vector(c_pcielanes-1 downto 0);
    pci_exp_rxn : in  std_logic_vector(c_pcielanes-1 downto 0);
    pci_exp_txp : out std_logic_vector(c_pcielanes-1 downto 0);
    pci_exp_txn : out std_logic_vector(c_pcielanes-1 downto 0);
    -- Necessity signals
    ddr_sys_clk   : in std_logic;
    ddr_sys_rst   : in std_logic;
    pci_sys_clk_p : in std_logic;         --100 MHz PCIe Clock
    pci_sys_clk_n : in std_logic;         --100 MHz PCIe Clock
    pci_sys_rst_n : in std_logic; --Reset to PCIe core
    -- DDR memory controller interface --
    ddr_axi_aclk_o : out std_logic;
    ddr_axi_aresetn_o : out std_logic;
    ddr_axi_awid : in STD_LOGIC_VECTOR ( 0 downto 0 );
    ddr_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ddr_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ddr_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_axi_awlock : in STD_LOGIC;
    ddr_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ddr_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ddr_axi_awvalid : in STD_LOGIC;
    ddr_axi_awready : out STD_LOGIC;
    ddr_axi_wdata : in STD_LOGIC_VECTOR ( c_ddr_payload_width-1 downto 0 );
    ddr_axi_wstrb : in STD_LOGIC_VECTOR ( c_ddr_payload_width/8-1 downto 0 );
    ddr_axi_wlast : in STD_LOGIC;
    ddr_axi_wvalid : in STD_LOGIC;
    ddr_axi_wready : out STD_LOGIC;
    ddr_axi_bready : in STD_LOGIC;
    ddr_axi_bid : out STD_LOGIC_VECTOR ( 0 downto 0 );
    ddr_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_axi_bvalid : out STD_LOGIC;
    ddr_axi_arid : in STD_LOGIC_VECTOR ( 0 downto 0 );
    ddr_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    ddr_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ddr_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_axi_arlock : in STD_LOGIC;
    ddr_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ddr_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    ddr_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    ddr_axi_arvalid : in STD_LOGIC;
    ddr_axi_arready : out STD_LOGIC;
    ddr_axi_rready : in STD_LOGIC;
    ddr_axi_rid : out STD_LOGIC_VECTOR ( 0 downto 0 );
    ddr_axi_rdata : out STD_LOGIC_VECTOR ( c_ddr_payload_width-1 downto 0 );
    ddr_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    ddr_axi_rlast : out STD_LOGIC;
    ddr_axi_rvalid : out STD_LOGIC;
    -- Wishbone interface --
    CLK_I : in  std_logic;
    RST_I : in  std_logic;
    ACK_I : in  std_logic;
    DAT_I : in  std_logic_vector(63 downto 0);
    ADDR_O : out std_logic_vector(28 downto 0);
    DAT_O : out std_logic_vector(63 downto 0);
    WE_O  : out std_logic;
    STB_O : out std_logic;
    SEL_O : out std_logic;
    CYC_O : out std_logic;
    --/ Wishbone interface
    -- Additional exported signals for instantiation
    ext_rst_o : out std_logic
    );
  end component;

begin

  ----------------------------------
  --         PCIe Core            --
  ----------------------------------
  cmp_bpm_pcie : bpm_pcie
  generic map (
    SIMULATION                              => g_simulation
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
    ddr_sys_clk                             => ddr_clk_i,   --200 MHz DDR core clock (connect through BUFG or PLL)
    ddr_sys_rst                             => ddr_rst_i,   --DDR core reset
    pci_sys_clk_p                           => pcie_clk_p_i,  --100 MHz PCIe Clock (connect directly to input pin)
    pci_sys_clk_n                           => pcie_clk_n_i,  --100 MHz PCIe Clock
    pci_sys_rst_n                           => pcie_rst_n_i,  -- PCIe core reset

    -- DDR memory controller interface --
    ddr_axi_aclk_o                          => ddr_aximm_sl_aclk_o,
    ddr_axi_aresetn_o                       => ddr_aximm_sl_aresetn_o,
    ddr_axi_awid_i                          => ddr_aximm_sl_awid_i,
    ddr_axi_awaddr_i                        => ddr_aximm_sl_awaddr_i,
    ddr_axi_awlen_i                         => ddr_aximm_sl_awlen_i,
    ddr_axi_awsize_i                        => ddr_aximm_sl_awsize_i,
    ddr_axi_awburst_i                       => ddr_aximm_sl_awburst_i,
    ddr_axi_awlock_i                        => ddr_aximm_sl_awlock_i,
    ddr_axi_awcache_i                       => ddr_aximm_sl_awcache_i,
    ddr_axi_awprot_i                        => ddr_aximm_sl_awprot_i,
    ddr_axi_awqos_i                         => ddr_aximm_sl_awqos_i,
    ddr_axi_awvalid_i                       => ddr_aximm_sl_awvalid_i,
    ddr_axi_awready_o                       => ddr_aximm_sl_awready_o,
    ddr_axi_wdata_i                         => ddr_aximm_sl_wdata_i,
    ddr_axi_wstrb_i                         => ddr_aximm_sl_wstrb_i,
    ddr_axi_wlast_i                         => ddr_aximm_sl_wlast_i,
    ddr_axi_wvalid_i                        => ddr_aximm_sl_wvalid_i,
    ddr_axi_wready_o                        => ddr_aximm_sl_wready_o,
    ddr_axi_bready_i                        => ddr_aximm_sl_bready_i,
    ddr_axi_bid_o                           => ddr_aximm_sl_bid_o,
    ddr_axi_bresp_o                         => ddr_aximm_sl_bresp_o,
    ddr_axi_bvalid_o                        => ddr_aximm_sl_bvalid_o,
    ddr_axi_arid_i                          => ddr_aximm_sl_arid_i,
    ddr_axi_araddr_i                        => ddr_aximm_sl_araddr_i,
    ddr_axi_arlen_i                         => ddr_aximm_sl_arlen_i,
    ddr_axi_arsize_i                        => ddr_aximm_sl_arsize_i,
    ddr_axi_arburst_i                       => ddr_aximm_sl_arburst_i,
    ddr_axi_arlock_i                        => ddr_aximm_sl_arlock_i,
    ddr_axi_arcache_i                       => ddr_aximm_sl_arcache_i,
    ddr_axi_arprot_i                        => ddr_aximm_sl_arprot_i,
    ddr_axi_arqos_i                         => ddr_aximm_sl_arqos_i,
    ddr_axi_arvalid_i                       => ddr_aximm_sl_arvalid_i,
    ddr_axi_arready_o                       => ddr_aximm_sl_arready_o,
    ddr_axi_rready_i                        => ddr_aximm_sl_rready_i,
    ddr_axi_rid_o                           => ddr_aximm_sl_rid_o,
    ddr_axi_rdata_o                         => ddr_aximm_sl_rdata_o,
    ddr_axi_rresp_o                         => ddr_aximm_sl_rresp_o,
    ddr_axi_rlast_o                         => ddr_aximm_sl_rlast_o,
    ddr_axi_rvalid_o                        => ddr_aximm_sl_rvalid_o,

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
    ext_rst_o                               => wb_ma_pcie_rst_o
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
