library IEEE;
use IEEE.STD_LOGIC_1164.all;

package ipcores_pkg is

constant c_pcielanes : positive := 4;
--***************************************************************************
-- Necessary parameters for DDR core support
-- (dependent on memory chip connected to FPGA, not to be modified at will)
--***************************************************************************
constant C_DDR_DQ_WIDTH      : positive := 64;
constant C_DDR_PAYLOAD_WIDTH : positive := 512;
constant C_DDR_DQS_WIDTH     : positive := 8;
constant C_DDR_DM_WIDTH      : positive := 8;
constant C_DDR_ROW_WIDTH     : positive := 14;
constant C_DDR_BANK_WIDTH    : positive := 3;
constant C_DDR_CK_WIDTH      : positive := 1;
constant C_DDR_CKE_WIDTH     : positive := 1;
constant C_DDR_ODT_WIDTH     : positive := 1;
constant C_DDR_ADDR_WIDTH    : positive := 30;

constant C_DDR_TID_WIDTH : positive := 8;
constant C_AXI_SLAVE_TID_WIDTH : positive := 4;

  -- ----------------------------------------------------------------------------
  -- Component declarations
  -- ----------------------------------------------------------------------------
component pcie_core
Port ( 
  pci_exp_txp : out STD_LOGIC_VECTOR ( 3 downto 0 );
  pci_exp_txn : out STD_LOGIC_VECTOR ( 3 downto 0 );
  pci_exp_rxp : in STD_LOGIC_VECTOR ( 3 downto 0 );
  pci_exp_rxn : in STD_LOGIC_VECTOR ( 3 downto 0 );
  user_clk_out : out STD_LOGIC;
  user_reset_out : out STD_LOGIC;
  user_lnk_up : out STD_LOGIC;
  user_app_rdy : out STD_LOGIC;
  tx_buf_av : out STD_LOGIC_VECTOR ( 5 downto 0 );
  tx_cfg_req : out STD_LOGIC;
  tx_err_drop : out STD_LOGIC;
  s_axis_tx_tready : out STD_LOGIC;
  s_axis_tx_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
  s_axis_tx_tkeep : in STD_LOGIC_VECTOR ( 7 downto 0 );
  s_axis_tx_tlast : in STD_LOGIC;
  s_axis_tx_tvalid : in STD_LOGIC;
  s_axis_tx_tuser : in STD_LOGIC_VECTOR ( 3 downto 0 );
  tx_cfg_gnt : in STD_LOGIC;
  m_axis_rx_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
  m_axis_rx_tkeep : out STD_LOGIC_VECTOR ( 7 downto 0 );
  m_axis_rx_tlast : out STD_LOGIC;
  m_axis_rx_tvalid : out STD_LOGIC;
  m_axis_rx_tready : in STD_LOGIC;
  m_axis_rx_tuser : out STD_LOGIC_VECTOR ( 21 downto 0 );
  rx_np_ok : in STD_LOGIC;
  rx_np_req : in STD_LOGIC;
  fc_cpld : out STD_LOGIC_VECTOR ( 11 downto 0 );
  fc_cplh : out STD_LOGIC_VECTOR ( 7 downto 0 );
  fc_npd : out STD_LOGIC_VECTOR ( 11 downto 0 );
  fc_nph : out STD_LOGIC_VECTOR ( 7 downto 0 );
  fc_pd : out STD_LOGIC_VECTOR ( 11 downto 0 );
  fc_ph : out STD_LOGIC_VECTOR ( 7 downto 0 );
  fc_sel : in STD_LOGIC_VECTOR ( 2 downto 0 );
  cfg_mgmt_do : out STD_LOGIC_VECTOR ( 31 downto 0 );
  cfg_mgmt_rd_wr_done : out STD_LOGIC;
  cfg_status : out STD_LOGIC_VECTOR ( 15 downto 0 );
  cfg_command : out STD_LOGIC_VECTOR ( 15 downto 0 );
  cfg_dstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
  cfg_dcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
  cfg_lstatus : out STD_LOGIC_VECTOR ( 15 downto 0 );
  cfg_lcommand : out STD_LOGIC_VECTOR ( 15 downto 0 );
  cfg_dcommand2 : out STD_LOGIC_VECTOR ( 15 downto 0 );
  cfg_pcie_link_state : out STD_LOGIC_VECTOR ( 2 downto 0 );
  cfg_pmcsr_pme_en : out STD_LOGIC;
  cfg_pmcsr_powerstate : out STD_LOGIC_VECTOR ( 1 downto 0 );
  cfg_pmcsr_pme_status : out STD_LOGIC;
  cfg_received_func_lvl_rst : out STD_LOGIC;
  cfg_mgmt_di : in STD_LOGIC_VECTOR ( 31 downto 0 );
  cfg_mgmt_byte_en : in STD_LOGIC_VECTOR ( 3 downto 0 );
  cfg_mgmt_dwaddr : in STD_LOGIC_VECTOR ( 9 downto 0 );
  cfg_mgmt_wr_en : in STD_LOGIC;
  cfg_mgmt_rd_en : in STD_LOGIC;
  cfg_mgmt_wr_readonly : in STD_LOGIC;
  cfg_err_ecrc : in STD_LOGIC;
  cfg_err_ur : in STD_LOGIC;
  cfg_err_cpl_timeout : in STD_LOGIC;
  cfg_err_cpl_unexpect : in STD_LOGIC;
  cfg_err_cpl_abort : in STD_LOGIC;
  cfg_err_posted : in STD_LOGIC;
  cfg_err_cor : in STD_LOGIC;
  cfg_err_atomic_egress_blocked : in STD_LOGIC;
  cfg_err_internal_cor : in STD_LOGIC;
  cfg_err_malformed : in STD_LOGIC;
  cfg_err_mc_blocked : in STD_LOGIC;
  cfg_err_poisoned : in STD_LOGIC;
  cfg_err_norecovery : in STD_LOGIC;
  cfg_err_tlp_cpl_header : in STD_LOGIC_VECTOR ( 47 downto 0 );
  cfg_err_cpl_rdy : out STD_LOGIC;
  cfg_err_locked : in STD_LOGIC;
  cfg_err_acs : in STD_LOGIC;
  cfg_err_internal_uncor : in STD_LOGIC;
  cfg_trn_pending : in STD_LOGIC;
  cfg_pm_halt_aspm_l0s : in STD_LOGIC;
  cfg_pm_halt_aspm_l1 : in STD_LOGIC;
  cfg_pm_force_state_en : in STD_LOGIC;
  cfg_pm_force_state : in STD_LOGIC_VECTOR ( 1 downto 0 );
  cfg_dsn : in STD_LOGIC_VECTOR ( 63 downto 0 );
  cfg_interrupt : in STD_LOGIC;
  cfg_interrupt_rdy : out STD_LOGIC;
  cfg_interrupt_assert : in STD_LOGIC;
  cfg_interrupt_di : in STD_LOGIC_VECTOR ( 7 downto 0 );
  cfg_interrupt_do : out STD_LOGIC_VECTOR ( 7 downto 0 );
  cfg_interrupt_mmenable : out STD_LOGIC_VECTOR ( 2 downto 0 );
  cfg_interrupt_msienable : out STD_LOGIC;
  cfg_interrupt_msixenable : out STD_LOGIC;
  cfg_interrupt_msixfm : out STD_LOGIC;
  cfg_interrupt_stat : in STD_LOGIC;
  cfg_pciecap_interrupt_msgnum : in STD_LOGIC_VECTOR ( 4 downto 0 );
  cfg_to_turnoff : out STD_LOGIC;
  cfg_turnoff_ok : in STD_LOGIC;
  cfg_bus_number : out STD_LOGIC_VECTOR ( 7 downto 0 );
  cfg_device_number : out STD_LOGIC_VECTOR ( 4 downto 0 );
  cfg_function_number : out STD_LOGIC_VECTOR ( 2 downto 0 );
  cfg_pm_wake : in STD_LOGIC;
  cfg_pm_send_pme_to : in STD_LOGIC;
  cfg_ds_bus_number : in STD_LOGIC_VECTOR ( 7 downto 0 );
  cfg_ds_device_number : in STD_LOGIC_VECTOR ( 4 downto 0 );
  cfg_ds_function_number : in STD_LOGIC_VECTOR ( 2 downto 0 );
  cfg_mgmt_wr_rw1c_as_rw : in STD_LOGIC;
  cfg_msg_received : out STD_LOGIC;
  cfg_msg_data : out STD_LOGIC_VECTOR ( 15 downto 0 );
  cfg_bridge_serr_en : out STD_LOGIC;
  cfg_slot_control_electromech_il_ctl_pulse : out STD_LOGIC;
  cfg_root_control_syserr_corr_err_en : out STD_LOGIC;
  cfg_root_control_syserr_non_fatal_err_en : out STD_LOGIC;
  cfg_root_control_syserr_fatal_err_en : out STD_LOGIC;
  cfg_root_control_pme_int_en : out STD_LOGIC;
  cfg_aer_rooterr_corr_err_reporting_en : out STD_LOGIC;
  cfg_aer_rooterr_non_fatal_err_reporting_en : out STD_LOGIC;
  cfg_aer_rooterr_fatal_err_reporting_en : out STD_LOGIC;
  cfg_aer_rooterr_corr_err_received : out STD_LOGIC;
  cfg_aer_rooterr_non_fatal_err_received : out STD_LOGIC;
  cfg_aer_rooterr_fatal_err_received : out STD_LOGIC;
  cfg_msg_received_err_cor : out STD_LOGIC;
  cfg_msg_received_err_non_fatal : out STD_LOGIC;
  cfg_msg_received_err_fatal : out STD_LOGIC;
  cfg_msg_received_pm_as_nak : out STD_LOGIC;
  cfg_msg_received_pm_pme : out STD_LOGIC;
  cfg_msg_received_pme_to_ack : out STD_LOGIC;
  cfg_msg_received_assert_int_a : out STD_LOGIC;
  cfg_msg_received_assert_int_b : out STD_LOGIC;
  cfg_msg_received_assert_int_c : out STD_LOGIC;
  cfg_msg_received_assert_int_d : out STD_LOGIC;
  cfg_msg_received_deassert_int_a : out STD_LOGIC;
  cfg_msg_received_deassert_int_b : out STD_LOGIC;
  cfg_msg_received_deassert_int_c : out STD_LOGIC;
  cfg_msg_received_deassert_int_d : out STD_LOGIC;
  cfg_msg_received_setslotpowerlimit : out STD_LOGIC;
  pl_directed_link_change : in STD_LOGIC_VECTOR ( 1 downto 0 );
  pl_directed_link_width : in STD_LOGIC_VECTOR ( 1 downto 0 );
  pl_directed_link_speed : in STD_LOGIC;
  pl_directed_link_auton : in STD_LOGIC;
  pl_upstream_prefer_deemph : in STD_LOGIC;
  pl_sel_lnk_rate : out STD_LOGIC;
  pl_sel_lnk_width : out STD_LOGIC_VECTOR ( 1 downto 0 );
  pl_ltssm_state : out STD_LOGIC_VECTOR ( 5 downto 0 );
  pl_lane_reversal_mode : out STD_LOGIC_VECTOR ( 1 downto 0 );
  pl_phy_lnk_up : out STD_LOGIC;
  pl_tx_pm_state : out STD_LOGIC_VECTOR ( 2 downto 0 );
  pl_rx_pm_state : out STD_LOGIC_VECTOR ( 1 downto 0 );
  pl_link_upcfg_cap : out STD_LOGIC;
  pl_link_gen2_cap : out STD_LOGIC;
  pl_link_partner_gen2_supported : out STD_LOGIC;
  pl_initial_link_width : out STD_LOGIC_VECTOR ( 2 downto 0 );
  pl_directed_change_done : out STD_LOGIC;
  pl_received_hot_rst : out STD_LOGIC;
  pl_transmit_hot_rst : in STD_LOGIC;
  pl_downstream_deemph_source : in STD_LOGIC;
  cfg_err_aer_headerlog : in STD_LOGIC_VECTOR ( 127 downto 0 );
  cfg_aer_interrupt_msgnum : in STD_LOGIC_VECTOR ( 4 downto 0 );
  cfg_err_aer_headerlog_set : out STD_LOGIC;
  cfg_aer_ecrc_check_en : out STD_LOGIC;
  cfg_aer_ecrc_gen_en : out STD_LOGIC;
  cfg_vc_tcvc_map : out STD_LOGIC_VECTOR ( 6 downto 0 );
  sys_clk : in STD_LOGIC;
  sys_rst_n : in STD_LOGIC
);
end component;
  
component ddr_core
Port( 
  ddr3_dq : inout STD_LOGIC_VECTOR ( 63 downto 0 );
  ddr3_dqs_n : inout STD_LOGIC_VECTOR ( 7 downto 0 );
  ddr3_dqs_p : inout STD_LOGIC_VECTOR ( 7 downto 0 );
  ddr3_addr : out STD_LOGIC_VECTOR ( 13 downto 0 );
  ddr3_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
  ddr3_ras_n : out STD_LOGIC;
  ddr3_cas_n : out STD_LOGIC;
  ddr3_we_n : out STD_LOGIC;
  ddr3_reset_n : out STD_LOGIC;
  ddr3_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
  ddr3_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
  ddr3_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
  ddr3_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
  ddr3_dm : out STD_LOGIC_VECTOR ( 7 downto 0 );
  ddr3_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
  sys_clk_i : in STD_LOGIC;
  ui_clk : out STD_LOGIC;
  ui_clk_sync_rst : out STD_LOGIC;
  mmcm_locked : out STD_LOGIC;
  aresetn : in STD_LOGIC;
  app_sr_req : in STD_LOGIC;
  app_ref_req : in STD_LOGIC;
  app_zq_req : in STD_LOGIC;
  app_sr_active : out STD_LOGIC;
  app_ref_ack : out STD_LOGIC;
  app_zq_ack : out STD_LOGIC;
  s_axi_awid : in STD_LOGIC_VECTOR ( 7 downto 0 );
  s_axi_awaddr : in STD_LOGIC_VECTOR ( 29 downto 0 );
  s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
  s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
  s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
  s_axi_awlock : in STD_LOGIC_VECTOR ( 0 to 0 );
  s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
  s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
  s_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
  s_axi_awvalid : in STD_LOGIC;
  s_axi_awready : out STD_LOGIC;
  s_axi_wdata : in STD_LOGIC_VECTOR ( 511 downto 0 );
  s_axi_wstrb : in STD_LOGIC_VECTOR ( 63 downto 0 );
  s_axi_wlast : in STD_LOGIC;
  s_axi_wvalid : in STD_LOGIC;
  s_axi_wready : out STD_LOGIC;
  s_axi_bready : in STD_LOGIC;
  s_axi_bid : out STD_LOGIC_VECTOR ( 7 downto 0 );
  s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
  s_axi_bvalid : out STD_LOGIC;
  s_axi_arid : in STD_LOGIC_VECTOR ( 7 downto 0 );
  s_axi_araddr : in STD_LOGIC_VECTOR ( 29 downto 0 );
  s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
  s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
  s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
  s_axi_arlock : in STD_LOGIC_VECTOR ( 0 to 0 );
  s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
  s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
  s_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
  s_axi_arvalid : in STD_LOGIC;
  s_axi_arready : out STD_LOGIC;
  s_axi_rready : in STD_LOGIC;
  s_axi_rid : out STD_LOGIC_VECTOR ( 7 downto 0 );
  s_axi_rdata : out STD_LOGIC_VECTOR ( 511 downto 0 );
  s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
  s_axi_rlast : out STD_LOGIC;
  s_axi_rvalid : out STD_LOGIC;
  init_calib_complete : out STD_LOGIC;
  sys_rst : in STD_LOGIC
);
end component;

COMPONENT axi_interconnect
PORT (
  INTERCONNECT_ACLK : IN STD_LOGIC;
  INTERCONNECT_ARESETN : IN STD_LOGIC;
  S00_AXI_ARESET_OUT_N : OUT STD_LOGIC;
  S00_AXI_ACLK : IN STD_LOGIC;
  S00_AXI_AWID : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_AWLOCK : IN STD_LOGIC;
  S00_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_AWVALID : IN STD_LOGIC;
  S00_AXI_AWREADY : OUT STD_LOGIC;
  S00_AXI_WDATA : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
  S00_AXI_WSTRB : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  S00_AXI_WLAST : IN STD_LOGIC;
  S00_AXI_WVALID : IN STD_LOGIC;
  S00_AXI_WREADY : OUT STD_LOGIC;
  S00_AXI_BID : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_BVALID : OUT STD_LOGIC;
  S00_AXI_BREADY : IN STD_LOGIC;
  S00_AXI_ARID : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S00_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S00_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_ARLOCK : IN STD_LOGIC;
  S00_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S00_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_ARVALID : IN STD_LOGIC;
  S00_AXI_ARREADY : OUT STD_LOGIC;
  S00_AXI_RID : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  S00_AXI_RDATA : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
  S00_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S00_AXI_RLAST : OUT STD_LOGIC;
  S00_AXI_RVALID : OUT STD_LOGIC;
  S00_AXI_RREADY : IN STD_LOGIC;
  S01_AXI_ARESET_OUT_N : OUT STD_LOGIC;
  S01_AXI_ACLK : IN STD_LOGIC;
  S01_AXI_AWID : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S01_AXI_AWADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S01_AXI_AWLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S01_AXI_AWSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S01_AXI_AWBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S01_AXI_AWLOCK : IN STD_LOGIC;
  S01_AXI_AWCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S01_AXI_AWPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S01_AXI_AWQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S01_AXI_AWVALID : IN STD_LOGIC;
  S01_AXI_AWREADY : OUT STD_LOGIC;
  S01_AXI_WDATA : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
  S01_AXI_WSTRB : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  S01_AXI_WLAST : IN STD_LOGIC;
  S01_AXI_WVALID : IN STD_LOGIC;
  S01_AXI_WREADY : OUT STD_LOGIC;
  S01_AXI_BID : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  S01_AXI_BRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S01_AXI_BVALID : OUT STD_LOGIC;
  S01_AXI_BREADY : IN STD_LOGIC;
  S01_AXI_ARID : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S01_AXI_ARADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
  S01_AXI_ARLEN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  S01_AXI_ARSIZE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S01_AXI_ARBURST : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  S01_AXI_ARLOCK : IN STD_LOGIC;
  S01_AXI_ARCACHE : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S01_AXI_ARPROT : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
  S01_AXI_ARQOS : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
  S01_AXI_ARVALID : IN STD_LOGIC;
  S01_AXI_ARREADY : OUT STD_LOGIC;
  S01_AXI_RID : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  S01_AXI_RDATA : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
  S01_AXI_RRESP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  S01_AXI_RLAST : OUT STD_LOGIC;
  S01_AXI_RVALID : OUT STD_LOGIC;
  S01_AXI_RREADY : IN STD_LOGIC;
  M00_AXI_ARESET_OUT_N : OUT STD_LOGIC;
  M00_AXI_ACLK : IN STD_LOGIC;
  M00_AXI_AWID : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  M00_AXI_AWADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  M00_AXI_AWLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  M00_AXI_AWSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
  M00_AXI_AWBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  M00_AXI_AWLOCK : OUT STD_LOGIC;
  M00_AXI_AWCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  M00_AXI_AWPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
  M00_AXI_AWQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  M00_AXI_AWVALID : OUT STD_LOGIC;
  M00_AXI_AWREADY : IN STD_LOGIC;
  M00_AXI_WDATA : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
  M00_AXI_WSTRB : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  M00_AXI_WLAST : OUT STD_LOGIC;
  M00_AXI_WVALID : OUT STD_LOGIC;
  M00_AXI_WREADY : IN STD_LOGIC;
  M00_AXI_BID : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  M00_AXI_BRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  M00_AXI_BVALID : IN STD_LOGIC;
  M00_AXI_BREADY : OUT STD_LOGIC;
  M00_AXI_ARID : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  M00_AXI_ARADDR : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  M00_AXI_ARLEN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  M00_AXI_ARSIZE : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
  M00_AXI_ARBURST : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  M00_AXI_ARLOCK : OUT STD_LOGIC;
  M00_AXI_ARCACHE : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  M00_AXI_ARPROT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
  M00_AXI_ARQOS : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  M00_AXI_ARVALID : OUT STD_LOGIC;
  M00_AXI_ARREADY : IN STD_LOGIC;
  M00_AXI_RID : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  M00_AXI_RDATA : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
  M00_AXI_RRESP : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  M00_AXI_RLAST : IN STD_LOGIC;
  M00_AXI_RVALID : IN STD_LOGIC;
  M00_AXI_RREADY : OUT STD_LOGIC
);
END COMPONENT;

COMPONENT axi_datamover_0
PORT (
  m_axi_mm2s_aclk : IN STD_LOGIC;
  m_axi_mm2s_aresetn : IN STD_LOGIC;
  mm2s_err : OUT STD_LOGIC;
  m_axis_mm2s_cmdsts_aclk : IN STD_LOGIC;
  m_axis_mm2s_cmdsts_aresetn : IN STD_LOGIC;
  s_axis_mm2s_cmd_tvalid : IN STD_LOGIC;
  s_axis_mm2s_cmd_tready : OUT STD_LOGIC;
  s_axis_mm2s_cmd_tdata : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
  m_axis_mm2s_sts_tvalid : OUT STD_LOGIC;
  m_axis_mm2s_sts_tready : IN STD_LOGIC;
  m_axis_mm2s_sts_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  m_axis_mm2s_sts_tkeep : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  m_axis_mm2s_sts_tlast : OUT STD_LOGIC;
  m_axi_mm2s_araddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  m_axi_mm2s_arlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  m_axi_mm2s_arsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
  m_axi_mm2s_arburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  m_axi_mm2s_arprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
  m_axi_mm2s_arcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  m_axi_mm2s_aruser : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  m_axi_mm2s_arvalid : OUT STD_LOGIC;
  m_axi_mm2s_arready : IN STD_LOGIC;
  m_axi_mm2s_rdata : IN STD_LOGIC_VECTOR(511 DOWNTO 0);
  m_axi_mm2s_rresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  m_axi_mm2s_rlast : IN STD_LOGIC;
  m_axi_mm2s_rvalid : IN STD_LOGIC;
  m_axi_mm2s_rready : OUT STD_LOGIC;
  m_axis_mm2s_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  m_axis_mm2s_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  m_axis_mm2s_tlast : OUT STD_LOGIC;
  m_axis_mm2s_tvalid : OUT STD_LOGIC;
  m_axis_mm2s_tready : IN STD_LOGIC;
  m_axi_s2mm_aclk : IN STD_LOGIC;
  m_axi_s2mm_aresetn : IN STD_LOGIC;
  s2mm_err : OUT STD_LOGIC;
  m_axis_s2mm_cmdsts_awclk : IN STD_LOGIC;
  m_axis_s2mm_cmdsts_aresetn : IN STD_LOGIC;
  s_axis_s2mm_cmd_tvalid : IN STD_LOGIC;
  s_axis_s2mm_cmd_tready : OUT STD_LOGIC;
  s_axis_s2mm_cmd_tdata : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
  m_axis_s2mm_sts_tvalid : OUT STD_LOGIC;
  m_axis_s2mm_sts_tready : IN STD_LOGIC;
  m_axis_s2mm_sts_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  m_axis_s2mm_sts_tkeep : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
  m_axis_s2mm_sts_tlast : OUT STD_LOGIC;
  m_axi_s2mm_awaddr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
  m_axi_s2mm_awlen : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
  m_axi_s2mm_awsize : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
  m_axi_s2mm_awburst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
  m_axi_s2mm_awprot : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
  m_axi_s2mm_awcache : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  m_axi_s2mm_awuser : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
  m_axi_s2mm_awvalid : OUT STD_LOGIC;
  m_axi_s2mm_awready : IN STD_LOGIC;
  m_axi_s2mm_wdata : OUT STD_LOGIC_VECTOR(511 DOWNTO 0);
  m_axi_s2mm_wstrb : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
  m_axi_s2mm_wlast : OUT STD_LOGIC;
  m_axi_s2mm_wvalid : OUT STD_LOGIC;
  m_axi_s2mm_wready : IN STD_LOGIC;
  m_axi_s2mm_bresp : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
  m_axi_s2mm_bvalid : IN STD_LOGIC;
  m_axi_s2mm_bready : OUT STD_LOGIC;
  s_axis_s2mm_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
  s_axis_s2mm_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
  s_axis_s2mm_tlast : IN STD_LOGIC;
  s_axis_s2mm_tvalid : IN STD_LOGIC;
  s_axis_s2mm_tready : OUT STD_LOGIC
);
END COMPONENT;

end package;
