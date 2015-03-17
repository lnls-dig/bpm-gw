library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr_core_wrapper is
  generic
  (
   PAYLOAD_WIDTH         : integer := 32;
   MEM_ADDR_ORDER        : string  := "TG_TEST";
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
   DQ_CNT_WIDTH          : integer := 5;
                                     -- = ceil(log2(DQ_WIDTH))
   DQ_PER_DM             : integer := 8;
   DM_WIDTH              : integer := 4;
                                     -- # of DM (data mask)
   DQ_WIDTH              : integer := 32;
                                     -- # of DQ (data)
   DQS_WIDTH             : integer := 4;
   DQS_CNT_WIDTH         : integer := 2;
                                     -- = ceil(log2(DQS_WIDTH))
   DRAM_WIDTH            : integer := 8;
                                     -- # of DQ per DQS
   ECC                   : string  := "OFF";
   nBANK_MACHS           : integer := 4;
   RANKS                 : integer := 1;
                                     -- # of Ranks.
   ODT_WIDTH             : integer := 1;
                                     -- # of ODT outputs to memory.
   ROW_WIDTH             : integer := 16;
                                     -- # of memory Row Address bits.
   ADDR_WIDTH            : integer := 30;
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
                                     -- Parameter configuration for Dynamic ODT support:
                                     -- USE_ODT_PORT = 0, RTT_NOM = "DISABLED", RTT_WR = "60/120".
                                     -- This configuration allows to save ODT pin mapping from FPGA.
                                     -- The user can tie the ODT input of DRAM to HIGH.
   PHY_CONTROL_MASTER_BANK : integer := 1;
                                     -- The bank index where master PHY_CONTROL resides,
                                     -- equal to the PLL residing bank
   MEM_DENSITY             : string  := "4Gb";
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
   CL                    : integer := 6;
                                     -- in number of clock cycles
                                     -- DDR3 SDRAM: CAS Latency (Mode Register 0).
                                     -- DDR2 SDRAM: CAS Latency (Mode Register).
   CWL                   : integer := 5;
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
   CLKIN_PERIOD          : integer := -2147483647;
                                     -- Input Clock Period
   CLKFBOUT_MULT         : integer := 0;
                                     -- write PLL VCO multiplier
   DIVCLK_DIVIDE         : integer := 0;
                                     -- write PLL VCO divisor
   CLKOUT0_PHASE         : real    := 337.5;
                                     -- Phase for PLL output clock (CLKOUT0)
   CLKOUT0_DIVIDE        : integer := 0;
                                     -- VCO output divisor for PLL output clock (CLKOUT0)
   CLKOUT1_DIVIDE        : integer := 0;
                                     -- VCO output divisor for PLL output clock (CLKOUT1)
   CLKOUT2_DIVIDE        : integer := 0;
                                     -- VCO output divisor for PLL output clock (CLKOUT2)
   CLKOUT3_DIVIDE        : integer := 0;
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
   tRCD                  : integer := 13750;
                                     -- memory tRCD paramter in pS.
   tREFI                 : integer := 7800000;
                                     -- memory tREFI paramter in pS.
   tRFC                  : integer := 300000;
                                     -- memory tRFC paramter in pS.
   tRP                   : integer := 13750;
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
   SIM_BYPASS_INIT_CAL   : string  := "OFF";
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
   BYTE_LANES_B1         : std_logic_vector(3 downto 0) := "1110";
                                     -- Byte lanes used in an IO column.
   BYTE_LANES_B2         : std_logic_vector(3 downto 0) := "0000";
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
   DATA_CTL_B2           : std_logic_vector(3 downto 0) := "0000";
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
   PHY_0_BITLANES        : std_logic_vector(47 downto 0) := X"3FE3FD2FF2FF";
   PHY_1_BITLANES        : std_logic_vector(47 downto 0) := X"FFEFF3CC0000";
   PHY_2_BITLANES        : std_logic_vector(47 downto 0) := X"000000000000";

   -- control/address/data pin mapping parameters
   CK_BYTE_MAP
     : std_logic_vector(143 downto 0) := X"000000000000000000000000000000000012";
   ADDR_MAP
     : std_logic_vector(191 downto 0) := X"13211A11712A11B13A12512012B126131129116124121128";
   BANK_MAP   : std_logic_vector(35 downto 0) := X"13613713B";
   CAS_MAP    : std_logic_vector(11 downto 0) := X"135";
   CKE_ODT_BYTE_MAP : std_logic_vector(7 downto 0) := X"00";
   CKE_MAP    : std_logic_vector(95 downto 0) := X"000000000000000000000127";
   ODT_MAP    : std_logic_vector(95 downto 0) := X"000000000000000000000138";
   CS_MAP     : std_logic_vector(119 downto 0) := X"000000000000000000000000000133";
   PARITY_MAP : std_logic_vector(11 downto 0) := X"000";
   RAS_MAP    : std_logic_vector(11 downto 0) := X"139";
   WE_MAP     : std_logic_vector(11 downto 0) := X"134";
   DQS_BYTE_MAP
     : std_logic_vector(143 downto 0) := X"000000000000000000000000000003020100";
   DATA0_MAP  : std_logic_vector(95 downto 0) := X"009006002004003007000005";
   DATA1_MAP  : std_logic_vector(95 downto 0) := X"017014010015013011016019";
   DATA2_MAP  : std_logic_vector(95 downto 0) := X"024026023027022025020029";
   DATA3_MAP  : std_logic_vector(95 downto 0) := X"034037031035033036032039";
   DATA4_MAP  : std_logic_vector(95 downto 0) := X"000000000000000000000000";
   DATA5_MAP  : std_logic_vector(95 downto 0) := X"000000000000000000000000";
   DATA6_MAP  : std_logic_vector(95 downto 0) := X"000000000000000000000000";
   DATA7_MAP  : std_logic_vector(95 downto 0) := X"000000000000000000000000";
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
   MASK0_MAP  : std_logic_vector(107 downto 0) := X"000000000000000038028012001";
   MASK1_MAP  : std_logic_vector(107 downto 0) := X"000000000000000000000000000";

   SLOT_0_CONFIG         : std_logic_vector(7 downto 0) := "00000001";
                                     -- Mapping of Ranks.
   SLOT_1_CONFIG         : std_logic_vector(7 downto 0) := "00000000";
                                     -- Mapping of Ranks.

   --***************************************************************************
   -- IODELAY and PHY related parameters
   --***************************************************************************
   IODELAY_HP_MODE       : string  := "ON";
                                     -- to phy_top
   IBUF_LPWR_MODE        : string  := "OFF";
                                     -- to phy_top
   DATA_IO_IDLE_PWRDWN   : string  := "OFF";
                                     -- # = "ON", "OFF"
   BANK_TYPE             : string  := "HR_IO";
                                     -- # = "HP_IO", "HPL_IO", "HR_IO", "HRL_IO"
   DATA_IO_PRIM_TYPE     : string  := "DEFAULT";
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
   SYSCLK_TYPE           : string  := "NO_BUFFER";
                                     -- System clock type DIFFERENTIAL, SINGLE_ENDED,
                                     -- NO_BUFFER
   REFCLK_TYPE           : string  := "USE_SYSTEM_CLOCK";
                                     -- Reference clock type DIFFERENTIAL, SINGLE_ENDED
                                     -- NO_BUFFER, USE_SYSTEM_CLOCK
   SYS_RST_PORT          : string  := "FALSE";
                                     -- "TRUE" - if pin is selected for sys_rst
                                     --          and IBUF will be instantiated.
                                     -- "FALSE" - if pin is not selected for sys_rst

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
   tCK                   : integer := 2500;
                                     -- memory tCK paramter.
                                     -- # = Clock Period in pS.
   nCK_PER_CLK           : integer := 4;
                                     -- # of memory CKs per fabric CLK
   DIFF_TERM_SYSCLK      : string  := "TRUE";
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
  port
  (
   -- Inouts
   ddr3_dq                        : inout std_logic_vector(DQ_WIDTH-1 downto 0);
   ddr3_dqs_p                     : inout std_logic_vector(DQS_WIDTH-1 downto 0);
   ddr3_dqs_n                     : inout std_logic_vector(DQS_WIDTH-1 downto 0);

   -- Outputs
   ddr3_addr                      : out   std_logic_vector(ROW_WIDTH-1 downto 0);
   ddr3_ba                        : out   std_logic_vector(BANK_WIDTH-1 downto 0);
   ddr3_ras_n                     : out   std_logic;
   ddr3_cas_n                     : out   std_logic;
   ddr3_we_n                      : out   std_logic;
   ddr3_reset_n                   : out   std_logic;
   ddr3_ck_p                      : out   std_logic_vector(CK_WIDTH-1 downto 0);
   ddr3_ck_n                      : out   std_logic_vector(CK_WIDTH-1 downto 0);
   ddr3_cke                       : out   std_logic_vector(CKE_WIDTH-1 downto 0);
   ddr3_cs_n                      : out   std_logic_vector(CS_WIDTH*nCS_PER_RANK-1 downto 0);
   ddr3_dm                        : out   std_logic_vector(DM_WIDTH-1 downto 0);
   ddr3_odt                       : out   std_logic_vector(ODT_WIDTH-1 downto 0);

   -- Inputs
   -- Single-ended system clock
   sys_clk_i                      : in std_logic;

   init_calib_complete            : out std_logic;

   -- DDR user interface
   app_addr                      : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
   app_cmd                       : in    std_logic_vector(2 downto 0);
   app_en                        : in    std_logic;
   app_wdf_data                  : in    std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
   app_wdf_end                   : in    std_logic;
   app_wdf_mask                  : in    std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)/8-1 downto 0);
   app_wdf_wren                  : in    std_logic;
   app_rd_data                   : out   std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
   app_rd_data_end               : out   std_logic;
   app_rd_data_valid             : out   std_logic;
   app_rdy                       : out   std_logic;
   app_wdf_rdy                   : out   std_logic;
   app_sr_req                    : in    std_logic;
   app_sr_active                 : out   std_logic;
   app_ref_req                   : in    std_logic;
   app_ref_ack                   : out   std_logic;
   app_zq_req                    : in    std_logic;
   app_zq_ack                    : out   std_logic;
   ui_clk                        : out   std_logic;
   ui_clk_sync_rst               : out   std_logic;

   -- System reset - Default polarity of sys_rst pin is Active Low.
   -- System reset polarity will change based on the option
   -- selected in GUI.
   sys_rst                        : in std_logic
 );

end entity ddr_core_wrapper;

architecture rtl of ddr_core_wrapper is


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
  end function;function STR_TO_INT(BM : string) return integer is
  begin
   if(BM = "8") then
     return 8;
   elsif(BM = "4") then
     return 4;
   else
     return 0;
   end if;
  end function;

  constant DATA_WIDTH            : integer := 32;

  function ECCWIDTH return integer is
  begin
    if(ECC = "OFF") then
      return 0;
    else
      if(DATA_WIDTH <= 4) then
        return 4;
      elsif(DATA_WIDTH <= 10) then
        return 5;
      elsif(DATA_WIDTH <= 26) then
        return 6;
      elsif(DATA_WIDTH <= 57) then
        return 7;
      elsif(DATA_WIDTH <= 120) then
        return 8;
      elsif(DATA_WIDTH <= 247) then
        return 9;
      else
        return 10;
      end if;
    end if;
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



  constant CMD_PIPE_PLUS1        : string  := "ON";
                                     -- add pipeline stage between MC and PHY
  constant ECC_WIDTH             : integer := ECCWIDTH;
  constant ECC_TEST              : string  := "OFF";
  constant DATA_BUF_OFFSET_WIDTH : integer := 1;
  constant MC_ERR_ADDR_WIDTH     : integer := XWIDTH + BANK_WIDTH + ROW_WIDTH
                                          + COL_WIDTH + DATA_BUF_OFFSET_WIDTH;
  constant tPRDI                 : integer := 1000000;
                                     -- memory tPRDI paramter in pS.
  -- constant PAYLOAD_WIDTH         : integer := DATA_WIDTH;
  constant BURST_LENGTH          : integer := STR_TO_INT(BURST_MODE);
  constant APP_DATA_WIDTH        : integer := 2 * nCK_PER_CLK * PAYLOAD_WIDTH;
  constant APP_MASK_WIDTH        : integer := APP_DATA_WIDTH / 8;

  --***************************************************************************
  -- Traffic Gen related parameters (derived)
  --***************************************************************************
  constant  TG_ADDR_WIDTH        : integer := XWIDTH + BANK_WIDTH + ROW_WIDTH + COL_WIDTH;
  constant MASK_SIZE             : integer := DATA_WIDTH/8;

  component ddr_core
    generic(
    --  BANK_WIDTH            : integer;
    --  CK_WIDTH              : integer;
    --  COL_WIDTH             : integer;
    --  CS_WIDTH              : integer;
    --  nCS_PER_RANK          : integer;
    --  CKE_WIDTH             : integer;
    --  DATA_BUF_ADDR_WIDTH   : integer;
    --  DQ_CNT_WIDTH          : integer;
    --  DQ_PER_DM             : integer;
    --  DM_WIDTH              : integer;
    --  DQ_WIDTH              : integer;
    --  DQS_WIDTH             : integer;
    --  DQS_CNT_WIDTH         : integer;
    --  DRAM_WIDTH            : integer;
    --  ECC                   : string;
    --  DATA_WIDTH            : integer;
    --  ECC_TEST              : string;
    --  PAYLOAD_WIDTH         : integer;
    --  ECC_WIDTH             : integer;
    --  MC_ERR_ADDR_WIDTH     : integer;
    --  nBANK_MACHS           : integer;
    --  RANKS                 : integer;
    --  ODT_WIDTH             : integer;
    --  ROW_WIDTH             : integer;
    --  ADDR_WIDTH            : integer;
    --  USE_CS_PORT           : integer;
    --  USE_DM_PORT           : integer;
    --  USE_ODT_PORT          : integer;
    --  PHY_CONTROL_MASTER_BANK : integer;
    --  AL                    : string;
    --  nAL                   : integer;
    --  BURST_MODE            : string;
    --  BURST_TYPE            : string;
    --  CL                    : integer;
    --  CWL                   : integer;
    --  OUTPUT_DRV            : string;
    --  RTT_NOM               : string;
    --  RTT_WR                : string;
    --  ADDR_CMD_MODE         : string;
    --  REG_CTRL              : string;
    --  CA_MIRROR             : string;
    --  CLKIN_PERIOD          : integer;
    --  CLKFBOUT_MULT         : integer;
    --  DIVCLK_DIVIDE         : integer;
    --  CLKOUT0_PHASE         : real;
    --  CLKOUT0_DIVIDE        : integer;
    --  CLKOUT1_DIVIDE        : integer;
    --  CLKOUT2_DIVIDE        : integer;
    --  CLKOUT3_DIVIDE        : integer;
    --  tCKE                  : integer;
    --  tFAW                  : integer;
    --  tRAS                  : integer;
    --  tRCD                  : integer;
    --  tREFI                 : integer;
    --  tRFC                  : integer;
    --  tRP                   : integer;
    --  tRRD                  : integer;
    --  tRTP                  : integer;
    --  tWTR                  : integer;
    --  tZQI                  : integer;
    --  tZQCS                 : integer;
    --  tPRDI                 : integer;
      SIM_BYPASS_INIT_CAL   : string;
      SIMULATION            : string;
    --  BYTE_LANES_B0         : std_logic_vector(3 downto 0);
    --  BYTE_LANES_B1         : std_logic_vector(3 downto 0);
    --  BYTE_LANES_B2         : std_logic_vector(3 downto 0);
    --  BYTE_LANES_B3         : std_logic_vector(3 downto 0);
    --  BYTE_LANES_B4         : std_logic_vector(3 downto 0);
    --  DATA_CTL_B0           : std_logic_vector(3 downto 0);
    --  DATA_CTL_B1           : std_logic_vector(3 downto 0);
    --  DATA_CTL_B2           : std_logic_vector(3 downto 0);
    --  DATA_CTL_B3           : std_logic_vector(3 downto 0);
    --  DATA_CTL_B4           : std_logic_vector(3 downto 0);
    --  PHY_0_BITLANES        : std_logic_vector(47 downto 0);
    --  PHY_1_BITLANES        : std_logic_vector(47 downto 0);
    --  PHY_2_BITLANES        : std_logic_vector(47 downto 0);
    --  CK_BYTE_MAP           : std_logic_vector(143 downto 0);
    --  ADDR_MAP              : std_logic_vector(191 downto 0);
    --  BANK_MAP              : std_logic_vector(35 downto 0);
    --  CAS_MAP               : std_logic_vector(11 downto 0);
    --  CKE_ODT_BYTE_MAP      : std_logic_vector(7 downto 0);
    --  CKE_MAP               : std_logic_vector(95 downto 0);
    --  ODT_MAP               : std_logic_vector(95 downto 0);
    --  CS_MAP                : std_logic_vector(119 downto 0);
    --  PARITY_MAP            : std_logic_vector(11 downto 0);
    --  RAS_MAP               : std_logic_vector(11 downto 0);
    --  WE_MAP                : std_logic_vector(11 downto 0);
    --  DQS_BYTE_MAP          : std_logic_vector(143 downto 0);
    --  DATA0_MAP             : std_logic_vector(95 downto 0);
    --  DATA1_MAP             : std_logic_vector(95 downto 0);
    --  DATA2_MAP             : std_logic_vector(95 downto 0);
    --  DATA3_MAP             : std_logic_vector(95 downto 0);
    --  DATA4_MAP             : std_logic_vector(95 downto 0);
    --  DATA5_MAP             : std_logic_vector(95 downto 0);
    --  DATA6_MAP             : std_logic_vector(95 downto 0);
    --  DATA7_MAP             : std_logic_vector(95 downto 0);
    --  DATA8_MAP             : std_logic_vector(95 downto 0);
    --  DATA9_MAP             : std_logic_vector(95 downto 0);
    --  DATA10_MAP            : std_logic_vector(95 downto 0);
    --  DATA11_MAP            : std_logic_vector(95 downto 0);
    --  DATA12_MAP            : std_logic_vector(95 downto 0);
    --  DATA13_MAP            : std_logic_vector(95 downto 0);
    --  DATA14_MAP            : std_logic_vector(95 downto 0);
    --  DATA15_MAP            : std_logic_vector(95 downto 0);
    --  DATA16_MAP            : std_logic_vector(95 downto 0);
    --  DATA17_MAP            : std_logic_vector(95 downto 0);
    --  MASK0_MAP             : std_logic_vector(107 downto 0);
    --  MASK1_MAP             : std_logic_vector(107 downto 0);
    --  SLOT_0_CONFIG         : std_logic_vector(7 downto 0);
    --  SLOT_1_CONFIG         : std_logic_vector(7 downto 0);
    --  MEM_ADDR_ORDER        : string;
    --  IODELAY_HP_MODE       : string;
    --  IBUF_LPWR_MODE        : string;
    --  DATA_IO_IDLE_PWRDWN   : string;
    --  BANK_TYPE             : string;
    --  DATA_IO_PRIM_TYPE     : string;
    --  CKE_ODT_AUX           : string;
    --  USER_REFRESH          : string;
    --  WRLVL                 : string;
    --  ORDERING              : string;
    --  CALIB_ROW_ADD         : std_logic_vector(15 downto 0);
    --  CALIB_COL_ADD         : std_logic_vector(11 downto 0);
    --  CALIB_BA_ADD          : std_logic_vector(2 downto 0);
    --  TCQ                   : integer;
    --  CMD_PIPE_PLUS1        : string;
    --  tCK                   : integer;
    --  nCK_PER_CLK           : integer;
    --  DIFF_TERM_SYSCLK      : string;
    --  DEBUG_PORT            : string;
    --  TEMP_MON_CONTROL      : string;


    --  IODELAY_GRP           : string;
    --  SYSCLK_TYPE           : string;
    --  REFCLK_TYPE           : string;
    --  SYS_RST_PORT          : string;
    --  REFCLK_FREQ           : real;
    --  DIFF_TERM_REFCLK      : string;

    --  DRAM_TYPE             : string;
    --  CAL_WIDTH             : string;
    --  STARVE_LIMIT          : integer;


      RST_ACT_LOW           : integer
      );
    port(


      ddr3_dq                       : inout std_logic_vector(DQ_WIDTH-1 downto 0);
      ddr3_dqs_p                    : inout std_logic_vector(DQS_WIDTH-1 downto 0);
      ddr3_dqs_n                    : inout std_logic_vector(DQS_WIDTH-1 downto 0);

      ddr3_addr                     : out   std_logic_vector(ROW_WIDTH-1 downto 0);
      ddr3_ba                       : out   std_logic_vector(BANK_WIDTH-1 downto 0);
      ddr3_ras_n                    : out   std_logic;
      ddr3_cas_n                    : out   std_logic;
      ddr3_we_n                     : out   std_logic;
      ddr3_reset_n                  : out   std_logic;
      ddr3_ck_p                     : out   std_logic_vector(CK_WIDTH-1 downto 0);
      ddr3_ck_n                     : out   std_logic_vector(CK_WIDTH-1 downto 0);
      ddr3_cke                      : out   std_logic_vector(CKE_WIDTH-1 downto 0);

      ddr3_cs_n                     : out   std_logic_vector((CS_WIDTH*nCS_PER_RANK)-1 downto 0);
      ddr3_dm                       : out   std_logic_vector(DM_WIDTH-1 downto 0);
      ddr3_odt                      : out   std_logic_vector(ODT_WIDTH-1 downto 0);

      app_addr                      : in    std_logic_vector(ADDR_WIDTH-1 downto 0);
      app_cmd                       : in    std_logic_vector(2 downto 0);
      app_en                        : in    std_logic;
      app_wdf_data                  : in    std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
      app_wdf_end                   : in    std_logic;
      app_wdf_mask                  : in    std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)/8-1 downto 0);
      app_wdf_wren                  : in    std_logic;
      app_rd_data                   : out   std_logic_vector((nCK_PER_CLK*2*PAYLOAD_WIDTH)-1 downto 0);
      app_rd_data_end               : out   std_logic;
      app_rd_data_valid             : out   std_logic;
      app_rdy                       : out   std_logic;
      app_wdf_rdy                   : out   std_logic;
      app_sr_req                    : in    std_logic;
      app_sr_active                 : out   std_logic;
      app_ref_req                   : in    std_logic;
      app_ref_ack                   : out   std_logic;
      app_zq_req                    : in    std_logic;
      app_zq_ack                    : out   std_logic;
      ui_clk                        : out   std_logic;
      ui_clk_sync_rst               : out   std_logic;
      init_calib_complete           : out   std_logic;


      -- System Clock Ports
      sys_clk_i                     : in    std_logic;

      sys_rst                       : in std_logic
      );
  end component ddr_core;

begin

  u_ddr_core : ddr_core
  generic map (
    --TCQ                              => TCQ,
    --ADDR_CMD_MODE                    => ADDR_CMD_MODE,
    --AL                               => AL,
    --PAYLOAD_WIDTH                    => PAYLOAD_WIDTH,
    --BANK_WIDTH                       => BANK_WIDTH,
    --BURST_MODE                       => BURST_MODE,
    --BURST_TYPE                       => BURST_TYPE,
    --CA_MIRROR                        => CA_MIRROR,
    --CK_WIDTH                         => CK_WIDTH,
    --COL_WIDTH                        => COL_WIDTH,
    --CMD_PIPE_PLUS1                   => CMD_PIPE_PLUS1,
    --CS_WIDTH                         => CS_WIDTH,
    --nCS_PER_RANK                     => nCS_PER_RANK,
    --CKE_WIDTH                        => CKE_WIDTH,
    --DATA_WIDTH                       => DATA_WIDTH,
    --DATA_BUF_ADDR_WIDTH              => DATA_BUF_ADDR_WIDTH,
    --DQ_CNT_WIDTH                     => DQ_CNT_WIDTH,
    --DQ_PER_DM                        => DQ_PER_DM,
    --DQ_WIDTH                         => DQ_WIDTH,
    --DQS_CNT_WIDTH                    => DQS_CNT_WIDTH,
    --DQS_WIDTH                        => DQS_WIDTH,
    --DRAM_WIDTH                       => DRAM_WIDTH,
    --ECC                              => ECC,
    --ECC_WIDTH                        => ECC_WIDTH,
    --ECC_TEST                         => ECC_TEST,
    --MC_ERR_ADDR_WIDTH                => MC_ERR_ADDR_WIDTH,
    --nAL                              => nAL,
    --nBANK_MACHS                      => nBANK_MACHS,
    --CKE_ODT_AUX                      => CKE_ODT_AUX,
    --ORDERING                         => ORDERING,
    --OUTPUT_DRV                       => OUTPUT_DRV,
    --IBUF_LPWR_MODE                   => IBUF_LPWR_MODE,
    --IODELAY_HP_MODE                  => IODELAY_HP_MODE,
    --DATA_IO_IDLE_PWRDWN              => DATA_IO_IDLE_PWRDWN,
    --BANK_TYPE                        => BANK_TYPE,
    --DATA_IO_PRIM_TYPE                => DATA_IO_PRIM_TYPE,
    --REG_CTRL                         => REG_CTRL,
    --RTT_NOM                          => RTT_NOM,
    --RTT_WR                           => RTT_WR,
    --CL                               => CL,
    --CWL                              => CWL,
    --tCKE                             => tCKE,
    --tFAW                             => tFAW,
    --tPRDI                            => tPRDI,
    --tRAS                             => tRAS,
    --tRCD                             => tRCD,
    --tREFI                            => tREFI,
    --tRFC                             => tRFC,
    --tRP                              => tRP,
    --tRRD                             => tRRD,
    --tRTP                             => tRTP,
    --tWTR                             => tWTR,
    --tZQI                             => tZQI,
    --tZQCS                            => tZQCS,
    --USER_REFRESH                     => USER_REFRESH,
    --WRLVL                            => WRLVL,
    --DEBUG_PORT                       => DEBUG_PORT,
    --RANKS                            => RANKS,
    --ODT_WIDTH                        => ODT_WIDTH,
    --ROW_WIDTH                        => ROW_WIDTH,
    --ADDR_WIDTH                       => ADDR_WIDTH,
    SIM_BYPASS_INIT_CAL              => SIM_BYPASS_INIT_CAL,
    SIMULATION                       => SIMULATION,
    --BYTE_LANES_B0                    => BYTE_LANES_B0,
    --BYTE_LANES_B1                    => BYTE_LANES_B1,
    --BYTE_LANES_B2                    => BYTE_LANES_B2,
    --BYTE_LANES_B3                    => BYTE_LANES_B3,
    --BYTE_LANES_B4                    => BYTE_LANES_B4,
    --DATA_CTL_B0                      => DATA_CTL_B0,
    --DATA_CTL_B1                      => DATA_CTL_B1,
    --DATA_CTL_B2                      => DATA_CTL_B2,
    --DATA_CTL_B3                      => DATA_CTL_B3,
    --DATA_CTL_B4                      => DATA_CTL_B4,
    --PHY_0_BITLANES                   => PHY_0_BITLANES,
    --PHY_1_BITLANES                   => PHY_1_BITLANES,
    --PHY_2_BITLANES                   => PHY_2_BITLANES,
    --CK_BYTE_MAP                      => CK_BYTE_MAP,
    --ADDR_MAP                         => ADDR_MAP,
    --BANK_MAP                         => BANK_MAP,
    --CAS_MAP                          => CAS_MAP,
    --CKE_ODT_BYTE_MAP                 => CKE_ODT_BYTE_MAP,
    --CKE_MAP                          => CKE_MAP,
    --ODT_MAP                          => ODT_MAP,
    --CS_MAP                           => CS_MAP,
    --PARITY_MAP                       => PARITY_MAP,
    --RAS_MAP                          => RAS_MAP,
    --WE_MAP                           => WE_MAP,
    --DQS_BYTE_MAP                     => DQS_BYTE_MAP,
    --DATA0_MAP                        => DATA0_MAP,
    --DATA1_MAP                        => DATA1_MAP,
    --DATA2_MAP                        => DATA2_MAP,
    --DATA3_MAP                        => DATA3_MAP,
    --DATA4_MAP                        => DATA4_MAP,
    --DATA5_MAP                        => DATA5_MAP,
    --DATA6_MAP                        => DATA6_MAP,
    --DATA7_MAP                        => DATA7_MAP,
    --DATA8_MAP                        => DATA8_MAP,
    --DATA9_MAP                        => DATA9_MAP,
    --DATA10_MAP                       => DATA10_MAP,
    --DATA11_MAP                       => DATA11_MAP,
    --DATA12_MAP                       => DATA12_MAP,
    --DATA13_MAP                       => DATA13_MAP,
    --DATA14_MAP                       => DATA14_MAP,
    --DATA15_MAP                       => DATA15_MAP,
    --DATA16_MAP                       => DATA16_MAP,
    --DATA17_MAP                       => DATA17_MAP,
    --MASK0_MAP                        => MASK0_MAP,
    --MASK1_MAP                        => MASK1_MAP,
    --CALIB_ROW_ADD                    => CALIB_ROW_ADD,
    --CALIB_COL_ADD                    => CALIB_COL_ADD,
    --CALIB_BA_ADD                     => CALIB_BA_ADD,
    --SLOT_0_CONFIG                    => SLOT_0_CONFIG,
    --SLOT_1_CONFIG                    => SLOT_1_CONFIG,
    --MEM_ADDR_ORDER                   => MEM_ADDR_ORDER,
    --USE_CS_PORT                      => USE_CS_PORT,
    --USE_DM_PORT                      => USE_DM_PORT,
    --USE_ODT_PORT                     => USE_ODT_PORT,
    --PHY_CONTROL_MASTER_BANK          => PHY_CONTROL_MASTER_BANK,
    --TEMP_MON_CONTROL                 => TEMP_MON_CONTROL,

    --DM_WIDTH                         => DM_WIDTH,

    --nCK_PER_CLK                      => nCK_PER_CLK,
    --tCK                              => tCK,
    --DIFF_TERM_SYSCLK                 => DIFF_TERM_SYSCLK,
    --CLKIN_PERIOD                     => CLKIN_PERIOD,
    --CLKFBOUT_MULT                    => CLKFBOUT_MULT,
    --DIVCLK_DIVIDE                    => DIVCLK_DIVIDE,
    --CLKOUT0_PHASE                    => CLKOUT0_PHASE,
    --CLKOUT0_DIVIDE                   => CLKOUT0_DIVIDE,
    --CLKOUT1_DIVIDE                   => CLKOUT1_DIVIDE,
    --CLKOUT2_DIVIDE                   => CLKOUT2_DIVIDE,
    --CLKOUT3_DIVIDE                   => CLKOUT3_DIVIDE,

    --SYSCLK_TYPE                      => SYSCLK_TYPE,
    --REFCLK_TYPE                      => REFCLK_TYPE,
    --SYS_RST_PORT                     => SYS_RST_PORT,
    --REFCLK_FREQ                      => REFCLK_FREQ,
    --DIFF_TERM_REFCLK                 => DIFF_TERM_REFCLK,
    --IODELAY_GRP                      => IODELAY_GRP,

    --CAL_WIDTH                        => CAL_WIDTH,
    --STARVE_LIMIT                     => STARVE_LIMIT,
    --DRAM_TYPE                        => DRAM_TYPE,

    RST_ACT_LOW                      => RST_ACT_LOW
  )
  port map (
    -- Memory interface ports
    ddr3_addr                        => ddr3_addr,
    ddr3_ba                          => ddr3_ba,
    ddr3_cas_n                       => ddr3_cas_n,
    ddr3_ck_n                        => ddr3_ck_n,
    ddr3_ck_p                        => ddr3_ck_p,
    ddr3_cke                         => ddr3_cke,
    ddr3_ras_n                       => ddr3_ras_n,
    ddr3_reset_n                     => ddr3_reset_n,
    ddr3_we_n                        => ddr3_we_n,
    ddr3_dq                          => ddr3_dq,
    ddr3_dqs_n                       => ddr3_dqs_n,
    ddr3_dqs_p                       => ddr3_dqs_p,
    init_calib_complete              => init_calib_complete,

    ddr3_cs_n                        => ddr3_cs_n,
    ddr3_dm                          => ddr3_dm,
    ddr3_odt                         => ddr3_odt,

    -- Application interface ports
    app_addr                         => app_addr,
    app_cmd                          => app_cmd,
    app_en                           => app_en,
    app_wdf_data                     => app_wdf_data,
    app_wdf_end                      => app_wdf_end,
    app_wdf_wren                     => app_wdf_wren,
    app_rd_data                      => app_rd_data,
    app_rd_data_end                  => app_rd_data_end,
    app_rd_data_valid                => app_rd_data_valid,
    app_rdy                          => app_rdy,
    app_wdf_rdy                      => app_wdf_rdy,
    app_sr_req                       => '0',
    app_sr_active                    => app_sr_active,
    app_ref_req                      => '0',
    app_ref_ack                      => app_ref_ack,
    app_zq_req                       => '0',
    app_zq_ack                       => app_zq_ack,
    ui_clk                           => ui_clk,
    ui_clk_sync_rst                  => ui_clk_sync_rst,

    app_wdf_mask                     => app_wdf_mask,

    -- System Clock Ports
    sys_clk_i                        => sys_clk_i,

    sys_rst                          => sys_rst
  );

end architecture rtl;
