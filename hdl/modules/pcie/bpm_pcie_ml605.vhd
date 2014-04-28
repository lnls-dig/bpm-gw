----------------------------------------------------------------------------------
-- Company: Creotech
-- Engineer: Adrian Byszuk (adrian.byszuk@gmail.com)
--
-- Design Name:
-- Module Name:    bpm_pcie_ml605 - Behavioral
-- Project Name:
-- Target Devices: XC7A200T on AC uTCA card from OHWR
-- Tool versions: ISE 14.4, ISE 14.6
-- Description: This is TOP module for the versatile firmware for PCIe communication.
-- It provides DMA engine with scatter-gather (linked list) functionality.
-- DDR memory is supported through BAR1. Wishbone endpoint is accessible through BAR2.
--
-- Dependencies: Xilinx PCIe core for 7 series. Xilinx DDR core for 7 series.
--
-- Revision: 2.00 - Original file completely rewritten by abyszuk.
--
-- Revision 1.00 - File Released
--
-- Additional Comments: This file can be used both as TOP module for independent operation, or
-- instantiated in another projects. To use it in your project, change INSTANTIATED generic to
-- "TRUE" and uncomment relevant interface sections in entity declaration. ATTENTION: you also
-- have to comment out dummy signal with names exactly the same as port names (it was necessary so
-- that XST won't complain about missing signal names).
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.abb64Package.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity bpm_pcie_ml605 is
  generic (
    SIMULATION   : string := "FALSE";
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
    constant DDR_DQ_WIDTH      : integer := 64;
    constant DDR_PAYLOAD_WIDTH : integer := 256;
    constant DDR_DQS_WIDTH     : integer := 8;
    constant DDR_DM_WIDTH      : integer := 8;
    constant DDR_ROW_WIDTH     : integer := 14;
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
    ddr3_cs_n    : out   std_logic_vector(0 downto 0);
    ddr3_ras_n   : out   std_logic;
    ddr3_cas_n   : out   std_logic;
    ddr3_we_n    : out   std_logic;
    ddr3_reset_n : out   std_logic;
    ddr3_ck_p    : out   std_logic_vector(DDR_CK_WIDTH-1 downto 0);
    ddr3_ck_n    : out   std_logic_vector(DDR_CK_WIDTH-1 downto 0);
    ddr3_cke     : out   std_logic_vector(DDR_CKE_WIDTH-1 downto 0);
    ddr3_dm      : out   std_logic_vector(DDR_DM_WIDTH-1 downto 0);
    ddr3_odt     : out   std_logic_vector(DDR_ODT_WIDTH-1 downto 0);
    -- PCIe transceivers
    pci_exp_rxp : in  std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_rxn : in  std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_txp : out std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_txn : out std_logic_vector(pcieLanes - 1 downto 0);
    -- Necessity signals
    ddr_sys_clk_p : in std_logic; --200 MHz DDR core clock (connect through BUFG or PLL)
    sys_clk_p     : in std_logic; --100 MHz PCIe Clock (connect directly to input pin)
    sys_clk_n     : in std_logic; --100 MHz PCIe Clock
    sys_rst_n     : in std_logic; --Reset to PCIe core

    -- DDR memory controller interface --
    -- uncomment when instantiating in another project
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
    -- uncomment when instantiating in another project
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
end entity bpm_pcie_ml605;

architecture Behavioral of bpm_pcie_ml605 is

  constant DDR_ADDR_WIDTH : integer := 28;

  component pcie_core
    generic (
      PL_FAST_TRAIN   : string := "FALSE";
      UPSTREAM_FACING : string := "TRUE"
      );
    port (
      -------------------------------------------------------------------------------------------------------------------
      -- 1. PCI Express (pci_exp) Interface                                                                            --
      -------------------------------------------------------------------------------------------------------------------
      pci_exp_txp : out std_logic_vector(3 downto 0);
      pci_exp_txn : out std_logic_vector(3 downto 0);
      pci_exp_rxp : in  std_logic_vector(3 downto 0);
      pci_exp_rxn : in  std_logic_vector(3 downto 0);

      -------------------------------------------------------------------------------------------------------------------
      -- 2. AXI-S Interface                                                                                            --
      -------------------------------------------------------------------------------------------------------------------
      -- Common
      user_clk_out   : out std_logic;
      user_reset_out : out std_logic;
      user_lnk_up    : out std_logic;

      -- TX
      tx_buf_av        : out std_logic_vector(5 downto 0);
      tx_cfg_req       : out std_logic;
      tx_err_drop      : out std_logic;
      s_axis_tx_tready : out std_logic;
      s_axis_tx_tdata  : in  std_logic_vector((C_DATA_WIDTH - 1) downto 0);
      s_axis_tx_tkeep  : in  std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      s_axis_tx_tlast  : in  std_logic;
      s_axis_tx_tvalid : in  std_logic;
      s_axis_tx_tuser  : in  std_logic_vector(3 downto 0);
      tx_cfg_gnt       : in  std_logic;

      -- RX
      m_axis_rx_tdata  : out std_logic_vector((C_DATA_WIDTH - 1) downto 0);
      m_axis_rx_tkeep  : out std_logic_vector((C_DATA_WIDTH / 8 - 1) downto 0);
      m_axis_rx_tlast  : out std_logic;
      m_axis_rx_tvalid : out std_logic;
      m_axis_rx_tready : in  std_logic;
      m_axis_rx_tuser  : out std_logic_vector(21 downto 0);
      rx_np_ok         : in  std_logic;

      -- Flow Control
      fc_cpld : out std_logic_vector(11 downto 0);
      fc_cplh : out std_logic_vector(7 downto 0);
      fc_npd  : out std_logic_vector(11 downto 0);
      fc_nph  : out std_logic_vector(7 downto 0);
      fc_pd   : out std_logic_vector(11 downto 0);
      fc_ph   : out std_logic_vector(7 downto 0);
      fc_sel  : in  std_logic_vector(2 downto 0);

      -------------------------------------------------------------------------------------------------------------------
      -- 3. Configuration (CFG) Interface                                                                              --
      -------------------------------------------------------------------------------------------------------------------
      cfg_di      : in std_logic_vector(31 downto 0);
      cfg_byte_en : in std_logic_vector(3 downto 0);
      cfg_dwaddr  : in std_logic_vector(9 downto 0);
      cfg_wr_en   : in std_logic;
      cfg_rd_en   : in std_logic;

      cfg_status          : out std_logic_vector(15 downto 0);
      cfg_command         : out std_logic_vector(15 downto 0);
      cfg_dstatus         : out std_logic_vector(15 downto 0);
      cfg_dcommand        : out std_logic_vector(15 downto 0);
      cfg_lstatus         : out std_logic_vector(15 downto 0);
      cfg_lcommand        : out std_logic_vector(15 downto 0);
      cfg_dcommand2       : out std_logic_vector(15 downto 0);
      cfg_pcie_link_state : out std_logic_vector(2 downto 0);

      cfg_pmcsr_pme_en          : out std_logic;
      cfg_pmcsr_powerstate      : out std_logic_vector(1 downto 0);
      cfg_pmcsr_pme_status      : out std_logic;

      -- Error Reporting Interface
      cfg_err_ecrc                  : in  std_logic;
      cfg_err_ur                    : in  std_logic;
      cfg_err_cpl_timeout           : in  std_logic;
      cfg_err_cpl_unexpect          : in  std_logic;
      cfg_err_cpl_abort             : in  std_logic;
      cfg_err_posted                : in  std_logic;
      cfg_err_cor                   : in  std_logic;
      cfg_err_tlp_cpl_header        : in  std_logic_vector(47 downto 0);
      cfg_err_cpl_rdy               : out std_logic;
      cfg_err_locked                : in  std_logic;
      cfg_trn_pending               : in  std_logic;
      cfg_dsn                       :     std_logic_vector(63 downto 0);

      ---------------------------------------------------------------------
      -- EP Only                                                        --
      ---------------------------------------------------------------------
      cfg_interrupt                : in  std_logic;
      cfg_interrupt_rdy            : out std_logic;
      cfg_interrupt_assert         : in  std_logic;
      cfg_interrupt_di             : in  std_logic_vector(7 downto 0);
      cfg_interrupt_do             : out std_logic_vector(7 downto 0);
      cfg_interrupt_mmenable       : out std_logic_vector(2 downto 0);
      cfg_interrupt_msienable      : out std_logic;
      cfg_interrupt_msixenable     : out std_logic;
      cfg_interrupt_msixfm         : out std_logic;
      cfg_to_turnoff               : out std_logic;
      cfg_turnoff_ok               : in  std_logic;
      cfg_bus_number               : out std_logic_vector(7 downto 0);
      cfg_device_number            : out std_logic_vector(4 downto 0);
      cfg_function_number          : out std_logic_vector(2 downto 0);
      cfg_pm_wake                  : in  std_logic;

      -------------------------------------------------------------------------------------------------------------------
      -- 4. Physical Layer Control and Status (PL) Interface                                                           --
      -------------------------------------------------------------------------------------------------------------------
      pl_directed_link_change   : in std_logic_vector(1 downto 0);
      pl_directed_link_width    : in std_logic_vector(1 downto 0);
      pl_directed_link_speed    : in std_logic;
      pl_directed_link_auton    : in std_logic;
      pl_upstream_prefer_deemph : in std_logic;

      pl_ltssm_state        : out std_logic_vector(5 downto 0);
      pl_lane_reversal_mode : out std_logic_vector(1 downto 0);

      pl_link_partner_gen2_supported : out std_logic;
      pl_initial_link_width          : out std_logic_vector(2 downto 0);

      ---------------------------------------------------------------------
      -- EP Only                                                        --
      ---------------------------------------------------------------------
      pl_received_hot_rst         : out std_logic;

      -------------------------------------------------------------------------------------------------------------------
      -- 6. System(SYS) Interface                                                                                      --
      -------------------------------------------------------------------------------------------------------------------
      sys_clk         : in std_logic;
      sys_reset       : in std_logic);
  end component;

  component ddr_v6
    generic(
      SIM_BYPASS_INIT_CAL : string := "OFF";
                          -- # = "OFF" -  Complete memory init &
                          --              calibration sequence
                          -- # = "SKIP" - Skip memory init &
                          --              calibration sequence
                          -- # = "FAST" - Skip memory init & use
                          --              abbreviated calib sequence
      RST_ACT_LOW : integer := 1
                    -- =1 for active low reset,
                    -- =0 for active high.
      );
    port(
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
      ddr3_dm      : out   std_logic_vector(DDR_DM_WIDTH-1 downto 0);
      ddr3_odt     : out   std_logic_vector(DDR_ODT_WIDTH-1 downto 0);
      ddr3_cs_n    : out   std_logic_vector(DDR_ODT_WIDTH-1 downto 0);

      sda               : inout std_logic;
      scl               : out   std_logic;
      app_addr          : in  std_logic_vector(DDR_ADDR_WIDTH-1 downto 0);
      app_cmd           : in  std_logic_vector(2 downto 0);
      app_en            : in  std_logic;
      app_wdf_data      : in  std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
      app_wdf_end       : in  std_logic;
      app_wdf_mask      : in  std_logic_vector(DDR_PAYLOAD_WIDTH/8-1 downto 0);
      app_wdf_wren      : in  std_logic;
      app_rd_data       : out std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
      app_rd_data_end   : out std_logic;
      app_rd_data_valid : out std_logic;
      app_rdy           : out std_logic;
      app_wdf_rdy       : out std_logic;
      ui_clk_sync_rst   : out   std_logic;
      ui_clk            : out   std_logic;
      phy_init_done     : out   std_logic;

      sys_clk : in std_logic;
      clk_ref : in std_logic;
      sys_rst : in std_logic
      );
  end component ddr_v6;

-- -----------------------------------------------------------------------
--  DDR SDRAM control module
-- -----------------------------------------------------------------------
  component bram_DDRs_Control_loopback
    generic (
      C_ASYNFIFO_WIDTH : integer;
      P_SIMULATION     : boolean
      );
    port (

      DDR_wr_sof   : in  std_logic;
      DDR_wr_eof   : in  std_logic;
      DDR_wr_v     : in  std_logic;
      DDR_wr_Shift : in  std_logic;
      DDR_wr_Mask  : in  std_logic_vector(2-1 downto 0);
      DDR_wr_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full  : out std_logic;

      DDR_rdc_sof   : in  std_logic;
      DDR_rdc_eof   : in  std_logic;
      DDR_rdc_v     : in  std_logic;
      DDR_rdc_Shift : in  std_logic;
      DDR_rdc_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_rdc_full  : out std_logic;

      -- DDR payload FIFO Read Port
      DDR_FIFO_RdEn   : in  std_logic;
      DDR_FIFO_Empty  : out std_logic;
      DDR_FIFO_RdQout : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Common interface
      DDR_Ready   : out std_logic;
      DDR_Blinker : out std_logic;
      mem_clk     : in  std_logic;
      user_clk    : in  std_logic;
      Sim_Zeichen : out std_logic;
      user_reset  : in  std_logic
      );
  end component;

  component DDR_Transact
    generic (
      SIMULATION       : string;
      DATA_WIDTH       : integer;
      ADDR_WIDTH       : integer;
      DDR_UI_DATAWIDTH : integer;
      DDR_DQ_WIDTH     : integer;
      DEVICE_TYPE      : string  -- "VIRTEX6"
                                 -- "KINTEX7"
                                 -- "ARTIX7"
      );
    port (
      --ext logic interface to memory core
      -- memory controller interface --
      memc_ui_clk    : out std_logic;
      memc_cmd_rdy   : out std_logic;
      memc_cmd_en    : in  std_logic;
      memc_cmd_instr : in  std_logic_vector(2 downto 0);
      memc_cmd_addr  : in  std_logic_vector(31 downto 0);
      memc_wr_en     : in  std_logic;
      memc_wr_end    : in  std_logic;
      memc_wr_mask   : in  std_logic_vector(DDR_UI_DATAWIDTH/8-1 downto 0);
      memc_wr_data   : in  std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
      memc_wr_rdy    : out std_logic;
      memc_rd_data   : out std_logic_vector(DDR_UI_DATAWIDTH-1 downto 0);
      memc_rd_valid  : out std_logic;
      -- memory arbiter interface
      memarb_acc_req : in  std_logic;
      memarb_acc_gnt : out std_logic;
      --/ext logic interface

      -- PCIE interface
      DDR_wr_eof   : in  std_logic;
      DDR_wr_v     : in  std_logic;
      DDR_wr_Shift : in  std_logic;
      DDR_wr_Mask  : in  std_logic_vector(2-1 downto 0);
      DDR_wr_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full  : out std_logic;

      DDR_rdc_v     : in  std_logic;
      DDR_rdc_Shift : in  std_logic;
      DDR_rdc_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_rdc_full  : out std_logic;

      -- DDR payload FIFO Read Port
      DDR_FIFO_RdEn   : in  std_logic;
      DDR_FIFO_Empty  : out std_logic;
      DDR_FIFO_RdQout : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      --/PCIE interface

      -- Common interface
      DDR_Ready : out std_logic;

      -- DDR core UI
      app_addr            : out std_logic_vector(ADDR_WIDTH-1 downto 0);
      app_cmd             : out std_logic_vector(2 downto 0);
      app_en              : out std_logic;
      app_wdf_data        : out std_logic_vector((DDR_UI_DATAWIDTH)-1 downto 0);
      app_wdf_end         : out std_logic;
      app_wdf_mask        : out std_logic_vector((DDR_UI_DATAWIDTH)/8-1 downto 0);
      app_wdf_wren        : out std_logic;
      app_rd_data         : in  std_logic_vector((DDR_UI_DATAWIDTH)-1 downto 0);
      app_rd_data_end     : in  std_logic;
      app_rd_data_valid   : in  std_logic;
      app_rdy             : in  std_logic;
      app_wdf_rdy         : in  std_logic;
      ui_clk              : in  std_logic;
      ui_clk_sync_rst     : in  std_logic;
      init_calib_complete : in  std_logic;

      --clocking & reset
      user_clk      : in std_logic;
      user_reset    : in std_logic;

      dbg_arb_req_o : out std_logic_vector(1 downto 0);
      dbg_arb_gnt_o : out std_logic_vector(1 downto 0)
      );
  end component;


  signal DDR_wr_sof   : std_logic;
  signal DDR_wr_eof   : std_logic;
  signal DDR_wr_v     : std_logic;
  signal DDR_wr_Shift : std_logic;
  signal DDR_wr_Mask  : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_wr_full  : std_logic;

  signal DDR_rdc_sof   : std_logic;
  signal DDR_rdc_eof   : std_logic;
  signal DDR_rdc_v     : std_logic;
  signal DDR_rdc_Shift : std_logic;
  signal DDR_rdc_din   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_rdc_full  : std_logic;

  signal DDR_FIFO_RdEn   : std_logic;
  signal DDR_FIFO_Empty  : std_logic;
  signal DDR_FIFO_RdQout : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal DDR_Ready   : std_logic;

  -- -----------------------------------------------------------------------
  -- Wishbone interface module
  -- -----------------------------------------------------------------------
  component wb_transact is
    port (
      -- PCIE user clk
      user_clk : in std_logic;
      -- Write port
      wr_we   : in std_logic;
      wr_sof  : in std_logic;
      wr_eof  : in std_logic;
      wr_din  : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wr_full : out std_logic;
      -- Read command port
      rdc_sof  : in std_logic;
      rdc_v    : in std_logic;
      rdc_din  : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      rdc_full : out std_logic;
      rd_tout  : in std_logic;
      -- Read data port
      rd_ren   : in std_logic;
      rd_empty : out std_logic;
      rd_dout  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Wishbone interface
      wb_clk : in std_logic;
      wb_rst : in std_logic;
      addr_o : out std_logic_vector(28 downto 0);
      dat_i  : in std_logic_vector(63 downto 0);
      dat_o  : out std_logic_vector(63 downto 0);
      we_o   : out std_logic;
      sel_o  : out std_logic_vector(0 downto 0);
      stb_o  : out std_logic;
      ack_i  : in std_logic;
      cyc_o  : out std_logic;

      --RESET from PCIe
      rst : in std_logic
      );
  end component;

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

------------- COMPONENT Declaration: tlpControl   ------
--
  component tlpControl
    port (
      -- Wishbone interface
      wb_FIFO_we   : out std_logic;
      wb_FIFO_wsof : out std_logic;
      wb_FIFO_weof : out std_logic;
      wb_FIFO_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wb_FIFO_full : in std_logic;

      wb_FIFO_Rst : out std_logic;

      -- Wishbone Read interface
      wb_rdc_sof  : out std_logic;
      wb_rdc_v    : out std_logic;
      wb_rdc_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wb_rdc_full : in std_logic;
      wb_timeout  : out std_logic;

      -- Wisbbone Buffer read port
      wb_FIFO_re    : out std_logic;
      wb_FIFO_empty : in  std_logic;
      wb_FIFO_qout  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- DDR control interface
      DDR_Ready : in std_logic;

      DDR_wr_sof   : out std_logic;
      DDR_wr_eof   : out std_logic;
      DDR_wr_v     : out std_logic;
      DDR_wr_Shift : out std_logic;
      DDR_wr_Mask  : out std_logic_vector(2-1 downto 0);
      DDR_wr_din   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full  : in  std_logic;

      DDR_rdc_sof   : out std_logic;
      DDR_rdc_eof   : out std_logic;
      DDR_rdc_v     : out std_logic;
      DDR_rdc_Shift : out std_logic;
      DDR_rdc_din   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_rdc_full  : in  std_logic;

      -- DDR payload FIFO Read Port
      DDR_FIFO_RdEn   : out std_logic;
      DDR_FIFO_Empty  : in  std_logic;
      DDR_FIFO_RdQout : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Transaction layer interface
      user_lnk_up       : in  std_logic;
      rx_np_ok          : out std_logic;
      rx_np_req         : out std_logic;
      s_axis_tx_tdsc    : out std_logic;
      tx_buf_av         : in  std_logic_vector(C_TBUF_AWIDTH-1 downto 0);
      s_axis_tx_terrfwd : out std_logic;

      user_clk          : in std_logic;
      user_reset        : in std_logic;
      m_axis_rx_tvalid  : in std_logic;
      s_axis_tx_tready  : in std_logic;
      m_axis_rx_tlast   : in std_logic;
      m_axis_rx_terrfwd : in std_logic;
      m_axis_rx_tkeep   : in std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      m_axis_rx_tdata   : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      cfg_dcommand    : in std_logic_vector(15 downto 0);
      pcie_link_width : in std_logic_vector(5 downto 0);
      localId         : in std_logic_vector(15 downto 0);

      cfg_interrupt            : out std_logic;
      cfg_interrupt_rdy        : in  std_logic;
      cfg_interrupt_mmenable   : in  std_logic_vector(2 downto 0);
      cfg_interrupt_msienable  : in  std_logic;
      cfg_interrupt_msixenable : in std_logic;
      cfg_interrupt_msixfm     : in std_logic;
      cfg_interrupt_di         : out std_logic_vector(7 downto 0);
      cfg_interrupt_do         : in  std_logic_vector(7 downto 0);
      cfg_interrupt_assert     : out std_logic;

      m_axis_rx_tbar_hit : in  std_logic_vector(6 downto 0);
      s_axis_tx_tvalid   : out std_logic;
      m_axis_rx_tready   : out std_logic;
      s_axis_tx_tlast    : out std_logic;
      s_axis_tx_tkeep    : out std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      s_axis_tx_tdata    : out std_logic_vector(C_DBUS_WIDTH-1 downto 0)
      );
  end component;

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

  signal cfg_dcommand2 : std_logic_vector (16-1 downto 0);
  signal tx_cfg_req    : std_logic;

  signal pl_initial_link_width          : std_logic_vector (3-1 downto 0);
  signal pl_lane_reversal_mode          : std_logic_vector (2-1 downto 0);
  signal pl_link_partner_gen2_supported : std_logic;
  signal pl_received_hot_rst            : std_logic;
  signal pl_directed_link_auton         : std_logic;
  signal pl_directed_link_change        : std_logic_vector (2-1 downto 0);
  signal pl_directed_link_speed         : std_logic;
  signal pl_directed_link_width         : std_logic_vector (2-1 downto 0);
  signal pl_upstream_prefer_deemph      : std_logic;

  -- Wires used for external clocking connectivity
  signal PIPE_PCLK_IN      : std_logic                    := '0';
  signal PIPE_RXUSRCLK_IN  : std_logic                    := '0';
  signal PIPE_RXOUTCLK_IN  : std_logic_vector(3 downto 0) := (others => '0');
  signal PIPE_DCLK_IN      : std_logic                    := '0';
  signal PIPE_USERCLK1_IN  : std_logic                    := '0';
  signal PIPE_USERCLK2_IN  : std_logic                    := '0';
  signal PIPE_OOBCLK_IN    : std_logic                    := '0';
  signal PIPE_MMCM_LOCK_IN : std_logic                    := '0';

  signal PIPE_TXOUTCLK_OUT : std_logic;
  signal PIPE_RXOUTCLK_OUT : std_logic_vector(3 downto 0);
  signal PIPE_PCLK_SEL_OUT : std_logic_vector(3 downto 0);
  signal PIPE_GEN3_OUT     : std_logic;
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
  signal cfg_interrupt_msixenable   : std_logic;
  signal cfg_interrupt_msixfm       : std_logic;
  signal cfg_interrupt_di           : std_logic_vector(7 downto 0);
  signal cfg_interrupt_do           : std_logic_vector(7 downto 0);
  signal cfg_interrupt_assert       : std_logic;
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

  signal sys_clk_c     : std_logic;
  signal sys_reset_n_c : std_logic;
  signal sys_reset_c   : std_logic;
  signal reset_n       : std_logic;

  signal localId         : std_logic_vector(15 downto 0);
  signal pcie_link_width : std_logic_vector(5 downto 0);

  signal ddr_ref_clk_i : std_logic;

  ----- DDR core User Interface signals -----------------------
  signal app_addr          : std_logic_vector(DDR_ADDR_WIDTH-1 downto 0);
  signal app_cmd           : std_logic_vector(2 downto 0);
  signal app_en            : std_logic;
  signal app_wdf_data      : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal app_wdf_end       : std_logic;
  signal app_wdf_mask      : std_logic_vector(DDR_PAYLOAD_WIDTH/8-1 downto 0);
  signal app_wdf_wren      : std_logic;
  signal app_rd_data       : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal app_rd_data_end   : std_logic;
  signal app_rd_data_valid : std_logic;
  signal app_rdy           : std_logic;
  signal app_wdf_rdy       : std_logic;
  signal ddr_ui_clk        : std_logic;
  signal ddr_ui_reset      : std_logic;
  signal ddr_calib_done    : std_logic;
  signal ddr_sys_clk_i     : std_logic;
  signal ddr_sys_reset_i   : std_logic;

begin

  sys_reset_c <= not sys_reset_n_c;
  sys_reset_n_ibuf : IBUF
    port map (
      O => sys_reset_n_c,
      I => sys_rst_n
      );

  pcieclk_ibuf : IBUFDS_GTXE1
    port map (
      O     => sys_clk_c,
      ODIV2 => open,
      I     => sys_clk_p,
      IB    => sys_clk_n,
      CEB   => '0'
      );

  cfg_err_cor            <= '0';
  cfg_err_ur             <= '0';
  cfg_err_ecrc           <= '0';
  cfg_err_cpl_timeout    <= '0';
  cfg_err_cpl_abort      <= '0';
  cfg_err_cpl_unexpect   <= '0';
  cfg_err_posted         <= '1';
  cfg_err_locked         <= '1';
  cfg_err_tlp_cpl_header <= (others => '0');
  cfg_trn_pending        <= '0';
  cfg_pm_wake            <= '0';
--
  fc_sel <= (others => '0');

  pl_directed_link_auton    <= '0';
  pl_directed_link_change   <= (others => '0');
  pl_directed_link_speed    <= '0';
  pl_directed_link_width    <= (others => '0');
  pl_upstream_prefer_deemph <= '0';

  tx_cfg_gnt         <= '1';
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
  pcie_core_i : pcie_core
  generic map(
    PL_FAST_TRAIN => PL_FAST_TRAIN
  )
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
    -- 2. AXI-S Interface                                                                                            --
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

    -- Flow Control
    fc_cpld => fc_cpld ,
    fc_cplh => fc_cplh ,
    fc_npd  => fc_npd ,
    fc_nph  => fc_nph ,
    fc_pd   => fc_pd ,
    fc_ph   => fc_ph ,
    fc_sel  => fc_sel ,

    -------------------------------------------------------------------------------------------------------------------
    -- 3. Configuration (CFG) Interface                                                                              --
    -------------------------------------------------------------------------------------------------------------------
    cfg_di      => cfg_di,
    cfg_byte_en => (others => '0'),
    cfg_dwaddr  => cfg_dwaddr,
    cfg_wr_en   => '0',
    cfg_rd_en   => '0',

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

    cfg_err_ecrc                  => cfg_err_ecrc ,
    cfg_err_ur                    => cfg_err_ur ,
    cfg_err_cpl_timeout           => cfg_err_cpl_timeout ,
    cfg_err_cpl_unexpect          => cfg_err_cpl_unexpect ,
    cfg_err_cpl_abort             => cfg_err_cpl_abort ,
    cfg_err_posted                => cfg_err_posted ,
    cfg_err_cor                   => cfg_err_cor ,
    cfg_err_tlp_cpl_header        => cfg_err_tlp_cpl_header,
    cfg_err_cpl_rdy               => cfg_err_cpl_rdy ,
    cfg_err_locked                => cfg_err_locked ,

    cfg_trn_pending       => cfg_trn_pending ,

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
    cfg_to_turnoff               => cfg_to_turnoff ,
    cfg_turnoff_ok               => cfg_turnoff_ok ,
    cfg_bus_number               => cfg_bus_number ,
    cfg_device_number            => cfg_device_number ,
    cfg_function_number          => cfg_function_number ,
    cfg_pm_wake                  => cfg_pm_wake ,

    -------------------------------------------------------------------------------------------------------------------
    -- 5. Physical Layer Control and Status (PL) Interface                                                           --
    -------------------------------------------------------------------------------------------------------------------
    pl_directed_link_auton    => pl_directed_link_auton ,
    pl_directed_link_change   => pl_directed_link_change ,
    pl_directed_link_speed    => pl_directed_link_speed ,
    pl_directed_link_width    => pl_directed_link_width ,
    pl_upstream_prefer_deemph => pl_upstream_prefer_deemph ,

    pl_ltssm_state        => open ,
    pl_lane_reversal_mode => pl_lane_reversal_mode ,

    cfg_dsn => cfg_dsn ,

    pl_link_partner_gen2_supported => pl_link_partner_gen2_supported ,
    pl_initial_link_width          => pl_initial_link_width ,

    ---------------------------------------------------------------------
    -- EP Only                                                        --
    ---------------------------------------------------------------------
    pl_received_hot_rst => pl_received_hot_rst ,

    -------------------------------------------------------------------------------------------------------------------
    -- 6. System(SYS) Interface                                                                                      --
    -------------------------------------------------------------------------------------------------------------------
    sys_clk         => sys_clk_c ,
    sys_reset       => sys_reset_c
    );

-- ---------------------------------------------------------------
-- tlp control module
-- ---------------------------------------------------------------
  theTlpControl :
    tlpControl
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

        wb_FIFO_Rst => wb_fifo_rst ,     --  OUT std_logic;

        -------------------
        -- DDR Interface
        DDR_Ready => DDR_Ready ,        --  IN    std_logic;

        DDR_wr_sof   => DDR_wr_sof ,    --  OUT   std_logic;
        DDR_wr_eof   => DDR_wr_eof ,    --  OUT   std_logic;
        DDR_wr_v     => DDR_wr_v ,      --  OUT   std_logic;
        DDR_wr_Shift => DDR_wr_Shift ,  --  OUT   std_logic;
        DDR_wr_Mask  => DDR_wr_Mask ,  --  OUT   std_logic_vector(2-1 downto 0);
        DDR_wr_din   => DDR_wr_din ,  --  OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DDR_wr_full  => DDR_wr_full ,   --  IN    std_logic;

        DDR_rdc_sof   => DDR_rdc_sof ,  --  OUT   std_logic;
        DDR_rdc_eof   => DDR_rdc_eof ,  --  OUT   std_logic;
        DDR_rdc_v     => DDR_rdc_v ,    --  OUT   std_logic;
        DDR_rdc_Shift => DDR_rdc_Shift ,  --  OUT   std_logic;
        DDR_rdc_din   => DDR_rdc_din ,  --  OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DDR_rdc_full  => DDR_rdc_full ,   --  IN    std_logic;

        -- DDR payload FIFO Read Port
        DDR_FIFO_RdEn   => DDR_FIFO_RdEn ,    -- OUT std_logic;
        DDR_FIFO_Empty  => DDR_FIFO_Empty ,   -- IN  std_logic;
        DDR_FIFO_RdQout => DDR_FIFO_RdQout ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        -------------------
        -- Transaction Interface
        user_lnk_up       => user_lnk_up ,
        rx_np_ok          => rx_np_ok ,
        rx_np_req         => rx_np_req ,
        s_axis_tx_tdsc    => s_axis_tx_tdsc ,
        tx_buf_av         => tx_buf_av ,
        s_axis_tx_terrfwd => s_axis_tx_terrfwd ,

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
  --  DDR SDRAM: control module USER LOGIC (2 BRAM Module:
  -- -----------------------------------------------------------------------

  LoopBack_BRAM_Off : if not USE_LOOPBACK_TEST generate

    DDRs_ctrl_module : DDR_Transact
      generic map (
        SIMULATION => SIMULATION,
        DATA_WIDTH => C_DBUS_WIDTH,
        ADDR_WIDTH => DDR_ADDR_WIDTH,
        DDR_UI_DATAWIDTH => DDR_PAYLOAD_WIDTH,
        DDR_DQ_WIDTH => DDR_DQ_WIDTH/2, --!!! Fix for differences between Virtex6 and 7 family devices
        DEVICE_TYPE => "VIRTEX6"
        )
      port map(
        memc_ui_clk    => memc_ui_clk, --: out std_logic;
        memc_cmd_rdy   => memc_cmd_rdy, --: out std_logic;
        memc_cmd_en    => memc_cmd_en, --: in  std_logic;
        memc_cmd_instr => memc_cmd_instr, --: in  std_logic_vector(2 downto 0);
        memc_cmd_addr  => memc_cmd_addr, --: in  std_logic_vector(31 downto 0);
        memc_wr_en     => memc_wr_en, --: in  std_logic;
        memc_wr_end    => memc_wr_end, --: in  std_logic;
        memc_wr_mask   => memc_wr_mask, --: in  std_logic_vector(64/8-1 downto 0);
        memc_wr_data   => memc_wr_data, --: in  std_logic_vector(64-1 downto 0);
        memc_wr_rdy    => memc_wr_rdy, --: out std_logic;
        memc_rd_data   => memc_rd_data, --: out std_logic_vector(64-1 downto 0);
        memc_rd_valid  => memc_rd_valid, --: out std_logic;
        memarb_acc_req => memarb_acc_req, --: in  std_logic;
        memarb_acc_gnt => memarb_acc_gnt, --: out std_logic;
        -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
        DDR_wr_eof   => DDR_wr_eof ,  --  IN    std_logic;
        DDR_wr_v     => DDR_wr_v ,   --  IN    std_logic;
        DDR_wr_Shift => DDR_wr_Shift ,  --  IN    std_logic;
        DDR_wr_Mask  => DDR_wr_Mask ,  --  IN    std_logic_vector(2-1 downto 0);
        DDR_wr_din   => DDR_wr_din ,  --  IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DDR_wr_full  => DDR_wr_full ,  --  OUT   std_logic;

        DDR_rdc_v     => DDR_rdc_v ,  --  IN    std_logic;
        DDR_rdc_Shift => DDR_rdc_Shift ,  --  IN    std_logic;
        DDR_rdc_din   => DDR_rdc_din ,  --  IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DDR_rdc_full  => DDR_rdc_full ,   --  OUT   std_logic;

        -- DDR payload FIFO Read Port
        DDR_FIFO_RdEn   => DDR_FIFO_RdEn ,    -- IN    std_logic;
        DDR_FIFO_Empty  => DDR_FIFO_Empty ,   -- OUT   std_logic;
        DDR_FIFO_RdQout => DDR_FIFO_RdQout ,  -- OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        -- Common interface
        DDR_Ready => DDR_Ready, --  OUT   std_logic;

        -- DDR core User Interface signals
        app_addr            => app_addr,
        app_cmd             => app_cmd,
        app_en              => app_en,
        app_wdf_data        => app_wdf_data,
        app_wdf_end         => app_wdf_end,
        app_wdf_wren        => app_wdf_wren,
        app_wdf_mask        => app_wdf_mask,
        app_rd_data         => app_rd_data,
        app_rd_data_end     => app_rd_data_end,
        app_rd_data_valid   => app_rd_data_valid,
        app_rdy             => app_rdy,
        app_wdf_rdy         => app_wdf_rdy,
        ui_clk              => ddr_ui_clk,
        ui_clk_sync_rst     => ddr_ui_reset,
        init_calib_complete => ddr_calib_done,

        --clocking & reset
        user_clk      => user_clk , --  IN    std_logic;
        user_reset    => user_reset, --  IN    std_logic

        dbg_arb_req_o => dbg_arb_req_o,
        dbg_arb_gnt_o => dbg_arb_gnt_o

        );

  end generate;

  LoopBack_BRAM_On : if USE_LOOPBACK_TEST generate

    DDRs_ctrl_module :
      bram_DDRs_Control_loopback
        generic map (
          C_ASYNFIFO_WIDTH => 72 ,
          P_SIMULATION     => false
          )
        port map(
          -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
          DDR_wr_sof   => DDR_wr_sof ,  --  IN    std_logic;
          DDR_wr_eof   => DDR_wr_eof ,  --  IN    std_logic;
          DDR_wr_v     => DDR_wr_v ,    --  IN    std_logic;
          DDR_wr_Shift => DDR_wr_Shift ,  --  IN    std_logic;
          DDR_wr_Mask  => DDR_wr_Mask ,  --  IN    std_logic_vector(2-1 downto 0);
          DDR_wr_din   => DDR_wr_din ,  --  IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
          DDR_wr_full  => DDR_wr_full ,  --  OUT   std_logic;

          DDR_rdc_sof   => DDR_rdc_sof ,  --  IN    std_logic;
          DDR_rdc_eof   => DDR_rdc_eof ,  --  IN    std_logic;
          DDR_rdc_v     => DDR_rdc_v ,  --  IN    std_logic;
          DDR_rdc_Shift => DDR_rdc_Shift ,  --  IN    std_logic;
          DDR_rdc_din   => DDR_rdc_din ,  --  IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
          DDR_rdc_full  => DDR_rdc_full ,   --  OUT   std_logic;

          -- DDR payload FIFO Read Port
          DDR_FIFO_RdEn   => DDR_FIFO_RdEn ,    -- IN    std_logic;
          DDR_FIFO_Empty  => DDR_FIFO_Empty ,   -- OUT   std_logic;
          DDR_FIFO_RdQout => DDR_FIFO_RdQout ,  -- OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);

          -- Common interface
          DDR_Ready   => DDR_Ready ,    --  OUT   std_logic;
          DDR_Blinker => open ,  --  OUT   std_logic;
          mem_clk     => user_clk ,     --  IN
          user_clk    => user_clk ,     --  IN    std_logic;
          Sim_Zeichen => open ,  --  OUT   std_logic;
          user_reset  => user_reset     --  IN    std_logic
          );

  end generate;

  Wishbone_intf :
    wb_transact
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


  u_ddr_core : ddr_v6
    generic map (
      SIM_BYPASS_INIT_CAL => SIM_BYPASS_INIT_CAL,
      RST_ACT_LOW => 0
    )
    port map (
      -- Memory interface ports
      ddr3_addr     => ddr3_addr,
      ddr3_ba       => ddr3_ba,
      ddr3_cas_n    => ddr3_cas_n,
      ddr3_ck_n     => ddr3_ck_n,
      ddr3_ck_p     => ddr3_ck_p,
      ddr3_cke      => ddr3_cke,
      ddr3_ras_n    => ddr3_ras_n,
      ddr3_reset_n  => ddr3_reset_n,
      ddr3_cs_n     => ddr3_cs_n,
      ddr3_we_n     => ddr3_we_n,
      ddr3_dq       => ddr3_dq,
      ddr3_dqs_n    => ddr3_dqs_n,
      ddr3_dqs_p    => ddr3_dqs_p,
      phy_init_done => ddr_calib_done,
      ddr3_dm       => ddr3_dm,
      ddr3_odt      => ddr3_odt,
      scl           => open,
      sda           => open,
      -- Application interface ports
      app_addr          => app_addr,
      app_cmd           => app_cmd,
      app_en            => app_en,
      app_wdf_data      => app_wdf_data,
      app_wdf_end       => app_wdf_end,
      app_wdf_wren      => app_wdf_wren,
      app_wdf_mask      => app_wdf_mask,
      app_rd_data       => app_rd_data,
      app_rd_data_end   => app_rd_data_end,
      app_rd_data_valid => app_rd_data_valid,
      app_rdy           => app_rdy,
      app_wdf_rdy       => app_wdf_rdy,
      ui_clk            => ddr_ui_clk,
      ui_clk_sync_rst   => ddr_ui_reset,

      -- System Clock Ports
      sys_clk => ddr_sys_clk_i,
      clk_ref => ddr_ref_clk_i,

      sys_rst => ddr_sys_reset_i
    );

  ddr_sys_clk_i   <= ddr_sys_clk_p;
  ddr_ref_clk_i   <= ddr_sys_clk_p;
  ddr_sys_reset_i <= ddr_core_rst;
  memc_ui_rst     <= ddr_ui_reset;
                              
  dbg_app_addr_o           <= "0000" & app_addr;
  dbg_app_cmd_o            <= app_cmd;
  dbg_app_en_o             <= app_en;
  dbg_app_wdf_data_o       <= app_wdf_data;
  dbg_app_wdf_end_o        <= app_wdf_end;
  dbg_app_wdf_wren_o       <= app_wdf_wren;
  dbg_app_wdf_mask_o       <= app_wdf_mask;
  dbg_app_rd_data_o        <= app_rd_data;
  dbg_app_rd_data_end_o    <= app_rd_data_end;
  dbg_app_rd_data_valid_o  <= app_rd_data_valid;
  dbg_app_rdy_o            <= app_rdy;
  dbg_app_wdf_rdy_o        <= app_wdf_rdy;
  dbg_ddr_ui_clk_o         <= ddr_ui_clk;
  dbg_ddr_ui_reset_o       <= ddr_ui_reset;

end Behavioral;
