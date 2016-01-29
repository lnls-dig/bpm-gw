library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_interconnect_wrapper is
port (
  interconnect_aclk    : in std_logic;
  interconnect_aresetn : in std_logic;
  s00_axi_areset_out_n : out std_logic;
  s00_axi_aclk         : in std_logic;
  s00_axi_awid         : in std_logic_vector ( 3 downto 0 );
  s00_axi_awaddr       : in std_logic_vector ( 31 downto 0 );
  s00_axi_awlen        : in std_logic_vector ( 7 downto 0 );
  s00_axi_awsize       : in std_logic_vector ( 2 downto 0 );
  s00_axi_awburst      : in std_logic_vector ( 1 downto 0 );
  s00_axi_awlock       : in std_logic;
  s00_axi_awcache      : in std_logic_vector ( 3 downto 0 );
  s00_axi_awprot       : in std_logic_vector ( 2 downto 0 );
  s00_axi_awqos        : in std_logic_vector ( 3 downto 0 );
  s00_axi_awvalid      : in std_logic;
  s00_axi_awready      : out std_logic;
  s00_axi_wdata        : in std_logic_vector ( 255 downto 0 );
  s00_axi_wstrb        : in std_logic_vector ( 31 downto 0 );
  s00_axi_wlast        : in std_logic;
  s00_axi_wvalid       : in std_logic;
  s00_axi_wready       : out std_logic;
  s00_axi_bid          : out std_logic_vector ( 3 downto 0 );
  s00_axi_bresp        : out std_logic_vector ( 1 downto 0 );
  s00_axi_bvalid       : out std_logic;
  s00_axi_bready       : in std_logic;
  s00_axi_arid         : in std_logic_vector ( 3 downto 0 );
  s00_axi_araddr       : in std_logic_vector ( 31 downto 0 );
  s00_axi_arlen        : in std_logic_vector ( 7 downto 0 );
  s00_axi_arsize       : in std_logic_vector ( 2 downto 0 );
  s00_axi_arburst      : in std_logic_vector ( 1 downto 0 );
  s00_axi_arlock       : in std_logic;
  s00_axi_arcache      : in std_logic_vector ( 3 downto 0 );
  s00_axi_arprot       : in std_logic_vector ( 2 downto 0 );
  s00_axi_arqos        : in std_logic_vector ( 3 downto 0 );
  s00_axi_arvalid      : in std_logic;
  s00_axi_arready      : out std_logic;
  s00_axi_rid          : out std_logic_vector ( 3 downto 0 );
  s00_axi_rdata        : out std_logic_vector ( 255 downto 0 );
  s00_axi_rresp        : out std_logic_vector ( 1 downto 0 );
  s00_axi_rlast        : out std_logic;
  s00_axi_rvalid       : out std_logic;
  s00_axi_rready       : in std_logic;
  s01_axi_areset_out_n : out std_logic;
  s01_axi_aclk         : in std_logic;
  s01_axi_awid         : in std_logic_vector ( 3 downto 0 );
  s01_axi_awaddr       : in std_logic_vector ( 31 downto 0 );
  s01_axi_awlen        : in std_logic_vector ( 7 downto 0 );
  s01_axi_awsize       : in std_logic_vector ( 2 downto 0 );
  s01_axi_awburst      : in std_logic_vector ( 1 downto 0 );
  s01_axi_awlock       : in std_logic;
  s01_axi_awcache      : in std_logic_vector ( 3 downto 0 );
  s01_axi_awprot       : in std_logic_vector ( 2 downto 0 );
  s01_axi_awqos        : in std_logic_vector ( 3 downto 0 );
  s01_axi_awvalid      : in std_logic;
  s01_axi_awready      : out std_logic;
  s01_axi_wdata        : in std_logic_vector ( 255 downto 0 );
  s01_axi_wstrb        : in std_logic_vector ( 31 downto 0 );
  s01_axi_wlast        : in std_logic;
  s01_axi_wvalid       : in std_logic;
  s01_axi_wready       : out std_logic;
  s01_axi_bid          : out std_logic_vector ( 3 downto 0 );
  s01_axi_bresp        : out std_logic_vector ( 1 downto 0 );
  s01_axi_bvalid       : out std_logic;
  s01_axi_bready       : in std_logic;
  s01_axi_arid         : in std_logic_vector ( 3 downto 0 );
  s01_axi_araddr       : in std_logic_vector ( 31 downto 0 );
  s01_axi_arlen        : in std_logic_vector ( 7 downto 0 );
  s01_axi_arsize       : in std_logic_vector ( 2 downto 0 );
  s01_axi_arburst      : in std_logic_vector ( 1 downto 0 );
  s01_axi_arlock       : in std_logic;
  s01_axi_arcache      : in std_logic_vector ( 3 downto 0 );
  s01_axi_arprot       : in std_logic_vector ( 2 downto 0 );
  s01_axi_arqos        : in std_logic_vector ( 3 downto 0 );
  s01_axi_arvalid      : in std_logic;
  s01_axi_arready      : out std_logic;
  s01_axi_rid          : out std_logic_vector ( 3 downto 0 );
  s01_axi_rdata        : out std_logic_vector ( 255 downto 0 );
  s01_axi_rresp        : out std_logic_vector ( 1 downto 0 );
  s01_axi_rlast        : out std_logic;
  s01_axi_rvalid       : out std_logic;
  s01_axi_rready       : in std_logic;
  m00_axi_areset_out_n : out std_logic;
  m00_axi_aclk         : in std_logic;
  m00_axi_awid         : out std_logic_vector ( 7 downto 0 );
  m00_axi_awaddr       : out std_logic_vector ( 31 downto 0 );
  m00_axi_awlen        : out std_logic_vector ( 7 downto 0 );
  m00_axi_awsize       : out std_logic_vector ( 2 downto 0 );
  m00_axi_awburst      : out std_logic_vector ( 1 downto 0 );
  m00_axi_awlock       : out std_logic;
  m00_axi_awcache      : out std_logic_vector ( 3 downto 0 );
  m00_axi_awprot       : out std_logic_vector ( 2 downto 0 );
  m00_axi_awqos        : out std_logic_vector ( 3 downto 0 );
  m00_axi_awvalid      : out std_logic;
  m00_axi_awready      : in std_logic;
  m00_axi_wdata        : out std_logic_vector ( 255 downto 0 );
  m00_axi_wstrb        : out std_logic_vector ( 31 downto 0 );
  m00_axi_wlast        : out std_logic;
  m00_axi_wvalid       : out std_logic;
  m00_axi_wready       : in std_logic;
  m00_axi_bid          : in std_logic_vector ( 7 downto 0 );
  m00_axi_bresp        : in std_logic_vector ( 1 downto 0 );
  m00_axi_bvalid       : in std_logic;
  m00_axi_bready       : out std_logic;
  m00_axi_arid         : out std_logic_vector ( 7 downto 0 );
  m00_axi_araddr       : out std_logic_vector ( 31 downto 0 );
  m00_axi_arlen        : out std_logic_vector ( 7 downto 0 );
  m00_axi_arsize       : out std_logic_vector ( 2 downto 0 );
  m00_axi_arburst      : out std_logic_vector ( 1 downto 0 );
  m00_axi_arlock       : out std_logic;
  m00_axi_arcache      : out std_logic_vector ( 3 downto 0 );
  m00_axi_arprot       : out std_logic_vector ( 2 downto 0 );
  m00_axi_arqos        : out std_logic_vector ( 3 downto 0 );
  m00_axi_arvalid      : out std_logic;
  m00_axi_arready      : in std_logic;
  m00_axi_rid          : in std_logic_vector ( 7 downto 0 );
  m00_axi_rdata        : in std_logic_vector ( 255 downto 0 );
  m00_axi_rresp        : in std_logic_vector ( 1 downto 0 );
  m00_axi_rlast        : in std_logic;
  m00_axi_rvalid       : in std_logic;
  m00_axi_rready       : out std_logic
 );

end entity axi_interconnect_wrapper;

architecture rtl of axi_interconnect_wrapper is

component axi_interconnect
  Port (
    INTERCONNECT_ACLK : in STD_LOGIC;
    INTERCONNECT_ARESETN : in STD_LOGIC;
    S00_AXI_ARESET_OUT_N : out STD_LOGIC;
    S00_AXI_ACLK : in STD_LOGIC;
    S00_AXI_AWID : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_AWLOCK : in STD_LOGIC;
    S00_AXI_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_AWVALID : in STD_LOGIC;
    S00_AXI_AWREADY : out STD_LOGIC;
    S00_AXI_WDATA : in STD_LOGIC_VECTOR ( 255 downto 0 );
    S00_AXI_WSTRB : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_WLAST : in STD_LOGIC;
    S00_AXI_WVALID : in STD_LOGIC;
    S00_AXI_WREADY : out STD_LOGIC;
    S00_AXI_BID : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_BVALID : out STD_LOGIC;
    S00_AXI_BREADY : in STD_LOGIC;
    S00_AXI_ARID : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S00_AXI_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S00_AXI_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_ARLOCK : in STD_LOGIC;
    S00_AXI_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S00_AXI_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_ARVALID : in STD_LOGIC;
    S00_AXI_ARREADY : out STD_LOGIC;
    S00_AXI_RID : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S00_AXI_RDATA : out STD_LOGIC_VECTOR ( 255 downto 0 );
    S00_AXI_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S00_AXI_RLAST : out STD_LOGIC;
    S00_AXI_RVALID : out STD_LOGIC;
    S00_AXI_RREADY : in STD_LOGIC;
    S01_AXI_ARESET_OUT_N : out STD_LOGIC;
    S01_AXI_ACLK : in STD_LOGIC;
    S01_AXI_AWID : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_AWLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S01_AXI_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_AWLOCK : in STD_LOGIC;
    S01_AXI_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_AWVALID : in STD_LOGIC;
    S01_AXI_AWREADY : out STD_LOGIC;
    S01_AXI_WDATA : in STD_LOGIC_VECTOR ( 255 downto 0 );
    S01_AXI_WSTRB : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_WLAST : in STD_LOGIC;
    S01_AXI_WVALID : in STD_LOGIC;
    S01_AXI_WREADY : out STD_LOGIC;
    S01_AXI_BID : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_BVALID : out STD_LOGIC;
    S01_AXI_BREADY : in STD_LOGIC;
    S01_AXI_ARID : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S01_AXI_ARLEN : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S01_AXI_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_ARLOCK : in STD_LOGIC;
    S01_AXI_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S01_AXI_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_ARVALID : in STD_LOGIC;
    S01_AXI_ARREADY : out STD_LOGIC;
    S01_AXI_RID : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S01_AXI_RDATA : out STD_LOGIC_VECTOR ( 255 downto 0 );
    S01_AXI_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S01_AXI_RLAST : out STD_LOGIC;
    S01_AXI_RVALID : out STD_LOGIC;
    S01_AXI_RREADY : in STD_LOGIC;
    M00_AXI_ARESET_OUT_N : out STD_LOGIC;
    M00_AXI_ACLK : in STD_LOGIC;
    M00_AXI_AWID : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_AWLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_AWLOCK : out STD_LOGIC;
    M00_AXI_AWCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_AWQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_AWVALID : out STD_LOGIC;
    M00_AXI_AWREADY : in STD_LOGIC;
    M00_AXI_WDATA : out STD_LOGIC_VECTOR ( 255 downto 0 );
    M00_AXI_WSTRB : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_WLAST : out STD_LOGIC;
    M00_AXI_WVALID : out STD_LOGIC;
    M00_AXI_WREADY : in STD_LOGIC;
    M00_AXI_BID : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_BVALID : in STD_LOGIC;
    M00_AXI_BREADY : out STD_LOGIC;
    M00_AXI_ARID : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M00_AXI_ARLEN : out STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_ARLOCK : out STD_LOGIC;
    M00_AXI_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M00_AXI_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M00_AXI_ARVALID : out STD_LOGIC;
    M00_AXI_ARREADY : in STD_LOGIC;
    M00_AXI_RID : in STD_LOGIC_VECTOR ( 7 downto 0 );
    M00_AXI_RDATA : in STD_LOGIC_VECTOR ( 255 downto 0 );
    M00_AXI_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M00_AXI_RLAST : in STD_LOGIC;
    M00_AXI_RVALID : in STD_LOGIC;
    M00_AXI_RREADY : out STD_LOGIC
  );
end component;

begin

  u_axi_interconnect : axi_interconnect
  port map (
    interconnect_aclk    => interconnect_aclk,
    interconnect_aresetn => interconnect_aresetn,
    s00_axi_areset_out_n => s00_axi_areset_out_n,
    s00_axi_aclk         => s00_axi_aclk,
    s00_axi_awid         => s00_axi_awid,
    s00_axi_awaddr       => s00_axi_awaddr,
    s00_axi_awlen        => s00_axi_awlen,
    s00_axi_awsize       => s00_axi_awsize,
    s00_axi_awburst      => s00_axi_awburst,
    s00_axi_awlock       => s00_axi_awlock,
    s00_axi_awcache      => s00_axi_awcache,
    s00_axi_awprot       => s00_axi_awprot,
    s00_axi_awqos        => s00_axi_awqos,
    s00_axi_awvalid      => s00_axi_awvalid,
    s00_axi_awready      => s00_axi_awready,
    s00_axi_wdata        => s00_axi_wdata,
    s00_axi_wstrb        => s00_axi_wstrb,
    s00_axi_wlast        => s00_axi_wlast,
    s00_axi_wvalid       => s00_axi_wvalid,
    s00_axi_wready       => s00_axi_wready,
    s00_axi_bid          => s00_axi_bid,
    s00_axi_bresp        => s00_axi_bresp,
    s00_axi_bvalid       => s00_axi_bvalid,
    s00_axi_bready       => s00_axi_bready,
    s00_axi_arid         => s00_axi_arid,
    s00_axi_araddr       => s00_axi_araddr,
    s00_axi_arlen        => s00_axi_arlen,
    s00_axi_arsize       => s00_axi_arsize,
    s00_axi_arburst      => s00_axi_arburst,
    s00_axi_arlock       => s00_axi_arlock,
    s00_axi_arcache      => s00_axi_arcache,
    s00_axi_arprot       => s00_axi_arprot,
    s00_axi_arqos        => s00_axi_arqos,
    s00_axi_arvalid      => s00_axi_arvalid,
    s00_axi_arready      => s00_axi_arready,
    s00_axi_rid          => s00_axi_rid,
    s00_axi_rdata        => s00_axi_rdata,
    s00_axi_rresp        => s00_axi_rresp,
    s00_axi_rlast        => s00_axi_rlast,
    s00_axi_rvalid       => s00_axi_rvalid,
    s00_axi_rready       => s00_axi_rready,
    s01_axi_areset_out_n => s01_axi_areset_out_n,
    s01_axi_aclk         => s01_axi_aclk,
    s01_axi_awid         => s01_axi_awid,
    s01_axi_awaddr       => s01_axi_awaddr,
    s01_axi_awlen        => s01_axi_awlen,
    s01_axi_awsize       => s01_axi_awsize,
    s01_axi_awburst      => s01_axi_awburst,
    s01_axi_awlock       => s01_axi_awlock,
    s01_axi_awcache      => s01_axi_awcache,
    s01_axi_awprot       => s01_axi_awprot,
    s01_axi_awqos        => s01_axi_awqos,
    s01_axi_awvalid      => s01_axi_awvalid,
    s01_axi_awready      => s01_axi_awready,
    s01_axi_wdata        => s01_axi_wdata,
    s01_axi_wstrb        => s01_axi_wstrb,
    s01_axi_wlast        => s01_axi_wlast,
    s01_axi_wvalid       => s01_axi_wvalid,
    s01_axi_wready       => s01_axi_wready,
    s01_axi_bid          => s01_axi_bid,
    s01_axi_bresp        => s01_axi_bresp,
    s01_axi_bvalid       => s01_axi_bvalid,
    s01_axi_bready       => s01_axi_bready,
    s01_axi_arid         => s01_axi_arid,
    s01_axi_araddr       => s01_axi_araddr,
    s01_axi_arlen        => s01_axi_arlen,
    s01_axi_arsize       => s01_axi_arsize,
    s01_axi_arburst      => s01_axi_arburst,
    s01_axi_arlock       => s01_axi_arlock,
    s01_axi_arcache      => s01_axi_arcache,
    s01_axi_arprot       => s01_axi_arprot,
    s01_axi_arqos        => s01_axi_arqos,
    s01_axi_arvalid      => s01_axi_arvalid,
    s01_axi_arready      => s01_axi_arready,
    s01_axi_rid          => s01_axi_rid,
    s01_axi_rdata        => s01_axi_rdata,
    s01_axi_rresp        => s01_axi_rresp,
    s01_axi_rlast        => s01_axi_rlast,
    s01_axi_rvalid       => s01_axi_rvalid,
    s01_axi_rready       => s01_axi_rready,
    m00_axi_areset_out_n => m00_axi_areset_out_n,
    m00_axi_aclk         => m00_axi_aclk,
    m00_axi_awid         => m00_axi_awid,
    m00_axi_awaddr       => m00_axi_awaddr,
    m00_axi_awlen        => m00_axi_awlen,
    m00_axi_awsize       => m00_axi_awsize,
    m00_axi_awburst      => m00_axi_awburst,
    m00_axi_awlock       => m00_axi_awlock,
    m00_axi_awcache      => m00_axi_awcache,
    m00_axi_awprot       => m00_axi_awprot,
    m00_axi_awqos        => m00_axi_awqos,
    m00_axi_awvalid      => m00_axi_awvalid,
    m00_axi_awready      => m00_axi_awready,
    m00_axi_wdata        => m00_axi_wdata,
    m00_axi_wstrb        => m00_axi_wstrb,
    m00_axi_wlast        => m00_axi_wlast,
    m00_axi_wvalid       => m00_axi_wvalid,
    m00_axi_wready       => m00_axi_wready,
    m00_axi_bid          => m00_axi_bid,
    m00_axi_bresp        => m00_axi_bresp,
    m00_axi_bvalid       => m00_axi_bvalid,
    m00_axi_bready       => m00_axi_bready,
    m00_axi_arid         => m00_axi_arid,
    m00_axi_araddr       => m00_axi_araddr,
    m00_axi_arlen        => m00_axi_arlen,
    m00_axi_arsize       => m00_axi_arsize,
    m00_axi_arburst      => m00_axi_arburst,
    m00_axi_arlock       => m00_axi_arlock,
    m00_axi_arcache      => m00_axi_arcache,
    m00_axi_arprot       => m00_axi_arprot,
    m00_axi_arqos        => m00_axi_arqos,
    m00_axi_arvalid      => m00_axi_arvalid,
    m00_axi_arready      => m00_axi_arready,
    m00_axi_rid          => m00_axi_rid,
    m00_axi_rdata        => m00_axi_rdata,
    m00_axi_rresp        => m00_axi_rresp,
    m00_axi_rlast        => m00_axi_rlast,
    m00_axi_rvalid       => m00_axi_rvalid,
    m00_axi_rready       => m00_axi_rready
  );

end architecture rtl;
