----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name:    RxIn_Delay - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision 1.10 - MAX_SIZE_EXCEEDED recalculated for better timing. 31.03.2008
--
-- Revision 1.00 - first release. 20.02.2007
--
-- Additional Comments: Virtual channels resolution.
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.abb64Package.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RxIn_Delay is
  port (
    -- Common ports
    user_clk    : in std_logic;
    user_reset  : in std_logic;
    user_lnk_up : in std_logic;

    -- Transaction receive interface
    m_axis_rx_tlast    : in  std_logic;
    m_axis_rx_tdata    : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    m_axis_rx_tkeep    : in  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
    m_axis_rx_terrfwd  : in  std_logic;
    m_axis_rx_tvalid   : in  std_logic;
    m_axis_rx_tbar_hit : in  std_logic_vector(C_BAR_NUMBER-1 downto 0);
    m_axis_rx_tready   : out std_logic;
    Pool_wrBuf_full    : in  std_logic;
    wb_FIFO_full       : in  std_logic;

    -- Delay for one clock
    m_axis_rx_tlast_dly    : out std_logic;
    m_axis_rx_tdata_dly    : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    m_axis_rx_tkeep_dly    : out std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
    m_axis_rx_terrfwd_dly  : out std_logic;
    m_axis_rx_tvalid_dly   : out std_logic;
    m_axis_rx_tready_dly   : out std_logic;
    m_axis_rx_tbar_hit_dly : out std_logic_vector(C_BAR_NUMBER-1 downto 0);

    -- TLP resolution
    MRd_Type  : out std_logic_vector(3 downto 0);
    MWr_Type  : out std_logic_vector(1 downto 0);
    CplD_Type : out std_logic_vector(3 downto 0);

    -- From Cpl/D channel
    usDMA_dex_Tag : in std_logic_vector(C_TAG_WIDTH-1 downto 0);
    dsDMA_dex_Tag : in std_logic_vector(C_TAG_WIDTH-1 downto 0);

    -- To Memory request process modules
    Tlp_straddles_4KB : out std_logic;

    -- To Cpl/D channel
    Tlp_has_4KB       : out std_logic;
    Tlp_has_1DW       : out std_logic;
    CplD_is_the_Last  : out std_logic;
    CplD_on_Pool      : out std_logic;
    CplD_on_EB        : out std_logic;
    Req_ID_Match      : out std_logic;
    usDex_Tag_Matched : out std_logic;
    dsDex_Tag_Matched : out std_logic;
    CplD_Tag          : out std_logic_vector(C_TAG_WIDTH-1 downto 0);


    -- Additional
    cfg_dcommand : in std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);
    localID      : in std_logic_vector(C_ID_WIDTH-1 downto 0)
    );

end entity RxIn_Delay;


architecture Behavioral of RxIn_Delay is

-- Max Length Checking
  signal Tlp_has_0_Length        : std_logic;
  signal Tlp_has_1DW_Length_i    : std_logic;
  signal MaxReadReqSize_Exceeded : std_logic;
  signal MaxPayloadSize_Exceeded : std_logic;

  signal Tlp_straddles_4KB_i : std_logic;
  signal Tlp_has_4KB_i       : std_logic;
  signal cfg_MRS             : std_logic_vector(C_CFG_MRS_BIT_TOP-C_CFG_MRS_BIT_BOT downto 0);
  signal cfg_MPS             : std_logic_vector(C_CFG_MPS_BIT_TOP-C_CFG_MPS_BIT_BOT downto 0);

  signal cfg_MRS_decoded : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
  signal cfg_MPS_decoded : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);

  type CfgThreshold is array (C_TLP_FLD_WIDTH_OF_LENG-CBIT_SENSE_OF_MAXSIZE downto 0)
    of std_logic_vector (C_TLP_FLD_WIDTH_OF_LENG downto 0);

  signal MaxSize_Thresholds : CfgThreshold;

-- As one clock of delay
  signal m_axis_rx_tlast_r1    : std_logic;
  signal m_axis_rx_tkeep_r1    : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal m_axis_rx_tdata_r1    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal m_axis_rx_terrfwd_r1  : std_logic;
  signal m_axis_rx_tvalid_r1   : std_logic;
  signal m_axis_rx_tready_i    : std_logic;
  signal m_axis_rx_tready_r1   : std_logic;
  signal m_axis_rx_tbar_hit_r1 : std_logic_vector(C_BAR_NUMBER-1 downto 0);

-- TLP type decision
  signal TLP_is_MRd_BAR0_H3DW : std_logic;
  signal TLP_is_MRd_BAR1_H3DW : std_logic;
  signal TLP_is_MRd_BAR2_H3DW : std_logic;
  signal TLP_is_MRd_BAR3_H3DW : std_logic;

  signal TLP_is_MRd_BAR0_H4DW : std_logic;
  signal TLP_is_MRd_BAR1_H4DW : std_logic;
  signal TLP_is_MRd_BAR2_H4DW : std_logic;
  signal TLP_is_MRd_BAR3_H4DW : std_logic;

  signal TLP_is_MRdLk_BAR0_H3DW : std_logic;
  signal TLP_is_MRdLk_BAR1_H3DW : std_logic;
  signal TLP_is_MRdLk_BAR2_H3DW : std_logic;
  signal TLP_is_MRdLk_BAR3_H3DW : std_logic;

  signal TLP_is_MRdLk_BAR0_H4DW : std_logic;
  signal TLP_is_MRdLk_BAR1_H4DW : std_logic;
  signal TLP_is_MRdLk_BAR2_H4DW : std_logic;
  signal TLP_is_MRdLk_BAR3_H4DW : std_logic;

  signal TLP_is_MWr_BAR0_H3DW : std_logic;
  signal TLP_is_MWr_BAR1_H3DW : std_logic;
  signal TLP_is_MWr_BAR2_H3DW : std_logic;
  signal TLP_is_MWr_BAR3_H3DW : std_logic;

  signal TLP_is_MWr_BAR0_H4DW : std_logic;
  signal TLP_is_MWr_BAR1_H4DW : std_logic;
  signal TLP_is_MWr_BAR2_H4DW : std_logic;
  signal TLP_is_MWr_BAR3_H4DW : std_logic;

  signal TLP_is_CplD   : std_logic;
  signal TLP_is_Cpl    : std_logic;
  signal TLP_is_CplDLk : std_logic;
  signal TLP_is_CplLk  : std_logic;

  signal TLP_is_MRd_H3DW   : std_logic;
  signal TLP_is_MRd_H4DW   : std_logic;
  signal TLP_is_MRdLk_H3DW : std_logic;
  signal TLP_is_MRdLk_H4DW : std_logic;

  signal TLP_is_MWr_H3DW : std_logic;
  signal TLP_is_MWr_H4DW : std_logic;

  signal MRd_Type_i  : std_logic_vector(3 downto 0);
  signal MWr_Type_i  : std_logic_vector(1 downto 0);
  signal CplD_Type_i : std_logic_vector(3 downto 0);

  signal Req_ID_Match_i : std_logic;

  signal usDex_Tag_Matched_i : std_logic;
  signal dsDex_Tag_Matched_i : std_logic;


  -----------------------------------------------------------------
  -- Inbound DW counter
  signal TLP_DW_Length_i       : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
  signal MWr_on_Pool           : std_logic;
  signal MWr_on_EB             : std_logic;
  signal CplD_on_Pool_i        : std_logic;
  signal CplD_on_EB_i          : std_logic;
  signal CplD_is_the_Last_i    : std_logic;
  signal CplD_Tag_i            : std_logic_vector(C_TAG_WIDTH-1 downto 0);

  --   Counter inside a TLP
  type TLPCntStates is (TK_RST
                                    , TK_Idle
--                                   , TK_MWr_3Hdr_B
                                    , TK_MWr_3Hdr_C
--                                   , TK_MWr_4Hdr_B
                                    , TK_MWr_4Hdr_C
--                                   , TK_MWr_4Hdr_D
--                                   , TK_CplD_Hdr_B
                                    , TK_CplD_Hdr_C
                                    , TK_Body
                                    );

  signal FSM_TLP_Cnt : TLPCntStates;

  --   CplD tag capture FSM (Address at tRAM)
  type AddrOnRAM_States is (AOtSt_RST
                                    , AOtSt_Idle
                                    , AOtSt_HdrA
                                    , AOtSt_HdrB
                                    , AOtSt_Body
                                    );

  signal FSM_AOtRAM : AddrOnRAM_States;

  --old interface helper signals
  signal in_packet_reg : std_logic;
  signal trn_rsof_n    : std_logic;

begin

  m_axis_rx_tready       <= m_axis_rx_tready_i;   -- Delay
  m_axis_rx_tlast_dly    <= m_axis_rx_tlast_r1;
  m_axis_rx_tkeep_dly    <= m_axis_rx_tkeep_r1;
  m_axis_rx_tdata_dly    <= m_axis_rx_tdata_r1;
  m_axis_rx_terrfwd_dly  <= m_axis_rx_terrfwd_r1;
  m_axis_rx_tvalid_dly   <= m_axis_rx_tvalid_r1;
  m_axis_rx_tready_dly   <= m_axis_rx_tready_r1;  -- m_axis_rx_tready_r1    ;
  m_axis_rx_tbar_hit_dly <= m_axis_rx_tbar_hit_r1;


  -- TLP resolution
  MRd_Type  <= MRd_Type_i;
  MWr_Type  <= MWr_Type_i;
  CplD_Type <= CplD_Type_i;

  -- To Cpl/D channel
  Req_ID_Match <= Req_ID_Match_i;

  usDex_Tag_Matched <= usDex_Tag_Matched_i;
  dsDex_Tag_Matched <= dsDex_Tag_Matched_i;

  CplD_Tag         <= CplD_Tag_i;
  CplD_is_the_Last <= CplD_is_the_Last_i;
  CplD_on_Pool     <= CplD_on_Pool_i;
  CplD_on_EB       <= CplD_on_EB_i;

  Tlp_has_4KB <= Tlp_has_4KB_i;
  Tlp_has_1DW <= Tlp_has_1DW_Length_i;

  Tlp_straddles_4KB <= '0';             --Tlp_straddles_4KB_i  ;

  --  !! !!
  MaxReadReqSize_Exceeded <= '0';
  MaxPayloadSize_Exceeded <= '0';

----------------------------------------------
--
-- Synchronous Registered: TLP_DW_Length
--                         Tlp_has_4KB
--                         Tlp_has_1DW_Length
--                         Tlp_has_0_Length
--
  FSM_TLP_1ST_DW_Info :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      TLP_DW_Length_i      <= (others => '0');
      Tlp_has_4KB_i        <= '0';
      Tlp_has_1DW_Length_i <= '0';
      Tlp_has_0_Length     <= '0';

    elsif user_clk'event and user_clk = '1' then
      if trn_rsof_n = '0' then
        TLP_DW_Length_i <= m_axis_rx_tdata(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT);
      else
        TLP_DW_Length_i <= TLP_DW_Length_i;
      end if;

      if trn_rsof_n = '0' then
        if m_axis_rx_tdata(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT) = C_ALL_ZEROS(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) then
          Tlp_has_4KB_i <= '1';
        else
          Tlp_has_4KB_i <= '0';
        end if;
      else
        Tlp_has_4KB_i <= Tlp_has_4KB_i;
      end if;

      if trn_rsof_n = '0' then
        if m_axis_rx_tdata(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)
           = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) then
          Tlp_has_1DW_Length_i <= '1';
        else
          Tlp_has_1DW_Length_i <= '0';
        end if;
      else
        Tlp_has_1DW_Length_i <= Tlp_has_1DW_Length_i;
      end if;

      if trn_rsof_n = '0' then
        if m_axis_rx_tdata(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)
           = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG)
          and m_axis_rx_tdata(32+2) = '0' then
          Tlp_has_0_Length <= '1';
        else
          Tlp_has_0_Length <= '0';
        end if;
      else
        Tlp_has_0_Length <= Tlp_has_0_Length;
      end if;

    end if;
  end process;

---- --------------------------------------------------------------------------
--   -- Max Payload Size bits
--   cfg_MPS               <= cfg_dcommand(C_CFG_MPS_BIT_TOP downto C_CFG_MPS_BIT_BOT);
--
--   -- Max Read Request Size bits
--   cfg_MRS               <= cfg_dcommand(C_CFG_MRS_BIT_TOP downto C_CFG_MRS_BIT_BOT);
--
--
--
--   -- --------------------------------
--   -- Decoding MPS
--   --
--   Trn_Rx_Decoding_MPS:
--   process ( user_clk )
--   begin
--      if user_clk'event and user_clk = '1' then
--
--         case cfg_MPS is
--           when CONV_STD_LOGIC_VECTOR(0, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(1, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(1)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(2, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(2)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(3, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(3)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(4, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(4)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(5, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(5)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when Others =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--         end case;
--
--      end if;
--   end process;
--
--
--   -- --------------------------------
--   -- Decoding MRS
--   --
--   Trn_Rx_Decoding_MRS:
--   process ( user_clk )
--   begin
--      if user_clk'event and user_clk = '1' then
--
--         case cfg_MRS is
--           when CONV_STD_LOGIC_VECTOR(0, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(1, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(1)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(2, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(2)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(3, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(3)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(4, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(4)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(5, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(5)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when Others =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--         end case;
--
--      end if;
--   end process;
--
--
--   -------------------------------------------------------------
--   MaxSize_Thresholds(0) <= (CBIT_SENSE_OF_MAXSIZE=>'1', Others=>'0');
--   Gen_MaxSizes:
--   FOR i IN 1 TO C_TLP_FLD_WIDTH_OF_LENG-CBIT_SENSE_OF_MAXSIZE GENERATE
--     MaxSize_Thresholds(i) <= MaxSize_Thresholds(i-1)(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0)&'0';
--   END GENERATE;
--
--   -- --------------------------------
--   -- Calculation of MPS exceed
--   --
--   Trn_Rx_MaxPayloadSize_Exceeded:
--   process ( user_clk )
--   begin
--      if user_clk'event and user_clk = '1' then
--
--         case cfg_MPS_decoded is
--
----           when CONV_STD_LOGIC_VECTOR(1, 6)  =>   -- MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
----             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(0) then
----                MaxPayloadSize_Exceeded <= '1';
----             else
----                MaxPayloadSize_Exceeded <= '0';
----             end if;
--
--           when CONV_STD_LOGIC_VECTOR(2, 6)  =>   -- MaxSize_Thresholds(1)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(1) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(4, 6)  =>   -- MaxSize_Thresholds(2)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(2) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(8, 6)  =>   -- MaxSize_Thresholds(3)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(3) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(16, 6)  =>   -- MaxSize_Thresholds(4)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(4) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(32, 6)  =>   -- MaxSize_Thresholds(5)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--                MaxPayloadSize_Exceeded <= '0';            -- !!
--
--           when OTHERS  =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(0) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--        end case;
--
--      end if;
--   end process;
--
--
--   -- --------------------------------
--   -- Calculation of MRS exceed
--   --
--   Trn_Rx_MaxReadReqSize_Exceeded:
--   process ( user_clk )
--   begin
--      if user_clk'event and user_clk = '1' then
--
--         case cfg_MRS_decoded is
--
----           when CONV_STD_LOGIC_VECTOR(1, 6)  =>   -- MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
----             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(0) then
----                MaxReadReqSize_Exceeded <= '1';
----             else
----                MaxReadReqSize_Exceeded <= '0';
----             end if;
--
--           when CONV_STD_LOGIC_VECTOR(2, 6)  =>   -- MaxSize_Thresholds(1)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(1) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(4, 6)  =>   -- MaxSize_Thresholds(2)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(2) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(8, 6)  =>   -- MaxSize_Thresholds(3)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(3) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(16, 6)  =>   -- MaxSize_Thresholds(4)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(4) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(32, 6)  =>   -- MaxSize_Thresholds(5)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--                MaxReadReqSize_Exceeded <= '0';            -- !!
--
--           when OTHERS  =>
--             if m_axis_rx_tdata(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(0) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--        end case;
--
--      end if;
--   end process;


  --    ---------------------------------------------------------
  ----  Pipelining all trn_rx input signals for one clock
  ----    to get better timing
  ----
  Trn_Rx_Inputs_Delayed :
  process (user_clk)
  begin
    if user_clk'event and user_clk = '1' then
      m_axis_rx_tlast_r1    <= m_axis_rx_tlast;
      m_axis_rx_tkeep_r1    <= m_axis_rx_tkeep;
      m_axis_rx_tdata_r1    <= m_axis_rx_tdata;
      m_axis_rx_terrfwd_r1  <= m_axis_rx_terrfwd;
      m_axis_rx_tvalid_r1   <= m_axis_rx_tvalid;
      m_axis_rx_tready_r1   <= m_axis_rx_tready_i;
      m_axis_rx_tbar_hit_r1 <= m_axis_rx_tbar_hit;
    end if;
  end process;


  -- -----------------------------------------
  -- TLP Types
  --
  TLP_Decision_Registered :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      TLP_is_MRd_H3DW <= '0';

      TLP_is_MRdLk_H3DW <= '0';

      TLP_is_MRd_H4DW <= '0';

      TLP_is_MRdLk_H4DW <= '0';

      TLP_is_MWr_H3DW <= '0';

      TLP_is_MWr_H4DW <= '0';

      TLP_is_CplD   <= '0';
      TLP_is_CplDLk <= '0';
      TLP_is_Cpl    <= '0';
      TLP_is_CplLk  <= '0';

    elsif user_clk'event and user_clk = '1' then

      -- MRd
      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT3_NO_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tbar_hit(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ZEROS(CINT_BAR_SPACES-1 downto 0)
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_MRd_H3DW <= '1';
      else
        TLP_is_MRd_H3DW <= '0';
      end if;

      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT4_NO_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tbar_hit(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ZEROS(CINT_BAR_SPACES-1 downto 0)
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_MRd_H4DW <= '1';
      else
        TLP_is_MRd_H4DW <= '0';
      end if;

      -- MRdLk
      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT3_NO_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ_LK
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tbar_hit(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ZEROS(CINT_BAR_SPACES-1 downto 0)
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_MRdLk_H3DW <= '1';
      else
        TLP_is_MRdLk_H3DW <= '0';
      end if;

      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT4_NO_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ_LK
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tbar_hit(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ZEROS(CINT_BAR_SPACES-1 downto 0)
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_MRdLk_H4DW <= '1';
      else
        TLP_is_MRdLk_H4DW <= '0';
      end if;

      -- MWr
      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT3_WITH_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tbar_hit(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ZEROS(CINT_BAR_SPACES-1 downto 0)
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_MWr_H3DW <= '1';
      else
        TLP_is_MWr_H3DW <= '0';
      end if;

      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT4_WITH_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tbar_hit(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ZEROS(CINT_BAR_SPACES-1 downto 0)
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_MWr_H4DW <= '1';
      else
        TLP_is_MWr_H4DW <= '0';
      end if;

      -- CplD, Cpl/CplDLk, CplLk
      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT3_WITH_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_COMPLETION
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_CplD <= '1';
      else
        TLP_is_CplD <= '0';
      end if;

      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT3_WITH_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_COMPLETION_LK
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_CplDLk <= '1';
      else
        TLP_is_CplDLk <= '0';
      end if;

      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT3_NO_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_COMPLETION
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_Cpl <= '1';
      else
        TLP_is_Cpl <= '0';
      end if;

      if m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = C_FMT3_NO_DATA
        and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_COMPLETION_LK
        and m_axis_rx_tdata(C_TLP_EP_BIT) = '0'
        and m_axis_rx_tvalid = '1'
        and trn_rsof_n = '0'
      then
        TLP_is_CplLk <= '1';
      else
        TLP_is_CplLk <= '0';
      end if;

    end if;
  end process;

-- --------------------------------------------------------------------------
--   TLP_is_MRd_H3DW    <=  TLP_is_MRd_BAR0_H3DW   or TLP_is_MRd_BAR1_H3DW;
--   TLP_is_MRdLk_H3DW  <=  TLP_is_MRdLk_BAR0_H3DW or TLP_is_MRdLk_BAR1_H3DW;

--   TLP_is_MRd_H4DW    <=  TLP_is_MRd_BAR0_H4DW   or TLP_is_MRd_BAR1_H4DW;
--   TLP_is_MRdLk_H4DW  <=  TLP_is_MRdLk_BAR0_H4DW or TLP_is_MRdLk_BAR1_H4DW;

--   TLP_is_MWr_H3DW    <=  TLP_is_MWr_BAR0_H3DW   or TLP_is_MWr_BAR1_H3DW;

--   TLP_is_MWr_H4DW    <=  TLP_is_MWr_BAR0_H4DW   or TLP_is_MWr_BAR1_H4DW;

-- --------------------------------------------------------------------------

  MRd_Type_i <= (TLP_is_MRd_H3DW and not MaxReadReqSize_Exceeded)
                & (TLP_is_MRdLk_H3DW and not MaxReadReqSize_Exceeded)
                & (TLP_is_MRd_H4DW and not MaxReadReqSize_Exceeded)
                & (TLP_is_MRdLk_H4DW and not MaxReadReqSize_Exceeded);

  MWr_Type_i <= (TLP_is_MWr_H3DW and not MaxPayloadSize_Exceeded)
                & (TLP_is_MWr_H4DW and not MaxPayloadSize_Exceeded);

  CplD_Type_i <= (TLP_is_CplD and not MaxPayloadSize_Exceeded)
                 & (TLP_is_Cpl and not MaxPayloadSize_Exceeded)
                 & (TLP_is_CplDLk and not MaxPayloadSize_Exceeded)
                 & (TLP_is_CplLk and not MaxPayloadSize_Exceeded);


  ---------------------------------------------------
  --
  -- Synchronous Registered: TLP_Header_Resolution
  --
  FSM_TLP_Header_Resolution :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      FSM_TLP_Cnt           <= TK_RST;
      MWr_on_Pool           <= '0';
      CplD_on_Pool_i        <= '0';
      CplD_on_EB_i          <= '0';
      m_axis_rx_tready_i    <= '0';

    elsif user_clk'event and user_clk = '1' then

      -- States transition
      case FSM_TLP_Cnt is

        when TK_RST =>
          FSM_TLP_Cnt        <= TK_Idle;
          m_axis_rx_tready_i <= '0';

        when TK_Idle =>
          m_axis_rx_tready_i <= '1';
          if trn_rsof_n = '0' and m_axis_rx_tvalid = '1' and m_axis_rx_tready_i = '1'
            and m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = "10"
            and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) = "00"
          then
            FSM_TLP_Cnt <= TK_MWr_3Hdr_C;
          elsif trn_rsof_n = '0' and m_axis_rx_tvalid = '1' and m_axis_rx_tready_i = '1'
            and m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = "11"
            and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) = "00"
          then
            FSM_TLP_Cnt <= TK_MWr_4Hdr_C;
          elsif trn_rsof_n = '0' and m_axis_rx_tvalid = '1' and m_axis_rx_tready_i = '1'
            and m_axis_rx_tdata(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) = "10"
            and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) = "01"
          then
            FSM_TLP_Cnt <= TK_CplD_Hdr_C;
          else
            FSM_TLP_Cnt <= TK_Idle;
          end if;

        when TK_MWr_3Hdr_C =>
          m_axis_rx_tready_i <= '1';
          if m_axis_rx_tlast = '1' and m_axis_rx_tlast_r1 = '0'  -- raising edge
            and m_axis_rx_tready_i = '1' then
            FSM_TLP_Cnt <= TK_Idle;
          elsif m_axis_rx_tvalid = '0' then
            FSM_TLP_Cnt <= TK_MWr_3Hdr_C;
          else
            FSM_TLP_Cnt <= TK_Body;
          end if;

        when TK_MWr_4Hdr_C =>
          m_axis_rx_tready_i <= '1';
          if m_axis_rx_tlast = '1' and m_axis_rx_tlast_r1 = '0'  -- raising edge
            and m_axis_rx_tready_i = '1' then
            FSM_TLP_Cnt <= TK_Idle;
          elsif m_axis_rx_tvalid = '0' then
            FSM_TLP_Cnt <= TK_MWr_4Hdr_C;
          else
            FSM_TLP_Cnt <= TK_Body;     -- TK_MWr_4Hdr_D;
          end if;

        when TK_Cpld_Hdr_C =>
          m_axis_rx_tready_i <= '1';
          if m_axis_rx_tlast = '1' and m_axis_rx_tlast_r1 = '0'  -- raising edge
            and m_axis_rx_tready_i = '1' then
            FSM_TLP_Cnt <= TK_Idle;
          elsif m_axis_rx_tvalid = '0' then
            FSM_TLP_Cnt <= TK_Cpld_Hdr_C;
          else
            FSM_TLP_Cnt <= TK_Body;
          end if;

        when TK_Body =>
          if m_axis_rx_tlast = '1' and m_axis_rx_tlast_r1 = '0' -- raising edge
            and m_axis_rx_tready_i = '1' then
            FSM_TLP_Cnt        <= TK_Idle;
            m_axis_rx_tready_i <= not(((MWr_on_Pool or CplD_on_Pool_i) and Pool_wrBuf_full)
                                      or ((MWr_on_EB or CplD_on_EB_i) and wb_fifo_full));
          else
            FSM_TLP_Cnt <= TK_Body;
            m_axis_rx_tready_i <= not(((MWr_on_Pool or CplD_on_Pool_i) and Pool_wrBuf_full)
                                      or ((MWr_on_EB or CplD_on_EB_i) and wb_fifo_full));
          end if;

        when others =>
          FSM_TLP_Cnt <= TK_RST;

      end case;

      -- MWr_on_Pool
      case FSM_TLP_Cnt is

        when TK_RST =>
          MWr_on_Pool <= '0';
          MWr_on_EB   <= '0';

        when TK_Idle =>
          if trn_rsof_n = '0' and m_axis_rx_tvalid = '1'
            and m_axis_rx_tdata(C_TLP_FMT_BIT_TOP) = '1'
            and m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) = "00"
          then
            MWr_on_Pool <= m_axis_rx_tbar_hit(CINT_DDR_SPACE_BAR);
            MWr_on_EB   <= m_axis_rx_tbar_hit(CINT_FIFO_SPACE_BAR);
          else
            MWr_on_Pool <= MWr_on_Pool;
            MWr_on_EB   <= MWr_on_EB;
          end if;


        when others =>
          MWr_on_Pool <= MWr_on_Pool;
          MWr_on_EB   <= MWr_on_EB;

      end case;

      -- CplD_on_Pool
      case FSM_TLP_Cnt is

        when TK_RST =>
          CplD_on_Pool_i <= '0';
          CplD_on_EB_i   <= '0';

        when TK_Idle =>
          CplD_on_Pool_i <= '0';
          CplD_on_EB_i   <= '0';

        when TK_CplD_Hdr_C =>
          CplD_on_Pool_i <= not m_axis_rx_tdata(C_CPLD_TAG_BIT_TOP) and not m_axis_rx_tdata(C_CPLD_TAG_BIT_TOP-1);
          CplD_on_EB_i   <= not m_axis_rx_tdata(C_CPLD_TAG_BIT_TOP) and m_axis_rx_tdata(C_CPLD_TAG_BIT_TOP-1);

        when others =>
          CplD_on_Pool_i <= CplD_on_Pool_i;
          CplD_on_EB_i   <= CplD_on_EB_i;

      end case;

      -- CplD_Tag
      case FSM_TLP_Cnt is

        when TK_RST =>
          CplD_Tag_i <= (others => '1');

        when TK_CplD_Hdr_C =>
          if m_axis_rx_tvalid = '1'     -- and m_axis_rx_tready='1'
          then
            CplD_Tag_i <= m_axis_rx_tdata(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT);
          else
            CplD_Tag_i <= CplD_Tag_i;
          end if;

        when others =>
          CplD_Tag_i <= CplD_Tag_i;

      end case;

    end if;
  end process;

  ---------------------------------------------------
  --
  -- Synchronous Registered: CplD_is_the_Last
  --
  Syn_Calc_CplD_is_the_Last :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      CplD_is_the_Last_i <= '0';

    elsif user_clk'event and user_clk = '1' then

      if trn_rsof_n = '0' and m_axis_rx_tvalid = '1' then
        if m_axis_rx_tdata(C_TLP_TYPE_BIT_TOP-1) = '1'
          and (m_axis_rx_tdata(C_CPLD_BC_BIT_TOP downto C_CPLD_BC_BIT_BOT+2) = m_axis_rx_tdata(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)
               or m_axis_rx_tdata(32+1 downto 32+0) = CONV_STD_LOGIC_VECTOR(1, 2))  -- Zero-length
        then
          CplD_is_the_Last_i <= '1';
        else
          CplD_is_the_Last_i <= '0';
        end if;
      else
        CplD_is_the_Last_i <= CplD_is_the_Last_i;
      end if;

    end if;
  end process;

  --  ---------------------------------------------------------
  --  To Cpl/D channel as indicator when ReqID matched
  --
  TLP_ReqID_Matched :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      Req_ID_Match_i <= '0';
    elsif user_clk'event and user_clk = '1' then
      if m_axis_rx_tdata(C_CPLD_REQID_BIT_TOP downto C_CPLD_REQID_BIT_BOT) = localID then
        Req_ID_Match_i <= '1';
      else
        Req_ID_Match_i <= '0';
      end if;
    end if;
  end process;

  --  ------------------------------------------------------------
  --  To Cpl/D channel as indicator when us Tag_Descriptor matched
  --
  TLP_usDexTag_Matched :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      usDex_Tag_Matched_i <= '0';
    elsif user_clk'event and user_clk = '1' then
      if m_axis_rx_tdata(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT) = usDMA_dex_Tag then
        usDex_Tag_Matched_i <= '1';
      else
        usDex_Tag_Matched_i <= '0';
      end if;
    end if;
  end process;

  --  ------------------------------------------------------------
  --  To Cpl/D channel as indicator when ds Tag_Descriptor matched
  --
  TLP_dsDexTag_Matched :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      dsDex_Tag_Matched_i <= '0';
    elsif user_clk'event and user_clk = '1' then
      if m_axis_rx_tdata(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT) = dsDMA_dex_Tag then
        dsDex_Tag_Matched_i <= '1';
      else
        dsDex_Tag_Matched_i <= '0';
      end if;
    end if;
  end process;

  -- ---------------------------------
  -- Regenerate trn_rsof_n signal as in old TRN core
  --
  TRN_rsof_n_make :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      in_packet_reg <= '0';
    elsif rising_edge(user_clk) then
      if (m_axis_rx_tvalid and m_axis_rx_tready_i) = '1' then
        in_packet_reg <= not(m_axis_rx_tlast);
      end if;
    end if;
  end process;
  trn_rsof_n <= not(m_axis_rx_tvalid and not(in_packet_reg));

end architecture Behavioral;
