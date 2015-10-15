----------------------------------------------------------------------------------
-- Company:
-- Engineer: abyszuk
--
-- Design Name:
-- Module Name:    rx_MRd_Transact - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision 1.30 - Ported to AXI and OHWR general-cores components 12.2013
--
-- Revision 1.20 - Literal assignments removed.   30.07.2007
--
-- Revision 1.10 - x4 timing constraints met.   02.02.2007
--
-- Revision 1.04 - Timing improved.     17.01.2007
--
-- Revision 1.02 - FIFO added.    20.12.2006
--
-- Revision 1.00 - first release. 14.12.2006
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
use work.genram_pkg.all;

entity rx_MRd_Transact is
  port (
    -- Transaction receive interface
    m_axis_rx_tlast    : in  std_logic;
    m_axis_rx_tdata    : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    m_axis_rx_tkeep    : in  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
    m_axis_rx_terrfwd  : in  std_logic;
    m_axis_rx_tvalid   : in  std_logic;
    m_axis_rx_tready   : in  std_logic;
--      m_axis_rx_tready     : OUT std_logic;
    rx_np_ok           : out std_logic;
    rx_np_req          : out std_logic;
    m_axis_rx_tbar_hit : in  std_logic_vector(C_BAR_NUMBER-1 downto 0);

    sdram_pg : in std_logic_vector(31 downto 0);
    wb_pg    : in std_logic_vector(31 downto 0);

    MRd_Type          : in std_logic_vector(3 downto 0);
    Tlp_straddles_4KB : in std_logic;

    -- MRd Channel
    pioCplD_Req        : out std_logic;
    pioCplD_RE         : in  std_logic;
    pioCplD_Qout       : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

    -- Channel reset (from MWr channel)
    Channel_Rst : in std_logic;

    -- Common ports
    user_clk    : in std_logic;
    user_reset  : in std_logic;
    user_lnk_up : in std_logic
    );

end entity rx_MRd_Transact;


architecture Behavioral of rx_MRd_Transact is

  type RxMRdTrnStates is (ST_MRd_RESET
                                   , ST_MRd_IDLE
                                   , ST_MRd_HEAD2
                                   , ST_MRd_Tail
                                   );

  -- State variables
  signal RxMRdTrn_NextState : RxMRdTrnStates;
  signal RxMRdTrn_State     : RxMRdTrnStates;

  -- trn_rx stubs
  signal trn_rsof_n_i         : std_logic;
  signal in_packet_reg        : std_logic;
  signal m_axis_rx_tdata_i    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal m_axis_rx_tbar_hit_i : std_logic_vector(C_BAR_NUMBER-1 downto 0);

  -- delays
  signal m_axis_rx_tdata_r1    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal m_axis_rx_tbar_hit_r1 : std_logic_vector(C_BAR_NUMBER-1 downto 0);

  -- BAR encoded
  signal Encoded_BAR_Index : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);

  -- Reset
  signal local_Reset   : std_logic;
  signal local_Reset_n : std_logic;

  -- Output signals
--  signal  m_axis_rx_tready_i       : std_logic;
  signal rx_np_ok_i  : std_logic := '1';
  signal rx_np_req_i : std_logic := '1';

  -- Throttle
  signal trn_rx_throttle : std_logic;

  signal MRd_Has_3DW_Header   : std_logic;
  signal MRd_Has_4DW_Header   : std_logic;
  signal Tlp_is_Zero_Length   : std_logic;
  signal Illegal_Leng_on_FIFO : std_logic;

  -- Signal with MRd channel FIFO
  signal pioCplD_din          : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal pioCplD_Qout_wire    : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal pioCplD_RE_i         : std_logic;
  signal pioCplD_we           : std_logic;
  signal pioCplD_empty_i      : std_logic;
  signal pioCplD_full         : std_logic;
  signal pioCplD_prog_Full    : std_logic;
  signal pioCplD_prog_full_r1 : std_logic;

  signal pioCplD_Qout_i   : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal pioCplD_Qout_reg : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  -- Request for output arbitration
  signal pioCplD_Req_i : std_logic;

  -- Busy/Done state bits generation
  type FSM_Request is (
    REQST_Idle
    , REQST_1Read
    , REQST_Decision
    , REQST_nFIFO_Req
--                               , REQST_Quantity
--                               , REQST_FIFO_Req
    );

  signal FSM_REQ_pio : FSM_Request;

begin

  -- positive reset and local
  local_Reset   <= user_reset or Channel_Rst;
  local_reset_n <= not local_reset;

  -- MRd channel buffer control
--   pioCplD_RE_i      <= pioCplD_RE;

  pioCplD_Qout <= pioCplD_Qout_i;
  pioCplD_Req  <= pioCplD_Req_i;        -- and not FIFO_Reading;

  -- Output to the core as handshaking
  m_axis_rx_tdata_i    <= m_axis_rx_tdata;
  m_axis_rx_tbar_hit_i <= m_axis_rx_tbar_hit;

  -- Output to the core as handshaking
  rx_np_ok    <= rx_np_ok_i;
  rx_np_ok_i  <= not pioCplD_prog_full_r1;
  rx_np_req   <= rx_np_req_i;
  rx_np_req_i <= rx_np_ok_i;

  -- ( m_axis_rx_tvalid seems never deasserted during packet)
  trn_rx_throttle <= not(m_axis_rx_tvalid) or not(m_axis_rx_tready);

-- ------------------------------------------------
-- Synchronous Delay: m_axis_rx_tdata + m_axis_rx_tbar_hit
--
  Synch_Delay_m_axis_rx_tdata :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      m_axis_rx_tdata_r1    <= m_axis_rx_tdata_i;
      m_axis_rx_tbar_hit_r1 <= m_axis_rx_tbar_hit_i;
    end if;
  end process;

-- ------------------------------------------------
-- States synchronous
--
  Syn_RxTrn_States :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if local_Reset = '1' then
        RxMRdTrn_State <= ST_MRd_RESET;
      else
        RxMRdTrn_State <= RxMRdTrn_NextState;
      end if;
    end if;
  end process;


-- Next States
  Comb_RxTrn_NextStates :
  process (
    RxMRdTrn_State
    , MRd_Type
    , trn_rx_throttle
    , rx_np_ok_i
    )
  begin
    case RxMRdTrn_State is

      when ST_MRd_RESET =>
        RxMRdTrn_NextState <= ST_MRd_IDLE;

      when ST_MRd_IDLE =>

        if rx_np_ok_i = '1' and trn_rx_throttle = '0' then

          case MRd_Type is

            when C_TLP_TYPE_IS_MRD_H3 =>
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
            when C_TLP_TYPE_IS_MRD_H4 =>
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
            when C_TLP_TYPE_IS_MRDLK_H3 =>
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
            when C_TLP_TYPE_IS_MRDLK_H4 =>
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
            when others =>
              RxMRdTrn_NextState <= ST_MRd_IDLE;

          end case;  -- MRd_Type

        else
          RxMRdTrn_NextState <= ST_MRd_IDLE;
        end if;

      when ST_MRd_HEAD2 =>
        if trn_rx_throttle = '1' then
          RxMRdTrn_NextState <= ST_MRd_HEAD2;
        else
          RxMRdTrn_NextState <= ST_MRd_Tail;
        end if;

      when ST_MRd_Tail =>               -- support back-to-back transactions

        if rx_np_ok_i = '1' and trn_rx_throttle = '0' then

          case MRd_Type is

            when C_TLP_TYPE_IS_MRD_H3 =>
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
            when C_TLP_TYPE_IS_MRD_H4 =>
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
            when C_TLP_TYPE_IS_MRDLK_H3 =>
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
            when C_TLP_TYPE_IS_MRDLK_H4 =>
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
            when others =>
              RxMRdTrn_NextState <= ST_MRd_IDLE;

          end case;  -- MRd_Type

        else
          RxMRdTrn_NextState <= ST_MRd_IDLE;
        end if;

      when others =>
        RxMRdTrn_NextState <= ST_MRd_RESET;

    end case;

  end process;


-- ------------------------------------------------
-- Synchronous calculation: Encoded_BAR_Index
--
  Syn_Calc_Encoded_BAR_Index :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if local_Reset = '1' then
        Encoded_BAR_Index <= (others => '1');
      else
        if m_axis_rx_tbar_hit(0) = '1' then
          Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(0, C_ENCODE_BAR_NUMBER);
        elsif m_axis_rx_tbar_hit(1) = '1' then
          Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(1, C_ENCODE_BAR_NUMBER);
        elsif m_axis_rx_tbar_hit(2) = '1' then
          Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(2, C_ENCODE_BAR_NUMBER);
        elsif m_axis_rx_tbar_hit(3) = '1' then
          Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(3, C_ENCODE_BAR_NUMBER);
        elsif m_axis_rx_tbar_hit(4) = '1' then
          Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(4, C_ENCODE_BAR_NUMBER);
        elsif m_axis_rx_tbar_hit(5) = '1' then
          Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(5, C_ENCODE_BAR_NUMBER);
        elsif m_axis_rx_tbar_hit(6) = '1' then
          Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(6, C_ENCODE_BAR_NUMBER);
        else
          Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(7, C_ENCODE_BAR_NUMBER);
        end if;
      end if;
    end if;
  end process;

-- ----------------------------------------------------------------------------------
--
-- Synchronous output: MRd FIFO write port
--
-- PIO Channel Buffer (128-bit) definition:
--     Note: Type not shows in this buffer
--
--  127 ~ xxx : Peripheral address
--  xxy ~  97 : reserved
--         96 : Zero-length
--         95 : reserved
--         94 : Valid
--   93 ~  68 : reserved
--   67 ~  65 : BAR number
--   64 ~  49 : Requester ID
--   48 ~  41 : Tag
--   40 ~  34 : Lower Address
--   33 ~  31 : Completion Status
--   30 ~  19 : Byte count
--
--   18 ~  17 : Format
--   16 ~  14 : TC
--         13 : TD
--         12 : EP
--   11 ~  10 : Attribute
--    9 ~   0 : Length
--
  RxFSM_Output_pioCplD_WR :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if local_Reset = '1' then
        pioCplD_we  <= '0';
        pioCplD_din <= (others => '0');
      else
        case RxMRdTrn_State is
  
          when ST_MRd_HEAD2 =>
            pioCplD_we <= '0';
  
            if Illegal_Leng_on_FIFO = '1' then  -- Cpl : unsupported request
              pioCplD_din(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT) <= C_FMT3_NO_DATA;
              pioCplD_din(C_CHBUF_CPLD_CS_BIT_TOP downto C_CHBUF_CPLD_CS_BIT_BOT) <= "001";
            else
              pioCplD_din(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT) <= C_FMT3_WITH_DATA;
              pioCplD_din(C_CHBUF_CPLD_CS_BIT_TOP downto C_CHBUF_CPLD_CS_BIT_BOT) <= "000";
            end if;
  
            pioCplD_din(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT) <= m_axis_rx_tdata_r1(C_TLP_TC_BIT_TOP downto C_TLP_TC_BIT_BOT);
            pioCplD_din(C_CHBUF_TD_BIT) <= '0';
            pioCplD_din(C_CHBUF_EP_BIT) <= '0';
            pioCplD_din(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT) <= m_axis_rx_tdata_r1(C_TLP_ATTR_BIT_TOP downto C_TLP_ATTR_BIT_BOT);
            pioCplD_din(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT) <= m_axis_rx_tdata_r1(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT);
            pioCplD_din(C_CHBUF_QVALID_BIT) <= '1';
            pioCplD_din(C_CHBUF_CPLD_REQID_BIT_TOP downto C_CHBUF_CPLD_REQID_BIT_BOT) <= m_axis_rx_tdata_r1(C_TLP_REQID_BIT_TOP downto C_TLP_REQID_BIT_BOT);
            pioCplD_din(C_CHBUF_CPLD_TAG_BIT_TOP downto C_CHBUF_CPLD_TAG_BIT_BOT) <= m_axis_rx_tdata_r1(C_TLP_TAG_BIT_TOP downto C_TLP_TAG_BIT_BOT);
            pioCplD_din(C_CHBUF_0LENG_BIT) <= Tlp_is_Zero_Length;
  
            if Tlp_is_Zero_Length = '1' then
              pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT) <= CONV_STD_LOGIC_VECTOR(0, C_ENCODE_BAR_NUMBER);
            else
              pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT) <= Encoded_BAR_Index;
            end if;
  
          when ST_MRd_Tail =>
  
            if MRd_Has_4DW_Header = '1' then
              pioCplD_din(C_CHBUF_CPLD_LA_BIT_TOP downto C_CHBUF_CPLD_LA_BIT_BOT)
                <= m_axis_rx_tdata_r1(C_CHBUF_CPLD_LA_BIT_TOP-C_CHBUF_CPLD_LA_BIT_BOT+32 downto 0+32);
  
              if m_axis_rx_tbar_hit_r1(CINT_REGS_SPACE_BAR) = '1' then
                pioCplD_din(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)
                  <= m_axis_rx_tdata_r1(C_CHBUF_PA_BIT_TOP-C_CHBUF_PA_BIT_BOT+32 downto 0+32);
              elsif m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1' then
                pioCplD_din(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT)
                  <= sdram_pg(C_CHBUF_DDA_BIT_TOP-C_CHBUF_DDA_BIT_BOT-C_DDR_PG_WIDTH downto 0) &
                     m_axis_rx_tdata_r1(C_DDR_PG_WIDTH-1+32 downto 0+32);
              elsif m_axis_rx_tbar_hit_r1(CINT_FIFO_SPACE_BAR) = '1' then
                pioCplD_din(C_CHBUF_WB_BIT_TOP downto C_CHBUF_WB_BIT_BOT)
                  <= wb_pg(C_CHBUF_WB_BIT_TOP-C_CHBUF_WB_BIT_BOT-C_WB_PG_WIDTH downto 0) &
                     m_axis_rx_tdata_r1(C_WB_PG_WIDTH-1+32 downto 0+32);
              else
                pioCplD_din(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)
                  <= C_ALL_ZEROS(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT);
              end if;
  
            else
              pioCplD_din(C_CHBUF_CPLD_LA_BIT_TOP downto C_CHBUF_CPLD_LA_BIT_BOT)
                <= m_axis_rx_tdata_r1(C_CHBUF_CPLD_LA_BIT_TOP-C_CHBUF_CPLD_LA_BIT_BOT downto 0);
  
              if m_axis_rx_tbar_hit_r1(CINT_REGS_SPACE_BAR) = '1' then
                pioCplD_din(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)
                  <= m_axis_rx_tdata_r1(C_CHBUF_PA_BIT_TOP-C_CHBUF_PA_BIT_BOT downto 0);
              elsif m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1' then
                pioCplD_din(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT)
                  <= sdram_pg(C_CHBUF_DDA_BIT_TOP-C_CHBUF_DDA_BIT_BOT-C_DDR_PG_WIDTH downto 0) &
                     m_axis_rx_tdata_r1(C_DDR_PG_WIDTH-1 downto 0);
              elsif m_axis_rx_tbar_hit_r1(CINT_FIFO_SPACE_BAR) = '1' then
                pioCplD_din(C_CHBUF_WB_BIT_TOP downto C_CHBUF_WB_BIT_BOT)
                  <= wb_pg(C_CHBUF_WB_BIT_TOP-C_CHBUF_WB_BIT_BOT-C_WB_PG_WIDTH downto 0) &
                     m_axis_rx_tdata_r1(C_WB_PG_WIDTH-1 downto 0);
              else
                pioCplD_din(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)
                  <= C_ALL_ZEROS(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT);
              end if;
            end if;
  
            if pioCplD_din(C_CHBUF_0LENG_BIT) = '1' then  --  Zero-length
              pioCplD_din(C_CHBUF_CPLD_BC_BIT_TOP downto C_CHBUF_CPLD_BC_BIT_BOT)
                <= CONV_STD_LOGIC_VECTOR(1, C_CHBUF_CPLD_BC_BIT_TOP-C_CHBUF_CPLD_BC_BIT_BOT+1);
            else
              pioCplD_din(C_CHBUF_CPLD_BC_BIT_TOP downto C_CHBUF_CPLD_BC_BIT_BOT)
                <= pioCplD_din(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT) &"00";
            end if;
  
            if m_axis_rx_tbar_hit_r1(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ZEROS(CINT_BAR_SPACES-1 downto 0) then
              pioCplD_we <= not Tlp_straddles_4KB;  --'1';
            else
              pioCplD_we <= '0';
            end if;
  
          when others =>
            pioCplD_we  <= '0';
            pioCplD_din <= pioCplD_din;
  
        end case;
      end if;
    end if;
  end process;

-- -----------------------------------------------------------------------
-- Capture: MRd_Has_4DW_Header
--        : Tlp_is_Zero_Length
--
  Syn_Capture_MRd_Has_4DW_Header :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        MRd_Has_3DW_Header   <= '0';
        MRd_Has_4DW_Header   <= '0';
        Tlp_is_Zero_Length   <= '0';
        Illegal_Leng_on_FIFO <= '0';
      else
        if trn_rsof_n_i = '0' then
          MRd_Has_3DW_Header <= not m_axis_rx_tdata_i(C_TLP_FMT_BIT_BOT) and not m_axis_rx_tdata_i(C_TLP_FMT_BIT_BOT+1);
          MRd_Has_4DW_Header <= m_axis_rx_tdata_i(C_TLP_FMT_BIT_BOT) and not m_axis_rx_tdata_i(C_TLP_FMT_BIT_BOT+1);
          --Tlp_is_Zero_Length   <= not (m_axis_rx_tdata_i(3) or m_axis_rx_tdata_i(2) or m_axis_rx_tdata_i(1) or m_axis_rx_tdata_i(0));
          if m_axis_rx_tdata(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT) = C_ALL_ZEROS(C_TLP_FLD_WIDTH_OF_LENG - 1 downto 0) then
            Tlp_is_Zero_Length <= '1';
          else
            Tlp_is_Zero_Length <= '0';
          end if;
          if m_axis_rx_tdata_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT) /= CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG)
            and m_axis_rx_tdata_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT) /= CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG)
            and m_axis_rx_tbar_hit(CINT_FIFO_SPACE_BAR) = '1'
          then
            Illegal_Leng_on_FIFO <= '1';
          else
            Illegal_Leng_on_FIFO <= '0';
          end if;
        else
          MRd_Has_3DW_Header   <= MRd_Has_3DW_Header;
          MRd_Has_4DW_Header   <= MRd_Has_4DW_Header;
          Tlp_is_Zero_Length   <= Tlp_is_Zero_Length;
          Illegal_Leng_on_FIFO <= Illegal_Leng_on_FIFO;
        end if;
      end if;
    end if;
  end process;

  -- -------------------------------------------------
  -- MRd TLP Buffer
  -- -------------------------------------------------
  pioCplD_Buffer :
    generic_sync_fifo
      generic map (
        g_data_width => 128,
        g_size => 16,
        g_show_ahead => false,
        g_with_empty => true,
        g_with_full => false,
        g_with_almost_empty => false,
        g_with_almost_full => true,
        g_with_count => false,
        g_almost_full_threshold => 12)
      port map (
        rst_n_i => local_Reset_n,
        clk_i   => user_clk,

        d_i            => pioCplD_din,
        we_i           => pioCplD_we,
        q_o            => pioCplD_Qout_wire,
        rd_i           => pioCplD_RE_i,
        empty_o        => pioCplD_empty_i,
        full_o         => pioCplD_full,
        almost_empty_o => open,
        almost_full_o  => pioCplD_prog_Full,
        count_o        => open);

-- ---------------------------------------------
--  Request for arbitration
--
  Synch_Req_Proc :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if local_Reset = '1' then
        pioCplD_RE_i     <= '0';
        pioCplD_Qout_i   <= (others => '0');
        pioCplD_Qout_reg <= (others => '0');
        pioCplD_Req_i    <= '0';
        FSM_REQ_pio      <= REQST_IDLE;
      else
        case FSM_REQ_pio is
  
          when REQST_IDLE =>
            if pioCplD_empty_i = '0' then
              pioCplD_RE_i   <= '1';
              pioCplD_Req_i  <= '0';
              pioCplD_Qout_i <= pioCplD_Qout_i;
              FSM_REQ_pio    <= REQST_1Read;
            else
              pioCplD_RE_i   <= '0';
              pioCplD_Req_i  <= '0';
              pioCplD_Qout_i <= pioCplD_Qout_i;
              FSM_REQ_pio    <= REQST_IDLE;
            end if;
  
          when REQST_1Read =>
            pioCplD_RE_i   <= '0';
            pioCplD_Req_i  <= '0';
            pioCplD_Qout_i <= pioCplD_Qout_i;
            FSM_REQ_pio    <= REQST_Decision;
  
          when REQST_Decision =>
            pioCplD_Qout_reg <= pioCplD_Qout_wire;
            pioCplD_Qout_i   <= pioCplD_Qout_i;
            pioCplD_RE_i     <= '0';
            pioCplD_Req_i    <= '1';
            FSM_REQ_pio      <= REQST_nFIFO_Req;
  
          when REQST_nFIFO_Req =>
            if pioCplD_RE = '1' then
              pioCplD_RE_i   <= '0';
              pioCplD_Qout_i <= pioCplD_Qout_reg;
              pioCplD_Req_i  <= '0';
              FSM_REQ_pio    <= REQST_IDLE;
            else
              pioCplD_RE_i   <= '0';
              pioCplD_Qout_i <= pioCplD_Qout_i;
              pioCplD_Req_i  <= '1';
              FSM_REQ_pio    <= REQST_nFIFO_Req;
            end if;
  
          when others =>
            pioCplD_RE_i     <= '0';
            pioCplD_Qout_i   <= (others => '0');
            pioCplD_Qout_reg <= (others => '0');
            pioCplD_Req_i    <= '0';
            FSM_REQ_pio      <= REQST_IDLE;
  
        end case;
      end if;
    end if;
  end process;

-- ---------------------------------------------
--  Delay of Empty and prog_Full
--
  Synch_Delay_empty_and_full :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      pioCplD_prog_full_r1 <= pioCplD_prog_Full;
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
      if (m_axis_rx_tvalid) = '1' then
        in_packet_reg <= not(m_axis_rx_tlast);
      end if;
    end if;
  end process;
  trn_rsof_n_i <= not(m_axis_rx_tvalid and not(in_packet_reg));

end architecture Behavioral;
