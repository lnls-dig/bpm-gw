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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DDR_Transact is
  generic (
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

    SIMULATION            : string  := "FALSE";
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

    RST_ACT_LOW           : integer := 0
                                     -- =1 for active low reset,
                                     -- =0 for active high.
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
    memc_wr_mask   : in  std_logic_vector(C_DDR_DATAWIDTH/8-1 downto 0);
    memc_wr_data   : in  std_logic_vector(C_DDR_DATAWIDTH-1 downto 0);
    memc_wr_rdy    : out std_logic;
    memc_rd_data   : out std_logic_vector(C_DDR_DATAWIDTH-1 downto 0);
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

    --clocking & reset
    ddr_sys_clk_p : in std_logic;
    ddr_sys_clk_n : in std_logic;
    ddr_ref_clk   : in std_logic;
    user_clk      : in std_logic;
    user_reset    : in std_logic;
    sys_reset     : in std_logic
    );
end entity DDR_Transact;

architecture Behavioral of DDR_Transact is
  -- ----------------------------------------------------------------------------
  -- Constants (some copied from DDR core example_top.vhd
  -- ----------------------------------------------------------------------------
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

  constant DATA_WIDTH            : integer := 64;
  constant PAYLOAD_WIDTH         : integer := DATA_WIDTH;
  constant ECC_WIDTH             : integer := 0;
  constant ECC_TEST              : string  := "OFF";
  constant DATA_BUF_OFFSET_WIDTH : integer := 1;
  constant tPRDI                 : integer := 1000000; -- memory tPRDI paramter in pS.
  constant MC_ERR_ADDR_WIDTH     : integer := XWIDTH + BANK_WIDTH + ROW_WIDTH + COL_WIDTH + DATA_BUF_OFFSET_WIDTH;
  constant CMD_PIPE_PLUS1        : string  := "ON"; -- add pipeline stage between MC and PHY

  -- ----------------------------------------------------------------------------
  -- Component declarations
  -- ----------------------------------------------------------------------------
  component DDRs_Control
    generic (
      C_ASYNFIFO_WIDTH : integer := 72;
      DATA_WIDTH       : integer := 64;
      P_SIMULATION     : string  := "FALSE"
      );
    port (
      -- FPGA interface --
      wr_clk   : in  std_logic;
      wr_eof   : in  std_logic;
      wr_v     : in  std_logic;
      wr_shift : in  std_logic;
      wr_mask  : in  std_logic_vector(2-1 downto 0);
      wr_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wr_full  : out std_logic;

      rd_clk    : in  std_logic;
      rdc_v     : in  std_logic;
      rdc_shift : in  std_logic;
      rdc_din   : in  std_logic_vector(c_dbus_width-1 downto 0);
      rdc_full  : out std_logic;

      -- ddr payload fifo read port
      rdd_fifo_rden  : in  std_logic;
      rdd_fifo_empty : out std_logic;
      rdd_fifo_dout  : out std_logic_vector(c_dbus_width-1 downto 0);

      -- memory controller interface --
      memc_cmd_rdy   : in   std_logic;
      memc_cmd_en    : out  std_logic;
      memc_cmd_instr : out  std_logic_vector(2 downto 0);
      memc_cmd_addr  : out  std_logic_vector(31 downto 0);
      memc_wr_en     : out  std_logic;
      memc_wr_end    : out  std_logic;
      memc_wr_mask   : out  std_logic_vector(C_DDR_DATAWIDTH/8-1 downto 0);
      memc_wr_data   : out  std_logic_vector(C_DDR_DATAWIDTH-1 downto 0);
      memc_wr_rdy    : in   std_logic;
      memc_rd_en     : out  std_logic;
      memc_rd_data   : in   std_logic_vector(C_DDR_DATAWIDTH-1 downto 0);
      memc_rd_valid  : in   std_logic;

      -- memory arbiter interface
      memarb_acc_req : out std_logic;
      memarb_acc_gnt : in  std_logic;

      memc_ui_clk : in std_logic;
      ddr_rdy     : in std_logic;
      reset       : in std_logic
      );
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

  -- ----------------------------------------------------------------------------
  -- Signal & type declarations
  -- ----------------------------------------------------------------------------
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
  signal ui_clk            : std_logic;
  signal calib_done        : std_logic;

  type ddr_switch_t is (EXT, PCIE);
  signal ddr_switch : ddr_switch_t := PCIE;
  signal arb_req    : std_logic_vector(1 downto 0);

  signal pcie_cmd_rdy   : std_logic;
  signal pcie_cmd_en    : std_logic;
  signal pcie_cmd_instr : std_logic_vector(2 downto 0);
  signal pcie_cmd_addr  : std_logic_vector(31 downto 0);
  signal pcie_wr_en     : std_logic;
  signal pcie_wr_end    : std_logic;
  signal pcie_wr_mask   : std_logic_vector(C_DDR_DATAWIDTH/8-1 downto 0);
  signal pcie_wr_data   : std_logic_vector(C_DDR_DATAWIDTH-1 downto 0);
  signal pcie_wr_rdy    : std_logic;
  signal pcie_rd_en     : std_logic;
  signal pcie_rd_data   : std_logic_vector(C_DDR_DATAWIDTH-1 downto 0);
  signal pcie_rd_valid  : std_logic;
  signal pcie_arb_gnt   : std_logic;
  signal pcie_arb_req   : std_logic;

  signal ext_cmd_rdy   : std_logic;
  signal ext_cmd_en    : std_logic;
  signal ext_cmd_instr : std_logic_vector(2 downto 0);
  signal ext_cmd_addr  : std_logic_vector(ADDR_WIDTH-1 downto 0);
  signal ext_wr_en     : std_logic;
  signal ext_wr_end    : std_logic;
  signal ext_wr_mask   : std_logic_vector(C_DDR_DATAWIDTH/8-1 downto 0);
  signal ext_wr_data   : std_logic_vector(C_DDR_DATAWIDTH-1 downto 0);
  signal ext_wr_rdy    : std_logic;
  signal ext_rd_en     : std_logic;
  signal ext_rd_data   : std_logic_vector(C_DDR_DATAWIDTH-1 downto 0);
  signal ext_rd_valid  : std_logic;
  signal ext_arb_gnt   : std_logic;
  signal ext_arb_req   : std_logic;

begin

  memc_ui_clk <= ui_clk;

  access_arb :
  process (ui_clk, user_reset)
  begin
    if user_reset = '1' then
      ext_arb_gnt  <= '0';
      pcie_arb_gnt <= '0';
      ddr_switch   <= PCIE;
    elsif rising_edge(ui_clk) then
      case arb_req is
        when "00" =>
          pcie_arb_gnt <= '0';
          ext_arb_gnt  <= '0';
          ddr_switch   <= ddr_switch;

        when "01" => --PCIE
          pcie_arb_gnt <= '1';
          ext_arb_gnt  <= '0';
          ddr_switch   <= PCIE;

        when "10" => --EXT
          pcie_arb_gnt <= '0';
          ext_arb_gnt  <= '1';
          ddr_switch   <= EXT;

        when "11" =>
          if (pcie_arb_gnt or ext_arb_gnt) = '1' then
            --we have already granted access, so wait until one of interested modules releases/gives up
            pcie_arb_gnt <= pcie_arb_gnt;
            ext_arb_gnt  <= ext_arb_gnt;
            ddr_switch   <= ddr_switch;
          else
            --simultaneous access request, favor PCIE
            pcie_arb_gnt <= '1';
            ext_arb_gnt  <= '0';
            ddr_switch   <= PCIE;
          end if;

        when others =>
          pcie_arb_gnt <= '0';
          ext_arb_gnt  <= '0';
          ddr_switch   <= ddr_switch;

      end case;
    end if;
  end process;

  arb_req <= ext_arb_req & pcie_arb_req;

  ddr_core_arb_mux :
  process (ddr_switch, pcie_cmd_addr, pcie_cmd_instr, pcie_cmd_en, pcie_wr_data, pcie_wr_en, pcie_wr_end, pcie_wr_mask,
           ext_cmd_addr, ext_cmd_instr, ext_cmd_en, ext_wr_data, ext_wr_en, ext_wr_end, ext_wr_mask, app_rdy,
           app_wdf_rdy, app_rd_data, app_rd_data_valid)
  begin
    case ddr_switch is
      when PCIE =>
        app_addr      <= pcie_cmd_addr(ADDR_WIDTH-1 downto 0);
        app_cmd       <= pcie_cmd_instr;
        app_en        <= pcie_cmd_en;
        app_wdf_data  <= pcie_wr_data;
        app_wdf_end   <= pcie_wr_end;
        app_wdf_mask  <= pcie_wr_mask;
        app_wdf_wren  <= pcie_wr_en;
        pcie_cmd_rdy  <= app_rdy;
        pcie_wr_rdy   <= app_wdf_rdy;
        pcie_rd_data  <= app_rd_data;
        pcie_rd_valid <= app_rd_data_valid;
        ext_cmd_rdy   <= '0';
        ext_wr_rdy    <= '0';
        ext_rd_data   <= (others => '0');
        ext_rd_valid  <= '0';

      when EXT =>
        app_addr      <= ext_cmd_addr;
        app_cmd       <= ext_cmd_instr;
        app_en        <= ext_cmd_en;
        app_wdf_data  <= ext_wr_data;
        app_wdf_end   <= ext_wr_end;
        app_wdf_mask  <= ext_wr_mask;
        app_wdf_wren  <= ext_wr_en;
        pcie_cmd_rdy  <= '0';
        pcie_wr_rdy   <= '0';
        pcie_rd_data  <= (others => '0');
        pcie_rd_valid <= '0';
        ext_cmd_rdy   <= app_rdy;
        ext_wr_rdy    <= app_wdf_rdy;
        ext_rd_data   <= app_rd_data;
        ext_rd_valid  <= app_rd_data_valid;

    end case;
  end process;

  memc_cmd_rdy   <= ext_cmd_rdy;
  ext_cmd_en     <= memc_cmd_en;
  ext_cmd_instr  <= memc_cmd_instr;
  ext_cmd_addr   <= memc_cmd_addr(ADDR_WIDTH - 1 downto 0);
  ext_wr_en      <= memc_wr_en;
  ext_wr_end     <= memc_wr_end;
  ext_wr_mask    <= memc_wr_mask;
  ext_wr_data    <= memc_wr_data;
  memc_wr_rdy    <= ext_wr_rdy;
  memc_rd_data   <= ext_rd_data;
  memc_rd_valid  <= ext_rd_valid;
  memarb_acc_gnt <= ext_arb_gnt;
  ext_arb_req    <= memarb_acc_req;

  DDR_Ready <= calib_done;
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
      init_calib_complete => calib_done,
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
      ui_clk            => ui_clk,
      ui_clk_sync_rst   => ui_reset,

      -- System Clock Ports
      sys_clk_p => ddr_sys_clk_p,
      sys_clk_n => ddr_sys_clk_n,
      -- Reference Clock Ports
      --clk_ref_i => ddr_ref_clk,

      sys_rst => sys_reset
    );

  u_ddr_control : DDRs_Control
    generic map (
      P_SIMULATION => SIMULATION
      )
    port map (
      -- FPGA interface --
      wr_clk   => user_clk, --: in  std_logic;
      wr_eof   => DDR_wr_eof, --: in  std_logic;
      wr_v     => DDR_wr_v, --: in  std_logic;
      wr_shift => DDR_wr_Shift, --: in  std_logic;
      wr_mask  => DDR_wr_Mask, --: in  std_logic_vector(2-1 downto 0);
      wr_din   => DDR_wr_din, --: in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wr_full  => DDR_wr_full, --: out std_logic;

      rd_clk    => user_clk, --: in  std_logic;
      rdc_v     => DDR_rdc_v, --: in  std_logic;
      rdc_shift => DDR_rdc_Shift, --: in  std_logic;
      rdc_din   => DDR_rdc_din, --: in  std_logic_vector(c_dbus_width-1 downto 0);
      rdc_full  => DDR_rdc_full, --: out std_logic;

      -- ddr payload fifo read port
      rdd_fifo_rden  => DDR_FIFO_RdEn, --: in  std_logic;
      rdd_fifo_empty => DDR_FIFO_Empty, --: out std_logic;
      rdd_fifo_dout  => DDR_FIFO_RdQout, --: out std_logic_vector(c_dbus_width-1 downto 0);

      -- memory controller interface --
      memc_cmd_rdy   => pcie_cmd_rdy, --: in   std_logic;
      memc_cmd_en    => pcie_cmd_en, --: out  std_logic;
      memc_cmd_instr => pcie_cmd_instr, --: out  std_logic_vector(2 downto 0);
      memc_cmd_addr  => pcie_cmd_addr, --: out  std_logic_vector(31 downto 0);
      memc_wr_en     => pcie_wr_en, --: out  std_logic;
      memc_wr_end    => pcie_wr_end, --: out  std_logic;
      memc_wr_mask   => pcie_wr_mask, --: out  std_logic_vector(data_width/8-1 downto 0);
      memc_wr_data   => pcie_wr_data, --: out  std_logic_vector(data_width-1 downto 0);
      memc_wr_rdy    => pcie_wr_rdy, --: in   std_logic;
      memc_rd_en     => pcie_rd_en, --: out  std_logic;
      memc_rd_data   => pcie_rd_data, --: in   std_logic_vector(data_width-1 downto 0);
      memc_rd_valid  => pcie_rd_valid, --: in   std_logic;

      -- memory arbiter interface
      memarb_acc_req => pcie_arb_req, --: out std_logic;
      memarb_acc_gnt => pcie_arb_gnt, --: in  std_logic;

      memc_ui_clk => ui_clk, --: in std_logic;
      ddr_rdy     => calib_done, --: in std_logic;
      reset       => user_reset   --: in std_logic
    );

end architecture Behavioral;
