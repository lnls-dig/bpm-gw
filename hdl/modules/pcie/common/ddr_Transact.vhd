----------------------------------------------------------------------------------
-- Company:  Creotech
-- Engineer:  abyszuk
--
-- Create Date:    19:47:45 18/01/2013
-- Design Name:
-- Module Name:    ddr_Transact - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.abb64Package.all;
use work.ipcores_pkg.all;


entity DDR_Transact is
  generic(
    G_USE_BRAM_STUB : boolean := true
  );
  port (
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
    ddr_sys_clk  : in std_logic;
    --AXI4 stream command/data
    axis_mm2s_cmd_tvalid : IN STD_LOGIC;
    axis_mm2s_cmd_tready : OUT STD_LOGIC;
    axis_mm2s_cmd_tdata : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
    axis_mm2s_sts_tvalid : OUT STD_LOGIC;
    axis_mm2s_sts_tready : IN STD_LOGIC;
    axis_mm2s_sts_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    axis_mm2s_sts_tkeep : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    axis_mm2s_sts_tlast : OUT STD_LOGIC;
    axis_mm2s_tdata : OUT STD_LOGIC_VECTOR(63 DOWNTO 0);
    axis_mm2s_tkeep : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    axis_mm2s_tlast : OUT STD_LOGIC;
    axis_mm2s_tvalid : OUT STD_LOGIC;
    axis_mm2s_tready : IN STD_LOGIC;
    axis_s2mm_cmd_tvalid : IN STD_LOGIC;
    axis_s2mm_cmd_tready : OUT STD_LOGIC;
    axis_s2mm_cmd_tdata : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
    axis_s2mm_sts_tvalid : OUT STD_LOGIC;
    axis_s2mm_sts_tready : IN STD_LOGIC;
    axis_s2mm_sts_tdata : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    axis_s2mm_sts_tkeep : OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
    axis_s2mm_sts_tlast : OUT STD_LOGIC;
    axis_s2mm_tdata : IN STD_LOGIC_VECTOR(63 DOWNTO 0);
    axis_s2mm_tkeep : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    axis_s2mm_tlast : IN STD_LOGIC;
    axis_s2mm_tvalid : IN STD_LOGIC;
    axis_s2mm_tready : OUT STD_LOGIC;
    mm2s_err : out std_logic;
    s2mm_err : out std_logic;
    --AXI4 interface
    s_axi_aclk_out : out std_logic;
    s_axi_aresetn_out : out std_logic;
    s_axi_awid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awaddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_awlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_awsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_awlock : in STD_LOGIC;
    s_axi_awcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_awqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_awvalid : in STD_LOGIC;
    s_axi_awready : out STD_LOGIC;
    s_axi_wdata : in STD_LOGIC_VECTOR ( c_ddr_payload_width-1 downto 0 );
    s_axi_wstrb : in STD_LOGIC_VECTOR ( c_ddr_payload_width/8-1 downto 0 );
    s_axi_wlast : in STD_LOGIC;
    s_axi_wvalid : in STD_LOGIC;
    s_axi_wready : out STD_LOGIC;
    s_axi_bready : in STD_LOGIC;
    s_axi_bid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_bresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_bvalid : out STD_LOGIC;
    s_axi_arid : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_araddr : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axi_arlen : in STD_LOGIC_VECTOR ( 7 downto 0 );
    s_axi_arsize : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arburst : in STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_arlock : in STD_LOGIC;
    s_axi_arcache : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arprot : in STD_LOGIC_VECTOR ( 2 downto 0 );
    s_axi_arqos : in STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_arvalid : in STD_LOGIC;
    s_axi_arready : out STD_LOGIC;
    s_axi_rready : in STD_LOGIC;
    s_axi_rid : out STD_LOGIC_VECTOR ( 3 downto 0 );
    s_axi_rdata : out STD_LOGIC_VECTOR ( c_ddr_payload_width-1 downto 0 );
    s_axi_rresp : out STD_LOGIC_VECTOR ( 1 downto 0 );
    s_axi_rlast : out STD_LOGIC;
    s_axi_rvalid : out STD_LOGIC;
    -- ctrl&status
    ddr_ready : out std_logic;
    ddr_reset : in std_logic;
    axi_reset : in std_logic;

    --clocking & reset
    pcie_clk : in std_logic;
    sys_reset : in std_logic
  );
end entity DDR_Transact;

architecture Behavioral of DDR_Transact is
-- ----------------------------------------------------------------------------
-- Signal & type declarations
-- ----------------------------------------------------------------------------
signal ddr_ui_clk, ddr_mmcm_locked : std_logic;
signal ddr_ui_rst, irconnect_arstn, ddr_axi_aresetn, pcie_axi_aresetn : std_logic;
signal ddr_axi_awid, ddr_axi_arid, ddr_axi_bid, ddr_axi_rid : std_logic_vector(7 downto 0);
signal pcie_axi_awaddr, ddr_axi_awaddr : std_logic_vector(31 downto 0);
signal pcie_axi_awlen, ddr_axi_awlen : std_logic_vector(7 downto 0);
signal pcie_axi_awsize, ddr_axi_awsize : std_logic_vector(2 downto 0);
signal pcie_axi_awburst, ddr_axi_awburst : std_logic_vector(1 downto 0);
signal pcie_axi_awlock, ddr_axi_awlock : std_logic := '0';
signal pcie_axi_awcache, ddr_axi_awcache : std_logic_vector(3 downto 0);
signal pcie_axi_awprot, ddr_axi_awprot : std_logic_vector(2 downto 0);
signal pcie_axi_awqos, ddr_axi_awqos : std_logic_vector(3 downto 0) := "0000";
signal pcie_axi_awvalid, pcie_axi_awready, ddr_axi_awvalid, ddr_axi_awready : std_logic;
signal pcie_axi_wdata, ddr_axi_wdata : std_logic_vector(c_ddr_payload_width-1 downto 0);
signal pcie_axi_wstrb, ddr_axi_wstrb : std_logic_vector(c_ddr_payload_width/8-1 downto 0);
signal pcie_axi_wvalid, pcie_axi_wready, ddr_axi_wvalid, ddr_axi_wready : std_logic;
signal pcie_axi_wlast, ddr_axi_wlast : std_logic;
signal pcie_axi_bresp, ddr_axi_bresp : std_logic_vector(1 downto 0);
signal pcie_axi_bvalid, pcie_axi_bready, ddr_axi_bvalid, ddr_axi_bready : std_logic;
signal pcie_axi_araddr, ddr_axi_araddr : std_logic_vector(31 downto 0);
signal pcie_axi_arlen, ddr_axi_arlen : std_logic_vector(7 downto 0);
signal pcie_axi_arsize, ddr_axi_arsize : std_logic_vector(2 downto 0);
signal pcie_axi_arburst, ddr_axi_arburst : std_logic_vector(1 downto 0);
signal pcie_axi_arlock, ddr_axi_arlock : std_logic := '0';
signal pcie_axi_arcache, ddr_axi_arcache : std_logic_vector(3 downto 0);
signal pcie_axi_arprot, ddr_axi_arprot : std_logic_vector(2 downto 0);
signal pcie_axi_arqos, ddr_axi_arqos : std_logic_vector(3 downto 0) := "0000";
signal pcie_axi_arvalid, pcie_axi_arready, ddr_axi_arvalid, ddr_axi_arready : std_logic;
signal pcie_axi_rdata, ddr_axi_rdata : std_logic_vector(c_ddr_payload_width-1 downto 0);
signal pcie_axi_rresp, ddr_axi_rresp : std_logic_vector(1 downto 0);
signal pcie_axi_rvalid, pcie_axi_rready, ddr_axi_rvalid, ddr_axi_rready : std_logic;
signal pcie_axi_rlast, ddr_axi_rlast : std_logic;

begin

axi_interconnect_i : axi_interconnect
PORT MAP (
  INTERCONNECT_ACLK => ddr_ui_clk,
  INTERCONNECT_ARESETN => irconnect_arstn,
  S00_AXI_ARESET_OUT_N => pcie_axi_aresetn,
  S00_AXI_ACLK => pcie_clk,
  S00_AXI_AWID => "0000",
  S00_AXI_AWADDR => pcie_axi_awaddr,
  S00_AXI_AWLEN => pcie_axi_awlen,
  S00_AXI_AWSIZE => pcie_axi_awsize,
  S00_AXI_AWBURST => pcie_axi_awburst,
  S00_AXI_AWLOCK => pcie_axi_awlock,
  S00_AXI_AWCACHE => pcie_axi_awcache,
  S00_AXI_AWPROT => pcie_axi_awprot,
  S00_AXI_AWQOS => pcie_axi_awqos,
  S00_AXI_AWVALID => pcie_axi_awvalid,
  S00_AXI_AWREADY => pcie_axi_awready,
  S00_AXI_WDATA => pcie_axi_wdata,
  S00_AXI_WSTRB => pcie_axi_wstrb,
  S00_AXI_WLAST => pcie_axi_wlast,
  S00_AXI_WVALID => pcie_axi_wvalid,
  S00_AXI_WREADY => pcie_axi_wready,
  S00_AXI_BID => open,
  S00_AXI_BRESP => pcie_axi_bresp,
  S00_AXI_BVALID => pcie_axi_bvalid,
  S00_AXI_BREADY => pcie_axi_bready,
  S00_AXI_ARID => "0000",
  S00_AXI_ARADDR => pcie_axi_araddr,
  S00_AXI_ARLEN => pcie_axi_arlen,
  S00_AXI_ARSIZE => pcie_axi_arsize,
  S00_AXI_ARBURST => pcie_axi_arburst,
  S00_AXI_ARLOCK => pcie_axi_arlock,
  S00_AXI_ARCACHE => pcie_axi_arcache,
  S00_AXI_ARPROT => pcie_axi_arprot,
  S00_AXI_ARQOS => pcie_axi_arqos,
  S00_AXI_ARVALID => pcie_axi_arvalid,
  S00_AXI_ARREADY => pcie_axi_arready,
  S00_AXI_RID => open,
  S00_AXI_RDATA => pcie_axi_rdata,
  S00_AXI_RRESP => pcie_axi_rresp,
  S00_AXI_RLAST => pcie_axi_rlast,
  S00_AXI_RVALID => pcie_axi_rvalid,
  S00_AXI_RREADY => pcie_axi_rready,
  S01_AXI_ARESET_OUT_N => s_axi_aresetn_out,
  S01_AXI_ACLK => ddr_ui_clk,
  S01_AXI_AWID => s_axi_awid,
  S01_AXI_AWADDR => s_axi_awaddr,
  S01_AXI_AWLEN => s_axi_awlen,
  S01_AXI_AWSIZE => s_axi_awsize,
  S01_AXI_AWBURST => s_axi_awburst,
  S01_AXI_AWLOCK => s_axi_awlock,
  S01_AXI_AWCACHE => s_axi_awcache,
  S01_AXI_AWPROT => s_axi_awprot,
  S01_AXI_AWQOS => s_axi_awqos,
  S01_AXI_AWVALID => s_axi_awvalid,
  S01_AXI_AWREADY => s_axi_awready,
  S01_AXI_WDATA => s_axi_wdata,
  S01_AXI_WSTRB => s_axi_wstrb,
  S01_AXI_WLAST => s_axi_wlast,
  S01_AXI_WVALID => s_axi_wvalid,
  S01_AXI_WREADY => s_axi_wready,
  S01_AXI_BID => s_axi_bid,
  S01_AXI_BRESP => s_axi_bresp,
  S01_AXI_BVALID => s_axi_bvalid,
  S01_AXI_BREADY => s_axi_bready,
  S01_AXI_ARID => s_axi_arid,
  S01_AXI_ARADDR => s_axi_araddr,
  S01_AXI_ARLEN => s_axi_arlen,
  S01_AXI_ARSIZE => s_axi_arsize,
  S01_AXI_ARBURST => s_axi_arburst,
  S01_AXI_ARLOCK => s_axi_arlock,
  S01_AXI_ARCACHE => s_axi_arcache,
  S01_AXI_ARPROT => s_axi_arprot,
  S01_AXI_ARQOS => s_axi_arqos,
  S01_AXI_ARVALID => s_axi_arvalid,
  S01_AXI_ARREADY => s_axi_arready,
  S01_AXI_RID => s_axi_rid,
  S01_AXI_RDATA => s_axi_rdata,
  S01_AXI_RRESP => s_axi_rresp,
  S01_AXI_RLAST => s_axi_rlast,
  S01_AXI_RVALID => s_axi_rvalid,
  S01_AXI_RREADY => s_axi_rready,
  M00_AXI_ARESET_OUT_N => ddr_axi_aresetn,
  M00_AXI_ACLK => ddr_ui_clk,
  M00_AXI_AWID => ddr_axi_awid,
  M00_AXI_AWADDR => ddr_axi_awaddr,
  M00_AXI_AWLEN => ddr_axi_awlen,
  M00_AXI_AWSIZE => ddr_axi_awsize,
  M00_AXI_AWBURST => ddr_axi_awburst,
  M00_AXI_AWLOCK => ddr_axi_awlock,
  M00_AXI_AWCACHE => ddr_axi_awcache,
  M00_AXI_AWPROT => ddr_axi_awprot,
  M00_AXI_AWQOS => ddr_axi_awqos,
  M00_AXI_AWVALID => ddr_axi_awvalid,
  M00_AXI_AWREADY => ddr_axi_awready,
  M00_AXI_WDATA => ddr_axi_wdata,
  M00_AXI_WSTRB => ddr_axi_wstrb,
  M00_AXI_WLAST => ddr_axi_wlast,
  M00_AXI_WVALID => ddr_axi_wvalid,
  M00_AXI_WREADY => ddr_axi_wready,
  M00_AXI_BID => ddr_axi_bid,
  M00_AXI_BRESP => ddr_axi_bresp,
  M00_AXI_BVALID => ddr_axi_bvalid,
  M00_AXI_BREADY => ddr_axi_bready,
  M00_AXI_ARID => ddr_axi_arid,
  M00_AXI_ARADDR => ddr_axi_araddr,
  M00_AXI_ARLEN => ddr_axi_arlen,
  M00_AXI_ARSIZE => ddr_axi_arsize,
  M00_AXI_ARBURST => ddr_axi_arburst,
  M00_AXI_ARLOCK => ddr_axi_arlock,
  M00_AXI_ARCACHE => ddr_axi_arcache,
  M00_AXI_ARPROT => ddr_axi_arprot,
  M00_AXI_ARQOS => ddr_axi_arqos,
  M00_AXI_ARVALID => ddr_axi_arvalid,
  M00_AXI_ARREADY => ddr_axi_arready,
  M00_AXI_RID => ddr_axi_rid,
  M00_AXI_RDATA => ddr_axi_rdata,
  M00_AXI_RRESP => ddr_axi_rresp,
  M00_AXI_RLAST => ddr_axi_rlast,
  M00_AXI_RVALID => ddr_axi_rvalid,
  M00_AXI_RREADY => ddr_axi_rready
);

axi_s2mm_bridge : axi_datamover_0
PORT MAP (
  m_axi_mm2s_aclk => pcie_clk,
  m_axi_mm2s_aresetn => pcie_axi_aresetn,
  mm2s_err => mm2s_err,
  m_axis_mm2s_cmdsts_aclk => pcie_clk,
  m_axis_mm2s_cmdsts_aresetn => pcie_axi_aresetn,
  s_axis_mm2s_cmd_tvalid => axis_mm2s_cmd_tvalid,
  s_axis_mm2s_cmd_tready => axis_mm2s_cmd_tready,
  s_axis_mm2s_cmd_tdata => axis_mm2s_cmd_tdata,
  m_axis_mm2s_sts_tvalid => axis_mm2s_sts_tvalid,
  m_axis_mm2s_sts_tready => axis_mm2s_sts_tready,
  m_axis_mm2s_sts_tdata => axis_mm2s_sts_tdata,
  m_axis_mm2s_sts_tkeep => axis_mm2s_sts_tkeep,
  m_axis_mm2s_sts_tlast => axis_mm2s_sts_tlast,
  m_axi_mm2s_araddr => pcie_axi_araddr,
  m_axi_mm2s_arlen => pcie_axi_arlen,
  m_axi_mm2s_arsize => pcie_axi_arsize,
  m_axi_mm2s_arburst => pcie_axi_arburst,
  m_axi_mm2s_arprot => pcie_axi_arprot,
  m_axi_mm2s_arcache => pcie_axi_arcache,
  m_axi_mm2s_aruser => open,
  m_axi_mm2s_arvalid => pcie_axi_arvalid,
  m_axi_mm2s_arready => pcie_axi_arready,
  m_axi_mm2s_rdata => pcie_axi_rdata,
  m_axi_mm2s_rresp => pcie_axi_rresp,
  m_axi_mm2s_rlast => pcie_axi_rlast,
  m_axi_mm2s_rvalid => pcie_axi_rvalid,
  m_axi_mm2s_rready => pcie_axi_rready,
  m_axis_mm2s_tdata => axis_mm2s_tdata,
  m_axis_mm2s_tkeep => axis_mm2s_tkeep,
  m_axis_mm2s_tlast => axis_mm2s_tlast,
  m_axis_mm2s_tvalid => axis_mm2s_tvalid,
  m_axis_mm2s_tready => axis_mm2s_tready,
  m_axi_s2mm_aclk => pcie_clk,
  m_axi_s2mm_aresetn => pcie_axi_aresetn,
  s2mm_err => s2mm_err,
  m_axis_s2mm_cmdsts_awclk => pcie_clk,
  m_axis_s2mm_cmdsts_aresetn => pcie_axi_aresetn,
  s_axis_s2mm_cmd_tvalid => axis_s2mm_cmd_tvalid,
  s_axis_s2mm_cmd_tready => axis_s2mm_cmd_tready,
  s_axis_s2mm_cmd_tdata => axis_s2mm_cmd_tdata,
  m_axis_s2mm_sts_tvalid => axis_s2mm_sts_tvalid,
  m_axis_s2mm_sts_tready => axis_s2mm_sts_tready,
  m_axis_s2mm_sts_tdata => axis_s2mm_sts_tdata,
  m_axis_s2mm_sts_tkeep => axis_s2mm_sts_tkeep,
  m_axis_s2mm_sts_tlast => axis_s2mm_sts_tlast,
  m_axi_s2mm_awaddr => pcie_axi_awaddr,
  m_axi_s2mm_awlen => pcie_axi_awlen,
  m_axi_s2mm_awsize => pcie_axi_awsize,
  m_axi_s2mm_awburst => pcie_axi_awburst,
  m_axi_s2mm_awprot => pcie_axi_awprot,
  m_axi_s2mm_awcache => pcie_axi_awcache,
  m_axi_s2mm_awuser => open,
  m_axi_s2mm_awvalid => pcie_axi_awvalid,
  m_axi_s2mm_awready => pcie_axi_awready,
  m_axi_s2mm_wdata => pcie_axi_wdata,
  m_axi_s2mm_wstrb => pcie_axi_wstrb,
  m_axi_s2mm_wlast => pcie_axi_wlast,
  m_axi_s2mm_wvalid => pcie_axi_wvalid,
  m_axi_s2mm_wready => pcie_axi_wready,
  m_axi_s2mm_bresp => pcie_axi_bresp,
  m_axi_s2mm_bvalid => pcie_axi_bvalid,
  m_axi_s2mm_bready => pcie_axi_bready,
  s_axis_s2mm_tdata => axis_s2mm_tdata,
  s_axis_s2mm_tkeep => axis_s2mm_tkeep,
  s_axis_s2mm_tlast => axis_s2mm_tlast,
  s_axis_s2mm_tvalid => axis_s2mm_tvalid,
  s_axis_s2mm_tready => axis_s2mm_tready
);

real_ddr:
if g_use_bram_stub = false generate
  signal ddr_sys_rst : std_logic;
  signal init_calib_complete : std_logic;
begin

  ddr_core_inst: ddr_core
  port map(
    -- Memory interface ports
    ddr3_addr => ddr3_addr,
    ddr3_ba => ddr3_ba,
    ddr3_cas_n => ddr3_cas_n,
    ddr3_ck_n => ddr3_ck_n,
    ddr3_ck_p => ddr3_ck_p,
    ddr3_cke => ddr3_cke,
    ddr3_ras_n => ddr3_ras_n,
    ddr3_reset_n => ddr3_reset_n,
    ddr3_we_n => ddr3_we_n,
    ddr3_dq => ddr3_dq,
    ddr3_dqs_n => ddr3_dqs_n,
    ddr3_dqs_p => ddr3_dqs_p,
    init_calib_complete => init_calib_complete,
    ddr3_cs_n => ddr3_cs_n,
    ddr3_dm => ddr3_dm,
    ddr3_odt => ddr3_odt,
    -- Application interface ports
    ui_clk => ddr_ui_clk,
    ui_clk_sync_rst => ddr_ui_rst,
    mmcm_locked => ddr_mmcm_locked,
    aresetn => ddr_axi_aresetn,
    app_sr_req => '0',
    app_ref_req => '0',
    app_zq_req => '0',
    app_sr_active => open,
    app_ref_ack => open,
    app_zq_ack => open,
    -- Slave Interface Write Address Ports
    s_axi_awid => ddr_axi_awid,
    s_axi_awaddr => ddr_axi_awaddr(c_ddr_addr_width-1 downto 0),
    s_axi_awlen => ddr_axi_awlen,
    s_axi_awsize => ddr_axi_awsize,
    s_axi_awburst => ddr_axi_awburst,
    s_axi_awlock(0) => ddr_axi_awlock,
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
    s_axi_araddr => ddr_axi_araddr(c_ddr_addr_width-1 downto 0),
    s_axi_arlen => ddr_axi_arlen,
    s_axi_arsize => ddr_axi_arsize,
    s_axi_arburst => ddr_axi_arburst,
    s_axi_arlock(0) => ddr_axi_arlock,
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
    -- System Clock Ports
    sys_clk_i => ddr_sys_clk,
    sys_rst => ddr_sys_rst
  );
  
  -- Reset sequence goes like this:
  -- 1. pcie_reset (global) or ddr_reset (register driven) reset DDR core
  -- 2. DDR core drives ddr_ui_rst
  -- 3. ddr_ui_rst or axi_reset (register driven) reset AXI interconnect
  -- 4. AXI interconnect resets:
  --   -> AXI Datamover (via pcie_axi_aresetn)
  --   -> DDR AXI interface (via ddr_axi_aresetn)
  --   -> external AXI master (via s_axi_aresetn_out)
  --
  -- This should provide a reliable reset chain where global reset correctly sets up all interfaces
  -- and PCIe core or DDR core reset correctly reset all AXI interfaces (as required by Interconnect IP)
  
  ddr_sys_rst <= sys_reset or ddr_reset;
  irconnect_arstn <= not(ddr_ui_rst) and not(axi_reset);
  
  s_axi_aclk_out <= ddr_ui_clk;

  ddr_ready <= init_calib_complete and ddr_axi_aresetn;

end generate;

end architecture Behavioral;
