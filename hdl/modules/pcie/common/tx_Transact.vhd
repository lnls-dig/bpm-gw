----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name:    tx_Transact - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision 1.30 - Memory buffer applied and structure regulated for DPR.   25.03.2008
--
-- Revision 1.20 - Literal assignments rewritten.   02.08.2007
--
-- Revision 1.10 - x4 timing constraints met.   02.02.2007
--
-- Revision 1.06 - BRAM output and FIFO output both registered.  01.02.2007
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

entity tx_Transact is
  port (
    -- Common ports
    user_clk    : in std_logic;
    user_reset  : in std_logic;
    user_lnk_up : in std_logic;
    -- Transaction
    s_axis_tx_tlast   : out std_logic;
    s_axis_tx_tdata   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    s_axis_tx_tkeep   : out std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
    s_axis_tx_terrfwd : out std_logic;
    s_axis_tx_tvalid  : out std_logic;
    s_axis_tx_tready  : in  std_logic;
    s_axis_tx_tdsc    : out std_logic;
    tx_buf_av         : in  std_logic_vector(C_TBUF_AWIDTH-1 downto 0);
    -- Upstream DMA transferred bytes count up
    us_DMA_Bytes_Add : out std_logic;
    us_DMA_Bytes     : out std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);
    -- Wishbone Read interface
    wb_rdc_sof  : out std_logic;
    wb_rdc_v    : out std_logic;
    wb_rdc_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wb_rdc_full : in std_logic;
    -- Wisbbone Buffer read port
    wb_FIFO_re    : out std_logic;
    wb_FIFO_empty : in  std_logic;
    wb_FIFO_qout  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    -- Read interface for Tx port
    Regs_RdAddr : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
    Regs_RdQout : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    -- Irpt Channel
    Irpt_Req  : in  std_logic;
    Irpt_RE   : out std_logic;
    Irpt_Qout : in  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
    -- PIO MRd Channel
    pioCplD_Req  : in  std_logic;
    pioCplD_RE   : out std_logic;
    pioCplD_Qout : in  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
    -- downstream MRd Channel
    dsMRd_Req  : in  std_logic;
    dsMRd_RE   : out std_logic;
    dsMRd_Qout : in  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
    -- upstream MWr/MRd Channel
    usTlp_Req   : in  std_logic;
    usTlp_RE    : out std_logic;
    usTlp_Qout  : in  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
    us_FC_stop  : out std_logic;
    us_Last_sof : out std_logic;
    us_Last_eof : out std_logic;
    -- Message routing method
    Msg_Routing : in std_logic_vector(C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT downto 0);
    --  DDR read port
    ddr_mm2s_cmd_tvalid : out STD_LOGIC;
    ddr_mm2s_cmd_tready : in STD_LOGIC;
    ddr_mm2s_cmd_tdata : out STD_LOGIC_VECTOR(71 DOWNTO 0);
    -- DDR payload FIFO Read Port
    ddr_mm2s_tdata : in STD_LOGIC_VECTOR(63 DOWNTO 0);
    ddr_mm2s_tkeep : in STD_LOGIC_VECTOR(7 DOWNTO 0);
    ddr_mm2s_tlast : in STD_LOGIC;
    ddr_mm2s_tvalid : in STD_LOGIC;
    ddr_mm2s_tready : out STD_LOGIC;
    -- Additional
    Tx_TimeOut    : out std_logic;
    Tx_wb_TimeOut : out std_logic;
    Tx_Reset      : in  std_logic;
    localID       : in  std_logic_vector(C_ID_WIDTH-1 downto 0)
    );

end tx_Transact;


architecture Behavioral of tx_Transact is

  type TxTrnStates is (St_TxIdle,       -- Idle

                       St_d_CmdReq,     -- Issue the read command to MemReader
                       St_d_CmdAck,  -- Wait for the read command ACK from MemReader
                       St_d_Header0,    -- 1st Header for TLP with payload
                       St_d_Header2,    -- 2nd Header for TLP with payload
                       St_d_1st_Data,   -- Last Header for TLP3/4 with payload
                       St_d_Payload,    -- Data for TLP with payload
                       St_d_Payload_used,  -- Data flow from memory buffer discontinued
                       St_d_Tail,       -- Last data for TLP with payload
                       St_d_Tail_chk,  -- Last data extended for TLP with payload
                       St_nd_Prepare,  -- Prepare for 1st Header of TLP without payload
                       St_nd_Header2,   -- 2nd Header for TLP without payload
                       St_nd_HeaderLast,  -- Tail processing for the last dword of TLP w/o payload
                       St_nd_Arbitration  -- One extra cycle for arbitration
                       );

  -- State variables
  signal TxTrn_State : TxTrnStates;

  -- Signals with the arbitrator
  signal take_an_Arbitration : std_logic;
  signal Req_Bundle          : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal Read_a_Buffer       : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal Ack_Indice          : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);

  signal b1_Tx_Indicator  : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal vec_ChQout_Valid : std_logic_vector (C_CHANNEL_NUMBER-1 downto 0);
  signal Tx_Busy          : std_logic;

  -- Channel buffer output token bits
  signal usTLP_is_MWr : std_logic;
  signal TLP_is_CplD  : std_logic;

  -- Bit information, telling whether the outgoing TLP has payload
  signal ChBuf_has_Payload : std_logic;
  signal ChBuf_No_Payload  : std_logic;

  -- Channel buffers output OR'ed and registered
  signal Trn_Qout_wire : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal Trn_Qout_reg  : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  --  Addresses from different channel buffer
  signal wbaddr_piocpld    : std_logic_vector(C_WB_AWIDTH-1 downto 0);
  signal mAddr_usTlp       : std_logic_vector(C_PRAM_AWIDTH-1+2 downto 0);
  signal DDRAddr_usTlp     : std_logic_vector(C_DDR_IAWIDTH-1 downto 0);
  signal WBAddr_usTlp      : std_logic_vector(C_WB_AWIDTH-1 downto 0);
  signal Regs_Addr_pioCplD : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal DDRAddr_pioCplD   : std_logic_vector(C_DDR_IAWIDTH-1 downto 0);
  --  BAR number
  signal BAR_pioCplD       : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
  signal BAR_usTlp         : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
  --  Misc. info.
  signal AInc_usTlp        : std_logic;
  signal pioCplD_is_0Leng  : std_logic;

  -- Delay for requests from Channel Buffers
  signal Irpt_Req_r1    : std_logic;
  signal pioCplD_Req_r1 : std_logic;
  signal dsMRd_Req_r1   : std_logic;
  signal usTlp_Req_r1   : std_logic;

  -- Registered channel buffer outputs
  signal Irpt_Qout_to_TLP    : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal pioCplD_Qout_to_TLP : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal dsMRd_Qout_to_TLP   : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal usTlp_Qout_to_TLP   : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  signal pioCplD_Req_Min_Leng : std_logic;
  signal pioCplD_Req_2DW_Leng : std_logic;
  signal usTlp_Req_Min_Leng   : std_logic;
  signal usTlp_Req_2DW_Leng   : std_logic;

  --  Channel buffer read enables
  signal Irpt_RE_i    : std_logic;
  signal pioCplD_RE_i : std_logic;
  signal dsMRd_RE_i   : std_logic;
  signal usTlp_RE_i   : std_logic;

  -- Flow controls
  signal us_FC_stop_i  : std_logic;

  -- Local reset for tx
  signal trn_tx_Reset_n : std_logic;

  -- Alias for transaction interface signals
  signal s_axis_tx_tdata_i   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal s_axis_tx_tkeep_i   : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal s_axis_tx_tlast_i   : std_logic;
  signal s_axis_tx_tvalid_i  : std_logic;
  signal s_axis_tx_tdsc_i    : std_logic;
  signal s_axis_tx_terrfwd_i : std_logic;
  signal s_axis_tx_tready_i  : std_logic;

  signal tx_buf_av_i  : std_logic_vector(C_TBUF_AWIDTH-1 downto 0);
  signal trn_tsof_n_i : std_logic;

  -- Upstream DMA transferred bytes count up
  signal us_DMA_Bytes_Add_i : std_logic;
  signal us_DMA_Bytes_i     : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

  signal RdNumber        : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
  signal RdNumber_eq_One : std_logic;
  signal RdNumber_eq_Two : std_logic;
  signal StartAddr       : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal Shift_1st_QWord : std_logic;
  signal is_CplD         : std_logic;
  signal BAR_value       : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
  signal RdCmd_Req       : std_logic;
  signal RdCmd_Ack       : std_logic;

  signal mbuf_reset_n : std_logic;
  signal mbuf_WE     : std_logic;
  signal mbuf_Din    : std_logic_vector(C_DBUS_WIDTH*9/8-1 downto 0);
  signal mbuf_Full   : std_logic;
  signal mbuf_aFull  : std_logic;
  signal mbuf_RE     : std_logic;
  signal mbuf_Qout   : std_logic_vector(C_DBUS_WIDTH*9/8-1 downto 0);
  signal mbuf_Empty  : std_logic;
  -- Calculated infomation
  signal mbuf_RE_ok  : std_logic;
  signal mbuf_Qvalid : std_logic;

begin

  -- Connect outputs
  s_axis_tx_tdata   <= s_axis_tx_tdata_i;
  s_axis_tx_tkeep   <= s_axis_tx_tkeep_i;
  s_axis_tx_tlast   <= s_axis_tx_tlast_i;
  s_axis_tx_tvalid  <= s_axis_tx_tvalid_i;
  s_axis_tx_tdsc    <= s_axis_tx_tdsc_i;
  s_axis_tx_terrfwd <= s_axis_tx_terrfwd_i;

  us_Last_sof   <= usTLP_is_MWr and not trn_tsof_n_i;
  us_Last_eof   <= usTLP_is_MWr and not s_axis_tx_tlast_i;

  -- Connect inputs
  s_axis_tx_tready_i <= s_axis_tx_tready;
  tx_buf_av_i        <= tx_buf_av;

  -- Always deasserted
  s_axis_tx_tdsc_i    <= '0';
  s_axis_tx_terrfwd_i <= '0';

  -- Upstream DMA transferred bytes counting up
  us_DMA_Bytes_Add <= us_DMA_Bytes_Add_i;
  us_DMA_Bytes     <= us_DMA_Bytes_i;

  -- Flow controls
  us_FC_stop  <= us_FC_stop_i;

---------------------------------------------------------------------------------
-- Synchronous Calculation: us_FC_stop, pio_FC_stop
--
  Synch_Calc_FC_stop :
  process (user_clk, Tx_Reset)
  begin
    if rising_edge(user_clk) then
      if Tx_Reset = '1' then
        us_FC_stop_i <= '1';
      else
        if tx_buf_av_i(C_TBUF_AWIDTH-1 downto 1) /= C_ALL_ZEROS(C_TBUF_AWIDTH-1 downto 1) then
          us_FC_stop_i  <= '0';
        else
          us_FC_stop_i  <= '1';
        end if;
      end if;
    end if;
  end process;

  -- Channel buffer read enable
  Irpt_RE    <= Irpt_RE_i;
  pioCplD_RE <= pioCplD_RE_i;
  dsMRd_RE   <= dsMRd_RE_i;
  usTlp_RE   <= usTlp_RE_i;

-- -----------------------------------
--   Synchronized Local reset
--
  Syn_Local_Reset :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        trn_tx_Reset_n <= '0';
      else
        trn_tx_Reset_n <= not Tx_Reset;
      end if;
    end if;
  end process;

  ---------------------  Memory Reader  -----------------------------
  ---
  --- Memory reader is the interface to access all sorts of memories
  ---   BRAM, FIFO, Registers, as well as possible DDR SDRAM
  ---
  -------------------------------------------------------------------
  ABB_Tx_MReader :
    entity work.tx_Mem_Reader
      port map(
        --  DDR read port
        ddr_mm2s_cmd_tvalid => ddr_mm2s_cmd_tvalid,
        ddr_mm2s_cmd_tready => ddr_mm2s_cmd_tready,
        ddr_mm2s_cmd_tdata => ddr_mm2s_cmd_tdata,
        ddr_mm2s_tdata => ddr_mm2s_tdata,
        ddr_mm2s_tkeep => ddr_mm2s_tkeep,
        ddr_mm2s_tlast => ddr_mm2s_tlast,
        ddr_mm2s_tvalid => ddr_mm2s_tvalid,
        ddr_mm2s_tready => ddr_mm2s_tready,

        wb_rdc_sof  => wb_rdc_sof, -- : out std_logic;
        wb_rdc_v    => wb_rdc_v, --   : out std_logic;
        wb_rdc_din  => wb_rdc_din, -- : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        wb_rdc_full => wb_rdc_full, --: in std_logic;

        wb_FIFO_re    => wb_FIFO_re ,   -- OUT std_logic;
        wb_FIFO_empty => wb_FIFO_empty ,  -- IN  std_logic;
        wb_FIFO_qout  => wb_FIFO_qout ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        Regs_RdAddr => Regs_RdAddr ,  -- OUT std_logic_vector(C_EP_AWIDTH-1 downto 0);
        Regs_RdQout => Regs_RdQout ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        RdNumber        => RdNumber ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        RdNumber_eq_One => RdNumber_eq_One ,  -- IN  std_logic;
        RdNumber_eq_Two => RdNumber_eq_Two ,  -- IN  std_logic;
        StartAddr       => StartAddr ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        Shift_1st_QWord => Shift_1st_QWord ,  -- IN  std_logic;
        is_CplD         => is_CplD ,    -- IN  std_logic;
        BAR_value       => BAR_value ,  -- IN  std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
        RdCmd_Req       => RdCmd_Req ,  -- IN  std_logic;
        RdCmd_Ack       => RdCmd_Ack ,  -- OUT std_logic;

        mbuf_WE       => mbuf_WE ,      -- OUT std_logic;
        mbuf_Din      => mbuf_Din ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        mbuf_Full     => mbuf_Full ,    -- IN  std_logic;
        mbuf_aFull    => mbuf_aFull ,   -- IN  std_logic;

        Tx_TimeOut    => Tx_TimeOut ,      -- OUT std_logic;
        Tx_wb_TimeOut => Tx_wb_TimeOut ,   -- OUT std_logic;
        mReader_Rst_n => trn_tx_Reset_n ,  -- IN  std_logic;
        user_clk      => user_clk          -- IN  std_logic
        );

---------------------  Memory Buffer  -----------------------------
---
--- A unified memory buffer holding the payload for the next tx TLP
---   34 bits wide, wherein 2 additional framing bits
---   temporarily 64 data depth, possibly deepened.
---
-------------------------------------------------------------------

  ABB_Tx_MBuffer :
    generic_sync_fifo
      generic map (
        g_data_width => 72,
        g_size => 128,
        g_show_ahead => false,
        g_with_empty => true,
        g_with_full => true,
        g_with_almost_empty => false,
        g_with_almost_full => true,
        g_with_count => false,
        g_almost_full_threshold => 124)
      port map(
        rst_n_i => mbuf_reset_n,
        clk_i   => user_clk,

        d_i            => mbuf_din,
        we_i           => mbuf_we,
        q_o            => mbuf_qout,
        rd_i           => mbuf_re,
        empty_o        => mbuf_empty,
        full_o         => mbuf_full,
        almost_empty_o => open,
        almost_full_o  => mbuf_afull,
        count_o        => open);

  mbuf_RE <= mbuf_RE_ok and (s_axis_tx_tready_i or not s_axis_tx_tvalid_i);

---------------------------------------------------------------------------------
-- Synchronous Delay: mbuf_Qout Valid
--
  Synchron_Delay_mbuf_Qvalid :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if Tx_Reset = '1' then
        mbuf_Qvalid <= '0';
      else
        if mbuf_Qvalid = '0' and mbuf_RE = '1' and mbuf_Empty = '0' then  -- a valid data is going out
          mbuf_Qvalid <= '1';
        elsif mbuf_Qvalid = '1' and mbuf_RE = '1' and mbuf_Empty = '1' then  -- an invalid data is going out
          mbuf_Qvalid <= '0';
        else                              -- state stays
          mbuf_Qvalid <= mbuf_Qvalid;
        end if;
      end if;
    end if;
  end process;

------------------------------------------------------------
---             Output arbitration
------------------------------------------------------------
  O_Arbitration :
    entity work.Tx_Output_Arbitor
      port map(
        rst_n   => trn_tx_Reset_n,
        clk     => user_clk,
        arbtake => take_an_Arbitration,
        Req     => Req_Bundle,
        bufread => Read_a_Buffer,
        Ack     => Ack_Indice
        );

-----------------------------------------------------
-- Synchronous Delay: Channel Requests
--
  Synchron_Delay_ChRequests :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      Irpt_Req_r1    <= Irpt_Req;
      pioCplD_Req_r1 <= pioCplD_Req;
      dsMRd_Req_r1   <= dsMRd_Req;
      usTlp_Req_r1   <= usTlp_Req;
    end if;
  end process;

-----------------------------------------------------
-- Synchronous Delay: Tx_Busy
--
  Synchron_Delay_Tx_Busy :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      Tx_Busy      <= (b1_Tx_Indicator(C_CHAN_INDEX_IRPT) and vec_ChQout_Valid(C_CHAN_INDEX_IRPT))
                      or (b1_Tx_Indicator(C_CHAN_INDEX_MRD) and vec_ChQout_Valid(C_CHAN_INDEX_MRD))
                      or (b1_Tx_Indicator(C_CHAN_INDEX_DMA_DS) and vec_ChQout_Valid(C_CHAN_INDEX_DMA_DS))
                      or (b1_Tx_Indicator(C_CHAN_INDEX_DMA_US) and vec_ChQout_Valid(C_CHAN_INDEX_DMA_US));
    end if;
  end process;

-- ---------------------------------------------
-- Reg : Channel Buffer Qout has Payload
--
  Reg_ChBuf_with_Payload :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      ChBuf_has_Payload <= (b1_Tx_Indicator(C_CHAN_INDEX_MRD) and TLP_is_CplD and vec_ChQout_Valid(C_CHAN_INDEX_MRD))
                           or (b1_Tx_Indicator(C_CHAN_INDEX_DMA_US) and usTLP_is_MWr and vec_ChQout_Valid(C_CHAN_INDEX_DMA_US));
    end if;
  end process;

-- ---------------------------------------------
-- Channel Buffer Qout has no Payload
--   (! subordinate to ChBuf_has_Payload ! )
--
  ChBuf_No_Payload <= Tx_Busy;

-- Arbitrator inputs
  Req_Bundle(C_CHAN_INDEX_IRPT)   <= Irpt_Req_r1;
  Req_Bundle(C_CHAN_INDEX_MRD)    <= pioCplD_Req_r1;
  Req_Bundle(C_CHAN_INDEX_DMA_DS) <= dsMRd_Req_r1;
  Req_Bundle(C_CHAN_INDEX_DMA_US) <= usTlp_Req_r1;

-- Arbitrator outputs
  b1_Tx_Indicator(C_CHAN_INDEX_IRPT)   <= Ack_Indice(C_CHAN_INDEX_IRPT);
  b1_Tx_Indicator(C_CHAN_INDEX_MRD)    <= Ack_Indice(C_CHAN_INDEX_MRD);
  b1_Tx_Indicator(C_CHAN_INDEX_DMA_DS) <= Ack_Indice(C_CHAN_INDEX_DMA_DS);
  b1_Tx_Indicator(C_CHAN_INDEX_DMA_US) <= Ack_Indice(C_CHAN_INDEX_DMA_US);


-- Arbitrator reads channel buffers
  Irpt_RE_i    <= Read_a_Buffer(C_CHAN_INDEX_IRPT);
  pioCplD_RE_i <= Read_a_Buffer(C_CHAN_INDEX_MRD);
  dsMRd_RE_i   <= Read_a_Buffer(C_CHAN_INDEX_DMA_DS);
  usTlp_RE_i   <= Read_a_Buffer(C_CHAN_INDEX_DMA_US);


-- determine whether the upstream TLP is an MWr or an MRd.
  usTLP_is_MWr <= usTlp_Qout (C_CHBUF_FMT_BIT_TOP);
  TLP_is_CplD  <= pioCplD_Qout(C_CHBUF_FMT_BIT_TOP);


-- check if the Channel buffer output is valid
  vec_ChQout_Valid(C_CHAN_INDEX_IRPT)   <= Irpt_Qout (C_CHBUF_QVALID_BIT);
  vec_ChQout_Valid(C_CHAN_INDEX_MRD)    <= pioCplD_Qout(C_CHBUF_QVALID_BIT);
  vec_ChQout_Valid(C_CHAN_INDEX_DMA_DS) <= dsMRd_Qout (C_CHBUF_QVALID_BIT);
  vec_ChQout_Valid(C_CHAN_INDEX_DMA_US) <= usTlp_Qout (C_CHBUF_QVALID_BIT);

-- -----------------------------------
-- Delay : Channel_Buffer_Qout
--         Bit-mapping is done
--
  Delay_Channel_Buffer_Qout :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if trn_tx_Reset_n = '0' then
        Irpt_Qout_to_TLP    <= (others => '0');
        pioCplD_Qout_to_TLP <= (others => '0');
        dsMRd_Qout_to_TLP   <= (others => '0');
        usTlp_Qout_to_TLP   <= (others => '0');
  
        pioCplD_Req_Min_Leng <= '0';
        pioCplD_Req_2DW_Leng <= '0';
        usTlp_Req_Min_Leng   <= '0';
        usTlp_Req_2DW_Leng   <= '0';
  
        Regs_Addr_pioCplD <= (others => '1');
        wbaddr_piocpld    <= (others => '1');
        mAddr_usTlp       <= (others => '1');
        AInc_usTlp        <= '1';
        BAR_pioCplD       <= (others => '1');
        BAR_usTlp         <= (others => '1');
        pioCplD_is_0Leng  <= '0';
      else
        if b1_Tx_Indicator(C_CHAN_INDEX_IRPT) = '1' then
          Irpt_Qout_to_TLP                                             <= (others => '0');  -- must be 1st argument
          -- 1st header Hi
          Irpt_Qout_to_TLP(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) <= Irpt_Qout(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT);
  --            Irpt_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)  <= C_TYPE_OF_MSG; --Irpt_Qout(C_CHBUF_MSGTYPE_BIT_TOP downto C_CHBUF_MSGTYPE_BIT_BOT);
          Irpt_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) <= C_TYPE_OF_MSG(C_TLP_TYPE_BIT_TOP
                                                                                           downto C_TLP_TYPE_BIT_BOT+1+C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT)
                                                                             & Msg_Routing;
          Irpt_Qout_to_TLP(C_TLP_TC_BIT_TOP downto C_TLP_TC_BIT_BOT)     <= Irpt_Qout(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT);
          Irpt_Qout_to_TLP(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT) <= Irpt_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
  
          -- 1st header Lo
          Irpt_Qout_to_TLP(C_TLP_REQID_BIT_TOP downto C_TLP_REQID_BIT_BOT) <= localID;
          Irpt_Qout_to_TLP(C_TLP_TAG_BIT_TOP downto C_TLP_TAG_BIT_BOT)     <= Irpt_Qout(C_CHBUF_TAG_BIT_TOP downto C_CHBUF_TAG_BIT_BOT);
          Irpt_Qout_to_TLP(C_MSG_CODE_BIT_TOP downto C_MSG_CODE_BIT_BOT)   <= Irpt_Qout(C_CHBUF_MSG_CODE_BIT_TOP downto C_CHBUF_MSG_CODE_BIT_BOT);
          -- 2nd headers all zero
          -- ...
        else
          Irpt_Qout_to_TLP <= (others => '0');
        end if;
  
        if b1_Tx_Indicator(C_CHAN_INDEX_MRD) = '1' then
          pioCplD_Qout_to_TLP                                                                             <= (others => '0');  -- must be 1st argument
          -- 1st header Hi
          pioCplD_Qout_to_TLP(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT)                                 <= pioCplD_Qout(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT);
          pioCplD_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)                               <= C_TYPE_COMPLETION;  --pioCplD_Qout(C_CHBUF_TYPE_BIT_TOP downto C_CHBUF_TYPE_BIT_BOT);
          pioCplD_Qout_to_TLP(C_TLP_TC_BIT_TOP downto C_TLP_TC_BIT_BOT)                                   <= pioCplD_Qout(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT);
          pioCplD_Qout_to_TLP(C_TLP_ATTR_BIT_TOP downto C_TLP_ATTR_BIT_BOT)                               <= pioCplD_Qout(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT);
          pioCplD_Qout_to_TLP(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)                               <= pioCplD_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
          -- 1st header Lo
          pioCplD_Qout_to_TLP(C_CPLD_CPLT_ID_BIT_TOP downto C_CPLD_CPLT_ID_BIT_BOT)                       <= localID;
          pioCplD_Qout_to_TLP(C_CPLD_CS_BIT_TOP downto C_CPLD_CS_BIT_BOT)                                 <= pioCplD_Qout(C_CHBUF_CPLD_CS_BIT_TOP downto C_CHBUF_CPLD_CS_BIT_BOT);
          pioCplD_Qout_to_TLP(C_CPLD_BC_BIT_TOP downto C_CPLD_BC_BIT_BOT)                                 <= pioCplD_Qout(C_CHBUF_CPLD_BC_BIT_TOP downto C_CHBUF_CPLD_BC_BIT_BOT);
          -- 2nd header Hi
          pioCplD_Qout_to_TLP(C_DBUS_WIDTH+C_CPLD_REQID_BIT_TOP downto C_DBUS_WIDTH+C_CPLD_REQID_BIT_BOT) <= pioCplD_Qout(C_CHBUF_CPLD_REQID_BIT_TOP downto C_CHBUF_CPLD_REQID_BIT_BOT);
          pioCplD_Qout_to_TLP(C_DBUS_WIDTH+C_CPLD_TAG_BIT_TOP downto C_DBUS_WIDTH+C_CPLD_TAG_BIT_BOT)     <= pioCplD_Qout(C_CHBUF_CPLD_TAG_BIT_TOP downto C_CHBUF_CPLD_TAG_BIT_BOT);
          pioCplD_Qout_to_TLP(C_DBUS_WIDTH+C_CPLD_LA_BIT_TOP downto C_DBUS_WIDTH+C_CPLD_LA_BIT_BOT)       <= pioCplD_Qout(C_CHBUF_CPLD_LA_BIT_TOP downto C_CHBUF_CPLD_LA_BIT_BOT);
          -- no 2nd header Lo
  
          if pioCplD_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
             = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG)
          then
            pioCplD_Req_Min_Leng <= '1';
          else
            pioCplD_Req_Min_Leng <= '0';
          end if;
          if pioCplD_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
             = CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG)
          then
            pioCplD_Req_2DW_Leng <= '1';
          else
            pioCplD_Req_2DW_Leng <= '0';
          end if;
  
          -- Misc
          Regs_Addr_pioCplD <= pioCplD_Qout(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT);
          wbaddr_piocpld    <= pioCplD_Qout(C_CHBUF_WB_BIT_TOP downto C_CHBUF_WB_BIT_BOT);
          DDRAddr_pioCplD   <= pioCplD_Qout(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT);
          BAR_pioCplD       <= pioCplD_Qout(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT);
          pioCplD_is_0Leng  <= pioCplD_Qout(C_CHBUF_0LENG_BIT);
        else
          pioCplD_Req_Min_Leng <= '0';
          pioCplD_Req_2DW_Leng <= '0';
          pioCplD_Qout_to_TLP  <= (others => '0');
          Regs_Addr_pioCplD    <= (others => '1');
          wbaddr_piocpld       <= (others => '1');
          DDRAddr_pioCplD      <= (others => '1');
          BAR_pioCplD          <= (others => '1');
          pioCplD_is_0Leng     <= '0';
        end if;
  
        if b1_Tx_Indicator(C_CHAN_INDEX_DMA_US) = '1' then
          usTlp_Qout_to_TLP                                                     <= (others => '0');  -- must be 1st argument
          -- 1st header HI
          usTlp_Qout_to_TLP(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT)         <= usTlp_Qout(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT);
          usTlp_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)       <= C_ALL_ZEROS(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT);
          usTlp_Qout_to_TLP(C_TLP_TC_BIT_TOP downto C_TLP_TC_BIT_BOT)           <= usTlp_Qout(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT);
          usTlp_Qout_to_TLP(C_TLP_ATTR_BIT_TOP downto C_TLP_ATTR_BIT_BOT)       <= usTlp_Qout(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT);
          usTlp_Qout_to_TLP(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)       <= usTlp_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
          -- 1st header LO
          usTlp_Qout_to_TLP(C_TLP_REQID_BIT_TOP downto C_TLP_REQID_BIT_BOT)     <= localID;
          usTlp_Qout_to_TLP(C_TLP_TAG_BIT_TOP downto C_TLP_TAG_BIT_BOT)         <= usTlp_Qout(C_CHBUF_TAG_BIT_TOP downto C_CHBUF_TAG_BIT_BOT);
          usTlp_Qout_to_TLP(C_TLP_LAST_BE_BIT_TOP downto C_TLP_LAST_BE_BIT_BOT) <= C_ALL_ONES(C_TLP_LAST_BE_BIT_TOP downto C_TLP_LAST_BE_BIT_BOT);
          usTlp_Qout_to_TLP(C_TLP_1ST_BE_BIT_TOP downto C_TLP_1ST_BE_BIT_BOT)   <= C_ALL_ONES(C_TLP_1ST_BE_BIT_TOP downto C_TLP_1ST_BE_BIT_BOT);
          -- 2nd header HI (Address)
  --            usTlp_Qout_to_TLP(2*C_DBUS_WIDTH-1 downto C_DBUS_WIDTH)    <= usTlp_Qout(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT);
          if usTlp_Qout(C_CHBUF_FMT_BIT_BOT) = '1' then  -- 4DW MWr
            usTlp_Qout_to_TLP(2*C_DBUS_WIDTH-1 downto C_DBUS_WIDTH+32) <= usTlp_Qout(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT+32);
          else
            usTlp_Qout_to_TLP(2*C_DBUS_WIDTH-1 downto C_DBUS_WIDTH+32) <= usTlp_Qout(C_CHBUF_HA_BIT_TOP-32 downto C_CHBUF_HA_BIT_BOT);
          end if;
          -- 2nd header LO (Address)
          usTlp_Qout_to_TLP(2*C_DBUS_WIDTH-1-32 downto C_DBUS_WIDTH) <= usTlp_Qout(C_CHBUF_HA_BIT_TOP-32 downto C_CHBUF_HA_BIT_BOT);
  
          --
          if usTlp_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
             = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG)
          then
            usTlp_Req_Min_Leng <= '1';
          else
            usTlp_Req_Min_Leng <= '0';
          end if;
          if usTlp_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
             = CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG)
          then
            usTlp_Req_2DW_Leng <= '1';
          else
            usTlp_Req_2DW_Leng <= '0';
          end if;
  
          -- Misc
          DDRAddr_usTlp <= usTlp_Qout(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT);
          WBAddr_usTlp  <= usTlp_Qout(C_CHBUF_WB_BIT_TOP downto C_CHBUF_WB_BIT_BOT);
          mAddr_usTlp   <= usTlp_Qout(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT);  -- !! C_CHBUF_MA_BIT_BOT);
          AInc_usTlp    <= usTlp_Qout(C_CHBUF_AINC_BIT);
          BAR_usTlp     <= usTlp_Qout(C_CHBUF_DMA_BAR_BIT_TOP downto C_CHBUF_DMA_BAR_BIT_BOT);
  
        else
          usTlp_Req_Min_Leng <= '0';
          usTlp_Req_2DW_Leng <= '0';
          usTlp_Qout_to_TLP  <= (others => '0');
          DDRAddr_usTlp      <= (others => '1');
          WBAddr_usTlp       <= (others => '1');
          mAddr_usTlp        <= (others => '1');
          AInc_usTlp         <= '1';
          BAR_usTlp          <= (others => '1');
        end if;
  
        if b1_Tx_Indicator(C_CHAN_INDEX_DMA_DS) = '1' then
          dsMRd_Qout_to_TLP                                                     <= (others => '0');  -- must be 1st argument
          -- 1st header HI
          dsMRd_Qout_to_TLP(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT)         <= dsMRd_Qout(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT);
          dsMRd_Qout_to_TLP(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)       <= C_ALL_ZEROS(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT);
          dsMRd_Qout_to_TLP(C_TLP_TC_BIT_TOP downto C_TLP_TC_BIT_BOT)           <= dsMRd_Qout(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT);
          dsMRd_Qout_to_TLP(C_TLP_ATTR_BIT_TOP downto C_TLP_ATTR_BIT_BOT)       <= dsMRd_Qout(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT);
          dsMRd_Qout_to_TLP(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)       <= dsMRd_Qout(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
          -- 1st header LO
          dsMRd_Qout_to_TLP(C_TLP_REQID_BIT_TOP downto C_TLP_REQID_BIT_BOT)     <= localID;
          dsMRd_Qout_to_TLP(C_TLP_TAG_BIT_TOP downto C_TLP_TAG_BIT_BOT)         <= dsMRd_Qout(C_CHBUF_TAG_BIT_TOP downto C_CHBUF_TAG_BIT_BOT);
          dsMRd_Qout_to_TLP(C_TLP_LAST_BE_BIT_TOP downto C_TLP_LAST_BE_BIT_BOT) <= C_ALL_ONES(C_TLP_LAST_BE_BIT_TOP downto C_TLP_LAST_BE_BIT_BOT);
          dsMRd_Qout_to_TLP(C_TLP_1ST_BE_BIT_TOP downto C_TLP_1ST_BE_BIT_BOT)   <= C_ALL_ONES(C_TLP_1ST_BE_BIT_TOP downto C_TLP_1ST_BE_BIT_BOT);
          -- 2nd header (Address)
          dsMRd_Qout_to_TLP(2*C_DBUS_WIDTH-1 downto C_DBUS_WIDTH)               <= dsMRd_Qout(C_CHBUF_HA_BIT_TOP downto C_CHBUF_HA_BIT_BOT);
  
        else
          dsMRd_Qout_to_TLP <= (others => '0');
        end if;
      end if;
    end if;
  end process;

-- OR-wired channel buffer outputs
  Trn_Qout_wire <= Irpt_Qout_to_TLP or pioCplD_Qout_to_TLP or dsMRd_Qout_to_TLP or usTlp_Qout_to_TLP;

-- ---------------------------------------------------
-- State Machine: Tx output control
--
  TxFSM_OutputControl :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if trn_tx_Reset_n = '0' then
        take_an_Arbitration <= '0';
        RdNumber            <= (others => '0');
        RdNumber_eq_One     <= '0';
        RdNumber_eq_Two     <= '0';
        StartAddr           <= (others => '0');
        Shift_1st_QWord     <= '0';
        is_CplD             <= '0';
        BAR_value           <= (others => '0');
        RdCmd_Req           <= '0';
        mbuf_reset_n        <= '0';
        mbuf_RE_ok          <= '0';
        s_axis_tx_tvalid_i  <= '0';
        trn_tsof_n_i        <= '1';
        s_axis_tx_tlast_i   <= '0';
        s_axis_tx_tdata_i   <= (others => '0');
        s_axis_tx_tkeep_i   <= (others => '1');
        TxTrn_State         <= St_TxIdle;
        Trn_Qout_reg        <= (others => '0');
      else
        case TxTrn_State is
  
          when St_TxIdle =>
            s_axis_tx_tvalid_i  <= '0';
            trn_tsof_n_i        <= '1';
            s_axis_tx_tlast_i   <= '0';
            s_axis_tx_tdata_i   <= (others => '0');
            s_axis_tx_tkeep_i   <= (others => '1');
            mbuf_RE_ok          <= '0';
            take_an_Arbitration <= '0';
            --ported from TRN to AXI, swap DWORDs
            Trn_Qout_reg        <= Trn_Qout_wire;
            RdNumber            <= Trn_Qout_wire (C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
            RdNumber_eq_One     <= pioCplD_Req_Min_Leng or usTlp_Req_Min_Leng;
            RdNumber_eq_Two     <= pioCplD_Req_2DW_Leng or usTlp_Req_2DW_Leng;
            RdCmd_Req           <= ChBuf_has_Payload;
            if pioCplD_is_0Leng = '1' then
              BAR_value       <= '0' & CONV_STD_LOGIC_VECTOR(CINT_REGS_SPACE_BAR, C_ENCODE_BAR_NUMBER-1);
              StartAddr       <= C_ALL_ONES(C_DBUS_WIDTH-1 downto 0);
              Shift_1st_QWord <= '1';
              is_CplD         <= '0';
            elsif BAR_pioCplD = CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
              BAR_value       <= '0' & BAR_pioCplD(C_ENCODE_BAR_NUMBER-2 downto 0);
              StartAddr       <= (C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_DDR_IAWIDTH) & DDRAddr_pioCplD);
              Shift_1st_QWord <= '1';
              is_CplD         <= '1';
            elsif BAR_pioCplD = CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
              BAR_value       <= BAR_pioCplD(C_ENCODE_BAR_NUMBER-1 downto 0);
              StartAddr       <= (C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_WB_AWIDTH) & wbaddr_piocpld);
              Shift_1st_QWord <= '1';
              is_CplD         <= '1';
            elsif BAR_usTlp = CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
              BAR_value       <= '0' & BAR_usTlp(C_ENCODE_BAR_NUMBER-2 downto 0);
              StartAddr       <= C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_DDR_IAWIDTH) & DDRAddr_usTlp;
              Shift_1st_QWord <= not usTlp_Qout_to_TLP(C_TLP_FMT_BIT_BOT);
              is_CplD         <= '0';
            elsif BAR_usTlp = CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) then
              BAR_value       <= BAR_usTlp(C_ENCODE_BAR_NUMBER-1 downto 0);
              StartAddr       <= C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_WB_AWIDTH) & WBAddr_usTlp;
              Shift_1st_QWord <= not usTlp_Qout_to_TLP(C_TLP_FMT_BIT_BOT);
              is_CplD         <= '0';
            else
              BAR_value <= '0' & BAR_pioCplD(C_ENCODE_BAR_NUMBER-2 downto 0);
              StartAddr <= (C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_EP_AWIDTH) & Regs_Addr_pioCplD);
              Shift_1st_QWord <= '1';
              is_CplD         <= '0';
            end if;
  
            if ChBuf_has_Payload = '1' then
              TxTrn_State <= St_d_CmdReq;
              mbuf_reset_n <= '1';
            elsif ChBuf_No_Payload = '1' then
              TxTrn_State <= St_nd_Prepare;
              mbuf_reset_n <= '1';
            else
              TxTrn_State <= St_TxIdle;
              mbuf_reset_n <= mbuf_Empty;  -- '1';
            end if;
            --- --- --- --- --- --- --- --- --- --- --- --- ---
            --- --- --- --- --- --- --- --- --- --- --- --- ---
          when St_nd_Prepare =>
            s_axis_tx_tlast_i <= '0';
            if s_axis_tx_tready_i = '1' then
              TxTrn_State        <= St_nd_Header2;  -- St_nd_Header1
              s_axis_tx_tvalid_i <= '1';
              trn_tsof_n_i       <= '0';
              s_axis_tx_tdata_i  <= Trn_Qout_reg (C_DBUS_WIDTH-1 downto 0);
            else
              TxTrn_State        <= St_nd_Prepare;
              s_axis_tx_tvalid_i <= '0';
              trn_tsof_n_i       <= '1';
              s_axis_tx_tdata_i  <= (others => '0');
            end if;
  
          when St_nd_Header2 =>
            s_axis_tx_tvalid_i <= '1';
            if s_axis_tx_tready_i = '0' then
              TxTrn_State         <= St_nd_Header2;
              take_an_Arbitration <= '0';
              trn_tsof_n_i        <= trn_tsof_n_i;
              s_axis_tx_tlast_i   <= '0';
              s_axis_tx_tdata_i   <= s_axis_tx_tdata_i;  -- Trn_Qout_reg (C_DBUS_WIDTH-1 downto 0);
            else                          -- 3DW header
              TxTrn_State         <= St_nd_HeaderLast;
              take_an_Arbitration <= '1';
              trn_tsof_n_i        <= '1';
              s_axis_tx_tlast_i   <= '1';
              if Trn_Qout_reg (C_TLP_FMT_BIT_BOT) = '1' then  -- 4DW header
                s_axis_tx_tkeep_i <= X"FF";
                s_axis_tx_tdata_i <= Trn_Qout_reg(C_DBUS_WIDTH+32-1 downto C_DBUS_WIDTH) &
                                      Trn_Qout_reg(C_DBUS_WIDTH*2-1 downto C_DBUS_WIDTH+32);
              else
                s_axis_tx_tkeep_i <= X"0F";
                s_axis_tx_tdata_i <= X"00000000" & Trn_Qout_reg (C_DBUS_WIDTH-1+32 downto C_DBUS_WIDTH);
              end if;
            end if;
  
          when St_nd_HeaderLast =>
            trn_tsof_n_i        <= '1';
            take_an_Arbitration <= '0';
            if s_axis_tx_tready_i = '0' then
              TxTrn_State        <= St_nd_HeaderLast;
              s_axis_tx_tvalid_i <= '1';
              s_axis_tx_tlast_i  <= '1';
              s_axis_tx_tdata_i  <= s_axis_tx_tdata_i;
              s_axis_tx_tkeep_i  <= s_axis_tx_tkeep_i;
            else
              TxTrn_State        <= St_nd_Arbitration;  -- St_TxIdle;
              s_axis_tx_tvalid_i <= '0';
              s_axis_tx_tlast_i  <= '0';
              s_axis_tx_tdata_i  <= s_axis_tx_tdata_i;
              s_axis_tx_tkeep_i  <= s_axis_tx_tkeep_i;
            end if;
  
          when St_nd_Arbitration =>
            trn_tsof_n_i       <= '1';
            TxTrn_State        <= St_TxIdle;
            s_axis_tx_tvalid_i <= '0';
            s_axis_tx_tlast_i  <= '0';
            s_axis_tx_tdata_i  <= s_axis_tx_tdata_i;
            s_axis_tx_tkeep_i  <= (others => '1');
            --- --- --- --- --- --- --- --- --- --- --- --- ---
            --- --- --- --- --- --- --- --- --- --- --- --- ---
          when St_d_CmdReq =>
            if RdCmd_Ack = '1' then
              RdCmd_Req   <= '0';
              TxTrn_State <= St_d_CmdAck;
            else
              RdCmd_Req   <= '1';
              TxTrn_State <= St_d_CmdReq;
            end if;
  
          when St_d_CmdAck =>
            s_axis_tx_tlast_i <= '0';
            if mbuf_Empty = '0' and s_axis_tx_tready_i = '1' then
              s_axis_tx_tvalid_i <= '0';
              trn_tsof_n_i       <= '1';
              s_axis_tx_tdata_i  <= (others => '0');
              mbuf_RE_ok         <= '1';
              TxTrn_State        <= St_d_Header0;  -- St_d_Header1
            else
              s_axis_tx_tvalid_i <= '0';
              trn_tsof_n_i       <= '1';
              s_axis_tx_tdata_i  <= (others => '0');
              mbuf_RE_ok         <= '0';
              TxTrn_State        <= St_d_CmdAck;
            end if;
  
          when St_d_Header0 =>
            if s_axis_tx_tready_i = '1' then
              take_an_Arbitration <= '1';
              s_axis_tx_tvalid_i  <= '1';
              trn_tsof_n_i        <= '0';
              s_axis_tx_tlast_i   <= '0';
              s_axis_tx_tdata_i   <= Trn_Qout_reg (C_DBUS_WIDTH-1 downto 0);
              mbuf_RE_ok          <= not Trn_Qout_reg (C_TLP_FMT_BIT_BOT);  -- '1'; -- 4DW
              TxTrn_State         <= St_d_Header2;
            else
              take_an_Arbitration <= '0';
              s_axis_tx_tvalid_i  <= '0';
              trn_tsof_n_i        <= '1';
              s_axis_tx_tlast_i   <= '0';
              s_axis_tx_tdata_i   <= s_axis_tx_tdata_i;
              mbuf_RE_ok          <= '0';
              TxTrn_State         <= St_d_Header0;
            end if;
  
          when St_d_Header2 =>
            s_axis_tx_tvalid_i  <= '1';
            s_axis_tx_tkeep_i   <= (others => '1');
            take_an_Arbitration <= '0';
            if s_axis_tx_tready_i = '0' then
              TxTrn_State       <= St_d_Header2;
              s_axis_tx_tdata_i <= Trn_Qout_reg (C_DBUS_WIDTH-1 downto 0);
              trn_tsof_n_i      <= '0';
              s_axis_tx_tlast_i <= '0';
              mbuf_RE_ok        <= not Trn_Qout_reg (C_TLP_FMT_BIT_BOT);
            elsif Trn_Qout_reg (C_TLP_FMT_BIT_BOT) = '1' then  -- 4DW header
              TxTrn_State       <= St_d_1st_Data;  -- St_d_HeaderPlus;
              s_axis_tx_tdata_i <= Trn_Qout_reg(C_DBUS_WIDTH+32-1 downto C_DBUS_WIDTH) &
                                    Trn_Qout_reg(C_DBUS_WIDTH*2-1 downto C_DBUS_WIDTH+32);
              trn_tsof_n_i      <= '1';
              s_axis_tx_tlast_i <= '0';
              mbuf_RE_ok        <= '1';
            else                          -- 3DW header
              s_axis_tx_tdata_i <= mbuf_Qout(C_DBUS_WIDTH-1 downto 32)
                                               & Trn_Qout_reg (C_DBUS_WIDTH+32-1 downto C_DBUS_WIDTH);
              trn_tsof_n_i      <= '1';
              s_axis_tx_tlast_i <= not(mbuf_qout(C_TXMEM_TLAST_BIT));
              mbuf_RE_ok        <= s_axis_tx_tvalid_i and mbuf_qout(C_TXMEM_TLAST_BIT);
              if mbuf_qout(C_TXMEM_TLAST_BIT) = '0' then
                TxTrn_State <= St_d_Tail_chk;
              else
                TxTrn_State <= St_d_1st_Data;
              end if;
            end if;
  
          when St_d_1st_Data =>
            mbuf_RE_ok          <= s_axis_tx_tvalid_i and mbuf_qout(C_TXMEM_TLAST_BIT);
            take_an_Arbitration <= '0';
            if s_axis_tx_tready_i = '0' then
              TxTrn_State        <= St_d_1st_Data;
              s_axis_tx_tlast_i  <= '0';
              s_axis_tx_tdata_i  <= s_axis_tx_tdata_i;
              s_axis_tx_tvalid_i <= '1';
            elsif mbuf_qout(C_TXMEM_TLAST_BIT) = '0' then
              TxTrn_State       <= St_d_Tail_chk;
              s_axis_tx_tlast_i <= '1';
              s_axis_tx_tkeep_i <= X"0" & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT)
                                           & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT);
              s_axis_tx_tdata_i  <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
              s_axis_tx_tvalid_i <= mbuf_Qvalid;  -- '0';
            elsif mbuf_Qvalid = '0' then
              TxTrn_State        <= St_d_Payload_used;
              s_axis_tx_tlast_i  <= '0';
              s_axis_tx_tdata_i  <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
              s_axis_tx_tvalid_i <= '0';
            else
              TxTrn_State        <= St_d_Payload;
              s_axis_tx_tlast_i  <= '0';
              s_axis_tx_tdata_i  <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
              s_axis_tx_tvalid_i <= '1';
            end if;
  
          when St_d_Payload =>
            mbuf_RE_ok          <= '1';
            take_an_Arbitration <= '0';
            if s_axis_tx_tready_i = '0' then
              s_axis_tx_tdata_i  <= s_axis_tx_tdata_i;
              s_axis_tx_tlast_i  <= s_axis_tx_tlast_i;
              s_axis_tx_tkeep_i  <= s_axis_tx_tkeep_i;
              s_axis_tx_tvalid_i <= '1';
              if mbuf_qout(C_TXMEM_TLAST_BIT) = '0' then
                TxTrn_State <= St_d_Tail;
              elsif mbuf_Qvalid = '1' then
                TxTrn_State <= St_d_Payload;
              else
                TxTrn_State <= St_d_Payload_used;
              end if;
            else
              s_axis_tx_tdata_i  <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
              s_axis_tx_tlast_i  <= not(mbuf_qout(C_TXMEM_TLAST_BIT));
              s_axis_tx_tvalid_i <= not(mbuf_qout(C_TXMEM_TLAST_BIT)) or mbuf_Qvalid;
              if mbuf_qout(C_TXMEM_TLAST_BIT) = '0' then
                TxTrn_State       <= St_d_Tail_chk;
                s_axis_tx_tkeep_i <= X"0" & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT)
                                             & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT);
              elsif mbuf_Qvalid = '1' then
                s_axis_tx_tkeep_i <= (others => '1');
                TxTrn_State       <= St_d_Payload;
              else
                s_axis_tx_tkeep_i <= (others => '1');
                TxTrn_State       <= St_d_Payload_used;
              end if;
            end if;
  
          when St_d_Payload_used =>
            mbuf_RE_ok          <= '1';
            take_an_Arbitration <= '0';
            if s_axis_tx_tvalid_i = '1' then
              s_axis_tx_tdata_i  <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
              s_axis_tx_tvalid_i <= mbuf_Qvalid and s_axis_tx_tready_i;
              if mbuf_qout(C_TXMEM_TLAST_BIT) = '0' then
                s_axis_tx_tlast_i <= '1';
                s_axis_tx_tkeep_i <= X"0" & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT)
                                             & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT);
              else
                s_axis_tx_tlast_i <= '0';
                s_axis_tx_tkeep_i <= (others => '1');
              end if;
              if mbuf_Qvalid = '1' then
                TxTrn_State <= St_d_Payload;
              else
                TxTrn_State <= St_d_Payload_used;
              end if;
            elsif mbuf_Qvalid = '1' then
              s_axis_tx_tdata_i  <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
              s_axis_tx_tvalid_i <= '1';
              if mbuf_qout(C_TXMEM_TLAST_BIT) = '0' then
                s_axis_tx_tlast_i <= '1';
                s_axis_tx_tkeep_i <= X"0" & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT)
                                             & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT);
              else
                s_axis_tx_tlast_i <= '0';
                s_axis_tx_tkeep_i <= (others => '1');
              end if;
              if mbuf_qout(C_TXMEM_TLAST_BIT) = '0' then
                TxTrn_State <= St_d_Tail_chk;
              else
                TxTrn_State <= St_d_Payload;
              end if;
            else
              TxTrn_State        <= St_d_Payload_used;
              s_axis_tx_tdata_i  <= s_axis_tx_tdata_i;
              s_axis_tx_tlast_i  <= s_axis_tx_tlast_i;
              s_axis_tx_tkeep_i  <= s_axis_tx_tkeep_i;
              s_axis_tx_tvalid_i <= '0';
            end if;
  
          when St_d_Tail =>
            take_an_Arbitration <= '0';
            mbuf_RE_ok          <= '0';
            s_axis_tx_tvalid_i  <= '1';
            if s_axis_tx_tready_i = '0' then
              TxTrn_State       <= St_d_Tail;
              s_axis_tx_tlast_i <= s_axis_tx_tlast_i;
              s_axis_tx_tkeep_i <= s_axis_tx_tkeep_i;
              s_axis_tx_tdata_i <= s_axis_tx_tdata_i;
            else
              TxTrn_State       <= St_d_Tail_chk;
              s_axis_tx_tlast_i <= '1';
              s_axis_tx_tkeep_i <= X"0" & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT)
                                           & mbuf_qout(C_TXMEM_KEEP_BIT) & mbuf_qout(C_TXMEM_KEEP_BIT);
              s_axis_tx_tdata_i <= mbuf_Qout(C_DBUS_WIDTH-1 downto 0);
            end if;
  
          when St_d_Tail_chk =>
            take_an_Arbitration <= '0';
            mbuf_RE_ok          <= '0';
            if s_axis_tx_tready_i = '0' then
              s_axis_tx_tvalid_i <= '1';
              s_axis_tx_tlast_i  <= '1';
              s_axis_tx_tkeep_i  <= s_axis_tx_tkeep_i;
              s_axis_tx_tdata_i  <= s_axis_tx_tdata_i;
              TxTrn_State        <= St_d_Tail_chk;
            else
              s_axis_tx_tvalid_i <= '0';
              s_axis_tx_tlast_i  <= '0';
              s_axis_tx_tdata_i  <= (others => '0');
              s_axis_tx_tkeep_i  <= (others => '1');
              TxTrn_State        <= St_TxIdle;
            end if;
  
          when others =>
            take_an_Arbitration <= '0';
            RdNumber            <= (others => '0');
            RdNumber_eq_One     <= '0';
            RdNumber_eq_Two     <= '0';
            StartAddr           <= (others => '0');
            BAR_value           <= (others => '0');
            RdCmd_Req           <= '0';
            mbuf_reset_n        <= '1';
            mbuf_RE_ok          <= '0';
            s_axis_tx_tvalid_i  <= '0';
            trn_tsof_n_i        <= '1';
            s_axis_tx_tlast_i   <= '0';
            s_axis_tx_tdata_i   <= (others => '0');
            s_axis_tx_tkeep_i   <= (others => '1');
            TxTrn_State         <= St_TxIdle;
  
        end case;
      end if;
    end if;
  end process;

---------------------------------------------------------------------------------
-- Synchronous Accumulation: us_DMA_Bytes
--
  Synch_Acc_us_DMA_Bytes :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      us_DMA_Bytes_i <= '0' & s_axis_tx_tdata_i(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) & "00";
      if s_axis_tx_tdata_i(C_TLP_FMT_BIT_TOP) = '1'
        and s_axis_tx_tdata_i(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT)
         = C_ALL_ZEROS(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) then
        us_DMA_Bytes_Add_i <= not trn_tsof_n_i
                              and s_axis_tx_tvalid_i
                              and s_axis_tx_tready_i;
      else
        us_DMA_Bytes_Add_i <= '0';
      end if;
    end if;
  end process;

end architecture Behavioral;
