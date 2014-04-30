library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.bpm_pcie_k7_const_pkg.all;

package bpm_pcie_k7_pkg is

  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------
  component wb_bpm_pcie_k7
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
  end component;

  component xwb_bpm_pcie_k7
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
  end component;

end bpm_pcie_k7_pkg;
