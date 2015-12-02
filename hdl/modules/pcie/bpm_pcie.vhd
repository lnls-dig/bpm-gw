----------------------------------------------------------------------------------
-- Company: Creotech
-- Engineer: Adrian Byszuk (adrian.byszuk@gmail.com)
--
-- Design Name:
-- Module Name:    bpm_pcie - Behavioral
-- Project Name:
-- Target Devices: KC705, AFC, AFCK
-- Tool versions: Vivado 2015.2+
-- Description: This is TOP module for the versatile firmware for PCIe communication.
-- It provides DMA engine with scatter-gather (linked list) functionality.
-- DDR memory is supported through BAR2. Wishbone endpoint is accessible through BAR4.
--
-- Dependencies: Xilinx PCIe core for 7 series. Xilinx DDR core for 7 series.
--              AXI infrastructe IP cores
--
-- Revision: 3.00 - Moved to AXI intfrastructe. More generic HDL code.
-- Revision: 2.00 - Original file completely rewritten by abyszuk.
--
-- Revision 1.00 - File Released
--
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.abb64Package.all;
use work.ipcores_pkg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity bpm_pcie is
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
end entity bpm_pcie;

architecture Behavioral of bpm_pcie is

  signal DDR_Ready : std_logic;
  signal ddr_reset : std_logic;
  signal ddr_axi_reset : std_logic;
				
  signal wbone_clk     : std_logic;
  signal wb_wr_we      : std_logic;
  signal wb_wr_wsof    : std_logic;
  signal wb_wr_weof    : std_logic;
  signal wb_wr_din     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wb_wr_pfull   : std_logic;
  signal wb_wr_full    : std_logic;
  signal wb_rdc_sof    : std_logic;
  signal wb_rdc_v      : std_logic;
  signal wb_rdc_din    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wb_rdc_full   : std_logic;
  signal wb_timeout    : std_logic;
  signal wb_rdd_ren    : std_logic;
  signal wb_rdd_dout   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wb_rdd_pempty : std_logic;
  signal wb_rdd_empty  : std_logic;
  signal wbone_rst     : std_logic;
  signal wb_fifo_rst   : std_logic;
  signal wbone_addr    : std_logic_vector(28 downto 0);
  signal wbone_mdin    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wbone_mdout   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wbone_we      : std_logic;
  signal wbone_sel     : std_logic_vector(0 downto 0);
  signal wbone_stb     : std_logic;
  signal wbone_ack     : std_logic;
  signal wbone_cyc     : std_logic;

  -- TRN Layer signals
  signal tx_err_drop : std_logic;
  signal tx_cfg_gnt  : std_logic;
  signal fc_cpld     : std_logic_vector (12-1 downto 0);
  signal fc_cplh     : std_logic_vector (8-1 downto 0);
  signal fc_npd      : std_logic_vector (12-1 downto 0);
  signal fc_nph      : std_logic_vector (8-1 downto 0);
  signal fc_pd       : std_logic_vector (12-1 downto 0);
  signal fc_ph       : std_logic_vector (8-1 downto 0);
  signal fc_sel      : std_logic_vector (3-1 downto 0);

  signal cfg_dcommand2            : std_logic_vector (16-1 downto 0);
  signal tx_cfg_req               : std_logic;
  signal pl_initial_link_width          : std_logic_vector (3-1 downto 0);
  signal pl_lane_reversal_mode          : std_logic_vector (2-1 downto 0);
  signal pl_link_gen2_cap               : std_logic;
  signal pl_link_partner_gen2_supported : std_logic;
  signal pl_link_upcfg_cap              : std_logic;
  signal pl_ltssm_state                 : std_logic_vector (6-1 downto 0);
  signal pl_received_hot_rst            : std_logic;
  signal pl_sel_lnk_rate                : std_logic;
  signal pl_sel_lnk_width               : std_logic_vector (2-1 downto 0);
  signal pl_directed_link_auton         : std_logic;
  signal pl_directed_link_change        : std_logic_vector (2-1 downto 0);
  signal pl_directed_link_speed         : std_logic;
  signal pl_directed_link_width         : std_logic_vector (2-1 downto 0);
  signal pl_upstream_prefer_deemph      : std_logic;
  ----------------------------------------------------

  signal user_reset_int1  : std_logic;
  signal user_lnk_up_int1 : std_logic;

  signal user_clk                   : std_logic;
  signal user_reset                 : std_logic;
  signal user_lnk_up                : std_logic;
  signal s_axis_tx_tdata            : std_logic_vector(63 downto 0);
  signal s_axis_tx_tkeep            : std_logic_vector(7 downto 0);
  signal s_axis_tx_tlast            : std_logic;
  signal s_axis_tx_tvalid           : std_logic;
  signal s_axis_tx_tready           : std_logic;
  signal s_axis_tx_tuser            : std_logic_vector(3 downto 0);
  signal s_axis_tx_tdsc             : std_logic;
  signal s_axis_tx_terrfwd          : std_logic;
  signal tx_buf_av                  : std_logic_vector(5 downto 0);
  signal m_axis_rx_tdata            : std_logic_vector(63 downto 0);
  signal m_axis_rx_tkeep            : std_logic_vector(7 downto 0);
  signal m_axis_rx_tlast            : std_logic;
  signal m_axis_rx_tvalid           : std_logic;
  signal m_axis_rx_tready           : std_logic;
  signal m_axis_rx_terrfwd          : std_logic;
  signal m_axis_rx_tuser            : std_logic_vector(21 downto 0);
  signal rx_np_ok                   : std_logic;
  signal rx_np_req                  : std_logic;
  signal m_axis_rx_tbar_hit         : std_logic_vector(6 downto 0);
  signal trn_rfc_nph_av             : std_logic_vector(7 downto 0);
  signal trn_rfc_npd_av             : std_logic_vector(11 downto 0);
  signal trn_rfc_ph_av              : std_logic_vector(7 downto 0);
  signal trn_rfc_pd_av              : std_logic_vector(11 downto 0);
  signal trn_rfc_cplh_av            : std_logic_vector(7 downto 0);
  signal trn_rfc_cpld_av            : std_logic_vector(11 downto 0);
  signal cfg_do                     : std_logic_vector(31 downto 0);
  signal cfg_mgmt_rd_wr_done        : std_logic;
  signal cfg_di                     : std_logic_vector(31 downto 0);
  signal cfg_mgmt_byte_en           : std_logic_vector(3 downto 0);
  signal cfg_dwaddr                 : std_logic_vector(9 downto 0);
  signal cfg_mgmt_wr_en             : std_logic;
  signal cfg_mgmt_rd_en             : std_logic;
  signal cfg_err_cor                : std_logic;
  signal cfg_err_ur                 : std_logic;
  signal cfg_err_cpl_rdy            : std_logic;
  signal cfg_err_ecrc               : std_logic;
  signal cfg_err_cpl_timeout        : std_logic;
  signal cfg_err_cpl_abort          : std_logic;
  signal cfg_err_cpl_unexpect       : std_logic;
  signal cfg_err_posted             : std_logic;
  signal cfg_err_locked             : std_logic;
  signal cfg_err_tlp_cpl_header     : std_logic_vector(47 downto 0);
  signal cfg_interrupt              : std_logic;
  signal cfg_interrupt_rdy          : std_logic;
  signal cfg_interrupt_mmenable     : std_logic_vector(2 downto 0);
  signal cfg_interrupt_msienable    : std_logic;
  signal cfg_interrupt_di           : std_logic_vector(7 downto 0);
  signal cfg_interrupt_do           : std_logic_vector(7 downto 0);
  signal cfg_interrupt_assert       : std_logic;
  signal cfg_interrupt_msixenable   : std_logic;
  signal cfg_interrupt_msixfm       : std_logic;
  
  signal cfg_turnoff_ok             : std_logic;
  signal cfg_to_turnoff             : std_logic;
  signal cfg_pm_wake                : std_logic;
  signal cfg_pcie_link_state        : std_logic_vector(2 downto 0);
  signal cfg_trn_pending            : std_logic;
  signal cfg_bus_number             : std_logic_vector(7 downto 0);
  signal cfg_device_number          : std_logic_vector(4 downto 0);
  signal cfg_function_number        : std_logic_vector(2 downto 0);
  signal cfg_dsn                    : std_logic_vector(63 downto 0);
  signal cfg_status                 : std_logic_vector(15 downto 0);
  signal cfg_command                : std_logic_vector(15 downto 0);
  signal cfg_dstatus                : std_logic_vector(15 downto 0);
  signal cfg_dcommand               : std_logic_vector(15 downto 0);
  signal cfg_lstatus                : std_logic_vector(15 downto 0);
  signal cfg_lcommand               : std_logic_vector(15 downto 0);

  signal cfg_mgmt_di                   : std_logic_vector(31 downto 0) := (others => '0');
  signal cfg_mgmt_dwaddr               : std_logic_vector(9 downto 0) := (others => '0');
  signal cfg_mgmt_wr_readonly          : std_logic := '0';
  signal cfg_err_atomic_egress_blocked : std_logic := '0';
  signal cfg_err_internal_cor          : std_logic := '0';
  signal cfg_err_malformed             : std_logic := '0';
  signal cfg_err_mc_blocked            : std_logic := '0';
  signal cfg_err_poisoned              : std_logic := '0';
  signal cfg_err_norecovery            : std_logic := '0';
  signal cfg_err_acs                   : std_logic := '0';
  signal cfg_err_internal_uncor        : std_logic := '0';
  signal cfg_err_aer_headerlog         : std_logic_vector(127 downto 0) := (others => '0');
  signal cfg_aer_interrupt_msgnum      : std_logic_vector(4 downto 0) := (others => '0');
  signal cfg_err_aer_headerlog_set     : std_logic := '0';
  signal cfg_aer_ecrc_check_en         : std_logic := '0';
  signal cfg_aer_ecrc_gen_en           : std_logic := '0';
  signal cfg_pm_halt_aspm_l0s          : std_logic := '0';
  signal cfg_pm_halt_aspm_l1           : std_logic := '1';
  signal cfg_pm_force_state_en         : std_logic := '0';
  signal cfg_pm_force_state            : std_logic_vector(1 downto 0) := "00";
  signal cfg_interrupt_stat            : std_logic := '0';
  signal cfg_pciecap_interrupt_msgnum  : std_logic_vector(4 downto 0) := (others => '0');

  --DDR AXI4 stream command/data
  signal ddr_mm2s_cmd_tvalid : STD_LOGIC;
  signal ddr_mm2s_cmd_tready : STD_LOGIC;
  signal ddr_mm2s_cmd_tdata : STD_LOGIC_VECTOR(71 DOWNTO 0);
  signal ddr_mm2s_sts_tvalid : STD_LOGIC;
  signal ddr_mm2s_sts_tready : STD_LOGIC;
  signal ddr_mm2s_sts_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal ddr_mm2s_sts_tkeep : STD_LOGIC_VECTOR(0 DOWNTO 0);
  signal ddr_mm2s_sts_tlast : STD_LOGIC;
  signal ddr_mm2s_tdata : STD_LOGIC_VECTOR(63 DOWNTO 0);
  signal ddr_mm2s_tkeep : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal ddr_mm2s_tlast : STD_LOGIC;
  signal ddr_mm2s_tvalid : STD_LOGIC;
  signal ddr_mm2s_tready : STD_LOGIC;
  signal ddr_s2mm_cmd_tvalid : STD_LOGIC;
  signal ddr_s2mm_cmd_tready : STD_LOGIC;
  signal ddr_s2mm_cmd_tdata : STD_LOGIC_VECTOR(71 DOWNTO 0);
  signal ddr_s2mm_sts_tvalid : STD_LOGIC;
  signal ddr_s2mm_sts_tready : STD_LOGIC;
  signal ddr_s2mm_sts_tdata : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal ddr_s2mm_sts_tkeep : STD_LOGIC_VECTOR(0 DOWNTO 0);
  signal ddr_s2mm_sts_tlast : STD_LOGIC;
  signal ddr_s2mm_tdata : STD_LOGIC_VECTOR(63 DOWNTO 0);
  signal ddr_s2mm_tkeep : STD_LOGIC_VECTOR(7 DOWNTO 0);
  signal ddr_s2mm_tlast : STD_LOGIC;
  signal ddr_s2mm_tvalid : STD_LOGIC;
  signal ddr_s2mm_tready : STD_LOGIC;
  signal ddr_mm2s_err : std_logic;
  signal ddr_s2mm_err : std_logic;

  signal sys_clk_c     : std_logic;
  signal sys_reset_c   : std_logic;

  signal localId         : std_logic_vector(15 downto 0);
  signal pcie_link_width : std_logic_vector(5 downto 0);

begin

  sys_reset_c <= not pci_sys_rst_n;

  pcieclk_ibuf : IBUFDS_GTE2
    port map (
      O     => sys_clk_c,
      ODIV2 => open,
      I     => pci_sys_clk_p,
      IB    => pci_sys_clk_n,
      CEB   => '0'
      );

  cfg_err_cor            <= '0';
  cfg_err_ur             <= '0';
  cfg_err_ecrc           <= '0';
  cfg_err_cpl_timeout    <= '0';
  cfg_err_cpl_abort      <= '0';
  cfg_err_cpl_unexpect   <= '0';
  cfg_err_posted         <= '0';
  cfg_err_locked         <= '0';
  cfg_err_tlp_cpl_header <= (others => '0');
  cfg_trn_pending        <= '0';
  cfg_pm_wake            <= '0';
--
  fc_sel <= "000";

  pl_directed_link_auton    <= '0';
  pl_directed_link_change   <= (others => '0');
  pl_directed_link_speed    <= '0';
  pl_directed_link_width    <= (others => '0');
  pl_upstream_prefer_deemph <= '0';

  s_axis_tx_tuser    <= s_axis_tx_tdsc & '0' & s_axis_tx_terrfwd & '0';
  m_axis_rx_terrfwd  <= m_axis_rx_tuser(1);
  m_axis_rx_tbar_hit <= m_axis_rx_tuser(8 downto 2);
--
  cfg_di           <= (others => '0');
  cfg_dwaddr       <= (others => '1');
  cfg_mgmt_byte_en <= (others => '0');
  cfg_mgmt_wr_en   <= '0';
  cfg_mgmt_rd_en   <= '0';
  cfg_dsn          <= X"00000001" & X"01" & X"000A35";  -- //this is taken from GUI -

  cfg_turnoff_ok <= '1';

  localId <= cfg_bus_number & cfg_device_number & cfg_function_number;

  pcie_link_width <= cfg_lstatus(9 downto 4);

  user_lnk_up_int_i : FDPE
    generic map (
      INIT => '0'
      )
    port map (
      Q   => user_lnk_up,
      D   => user_lnk_up_int1,
      C   => user_clk,
      CE  => '1',
      PRE => '0'
      );

  user_reset_i : FDPE
    generic map (
      INIT => '1'
      )
    port map (
      Q   => user_reset,
      D   => user_reset_int1,
      C   => user_clk,
      CE  => '1',
      PRE => '0'
      );

-- --------------------------------------------------------------
-- --------------------------------------------------------------
pcie_core_i: pcie_core
port map(
  --------------------------------------------------------------------------------------------------------------------
  -- 1. PCI Express (pci_exp) Interface                                                                             --
  --------------------------------------------------------------------------------------------------------------------
  --TX
  pci_exp_txp => pci_exp_txp,
  pci_exp_txn => pci_exp_txn,
  -- RX
  pci_exp_rxp => pci_exp_rxp,
  pci_exp_rxn => pci_exp_rxn,

  -------------------------------------------------------------------------------------------------------------------
  -- 3. AXI-S Interface                                                                                            --
  -------------------------------------------------------------------------------------------------------------------
  -- Common
  user_clk_out   => user_clk ,
  user_reset_out => user_reset_int1,
  user_lnk_up    => user_lnk_up_int1,

  -- TX
  tx_buf_av        => tx_buf_av ,
  tx_cfg_req       => tx_cfg_req ,
  tx_err_drop      => tx_err_drop ,
  s_axis_tx_tready => s_axis_tx_tready ,
  s_axis_tx_tdata  => s_axis_tx_tdata ,
  s_axis_tx_tkeep  => s_axis_tx_tkeep ,
  s_axis_tx_tlast  => s_axis_tx_tlast ,
  s_axis_tx_tvalid => s_axis_tx_tvalid ,
  s_axis_tx_tuser  => s_axis_tx_tuser,
  tx_cfg_gnt       => tx_cfg_gnt ,

  -- RX
  m_axis_rx_tdata  => m_axis_rx_tdata ,
  m_axis_rx_tkeep  => m_axis_rx_tkeep ,
  m_axis_rx_tlast  => m_axis_rx_tlast ,
  m_axis_rx_tvalid => m_axis_rx_tvalid ,
  m_axis_rx_tready => m_axis_rx_tready ,
  m_axis_rx_tuser  => m_axis_rx_tuser,
  rx_np_ok         => rx_np_ok ,
  rx_np_req        => rx_np_req ,

  -- Flow Control
  fc_cpld => fc_cpld ,
  fc_cplh => fc_cplh ,
  fc_npd  => fc_npd ,
  fc_nph  => fc_nph ,
  fc_pd   => fc_pd ,
  fc_ph   => fc_ph ,
  fc_sel  => fc_sel ,

  -------------------------------------------------------------------------------------------------------------------
  -- 4. Configuration (CFG) Interface                                                                              --
  -------------------------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------
  -- EP and RP                                                      --
  ---------------------------------------------------------------------

  cfg_mgmt_do         => open ,
  cfg_mgmt_rd_wr_done => open ,

  cfg_status          => cfg_status ,
  cfg_command         => cfg_command ,
  cfg_dstatus         => cfg_dstatus ,
  cfg_dcommand        => cfg_dcommand ,
  cfg_lstatus         => cfg_lstatus ,
  cfg_lcommand        => cfg_lcommand ,
  cfg_dcommand2       => cfg_dcommand2 ,
  cfg_pcie_link_state => cfg_pcie_link_state ,

  cfg_pmcsr_pme_en          => open ,
  cfg_pmcsr_pme_status      => open ,
  cfg_pmcsr_powerstate      => open ,
  cfg_received_func_lvl_rst => open ,

  cfg_mgmt_di          => cfg_mgmt_di ,
  cfg_mgmt_byte_en     => cfg_mgmt_byte_en ,
  cfg_mgmt_dwaddr      => cfg_mgmt_dwaddr ,
  cfg_mgmt_wr_en       => cfg_mgmt_wr_en ,
  cfg_mgmt_rd_en       => cfg_mgmt_rd_en ,
  cfg_mgmt_wr_readonly => cfg_mgmt_wr_readonly ,

  cfg_err_ecrc                  => cfg_err_ecrc ,
  cfg_err_ur                    => cfg_err_ur ,
  cfg_err_cpl_timeout           => cfg_err_cpl_timeout ,
  cfg_err_cpl_unexpect          => cfg_err_cpl_unexpect ,
  cfg_err_cpl_abort             => cfg_err_cpl_abort ,
  cfg_err_posted                => cfg_err_posted ,
  cfg_err_cor                   => cfg_err_cor ,
  cfg_err_atomic_egress_blocked => cfg_err_atomic_egress_blocked ,
  cfg_err_internal_cor          => cfg_err_internal_cor ,
  cfg_err_malformed             => cfg_err_malformed ,
  cfg_err_mc_blocked            => cfg_err_mc_blocked ,
  cfg_err_poisoned              => cfg_err_poisoned ,
  cfg_err_norecovery            => cfg_err_norecovery ,
  cfg_err_tlp_cpl_header        => cfg_err_tlp_cpl_header,
  cfg_err_cpl_rdy               => cfg_err_cpl_rdy ,
  cfg_err_locked                => cfg_err_locked ,
  cfg_err_acs                   => cfg_err_acs ,
  cfg_err_internal_uncor        => cfg_err_internal_uncor ,

  cfg_trn_pending       => cfg_trn_pending ,
  cfg_pm_halt_aspm_l0s  => cfg_pm_halt_aspm_l0s ,
  cfg_pm_halt_aspm_l1   => cfg_pm_halt_aspm_l1 ,
  cfg_pm_force_state_en => cfg_pm_force_state_en ,
  cfg_pm_force_state    => cfg_pm_force_state ,

  ---------------------------------------------------------------------
  -- EP Only                                                        --
  ---------------------------------------------------------------------

  cfg_interrupt                => cfg_interrupt ,
  cfg_interrupt_rdy            => cfg_interrupt_rdy ,
  cfg_interrupt_assert         => cfg_interrupt_assert ,
  cfg_interrupt_di             => cfg_interrupt_di ,
  cfg_interrupt_do             => cfg_interrupt_do ,
  cfg_interrupt_mmenable       => cfg_interrupt_mmenable ,
  cfg_interrupt_msienable      => cfg_interrupt_msienable ,
  cfg_interrupt_msixenable     => cfg_interrupt_msixenable ,
  cfg_interrupt_msixfm         => cfg_interrupt_msixfm ,
  cfg_interrupt_stat           => cfg_interrupt_stat ,
  cfg_pciecap_interrupt_msgnum => cfg_pciecap_interrupt_msgnum ,
  cfg_to_turnoff               => cfg_to_turnoff ,
  cfg_turnoff_ok               => cfg_turnoff_ok ,
  cfg_bus_number               => cfg_bus_number ,
  cfg_device_number            => cfg_device_number ,
  cfg_function_number          => cfg_function_number ,
  cfg_pm_wake                  => cfg_pm_wake ,

  ---------------------------------------------------------------------
  -- RP Only                                                        --
  ---------------------------------------------------------------------
  cfg_pm_send_pme_to     => '0' ,
  cfg_ds_bus_number      => x"00" ,
  cfg_ds_device_number   => "00000" ,
  cfg_ds_function_number => "000" ,
  cfg_mgmt_wr_rw1c_as_rw => '0' ,
  cfg_msg_received       => open ,
  cfg_msg_data           => open ,

  cfg_bridge_serr_en                         => open ,
  cfg_slot_control_electromech_il_ctl_pulse  => open ,
  cfg_root_control_syserr_corr_err_en        => open ,
  cfg_root_control_syserr_non_fatal_err_en   => open ,
  cfg_root_control_syserr_fatal_err_en       => open ,
  cfg_root_control_pme_int_en                => open ,
  cfg_aer_rooterr_corr_err_reporting_en      => open ,
  cfg_aer_rooterr_non_fatal_err_reporting_en => open ,
  cfg_aer_rooterr_fatal_err_reporting_en     => open ,
  cfg_aer_rooterr_corr_err_received          => open ,
  cfg_aer_rooterr_non_fatal_err_received     => open ,
  cfg_aer_rooterr_fatal_err_received         => open ,

  cfg_msg_received_err_cor        => open ,
  cfg_msg_received_err_non_fatal  => open ,
  cfg_msg_received_err_fatal      => open ,
  cfg_msg_received_pm_as_nak      => open ,
  cfg_msg_received_pm_pme         => open ,
  cfg_msg_received_pme_to_ack     => open ,
  cfg_msg_received_assert_int_a   => open ,
  cfg_msg_received_assert_int_b   => open ,
  cfg_msg_received_assert_int_c   => open ,
  cfg_msg_received_assert_int_d   => open ,
  cfg_msg_received_deassert_int_a => open ,
  cfg_msg_received_deassert_int_b => open ,
  cfg_msg_received_deassert_int_c => open ,
  cfg_msg_received_deassert_int_d => open ,

  -------------------------------------------------------------------------------------------------------------------
  -- 5. Physical Layer Control and Status (PL) Interface                                                           --
  -------------------------------------------------------------------------------------------------------------------
  pl_directed_link_auton    => pl_directed_link_auton ,
  pl_directed_link_change   => pl_directed_link_change ,
  pl_directed_link_speed    => pl_directed_link_speed ,
  pl_directed_link_width    => pl_directed_link_width ,
  pl_upstream_prefer_deemph => pl_upstream_prefer_deemph ,

  pl_sel_lnk_rate       => pl_sel_lnk_rate ,
  pl_sel_lnk_width      => pl_sel_lnk_width ,
  pl_ltssm_state        => pl_ltssm_state ,
  pl_lane_reversal_mode => pl_lane_reversal_mode ,

  pl_phy_lnk_up  => open ,
  pl_tx_pm_state => open ,
  pl_rx_pm_state => open ,

  cfg_dsn => cfg_dsn ,

  pl_link_upcfg_cap              => pl_link_upcfg_cap ,
  pl_link_gen2_cap               => pl_link_gen2_cap ,
  pl_link_partner_gen2_supported => pl_link_partner_gen2_supported ,
  pl_initial_link_width          => pl_initial_link_width ,

  pl_directed_change_done => open ,

  ---------------------------------------------------------------------
  -- EP Only                                                        --
  ---------------------------------------------------------------------
  pl_received_hot_rst => pl_received_hot_rst ,

  ---------------------------------------------------------------------
  -- RP Only                                                        --
  ---------------------------------------------------------------------
  pl_transmit_hot_rst         => '0' ,
  pl_downstream_deemph_source => '0' ,

  -------------------------------------------------------------------------------------------------------------------
  -- 6. AER interface                                                                                              --
  -------------------------------------------------------------------------------------------------------------------
  cfg_err_aer_headerlog     => cfg_err_aer_headerlog ,
  cfg_aer_interrupt_msgnum  => cfg_aer_interrupt_msgnum ,
  cfg_err_aer_headerlog_set => cfg_err_aer_headerlog_set ,
  cfg_aer_ecrc_check_en     => cfg_aer_ecrc_check_en ,
  cfg_aer_ecrc_gen_en       => cfg_aer_ecrc_gen_en ,

  -------------------------------------------------------------------------------------------------------------------
  -- 7. VC interface                                                                                               --
  -------------------------------------------------------------------------------------------------------------------
  cfg_vc_tcvc_map => open ,


  -------------------------------------------------------------------------------------------------------------------
  -- 8. System(SYS) Interface                                                                                      --
  -------------------------------------------------------------------------------------------------------------------
  sys_clk         => sys_clk_c ,
  sys_rst_n       => pci_sys_rst_n
);

-- ---------------------------------------------------------------
-- tlp control module
-- ---------------------------------------------------------------

theTlpControl: entity work.tlpControl
  port map (
  -- Wishbone FIFO interface
  wb_FIFO_we   => wb_wr_we ,         --  OUT std_logic;
  wb_FIFO_wsof => wb_wr_wsof ,       --  OUT std_logic;
  wb_FIFO_weof => wb_wr_weof ,       --  OUT std_logic;
  wb_FIFO_din  => wb_wr_din(C_DBUS_WIDTH-1 downto 0) ,  --  OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  wb_fifo_full => wb_wr_full,

  wb_FIFO_re    => wb_rdd_ren ,   --  OUT std_logic;
  wb_FIFO_empty => wb_rdd_empty ,       --  IN  std_logic;
  wb_FIFO_qout  => wb_rdd_dout(C_DBUS_WIDTH-1 downto 0) ,  --  IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  wb_rdc_sof  => wb_rdc_sof, --out std_logic;
  wb_rdc_v    => wb_rdc_v, --out std_logic;
  wb_rdc_din  => wb_rdc_din, --out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  wb_rdc_full => wb_rdc_full, --in std_logic;
  wb_timeout  => wb_timeout,

  wb_FIFO_Rst => wb_fifo_rst,     --  OUT std_logic;

  -------------------
  -- DDR Interface
  DDR_Ready => DDR_Ready,
  ddr_reset => ddr_reset,
  ddr_axi_reset => ddr_axi_reset,
  --DDR AXI <-> PCIe interface
  ddr_mm2s_cmd_tvalid => ddr_mm2s_cmd_tvalid,
  ddr_mm2s_cmd_tready => ddr_mm2s_cmd_tready,
  ddr_mm2s_cmd_tdata => ddr_mm2s_cmd_tdata,
  ddr_mm2s_sts_tvalid => ddr_mm2s_sts_tvalid,
  ddr_mm2s_sts_tready => ddr_mm2s_sts_tready,
  ddr_mm2s_sts_tdata => ddr_mm2s_sts_tdata,
  ddr_mm2s_sts_tkeep => ddr_mm2s_sts_tkeep,
  ddr_mm2s_sts_tlast => ddr_mm2s_sts_tlast,
  ddr_mm2s_tdata => ddr_mm2s_tdata,
  ddr_mm2s_tkeep => ddr_mm2s_tkeep,
  ddr_mm2s_tlast => ddr_mm2s_tlast,
  ddr_mm2s_tvalid => ddr_mm2s_tvalid,
  ddr_mm2s_tready => ddr_mm2s_tready,
  ddr_s2mm_cmd_tvalid => ddr_s2mm_cmd_tvalid,
  ddr_s2mm_cmd_tready => ddr_s2mm_cmd_tready,
  ddr_s2mm_cmd_tdata => ddr_s2mm_cmd_tdata,
  ddr_s2mm_sts_tvalid => ddr_s2mm_sts_tvalid,
  ddr_s2mm_sts_tready => ddr_s2mm_sts_tready,
  ddr_s2mm_sts_tdata => ddr_s2mm_sts_tdata,
  ddr_s2mm_sts_tkeep => ddr_s2mm_sts_tkeep,
  ddr_s2mm_sts_tlast => ddr_s2mm_sts_tlast,
  ddr_s2mm_tdata => ddr_s2mm_tdata,
  ddr_s2mm_tkeep => ddr_s2mm_tkeep,
  ddr_s2mm_tlast => ddr_s2mm_tlast,
  ddr_s2mm_tvalid => ddr_s2mm_tvalid,
  ddr_s2mm_tready => ddr_s2mm_tready,
  ddr_mm2s_err => ddr_mm2s_err,
  ddr_s2mm_err => ddr_s2mm_err,
  -------------------
  -- Transaction Interface
  user_lnk_up       => user_lnk_up ,
  rx_np_ok          => rx_np_ok ,
  rx_np_req         => rx_np_req ,
  s_axis_tx_tdsc    => s_axis_tx_tdsc ,
  tx_buf_av         => tx_buf_av ,
  s_axis_tx_terrfwd => s_axis_tx_terrfwd ,
  tx_cfg_gnt        => tx_cfg_gnt,

  user_clk          => user_clk ,
  user_reset        => user_reset ,
  m_axis_rx_tvalid  => m_axis_rx_tvalid ,
  s_axis_tx_tready  => s_axis_tx_tready ,
  m_axis_rx_tlast   => m_axis_rx_tlast ,
  m_axis_rx_terrfwd => m_axis_rx_terrfwd ,
  m_axis_rx_tkeep   => m_axis_rx_tkeep ,
  m_axis_rx_tdata   => m_axis_rx_tdata ,

  cfg_interrupt            => cfg_interrupt ,
  cfg_interrupt_rdy        => cfg_interrupt_rdy ,
  cfg_interrupt_mmenable   => cfg_interrupt_mmenable ,
  cfg_interrupt_msienable  => cfg_interrupt_msienable ,
  cfg_interrupt_msixenable => cfg_interrupt_msixenable ,
  cfg_interrupt_msixfm     => cfg_interrupt_msixfm ,
  cfg_interrupt_di         => cfg_interrupt_di ,
  cfg_interrupt_do         => cfg_interrupt_do ,
  cfg_interrupt_assert     => cfg_interrupt_assert ,

  m_axis_rx_tbar_hit => m_axis_rx_tbar_hit ,
  s_axis_tx_tvalid   => s_axis_tx_tvalid ,
  m_axis_rx_tready   => m_axis_rx_tready ,
  s_axis_tx_tlast    => s_axis_tx_tlast ,
  s_axis_tx_tkeep    => s_axis_tx_tkeep ,
  s_axis_tx_tdata    => s_axis_tx_tdata ,

  cfg_dcommand    => cfg_dcommand ,
  pcie_link_width => pcie_link_width ,
  localId         => localId
);

-- -----------------------------------------------------------------------
--  DDR SDRAM: control module
-- -----------------------------------------------------------------------
DDRs_ctrl_module: entity work.DDR_Transact
  generic map(
    g_use_bram_stub => false
  )
  port map(
    -- Common interface
    DDR_Ready => DDR_Ready,
    ddr_reset => ddr_reset,
    axi_reset => ddr_axi_reset,
    -- AXI <-> PCIe interface
    axis_mm2s_cmd_tvalid => ddr_mm2s_cmd_tvalid,
    axis_mm2s_cmd_tready => ddr_mm2s_cmd_tready,
    axis_mm2s_cmd_tdata => ddr_mm2s_cmd_tdata,
    axis_mm2s_sts_tvalid => ddr_mm2s_sts_tvalid,
    axis_mm2s_sts_tready => ddr_mm2s_sts_tready,
    axis_mm2s_sts_tdata => ddr_mm2s_sts_tdata,
    axis_mm2s_sts_tkeep => ddr_mm2s_sts_tkeep,
    axis_mm2s_sts_tlast => ddr_mm2s_sts_tlast,
    axis_mm2s_tdata => ddr_mm2s_tdata,
    axis_mm2s_tkeep => ddr_mm2s_tkeep,
    axis_mm2s_tlast => ddr_mm2s_tlast,
    axis_mm2s_tvalid => ddr_mm2s_tvalid,
    axis_mm2s_tready => ddr_mm2s_tready,
    axis_s2mm_cmd_tvalid => ddr_s2mm_cmd_tvalid,
    axis_s2mm_cmd_tready => ddr_s2mm_cmd_tready,
    axis_s2mm_cmd_tdata => ddr_s2mm_cmd_tdata,
    axis_s2mm_sts_tvalid => ddr_s2mm_sts_tvalid,
    axis_s2mm_sts_tready => ddr_s2mm_sts_tready,
    axis_s2mm_sts_tdata => ddr_s2mm_sts_tdata,
    axis_s2mm_sts_tkeep => ddr_s2mm_sts_tkeep,
    axis_s2mm_sts_tlast => ddr_s2mm_sts_tlast,
    axis_s2mm_tdata => ddr_s2mm_tdata,
    axis_s2mm_tkeep => ddr_s2mm_tkeep,
    axis_s2mm_tlast => ddr_s2mm_tlast,
    axis_s2mm_tvalid => ddr_s2mm_tvalid,
    axis_s2mm_tready => ddr_s2mm_tready,
    mm2s_err => ddr_mm2s_err,
    s2mm_err => ddr_s2mm_err,
    -- Slave interface clock
    s_axi_aclk_out => ddr_axi_aclk_o,
    s_axi_aresetn_out => ddr_axi_aresetn_o,
    -- Slave Interface Write Address Ports
    s_axi_awid => ddr_axi_awid,
    s_axi_awaddr => ddr_axi_awaddr,
    s_axi_awlen => ddr_axi_awlen,
    s_axi_awsize => ddr_axi_awsize,
    s_axi_awburst => ddr_axi_awburst,
    s_axi_awlock => ddr_axi_awlock,
    s_axi_awcache => ddr_axi_awcache,
    s_axi_awprot => ddr_axi_awprot,
    s_axi_awqos => ddr_axi_awqos,
    s_axi_awvalid => ddr_axi_awvalid,
    s_axi_awready => ddr_axi_awready,
    -- Slave Interface Write Data Ports
    s_axi_wdata => ddr_axi_wdata,
    s_axi_wstrb => ddr_axi_wstrb,
    s_axi_wlast => ddr_axi_wlast,
    s_axi_wvalid => ddr_axi_wvalid,
    s_axi_wready => ddr_axi_wready,
    -- Slave Interface Write Response Ports
    s_axi_bid => ddr_axi_bid,
    s_axi_bresp => ddr_axi_bresp,
    s_axi_bvalid => ddr_axi_bvalid,
    s_axi_bready => ddr_axi_bready,
    -- Slave Interface Read Address Ports
    s_axi_arid => ddr_axi_arid,
    s_axi_araddr => ddr_axi_araddr,
    s_axi_arlen => ddr_axi_arlen,
    s_axi_arsize => ddr_axi_arsize,
    s_axi_arburst => ddr_axi_arburst,
    s_axi_arlock => ddr_axi_arlock,
    s_axi_arcache => ddr_axi_arcache,
    s_axi_arprot => ddr_axi_arprot,
    s_axi_arqos => ddr_axi_arqos,
    s_axi_arvalid => ddr_axi_arvalid,
    s_axi_arready => ddr_axi_arready,
    -- Slave Interface Read Data Ports
    s_axi_rid => ddr_axi_rid,
    s_axi_rdata => ddr_axi_rdata,
    s_axi_rresp => ddr_axi_rresp,
    s_axi_rlast => ddr_axi_rlast,
    s_axi_rvalid => ddr_axi_rvalid,
    s_axi_rready => ddr_axi_rready,
    -- DDR core memory signals
    ddr3_addr     => ddr3_addr,
    ddr3_ba       => ddr3_ba,
    ddr3_cas_n    => ddr3_cas_n,
    ddr3_ck_n     => ddr3_ck_n,
    ddr3_ck_p     => ddr3_ck_p,
    ddr3_cke      => ddr3_cke,
    ddr3_ras_n    => ddr3_ras_n,
    ddr3_reset_n  => ddr3_reset_n,
    ddr3_we_n     => ddr3_we_n,
    ddr3_dq       => ddr3_dq,
    ddr3_dqs_n    => ddr3_dqs_n,
    ddr3_dqs_p    => ddr3_dqs_p,
    ddr3_cs_n     => ddr3_cs_n,
    ddr3_dm       => ddr3_dm,
    ddr3_odt      => ddr3_odt,
    ddr_sys_clk   => ddr_sys_clk,
    --clocking & reset
    pcie_clk   => user_clk,
    sys_reset => ddr_sys_rst
  );
  
Wishbone_intf: entity work.wb_transact
  port map(
    -- PCIE user clk
    user_clk => user_clk, --in std_logic;
    -- Write port
    wr_we   => wb_wr_we, --in std_logic;
    wr_sof  => wb_wr_wsof, --in std_logic;
    wr_eof  => wb_wr_weof, --in std_logic;
    wr_din  => wb_wr_din, --in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wr_full => wb_wr_full, --out std_logic;
    -- Read command port
    rdc_sof  => wb_rdc_sof, --in std_logic;
    rdc_v    => wb_rdc_v, --in std_logic;
    rdc_din  => wb_rdc_din, --in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    rdc_full => wb_rdc_full,--out std_logic;
    rd_tout  => wb_timeout,
    -- Read data port
    rd_ren   => wb_rdd_ren, --in std_logic;
    rd_empty => wb_rdd_empty, --out std_logic;
    rd_dout  => wb_rdd_dout, --out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- Wishbone interface
    wb_clk => wbone_clk, --in std_logic;
    wb_rst => wbone_rst, --in std_logic;
    addr_o => wbone_addr(28 downto 0), --out std_logic_vector(31 downto 0);
    dat_i  => wbone_mdin, --in std_logic_vector(63 downto 0);
    dat_o  => wbone_mdout, --out std_logic_vector(63 downto 0);
    we_o   => wbone_we, --out std_logic;
    sel_o  => wbone_sel, --out std_logic_vector(0 downto 0);
    stb_o  => wbone_stb, --out std_logic;
    ack_i  => wbone_ack, --in std_logic;
    cyc_o  => wbone_cyc, --out std_logic;
    --RESET from PCIe
    rst => user_reset --in std_logic
  );

  wbone_clk  <= CLK_I;
  wbone_rst  <= RST_I;
  wbone_mdin <= DAT_I;
  wbone_ack  <= ACK_I;
  ADDR_O     <= wbone_addr;
  DAT_O      <= wbone_mdout;
  WE_O       <= wbone_we;
  SEL_O      <= wbone_sel(0);
  STB_O      <= wbone_stb;
  CYC_O      <= wbone_cyc;
  ext_rst_o  <= wb_fifo_rst;


end Behavioral;
