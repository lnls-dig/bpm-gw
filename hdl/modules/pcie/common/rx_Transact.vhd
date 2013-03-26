----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name:    rx_Transact - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision 1.20 - Memory space repartitioned.   13.07.2007
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


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rx_Transact is
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
    m_axis_rx_tready   : out std_logic;
    rx_np_ok           : out std_logic;
    rx_np_req          : out std_logic;
    m_axis_rx_tbar_hit : in  std_logic_vector(C_BAR_NUMBER-1 downto 0);
--      trn_rfc_ph_av             : IN  std_logic_vector(7 downto 0);
--      trn_rfc_pd_av             : IN  std_logic_vector(11 downto 0);
--      trn_rfc_nph_av            : IN  std_logic_vector(7 downto 0);
--      trn_rfc_npd_av            : IN  std_logic_vector(11 downto 0);
--      trn_rfc_cplh_av           : IN  std_logic_vector(7 downto 0);
--      trn_rfc_cpld_av           : IN  std_logic_vector(11 downto 0);

    -- PIO MRd Channel
    pioCplD_Req  : out std_logic;
    pioCplD_RE   : in  std_logic;
    pioCplD_Qout : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
    pio_FC_stop  : in  std_logic;

    -- downstream MRd Channel
    dsMRd_Req  : out std_logic;
    dsMRd_RE   : in  std_logic;
    dsMRd_Qout : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

    -- upstream MWr/MRd Channel
    usTlp_Req   : out std_logic;
    usTlp_RE    : in  std_logic;
    usTlp_Qout  : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
    us_FC_stop  : in  std_logic;
    us_Last_sof : in  std_logic;
    us_Last_eof : in  std_logic;

    -- Irpt Channel
    Irpt_Req  : out std_logic;
    Irpt_RE   : in  std_logic;
    Irpt_Qout : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

    -- Interrupt Interface
    cfg_interrupt           : out std_logic;
    cfg_interrupt_rdy       : in  std_logic;
    cfg_interrupt_mmenable  : in  std_logic_vector(2 downto 0);
    cfg_interrupt_msienable : in  std_logic;
    cfg_interrupt_di        : out std_logic_vector(7 downto 0);
    cfg_interrupt_do        : in  std_logic_vector(7 downto 0);
    cfg_interrupt_assert    : out std_logic;

    -- Downstream DMA transferred bytes count up
    ds_DMA_Bytes_Add : out std_logic;
    ds_DMA_Bytes     : out std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

    -- --------------------------
    -- Registers
    DMA_ds_PA         : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_ds_HA         : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_ds_BDA        : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_ds_Length     : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_ds_Control    : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    dsDMA_BDA_eq_Null : in  std_logic;
    DMA_ds_Status     : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_ds_Done       : out std_logic;
    DMA_ds_Busy       : out std_logic;
    DMA_ds_Tout       : out std_logic;

    -- Calculation in advance, for better timing
    dsHA_is_64b  : in std_logic;
    dsBDA_is_64b : in std_logic;

    -- Calculation in advance, for better timing
    dsLeng_Hi19b_True : in std_logic;
    dsLeng_Lo7b_True  : in std_logic;

    --
    dsDMA_Start       : in  std_logic;
    dsDMA_Stop        : in  std_logic;
    dsDMA_Start2      : in  std_logic;
    dsDMA_Stop2       : in  std_logic;
    dsDMA_Channel_Rst : in  std_logic;
    dsDMA_Cmd_Ack     : out std_logic;

    --
    DMA_us_PA         : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_us_HA         : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_us_BDA        : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_us_Length     : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_us_Control    : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    usDMA_BDA_eq_Null : in  std_logic;
    us_MWr_Param_Vec  : in  std_logic_vector(6-1 downto 0);
    DMA_us_Status     : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DMA_us_Done       : out std_logic;
    DMA_us_Busy       : out std_logic;
    DMA_us_Tout       : out std_logic;

    -- Calculation in advance, for better timing
    usHA_is_64b  : in std_logic;
    usBDA_is_64b : in std_logic;

    -- Calculation in advance, for better timing
    usLeng_Hi19b_True : in std_logic;
    usLeng_Lo7b_True  : in std_logic;

    --
    usDMA_Start       : in  std_logic;
    usDMA_Stop        : in  std_logic;
    usDMA_Start2      : in  std_logic;
    usDMA_Stop2       : in  std_logic;
    usDMA_Channel_Rst : in  std_logic;
    usDMA_Cmd_Ack     : out std_logic;

    MRd_Channel_Rst : in std_logic;

    -- to Interrupt module
    Sys_IRQ : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- Event Buffer write port
    wb_FIFO_we   : out std_logic;
    wb_FIFO_wsof : out std_logic;
    wb_FIFO_weof : out std_logic;
    wb_FIFO_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    wb_FIFO_data_count : in  std_logic_vector(C_FIFO_DC_WIDTH downto 0);
    wb_FIFO_Empty      : in  std_logic;
    wb_FIFO_Reading    : in  std_logic;
    pio_reading_status : out std_logic;

    Link_Buf_full : in std_logic;

    -- Registers Write Port
    Regs_WrEn0   : out std_logic;
    Regs_WrMask0 : out std_logic_vector(2-1 downto 0);
    Regs_WrAddr0 : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
    Regs_WrDin0  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    Regs_WrEn1   : out std_logic;
    Regs_WrMask1 : out std_logic_vector(2-1 downto 0);
    Regs_WrAddr1 : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
    Regs_WrDin1  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- DDR write port
    DDR_wr_sof_A   : out std_logic;
    DDR_wr_eof_A   : out std_logic;
    DDR_wr_v_A     : out std_logic;
    DDR_wr_FA_A    : out std_logic;
    DDR_wr_Shift_A : out std_logic;
    DDR_wr_Mask_A  : out std_logic_vector(2-1 downto 0);
    DDR_wr_din_A   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    DDR_wr_sof_B   : out std_logic;
    DDR_wr_eof_B   : out std_logic;
    DDR_wr_v_B     : out std_logic;
    DDR_wr_FA_B    : out std_logic;
    DDR_wr_Shift_B : out std_logic;
    DDR_wr_Mask_B  : out std_logic_vector(2-1 downto 0);
    DDR_wr_din_B   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    DDR_wr_full : in std_logic;

    -- Data generator table write
    tab_we : out std_logic_vector(2-1 downto 0);
    tab_wa : out std_logic_vector(12-1 downto 0);
    tab_wd : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- Interrupt generator signals
    IG_Reset        : in  std_logic;
    IG_Host_Clear   : in  std_logic;
    IG_Latency      : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    IG_Num_Assert   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    IG_Num_Deassert : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    IG_Asserting    : out std_logic;

    -- Additional
    cfg_dcommand : in std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);
    localID      : in std_logic_vector(C_ID_WIDTH-1 downto 0)
    );

end entity rx_Transact;


architecture Behavioral of rx_Transact is

  signal wb_FIFO_we_i   : std_logic;
  signal wb_FIFO_wsof_i : std_logic;
  signal wb_FIFO_weof_i : std_logic;
  signal wb_FIFO_din_i  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  ------------------------------------------------------------------
  --  Rx input delay
  --  some calculation in advance, to achieve better timing
  --
  component
    RxIn_Delay
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
      Link_Buf_full      : in  std_logic;

      -- Delayed
      m_axis_rx_tlast_dly    : out std_logic;
      m_axis_rx_tdata_dly    : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      m_axis_rx_tkeep_dly    : out std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      m_axis_rx_terrfwd_dly  : out std_logic;
      m_axis_rx_tvalid_dly   : out std_logic;
      m_axis_rx_tready_dly   : out std_logic;
      m_axis_rx_tbar_hit_dly : out std_logic_vector(C_BAR_NUMBER-1 downto 0);

      -- TLP resolution
      IORd_Type : out std_logic;
      IOWr_Type : out std_logic;
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
  end component;

  -- One clock delayed
  signal m_axis_rx_tlast_dly    : std_logic;
  signal m_axis_rx_tdata_dly    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal m_axis_rx_tkeep_dly    : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal m_axis_rx_terrfwd_dly  : std_logic;
  signal m_axis_rx_tvalid_dly   : std_logic;
  signal m_axis_rx_tready_dly   : std_logic;
  signal m_axis_rx_tbar_hit_dly : std_logic_vector(C_BAR_NUMBER-1 downto 0);

  -- TLP types
  signal IORd_Type : std_logic;
  signal IOWr_Type : std_logic;
  signal MRd_Type  : std_logic_vector(3 downto 0);
  signal MWr_Type  : std_logic_vector(1 downto 0);
  signal CplD_Type : std_logic_vector(3 downto 0);

  signal Tlp_straddles_4KB : std_logic;

  -- To Cpl/D channel
  signal Tlp_has_4KB       : std_logic;
  signal Tlp_has_1DW       : std_logic;
  signal CplD_is_the_Last  : std_logic;
  signal CplD_on_Pool      : std_logic;
  signal CplD_on_EB        : std_logic;
  signal Req_ID_Match      : std_logic;
  signal usDex_Tag_Matched : std_logic;
  signal dsDex_Tag_Matched : std_logic;
  signal CplD_Tag          : std_logic_vector(C_TAG_WIDTH-1 downto 0);


  ------------------------------------------------------------------
  --  MRd TLP processing
  --   contains channel buffer for PIO Completions
  --
  component
    rx_MRd_Transact
    port(
      m_axis_rx_tlast    : in  std_logic;
      m_axis_rx_tdata    : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      m_axis_rx_tkeep    : in  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
--              m_axis_rx_tready            : OUT std_logic;
      rx_np_ok           : out std_logic;  -----------------
      rx_np_req          : out std_logic;
      m_axis_rx_terrfwd  : in  std_logic;
      m_axis_rx_tvalid   : in  std_logic;
      m_axis_rx_tbar_hit : in  std_logic_vector(C_BAR_NUMBER-1 downto 0);

      IORd_Type         : in std_logic;
      MRd_Type          : in std_logic_vector(3 downto 0);
      Tlp_straddles_4KB : in std_logic;

      pioCplD_RE         : in  std_logic;
      pioCplD_Req        : out std_logic;
      pioCplD_Qout       : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      FIFO_Empty         : in  std_logic;
      FIFO_Reading       : in  std_logic;
      pio_FC_stop        : in  std_logic;
      pio_reading_status : out std_logic;

      Channel_Rst : in std_logic;

      user_clk    : in std_logic;
      user_reset  : in std_logic;
      user_lnk_up : in std_logic
      );
  end component;

  ------------------------------------------------------------------
  --  MWr TLP processing
  --
  component
    rx_MWr_Transact
    port(
      --
      m_axis_rx_tlast    : in std_logic;
      m_axis_rx_tdata    : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      m_axis_rx_tkeep    : in std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      m_axis_rx_tready   : in std_logic;  -- !!
      m_axis_rx_terrfwd  : in std_logic;
      m_axis_rx_tvalid   : in std_logic;
      m_axis_rx_tbar_hit : in std_logic_vector(C_BAR_NUMBER-1 downto 0);

      IOWr_Type         : in std_logic;
      MWr_Type          : in std_logic_vector(1 downto 0);
      Tlp_straddles_4KB : in std_logic;
      Tlp_has_4KB       : in std_logic;


      -- Event Buffer write port
      wb_FIFO_we   : out std_logic;
      wb_FIFO_wsof : out std_logic;
      wb_FIFO_weof : out std_logic;
      wb_FIFO_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Registers Write Port
      Regs_WrEn   : out std_logic;
      Regs_WrMask : out std_logic_vector(2-1 downto 0);
      Regs_WrAddr : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- DDR write port
      DDR_wr_sof   : out std_logic;
      DDR_wr_eof   : out std_logic;
      DDR_wr_v     : out std_logic;
      DDR_wr_FA    : out std_logic;
      DDR_wr_Shift : out std_logic;
      DDR_wr_Mask  : out std_logic_vector(2-1 downto 0);
      DDR_wr_din   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full  : in  std_logic;

      -- Data generator table write
      tab_we : out std_logic_vector(2-1 downto 0);
      tab_wa : out std_logic_vector(12-1 downto 0);
      tab_wd : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Common
      user_clk    : in std_logic;
      user_reset  : in std_logic;
      user_lnk_up : in std_logic

      );
  end component;

  signal wb_FIFO_we_MWr   : std_logic;
  signal wb_FIFO_wsof_MWr : std_logic;
  signal wb_FIFO_weof_MWr : std_logic;
  signal wb_FIFO_din_MWr  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);


  ------------------------------------------------------------------
  --  Cpl/D TLP processing
  --
  component
    rx_CplD_Transact
    port(
      m_axis_rx_tlast    : in std_logic;
      m_axis_rx_tdata    : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      m_axis_rx_tkeep    : in std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      m_axis_rx_tready   : in std_logic;
      m_axis_rx_terrfwd  : in std_logic;
      m_axis_rx_tvalid   : in std_logic;
      m_axis_rx_tbar_hit : in std_logic_vector(C_BAR_NUMBER-1 downto 0);

      CplD_Type : in std_logic_vector(3 downto 0);

      Req_ID_Match      : in std_logic;
      usDex_Tag_Matched : in std_logic;
      dsDex_Tag_Matched : in std_logic;

      Tlp_has_4KB      : in  std_logic;
      Tlp_has_1DW      : in  std_logic;
      CplD_is_the_Last : in  std_logic;
      CplD_on_Pool     : in  std_logic;
      CplD_on_EB       : in  std_logic;
      CplD_Tag         : in  std_logic_vector(C_TAG_WIDTH-1 downto 0);
      FC_pop           : out std_logic;

      -- Downstream DMA transferred bytes count up
      ds_DMA_Bytes_Add : out std_logic;
      ds_DMA_Bytes     : out std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      -- for descriptor of the downstream DMA
      dsDMA_Dex_Tag : out std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- Downstream Handshake Signals with ds Channel for Busy/Done
      Tag_Map_Clear : out std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);

      -- Downstream tRAM port A write request
      tRAM_weB   : in std_logic;
      tRAM_addrB : in std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
      tRAM_dinB  : in std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);

      -- for descriptor of the upstream DMA
      usDMA_dex_Tag : out std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- Event Buffer write port
      wb_FIFO_we   : out std_logic;
      wb_FIFO_wsof : out std_logic;
      wb_FIFO_weof : out std_logic;
      wb_FIFO_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Registers Write Port
      Regs_WrEn   : out std_logic;
      Regs_WrMask : out std_logic_vector(2-1 downto 0);
      Regs_WrAddr : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- DDR write port
      DDR_wr_sof   : out std_logic;
      DDR_wr_eof   : out std_logic;
      DDR_wr_v     : out std_logic;
      DDR_wr_FA    : out std_logic;
      DDR_wr_Shift : out std_logic;
      DDR_wr_Mask  : out std_logic_vector(2-1 downto 0);
      DDR_wr_din   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_wr_full  : in  std_logic;

      -- Common signals
      user_clk    : in std_logic;
      user_reset  : in std_logic;
      user_lnk_up : in std_logic
      );
  end component;

  signal wb_FIFO_we_CplD   : std_logic;
  signal wb_FIFO_wsof_CplD : std_logic;
  signal wb_FIFO_weof_CplD : std_logic;
  signal wb_FIFO_din_CplD  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal usDMA_dex_Tag : std_logic_vector(C_TAG_WIDTH-1 downto 0);
  signal dsDMA_dex_Tag : std_logic_vector(C_TAG_WIDTH-1 downto 0);

  signal Tag_Map_Clear : std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);
  signal FC_pop        : std_logic;

  ------------------------------------------------------------------
  --  Interrupts generation
  --
  component
    Interrupts
    port(
      Sys_IRQ : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Interrupt generator signals
      IG_Reset        : in  std_logic;
      IG_Host_Clear   : in  std_logic;
      IG_Latency      : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Num_Assert   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Num_Deassert : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Asserting    : out std_logic;

      -- cfg interface
      cfg_interrupt           : out std_logic;
      cfg_interrupt_rdy       : in  std_logic;
      cfg_interrupt_mmenable  : in  std_logic_vector(2 downto 0);
      cfg_interrupt_msienable : in  std_logic;
      cfg_interrupt_di        : out std_logic_vector(7 downto 0);
      cfg_interrupt_do        : in  std_logic_vector(7 downto 0);
      cfg_interrupt_assert    : out std_logic;

      -- Irpt Channel
      Irpt_Req  : out std_logic;
      Irpt_RE   : in  std_logic;
      Irpt_Qout : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      user_clk   : in std_logic;
      user_reset : in std_logic
      );
  end component;

  ------------------------------------------------------------------
  --  Upstream DMA Channel
  --   contains channel buffer for upstream DMA
  --
  component
    usDMA_Transact
    port(

      -- command buffer
      usTlp_Req  : out std_logic;
      usTlp_RE   : in  std_logic;
      usTlp_Qout : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      FIFO_Data_Count : in std_logic_vector(C_FIFO_DC_WIDTH downto 0);
      FIFO_Reading    : in std_logic;

      -- Upstream DMA Control Signals from MWr Channel
      usDMA_Start       : in std_logic;
      usDMA_Stop        : in std_logic;
      usDMA_Channel_Rst : in std_logic;
      us_FC_stop        : in std_logic;
      us_Last_sof       : in std_logic;
      us_Last_eof       : in std_logic;

      --- Upstream registers from CplD channel
      DMA_us_PA         : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_HA         : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_BDA        : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Length     : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Control    : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      usDMA_BDA_eq_Null : in std_logic;
      us_MWr_Param_Vec  : in std_logic_vector(6-1 downto 0);

      -- Calculation in advance, for better timing
      usHA_is_64b  : in std_logic;
      usBDA_is_64b : in std_logic;

      -- Calculation in advance, for better timing
      usLeng_Hi19b_True : in std_logic;
      usLeng_Lo7b_True  : in std_logic;

      --- Upstream commands from CplD channel
      usDMA_Start2 : in std_logic;
      usDMA_Stop2  : in std_logic;

      -- DMA Acknowledge to the start command
      DMA_Cmd_Ack : out std_logic;

      --- Tag for descriptor
      usDMA_dex_Tag : in std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- To Interrupt module
      DMA_Done    : out std_logic;
      DMA_TimeOut : out std_logic;
      DMA_Busy    : out std_logic;

      -- To Tx channel
      DMA_us_Status : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Additional
      cfg_dcommand : in std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);

      -- common
      user_clk : in std_logic
      );
  end component;

  ------------------------------------------------------------------
  --  Downstream DMA Channel
  --   contains channel buffer for downstream DMA
  --
  component
    dsDMA_Transact
    port(
      -- command buffer
      MRd_dsp_RE   : in  std_logic;
      MRd_dsp_Req  : out std_logic;
      MRd_dsp_Qout : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- Downstream tRAM port A write request, to CplD channel
      tRAM_weB   : out std_logic;
      tRAM_addrB : out std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
      tRAM_dinB  : out std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);

      -- Downstream Registers from MWr Channel
      DMA_ds_PA         : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_HA         : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_BDA        : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Length     : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Control    : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      dsDMA_BDA_eq_Null : in std_logic;

      -- Calculation in advance, for better timing
      dsHA_is_64b  : in std_logic;
      dsBDA_is_64b : in std_logic;

      -- Calculation in advance, for better timing
      dsLeng_Hi19b_True : in std_logic;
      dsLeng_Lo7b_True  : in std_logic;

      -- Downstream Control Signals from MWr Channel
      dsDMA_Start : in std_logic;
      dsDMA_Stop  : in std_logic;

      -- DMA Acknowledge to the start command
      DMA_Cmd_Ack : out std_logic;

      dsDMA_Channel_Rst : in std_logic;

      -- Downstream Control Signals from CplD Channel, out of consecutive dex
      dsDMA_Start2 : in std_logic;
      dsDMA_Stop2  : in std_logic;

      -- Downstream Handshake Signals with CplD Channel for Busy/Done
      Tag_Map_Clear : in std_logic_vector(C_TAG_MAP_WIDTH-1 downto 0);
      FC_pop        : in std_logic;


      -- Tag for descriptor
      dsDMA_dex_Tag : in std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- To Interrupt module
      DMA_Done    : out std_logic;
      DMA_TimeOut : out std_logic;
      DMA_Busy    : out std_logic;

      -- To Cpl/D channel
      DMA_ds_Status : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Additional
      cfg_dcommand : in std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);

      -- common
      user_clk : in std_logic
      );
  end component;

  -- tag RAM port A write request
  signal tRAM_weB   : std_logic;
  signal tRAM_addrB : std_logic_vector(C_TAGRAM_AWIDTH-1 downto 0);
  signal tRAM_dinB  : std_logic_vector(C_TAGRAM_DWIDTH-1 downto 0);


begin

  wb_FIFO_we   <= wb_FIFO_we_i;
  wb_FIFO_wsof <= wb_FIFO_wsof_i;
  wb_FIFO_weof <= wb_FIFO_weof_i;
  wb_FIFO_din  <= wb_FIFO_din_i;


  wb_FIFO_we_i   <= wb_FIFO_we_MWr or wb_FIFO_we_CplD;
  wb_FIFO_wsof_i <= wb_FIFO_wsof_CplD when wb_FIFO_we_CplD = '1' else wb_FIFO_wsof_MWr;
  wb_FIFO_weof_i <= wb_FIFO_weof_CplD when wb_FIFO_we_CplD = '1' else wb_FIFO_weof_MWr;
  wb_FIFO_din_i  <= wb_FIFO_din_CplD  when wb_FIFO_we_CplD = '1' else wb_FIFO_din_MWr;

  -- ------------------------------------------------
  -- Delay of Rx inputs
  -- ------------------------------------------------
  Rx_Input_Delays :
    RxIn_Delay
      port map(
        -- Common ports
        user_clk    => user_clk ,       -- IN  std_logic;
        user_reset  => user_reset ,     -- IN  std_logic;
        user_lnk_up => user_lnk_up ,    -- IN  std_logic;

        -- Transaction receive interface
        m_axis_rx_tlast    => m_axis_rx_tlast ,  -- IN  std_logic;
        m_axis_rx_tdata    => m_axis_rx_tdata ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        m_axis_rx_tkeep    => m_axis_rx_tkeep ,  -- IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
        m_axis_rx_terrfwd  => m_axis_rx_terrfwd ,   -- IN  std_logic;
        m_axis_rx_tvalid   => m_axis_rx_tvalid ,    -- IN  std_logic;
        m_axis_rx_tbar_hit => m_axis_rx_tbar_hit ,  -- IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);
        m_axis_rx_tready   => m_axis_rx_tready ,    -- OUT std_logic;
        Pool_wrBuf_full    => DDR_wr_full ,      -- IN  std_logic;
        Link_Buf_full      => Link_Buf_full ,    -- IN  std_logic;

        -- Delayed
        m_axis_rx_tlast_dly    => m_axis_rx_tlast_dly ,  -- OUT std_logic;
        m_axis_rx_tdata_dly    => m_axis_rx_tdata_dly ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        m_axis_rx_tkeep_dly    => m_axis_rx_tkeep_dly ,  -- OUT std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
        m_axis_rx_terrfwd_dly  => m_axis_rx_terrfwd_dly ,  -- OUT std_logic;
        m_axis_rx_tvalid_dly   => m_axis_rx_tvalid_dly,  -- OUT std_logic;
        m_axis_rx_tready_dly   => m_axis_rx_tready_dly,  -- OUT std_logic;
        m_axis_rx_tbar_hit_dly => m_axis_rx_tbar_hit_dly,  -- OUT std_logic_vector(C_BAR_NUMBER-1 downto 0);

        -- TLP resolution
        IORd_Type => IORd_Type ,        -- OUT std_logic;
        IOWr_Type => IOWr_Type ,        -- OUT std_logic;
        MRd_Type  => MRd_Type ,         -- OUT std_logic_vector(3 downto 0);
        MWr_Type  => MWr_Type ,         -- OUT std_logic_vector(1 downto 0);
        CplD_Type => CplD_Type ,        -- OUT std_logic_vector(3 downto 0);

        -- From Cpl/D channel
        usDMA_dex_Tag => usDMA_dex_Tag ,  -- IN  std_logic_vector(7 downto 0);
        dsDMA_dex_Tag => dsDMA_dex_Tag ,  -- IN  std_logic_vector(7 downto 0);

        -- To Memory request process modules
        Tlp_straddles_4KB => Tlp_straddles_4KB ,  -- OUT std_logic;

        -- To Cpl/D channel
        Tlp_has_4KB       => Tlp_has_4KB ,        -- OUT std_logic;
        Tlp_has_1DW       => Tlp_has_1DW ,        -- OUT std_logic;
        CplD_is_the_Last  => CplD_is_the_Last ,   -- OUT std_logic;
        CplD_on_Pool      => CplD_on_Pool ,       -- OUT std_logic;
        CplD_on_EB        => CplD_on_EB ,         -- OUT std_logic;
        Req_ID_Match      => Req_ID_Match ,       -- OUT std_logic;
        usDex_Tag_Matched => usDex_Tag_Matched ,  -- OUT std_logic;
        dsDex_Tag_Matched => dsDex_Tag_Matched ,  -- OUT std_logic;
        CplD_Tag          => CplD_Tag ,  -- OUT std_logic_vector(7 downto  0);

        -- Additional
        cfg_dcommand => cfg_dcommand ,  -- IN  std_logic_vector(16-1 downto 0)
        localID      => localID         -- IN  std_logic_vector(15 downto 0)
        );


  -- ------------------------------------------------
  -- Processing MRd Requests
  -- ------------------------------------------------
  MRd_Channel :
    rx_MRd_Transact
      port map(
        --
        m_axis_rx_tlast    => m_axis_rx_tlast_dly,  -- IN  std_logic;
        m_axis_rx_tdata    => m_axis_rx_tdata_dly,  -- IN  std_logic_vector(31 downto 0);
        m_axis_rx_tkeep    => m_axis_rx_tkeep_dly,  -- IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
        m_axis_rx_terrfwd  => m_axis_rx_terrfwd_dly,   -- IN  std_logic;
        m_axis_rx_tvalid   => m_axis_rx_tvalid_dly,    -- IN  std_logic;
        m_axis_rx_tbar_hit => m_axis_rx_tbar_hit_dly,  -- IN  std_logic_vector(6 downto 0);
--      m_axis_rx_tready      =>  open,  -- m_axis_rx_tready_MRd,            -- OUT std_logic;
        rx_np_ok           => rx_np_ok,             -- OUT std_logic;
        rx_np_req          => rx_np_req,            -- out std_logic;

        IORd_Type         => IORd_Type ,          -- IN  std_logic;
        MRd_Type          => MRd_Type ,  -- IN  std_logic_vector(3 downto 0);
        Tlp_straddles_4KB => Tlp_straddles_4KB ,  -- IN  std_logic;

        pioCplD_RE   => pioCplD_RE,     -- IN  std_logic;
        pioCplD_Req  => pioCplD_Req,    -- OUT std_logic;
        pioCplD_Qout => pioCplD_Qout,   -- OUT std_logic_vector(127 downto 0);
        pio_FC_stop  => pio_FC_stop,    -- IN  std_logic;

        FIFO_Empty         => wb_FIFO_Empty,       -- IN  std_logic;
        FIFO_Reading       => wb_FIFO_Reading,     -- IN  std_logic;
        pio_reading_status => pio_reading_status,  -- OUT std_logic;

        Channel_Rst => MRd_Channel_Rst,  -- IN  std_logic;

        user_clk    => user_clk,        -- IN  std_logic;
        user_reset  => user_reset,      -- IN  std_logic;
        user_lnk_up => user_lnk_up      -- IN  std_logic;
        );


  -- ------------------------------------------------
  -- Processing MWr Requests
  -- ------------------------------------------------
  MWr_Channel :
    rx_MWr_Transact
      port map(
        --
        m_axis_rx_tlast    => m_axis_rx_tlast_dly,  -- IN  std_logic;
        m_axis_rx_tdata    => m_axis_rx_tdata_dly,  -- IN  std_logic_vector(31 downto 0);
        m_axis_rx_tkeep    => m_axis_rx_tkeep_dly,  -- IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
        m_axis_rx_terrfwd  => m_axis_rx_terrfwd_dly ,  -- IN  std_logic;
        m_axis_rx_tvalid   => m_axis_rx_tvalid_dly,    -- IN  std_logic;
        m_axis_rx_tready   => m_axis_rx_tready_dly,    -- IN  std_logic;
        m_axis_rx_tbar_hit => m_axis_rx_tbar_hit_dly,  -- IN  std_logic_vector(6 downto 0);

        IOWr_Type         => IOWr_Type ,          -- OUT std_logic;
        MWr_Type          => MWr_Type ,  -- IN  std_logic_vector(1 downto 0);
        Tlp_straddles_4KB => Tlp_straddles_4KB ,  -- IN  std_logic;
        Tlp_has_4KB       => Tlp_has_4KB ,        -- IN  std_logic;

        -- Event Buffer write port
        wb_FIFO_we   => wb_FIFO_we_MWr ,   -- OUT std_logic;
        wb_FIFO_wsof => wb_FIFO_wsof_MWr ,  -- OUT std_logic;
        wb_FIFO_weof => wb_FIFO_weof_MWr ,  -- OUT std_logic;
        wb_FIFO_din  => wb_FIFO_din_MWr ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        -- To registers module
        Regs_WrEn   => Regs_WrEn0 ,     -- OUT std_logic;
        Regs_WrMask => Regs_WrMask0 ,   -- OUT std_logic_vector(2-1 downto 0);
        Regs_WrAddr => Regs_WrAddr0 ,   -- OUT std_logic_vector(16-1 downto 0);
        Regs_WrDin  => Regs_WrDin0 ,    -- OUT std_logic_vector(32-1 downto 0);

        -- DDR write port
        DDR_wr_sof   => DDR_wr_sof_A ,  --        OUT   std_logic;
        DDR_wr_eof   => DDR_wr_eof_A ,  --        OUT   std_logic;
        DDR_wr_v     => DDR_wr_v_A ,    --        OUT   std_logic;
        DDR_wr_FA    => DDR_wr_FA_A ,   --        OUT   std_logic;
        DDR_wr_Shift => DDR_wr_Shift_A ,  --        OUT   std_logic;
        DDR_wr_din   => DDR_wr_din_A ,  --        OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DDR_wr_Mask  => DDR_wr_Mask_A ,  --        OUT   std_logic_vector(2-1 downto 0);
        DDR_wr_full  => DDR_wr_full ,   --        IN    std_logic;

        -- Data generator table write
        tab_we => tab_we ,              -- OUT std_logic_vector(2-1 downto 0);
        tab_wa => tab_wa ,              -- OUT std_logic_vector(12-1 downto 0);
        tab_wd => tab_wd ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        -- Common
        user_clk    => user_clk ,       --        IN  std_logic;
        user_reset  => user_reset ,     --        IN  std_logic;
        user_lnk_up => user_lnk_up      --        IN  std_logic;
        );


  -- ---------------------------------------------------
  -- Processing Completions
  -- ---------------------------------------------------
  CplD_Channel :
    rx_CplD_Transact
      port map(
        --
        m_axis_rx_tlast    => m_axis_rx_tlast_dly,  -- IN  std_logic;
        m_axis_rx_tdata    => m_axis_rx_tdata_dly,  -- IN  std_logic_vector(31 downto 0);
        m_axis_rx_tkeep    => m_axis_rx_tkeep_dly,  -- IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
        m_axis_rx_terrfwd  => m_axis_rx_terrfwd_dly,   -- IN  std_logic;
        m_axis_rx_tvalid   => m_axis_rx_tvalid_dly,    -- IN  std_logic;
        m_axis_rx_tready   => m_axis_rx_tready_dly,    -- IN  std_logic;
        m_axis_rx_tbar_hit => m_axis_rx_tbar_hit_dly,  -- IN  std_logic_vector(6 downto 0);

        CplD_Type => CplD_Type,         -- IN  std_logic_vector(3 downto 0);

        Req_ID_Match      => Req_ID_Match,       -- IN  std_logic;
        usDex_Tag_Matched => usDex_Tag_Matched,  -- IN  std_logic;
        dsDex_Tag_Matched => dsDex_Tag_Matched,  -- IN  std_logic;

        Tlp_has_4KB      => Tlp_has_4KB ,      -- IN  std_logic;
        Tlp_has_1DW      => Tlp_has_1DW ,      -- IN  std_logic;
        CplD_is_the_Last => CplD_is_the_Last,  -- IN  std_logic;
        CplD_on_Pool     => CplD_on_Pool ,     -- IN  std_logic;
        CplD_on_EB       => CplD_on_EB ,       -- IN  std_logic;
        CplD_Tag         => CplD_Tag,   -- IN  std_logic_vector( 7 downto  0);
        FC_pop           => FC_pop,     -- OUT std_logic;

        -- Downstream DMA transferred bytes count up
        ds_DMA_Bytes_Add => ds_DMA_Bytes_Add,  -- OUT std_logic;
        ds_DMA_Bytes     => ds_DMA_Bytes ,  -- OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

        -- Downstream tRAM port A write request
        tRAM_weB   => tRAM_weB,         -- IN  std_logic;
        tRAM_addrB => tRAM_addrB,       -- IN  std_logic_vector( 6 downto 0);
        tRAM_dinB  => tRAM_dinB,        -- IN  std_logic_vector(47 downto 0);

        -- Downstream channel descriptor tag
        dsDMA_dex_Tag => dsDMA_dex_Tag,  -- OUT std_logic_vector( 7 downto 0);

        -- Downstream Tag Map Signal for Busy/Done
        Tag_Map_Clear => Tag_Map_Clear,  -- OUT std_logic_vector(127 downto 0);

        -- Upstream channel descriptor tag
        usDMA_dex_Tag => usDMA_dex_Tag,  -- OUT std_logic_vector( 7 downto 0);

        -- Event Buffer write port
        wb_FIFO_we   => wb_FIFO_we_CplD ,   -- OUT std_logic;
        wb_FIFO_wsof => wb_FIFO_wsof_CplD ,  -- OUT std_logic;
        wb_FIFO_weof => wb_FIFO_weof_CplD ,  -- OUT std_logic;
        wb_FIFO_din  => wb_FIFO_din_CplD ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        -- To registers module
        Regs_WrEn   => Regs_WrEn1,      -- OUT std_logic;
        Regs_WrMask => Regs_WrMask1,    -- OUT std_logic_vector(2-1 downto 0);
        Regs_WrAddr => Regs_WrAddr1,    -- OUT std_logic_vector(16-1 downto 0);
        Regs_WrDin  => Regs_WrDin1,     -- OUT std_logic_vector(32-1 downto 0);

        -- DDR write port
        DDR_wr_sof   => DDR_wr_sof_B ,  --        OUT   std_logic;
        DDR_wr_eof   => DDR_wr_eof_B ,  --        OUT   std_logic;
        DDR_wr_v     => DDR_wr_v_B ,    --        OUT   std_logic;
        DDR_wr_FA    => DDR_wr_FA_B ,   --        OUT   std_logic;
        DDR_wr_Shift => DDR_wr_Shift_B ,  --        OUT   std_logic;
        DDR_wr_Mask  => DDR_wr_Mask_B ,  --        OUT   std_logic_vector(2-1 downto 0);
        DDR_wr_din   => DDR_wr_din_B ,  --        OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DDR_wr_full  => DDR_wr_full ,   --        IN    std_logic;

        -- Common
        user_clk    => user_clk,        -- IN std_logic;
        user_reset  => user_reset,      -- IN std_logic;
        user_lnk_up => user_lnk_up      -- IN std_logic;
        );

  -- ------------------------------------------------
  -- Processing upstream DMA Requests
  -- ------------------------------------------------
  Upstream_DMA_Engine :
    usDMA_Transact
      port map(
        -- TLP buffer
        usTlp_RE   => usTlp_RE,         -- IN std_logic;
        usTlp_Req  => usTlp_Req,        -- OUT std_logic;
        usTlp_Qout => usTlp_Qout,       -- OUT std_logic_vector(127 downto 0)

        FIFO_Data_Count => wb_FIFO_data_count,  -- IN  std_logic_vector(C_FIFO_DC_WIDTH downto 0);
        FIFO_Reading    => wb_FIFO_Reading,     -- IN  std_logic;

        -- upstream Control Signals from MWr Channel
        usDMA_Start => usDMA_Start,     -- IN  std_logic;
        usDMA_Stop  => usDMA_Stop,      -- IN  std_logic;

        -- Upstream Control Signals from CplD Channel
        usDMA_Start2 => usDMA_Start2,   -- IN  std_logic;
        usDMA_Stop2  => usDMA_Stop2,    -- IN  std_logic;

        DMA_Cmd_Ack       => usDMA_Cmd_Ack,      -- OUT std_logic;
        usDMA_Channel_Rst => usDMA_Channel_Rst,  -- IN  std_logic;
        us_FC_stop        => us_FC_stop,         -- IN  std_logic;
        us_Last_sof       => us_Last_sof,        -- IN  std_logic;
        us_Last_eof       => us_Last_eof,        -- IN  std_logic;

        -- To Interrupt module
        DMA_Done    => DMA_us_Done,     -- OUT std_logic;
        DMA_TimeOut => DMA_us_Tout,     -- OUT std_logic;
        DMA_Busy    => DMA_us_Busy,     -- OUT std_logic;

        -- To Tx channel
        DMA_us_Status => DMA_us_Status,  -- OUT std_logic_vector(31 downto 0);

        -- upstream Registers
        DMA_us_PA         => DMA_us_PA,   -- IN  std_logic_vector(63 downto 0);
        DMA_us_HA         => DMA_us_HA,   -- IN  std_logic_vector(63 downto 0);
        DMA_us_BDA        => DMA_us_BDA,  -- IN  std_logic_vector(63 downto 0);
        DMA_us_Length     => DMA_us_Length,  -- IN  std_logic_vector(31 downto 0);
        DMA_us_Control    => DMA_us_Control,  -- IN  std_logic_vector(31 downto 0);
        usDMA_BDA_eq_Null => usDMA_BDA_eq_Null,  -- IN  std_logic;
        us_MWr_Param_Vec  => us_MWr_Param_Vec,  -- IN  std_logic_vector(5 downto 0);

        -- Calculation in advance, for better timing
        usHA_is_64b  => usHA_is_64b ,   -- IN  std_logic;
        usBDA_is_64b => usBDA_is_64b ,  -- IN  std_logic;

        usLeng_Hi19b_True => usLeng_Hi19b_True ,  --  IN  std_logic;
        usLeng_Lo7b_True  => usLeng_Lo7b_True ,   --  IN  std_logic;

        usDMA_dex_Tag => usDMA_dex_Tag ,  -- OUT std_logic_vector( 7 downto 0);

        cfg_dcommand => cfg_dcommand ,  -- IN  std_logic_vector(16-1 downto 0)

        user_clk => user_clk            -- IN std_logic;
        );

  -- ------------------------------------------------
  -- Processing downstream DMA Requests
  -- ------------------------------------------------
  Downstream_DMA_Engine :
    dsDMA_Transact
      port map(
        -- Downstream tRAM port A write request
        tRAM_weB   => tRAM_weB,         -- OUT std_logic;
        tRAM_addrB => tRAM_addrB,       -- OUT std_logic_vector( 6 downto 0);
        tRAM_dinB  => tRAM_dinB,        -- OUT std_logic_vector(47 downto 0);

        -- TLP buffer
        MRd_dsp_RE   => dsMRd_RE,       -- IN std_logic;
        MRd_dsp_Req  => dsMRd_Req,      -- OUT std_logic;
        MRd_dsp_Qout => dsMRd_Qout,     -- OUT std_logic_vector(127 downto 0);

        -- Downstream Registers
        DMA_ds_PA         => DMA_ds_PA,   -- IN  std_logic_vector(63 downto 0);
        DMA_ds_HA         => DMA_ds_HA,   -- IN  std_logic_vector(63 downto 0);
        DMA_ds_BDA        => DMA_ds_BDA,  -- IN  std_logic_vector(63 downto 0);
        DMA_ds_Length     => DMA_ds_Length,  -- IN  std_logic_vector(31 downto 0);
        DMA_ds_Control    => DMA_ds_Control,  -- IN  std_logic_vector(31 downto 0);
        dsDMA_BDA_eq_Null => dsDMA_BDA_eq_Null,  -- IN  std_logic;

        -- Calculation in advance, for better timing
        dsHA_is_64b  => dsHA_is_64b ,   -- IN  std_logic;
        dsBDA_is_64b => dsBDA_is_64b ,  -- IN  std_logic;

        dsLeng_Hi19b_True => dsLeng_Hi19b_True ,  -- IN  std_logic;
        dsLeng_Lo7b_True  => dsLeng_Lo7b_True ,   -- IN  std_logic;

        -- Downstream Control Signals from MWr Channel
        dsDMA_Start => dsDMA_Start,     -- IN  std_logic;
        dsDMA_Stop  => dsDMA_Stop,      -- IN  std_logic;

        -- Downstream Control Signals from CplD Channel
        dsDMA_Start2 => dsDMA_Start2,   -- IN  std_logic;
        dsDMA_Stop2  => dsDMA_Stop2,    -- IN  std_logic;

        DMA_Cmd_Ack       => dsDMA_Cmd_Ack,      -- OUT std_logic;
        dsDMA_Channel_Rst => dsDMA_Channel_Rst,  -- IN  std_logic;

        -- Downstream Handshake Signals with CplD Channel for Busy/Done
        Tag_Map_Clear => Tag_Map_Clear,  -- IN  std_logic_vector(127 downto 0);

        FC_pop => FC_pop,               -- IN  std_logic;

        -- To Interrupt module
        DMA_Done    => DMA_ds_Done,     -- OUT std_logic;
        DMA_TimeOut => DMA_ds_Tout,     -- OUT std_logic;
        DMA_Busy    => DMA_ds_Busy,     -- OUT std_logic;

        -- To Tx channel
        DMA_ds_Status => DMA_ds_Status,  -- OUT std_logic_vector(31 downto 0);

        -- tag for descriptor
        dsDMA_dex_Tag => dsDMA_dex_Tag,  -- IN  std_logic_vector( 7 downto 0);

        -- Additional
        cfg_dcommand => cfg_dcommand ,  -- IN  std_logic_vector(16-1 downto 0)

        -- common
        user_clk => user_clk            -- IN std_logic;
        );

  -- ------------------------------------------------
  --   Interrupts generation
  -- ------------------------------------------------
  Intrpt_Handle :
    Interrupts
      port map(
        Sys_IRQ => Sys_IRQ ,            -- IN  std_logic_vector(31 downto 0);

        -- Interrupt generator signals
        IG_Reset        => IG_Reset ,   -- IN  std_logic;
        IG_Host_Clear   => IG_Host_Clear ,  -- IN  std_logic;
        IG_Latency      => IG_Latency ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1   downto 0);
        IG_Num_Assert   => IG_Num_Assert ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1   downto 0);
        IG_Num_Deassert => IG_Num_Deassert ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1   downto 0);
        IG_Asserting    => IG_Asserting ,   -- OUT std_logic;

        -- cfg interface
        cfg_interrupt           => cfg_interrupt ,     -- OUT std_logic;
        cfg_interrupt_rdy       => cfg_interrupt_rdy ,       -- IN  std_logic;
        cfg_interrupt_mmenable  => cfg_interrupt_mmenable ,  -- IN  std_logic_vector(2 downto 0);
        cfg_interrupt_msienable => cfg_interrupt_msienable ,  -- IN  std_logic;
        cfg_interrupt_di        => cfg_interrupt_di ,  -- OUT std_logic_vector(7 downto 0);
        cfg_interrupt_do        => cfg_interrupt_do ,  -- IN  std_logic_vector(7 downto 0);
        cfg_interrupt_assert    => cfg_interrupt_assert ,    -- OUT std_logic;

        -- Irpt Channel
        Irpt_Req  => Irpt_Req ,         -- OUT std_logic;
        Irpt_RE   => Irpt_RE ,          -- IN  std_logic;
        Irpt_Qout => Irpt_Qout ,        -- OUT std_logic_vector(127 downto 0);

        user_clk   => user_clk ,        -- IN  std_logic;
        user_reset => user_reset        -- IN  std_logic
        );


end architecture Behavioral;
