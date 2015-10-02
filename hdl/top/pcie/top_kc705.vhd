
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.abb64Package.all;
use work.ipcores_pkg.all;

library UNISIM;
use UNISIM.VComponents.all;

entity top is
  generic (
    SIMULATION : string := "FALSE"
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
    ddr_sys_clk_p : in std_logic;
    ddr_sys_clk_n : in std_logic;
    pci_sys_clk_p : in std_logic; --100 MHz PCIe Clock (connect directly to input pin)
    pci_sys_clk_n : in std_logic; --100 MHz PCIe Clock
    sys_rst_n     : in std_logic --Reset to PCIe core
    );
end entity top;

architecture arch of top is

  signal ddr_sys_clk_i  : std_logic;
  signal ddr_sys_rst_i  : std_logic;
  signal ddr_axi_aclk_o : std_logic;
  signal sys_rst_n_c : std_logic;

  signal wbone_clk   : std_logic;
  signal wbone_addr  : std_logic_vector(31 downto 0);
  signal wbone_mdin  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wbone_mdout : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wbone_we    : std_logic;
  signal wbone_sel   : std_logic_vector(0 downto 0);
  signal wbone_stb   : std_logic;
  signal wbone_ack   : std_logic;
  signal wbone_cyc   : std_logic;
  signal wbone_rst   : std_logic;

begin
    bpm_pcie_i : entity work.bpm_pcie
    generic map(
      SIMULATION => SIMULATION
      )
    port map(
      --DDR3 memory pins
      ddr3_dq      => ddr3_dq,
      ddr3_dqs_p   => ddr3_dqs_p,
      ddr3_dqs_n   => ddr3_dqs_n,
      ddr3_addr    => ddr3_addr,
      ddr3_ba      => ddr3_ba,
      ddr3_cs_n    => ddr3_cs_n,
      ddr3_ras_n   => ddr3_ras_n,
      ddr3_cas_n   => ddr3_cas_n,
      ddr3_we_n    => ddr3_we_n,
      ddr3_reset_n => ddr3_reset_n,
      ddr3_ck_p    => ddr3_ck_p,
      ddr3_ck_n    => ddr3_ck_n,
      ddr3_cke     => ddr3_cke,
      ddr3_dm      => ddr3_dm,
      ddr3_odt     => ddr3_odt,
      -- PCIe transceivers
      pci_exp_rxp => pci_exp_rxp,
      pci_exp_rxn => pci_exp_rxn,
      pci_exp_txp => pci_exp_txp,
      pci_exp_txn => pci_exp_txn,
      -- Necessity signals
      ddr_sys_clk => ddr_sys_clk_i,
      ddr_sys_rst => ddr_sys_rst_i,
      pci_sys_clk_p => pci_sys_clk_p,
      pci_sys_clk_n => pci_sys_clk_n,
      pci_sys_rst_n => sys_rst_n_c,

      -- DDR memory controller AXI4 interface --
     -- Slave interface clock
      ddr_axi_aclk_o => ddr_axi_aclk_o,
      ddr_axi_aresetn_o => open,
      -- Slave Interface Write Address Ports
      ddr_axi_awid => (others => '0'),
      ddr_axi_awaddr => (others => '0'),
      ddr_axi_awlen => (others => '0'),
      ddr_axi_awsize => (others => '0'),
      ddr_axi_awburst => (others => '0'),
      ddr_axi_awlock => '0',
      ddr_axi_awcache => (others => '0'),
      ddr_axi_awprot => (others => '0'),
      ddr_axi_awqos => (others => '0'),
      ddr_axi_awvalid => '0',
      ddr_axi_awready => open,
      -- Slave Interface Write Data Ports
      ddr_axi_wdata => (others => '0'),
      ddr_axi_wstrb => (others => '0'),
      ddr_axi_wlast => '0',
      ddr_axi_wvalid => '0',
      ddr_axi_wready => open,
      -- Slave Interface Write Response Ports
      ddr_axi_bid => open,
      ddr_axi_bresp => open,
      ddr_axi_bvalid => open,
      ddr_axi_bready => '1',
      -- Slave Interface Read Address Ports
      ddr_axi_arid => (others => '0'),
      ddr_axi_araddr => (others => '0'),
      ddr_axi_arlen => (others => '0'),
      ddr_axi_arsize => (others => '0'),
      ddr_axi_arburst => (others => '0'),
      ddr_axi_arlock => '0',
      ddr_axi_arcache => (others => '0'),
      ddr_axi_arprot => (others => '0'),
      ddr_axi_arqos => (others => '0'),
      ddr_axi_arvalid => '0',
      ddr_axi_arready => open,
      -- Slave Interface Read Data Ports
      ddr_axi_rid => open,
      ddr_axi_rdata => open,
      ddr_axi_rresp => open,
      ddr_axi_rlast => open,
      ddr_axi_rvalid => open,
      ddr_axi_rready => '1',
      --/ DDR memory controller interface

      -- Wishbone interface --
      -- uncomment when instantiating in another project
      CLK_I  => wbone_clk,
      RST_I  => wbone_rst,
      ACK_I  => wbone_ack,
      DAT_I  => wbone_mdin,
      ADDR_O => wbone_addr(28 downto 0),
      DAT_O  => wbone_mdout,
      WE_O   => wbone_we,
      STB_O  => wbone_stb,
      SEL_O  => wbone_sel(0),
      CYC_O  => wbone_cyc,
      --/ Wishbone interface
      -- Additional exported signals for instantiation
      ext_rst_o => wbone_rst
    );

  Wishbone_mem_large: if (SIMULATION = "TRUE") generate
    wb_mem_sim :
      entity work.wb_mem
        generic map(
          AWIDTH => 16,
          DWIDTH => 64
        )
        port map(
          CLK_I => wbone_clk, --in  std_logic;
          ACK_O => wbone_ack, --out std_logic;
          ADR_I => wbone_addr(16-1 downto 0), --in  std_logic_vector(AWIDTH-1 downto 0);
          DAT_I => wbone_mdout, --in  std_logic_vector(DWIDTH-1 downto 0);
          DAT_O => wbone_mdin, --out std_logic_vector(DWIDTH-1 downto 0);
          STB_I => wbone_stb, --in  std_logic;
          WE_I  => wbone_we --in  std_logic
        );

  end generate;

  Wishbone_mem_sample: if (SIMULATION = "FALSE") generate
    wb_mem_syn :
      entity work.wb_mem
        generic map(
          AWIDTH => 7,
          DWIDTH => 64
        )
        port map(
          CLK_I => wbone_clk, --in  std_logic;
          ACK_O => wbone_ack, --out std_logic;
          ADR_I => wbone_addr(7-1 downto 0), --in  std_logic_vector(AWIDTH-1 downto 0);
          DAT_I => wbone_mdout, --in  std_logic_vector(DWIDTH-1 downto 0);
          DAT_O => wbone_mdin, --out std_logic_vector(DWIDTH-1 downto 0);
          STB_I => wbone_stb, --in  std_logic;
          WE_I  => wbone_we --in  std_logic
        );

  end generate;

  --temporary clock assignment
  wbone_clk <= ddr_axi_aclk_o;
  
  sys_reset_n_ibuf: IBUF
    port map (
      O => sys_rst_n_c,
      I => sys_rst_n
      );
      
  ddr_sys_rst_i <= not sys_rst_n_c;
  
  ddr_inclk_buf: IBUFGDS
    port map(
      o  => ddr_sys_clk_i,
      i  => ddr_sys_clk_p,
      ib => ddr_sys_clk_n
    );

end architecture;

