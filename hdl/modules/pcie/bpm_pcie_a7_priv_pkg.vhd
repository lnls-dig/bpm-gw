library ieee;
use ieee.std_logic_1164.all;

library work;
use work.abb64Package.all;
use work.wishbone_pkg.all;

package bpm_pcie_a7_priv_pkg is

  --------------------------------------------------------------------
  -- Components
  --------------------------------------------------------------------
  component bpm_pcie_a7
  generic (
    SIMULATION   : string := "FALSE";
    EXT_RST_PIN  : boolean := true;
    -- ****
    -- PCIe core parameters
    -- ****
    constant pcieLanes : integer := 4;
    PL_FAST_TRAIN      : string  := "FALSE";
    PIPE_SIM_MODE      : string  := "FALSE";
    --***************************************************************************
    -- Necessary parameters for DDR core support
    -- (dependent on memory chip connected to FPGA, not to be modified at will)
    --***************************************************************************
    constant DDR_DQ_WIDTH      : integer := 32;
    constant DDR_PAYLOAD_WIDTH : integer := 256;
    constant DDR_DQS_WIDTH     : integer := 4;
    constant DDR_DM_WIDTH      : integer := 4;
    constant DDR_ROW_WIDTH     : integer := 16;
    constant DDR_BANK_WIDTH    : integer := 3;
    constant DDR_CK_WIDTH      : integer := 1;
    constant DDR_CKE_WIDTH     : integer := 1;
    constant DDR_ODT_WIDTH     : integer := 1;
    SIM_BYPASS_INIT_CAL        : string  := "FAST"
                                     -- # = "OFF" -  Complete memory init &
                                     --              calibration sequence
                                     -- # = "SKIP" - Not supported
                                     -- # = "FAST" - Complete memory init & use
                                     --              abbreviated calib sequence
    );
  port (
    --DDR3 memory pins
    ddr3_dq      : inout std_logic_vector(DDR_DQ_WIDTH-1 downto 0);
    ddr3_dqs_p   : inout std_logic_vector(DDR_DQS_WIDTH-1 downto 0);
    ddr3_dqs_n   : inout std_logic_vector(DDR_DQS_WIDTH-1 downto 0);
    ddr3_addr    : out   std_logic_vector(DDR_ROW_WIDTH-1 downto 0);
    ddr3_ba      : out   std_logic_vector(DDR_BANK_WIDTH-1 downto 0);
    ddr3_ras_n   : out   std_logic;
    ddr3_cas_n   : out   std_logic;
    ddr3_we_n    : out   std_logic;
    ddr3_reset_n : out   std_logic;
    ddr3_ck_p    : out   std_logic_vector(DDR_CK_WIDTH-1 downto 0);
    ddr3_ck_n    : out   std_logic_vector(DDR_CK_WIDTH-1 downto 0);
    ddr3_cke     : out   std_logic_vector(DDR_CKE_WIDTH-1 downto 0);
    ddr3_cs_n    : out   std_logic_vector(0 downto 0);
    ddr3_dm      : out   std_logic_vector(DDR_DM_WIDTH-1 downto 0);
    ddr3_odt     : out   std_logic_vector(DDR_ODT_WIDTH-1 downto 0);
    -- PCIe transceivers
    pci_exp_rxp : in  std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_rxn : in  std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_txp : out std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_txn : out std_logic_vector(pcieLanes - 1 downto 0);
    -- Necessity signals
    ddr_sys_clk_p : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
    ddr_sys_clk_n : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
    sys_clk_p     : in std_logic; --100 MHz PCIe Clock (connect directly to input pin)
    sys_clk_n     : in std_logic; --100 MHz PCIe Clock
    sys_rst_n     : in std_logic; --Reset to PCIe core

    -- DDR memory controller interface --
    ddr_core_rst   : in  std_logic;
    memc_ui_clk    : out std_logic;
    memc_ui_rst    : out std_logic;
    memc_cmd_rdy   : out std_logic;
    memc_cmd_en    : in  std_logic;
    memc_cmd_instr : in  std_logic_vector(2 downto 0);
    memc_cmd_addr  : in  std_logic_vector(31 downto 0);
    memc_wr_en     : in  std_logic;
    memc_wr_end    : in  std_logic;
    memc_wr_mask   : in  std_logic_vector(DDR_PAYLOAD_WIDTH/8-1 downto 0);
    memc_wr_data   : in  std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
    memc_wr_rdy    : out std_logic;
    memc_rd_data   : out std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
    memc_rd_valid  : out std_logic;
    ---- memory arbiter interface
    memarb_acc_req : in  std_logic;
    memarb_acc_gnt : out std_logic;
    --/ DDR memory controller interface

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
    ext_rst_o : out std_logic;

    -- Debug signals
    dbg_app_addr_o           : out   std_logic_vector(31 downto 0);
    dbg_app_cmd_o            : out   std_logic_vector(2 downto 0);
    dbg_app_en_o             : out   std_logic;
    dbg_app_wdf_data_o       : out   std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
    dbg_app_wdf_end_o        : out   std_logic;
    dbg_app_wdf_wren_o       : out   std_logic;
    dbg_app_wdf_mask_o       : out   std_logic_vector(DDR_PAYLOAD_WIDTH/8-1 downto 0);
    dbg_app_rd_data_o        : out   std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
    dbg_app_rd_data_end_o    : out   std_logic;
    dbg_app_rd_data_valid_o  : out   std_logic;
    dbg_app_rdy_o            : out   std_logic;
    dbg_app_wdf_rdy_o        : out   std_logic;
    dbg_ddr_ui_clk_o         : out   std_logic;
    dbg_ddr_ui_reset_o       : out   std_logic;

    dbg_arb_req_o            : out std_logic_vector(1 downto 0);
    dbg_arb_gnt_o            : out std_logic_vector(1 downto 0)
    );
  end component;

end bpm_pcie_a7_priv_pkg;
