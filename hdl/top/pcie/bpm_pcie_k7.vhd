----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    09:12:51 01 Feb 2010
-- Design Name:
-- Module Name:    pcieDMA - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
--
-- Revision 1.00 - File Released
--
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.abb64Package.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity bpm_pcie_k7 is
  generic (
    constant pcieLanes : integer := C_NUM_PCIE_LANES;
    PL_FAST_TRAIN      : string  := "FALSE";
    PIPE_SIM_MODE      : string := "FALSE";
    SIMULATION         : string := "FALSE";


    -- *** GENERICs copied from the example project generated with DDR core *** --

    --***************************************************************************
    -- The following parameters refer to width of various ports
    --***************************************************************************
    BANK_WIDTH            : integer := 3;
                                     -- # of memory Bank Address bits.
    CK_WIDTH              : integer := 1;
                                     -- # of CK/CK# outputs to memory.
    COL_WIDTH             : integer := 10;
                                     -- # of memory Column Address bits.
    CS_WIDTH              : integer := 1;
                                     -- # of unique CS outputs to memory.
    nCS_PER_RANK          : integer := 1;
                                     -- # of unique CS outputs per rank for phy
    CKE_WIDTH             : integer := 1;
                                     -- # of CKE outputs to memory.
    DATA_BUF_ADDR_WIDTH   : integer := 5;
    DQ_CNT_WIDTH          : integer := 6;
                                     -- = ceil(log2(DQ_WIDTH))
    DQ_PER_DM             : integer := 8;
    DM_WIDTH              : integer := 8;
                                     -- # of DM (data mask)
    DQ_WIDTH              : integer := 64;
                                     -- # of DQ (data)
    DQS_WIDTH             : integer := 8;
    DQS_CNT_WIDTH         : integer := 3;
                                     -- = ceil(log2(DQS_WIDTH))
    DRAM_WIDTH            : integer := 8;
                                     -- # of DQ per DQS
    ECC                   : string  := "OFF";
    nBANK_MACHS           : integer := 4;
    RANKS                 : integer := 1;
                                     -- # of Ranks.
    ODT_WIDTH             : integer := 1;
                                     -- # of ODT outputs to memory.
    ROW_WIDTH             : integer := 14;
                                     -- # of memory Row Address bits.
    ADDR_WIDTH            : integer := 28;
                                     -- # = RANK_WIDTH + BANK_WIDTH
                                     --     + ROW_WIDTH + COL_WIDTH;
                                     -- Chip Select is always tied to low for
                                     -- single rank devices
    USE_CS_PORT          : integer := 1;
                                     -- # = 1, When Chip Select (CS#) output is enabled
                                     --   = 0, When Chip Select (CS#) output is disabled
                                     -- If CS_N disabled, user must connect
                                     -- DRAM CS_N input(s) to ground
    USE_DM_PORT           : integer := 1;
                                     -- # = 1, When Data Mask option is enabled
                                     --   = 0, When Data Mask option is disbaled
                                     -- When Data Mask option is disabled in
                                     -- MIG Controller Options page, the logic
                                     -- related to Data Mask should not get
                                     -- synthesized
    USE_ODT_PORT          : integer := 1;
                                     -- # = 1, When ODT output is enabled
                                     --   = 0, When ODT output is disabled
    PHY_CONTROL_MASTER_BANK : integer := 1;
                                     -- The bank index where master PHY_CONTROL resides,
                                     -- equal to the PLL residing bank
    MEM_DENSITY             : string  := "1GB";
                                     -- Indicates the density of the Memory part
                                     -- Added for the sake of Vivado simulations
    MEM_SPEEDGRADE          : string  := "125";
                                     -- Indicates the Speed grade of Memory Part
                                     -- Added for the sake of Vivado simulations
    MEM_DEVICE_WIDTH        : integer := 8;
                                     -- Indicates the device width of the Memory Part
                                     -- Added for the sake of Vivado simulations

    --***************************************************************************
    -- The following parameters are mode register settings
    --***************************************************************************
    AL                    : string  := "0";
                                     -- DDR3 SDRAM:
                                     -- Additive Latency (Mode Register 1).
                                     -- # = "0", "CL-1", "CL-2".
                                     -- DDR2 SDRAM:
                                     -- Additive Latency (Extended Mode Register).
    nAL                   : integer := 0;
                                     -- # Additive Latency in number of clock
                                     -- cycles.
    BURST_MODE            : string  := "8";
                                     -- DDR3 SDRAM:
                                     -- Burst Length (Mode Register 0).
                                     -- # = "8", "4", "OTF".
                                     -- DDR2 SDRAM:
                                     -- Burst Length (Mode Register).
                                     -- # = "8", "4".
    BURST_TYPE            : string  := "SEQ";
                                     -- DDR3 SDRAM: Burst Type (Mode Register 0).
                                     -- DDR2 SDRAM: Burst Type (Mode Register).
                                     -- # = "SEQ" - (Sequential),
                                     --   = "INT" - (Interleaved).
    CL                    : integer := 11;
                                     -- in number of clock cycles
                                     -- DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     -- DDR2 SDRAM: CAS Latency (Mode Register).
    CWL                   : integer := 8;
                                     -- in number of clock cycles
                                     -- DDR3 SDRAM: CAS Write Latency (Mode Register 2).
                                     -- DDR2 SDRAM: Can be ignored
    OUTPUT_DRV            : string  := "HIGH";
                                     -- Output Driver Impedance Control (Mode Register 1).
                                     -- # = "HIGH" - RZQ/7,
                                     --   = "LOW" - RZQ/6.
    RTT_NOM               : string  := "40";
                                     -- RTT_NOM (ODT) (Mode Register 1).
                                     --   = "120" - RZQ/2,
                                     --   = "60"  - RZQ/4,
                                     --   = "40"  - RZQ/6.
    RTT_WR                : string  := "OFF";
                                     -- RTT_WR (ODT) (Mode Register 2).
                                     -- # = "OFF" - Dynamic ODT off,
                                     --   = "120" - RZQ/2,
                                     --   = "60"  - RZQ/4,
    ADDR_CMD_MODE         : string  := "1T" ;
                                     -- # = "1T", "2T".
    REG_CTRL              : string  := "OFF";
                                     -- # = "ON" - RDIMMs,
                                     --   = "OFF" - Components, SODIMMs, UDIMMs.
    CA_MIRROR             : string  := "OFF";
                                     -- C/A mirror opt for DDR3 dual rank

    --***************************************************************************
    -- The following parameters are multiplier and divisor factors for PLLE2.
    -- Based on the selected design frequency these parameters vary.
    --***************************************************************************
    CLKIN_PERIOD          : integer := 5000;
                                     -- Input Clock Period
    CLKFBOUT_MULT         : integer := 8;
                                     -- write PLL VCO multiplier
    DIVCLK_DIVIDE         : integer := 1;
                                     -- write PLL VCO divisor
    CLKOUT0_PHASE         : real    := 337.5;
                                     -- Phase for PLL output clock (CLKOUT0)
    CLKOUT0_DIVIDE        : integer := 2;
                                     -- VCO output divisor for PLL output clock (CLKOUT0)
    CLKOUT1_DIVIDE        : integer := 2;
                                     -- VCO output divisor for PLL output clock (CLKOUT1)
    CLKOUT2_DIVIDE        : integer := 32;
                                     -- VCO output divisor for PLL output clock (CLKOUT2)
    CLKOUT3_DIVIDE        : integer := 8;
                                     -- VCO output divisor for PLL output clock (CLKOUT3)

    --***************************************************************************
    -- Memory Timing Parameters. These parameters varies based on the selected
    -- memory part.
    --***************************************************************************
    tCKE                  : integer := 5000;
                                     -- memory tCKE paramter in pS
    tFAW                  : integer := 30000;
                                     -- memory tRAW paramter in pS.
    tRAS                  : integer := 35000;
                                     -- memory tRAS paramter in pS.
    tRCD                  : integer := 13125;
                                     -- memory tRCD paramter in pS.
    tREFI                 : integer := 7800000;
                                     -- memory tREFI paramter in pS.
    tRFC                  : integer := 110000;
                                     -- memory tRFC paramter in pS.
    tRP                   : integer := 13125;
                                     -- memory tRP paramter in pS.
    tRRD                  : integer := 6000;
                                     -- memory tRRD paramter in pS.
    tRTP                  : integer := 7500;
                                     -- memory tRTP paramter in pS.
    tWTR                  : integer := 7500;
                                     -- memory tWTR paramter in pS.
    tZQI                  : integer := 128000000;
                                     -- memory tZQI paramter in nS.
    tZQCS                 : integer := 64;
                                     -- memory tZQCS paramter in clock cycles.

    --***************************************************************************
    -- Simulation parameters
    --***************************************************************************
    SIM_BYPASS_INIT_CAL   : string  := "FAST";
                                     -- # = "OFF" -  Complete memory init &
                                     --              calibration sequence
                                     -- # = "SKIP" - Not supported
                                     -- # = "FAST" - Complete memory init & use
                                     --              abbreviated calib sequence
    --already declared
    --SIMULATION            : string  := "FALSE";
                                     -- Should be TRUE during design simulations and
                                     -- FALSE during implementations

    --***************************************************************************
    -- The following parameters varies based on the pin out entered in MIG GUI.
    -- Do not change any of these parameters directly by editing the RTL.
    -- Any changes required should be done through GUI and the design regenerated.
    --***************************************************************************
    BYTE_LANES_B0         : std_logic_vector(3 downto 0) := "1111";
                                     -- Byte lanes used in an IO column.
    BYTE_LANES_B1         : std_logic_vector(3 downto 0) := "0111";
                                     -- Byte lanes used in an IO column.
    BYTE_LANES_B2         : std_logic_vector(3 downto 0) := "1111";
                                     -- Byte lanes used in an IO column.
    BYTE_LANES_B3         : std_logic_vector(3 downto 0) := "0000";
                                     -- Byte lanes used in an IO column.
    BYTE_LANES_B4         : std_logic_vector(3 downto 0) := "0000";
                                     -- Byte lanes used in an IO column.
    DATA_CTL_B0           : std_logic_vector(3 downto 0) := "1111";
                                     -- Indicates Byte lane is data byte lane
                                     -- or control Byte lane. '1' in a bit
                                     -- position indicates a data byte lane and
                                     -- a '0' indicates a control byte lane
    DATA_CTL_B1           : std_logic_vector(3 downto 0) := "0000";
                                     -- Indicates Byte lane is data byte lane
                                     -- or control Byte lane. '1' in a bit
                                     -- position indicates a data byte lane and
                                     -- a '0' indicates a control byte lane
    DATA_CTL_B2           : std_logic_vector(3 downto 0) := "1111";
                                     -- Indicates Byte lane is data byte lane
                                     -- or control Byte lane. '1' in a bit
                                     -- position indicates a data byte lane and
                                     -- a '0' indicates a control byte lane
    DATA_CTL_B3           : std_logic_vector(3 downto 0) := "0000";
                                     -- Indicates Byte lane is data byte lane
                                     -- or control Byte lane. '1' in a bit
                                     -- position indicates a data byte lane and
                                     -- a '0' indicates a control byte lane
    DATA_CTL_B4           : std_logic_vector(3 downto 0) := "0000";
                                     -- Indicates Byte lane is data byte lane
                                     -- or control Byte lane. '1' in a bit
                                     -- position indicates a data byte lane and
                                     -- a '0' indicates a control byte lane
    PHY_0_BITLANES        : std_logic_vector(47 downto 0) := X"3FE3FE3FE2FF";
    PHY_1_BITLANES        : std_logic_vector(47 downto 0) := X"000CB0473FFF";
    PHY_2_BITLANES        : std_logic_vector(47 downto 0) := X"3FE3FE3FE2FF";

    -- control/address/data pin mapping parameters
    CK_BYTE_MAP
     : std_logic_vector(143 downto 0) := X"000000000000000000000000000000000011";
    ADDR_MAP
     : std_logic_vector(191 downto 0) := X"00000011111010910810710610B10A105104103102101100";
    BANK_MAP   : std_logic_vector(35 downto 0) := X"11A115114";
    CAS_MAP    : std_logic_vector(11 downto 0) := X"12A";
    CKE_ODT_BYTE_MAP : std_logic_vector(7 downto 0) := X"00";
    CKE_MAP    : std_logic_vector(95 downto 0) := X"000000000000000000000116";
    ODT_MAP    : std_logic_vector(95 downto 0) := X"000000000000000000000127";
    CS_MAP     : std_logic_vector(119 downto 0) := X"00000000000000000000000000012B";
    PARITY_MAP : std_logic_vector(11 downto 0) := X"000";
    RAS_MAP    : std_logic_vector(11 downto 0) := X"125";
    WE_MAP     : std_logic_vector(11 downto 0) := X"124";
    DQS_BYTE_MAP
     : std_logic_vector(143 downto 0) := X"000000000000000000000302010023222120";
    DATA0_MAP  : std_logic_vector(95 downto 0) := X"200209206203204205202207";
    DATA1_MAP  : std_logic_vector(95 downto 0) := X"219218214215217212216213";
    DATA2_MAP  : std_logic_vector(95 downto 0) := X"225224229226223222228227";
    DATA3_MAP  : std_logic_vector(95 downto 0) := X"238236234233235237232239";
    DATA4_MAP  : std_logic_vector(95 downto 0) := X"005003000009007006004002";
    DATA5_MAP  : std_logic_vector(95 downto 0) := X"013012018019015014017016";
    DATA6_MAP  : std_logic_vector(95 downto 0) := X"023027022029024025028026";
    DATA7_MAP  : std_logic_vector(95 downto 0) := X"039037033032035034038036";
    DATA8_MAP  : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA9_MAP  : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA10_MAP : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA11_MAP : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA12_MAP : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA13_MAP : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA14_MAP : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA15_MAP : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA16_MAP : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    DATA17_MAP : std_logic_vector(95 downto 0) := X"000000000000000000000000";
    MASK0_MAP  : std_logic_vector(107 downto 0) := X"000031021011001231221211201";
    MASK1_MAP  : std_logic_vector(107 downto 0) := X"000000000000000000000000000";

    SLOT_0_CONFIG         : std_logic_vector(7 downto 0) := "00000001";
                                     -- Mapping of Ranks.
    SLOT_1_CONFIG         : std_logic_vector(7 downto 0) := "00000000";
                                     -- Mapping of Ranks.
    MEM_ADDR_ORDER
     : string  := "BANK_ROW_COLUMN";

    --***************************************************************************
    -- IODELAY and PHY related parameters
    --***************************************************************************
    IODELAY_HP_MODE       : string  := "ON";
                                     -- to phy_top
    IBUF_LPWR_MODE        : string  := "OFF";
                                     -- to phy_top
    DATA_IO_IDLE_PWRDWN   : string  := "ON";
                                     -- # = "ON", "OFF"
    BANK_TYPE             : string  := "HP_IO";
                                     -- # = "HP_IO", "HPL_IO", "HR_IO", "HRL_IO"
    DATA_IO_PRIM_TYPE     : string  := "HP_LP";
                                     -- # = "HP_LP", "HR_LP", "DEFAULT"
    CKE_ODT_AUX           : string  := "FALSE";
    USER_REFRESH          : string  := "OFF";
    WRLVL                 : string  := "ON";
                                     -- # = "ON" - DDR3 SDRAM
                                     --   = "OFF" - DDR2 SDRAM.
    ORDERING              : string  := "NORM";
                                     -- # = "NORM", "STRICT", "RELAXED".
    CALIB_ROW_ADD         : std_logic_vector(15 downto 0) := X"0000";
                                     -- Calibration row address will be used for
                                     -- calibration read and write operations
    CALIB_COL_ADD         : std_logic_vector(11 downto 0) := X"000";
                                     -- Calibration column address will be used for
                                     -- calibration read and write operations
    CALIB_BA_ADD          : std_logic_vector(2 downto 0) := "000";
                                     -- Calibration bank address will be used for
                                     -- calibration read and write operations
    TCQ                   : integer := 100;
    IODELAY_GRP           : string  := "IODELAY_MIG";
                                     -- It is associated to a set of IODELAYs with
                                     -- an IDELAYCTRL that have same IODELAY CONTROLLER
                                     -- clock frequency.
    SYSCLK_TYPE           : string  := "DIFFERENTIAL";
                                     -- System clock type DIFFERENTIAL, SINGLE_ENDED,
                                     -- NO_BUFFER
    REFCLK_TYPE           : string  := "USE_SYSTEM_CLOCK";
                                     -- Reference clock type DIFFERENTIAL, SINGLE_ENDED
                                     -- NO_BUFFER, USE_SYSTEM_CLOCK

    DRAM_TYPE             : string  := "DDR3";
    CAL_WIDTH             : string  := "HALF";
    STARVE_LIMIT          : integer := 2;
                                     -- # = 2,3,4.

    --***************************************************************************
    -- Referece clock frequency parameters
    --***************************************************************************
    REFCLK_FREQ           : real    := 200.0;
                                     -- IODELAYCTRL reference clock frequency
    DIFF_TERM_REFCLK      : string  := "TRUE";
                                     -- Differential Termination for idelay
                                     -- reference clock input pins
    --***************************************************************************
    -- System clock frequency parameters
    --***************************************************************************
    tCK                   : integer := 1250;
                                     -- memory tCK paramter.
                                     -- # = Clock Period in pS.
    nCK_PER_CLK           : integer := 4;
                                     -- # of memory CKs per fabric CLK
    DIFF_TERM_SYSCLK      : string  := "FALSE";
                                     -- Differential Termination for System
                                     -- clock input pins

    --***************************************************************************
    -- Debug parameters
    --***************************************************************************
    DEBUG_PORT            : string  := "OFF";
                                     -- # = "ON" Enable debug signals/controls.
                                     --   = "OFF" Disable debug signals/controls.

    --***************************************************************************
    -- Temparature monitor parameter
    --***************************************************************************
    TEMP_MON_CONTROL         : string  := "INTERNAL";
                                     -- # = "INTERNAL", "EXTERNAL"

    RST_ACT_LOW           : integer := 1
                                     -- =1 for active low reset,
                                     -- =0 for active high.
    );
  port (
    --DDR3 memory pins
    ddr3_dq      : inout std_logic_vector(DQ_WIDTH-1 downto 0);
    ddr3_dqs_p   : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr3_dqs_n   : inout std_logic_vector(DQS_WIDTH-1 downto 0);
    ddr3_addr    : out   std_logic_vector(ROW_WIDTH-1 downto 0);
    ddr3_ba      : out   std_logic_vector(BANK_WIDTH-1 downto 0);
    ddr3_ras_n   : out   std_logic;
    ddr3_cas_n   : out   std_logic;
    ddr3_we_n    : out   std_logic;
    ddr3_reset_n : out   std_logic;
    ddr3_ck_p    : out   std_logic_vector(CK_WIDTH-1 downto 0);
    ddr3_ck_n    : out   std_logic_vector(CK_WIDTH-1 downto 0);
    ddr3_cke     : out   std_logic_vector(CKE_WIDTH-1 downto 0);
    ddr3_cs_n    : out   std_logic_vector((CS_WIDTH*nCS_PER_RANK)-1 downto 0);
    ddr3_dm      : out   std_logic_vector(DM_WIDTH-1 downto 0);
    ddr3_odt     : out   std_logic_vector(ODT_WIDTH-1 downto 0);
    -- PCIe transceivers
    pci_exp_rxp : in  std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_rxn : in  std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_txp : out std_logic_vector(pcieLanes - 1 downto 0);
    pci_exp_txn : out std_logic_vector(pcieLanes - 1 downto 0);
    -- Necessity signals
    ddr_sys_clk_p : in std_logic;
    ddr_sys_clk_n : in std_logic;
    sys_clk_p     : in std_logic;         --100 MHz PCIe Clock
    sys_clk_n     : in std_logic;         --100 MHz PCIe Clock
    sys_rst_n     : in std_logic          --Reset
    );
end entity bpm_pcie_k7;

architecture Behavioral of bpm_pcie_k7 is
  -------------------------------------------------------
  -------- Constants & functions helpful in DDR core instatiation
  -------------------------------------------------------
  -- clogb2 function - ceiling of log base 2
  function clogb2 (size : integer) return integer is
    variable base : integer := 1;
    variable inp : integer := 0;
  begin
    inp := size - 1;
    while (inp > 1) loop
      inp := inp/2 ;
      base := base + 1;
    end loop;
    return base;
  end function;

  constant RANK_WIDTH : integer := clogb2(RANKS);

  function XWIDTH return integer is
  begin
    if(CS_WIDTH = 1) then
      return 0;
    else
      return RANK_WIDTH;
    end if;
  end function;

  constant DATA_WIDTH            : integer := C_DBUS_WIDTH;
  constant PAYLOAD_WIDTH         : integer := C_DBUS_WIDTH;
  constant DATA_BUF_OFFSET_WIDTH : integer := 1;
  constant CMD_PIPE_PLUS1        : string  := "ON";
                                     -- add pipeline stage between MC and PHY
  constant ECC_WIDTH         : integer := 0;
  constant ECC_TEST          : string  := "OFF";
  constant MC_ERR_ADDR_WIDTH : integer := XWIDTH + BANK_WIDTH + ROW_WIDTH
                                          + COL_WIDTH + DATA_BUF_OFFSET_WIDTH;
  constant tPRDI : integer := 1000000;
                                     -- memory tPRDI paramter in pS.


  component pcie_core
    generic (
      PL_FAST_TRAIN   : string := "FALSE";
      PCIE_EXT_CLK    : string := "FALSE";
      UPSTREAM_FACING : string := "TRUE";
      PIPE_SIM_MODE   : string := "FALSE"
      );
    port (
      -------------------------------------------------------------------------------------------------------------------
      -- 1. PCI Express (pci_exp) Interface                                                                            --
      -------------------------------------------------------------------------------------------------------------------
      pci_exp_txp : out std_logic_vector(0 downto 0);
      pci_exp_txn : out std_logic_vector(0 downto 0);
      pci_exp_rxp : in  std_logic_vector(0 downto 0);
      pci_exp_rxn : in  std_logic_vector(0 downto 0);

      -------------------------------------------------------------------------------------------------------------------
      -- 2. Clocking Interface                                                                                         --
      -------------------------------------------------------------------------------------------------------------------
      PIPE_PCLK_IN      : in std_logic;
      PIPE_RXUSRCLK_IN  : in std_logic;
      PIPE_RXOUTCLK_IN  : in std_logic_vector(0 downto 0);
      PIPE_DCLK_IN      : in std_logic;
      PIPE_USERCLK1_IN  : in std_logic;
      PIPE_USERCLK2_IN  : in std_logic;
      PIPE_OOBCLK_IN    : in std_logic;
      PIPE_MMCM_LOCK_IN : in std_logic;

      PIPE_TXOUTCLK_OUT : out std_logic;
      PIPE_RXOUTCLK_OUT : out std_logic_vector(0 downto 0);
      PIPE_PCLK_SEL_OUT : out std_logic_vector(0 downto 0);
      PIPE_GEN3_OUT     : out std_logic;

      -------------------------------------------------------------------------------------------------------------------
      -- 3. AXI-S Interface                                                                                            --
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
      rx_np_req        : in  std_logic;

      -- Flow Control
      fc_cpld : out std_logic_vector(11 downto 0);
      fc_cplh : out std_logic_vector(7 downto 0);
      fc_npd  : out std_logic_vector(11 downto 0);
      fc_nph  : out std_logic_vector(7 downto 0);
      fc_pd   : out std_logic_vector(11 downto 0);
      fc_ph   : out std_logic_vector(7 downto 0);
      fc_sel  : in  std_logic_vector(2 downto 0);

      -------------------------------------------------------------------------------------------------------------------
      -- 4. Configuration (CFG) Interface                                                                              --
      -------------------------------------------------------------------------------------------------------------------
      ---------------------------------------------------------------------
      -- EP and RP                                                      --
      ---------------------------------------------------------------------
      cfg_mgmt_do         : out std_logic_vector (31 downto 0);
      cfg_mgmt_rd_wr_done : out std_logic;

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
      cfg_received_func_lvl_rst : out std_logic;

      -- Management Interface
      cfg_mgmt_di          : in std_logic_vector (31 downto 0);
      cfg_mgmt_byte_en     : in std_logic_vector (3 downto 0);
      cfg_mgmt_dwaddr      : in std_logic_vector (9 downto 0);
      cfg_mgmt_wr_en       : in std_logic;
      cfg_mgmt_rd_en       : in std_logic;
      cfg_mgmt_wr_readonly : in std_logic;

      -- Error Reporting Interface
      cfg_err_ecrc                  : in  std_logic;
      cfg_err_ur                    : in  std_logic;
      cfg_err_cpl_timeout           : in  std_logic;
      cfg_err_cpl_unexpect          : in  std_logic;
      cfg_err_cpl_abort             : in  std_logic;
      cfg_err_posted                : in  std_logic;
      cfg_err_cor                   : in  std_logic;
      cfg_err_atomic_egress_blocked : in  std_logic;
      cfg_err_internal_cor          : in  std_logic;
      cfg_err_malformed             : in  std_logic;
      cfg_err_mc_blocked            : in  std_logic;
      cfg_err_poisoned              : in  std_logic;
      cfg_err_norecovery            : in  std_logic;
      cfg_err_tlp_cpl_header        : in  std_logic_vector(47 downto 0);
      cfg_err_cpl_rdy               : out std_logic;
      cfg_err_locked                : in  std_logic;
      cfg_err_acs                   : in  std_logic;
      cfg_err_internal_uncor        : in  std_logic;
      cfg_trn_pending               : in  std_logic;
      cfg_pm_halt_aspm_l0s          : in  std_logic;
      cfg_pm_halt_aspm_l1           : in  std_logic;
      cfg_pm_force_state_en         : in  std_logic;
      cfg_pm_force_state            :     std_logic_vector(1 downto 0);
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
      cfg_interrupt_stat           : in  std_logic;
      cfg_pciecap_interrupt_msgnum : in  std_logic_vector(4 downto 0);
      cfg_to_turnoff               : out std_logic;
      cfg_turnoff_ok               : in  std_logic;
      cfg_bus_number               : out std_logic_vector(7 downto 0);
      cfg_device_number            : out std_logic_vector(4 downto 0);
      cfg_function_number          : out std_logic_vector(2 downto 0);
      cfg_pm_wake                  : in  std_logic;

      ---------------------------------------------------------------------
      -- RP Only                                                        --
      ---------------------------------------------------------------------
      cfg_pm_send_pme_to     : in std_logic;
      cfg_ds_bus_number      : in std_logic_vector(7 downto 0);
      cfg_ds_device_number   : in std_logic_vector(4 downto 0);
      cfg_ds_function_number : in std_logic_vector(2 downto 0);

      cfg_mgmt_wr_rw1c_as_rw : in  std_logic;
      cfg_msg_received       : out std_logic;
      cfg_msg_data           : out std_logic_vector(15 downto 0);

      cfg_bridge_serr_en                         : out std_logic;
      cfg_slot_control_electromech_il_ctl_pulse  : out std_logic;
      cfg_root_control_syserr_corr_err_en        : out std_logic;
      cfg_root_control_syserr_non_fatal_err_en   : out std_logic;
      cfg_root_control_syserr_fatal_err_en       : out std_logic;
      cfg_root_control_pme_int_en                : out std_logic;
      cfg_aer_rooterr_corr_err_reporting_en      : out std_logic;
      cfg_aer_rooterr_non_fatal_err_reporting_en : out std_logic;
      cfg_aer_rooterr_fatal_err_reporting_en     : out std_logic;
      cfg_aer_rooterr_corr_err_received          : out std_logic;
      cfg_aer_rooterr_non_fatal_err_received     : out std_logic;
      cfg_aer_rooterr_fatal_err_received         : out std_logic;

      cfg_msg_received_err_cor           : out std_logic;
      cfg_msg_received_err_non_fatal     : out std_logic;
      cfg_msg_received_err_fatal         : out std_logic;
      cfg_msg_received_pm_as_nak         : out std_logic;
      cfg_msg_received_pm_pme            : out std_logic;
      cfg_msg_received_pme_to_ack        : out std_logic;
      cfg_msg_received_assert_int_a      : out std_logic;
      cfg_msg_received_assert_int_b      : out std_logic;
      cfg_msg_received_assert_int_c      : out std_logic;
      cfg_msg_received_assert_int_d      : out std_logic;
      cfg_msg_received_deassert_int_a    : out std_logic;
      cfg_msg_received_deassert_int_b    : out std_logic;
      cfg_msg_received_deassert_int_c    : out std_logic;
      cfg_msg_received_deassert_int_d    : out std_logic;
      cfg_msg_received_setslotpowerlimit : out std_logic;

      -------------------------------------------------------------------------------------------------------------------
      -- 5. Physical Layer Control and Status (PL) Interface                                                           --
      -------------------------------------------------------------------------------------------------------------------
      pl_directed_link_change   : in std_logic_vector(1 downto 0);
      pl_directed_link_width    : in std_logic_vector(1 downto 0);
      pl_directed_link_speed    : in std_logic;
      pl_directed_link_auton    : in std_logic;
      pl_upstream_prefer_deemph : in std_logic;

      pl_sel_lnk_rate       : out std_logic;
      pl_sel_lnk_width      : out std_logic_vector(1 downto 0);
      pl_ltssm_state        : out std_logic_vector(5 downto 0);
      pl_lane_reversal_mode : out std_logic_vector(1 downto 0);

      pl_phy_lnk_up  : out std_logic;
      pl_tx_pm_state : out std_logic_vector(2 downto 0);
      pl_rx_pm_state : out std_logic_vector(1 downto 0);

      pl_link_upcfg_cap              : out std_logic;
      pl_link_gen2_cap               : out std_logic;
      pl_link_partner_gen2_supported : out std_logic;
      pl_initial_link_width          : out std_logic_vector(2 downto 0);

      pl_directed_change_done : out std_logic;

      ---------------------------------------------------------------------
      -- EP Only                                                        --
      ---------------------------------------------------------------------
      pl_received_hot_rst         : out std_logic;
      ---------------------------------------------------------------------
      -- RP Only                                                        --
      ---------------------------------------------------------------------
      pl_transmit_hot_rst         : in  std_logic;
      pl_downstream_deemph_source : in  std_logic;
      -------------------------------------------------------------------------------------------------------------------
      -- 6. AER interface                                                                                              --
      -------------------------------------------------------------------------------------------------------------------
      cfg_err_aer_headerlog       : in  std_logic_vector(127 downto 0);
      cfg_aer_interrupt_msgnum    : in  std_logic_vector(4 downto 0);
      cfg_err_aer_headerlog_set   : out std_logic;
      cfg_aer_ecrc_check_en       : out std_logic;
      cfg_aer_ecrc_gen_en         : out std_logic;
      -------------------------------------------------------------------------------------------------------------------
      -- 7. VC interface                                                                                               --
      -------------------------------------------------------------------------------------------------------------------
      cfg_vc_tcvc_map             : out std_logic_vector(6 downto 0);

      -------------------------------------------------------------------------------------------------------------------
      -- 8. System(SYS) Interface                                                                                      --
      -------------------------------------------------------------------------------------------------------------------
      sys_clk   : in std_logic;
      sys_rst_n : in std_logic);
  end component;

  component ddr_core
    generic(
      BANK_WIDTH              : integer;
      CK_WIDTH                : integer;
      COL_WIDTH               : integer;
      CS_WIDTH                : integer;
      nCS_PER_RANK            : integer;
      CKE_WIDTH               : integer;
      DATA_BUF_ADDR_WIDTH     : integer;
      DQ_CNT_WIDTH            : integer;
      DQ_PER_DM               : integer;
      DM_WIDTH                : integer;
      DQ_WIDTH                : integer;
      DQS_WIDTH               : integer;
      DQS_CNT_WIDTH           : integer;
      DRAM_WIDTH              : integer;
      ECC                     : string;
      DATA_WIDTH              : integer;
      ECC_TEST                : string;
      PAYLOAD_WIDTH           : integer;
      ECC_WIDTH               : integer;
      MC_ERR_ADDR_WIDTH       : integer;
      nBANK_MACHS             : integer;
      RANKS                   : integer;
      ODT_WIDTH               : integer;
      ROW_WIDTH               : integer;
      ADDR_WIDTH              : integer;
      USE_CS_PORT             : integer;
      USE_DM_PORT             : integer;
      USE_ODT_PORT            : integer;
      PHY_CONTROL_MASTER_BANK : integer;
      AL                      : string;
      nAL                     : integer;
      BURST_MODE              : string;
      BURST_TYPE              : string;
      CL                      : integer;
      CWL                     : integer;
      OUTPUT_DRV              : string;
      RTT_NOM                 : string;
      RTT_WR                  : string;
      ADDR_CMD_MODE           : string;
      REG_CTRL                : string;
      CA_MIRROR               : string;
      CLKIN_PERIOD            : integer;
      CLKFBOUT_MULT           : integer;
      DIVCLK_DIVIDE           : integer;
      CLKOUT0_PHASE           : real;
      CLKOUT0_DIVIDE          : integer;
      CLKOUT1_DIVIDE          : integer;
      CLKOUT2_DIVIDE          : integer;
      CLKOUT3_DIVIDE          : integer;
      tCKE                    : integer;
      tFAW                    : integer;
      tRAS                    : integer;
      tRCD                    : integer;
      tREFI                   : integer;
      tRFC                    : integer;
      tRP                     : integer;
      tRRD                    : integer;
      tRTP                    : integer;
      tWTR                    : integer;
      tZQI                    : integer;
      tZQCS                   : integer;
      tPRDI                   : integer;
      SIM_BYPASS_INIT_CAL     : string;
      SIMULATION              : string;
      BYTE_LANES_B0           : std_logic_vector(3 downto 0);
      BYTE_LANES_B1           : std_logic_vector(3 downto 0);
      BYTE_LANES_B2           : std_logic_vector(3 downto 0);
      BYTE_LANES_B3           : std_logic_vector(3 downto 0);
      BYTE_LANES_B4           : std_logic_vector(3 downto 0);
      DATA_CTL_B0             : std_logic_vector(3 downto 0);
      DATA_CTL_B1             : std_logic_vector(3 downto 0);
      DATA_CTL_B2             : std_logic_vector(3 downto 0);
      DATA_CTL_B3             : std_logic_vector(3 downto 0);
      DATA_CTL_B4             : std_logic_vector(3 downto 0);
      PHY_0_BITLANES          : std_logic_vector(47 downto 0);
      PHY_1_BITLANES          : std_logic_vector(47 downto 0);
      PHY_2_BITLANES          : std_logic_vector(47 downto 0);
      CK_BYTE_MAP             : std_logic_vector(143 downto 0);
      ADDR_MAP                : std_logic_vector(191 downto 0);
      BANK_MAP                : std_logic_vector(35 downto 0);
      CAS_MAP                 : std_logic_vector(11 downto 0);
      CKE_ODT_BYTE_MAP        : std_logic_vector(7 downto 0);
      CKE_MAP                 : std_logic_vector(95 downto 0);
      ODT_MAP                 : std_logic_vector(95 downto 0);
      CS_MAP                  : std_logic_vector(119 downto 0);
      PARITY_MAP              : std_logic_vector(11 downto 0);
      RAS_MAP                 : std_logic_vector(11 downto 0);
      WE_MAP                  : std_logic_vector(11 downto 0);
      DQS_BYTE_MAP            : std_logic_vector(143 downto 0);
      DATA0_MAP               : std_logic_vector(95 downto 0);
      DATA1_MAP               : std_logic_vector(95 downto 0);
      DATA2_MAP               : std_logic_vector(95 downto 0);
      DATA3_MAP               : std_logic_vector(95 downto 0);
      DATA4_MAP               : std_logic_vector(95 downto 0);
      DATA5_MAP               : std_logic_vector(95 downto 0);
      DATA6_MAP               : std_logic_vector(95 downto 0);
      DATA7_MAP               : std_logic_vector(95 downto 0);
      DATA8_MAP               : std_logic_vector(95 downto 0);
      DATA9_MAP               : std_logic_vector(95 downto 0);
      DATA10_MAP              : std_logic_vector(95 downto 0);
      DATA11_MAP              : std_logic_vector(95 downto 0);
      DATA12_MAP              : std_logic_vector(95 downto 0);
      DATA13_MAP              : std_logic_vector(95 downto 0);
      DATA14_MAP              : std_logic_vector(95 downto 0);
      DATA15_MAP              : std_logic_vector(95 downto 0);
      DATA16_MAP              : std_logic_vector(95 downto 0);
      DATA17_MAP              : std_logic_vector(95 downto 0);
      MASK0_MAP               : std_logic_vector(107 downto 0);
      MASK1_MAP               : std_logic_vector(107 downto 0);
      SLOT_0_CONFIG           : std_logic_vector(7 downto 0);
      SLOT_1_CONFIG           : std_logic_vector(7 downto 0);
      MEM_ADDR_ORDER          : string;
      IODELAY_HP_MODE         : string;
      IBUF_LPWR_MODE          : string;
      DATA_IO_IDLE_PWRDWN     : string;
      BANK_TYPE               : string;
      DATA_IO_PRIM_TYPE       : string;
      CKE_ODT_AUX             : string;
      USER_REFRESH            : string;
      WRLVL                   : string;
      ORDERING                : string;
      CALIB_ROW_ADD           : std_logic_vector(15 downto 0);
      CALIB_COL_ADD           : std_logic_vector(11 downto 0);
      CALIB_BA_ADD            : std_logic_vector(2 downto 0);
      TCQ                     : integer;
      CMD_PIPE_PLUS1          : string;
      tCK                     : integer;
      nCK_PER_CLK             : integer;
      DIFF_TERM_SYSCLK        : string;
      DEBUG_PORT              : string;
      TEMP_MON_CONTROL        : string;


      IODELAY_GRP      : string;
      SYSCLK_TYPE      : string;
      REFCLK_TYPE      : string;
      REFCLK_FREQ      : real;
      DIFF_TERM_REFCLK : string;

      DRAM_TYPE    : string;
      CAL_WIDTH    : string;
      STARVE_LIMIT : integer;

      RST_ACT_LOW : integer
      );
    port(
      ddr3_dq      : inout std_logic_vector(DQ_WIDTH-1 downto 0);
      ddr3_dqs_p   : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr3_dqs_n   : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr3_addr    : out   std_logic_vector(ROW_WIDTH-1 downto 0);
      ddr3_ba      : out   std_logic_vector(BANK_WIDTH-1 downto 0);
      ddr3_ras_n   : out   std_logic;
      ddr3_cas_n   : out   std_logic;
      ddr3_we_n    : out   std_logic;
      ddr3_reset_n : out   std_logic;
      ddr3_ck_p    : out   std_logic_vector(CK_WIDTH-1 downto 0);
      ddr3_ck_n    : out   std_logic_vector(CK_WIDTH-1 downto 0);
      ddr3_cke     : out   std_logic_vector(CKE_WIDTH-1 downto 0);
      ddr3_cs_n    : out   std_logic_vector((CS_WIDTH*nCS_PER_RANK)-1 downto 0);
      ddr3_dm      : out   std_logic_vector(DM_WIDTH-1 downto 0);
      ddr3_odt     : out   std_logic_vector(ODT_WIDTH-1 downto 0);

      app_addr            : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      app_cmd             : in  std_logic_vector(2 downto 0);
      app_en              : in  std_logic;
      app_wdf_data        : in  std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
      app_wdf_end         : in  std_logic;
      app_wdf_mask        : in  std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)/8-1 downto 0);
      app_wdf_wren        : in  std_logic;
      app_rd_data         : out std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
      app_rd_data_end     : out std_logic;
      app_rd_data_valid   : out std_logic;
      app_rdy             : out std_logic;
      app_wdf_rdy         : out std_logic;
      app_sr_req          : in  std_logic;
      app_sr_active       : out std_logic;
      app_ref_req         : in  std_logic;
      app_ref_ack         : out std_logic;
      app_zq_req          : in  std_logic;
      app_zq_ack          : out std_logic;
      ui_clk              : out std_logic;
      ui_clk_sync_rst     : out std_logic;
      init_calib_complete : out std_logic;

      -- System Clock Ports
      sys_clk_p : in std_logic;
      sys_clk_n : in std_logic;

      sys_rst : in std_logic
      );
  end component ddr_core;

  component PCIe_UserLogic_00
    port (
      bram_rd_dout        : in  std_logic_vector(63 downto 0);
      debug_in_1i         : in  std_logic_vector(31 downto 0);
      debug_in_2i         : in  std_logic_vector(31 downto 0);
      debug_in_3i         : in  std_logic_vector(31 downto 0);
      debug_in_4i         : in  std_logic_vector(31 downto 0);
      dma_host2board_busy : in  std_logic;
      dma_host2board_done : in  std_logic;
      fifo_rd_count       : in  std_logic_vector(14 downto 0);
      fifo_wr_count       : in  std_logic_vector(14 downto 0);
      fifo_rd_dout        : in  std_logic_vector(71 downto 0);
      fifo_rd_empty       : in  std_logic;
      fifo_rd_pempty      : in  std_logic;
      fifo_wr_full        : in  std_logic;
      fifo_wr_pfull       : in  std_logic;
      fifo_rd_valid       : in  std_logic;
      inout_logic_cw_ce   : in  std_logic := '1';
      inout_logic_cw_clk  : in  std_logic;
      reg01_td            : in  std_logic_vector(31 downto 0);
      reg01_tv            : in  std_logic;
      reg02_td            : in  std_logic_vector(31 downto 0);
      reg02_tv            : in  std_logic;
      reg03_td            : in  std_logic_vector(31 downto 0);
      reg03_tv            : in  std_logic;
      reg04_td            : in  std_logic_vector(31 downto 0);
      reg04_tv            : in  std_logic;
      reg05_td            : in  std_logic_vector(31 downto 0);
      reg05_tv            : in  std_logic;
      reg06_td            : in  std_logic_vector(31 downto 0);
      reg06_tv            : in  std_logic;
      reg07_td            : in  std_logic_vector(31 downto 0);
      reg07_tv            : in  std_logic;
      reg08_td            : in  std_logic_vector(31 downto 0);
      reg08_tv            : in  std_logic;
      reg09_td            : in  std_logic_vector(31 downto 0);
      reg09_tv            : in  std_logic;
      reg10_td            : in  std_logic_vector(31 downto 0);
      reg10_tv            : in  std_logic;
      reg11_td            : in  std_logic_vector(31 downto 0);
      reg11_tv            : in  std_logic;
      reg12_td            : in  std_logic_vector(31 downto 0);
      reg12_tv            : in  std_logic;
      reg13_td            : in  std_logic_vector(31 downto 0);
      reg13_tv            : in  std_logic;
      reg14_td            : in  std_logic_vector(31 downto 0);
      reg14_tv            : in  std_logic;
      rst_i               : in  std_logic;
      user_logic_cw_ce    : in  std_logic := '1';
      user_logic_cw_clk   : in  std_logic;
      bram_rd_addr        : out std_logic_vector(11 downto 0);
      bram_wr_addr        : out std_logic_vector(11 downto 0);
      bram_wr_din         : out std_logic_vector(63 downto 0);
      bram_wr_en          : out std_logic_vector(7 downto 0);
      fifo_rd_en          : out std_logic;
      fifo_wr_din         : out std_logic_vector(71 downto 0);
      fifo_wr_en          : out std_logic;
      reg01_rd            : out std_logic_vector(31 downto 0);
      reg01_rv            : out std_logic;
      reg02_rd            : out std_logic_vector(31 downto 0);
      reg02_rv            : out std_logic;
      reg03_rd            : out std_logic_vector(31 downto 0);
      reg03_rv            : out std_logic;
      reg04_rd            : out std_logic_vector(31 downto 0);
      reg04_rv            : out std_logic;
      reg05_rd            : out std_logic_vector(31 downto 0);
      reg05_rv            : out std_logic;
      reg06_rd            : out std_logic_vector(31 downto 0);
      reg06_rv            : out std_logic;
      reg07_rd            : out std_logic_vector(31 downto 0);
      reg07_rv            : out std_logic;
      reg08_rd            : out std_logic_vector(31 downto 0);
      reg08_rv            : out std_logic;
      reg09_rd            : out std_logic_vector(31 downto 0);
      reg09_rv            : out std_logic;
      reg10_rd            : out std_logic_vector(31 downto 0);
      reg10_rv            : out std_logic;
      reg11_rd            : out std_logic_vector(31 downto 0);
      reg11_rv            : out std_logic;
      reg12_rd            : out std_logic_vector(31 downto 0);
      reg12_rv            : out std_logic;
      reg13_rd            : out std_logic_vector(31 downto 0);
      reg13_rv            : out std_logic;
      reg14_rd            : out std_logic_vector(31 downto 0);
      reg14_rv            : out std_logic;
      rst_o               : out std_logic;
      user_int_1o         : out std_logic;
      user_int_2o         : out std_logic;
      user_int_3o         : out std_logic
      );
  end component;

  signal fifo_reset_done    : std_logic;
  signal pio_reading_status : std_logic;


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
      DDR_wr_FA    : in  std_logic;
      DDR_wr_Shift : in  std_logic;
      DDR_wr_Mask  : in  std_logic_vector(2-1 downto 0);
      DDR_wr_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full  : out std_logic;

      DDR_rdc_sof   : in  std_logic;
      DDR_rdc_eof   : in  std_logic;
      DDR_rdc_v     : in  std_logic;
      DDR_rdc_FA    : in  std_logic;
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
      DDR_UI_DATAWIDTH : integer
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
      user_reset    : in std_logic
      );
  end component;


  signal DDR_wr_sof   : std_logic;
  signal DDR_wr_eof   : std_logic;
  signal DDR_wr_v     : std_logic;
  signal DDR_wr_FA    : std_logic;
  signal DDR_wr_Shift : std_logic;
  signal DDR_wr_Mask  : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_wr_full  : std_logic;

  signal DDR_rdc_sof   : std_logic;
  signal DDR_rdc_eof   : std_logic;
  signal DDR_rdc_v     : std_logic;
  signal DDR_rdc_FA    : std_logic;
  signal DDR_rdc_Shift : std_logic;
  signal DDR_rdc_din   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_rdc_full  : std_logic;

  signal DDR_FIFO_RdEn   : std_logic;
  signal DDR_FIFO_Empty  : std_logic;
  signal DDR_FIFO_RdQout : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal DDR_Ready   : std_logic;
  signal DDR_Blinker : std_logic;

  signal user_wr_weA   : std_logic_vector(7 downto 0)               := (others => '0');
  signal user_wr_addrA : std_logic_vector(C_PRAM_AWIDTH-1 downto 0) := (others => '0');
  signal user_wr_dinA  : std_logic_vector(C_DBUS_WIDTH-1 downto 0)  := (others => '0');
  signal user_rd_addrB : std_logic_vector(C_PRAM_AWIDTH-1 downto 0) := (others => '0');
  signal user_rd_doutB : std_logic_vector(C_DBUS_WIDTH-1 downto 0);


  -- -----------------------------------------------------------------------
  -- Wishbone interface module
  -- -----------------------------------------------------------------------
  component wb_transact is
    generic (
      C_ASYNFIFO_WIDTH : integer := 72
      );
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

  -- WISHBONE SLAVE interface:
  -- Single-Port RAM with Asynchronous Read
  --
  component WB_MEM is
    generic(
      AWIDTH : natural range 2 to 29 := 7;
      DWIDTH : natural range 8 to 128 := 64
    );
    port(
      CLK_I : in  std_logic;
      ACK_O : out std_logic;
      ADR_I : in  std_logic_vector(AWIDTH-1 downto 0);
      DAT_I : in  std_logic_vector(DWIDTH-1 downto 0);
      DAT_O : out std_logic_vector(DWIDTH-1 downto 0);
      STB_I : in  std_logic;
      WE_I  : in  std_logic
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
  signal wb_rdd_ren    : std_logic;
  signal wb_rdd_dout   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wb_rdd_pempty : std_logic;
  signal wb_rdd_empty  : std_logic;
  signal wbone_rst     : std_logic;
  signal wbone_addr    : std_logic_vector(31 downto 0);
  signal wbone_mdin    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wbone_mdout   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wbone_we      : std_logic;
  signal wbone_sel     : std_logic_vector(0 downto 0);
  signal wbone_stb     : std_logic;
  signal wbone_ack     : std_logic;
  signal wbone_cyc     : std_logic;

  signal wb_data_count     : std_logic_vector(C_FIFO_DC_WIDTH downto 0) := (others => '0');
  signal H2B_wr_data_count : std_logic_vector(C_FIFO_DC_WIDTH downto 0) := (others => '0');
  signal B2H_rd_data_count : std_logic_vector(C_FIFO_DC_WIDTH downto 0) := (others => '0');

  signal wb_FIFO_ow : std_logic;

  signal wb_FIFO_Status  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal H2B_FIFO_Status : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal B2H_FIFO_Status : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal user_rd_en         : std_logic := '0';
  signal user_rd_dout       : std_logic_vector(72-1 downto 0);
  signal user_rd_pempty     : std_logic;
  signal user_rd_empty      : std_logic;
  signal user_rd_data_count : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal user_wr_data_count : std_logic_vector(C_EMU_FIFO_DC_WIDTH-1 downto 0);
  signal user_wr_en         : std_logic := '0';
  signal user_wr_din        : std_logic_vector(72-1 downto 0) := (others => '0');
  signal user_wr_pfull      : std_logic;
  signal user_wr_full       : std_logic;
  signal user_rd_valid      : std_logic;

------------- COMPONENT Declaration: tlpControl   ------
--
  component tlpControl
    port (
      --  Test pin, emulating DDR data flow discontinuity
      mbuf_UserFull : in  std_logic;
      trn_Blinker   : out std_logic;

--S     SIMONE: Wanxau UserLogic Signals, not Used
      -- DCB protocol interface
      protocol_link_act : in  std_logic_vector(2-1 downto 0);
      protocol_rst      : out std_logic;
      -- Fabric side: CTL Rx
      ctl_rv            : out std_logic;
      ctl_rd            : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      -- Fabric side: CTL Tx
      ctl_ttake         : out std_logic;
      ctl_tv            : in  std_logic;
      ctl_td            : in  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      ctl_tstop         : out std_logic;
      ctl_reset         : out std_logic;
      ctl_status        : in  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      -- Fabric side: DLM Rx
      dlm_rv            : in std_logic;
      dlm_rd            : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      -- Fabric side: DLM Tx
      dlm_tv            : out std_logic;
      dlm_td            : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      Link_Buf_full     : in  std_logic;
      -- Data generator table write
      tab_we            : out std_logic_vector(2-1 downto 0);
      tab_wa            : out std_logic_vector(12-1 downto 0);
      tab_wd            : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      -- Data generator control
      DG_is_Running     : in  std_logic;
      DG_Reset          : out std_logic;
      DG_Mask           : out std_logic;
--S     SIMONE: Wanxau UserLogic Signals, not Used

      -- Interrupter triggers
      DAQ_irq : in std_logic;
      CTL_irq : in std_logic;
      DLM_irq : in std_logic;

      -- SIMONE Register: PC-->FPGA
      reg01_tv : out std_logic;
      reg01_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg02_tv : out std_logic;
      reg02_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg03_tv : out std_logic;
      reg03_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg04_tv : out std_logic;
      reg04_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg05_tv : out std_logic;
      reg05_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg06_tv : out std_logic;
      reg06_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg07_tv : out std_logic;
      reg07_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg08_tv : out std_logic;
      reg08_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg09_tv : out std_logic;
      reg09_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg10_tv : out std_logic;
      reg10_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg11_tv : out std_logic;
      reg11_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg12_tv : out std_logic;
      reg12_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg13_tv : out std_logic;
      reg13_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg14_tv : out std_logic;
      reg14_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

      -- SIMONE Register: FPGA-->PC
      reg01_rv : in std_logic;
      reg01_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg02_rv : in std_logic;
      reg02_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg03_rv : in std_logic;
      reg03_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg04_rv : in std_logic;
      reg04_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg05_rv : in std_logic;
      reg05_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg06_rv : in std_logic;
      reg06_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg07_rv : in std_logic;
      reg07_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg08_rv : in std_logic;
      reg08_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg09_rv : in std_logic;
      reg09_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg10_rv : in std_logic;
      reg10_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg11_rv : in std_logic;
      reg11_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg12_rv : in std_logic;
      reg12_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg13_rv : in std_logic;
      reg13_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      reg14_rv : in std_logic;
      reg14_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

      --SIMONE debug signals
      debug_in_1i : out std_logic_vector(31 downto 0);
      debug_in_2i : out std_logic_vector(31 downto 0);
      debug_in_3i : out std_logic_vector(31 downto 0);
      debug_in_4i : out std_logic_vector(31 downto 0);

      -- Wishbone interface
      wb_FIFO_we   : out std_logic;
      wb_FIFO_wsof : out std_logic;
      wb_FIFO_weof : out std_logic;
      wb_FIFO_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      wb_FIFO_data_count : in  std_logic_vector(C_FIFO_DC_WIDTH downto 0);

      wb_FIFO_ow : in std_logic;

      pio_reading_status : out std_logic;
      wb_FIFO_Status     : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wb_FIFO_Rst        : out std_logic;

      -- Wishbone Read interface
      wb_rdc_sof  : out std_logic;
      wb_rdc_v    : out std_logic;
      wb_rdc_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wb_rdc_full : in std_logic;

      -- Wisbbone Buffer read port
      wb_FIFO_re    : out std_logic;
      wb_FIFO_empty : in  std_logic;
      wb_FIFO_qout  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      H2B_FIFO_Status : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      B2H_FIFO_Status : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Debugging signals
      DMA_us_Done     : out std_logic;
      DMA_us_Busy     : out std_logic;
      DMA_us_Busy_LED : out std_logic;
      DMA_ds_Done     : out std_logic;
      DMA_ds_Busy     : out std_logic;
      DMA_ds_Busy_LED : out std_logic;

      -- DDR control interface
      DDR_Ready : in std_logic;

      DDR_wr_sof   : out std_logic;
      DDR_wr_eof   : out std_logic;
      DDR_wr_v     : out std_logic;
      DDR_wr_FA    : out std_logic;
      DDR_wr_Shift : out std_logic;
      DDR_wr_Mask  : out std_logic_vector(2-1 downto 0);
      DDR_wr_din   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full  : in  std_logic;

      DDR_rdc_sof   : out std_logic;
      DDR_rdc_eof   : out std_logic;
      DDR_rdc_v     : out std_logic;
      DDR_rdc_FA    : out std_logic;
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

      cfg_interrupt           : out std_logic;
      cfg_interrupt_rdy       : in  std_logic;
      cfg_interrupt_mmenable  : in  std_logic_vector(2 downto 0);
      cfg_interrupt_msienable : in  std_logic;
      cfg_interrupt_di        : out std_logic_vector(7 downto 0);
      cfg_interrupt_do        : in  std_logic_vector(7 downto 0);
      cfg_interrupt_assert    : out std_logic;

      Format_Shower : out std_logic;

      m_axis_rx_tbar_hit : in  std_logic_vector(6 downto 0);
      s_axis_tx_tvalid   : out std_logic;
      m_axis_rx_tready   : out std_logic;
      s_axis_tx_tlast    : out std_logic;
      s_axis_tx_tkeep    : out std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      s_axis_tx_tdata    : out std_logic_vector(C_DBUS_WIDTH-1 downto 0)
      );
  end component;

  signal Format_Shower : std_logic;

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

  signal cfg_interrupt_msixenable : std_logic;
  signal cfg_interrupt_msixfm     : std_logic;
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

  -- Wires used for external clocking connectivity
  signal PIPE_PCLK_IN      : std_logic                    := '0';
  signal PIPE_RXUSRCLK_IN  : std_logic                    := '0';
  signal PIPE_RXOUTCLK_IN  : std_logic_vector(0 downto 0) := (others => '0');
  signal PIPE_DCLK_IN      : std_logic                    := '0';
  signal PIPE_USERCLK1_IN  : std_logic                    := '0';
  signal PIPE_USERCLK2_IN  : std_logic                    := '0';
  signal PIPE_OOBCLK_IN    : std_logic                    := '0';
  signal PIPE_MMCM_LOCK_IN : std_logic                    := '0';

  signal PIPE_TXOUTCLK_OUT : std_logic;
  signal PIPE_RXOUTCLK_OUT : std_logic_vector(0 downto 0);
  signal PIPE_PCLK_SEL_OUT : std_logic_vector(0 downto 0);
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
  signal fast_train_simulation_only : std_logic;
  signal two_plm_auto_config        : std_logic_vector(1 downto 0);

  signal cfg_mgmt_di                   : std_logic_vector(31 downto 0);
  signal cfg_mgmt_dwaddr               : std_logic_vector(9 downto 0);
  signal cfg_mgmt_wr_readonly          : std_logic;
  signal cfg_err_atomic_egress_blocked : std_logic;
  signal cfg_err_internal_cor          : std_logic;
  signal cfg_err_malformed             : std_logic;
  signal cfg_err_mc_blocked            : std_logic;
  signal cfg_err_poisoned              : std_logic;
  signal cfg_err_norecovery            : std_logic;
  signal cfg_err_acs                   : std_logic;
  signal cfg_err_internal_uncor        : std_logic;
  signal cfg_err_aer_headerlog         : std_logic_vector(127 downto 0);
  signal cfg_aer_interrupt_msgnum      : std_logic_vector(4 downto 0);
  signal cfg_err_aer_headerlog_set     : std_logic;
  signal cfg_aer_ecrc_check_en         : std_logic;
  signal cfg_aer_ecrc_gen_en           : std_logic;
  signal cfg_pm_halt_aspm_l0s          : std_logic;
  signal cfg_pm_halt_aspm_l1           : std_logic;
  signal cfg_pm_force_state_en         : std_logic;
  signal cfg_pm_force_state            : std_logic_vector(1 downto 0);
  signal cfg_interrupt_stat            : std_logic;
  signal cfg_pciecap_interrupt_msgnum  : std_logic_vector(4 downto 0);

  signal sys_clk_c     : std_logic;
  signal sys_reset_n_c : std_logic;
  signal sys_reset_c   : std_logic;
  signal reset_n       : std_logic;

  signal localId         : std_logic_vector(15 downto 0);
  signal pcie_link_width : std_logic_vector(5 downto 0);

  signal synclk2out : std_logic;

  signal Sim_Zeichen : std_logic;
  --
  signal trn_Blinker : std_logic;

  signal DAQ_irq : std_logic := '0';
  signal CTL_irq : std_logic := '0';
  signal DLM_irq : std_logic := '0';

--S     SIMONE: Wanxau UserLogic Signals, not Used
  signal protocol_link_act : std_logic_vector(2-1 downto 0)              := (others => '0');
  signal protocol_rst      : std_logic;
  signal daq_rstop         : std_logic := '0';
  signal ctl_rv            : std_logic;
  signal ctl_rd            : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal ctl_ttake         : std_logic;
  signal ctl_tv            : std_logic                                   := '0';
  signal ctl_td            : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal ctl_tstop         : std_logic;
  signal ctl_reset         : std_logic;
  signal ctl_status        : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal dlm_tv            : std_logic;
  signal dlm_td            : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal dlm_rv            : std_logic                                   := '0';
  signal dlm_rd            : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal tab_we            : std_logic_vector(2-1 downto 0);
  signal tab_wa            : std_logic_vector(12-1 downto 0);
  signal tab_wd            : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal dg_running        : std_logic                                   := '0';
  signal dg_rst            : std_logic;
  signal DG_Mask           : std_logic;
--S     SIMONE: Wanxau UserLogic Signals, not Used

  -- SIMONE Register: PC-->FPGA
  signal reg01_tv : std_logic;
  signal reg01_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg02_tv : std_logic;
  signal reg02_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg03_tv : std_logic;
  signal reg03_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg04_tv : std_logic;
  signal reg04_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg05_tv : std_logic;
  signal reg05_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg06_tv : std_logic;
  signal reg06_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg07_tv : std_logic;
  signal reg07_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg08_tv : std_logic;
  signal reg08_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg09_tv : std_logic;
  signal reg09_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg10_tv : std_logic;
  signal reg10_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg11_tv : std_logic;
  signal reg11_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg12_tv : std_logic;
  signal reg12_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg13_tv : std_logic;
  signal reg13_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
  signal reg14_tv : std_logic;
  signal reg14_td : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

  -- SIMONE Register: FPGA-->PC
  signal reg01_rv : std_logic                                   := '0';
  signal reg01_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg02_rv : std_logic                                   := '0';
  signal reg02_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg03_rv : std_logic                                   := '0';
  signal reg03_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg04_rv : std_logic                                   := '0';
  signal reg04_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg05_rv : std_logic                                   := '0';
  signal reg05_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg06_rv : std_logic                                   := '0';
  signal reg06_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg07_rv : std_logic                                   := '0';
  signal reg07_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg08_rv : std_logic                                   := '0';
  signal reg08_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg09_rv : std_logic                                   := '0';
  signal reg09_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg10_rv : std_logic                                   := '0';
  signal reg10_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg11_rv : std_logic                                   := '0';
  signal reg11_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg12_rv : std_logic                                   := '0';
  signal reg12_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg13_rv : std_logic                                   := '0';
  signal reg13_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');
  signal reg14_rv : std_logic                                   := '0';
  signal reg14_rd : std_logic_vector(C_DBUS_WIDTH/2-1 downto 0) := (others => '0');

  signal debug_in_1i : std_logic_vector(31 downto 0);
  signal debug_in_2i : std_logic_vector(31 downto 0);
  signal debug_in_3i : std_logic_vector(31 downto 0);
  signal debug_in_4i : std_logic_vector(31 downto 0);

  signal user_rst_o : std_logic;

  signal ddr_ref_clk_i : std_logic;

  signal DMA_Host2Board_Busy : std_logic;
  signal DMA_Host2Board_Done : std_logic;

  signal DMA_us_Busy : std_logic;
  signal DMA_us_Done : std_logic;
  signal DMA_ds_Done : std_logic;
  signal DMA_ds_Busy : std_logic;

  ----- DDR core User Interface signals -----------------------
  signal app_addr          : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal app_cmd           : std_logic_vector(2 downto 0);
  signal app_en            : std_logic;
  signal app_wdf_data      : std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
  signal app_wdf_end       : std_logic;
  signal app_wdf_mask      : std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)/8-1 downto 0);
  signal app_wdf_wren      : std_logic;
  signal app_rd_data       : std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
  signal app_rd_data_end   : std_logic;
  signal app_rd_data_valid : std_logic;
  signal app_rdy           : std_logic;
  signal app_wdf_rdy       : std_logic;
  signal app_sr_active     : std_logic;
  signal app_ref_ack       : std_logic;
  signal app_zq_ack        : std_logic;
  signal ddr_ui_clk        : std_logic;
  signal ddr_ui_reset      : std_logic;
  signal ddr_calib_done    : std_logic;

begin

  LoopBack_Off_UserLogic : if not USE_LOOPBACK_TEST generate

--S SIMONE: My Custom User Logic!!
    pcie_userlogic_00_x0 : PCIe_UserLogic_00
      port map (
        inout_logic_cw_ce   => '1',
        inout_logic_cw_clk  => user_clk,
        user_logic_cw_ce    => '1',
        user_logic_cw_clk   => ddr_ref_clk_i,
        fifo_rd_count       => user_rd_data_count,
        fifo_rd_dout        => user_rd_dout ,
        fifo_rd_empty       => user_rd_empty ,
        fifo_rd_pempty      => user_rd_pempty ,
        fifo_wr_full        => user_wr_full ,
        fifo_wr_pfull       => user_wr_pfull ,
        fifo_rd_en          => user_rd_en ,
        fifo_wr_din         => user_wr_din ,
        fifo_wr_en          => user_wr_en ,
        fifo_rd_valid       => user_rd_valid ,
        fifo_wr_count       => user_wr_data_count,
        bram_rd_addr        => user_rd_addrB(11 downto 0) ,
        bram_wr_addr        => user_wr_addrA(11 downto 0) ,
        bram_wr_din         => user_wr_dinA ,
        bram_wr_en          => user_wr_weA ,
        bram_rd_dout        => user_rd_doutB ,
        DMA_Host2Board_Busy => DMA_Host2Board_Busy,
        DMA_Host2Board_Done => DMA_Host2Board_Done,
        reg01_td            => reg01_td,
        reg01_tv            => reg01_tv,
        reg02_td            => reg02_td,
        reg02_tv            => reg02_tv,
        reg03_td            => reg03_td,
        reg03_tv            => reg03_tv,
        reg04_td            => reg04_td,
        reg04_tv            => reg04_tv,
        reg05_td            => reg05_td,
        reg05_tv            => reg05_tv,
        reg06_td            => reg06_td,
        reg06_tv            => reg06_tv,
        reg07_td            => reg07_td,
        reg07_tv            => reg07_tv,
        reg08_td            => reg08_td,
        reg08_tv            => reg08_tv,
        reg09_td            => reg09_td,
        reg09_tv            => reg09_tv,
        reg10_td            => reg10_td,
        reg10_tv            => reg10_tv,
        reg11_td            => reg11_td,
        reg11_tv            => reg11_tv,
        reg12_td            => reg12_td,
        reg12_tv            => reg12_tv,
        reg13_td            => reg13_td,
        reg13_tv            => reg13_tv,
        reg14_td            => reg14_td,
        reg14_tv            => reg14_tv,
        reg01_rd            => reg01_rd,
        reg01_rv            => reg01_rv,
        reg02_rd            => reg02_rd,
        reg02_rv            => reg02_rv,
        reg03_rd            => reg03_rd,
        reg03_rv            => reg03_rv,
        reg04_rd            => reg04_rd,
        reg04_rv            => reg04_rv,
        reg05_rd            => reg05_rd,
        reg05_rv            => reg05_rv,
        reg06_rd            => reg06_rd,
        reg06_rv            => reg06_rv,
        reg07_rd            => reg07_rd,
        reg07_rv            => reg07_rv,
        reg08_rd            => reg08_rd,
        reg08_rv            => reg08_rv,
        reg09_rd            => reg09_rd,
        reg09_rv            => reg09_rv,
        reg10_rd            => reg10_rd,
        reg10_rv            => reg10_rv,
        reg11_rd            => reg11_rd,
        reg11_rv            => reg11_rv,
        reg12_rd            => reg12_rd,
        reg12_rv            => reg12_rv,
        reg13_rd            => reg13_rd,
        reg13_rv            => reg13_rv,
        reg14_rd            => reg14_rd,
        reg14_rv            => reg14_rv,
        user_int_1o         => CTL_irq,
        user_int_2o         => DAQ_irq,
        user_int_3o         => DLM_irq,
        debug_in_1i         => debug_in_1i,
        debug_in_2i         => debug_in_2i,
        debug_in_3i         => debug_in_3i,
        debug_in_4i         => debug_in_4i,
        rst_i               => user_reset,
        rst_o               => user_rst_o
        );

  end generate;

  DMA_Host2Board_Busy <= '0';           --DMA_ds_Busy;
  DMA_Host2Board_Done <= DMA_ds_Done;
--   LEDs_IO_pin(5) <= DMA_ds_Done;
--      LEDs_IO_pin(7) <= DMA_us_Done;

  sys_reset_c <= not sys_reset_n_c;
  sys_reset_n_ibuf : IBUF
    port map (
      O => sys_reset_n_c,
      I => sys_rst_n
      );

  pcieclk_ibuf : IBUFDS_GTE2
    port map (
      O     => sys_clk_c,
      ODIV2 => open,
      I     => sys_clk_p,
      IB    => sys_clk_n,
      CEB   => '0'
      );

  --ddr_refclk_ibuf : IBUFGDS
    --generic map (
      --DIFF_TERM    => TRUE,
      --IBUF_LOW_PWR => FALSE
    --)
    --port map (
      --I  => ddr_sys_clk_p,
      --IB => ddr_sys_clk_n,
      --O  => ddr_ref_clk_i
    --);
  ddr_ref_clk_i <= '0'; --USE_SYSTEM_CLOCK

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
    PL_FAST_TRAIN => PL_FAST_TRAIN,
    PCIE_EXT_CLK => "FALSE",
    PIPE_SIM_MODE => PIPE_SIM_MODE
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
    -- 2. Clocking Interface - For Partial Reconfig Support                                                          --
    -------------------------------------------------------------------------------------------------------------------
    PIPE_PCLK_IN      => PIPE_PCLK_IN,
    PIPE_RXUSRCLK_IN  => PIPE_RXUSRCLK_IN,
    PIPE_RXOUTCLK_IN  => PIPE_RXOUTCLK_IN,
    PIPE_DCLK_IN      => PIPE_DCLK_IN,
    PIPE_USERCLK1_IN  => PIPE_USERCLK1_IN,
    PIPE_USERCLK2_IN  => PIPE_USERCLK2_IN,
    PIPE_OOBCLK_IN    => PIPE_OOBCLK_IN,
    PIPE_MMCM_LOCK_IN => PIPE_MMCM_LOCK_IN,
    PIPE_TXOUTCLK_OUT => PIPE_TXOUTCLK_OUT,
    PIPE_RXOUTCLK_OUT => PIPE_RXOUTCLK_OUT,
    PIPE_PCLK_SEL_OUT => PIPE_PCLK_SEL_OUT,
    PIPE_GEN3_OUT     => PIPE_GEN3_OUT,

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
    sys_clk   => sys_clk_c ,
    sys_rst_n => sys_reset_n_c
    );

-- ---------------------------------------------------------------
-- tlp control module
-- ---------------------------------------------------------------

-- workaround pcie core bug
  --m_axis_rx_tkeep(7 downto 1) <= X"0" & m_axis_rx_tkeep(0) & m_axis_rx_tkeep(0) & m_axis_rx_tkeep(0);

  theTlpControl :
    tlpControl
      port map (

        mbuf_UserFull => '0' ,
        trn_Blinker   => trn_Blinker ,

        -- Interrupter triggers
        DAQ_irq => DAQ_irq ,            -- IN  std_logic;
        CTL_irq => CTL_irq ,            -- IN  std_logic;
        DLM_irq => DLM_irq ,            -- IN  std_logic;


--S     SIMONE: Wanxau UserLogic Signals, not Used
        -- DCB protocol interface
        protocol_link_act => protocol_link_act ,  -- IN  std_logic_vector(2-1 downto 0);
        protocol_rst      => protocol_rst ,       -- OUT std_logic;
        Link_Buf_Full     => daq_rstop ,   -- IN  std_logic;
        -- Fabric side: CTL Rx
        ctl_rv            => ctl_rv ,   -- OUT std_logic;
        ctl_rd            => ctl_rd ,  -- OUT std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
        -- Fabric side: CTL Tx
        ctl_ttake         => ctl_ttake ,   -- OUT std_logic;
        ctl_tv            => ctl_tv ,   -- IN  std_logic;
        ctl_td            => ctl_td ,  -- IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
        ctl_tstop         => ctl_tstop ,   -- OUT std_logic;
        ctl_reset         => ctl_reset ,   -- OUT std_logic;
        ctl_status        => ctl_status ,  -- IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
        -- Fabric side: DLM Rx
        dlm_rv            => dlm_rv ,   -- OUT std_logic;
        dlm_rd            => dlm_rd ,  -- OUT std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
        -- Fabric side: DLM Tx
        dlm_tv            => dlm_tv ,   -- IN  std_logic;
        dlm_td            => dlm_td ,  -- IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
        tab_we            => tab_we ,   -- OUT std_logic_vector(2-1 downto 0);
        tab_wa            => tab_wa ,   -- OUT std_logic_vector(12-1 downto 0);
        tab_wd            => tab_wd ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DG_is_Running     => dg_running ,  -- IN  std_logic;
        DG_Reset          => dg_rst ,   -- OUT   STD_LOGIC;
        DG_Mask           => dg_mask ,  -- OUT   STD_LOGIC
--S     SIMONE: Wanxau UserLogic Signals, not Used


        -- SIMONE Register: PC-->FPGA
        reg01_tv => reg01_tv,
        reg01_td => reg01_td,
        reg02_tv => reg02_tv,
        reg02_td => reg02_td,
        reg03_tv => reg03_tv,
        reg03_td => reg03_td,
        reg04_tv => reg04_tv,
        reg04_td => reg04_td,
        reg05_tv => reg05_tv,
        reg05_td => reg05_td,
        reg06_tv => reg06_tv,
        reg06_td => reg06_td,
        reg07_tv => reg07_tv,
        reg07_td => reg07_td,
        reg08_tv => reg08_tv,
        reg08_td => reg08_td,
        reg09_tv => reg09_tv,
        reg09_td => reg09_td,
        reg10_tv => reg10_tv,
        reg10_td => reg10_td,
        reg11_tv => reg11_tv,
        reg11_td => reg11_td,
        reg12_tv => reg12_tv,
        reg12_td => reg12_td,
        reg13_tv => reg13_tv,
        reg13_td => reg13_td,
        reg14_tv => reg14_tv,
        reg14_td => reg14_td,

        -- SIMONE Register: FPGA-->PC
        reg01_rv => reg01_rv,
        reg01_rd => reg01_rd,
        reg02_rv => reg02_rv,
        reg02_rd => reg02_rd,
        reg03_rv => reg03_rv,
        reg03_rd => reg03_rd,
        reg04_rv => reg04_rv,
        reg04_rd => reg04_rd,
        reg05_rv => reg05_rv,
        reg05_rd => reg05_rd,
        reg06_rv => reg06_rv,
        reg06_rd => reg06_rd,
        reg07_rv => reg07_rv,
        reg07_rd => reg07_rd,
        reg08_rv => reg08_rv,
        reg08_rd => reg08_rd,
        reg09_rv => reg09_rv,
        reg09_rd => reg09_rd,
        reg10_rv => reg10_rv,
        reg10_rd => reg10_rd,
        reg11_rv => reg11_rv,
        reg11_rd => reg11_rd,
        reg12_rv => reg12_rv,
        reg12_rd => reg12_rd,
        reg13_rv => reg13_rv,
        reg13_rd => reg13_rd,
        reg14_rv => reg14_rv,
        reg14_rd => reg14_rd,

        -- SIMONE debug signals
        debug_in_1i => debug_in_1i,
        debug_in_2i => debug_in_2i,
        debug_in_3i => debug_in_3i,
        debug_in_4i => debug_in_4i,

        -- Wishbone FIFO interface
        wb_FIFO_we   => wb_wr_we ,         --  OUT std_logic;
        wb_FIFO_wsof => wb_wr_wsof ,       --  OUT std_logic;
        wb_FIFO_weof => wb_wr_weof ,       --  OUT std_logic;
        wb_FIFO_din  => wb_wr_din(C_DBUS_WIDTH-1 downto 0) ,  --  OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        wb_FIFO_re         => wb_rdd_ren ,   --  OUT std_logic;
        wb_FIFO_empty      => wb_rdd_empty ,       --  IN  std_logic;
        wb_FIFO_qout       => wb_rdd_dout(C_DBUS_WIDTH-1 downto 0) ,  --  IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        wb_FIFO_data_count => wb_data_count ,  --  IN  std_logic_vector(C_FIFO_DC_WIDTH downto 0);

        wb_rdc_sof  => wb_rdc_sof, --out std_logic;
        wb_rdc_v    => wb_rdc_v, --out std_logic;
        wb_rdc_din  => wb_rdc_din, --out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        wb_rdc_full => wb_rdc_full, --in std_logic;
        wb_FIFO_ow   => wb_FIFO_ow ,      --  IN  std_logic;

        pio_reading_status => pio_reading_status ,  --  OUT std_logic;

        wb_FIFO_Status  => wb_FIFO_Status ,  --  IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        wb_FIFO_Rst     => wbone_rst ,     --  OUT std_logic;
        H2B_FIFO_Status => H2B_FIFO_Status ,
        B2H_FIFO_Status => B2H_FIFO_Status ,

        -- Debugging signals
        DMA_us_Done     => DMA_us_Done ,  -- OUT std_logic;
        DMA_us_Busy     => DMA_us_Busy ,  -- OUT std_logic;
        --DMA_us_Busy_LED             => LEDs_IO_pin(6)      , -- OUT std_logic;
        DMA_us_Busy_LED => open ,         -- OUT std_logic;
        DMA_ds_Done     => DMA_ds_Done ,  -- OUT std_logic;
        DMA_ds_Busy     => DMA_ds_Busy ,  -- OUT std_logic;
        --DMA_ds_Busy_LED             => LEDs_IO_pin(4)      , -- OUT std_logic;
        DMA_ds_Busy_LED => open ,         -- OUT std_logic;

        -------------------
        -- DDR Interface
        DDR_Ready => DDR_Ready ,        --  IN    std_logic;

        DDR_wr_sof   => DDR_wr_sof ,    --  OUT   std_logic;
        DDR_wr_eof   => DDR_wr_eof ,    --  OUT   std_logic;
        DDR_wr_v     => DDR_wr_v ,      --  OUT   std_logic;
        DDR_wr_FA    => DDR_wr_FA ,     --  OUT   std_logic;
        DDR_wr_Shift => DDR_wr_Shift ,  --  OUT   std_logic;
        DDR_wr_Mask  => DDR_wr_Mask ,  --  OUT   std_logic_vector(2-1 downto 0);
        DDR_wr_din   => DDR_wr_din ,  --  OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DDR_wr_full  => DDR_wr_full ,   --  IN    std_logic;

        DDR_rdc_sof   => DDR_rdc_sof ,  --  OUT   std_logic;
        DDR_rdc_eof   => DDR_rdc_eof ,  --  OUT   std_logic;
        DDR_rdc_v     => DDR_rdc_v ,    --  OUT   std_logic;
        DDR_rdc_FA    => DDR_rdc_FA ,   --  OUT   std_logic;
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

        cfg_interrupt           => cfg_interrupt ,
        cfg_interrupt_rdy       => cfg_interrupt_rdy ,
        cfg_interrupt_mmenable  => cfg_interrupt_mmenable ,
        cfg_interrupt_msienable => cfg_interrupt_msienable ,
        cfg_interrupt_di        => cfg_interrupt_di ,
        cfg_interrupt_do        => cfg_interrupt_do ,
        cfg_interrupt_assert    => cfg_interrupt_assert ,

        m_axis_rx_tbar_hit => m_axis_rx_tbar_hit ,
        s_axis_tx_tvalid   => s_axis_tx_tvalid ,
        m_axis_rx_tready   => m_axis_rx_tready ,
        s_axis_tx_tlast    => s_axis_tx_tlast ,
        s_axis_tx_tkeep    => s_axis_tx_tkeep ,
        s_axis_tx_tdata    => s_axis_tx_tdata ,

        Format_Shower => Format_Shower ,

        cfg_dcommand    => cfg_dcommand ,
        pcie_link_width => pcie_link_width ,
        localId         => localId
        );

  -- -----------------------------------------------------------------------
  --  DDR SDRAM: control module
  -- -----------------------------------------------------------------------

  LoopBack_BRAM_Off : if not USE_LOOPBACK_TEST generate

    DDRs_ctrl_module : DDR_Transact
      generic map (
        SIMULATION => SIMULATION,
        DATA_WIDTH => C_DBUS_WIDTH,
        ADDR_WIDTH => ADDR_WIDTH,
        DDR_UI_DATAWIDTH => nCK_PER_CLK*2*PAYLOAD_WIDTH
        )
      port map(
        -- connect your own signals here
        memc_ui_clk    => open, --: out std_logic;
        memc_cmd_rdy   => open, --: out std_logic;
        memc_cmd_en    => '0', --: in  std_logic;
        memc_cmd_instr => (others => '0'), --: in  std_logic_vector(2 downto 0);
        memc_cmd_addr  => (others => '0'), --: in  std_logic_vector(31 downto 0);
        memc_wr_en     => '0', --: in  std_logic;
        memc_wr_end    => '0', --: in  std_logic;
        memc_wr_mask   => (others => '0'), --: in  std_logic_vector(64/8-1 downto 0);
        memc_wr_data   => (others => '0'), --: in  std_logic_vector(64-1 downto 0);
        memc_wr_rdy    => open, --: out std_logic;
        memc_rd_data   => open, --: out std_logic_vector(64-1 downto 0);
        memc_rd_valid  => open, --: out std_logic;
        memarb_acc_req => '0', --: in  std_logic;
        memarb_acc_gnt => open, --: out std_logic;
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
        user_reset    => user_reset --  IN    std_logic
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
          DDR_wr_FA    => DDR_wr_FA ,   --  IN    std_logic;
          DDR_wr_Shift => DDR_wr_Shift ,  --  IN    std_logic;
          DDR_wr_Mask  => DDR_wr_Mask ,  --  IN    std_logic_vector(2-1 downto 0);
          DDR_wr_din   => DDR_wr_din ,  --  IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
          DDR_wr_full  => DDR_wr_full ,  --  OUT   std_logic;

          DDR_rdc_sof   => DDR_rdc_sof ,  --  IN    std_logic;
          DDR_rdc_eof   => DDR_rdc_eof ,  --  IN    std_logic;
          DDR_rdc_v     => DDR_rdc_v ,  --  IN    std_logic;
          DDR_rdc_FA    => DDR_rdc_FA ,   --  IN    std_logic;
          DDR_rdc_Shift => DDR_rdc_Shift ,  --  IN    std_logic;
          DDR_rdc_din   => DDR_rdc_din ,  --  IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
          DDR_rdc_full  => DDR_rdc_full ,   --  OUT   std_logic;

          -- DDR payload FIFO Read Port
          DDR_FIFO_RdEn   => DDR_FIFO_RdEn ,    -- IN    std_logic;
          DDR_FIFO_Empty  => DDR_FIFO_Empty ,   -- OUT   std_logic;
          DDR_FIFO_RdQout => DDR_FIFO_RdQout ,  -- OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);

          -- Common interface
          DDR_Ready   => DDR_Ready ,    --  OUT   std_logic;
          DDR_Blinker => DDR_Blinker ,  --  OUT   std_logic;
          mem_clk     => user_clk ,     --  IN
          user_clk    => user_clk ,     --  IN    std_logic;
          Sim_Zeichen => Sim_Zeichen ,  --  OUT   std_logic;
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

  Wishbone_mem_large: if SIMULATION = "TRUE" generate

    wb_mem_sim :
      wb_mem
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

  Wishbone_mem_sample: if SIMULATION = "FALSE" generate

    wb_mem_syn :
      wb_mem
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
    wbone_clk <= ddr_ui_clk;

    --- Hybrid FIFO Signal used by PCIe interface and Linux Driver
    fifo_reset_done <= not wbone_rst;
    wb_data_count   <= B2H_rd_data_count;

    --- Hybrid FIFO Status used by PCIe interface and Linux Driver ---
    --- read: status ; write: reset H2B and B2H FIFO
    wb_FIFO_Status(C_DBUS_WIDTH-1 downto C_FIFO_DC_WIDTH+3)
 <= (others => '0');
    wb_FIFO_Status(C_FIFO_DC_WIDTH+2 downto 3)
 <= B2H_rd_data_count(C_FIFO_DC_WIDTH downto 1);
    wb_FIFO_Status(2) <= '0';
    wb_FIFO_Status(1) <= wb_rdc_full;
    wb_FIFO_Status(0) <= wb_rdd_empty and fifo_reset_done;

    --- Host2Board FIFO status used by user ---
    --- read: H2B status ; write: nothing
    H2B_FIFO_Status(C_DBUS_WIDTH-1 downto C_FIFO_DC_WIDTH+3)
 <= (others => '0');
    H2B_FIFO_Status(C_FIFO_DC_WIDTH+2 downto 3)
 <= H2B_wr_data_count(C_FIFO_DC_WIDTH downto 1);
    H2B_FIFO_Status(2) <= '0';
    H2B_FIFO_Status(1) <= wb_wr_full;
    H2B_FIFO_Status(0) <= wb_wr_full and fifo_reset_done;

    --- Board2Host FIFO status used by user ---
    --- read: B2H status ; write: nothing
    B2H_FIFO_Status(C_DBUS_WIDTH-1 downto C_FIFO_DC_WIDTH+3) <= (others => '0');
    B2H_FIFO_Status(C_FIFO_DC_WIDTH+2 downto 3)
 <= B2H_rd_data_count(C_FIFO_DC_WIDTH downto 1);
    B2H_FIFO_Status(2) <= wb_rdc_v;
    B2H_FIFO_Status(1) <= wb_rdd_empty;
    B2H_FIFO_Status(0) <= wb_rdd_empty and fifo_reset_done;


  u_ddr_core : ddr_core
    generic map (
      TCQ                     => TCQ,
      ADDR_CMD_MODE           => ADDR_CMD_MODE,
      AL                      => AL,
      PAYLOAD_WIDTH           => PAYLOAD_WIDTH,
      BANK_WIDTH              => BANK_WIDTH,
      BURST_MODE              => BURST_MODE,
      BURST_TYPE              => BURST_TYPE,
      CA_MIRROR               => CA_MIRROR,
      CK_WIDTH                => CK_WIDTH,
      COL_WIDTH               => COL_WIDTH,
      CMD_PIPE_PLUS1          => CMD_PIPE_PLUS1,
      CS_WIDTH                => CS_WIDTH,
      nCS_PER_RANK            => nCS_PER_RANK,
      CKE_WIDTH               => CKE_WIDTH,
      DATA_WIDTH              => DATA_WIDTH,
      DATA_BUF_ADDR_WIDTH     => DATA_BUF_ADDR_WIDTH,
      DQ_CNT_WIDTH            => DQ_CNT_WIDTH,
      DQ_PER_DM               => DQ_PER_DM,
      DQ_WIDTH                => DQ_WIDTH,
      DQS_CNT_WIDTH           => DQS_CNT_WIDTH,
      DQS_WIDTH               => DQS_WIDTH,
      DRAM_WIDTH              => DRAM_WIDTH,
      ECC                     => ECC,
      ECC_WIDTH               => ECC_WIDTH,
      ECC_TEST                => ECC_TEST,
      MC_ERR_ADDR_WIDTH       => MC_ERR_ADDR_WIDTH,
      nAL                     => nAL,
      nBANK_MACHS             => nBANK_MACHS,
      CKE_ODT_AUX             => CKE_ODT_AUX,
      ORDERING                => ORDERING,
      OUTPUT_DRV              => OUTPUT_DRV,
      IBUF_LPWR_MODE          => IBUF_LPWR_MODE,
      IODELAY_HP_MODE         => IODELAY_HP_MODE,
      DATA_IO_IDLE_PWRDWN     => DATA_IO_IDLE_PWRDWN,
      BANK_TYPE               => BANK_TYPE,
      DATA_IO_PRIM_TYPE       => DATA_IO_PRIM_TYPE,
      REG_CTRL                => REG_CTRL,
      RTT_NOM                 => RTT_NOM,
      RTT_WR                  => RTT_WR,
      CL                      => CL,
      CWL                     => CWL,
      tCKE                    => tCKE,
      tFAW                    => tFAW,
      tPRDI                   => tPRDI,
      tRAS                    => tRAS,
      tRCD                    => tRCD,
      tREFI                   => tREFI,
      tRFC                    => tRFC,
      tRP                     => tRP,
      tRRD                    => tRRD,
      tRTP                    => tRTP,
      tWTR                    => tWTR,
      tZQI                    => tZQI,
      tZQCS                   => tZQCS,
      USER_REFRESH            => USER_REFRESH,
      WRLVL                   => WRLVL,
      DEBUG_PORT              => DEBUG_PORT,
      RANKS                   => RANKS,
      ODT_WIDTH               => ODT_WIDTH,
      ROW_WIDTH               => ROW_WIDTH,
      ADDR_WIDTH              => ADDR_WIDTH,
      SIM_BYPASS_INIT_CAL     => SIM_BYPASS_INIT_CAL,
      SIMULATION              => SIMULATION,
      BYTE_LANES_B0           => BYTE_LANES_B0,
      BYTE_LANES_B1           => BYTE_LANES_B1,
      BYTE_LANES_B2           => BYTE_LANES_B2,
      BYTE_LANES_B3           => BYTE_LANES_B3,
      BYTE_LANES_B4           => BYTE_LANES_B4,
      DATA_CTL_B0             => DATA_CTL_B0,
      DATA_CTL_B1             => DATA_CTL_B1,
      DATA_CTL_B2             => DATA_CTL_B2,
      DATA_CTL_B3             => DATA_CTL_B3,
      DATA_CTL_B4             => DATA_CTL_B4,
      PHY_0_BITLANES          => PHY_0_BITLANES,
      PHY_1_BITLANES          => PHY_1_BITLANES,
      PHY_2_BITLANES          => PHY_2_BITLANES,
      CK_BYTE_MAP             => CK_BYTE_MAP,
      ADDR_MAP                => ADDR_MAP,
      BANK_MAP                => BANK_MAP,
      CAS_MAP                 => CAS_MAP,
      CKE_ODT_BYTE_MAP        => CKE_ODT_BYTE_MAP,
      CKE_MAP                 => CKE_MAP,
      ODT_MAP                 => ODT_MAP,
      CS_MAP                  => CS_MAP,
      PARITY_MAP              => PARITY_MAP,
      RAS_MAP                 => RAS_MAP,
      WE_MAP                  => WE_MAP,
      DQS_BYTE_MAP            => DQS_BYTE_MAP,
      DATA0_MAP               => DATA0_MAP,
      DATA1_MAP               => DATA1_MAP,
      DATA2_MAP               => DATA2_MAP,
      DATA3_MAP               => DATA3_MAP,
      DATA4_MAP               => DATA4_MAP,
      DATA5_MAP               => DATA5_MAP,
      DATA6_MAP               => DATA6_MAP,
      DATA7_MAP               => DATA7_MAP,
      DATA8_MAP               => DATA8_MAP,
      DATA9_MAP               => DATA9_MAP,
      DATA10_MAP              => DATA10_MAP,
      DATA11_MAP              => DATA11_MAP,
      DATA12_MAP              => DATA12_MAP,
      DATA13_MAP              => DATA13_MAP,
      DATA14_MAP              => DATA14_MAP,
      DATA15_MAP              => DATA15_MAP,
      DATA16_MAP              => DATA16_MAP,
      DATA17_MAP              => DATA17_MAP,
      MASK0_MAP               => MASK0_MAP,
      MASK1_MAP               => MASK1_MAP,
      CALIB_ROW_ADD           => CALIB_ROW_ADD,
      CALIB_COL_ADD           => CALIB_COL_ADD,
      CALIB_BA_ADD            => CALIB_BA_ADD,
      SLOT_0_CONFIG           => SLOT_0_CONFIG,
      SLOT_1_CONFIG           => SLOT_1_CONFIG,
      MEM_ADDR_ORDER          => MEM_ADDR_ORDER,
      USE_CS_PORT             => USE_CS_PORT,
      USE_DM_PORT             => USE_DM_PORT,
      USE_ODT_PORT            => USE_ODT_PORT,
      PHY_CONTROL_MASTER_BANK => PHY_CONTROL_MASTER_BANK,
      TEMP_MON_CONTROL        => TEMP_MON_CONTROL,
      DM_WIDTH                => DM_WIDTH,
      nCK_PER_CLK             => nCK_PER_CLK,
      tCK                     => tCK,
      DIFF_TERM_SYSCLK        => DIFF_TERM_SYSCLK,
      CLKIN_PERIOD            => CLKIN_PERIOD,
      CLKFBOUT_MULT           => CLKFBOUT_MULT,
      DIVCLK_DIVIDE           => DIVCLK_DIVIDE,
      CLKOUT0_PHASE           => CLKOUT0_PHASE,
      CLKOUT0_DIVIDE          => CLKOUT0_DIVIDE,
      CLKOUT1_DIVIDE          => CLKOUT1_DIVIDE,
      CLKOUT2_DIVIDE          => CLKOUT2_DIVIDE,
      CLKOUT3_DIVIDE          => CLKOUT3_DIVIDE,

      SYSCLK_TYPE      => SYSCLK_TYPE,
      REFCLK_TYPE      => REFCLK_TYPE,
      REFCLK_FREQ      => REFCLK_FREQ,
      DIFF_TERM_REFCLK => DIFF_TERM_REFCLK,
      IODELAY_GRP      => IODELAY_GRP,

      CAL_WIDTH    => CAL_WIDTH,
      STARVE_LIMIT => STARVE_LIMIT,
      DRAM_TYPE    => DRAM_TYPE,

      RST_ACT_LOW => RST_ACT_LOW
    )
    port map (
      -- Memory interface ports
      ddr3_addr           => ddr3_addr,
      ddr3_ba             => ddr3_ba,
      ddr3_cas_n          => ddr3_cas_n,
      ddr3_ck_n           => ddr3_ck_n,
      ddr3_ck_p           => ddr3_ck_p,
      ddr3_cke            => ddr3_cke,
      ddr3_ras_n          => ddr3_ras_n,
      ddr3_reset_n        => ddr3_reset_n,
      ddr3_we_n           => ddr3_we_n,
      ddr3_dq             => ddr3_dq,
      ddr3_dqs_n          => ddr3_dqs_n,
      ddr3_dqs_p          => ddr3_dqs_p,
      init_calib_complete => ddr_calib_done,
      ddr3_cs_n           => ddr3_cs_n,
      ddr3_dm             => ddr3_dm,
      ddr3_odt            => ddr3_odt,
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
      app_sr_req        => '0',
      app_sr_active     => app_sr_active,
      app_ref_req       => '0',
      app_ref_ack       => app_ref_ack,
      app_zq_req        => '0',
      app_zq_ack        => app_zq_ack,
      ui_clk            => ddr_ui_clk,
      ui_clk_sync_rst   => ddr_ui_reset,

      -- System Clock Ports
      sys_clk_p => ddr_sys_clk_p,
      sys_clk_n => ddr_sys_clk_n,
      -- Reference Clock Ports
      --clk_ref_i => ddr_ref_clk,

      sys_rst => sys_reset_n_c
    );
end Behavioral;
