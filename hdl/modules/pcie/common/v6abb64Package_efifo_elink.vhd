--      -------------------------------------------------------------
--
--      Purpose: This package defines supplemental types, subtypes,
--               constants, and functions
--
--     Nov 2008 --> 64-bit
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

package abb64Package is


  -- Implemet a design with only one FIFO and only one BRAM Module: For Loopback Test!!
  constant USE_LOOPBACK_TEST : boolean := false;


-- Declare constants

  -- ----------------------------------------------------------------------
  -- Address definitions

  --  The 2 MSB's are for Addressing, i.e.
  --
  --  0x0000         : Design ID
  --  0x0008         : Interrupt status
  --  0x0010         : Interrupt enable
  --  0x0018         : General error
  --  0x001C         : DDR SDRAM address page
  --  0x0020         : General status
  --  0x0024         : Wishbone address page
  --  0x0028         : General control

  --  0x002C ~ 0x004C: DMA upstream registers
  --  0x0050 ~ 0x0070: DMA upstream registers

  --  0x0074         : MRd channel control
  --  0x0078         : CplD channel control
  --  0x007C         : ICAP input/output

  --  0x0080 ~ 0x008C: Interrupt Generator (IG) registers

  --  0x4010         : TxFIFO write port
  --  0x4018         : W - TxFIFO Reset
  --                 : R - TxFIFO Vacancy status

  --  0x4020         : RxFIFO read port
  --  0x4028         : W - RxFIFO Reset
  --                 : R - RxFIFO Occupancy status

  --  0x8000 ~ 0xBFFF: BRAM space (BAR1)

  --  Others         : Reserved


  ------------------------------------------------------------------------
  --  Global Constants
  --

  ---       Number of Lanes for PCIe, 1, 4 or 8
  constant C_NUM_PCIE_LANES : integer := 1;

  ---       Data bus width
  constant C_DBUS_WIDTH : integer := 64;
  constant C_DATA_WIDTH : integer := C_DBUS_WIDTH;

  ---       Event Buffer: FIFO Data Count width
  constant C_FIFO_DC_WIDTH     : integer := 26;
  ---       Small BRAM FIFO for emulation
  constant C_EMU_FIFO_DC_WIDTH : integer := 15;  --S 14 x fifo originale ; 15 x fifo grande!!

  ---       Address width for endpoint device/peripheral
  --
  constant C_EP_AWIDTH : integer range 10 to 30 := 10;

  ---       Buffer width from the PCIe Core
  constant C_TBUF_AWIDTH : integer := 6;  -- 4;  -- 5;

  ---       Width for Tx output Arbitration
  constant C_ARBITRATE_WIDTH : integer := 4;

  ---       Number of BAR spaces
  constant CINT_BAR_SPACES : integer := 6;

  ---       Max BAR number, 7
  constant C_BAR_NUMBER        : integer := 7;
  ---       Encoded BAR number takes 3 bits to represent 0~6.  7 means invalid or don't care
  constant C_ENCODE_BAR_NUMBER : integer := 3;

  ---       Number of Channels, currently 4: Interrupt, PIO MRd, upstream DMA, downstream DMA
  constant C_CHANNEL_NUMBER : integer := 4;

  ---       Data width of the channel buffers (FIFOs)
  constant C_CHANNEL_BUF_WIDTH : integer := 128;

  ---       Higher 4 bits are for tag decoding
  constant C_TAG_DECODE_BITS : integer := 4;

  ---       DDR SDRAM bank address pin number
  constant C_DDR_BANK_AWIDTH : integer := 2;

  ---       DDR SDRAM address pin number
  constant C_DDR_AWIDTH : integer := 13;

  ---       DDR SDRAM data pin number
  constant C_DDR_DWIDTH : integer := 16;

  ---       DDR SDRAM module address width, dependent on total DDR memory capacity.
  --  128 Mb=  16MB : 24
  --  256 Mb=  32MB : 25
  --  512 Mb=  64MB : 26
  -- 1024 Mb= 128MB : 27
  -- 2048 Mb= 256MB : 28
  -- 4096 Mb= 512MB : 29
  -- 8192 Mb= 1024MB : 30
  -- 16384 Mb= 2048MB : 31
  -- 32768 Mb= 4096MB : 32
  constant C_DDR_IAWIDTH : integer range 24 to 32 := 30;

  --- DDR SDRAM controller data width, dependent on controller, memory type & clock speed used
  constant C_DDR_DATAWIDTH : integer range 32 to 512 := 512;

  ---       Block RAM address bus width.  Variation requires BRAM core regeneration.
  constant C_PRAM_AWIDTH : integer range 8 to 29 := 29;

  -- Wishbone endpoint address width
  constant C_WB_AWIDTH : integer range 24 to 31 := 31;

  -- DDR SDRAM page address width
  constant C_DDR_PG_WIDTH : integer range 0 to 30 := 20;

  -- Wishbone endpoint page address width
  constant C_WB_PG_WIDTH : integer range 0 to 30 := 19;

  ---       Width for Interrupt generation counter
  constant C_CNT_GINT_WIDTH : integer := 30;

--  ---       Emulation FIFOs' address width
--  Constant  C_FIFO_AWIDTH         : integer      :=   5;

  ---       Tag RAM data bus width, 1 bit for AInc information and 3 bits for BAR number
  constant C_TAGRAM_DWIDTH : integer := 36;

  ---       Configuration command width, e.g. cfg_dcommand, cfg_lcommand.
  constant C_CFG_COMMAND_DWIDTH : integer := 16;

  ---       Tag RAM address bus width, only 6 bits (of 8) are used for MRd from DMA Write Channel
  constant C_TAGRAM_AWIDTH     : integer := 6;
  constant C_TAG_MAP_WIDTH     : integer := 64;  -- 2^C_TAGRAM_AWIDTH
  --        TAG map are partitioned into sub-parts
  constant C_SUB_TAG_MAP_WIDTH : integer := 8;

  ---       Address_Increment bit is put in tag RAM
  constant CBIT_AINC_IN_TAGRAM : integer := C_TAGRAM_DWIDTH-1;

  -- Bit range of BAR field in TAG ram
  constant C_TAGBAR_BIT_TOP : integer := CBIT_AINC_IN_TAGRAM-1;
  constant C_TAGBAR_BIT_BOT : integer := C_TAGBAR_BIT_TOP-C_ENCODE_BAR_NUMBER+1;


  ---       Number of bits for Last DW BE and 1st DW BE in the header of a TLP
  constant C_BE_WIDTH : integer := 4;


  ---       ICAP width: 8 or 32.
  constant C_ICAP_WIDTH : integer := 32;

  ---       Feature Bits width
  constant C_FEAT_BITS_WIDTH : integer := 8;

  ---       Channel lables
  constant C_CHAN_INDEX_IRPT   : integer := 3;
  constant C_CHAN_INDEX_MRD    : integer := 2;
  constant C_CHAN_INDEX_DMA_DS : integer := 1;
  constant C_CHAN_INDEX_DMA_US : integer := 0;

  ------------------------------------------------------------------------
  --  Bit ranges

  --        Bits range for Max_Read_Request_Size in cfg_dcommand
  constant C_CFG_MRS_BIT_TOP : integer := 14;
  constant C_CFG_MRS_BIT_BOT : integer := 12;

  --        Bits range for Max_Payload_Size in cfg_dcommand
  constant C_CFG_MPS_BIT_TOP : integer := 7;
  constant C_CFG_MPS_BIT_BOT : integer := 5;

  --        The bit in minimum Max_Read_Request_Size/Max_Payload_Size that is one
  --  i.e. 0x80 Bytes = 0x20 DW = "000000100000"
  constant CBIT_SENSE_OF_MAXSIZE : integer := 5;

-- ------------------------------------------------------------------------
--
--  Section for TLP headers' bit definition
--         ( not shown in user header file)
--
-- ------------------------------------------------------------------------

--  -- The bit in TLP header #0 that means whether the TLP comes with data
--  Constant  CBIT_TLP_HAS_PAYLOAD  : integer      :=   30;

--  -- The bit in TLP header #0 that means whether the TLP has 4-DW header
--  Constant  CBIT_TLP_HAS_4DW_HEAD : integer      :=   29;

--  -- The bit in TLP header #0 that means Cpl/CplD
--  Constant  C_TLP_CPLD_BIT        : integer      :=   27;

  -- The bit in TLP header #0 that means TLP Digest
  constant C_TLP_TD_BIT : integer := 15;

  -- The bit in TLP header #0 that means Error Poison
  constant C_TLP_EP_BIT : integer := 14;

  -- Bit range of Format field in TLP header #0
  constant C_TLP_FMT_BIT_TOP : integer := 30;  -- TLP has payload
  constant C_TLP_FMT_BIT_BOT : integer := 29;  -- TLP header has 4 DW

  -- Bit range of Type field in TLP header #0
  constant C_TLP_TYPE_BIT_TOP : integer := 28;
  constant C_TLP_TYPE_BIT_BOT : integer := 24;

  -- Bit range of TC field in TLP header #0
  constant C_TLP_TC_BIT_TOP : integer := 22;
  constant C_TLP_TC_BIT_BOT : integer := 20;

  -- Bit range of Attribute field in TLP header #0
  constant C_TLP_ATTR_BIT_TOP : integer := 13;
  constant C_TLP_ATTR_BIT_BOT : integer := 12;

  -- Bit range of Length field in TLP header #0
  constant C_TLP_LENG_BIT_TOP : integer := 9;
  constant C_TLP_LENG_BIT_BOT : integer := 0;

  -- Bit range of Requester ID field in header #1 of non-Cpl/D TLP
  constant C_TLP_REQID_BIT_TOP : integer := 31+32;
  constant C_TLP_REQID_BIT_BOT : integer := 16+32;

  -- Bit range of Tag field in header #1 of non-Cpl/D TLP
  constant C_TLP_TAG_BIT_TOP : integer := 15+32;
  constant C_TLP_TAG_BIT_BOT : integer := 8+32;

  -- Bit range of Last BE field in TLP header #1
  constant C_TLP_LAST_BE_BIT_TOP : integer := 7+32;
  constant C_TLP_LAST_BE_BIT_BOT : integer := 4+32;

  -- Bit range of 1st BE field in TLP header #1
  constant C_TLP_1ST_BE_BIT_TOP : integer := 3+32;
  constant C_TLP_1ST_BE_BIT_BOT : integer := 0+32;

  -- Bit range of Completion Status field in Cpl/D TLP header #1
  constant C_CPLD_CS_BIT_TOP : integer := 15+32;
  constant C_CPLD_CS_BIT_BOT : integer := 13+32;

  -- Bit range of Completion Byte Count field in Cpl/D TLP header #1
  constant C_CPLD_BC_BIT_TOP : integer := 11+32;
  constant C_CPLD_BC_BIT_BOT : integer := 0+32;

  -- Bit range of Completer ID field in header#1 of Cpl/D TLP
  constant C_CPLD_CPLT_ID_BIT_TOP : integer := C_TLP_REQID_BIT_TOP;
  constant C_CPLD_CPLT_ID_BIT_BOT : integer := C_TLP_REQID_BIT_BOT;

  -- Bit range of Requester ID field in header#2 of Cpl/D TLP
  constant C_CPLD_REQID_BIT_TOP : integer := 31;
  constant C_CPLD_REQID_BIT_BOT : integer := 16;

  -- Bit range of Completion Tag field in Cpl/D TLP 3rd header
  constant C_CPLD_TAG_BIT_TOP : integer := 15;
  constant C_CPLD_TAG_BIT_BOT : integer := 8;

  -- Bit range of Completion Lower Address field in Cpl/D TLP 3rd header
  constant C_CPLD_LA_BIT_TOP : integer := 6;
  constant C_CPLD_LA_BIT_BOT : integer := 0;


  -- Bit range of Message Code field in Msg 2nd header
  constant C_MSG_CODE_BIT_TOP : integer := 7+32;
  constant C_MSG_CODE_BIT_BOT : integer := 0+32;

  -- ----------------------------------------------------------------------
  -- TLP field widths
  -- For PCIe, the length field is 10 bits wide.
  constant C_TLP_FLD_WIDTH_OF_LENG : integer := C_TLP_LENG_BIT_TOP-C_TLP_LENG_BIT_BOT+1;

  ------------------------------------------------------------------------
  ---       Tag width in TLP
  constant C_TAG_WIDTH : integer := C_TLP_TAG_BIT_TOP-C_TLP_TAG_BIT_BOT+1;

  ------------------------------------------------------------------------
  ---       Width for Local ID
  constant C_ID_WIDTH : integer := C_TLP_REQID_BIT_TOP-C_TLP_REQID_BIT_BOT+1;

  ------------------------------------------------------------------------
  ---       Width for Requester ID
  constant C_REQID_WIDTH : integer := C_TLP_REQID_BIT_TOP-C_TLP_REQID_BIT_BOT+1;

-- ------------------------------------------------------------------------
-- Section for Channel Buffer bit definition, referenced to TLP header definition
--         ( not shown in user header file)
--
-- ------------------------------------------------------------------------


  -- Bit range of Length field in Channel Buffer word
  constant C_CHBUF_LENG_BIT_BOT : integer := 0;
  constant C_CHBUF_LENG_BIT_TOP : integer := C_CHBUF_LENG_BIT_BOT+C_TLP_FLD_WIDTH_OF_LENG-1;  -- 9

  -- Bit range of Attribute field in Channel Buffer word
  constant C_CHBUF_ATTR_BIT_BOT : integer := C_CHBUF_LENG_BIT_TOP+1;  --10;
  constant C_CHBUF_ATTR_BIT_TOP : integer := C_CHBUF_ATTR_BIT_BOT+C_TLP_ATTR_BIT_TOP-C_TLP_ATTR_BIT_BOT;  --11;

  -- The bit in Channel Buffer word that means Error Poison
  constant C_CHBUF_EP_BIT : integer := C_CHBUF_ATTR_BIT_TOP+1;  --12;

  -- The bit in Channel Buffer word that means TLP Digest
  constant C_CHBUF_TD_BIT : integer := C_CHBUF_EP_BIT+1;  --13;

  -- Bit range of TC field in Channel Buffer word
  constant C_CHBUF_TC_BIT_BOT : integer := C_CHBUF_TD_BIT+1;  --14;
  constant C_CHBUF_TC_BIT_TOP : integer := C_CHBUF_TC_BIT_BOT+C_TLP_TC_BIT_TOP-C_TLP_TC_BIT_BOT;  --16;

  -- Bit range of Format field in Channel Buffer word
  constant C_CHBUF_FMT_BIT_BOT : integer := C_CHBUF_TC_BIT_TOP+1;  --17;
  constant C_CHBUF_FMT_BIT_TOP : integer := C_CHBUF_FMT_BIT_BOT+C_TLP_FMT_BIT_TOP-C_TLP_FMT_BIT_BOT;  --18;


  -- Bit range of Tag field in Channel Buffer word except Cpl/D
  constant C_CHBUF_TAG_BIT_BOT : integer := C_CHBUF_FMT_BIT_TOP+1;  --19;
  constant C_CHBUF_TAG_BIT_TOP : integer := C_CHBUF_TAG_BIT_BOT+C_TLP_TAG_BIT_TOP-C_TLP_TAG_BIT_BOT;  --26;

  -- Bit range of BAR Index field in upstream DMA Channel Buffer word
  constant C_CHBUF_DMA_BAR_BIT_BOT : integer := C_CHBUF_TAG_BIT_TOP+1;  --27;
  constant C_CHBUF_DMA_BAR_BIT_TOP : integer := C_CHBUF_DMA_BAR_BIT_BOT+C_ENCODE_BAR_NUMBER-1;  --29;

  -- Bit range of Message Code field in Channel Buffer word for Msg
  constant C_CHBUF_MSG_CODE_BIT_BOT : integer := C_CHBUF_TAG_BIT_TOP+1;  --27;
  constant C_CHBUF_MSG_CODE_BIT_TOP : integer := C_CHBUF_MSG_CODE_BIT_BOT+C_MSG_CODE_BIT_TOP-C_MSG_CODE_BIT_BOT;  --34;


  -- Bit range of remaining Byte Count field in Cpl/D Channel Buffer word
  constant C_CHBUF_CPLD_BC_BIT_BOT : integer := C_CHBUF_FMT_BIT_TOP+1;  --19;
  constant C_CHBUF_CPLD_BC_BIT_TOP : integer := C_CHBUF_CPLD_BC_BIT_BOT+C_TLP_FLD_WIDTH_OF_LENG-1+2;  --30;

  -- Bit range of Completion Status field in Cpl/D Channel Buffer word
  constant C_CHBUF_CPLD_CS_BIT_BOT : integer := C_CHBUF_CPLD_BC_BIT_TOP+1;  --31;
  constant C_CHBUF_CPLD_CS_BIT_TOP : integer := C_CHBUF_CPLD_CS_BIT_BOT+C_CPLD_CS_BIT_TOP-C_CPLD_CS_BIT_BOT;  --33;

  -- Bit range of Lower Address field in Cpl/D Channel Buffer word
  constant C_CHBUF_CPLD_LA_BIT_BOT : integer := C_CHBUF_CPLD_CS_BIT_TOP+1;  --34;
  constant C_CHBUF_CPLD_LA_BIT_TOP : integer := C_CHBUF_CPLD_LA_BIT_BOT+C_CPLD_LA_BIT_TOP-C_CPLD_LA_BIT_BOT;  --40;

  -- Bit range of Tag field in Cpl/D Channel Buffer word
  constant C_CHBUF_CPLD_TAG_BIT_BOT : integer := C_CHBUF_CPLD_LA_BIT_TOP+1;  --41;
  constant C_CHBUF_CPLD_TAG_BIT_TOP : integer := C_CHBUF_CPLD_TAG_BIT_BOT+C_CPLD_TAG_BIT_TOP-C_CPLD_TAG_BIT_BOT;  --48;

  -- Bit range of Requester ID field in Cpl/D Channel Buffer word
  constant C_CHBUF_CPLD_REQID_BIT_BOT : integer := C_CHBUF_CPLD_TAG_BIT_TOP+1;  --49;
  constant C_CHBUF_CPLD_REQID_BIT_TOP : integer := C_CHBUF_CPLD_REQID_BIT_BOT+C_CPLD_REQID_BIT_TOP-C_CPLD_REQID_BIT_BOT;  --64;

  -- Bit range of BAR Index field in Cpl/D Channel Buffer word
  constant C_CHBUF_CPLD_BAR_BIT_BOT : integer := C_CHBUF_CPLD_REQID_BIT_TOP+1;  --65;
  constant C_CHBUF_CPLD_BAR_BIT_TOP : integer := C_CHBUF_CPLD_BAR_BIT_BOT+C_ENCODE_BAR_NUMBER-1;  --67;


  -- Bit range of host address in Channel Buffer word
  constant C_CHBUF_HA_BIT_BOT : integer := C_CHBUF_DMA_BAR_BIT_TOP+1;  --30;
--  Constant  C_CHBUF_HA_BIT_TOP         : integer      :=   C_CHBUF_HA_BIT_BOT+2*C_DBUS_WIDTH-1;  --93;
  constant C_CHBUF_HA_BIT_TOP : integer := C_CHBUF_HA_BIT_BOT+C_DBUS_WIDTH-1;  --93;

  -- The bit in Channel Buffer word that means whether this TLP is valid for output arbitration
  --        (against channel buffer reset during arbitration)
  constant C_CHBUF_QVALID_BIT : integer := C_CHBUF_HA_BIT_TOP+1;  --94;

  -- The bit in Channel Buffer word that means address increment
  constant C_CHBUF_AINC_BIT : integer := C_CHBUF_QVALID_BIT+1;  --95;

  -- The bit in Channel Buffer word that means zero-length
  constant C_CHBUF_0LENG_BIT : integer := C_CHBUF_AINC_BIT+1;  --96;

  -- Bit range of peripheral address in Channel Buffer word
  constant C_CHBUF_PA_BIT_BOT : integer := C_CHANNEL_BUF_WIDTH-C_EP_AWIDTH;  --118;
  constant C_CHBUF_PA_BIT_TOP : integer := C_CHANNEL_BUF_WIDTH-1;  --127;

  -- Bit range of BRAM address in Channel Buffer word
  constant C_CHBUF_MA_BIT_BOT : integer := C_CHANNEL_BUF_WIDTH-C_PRAM_AWIDTH-2;  --97;
  constant C_CHBUF_MA_BIT_TOP : integer := C_CHANNEL_BUF_WIDTH-1;  --127;

  -- Bit range of DDR address in Channel Buffer word
  constant C_CHBUF_DDA_BIT_BOT : integer := C_CHANNEL_BUF_WIDTH-C_DDR_IAWIDTH;  --102;
  constant C_CHBUF_DDA_BIT_TOP : integer := C_CHANNEL_BUF_WIDTH-1;  --127;

  -- Bit range of Wishbone address in Channel Buffer word
  constant C_CHBUF_WB_BIT_BOT : integer := C_CHANNEL_BUF_WIDTH-C_WB_AWIDTH;  --97;
  constant C_CHBUF_WB_BIT_TOP : integer := C_CHANNEL_BUF_WIDTH-1;  --127;
  ------------------------------------------------------------------------
  -- The Relaxed Ordering bit constant in TLP
  constant C_RELAXED_ORDERING : std_logic := '0';

  -- The NO SNOOP bit constant in TLP
  constant C_NO_SNOOP : std_logic := '0';                                -- '1';

  -- AK, 2007-11-07: SNOOP-bit corrupts DMA, if set on INTEL platform. Seems to be don't care on AMD

  ------------------------------------------------------------------------
  -- TLP resolution concerning Format
  constant C_FMT3_NO_DATA : std_logic_vector(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) := "00";
  constant C_FMT3_WITH_DATA : std_logic_vector(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) := "10";

  constant C_FMT4_NO_DATA : std_logic_vector(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) := "01";
  constant C_FMT4_WITH_DATA : std_logic_vector(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) := "11";

  -- TLP resolution concerning Type
  constant C_TYPE_MEM_REQ : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "00000";
  constant C_TYPE_IO_REQ : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "00010";

  constant C_TYPE_MEM_REQ_LK : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "00001";
  constant C_TYPE_COMPLETION : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "01010";
  constant C_TYPE_COMPLETION_LK : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "01011";

  constant C_TYPE_MSG_TO_ROOT : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "10000";
  constant C_TYPE_MSG_BY_ADDRESS : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "10001";
  constant C_TYPE_MSG_BY_ID : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "10010";
  constant C_TYPE_MSG_FROM_ROOT : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "10011";
  constant C_TYPE_MSG_LOCAL : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "10100";
  constant C_TYPE_MSG_GATHER_TO_ROOT : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := "10101";

  --  Select this constant to test system response
  constant C_TYPE_OF_MSG : std_logic_vector(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) := C_TYPE_MSG_LOCAL; -- C_TYPE_MSG_TO_ROOT;

  ------------------------------------------------------------------------
  -- Lowest priority for Tx_Output_Arbitration module
  constant C_LOWEST_PRIORITY : std_logic_vector (C_ARBITRATE_WIDTH-1 downto 0) := (0 => '1', others => '0');

  ------------------------------------------------------------------------
  constant C_DECODE_BIT_TOP : integer := C_EP_AWIDTH-1;       -- 9;
  constant C_DECODE_BIT_BOT : integer := C_DECODE_BIT_TOP-1;  -- 8;


  ------------------------------------------------------------------------
  -- Current buffer descriptor length is 8 DW.
  constant C_NEXT_BD_LENGTH : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0)
 := CONV_STD_LOGIC_VECTOR(8*4, C_TLP_FLD_WIDTH_OF_LENG+2);

  --  Maximum 8 DW for the CplD carrying next BDA
  constant C_NEXT_BD_LENG_MSB : integer := 3;

  ------------------------------------------------------------------------
  --  To determine the max.size parameters, 6 bits are used.
  constant C_MAXSIZE_FLD_BIT_TOP : integer := C_TLP_FLD_WIDTH_OF_LENG +2;
  constant C_MAXSIZE_FLD_BIT_BOT : integer := 7;


  -- DDR commands: RASn-CASn-WEn
  constant CMD_NOP   : std_logic_vector(2 downto 0) := "111";
  constant CMD_LMR   : std_logic_vector(2 downto 0) := "000";
  constant CMD_ACT   : std_logic_vector(2 downto 0) := "011";
  constant CMD_READ  : std_logic_vector(2 downto 0) := "101";
  constant CMD_WRITE : std_logic_vector(2 downto 0) := "100";
  constant CMD_PRECH : std_logic_vector(2 downto 0) := "010";
  constant CMD_BTERM : std_logic_vector(2 downto 0) := "110";
  constant CMD_AREF  : std_logic_vector(2 downto 0) := "001";


  ------------------------------------------------------------------------
  --  Time-out counter width
  constant C_TOUT_WIDTH : integer := 32;

  --  Bottom bit for determining time-out
  constant CBIT_TOUT_BOT : integer := 16;

  --  Time-out value
  constant C_TIME_OUT_VALUE : std_logic_vector(C_TOUT_WIDTH-1 downto CBIT_TOUT_BOT) := (24 => '1', others => '0');
--                                         := (OTHERS=>'1' );  -- Maximum value (-1)

  ----------------------------------------------------------------------------------
  constant C_REGS_BASE_ADDR : std_logic_vector(C_EP_AWIDTH-1 downto 0) := (C_DECODE_BIT_TOP => '0', C_DECODE_BIT_BOT => '0', others => '0');

  constant C_BRAM_BASE_ADDR : std_logic_vector(C_EP_AWIDTH-1 downto 0) := (C_DECODE_BIT_TOP => '1', C_DECODE_BIT_BOT => '0', others => '0');

  constant C_FIFO_BASE_ADDR : std_logic_vector(C_EP_AWIDTH-1 downto 0) := (C_DECODE_BIT_TOP => '0', C_DECODE_BIT_BOT => '0', others => '0');

  ----------------------------------------------------------------------------------
--  Constant  CINT_ADDR_TXFIFO_DATA  : integer  := 4;
--  Constant  CINT_ADDR_TXFIFO_CTRL  : integer  := 6;
--  Constant  CINT_ADDR_TXFIFO_STA   : integer  := 6;
--
--  Constant  CINT_ADDR_RXFIFO_DATA  : integer  := 8;
--  Constant  CINT_ADDR_RXFIFO_CTRL  : integer  := 10;
--  Constant  CINT_ADDR_RXFIFO_STA   : integer  := 10;

  constant CINT_REGS_SPACE_BAR : integer := 0;
  constant CINT_FIFO_SPACE_BAR : integer := 4;
  constant CINT_DDR_SPACE_BAR  : integer := 2;
  ------------------------------------------------------------------------


--  -- Default channel buffer word for CplD
--  Constant  C_DEF_CPLD_WORD        : std_logic_vector(C_DBUS_WIDTH-1 downto 0)
--                                   :=X"CA000000";

  ----------------------------------------------------------------------------------
  --  1st word of MRd, for requesting the next descriptor
--  Constant  C_MRD_HEAD0_WORD       : std_logic_vector(C_DBUS_WIDTH-1 downto 0)
--                                   := X"80000000";
  constant C_TLP_HAS_DATA : std_logic := '1';
  constant C_TLP_HAS_NO_DATA : std_logic := '0';
  constant C_TLP_3DW_HEADER : std_logic := '0';
  constant C_TLP_4DW_HEADER : std_logic := '1';

  ------------------------------------------------------------------------
  constant C_TLP_TYPE_IS_MRD_H3 : std_logic_vector(3 downto 0) := "1000";
  constant C_TLP_TYPE_IS_MRDLK_H3 : std_logic_vector(3 downto 0) := "0100";
  constant C_TLP_TYPE_IS_MRD_H4 : std_logic_vector(3 downto 0) := "0010";
  constant C_TLP_TYPE_IS_MRDLK_H4 : std_logic_vector(3 downto 0) := "0001";

  constant C_TLP_TYPE_IS_MWR_H3 : std_logic_vector(1 downto 0) := "10";
  constant C_TLP_TYPE_IS_MWR_H4 : std_logic_vector(1 downto 0) := "01";

  constant C_TLP_TYPE_IS_CPLD : std_logic_vector(3 downto 0) := "1000";
  constant C_TLP_TYPE_IS_CPL : std_logic_vector(3 downto 0) := "0100";
  constant C_TLP_TYPE_IS_CPLDLK : std_logic_vector(3 downto 0) := "0010";
  constant C_TLP_TYPE_IS_CPLLK : std_logic_vector(3 downto 0) := "0001";

  ------------------------------------------------------------------------
  --        Maximal number of Interrupts
  constant C_NUM_OF_INTERRUPTS : integer := 16;

  ------------------------------------------------------------------------
  -- Minimal register set
  constant CINT_ADDR_VERSION : integer := 0;

  constant CINT_ADDR_IRQ_STAT : integer := 2;

  -- IRQ Enable. Write '1' turns on the interrupt, '0' masks.

  constant CINT_ADDR_IRQ_EN : integer := 4;

  constant CINT_ADDR_ERROR : integer := 6;  -- unused
  constant CINT_ADDR_SDRAM_PG : integer := 7;
  constant CINT_ADDR_STATUS : integer := 8;
  constant CINT_ADDR_WB_PG : integer := 9;
  constant CINT_ADDR_CONTROL : integer := 10;

  -- Upstream DMA channel Constants
  constant CINT_ADDR_DMA_US_PAH : integer := 11;

  constant CINT_ADDR_DMA_US_PAL : integer := 12;

  constant CINT_ADDR_DMA_US_HAH : integer := 13;

  constant CINT_ADDR_DMA_US_HAL : integer := 14;

  constant CINT_ADDR_DMA_US_BDAH : integer := 15;

  constant CINT_ADDR_DMA_US_BDAL : integer := 16;

  constant CINT_ADDR_DMA_US_LENG : integer := 17;

  constant CINT_ADDR_DMA_US_CTRL : integer := 18;

  constant CINT_ADDR_DMA_US_STA : integer := 19;


  -- Downstream DMA channel Constants
  constant CINT_ADDR_DMA_DS_PAH : integer := 20;

  constant CINT_ADDR_DMA_DS_PAL : integer := 21;

  constant CINT_ADDR_DMA_DS_HAH : integer := 22;

  constant CINT_ADDR_DMA_DS_HAL : integer := 23;

  constant CINT_ADDR_DMA_DS_BDAH : integer := 24;

  constant CINT_ADDR_DMA_DS_BDAL : integer := 25;

  constant CINT_ADDR_DMA_DS_LENG : integer := 26;

  constant CINT_ADDR_DMA_DS_CTRL : integer := 27;

  constant CINT_ADDR_DMA_DS_STA : integer := 28;


  --------  Address for MRd channel control
  constant CINT_ADDR_MRD_CTRL : integer := 29;

  --------  Address for Tx module control
  constant CINT_ADDR_TX_CTRL : integer := 30;

  --------  Address for ICAP access
  constant CINT_ADDR_ICAP : integer := 31;



  --------  Address of Interrupt Generator Control (W)
  constant CINT_ADDR_IG_CONTROL : integer := 32;

  --------  Address of Interrupt Generator Latency (W+R)
  constant CINT_ADDR_IG_LATENCY : integer := 33;

  --------  Address of Interrupt Generator Assert Number (R)
  constant CINT_ADDR_IG_NUM_ASSERT : integer := 34;

  --------  Address of Interrupt Generator Deassert Number (R)
  constant CINT_ADDR_IG_NUM_DEASSERT : integer := 35;

  --------  Event Buffer FIFO status (R) + control (W)
  constant CINT_ADDR_EB_STACON : integer := 36;

  --------  Upstream DMA transferred byte count (R)
  constant CINT_ADDR_US_TRANSF_BC : integer := 37;
  --------  Downstream DMA transferred byte count (R)
  constant CINT_ADDR_DS_TRANSF_BC : integer := 38;

  --------  DCB protocol link status (R) + control (W)
  constant CINT_ADDR_PROTOCOL_STACON : integer := 39;

  --------  CTL class register rx(R) + tx (W)
  constant CINT_ADDR_CTL_CLASS : integer := 40;

  --------  DLM class register rx(R) + tx (W)
  constant CINT_ADDR_DLM_CLASS : integer := 41;

  --------  Data generator control register (W)
  constant CINT_ADDR_DG_CTRL : integer := 42;

  --------  Traffice classes status (R)
  constant CINT_ADDR_TC_STATUS : integer := 43;

  --------  SIMONE USER REGISTER 01 rx(R) + tx (W)
  constant CINT_ADDR_REG01 : integer := 44;

  --------  SIMONE USER REGISTER 02 rx(R) + tx (W)
  constant CINT_ADDR_REG02 : integer := 45;

  --------  SIMONE USER REGISTER 03 rx(R) + tx (W)
  constant CINT_ADDR_REG03 : integer := 46;

  --------  SIMONE USER REGISTER 04 rx(R) + tx (W)
  constant CINT_ADDR_REG04 : integer := 47;

  --------  SIMONE USER REGISTER 05 rx(R) + tx (W)
  constant CINT_ADDR_REG05 : integer := 48;

  --------  SIMONE USER REGISTER 06 rx(R) + tx (W)
  constant CINT_ADDR_REG06 : integer := 49;

  --------  SIMONE USER REGISTER 07 rx(R) + tx (W)
  constant CINT_ADDR_REG07 : integer := 50;

  --------  SIMONE USER REGISTER 08 rx(R) + tx (W)
  constant CINT_ADDR_REG08 : integer := 51;

  --------  SIMONE USER REGISTER 09 rx(R) + tx (W)
  constant CINT_ADDR_REG09 : integer := 52;

  --------  SIMONE USER REGISTER 10 rx(R) + tx (W)
  constant CINT_ADDR_REG10 : integer := 53;

  --------  Host2Board FIFO status (R)
  constant CINT_ADDR_H2B_STACON : integer := 54;

  --------  Board2Host FIFO status (R)
  constant CINT_ADDR_B2H_STACON : integer := 55;

  --------  SIMONE USER REGISTER 11 rx(R) + tx (W)
  constant CINT_ADDR_REG11 : integer := 56;

  --------  SIMONE USER REGISTER 12 rx(R) + tx (W)
  constant CINT_ADDR_REG12 : integer := 57;

  --------  SIMONE USER REGISTER 13 rx(R) + tx (W)
  constant CINT_ADDR_REG13 : integer := 58;

  --------  SIMONE USER REGISTER 14 rx(R) + tx (W)
  constant CINT_ADDR_REG14 : integer := 59;

  ------------------------------------------------------------------------
  --        Number of registers
  constant C_NUM_OF_ADDRESSES : integer := 60;
  --
  ------------------------------------------------------------------------


  -- ----------------------------------------------------------------------
  -- Bit definitions of the Control register for DMA channels
  --
  constant CINT_BIT_DMA_CTRL_VALID : integer := 25;
  constant CINT_BIT_DMA_CTRL_LAST  : integer := 24;
  constant CINT_BIT_DMA_CTRL_UPA   : integer := 20;
  constant CINT_BIT_DMA_CTRL_AINC  : integer := 15;
  constant CINT_BIT_DMA_CTRL_END   : integer := 08;

  -- Bit range of BAR field in DMA Control register
  constant CINT_BIT_DMA_CTRL_BAR_TOP : integer := 18;
  constant CINT_BIT_DMA_CTRL_BAR_BOT : integer := 16;


  --  Default DMA Control register value
--  Constant  C_DEF_DMA_CTRL_WORD    : std_logic_vector(C_DBUS_WIDTH-1 downto 0)
  constant C_DEF_DMA_CTRL_WORD : std_logic_vector(C_DBUS_WIDTH-1 downto 0) := (CINT_BIT_DMA_CTRL_VALID => '1',
                                                                               CINT_BIT_DMA_CTRL_END => '1' , others => '0');

  ------------------------------------------------------------------------
  constant C_CHANNEL_RST_BITS : std_logic_vector(C_FEAT_BITS_WIDTH-1 downto 0) := X"0A";

  ------------------------------------------------------------------------
  constant C_HOST_ICLR_BITS : std_logic_vector(C_FEAT_BITS_WIDTH-1 downto 0) := X"F0";

  ----------------------------------------------------------------------------------
  -- Initial MWr Tag for upstream DMA
  constant C_TAG0_DMA_US_MWR : std_logic_vector(C_TAG_WIDTH-1 downto 0) := X"D0";

  -- Initial MRd Tag for upstream DMA descriptor
  constant C_TAG0_DMA_USB : std_logic_vector(C_TAG_WIDTH-1 downto 0) := X"E0";

  -- Initial MRd Tag for downstream DMA descriptor
  constant C_TAG0_DMA_DSB : std_logic_vector(C_TAG_WIDTH-1 downto 0) := X"C0";

  -- Initial Msg Tag Hihger 4 bits for interrupt
  constant C_MSG_TAG_HI : std_logic_vector(3 downto 0) := X"F";
  -- Msg code for IntA (fixed by PCIe)
  constant C_MSGCODE_INTA : std_logic_vector(7 downto 0) := X"20";
  -- Msg code for #IntA  (fixed by PCIe)
  constant C_MSGCODE_INTA_N : std_logic_vector(7 downto 0) := X"24";

  ----------------------------------------------------------------------------------
  -- DMA status bit definition
  constant CINT_BIT_DMA_STAT_NALIGN  : integer := 7;
  constant CINT_BIT_DMA_STAT_TIMEOUT : integer := 4;
  constant CINT_BIT_DMA_STAT_BDANULL : integer := 3;
  constant CINT_BIT_DMA_STAT_BUSY    : integer := 1;
  constant CINT_BIT_DMA_STAT_DONE    : integer := 0;

  -- Bit definition in interrup status register (ISR)
  constant CINT_BIT_US_DONE_IN_ISR : integer := 0;
  constant CINT_BIT_DS_DONE_IN_ISR : integer := 1;

  constant CINT_BIT_INTGEN_IN_ISR : integer := 2;
  constant CINT_BIT_DGEN_IN_ISR   : integer := 3;

  constant CINT_BIT_USTOUT_IN_ISR : integer := 4;
  constant CINT_BIT_DSTOUT_IN_ISR : integer := 5;

  constant CINT_BIT_DAQ_IN_ISR : integer := 6;
  constant CINT_BIT_CTL_IN_ISR : integer := 7;
  constant CINT_BIT_DLM_IN_ISR : integer := 8;

  -- The Time-out bits in System Error Register (SER)
  constant CINT_BIT_TX_TOUT_IN_SER : integer := 18;
  constant CINT_BIT_EB_TOUT_IN_SER : integer := 19;
  constant CINT_BIT_EB_OVERWRITTEN : integer := 20;

  -- The separate RST bit in DG_CTRL register
  constant CINT_BIT_DG_RST : integer := 12;

  -- The MASK bit in DG_CTRL register
  constant CINT_BIT_DG_MASK : integer := 8;

  -- The BUSY bit in DG_CTRL register
  constant CINT_BIT_DG_BUSY : integer := 1;

  -- The AVAIL bit in DG_CTRL register
  constant CINT_BIT_DG_AVAIL : integer := 0;

  -- Bit definition of msg routing method in General Control Register (GCR)
  constant C_GCR_MSG_ROUT_BIT_BOT : integer := 0;
  constant C_GCR_MSG_ROUT_BIT_TOP : integer := 2;

  -- Bit definition of ICAP Busy in global status register (GSR)
  constant CINT_BIT_ICAP_BUSY_IN_GSR : integer := 4;

  -- Bit definition of Data Generator available in global status register (GSR)
  constant CINT_BIT_DG_AVAIL_IN_GSR : integer := 5;

  -- Bit definition of DCB link_active in global status register (GSR)
  constant CINT_BIT_LINK_ACT_IN_GSR : integer := 6;

  -- Bit definition of DDR SDRAM ready for use in global status register (GSR)
  constant CINT_BIT_DDR_RDY_GSR : integer := 7;

  -- Bit range of link width in GSR
  constant CINT_BIT_LWIDTH_IN_GSR_BOT : integer := 10;  -- 16;
  constant CINT_BIT_LWIDTH_IN_GSR_TOP : integer := 15;  -- 21;


  ----------------------------------------------------------------------------------
  -- Carry bit, only for better timing, used to divide 32-bit add into 2 stages
  constant CBIT_CARRY : integer := 16;

  ----------------------------------------------------------------------------------
  --   Zero and -1 constants for different dimensions
  --
  constant C_ALL_ZEROS : std_logic_vector(255 downto 0) := (others => '0');
  constant C_ALL_ONES : std_logic_vector(255 downto 0) := (others => '1');


  ----------------------------------------------------------------------------------
  -- Implement date generator (DG)
  constant IMP_DATA_GENERATOR : boolean := false;

  -- DDR2 SODIMM module as the event buffer kernel
  -- !! remember to replace the UCF accordingly
  constant USE_DDR2_MODULE : boolean := false;

  -- For simplified verification, emulated loop-backed links be used if FALSE
  constant USE_OPTO_LINKS : boolean := false;

  -- Implement interrupt generator (IG)
  constant IMP_INT_GENERATOR : boolean := false;

  -- interrupt type: cfg(aka legacy) or MSI
  constant USE_CFG_INTERRUPT : boolean := false;

  -- Busmacro insertion for partial reconfigurability
  constant INSERT_BUSMACRO : boolean := false;

------------------------------------------------------------------------------------
----  ------------ Author ID
  constant AUTHOR_UNKNOWN : std_logic_vector(4-1 downto 0) := X"0";
  constant AUTHOR_AKUGEL  : std_logic_vector(4-1 downto 0) := X"1";
  constant AUTHOR_WGAO    : std_logic_vector(4-1 downto 0) := X"2";
  ----------------------------------------------------------------------------------

----  ------------ design ID              ---------------------
---- design id now contains a version: upper 8 bits, a major revision: next 8 bits,
---- and author code: next 4 bits and a minor revision: lower 12 bits
---- keep the autor file seperate and don't submit to CVS
----
  constant DESIGN_VERSION        : std_logic_vector(8-1 downto 0)  := X"01";
  constant DESIGN_MAJOR_REVISION : std_logic_vector(8-1 downto 0)  := X"04";
  constant DESIGN_MINOR_REVISION : std_logic_vector(12-1 downto 0) := X"001";
  constant C_DESIGN_ID : std_logic_vector(64-1 downto 0) := X"00000000"
                                                            & DESIGN_VERSION
                                                            & DESIGN_MAJOR_REVISION
                                                            & AUTHOR_WGAO
                                                            & DESIGN_MINOR_REVISION;

  ----------------------------------------------------------------------------------
  --       Function to invert endian for 32-bit data
  --
  function Endian_Invert_32 (Word_in : std_logic_vector) return std_logic_vector;
  function Endian_Invert_64 (Word_in : std_logic_vector(64-1 downto 0)) return std_logic_vector;


  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  -- revision log
  -- 2007-05-30: AK - abbPackage added, address map changed
  -- 2007-06-12: WGao - C_DEF_DMA_CTRL_WORD added,
  --                    DMA Control word bit definition added,
  --                    Function Endian_Invert_32 added.
  --                    CINT_ADDR_MRD_CTRL and CINT_ADDR_CPLD_CTRL changed,
  --                    CINT_ADDR_US_SAH and CINT_ADDR_DS_SAH removed.
  -- 2007-07-16: AK - dma status bits added


end abb64Package;


package body abb64Package is

  -- ------------------------------------------------------------------------------------------
  --   Function to invert bytewise endian for 32-bit data
  -- ------------------------------------------------------------------------------------------
  function Endian_Invert_32 (Word_in : std_logic_vector) return std_logic_vector is
  begin
    return Word_in(7 downto 0)&Word_in(15 downto 8)&Word_in(23 downto 16)&Word_in(31 downto 24);
  end Endian_Invert_32;

  -- ------------------------------------------------------------------------------------------
  --   Function to invert bytewise endian for 64-bit data
  -- ------------------------------------------------------------------------------------------
  function Endian_Invert_64 (Word_in : std_logic_vector(64-1 downto 0)) return std_logic_vector is
  begin
    return Word_in(39 downto 32)&Word_in(47 downto 40)&Word_in(55 downto 48)&Word_in(63 downto 56)
      & Word_in(7 downto 0)&Word_in(15 downto 8)&Word_in(23 downto 16)&Word_in(31 downto 24);
  end Endian_Invert_64;

end abb64Package;
