----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    11:09:49 10/18/2006
-- Design Name:
-- Module Name:    tlpControl - Behavioral
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
-- Revision 1.06 - Timing improved.     17.01.2007
--
-- Revision 1.04 - FIFO added.     20.12.2006
--
-- Revision 1.02 - second release. 14.12.2006
--
-- Revision 1.00 - first release.  18.10.2006
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

entity tlpControl is
  port (
    -- Wishbone write interface
    wb_FIFO_we   : out std_logic;
    wb_FIFO_wsof : out std_logic;
    wb_FIFO_weof : out std_logic;
    wb_FIFO_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wb_fifo_full : in std_logic;
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

    wb_fifo_rst : out std_logic;
    -- DDR control interface
    DDR_Ready : in std_logic;
    ddr_reset : out std_logic;
    ddr_axi_reset : out std_logic; 
    --AXI4 stream command/data
    ddr_mm2s_cmd_tvalid : out STD_LOGIC;
    ddr_mm2s_cmd_tready : in STD_LOGIC;
    ddr_mm2s_cmd_tdata : out STD_LOGIC_VECTOR(71 DOWNTO 0);
    ddr_mm2s_sts_tvalid : in STD_LOGIC;
    ddr_mm2s_sts_tready : out STD_LOGIC;
    ddr_mm2s_sts_tdata : in STD_LOGIC_VECTOR(7 DOWNTO 0);
    ddr_mm2s_sts_tkeep : in STD_LOGIC_VECTOR(0 DOWNTO 0);
    ddr_mm2s_sts_tlast : in STD_LOGIC;
    ddr_mm2s_tdata : in STD_LOGIC_VECTOR(63 DOWNTO 0);
    ddr_mm2s_tkeep : in STD_LOGIC_VECTOR(7 DOWNTO 0);
    ddr_mm2s_tlast : in STD_LOGIC;
    ddr_mm2s_tvalid : in STD_LOGIC;
    ddr_mm2s_tready : out STD_LOGIC;
    ddr_s2mm_cmd_tvalid : out STD_LOGIC;
    ddr_s2mm_cmd_tready : in STD_LOGIC;
    ddr_s2mm_cmd_tdata : out STD_LOGIC_VECTOR(71 DOWNTO 0);
    ddr_s2mm_sts_tvalid : in STD_LOGIC;
    ddr_s2mm_sts_tready : out STD_LOGIC;
    ddr_s2mm_sts_tdata : in STD_LOGIC_VECTOR(7 DOWNTO 0);
    ddr_s2mm_sts_tkeep : in STD_LOGIC_VECTOR(0 DOWNTO 0);
    ddr_s2mm_sts_tlast : in STD_LOGIC;
    ddr_s2mm_tdata : out STD_LOGIC_VECTOR(63 DOWNTO 0);
    ddr_s2mm_tkeep : out STD_LOGIC_VECTOR(7 DOWNTO 0);
    ddr_s2mm_tlast : out STD_LOGIC;
    ddr_s2mm_tvalid : out STD_LOGIC;
    ddr_s2mm_tready : in STD_LOGIC;
    ddr_mm2s_err : in std_logic;
    ddr_s2mm_err : in std_logic;
    -- Common interface
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
--    trn_rfc_ph_av              : IN  std_logic_vector(7 downto 0);
--    trn_rfc_pd_av              : IN  std_logic_vector(11 downto 0);
--    trn_rfc_nph_av             : IN  std_logic_vector(7 downto 0);
--    trn_rfc_npd_av             : IN  std_logic_vector(11 downto 0);
--    trn_rfc_cplh_av            : IN  std_logic_vector(7 downto 0);
--    trn_rfc_cpld_av            : IN  std_logic_vector(11 downto 0);

    -- Transaction transmit interface
    s_axis_tx_tlast   : out std_logic;
    s_axis_tx_tdata   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    s_axis_tx_tkeep   : out std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
    s_axis_tx_terrfwd : out std_logic;
    s_axis_tx_tvalid  : out std_logic;
    s_axis_tx_tready  : in  std_logic;
    s_axis_tx_tdsc    : out std_logic;
    tx_buf_av         : in  std_logic_vector(C_TBUF_AWIDTH-1 downto 0);

    -- Interrupt Interface
    cfg_interrupt            : out std_logic;
    cfg_interrupt_rdy        : in  std_logic;
    cfg_interrupt_mmenable   : in  std_logic_vector(2 downto 0);
    cfg_interrupt_msienable  : in  std_logic;
    cfg_interrupt_msixenable : in std_logic;
    cfg_interrupt_msixfm     : in std_logic;
    cfg_interrupt_di         : out std_logic_vector(7 downto 0);
    cfg_interrupt_do         : in  std_logic_vector(7 downto 0);
    cfg_interrupt_assert     : out std_logic;

    -- Local signals
    pcie_link_width : in std_logic_vector(CINT_BIT_LWIDTH_IN_GSR_TOP-CINT_BIT_LWIDTH_IN_GSR_BOT downto 0);
    cfg_dcommand    : in std_logic_vector(16-1 downto 0);
    localID         : in std_logic_vector(C_ID_WIDTH-1 downto 0)
    );

end entity tlpControl;


architecture Behavioral of tlpControl is

  -- Downstream DMA transferred bytes count up
  signal ds_DMA_Bytes_Add : std_logic;
  signal ds_DMA_Bytes     : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

  -- Upstream DMA transferred bytes count up
  signal us_DMA_Bytes_Add : std_logic;
  signal us_DMA_Bytes     : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

  -- eb FIFO read enable
  signal wb_FIFO_RdEn_i : std_logic;

  -- Flow control signals
  signal us_FC_stop  : std_logic;
  signal us_Last_sof : std_logic;
  signal us_Last_eof : std_logic;


  -- Signals between Tx_Transact and Rx_Transact
  signal pioCplD_Req  : std_logic;
  signal pioCplD_RE   : std_logic;
  signal pioCplD_Qout : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  -- MRd-downstream packet Channel
  signal dsMRd_Req  : std_logic;
  signal dsMRd_RE   : std_logic;
  signal dsMRd_Qout : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  -- Upstream MWr Channel
  signal usTlp_Req  : std_logic;
  signal usTlp_RE   : std_logic;
  signal usTlp_Qout : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  -- Irpt Channel
  signal Irpt_Req  : std_logic;
  signal Irpt_RE   : std_logic;
  signal Irpt_Qout : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  -- SDRAM and Wishbone paging registers
  signal sdram_pg_i : std_logic_vector(31 downto 0);
  signal wb_pg_i    : std_logic_vector(31 downto 0);

  -- Registers Write Port
  signal Regs_WrEnA   : std_logic;
  signal Regs_WrMaskA : std_logic_vector(2-1 downto 0);
  signal Regs_WrAddrA : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal Regs_WrDinA  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal Regs_WrEnB   : std_logic;
  signal Regs_WrMaskB : std_logic_vector(2-1 downto 0);
  signal Regs_WrAddrB : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal Regs_WrDinB  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Dex parameters to downstream DMA
  signal DMA_ds_PA         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_ds_HA         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_ds_BDA        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_ds_Length     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_ds_Control    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal dsDMA_BDA_eq_Null : std_logic;
  signal DMA_ds_Status     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_ds_Done_i     : std_logic;
  signal DMA_ds_Busy_i     : std_logic;
  signal DMA_ds_Tout       : std_logic;

  -- Calculation in advance, for better timing
  signal dsHA_is_64b       : std_logic;
  signal dsBDA_is_64b      : std_logic;
  -- Calculation in advance, for better timing
  signal dsLeng_Hi19b_True : std_logic;
  signal dsLeng_Lo7b_True  : std_logic;

  -- Downstream Control Signals
  signal dsDMA_Start       : std_logic;
  signal dsDMA_Stop        : std_logic;
  signal dsDMA_Start2      : std_logic;
  signal dsDMA_Stop2       : std_logic;
  signal dsDMA_Cmd_Ack     : std_logic;
  signal dsDMA_Channel_Rst : std_logic;

  -- Dex parameters to upstream DMA
  signal DMA_us_PA         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_us_HA         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_us_BDA        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_us_Length     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_us_Control    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal usDMA_BDA_eq_Null : std_logic;
  signal us_MWr_Param_Vec  : std_logic_vector(6-1 downto 0);
  signal DMA_us_Status     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DMA_us_Done_i     : std_logic;
  signal DMA_us_Busy_i     : std_logic;
  signal DMA_us_Tout       : std_logic;

  -- Calculation in advance, for better timing
  signal usHA_is_64b       : std_logic;
  signal usBDA_is_64b      : std_logic;
  -- Calculation in advance, for better timing
  signal usLeng_Hi19b_True : std_logic;
  signal usLeng_Lo7b_True  : std_logic;

  -- Upstream Control Signals
  signal usDMA_Start       : std_logic;
  signal usDMA_Stop        : std_logic;
  signal usDMA_Start2      : std_logic;
  signal usDMA_Stop2       : std_logic;
  signal usDMA_Cmd_Ack     : std_logic;
  signal usDMA_Channel_Rst : std_logic;
  --      MRd Channel Reset
  signal MRd_Channel_Rst : std_logic;
  --      Tx module Reset
  signal Tx_Reset : std_logic;
  --      Tx time out
  signal Tx_TimeOut    : std_logic;
  signal Tx_wb_TimeOut : std_logic;
  -- Registers read port
  signal Regs_RdAddr : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal Regs_RdQout : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  -- Register to Interrupt module
  signal Sys_IRQ : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  -- Message routing method
  signal Msg_Routing : std_logic_vector(C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT downto 0);
  -- Interrupt Generation Signals
  signal IG_Reset        : std_logic;
  signal IG_Host_Clear   : std_logic;
  signal IG_Latency      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal IG_Num_Assert   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal IG_Num_Deassert : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal IG_Asserting    : std_logic;

begin

  wb_FIFO_re <= wb_FIFO_RdEn_i;
  wb_timeout <= Tx_wb_TimeOut;

  -- Rx TLP interface
  rx_Itf :
    entity work.rx_Transact
      port map(
        -- Common ports
        user_clk    => user_clk,        -- IN  std_logic,
        user_reset  => user_reset,      -- IN  std_logic,
        user_lnk_up => user_lnk_up,     -- IN  std_logic,

        -- Transaction receive interface
        m_axis_rx_tlast    => m_axis_rx_tlast,  -- IN  std_logic,
        m_axis_rx_tdata    => m_axis_rx_tdata,  -- IN  std_logic_vector(31 downto 0),
        m_axis_rx_tkeep    => m_axis_rx_tkeep,  -- IN  STD_LOGIC_VECTOR (  7 downto 0 );
        m_axis_rx_terrfwd  => m_axis_rx_terrfwd,   -- IN  std_logic,
        m_axis_rx_tvalid   => m_axis_rx_tvalid,    -- IN  std_logic,
        m_axis_rx_tready   => m_axis_rx_tready,    -- OUT std_logic,
        rx_np_ok           => rx_np_ok,         -- OUT std_logic,
        rx_np_req          => rx_np_req,        -- out std_logic;
        m_axis_rx_tbar_hit => m_axis_rx_tbar_hit,  -- IN  std_logic_vector(6 downto 0),
--    trn_rfc_ph_av        => trn_rfc_ph_av,       -- IN  std_logic_vector(7 downto 0),
--    trn_rfc_pd_av        => trn_rfc_pd_av,       -- IN  std_logic_vector(11 downto 0),
--    trn_rfc_nph_av       => trn_rfc_nph_av,      -- IN  std_logic_vector(7 downto 0),
--    trn_rfc_npd_av       => trn_rfc_npd_av,      -- IN  std_logic_vector(11 downto 0),
--    trn_rfc_cplh_av      => trn_rfc_cplh_av,     -- IN  std_logic_vector(7 downto 0),
--    trn_rfc_cpld_av      => trn_rfc_cpld_av,     -- IN  std_logic_vector(11 downto 0),

        -- MRd Channel
        pioCplD_Req  => pioCplD_Req,    -- OUT std_logic;
        pioCplD_RE   => pioCplD_RE,     -- IN  std_logic;
        pioCplD_Qout => pioCplD_Qout,   -- OUT std_logic_vector(96 downto 0);

        -- downstream MRd Channel
        dsMRd_Req  => dsMRd_Req,        -- OUT std_logic;
        dsMRd_RE   => dsMRd_RE,         -- IN  std_logic;
        dsMRd_Qout => dsMRd_Qout,       -- OUT std_logic_vector(96 downto 0);

        -- Upstream MWr/MRd Channel
        usTlp_Req   => usTlp_Req,       -- OUT std_logic;
        usTlp_RE    => usTlp_RE,        -- IN  std_logic;
        usTlp_Qout  => usTlp_Qout,      -- OUT std_logic_vector(96 downto 0);
        us_FC_stop  => us_FC_stop,      -- IN  std_logic;
        us_Last_sof => us_Last_sof,     -- IN  std_logic;
        us_Last_eof => us_Last_eof,     -- IN  std_logic;

        -- Irpt Channel
        Irpt_Req  => Irpt_Req,          -- OUT std_logic;
        Irpt_RE   => Irpt_RE,           -- IN  std_logic;
        Irpt_Qout => Irpt_Qout,         -- OUT std_logic_vector(96 downto 0);

        -- SDRAM and Wishbone pages
        sdram_pg => sdram_pg_i,
        wb_pg    => wb_pg_i,

        -- Interrupt Interface
        cfg_interrupt            => cfg_interrupt ,     -- OUT std_logic;
        cfg_interrupt_rdy        => cfg_interrupt_rdy ,       -- IN std_logic;
        cfg_interrupt_mmenable   => cfg_interrupt_mmenable ,  -- IN std_logic_VECTOR(2 downto 0);
        cfg_interrupt_msienable  => cfg_interrupt_msienable ,  -- IN std_logic;
        cfg_interrupt_msixenable => cfg_interrupt_msixenable ,
        cfg_interrupt_msixfm     => cfg_interrupt_msixfm ,
        cfg_interrupt_di         => cfg_interrupt_di ,  -- OUT std_logic_VECTOR(7 downto 0);
        cfg_interrupt_do         => cfg_interrupt_do ,  -- IN std_logic_VECTOR(7 downto 0);
        cfg_interrupt_assert     => cfg_interrupt_assert ,    -- OUT std_logic;

        -- Wishbone write port
        wb_FIFO_we   => wb_FIFO_we ,    -- OUT std_logic;
        wb_FIFO_wsof => wb_FIFO_wsof ,  -- OUT std_logic;
        wb_FIFO_weof => wb_FIFO_weof ,  -- OUT std_logic;
        wb_FIFO_din  => wb_FIFO_din ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        wb_FIFO_full => wb_FIFO_full,

        wb_FIFO_Empty      => wb_FIFO_Empty ,      -- IN  std_logic;
        wb_FIFO_Reading    => wb_FIFO_RdEn_i ,     -- IN  std_logic;

        -- Register Write
        Regs_WrEn0   => Regs_WrEnA ,    -- OUT std_logic;
        Regs_WrMask0 => Regs_WrMaskA ,  -- OUT std_logic_vector(2-1   downto 0);
        Regs_WrAddr0 => Regs_WrAddrA ,  -- OUT std_logic_vector(16-1   downto 0);
        Regs_WrDin0  => Regs_WrDinA ,  -- OUT std_logic_vector(32-1   downto 0);

        Regs_WrEn1   => Regs_WrEnB ,    -- OUT std_logic;
        Regs_WrMask1 => Regs_WrMaskB ,  -- OUT std_logic_vector(2-1   downto 0);
        Regs_WrAddr1 => Regs_WrAddrB ,  -- OUT std_logic_vector(16-1   downto 0);
        Regs_WrDin1  => Regs_WrDinB ,  -- OUT std_logic_vector(32-1   downto 0);

        -- Downstream DMA transferred bytes count up
        ds_DMA_Bytes_Add => ds_DMA_Bytes_Add ,  -- OUT std_logic;
        ds_DMA_Bytes     => ds_DMA_Bytes ,  -- OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

        -- Registers
        DMA_ds_PA         => DMA_ds_PA ,  -- IN  std_logic_vector(63 downto 0);
        DMA_ds_HA         => DMA_ds_HA ,  -- IN  std_logic_vector(63 downto 0);
        DMA_ds_BDA        => DMA_ds_BDA ,  -- IN  std_logic_vector(63 downto 0);
        DMA_ds_Length     => DMA_ds_Length ,  -- IN  std_logic_vector(31 downto 0);
        DMA_ds_Control    => DMA_ds_Control ,  -- IN  std_logic_vector(31 downto 0);
        dsDMA_BDA_eq_Null => dsDMA_BDA_eq_Null ,  -- IN  std_logic;
        DMA_ds_Status     => DMA_ds_Status ,  -- OUT std_logic_vector(31 downto 0);
        DMA_ds_Done       => DMA_ds_Done_i ,  -- OUT std_logic;
        DMA_ds_Busy       => DMA_ds_Busy_i ,  -- OUT std_logic;
        DMA_ds_Tout       => DMA_ds_Tout ,    -- OUT std_logic;

        dsHA_is_64b  => dsHA_is_64b ,   -- IN  std_logic;
        dsBDA_is_64b => dsBDA_is_64b ,  -- IN  std_logic;

        dsLeng_Hi19b_True => dsLeng_Hi19b_True ,  -- IN  std_logic;
        dsLeng_Lo7b_True  => dsLeng_Lo7b_True ,   -- IN  std_logic;

        dsDMA_Start       => dsDMA_Start ,        -- IN  std_logic;
        dsDMA_Stop        => dsDMA_Stop ,         -- IN  std_logic;
        dsDMA_Start2      => dsDMA_Start2 ,       -- IN  std_logic;
        dsDMA_Stop2       => dsDMA_Stop2 ,        -- IN  std_logic;
        dsDMA_Channel_Rst => dsDMA_Channel_Rst ,  -- IN  std_logic;
        dsDMA_Cmd_Ack     => dsDMA_Cmd_Ack ,      -- OUT std_logic;

        DMA_us_PA         => DMA_us_PA ,  -- IN  std_logic_vector(63 downto 0);
        DMA_us_HA         => DMA_us_HA ,  -- IN  std_logic_vector(63 downto 0);
        DMA_us_BDA        => DMA_us_BDA ,  -- IN  std_logic_vector(63 downto 0);
        DMA_us_Length     => DMA_us_Length ,  -- IN  std_logic_vector(31 downto 0);
        DMA_us_Control    => DMA_us_Control ,  -- IN  std_logic_vector(31 downto 0);
        usDMA_BDA_eq_Null => usDMA_BDA_eq_Null ,  -- IN  std_logic;
        us_MWr_Param_Vec  => us_MWr_Param_Vec ,  -- IN  std_logic_vector(6-1   downto 0);
        DMA_us_Status     => DMA_us_Status ,  -- OUT std_logic_vector(31 downto 0);
        DMA_us_Done       => DMA_us_Done_i ,  -- OUT std_logic;
        DMA_us_Busy       => DMA_us_Busy_i ,  -- OUT std_logic;
        DMA_us_Tout       => DMA_us_Tout ,    -- OUT std_logic;

        usHA_is_64b  => usHA_is_64b ,   -- IN  std_logic;
        usBDA_is_64b => usBDA_is_64b ,  -- IN  std_logic;

        usLeng_Hi19b_True => usLeng_Hi19b_True ,  -- IN  std_logic;
        usLeng_Lo7b_True  => usLeng_Lo7b_True ,   -- IN  std_logic;

        usDMA_Start       => usDMA_Start ,        -- IN  std_logic;
        usDMA_Stop        => usDMA_Stop ,         -- IN  std_logic;
        usDMA_Start2      => usDMA_Start2 ,       -- IN  std_logic;
        usDMA_Stop2       => usDMA_Stop2 ,        -- IN  std_logic;
        usDMA_Channel_Rst => usDMA_Channel_Rst ,  -- IN  std_logic;
        usDMA_Cmd_Ack     => usDMA_Cmd_Ack ,      -- OUT std_logic;

        -- Reset signals
        MRd_Channel_Rst => MRd_Channel_Rst ,  -- IN  std_logic;

        -- to Interrupt module
        Sys_IRQ => Sys_IRQ ,            -- IN  std_logic_vector(31 downto 0);

        IG_Reset        => IG_Reset ,
        IG_Host_Clear   => IG_Host_Clear ,
        IG_Latency      => IG_Latency ,
        IG_Num_Assert   => IG_Num_Assert ,
        IG_Num_Deassert => IG_Num_Deassert ,
        IG_Asserting    => IG_Asserting ,
        -- DDR write port
        ddr_s2mm_cmd_tvalid => ddr_s2mm_cmd_tvalid,
        ddr_s2mm_cmd_tready => ddr_s2mm_cmd_tready,
        ddr_s2mm_cmd_tdata => ddr_s2mm_cmd_tdata,
        ddr_s2mm_tdata => ddr_s2mm_tdata,
        ddr_s2mm_tkeep => ddr_s2mm_tkeep,
        ddr_s2mm_tlast => ddr_s2mm_tlast,
        ddr_s2mm_tvalid => ddr_s2mm_tvalid,
        ddr_s2mm_tready => ddr_s2mm_tready,
        -- Additional
        cfg_dcommand => cfg_dcommand ,  -- IN  std_logic_vector(15 downto 0)
        localID      => localID         -- IN  std_logic_vector(15 downto 0)
        );

  -- Tx TLP interface
  tx_Itf :
    entity work.tx_Transact
      port map(
        -- Common ports
        user_clk    => user_clk,        -- IN  std_logic,
        user_reset  => user_reset,      -- IN  std_logic,
        user_lnk_up => user_lnk_up,     -- IN  std_logic,
        -- Transaction
        s_axis_tx_tlast   => s_axis_tx_tlast,  -- OUT std_logic,
        s_axis_tx_tdata   => s_axis_tx_tdata,  -- OUT std_logic_vector(31 downto 0),
        s_axis_tx_tkeep   => s_axis_tx_tkeep,  -- OUT STD_LOGIC_VECTOR (  7 downto 0 );
        s_axis_tx_terrfwd => s_axis_tx_terrfwd,  -- OUT std_logic,
        s_axis_tx_tvalid  => s_axis_tx_tvalid,   -- OUT std_logic,
        s_axis_tx_tready  => s_axis_tx_tready,   -- IN  std_logic,
        s_axis_tx_tdsc    => s_axis_tx_tdsc,   -- OUT std_logic,
        tx_buf_av         => tx_buf_av,  -- IN  std_logic_vector(6 downto 0),
        -- Upstream DMA transferred bytes count up
        us_DMA_Bytes_Add => us_DMA_Bytes_Add,  -- OUT std_logic;
        us_DMA_Bytes     => us_DMA_Bytes,  -- OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);
        -- MRd Channel
        pioCplD_Req  => pioCplD_Req,    -- IN  std_logic;
        pioCplD_RE   => pioCplD_RE,     -- OUT std_logic;
        pioCplD_Qout => pioCplD_Qout,   -- IN  std_logic_vector(96 downto 0);
        -- downstream MRd Channel
        dsMRd_Req  => dsMRd_Req,        -- IN  std_logic;
        dsMRd_RE   => dsMRd_RE,         -- OUT std_logic;
        dsMRd_Qout => dsMRd_Qout,       -- IN  std_logic_vector(96 downto 0);
        -- Upstream MWr/MRd Channel
        usTlp_Req   => usTlp_Req,       -- IN  std_logic;
        usTlp_RE    => usTlp_RE,        -- OUT std_logic;
        usTlp_Qout  => usTlp_Qout,      -- IN  std_logic_vector(96 downto 0);
        us_FC_stop  => us_FC_stop,      -- OUT std_logic;
        us_Last_sof => us_Last_sof,     -- OUT std_logic;
        us_Last_eof => us_Last_eof,     -- OUT std_logic;
        -- Irpt Channel
        Irpt_Req  => Irpt_Req,          -- IN  std_logic;
        Irpt_RE   => Irpt_RE,           -- OUT std_logic;
        Irpt_Qout => Irpt_Qout,         -- IN  std_logic_vector(96 downto 0);
        -- Wishbone read command port
        wb_rdc_sof  => wb_rdc_sof, --out std_logic;
        wb_rdc_v    => wb_rdc_v, --out std_logic;
        wb_rdc_din  => wb_rdc_din, --out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        wb_rdc_full => wb_rdc_full, --in std_logic;
        -- Wisbbone Buffer read port
        wb_FIFO_re    => wb_FIFO_RdEn_i,  -- OUT std_logic;
        wb_FIFO_empty => wb_FIFO_empty ,  -- IN  std_logic;
        wb_FIFO_qout  => wb_FIFO_qout ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        -- Registers read
        Regs_RdAddr => Regs_RdAddr,     -- OUT std_logic_vector(15 downto 0);
        Regs_RdQout => Regs_RdQout,     -- IN  std_logic_vector(31 downto 0);
        -- Message routing method
        Msg_Routing => Msg_Routing,
        --  DDR read port
        ddr_mm2s_cmd_tvalid => ddr_mm2s_cmd_tvalid,
        ddr_mm2s_cmd_tready => ddr_mm2s_cmd_tready,
        ddr_mm2s_cmd_tdata => ddr_mm2s_cmd_tdata,
        ddr_mm2s_tdata => ddr_mm2s_tdata,
        ddr_mm2s_tkeep => ddr_mm2s_tkeep,
        ddr_mm2s_tlast => ddr_mm2s_tlast,
        ddr_mm2s_tvalid => ddr_mm2s_tvalid,
        ddr_mm2s_tready => ddr_mm2s_tready,

        -- Additional
        Tx_TimeOut    => Tx_TimeOut,     -- OUT std_logic;
        Tx_wb_TimeOut => Tx_wb_TimeOut,  -- OUT std_logic;
        Tx_Reset      => Tx_Reset,       -- IN  std_logic;
        localID       => localID         -- IN  std_logic_vector(15 downto 0)
        );

  -- ------------------------------------------------
  --   Unified memory space
  -- ------------------------------------------------
  Memory_Space :
    entity work.Regs_Group
      port map(
        -- Wishbone Buffer status + reset
        wb_FIFO_Rst => wb_FIFO_Rst ,     -- OUT std_logic;

        -- Registers
        Regs_WrEnA   => Regs_WrEnA ,    -- IN  std_logic;
        Regs_WrMaskA => Regs_WrMaskA ,  -- IN  std_logic_vector(2-1   downto 0);
        Regs_WrAddrA => Regs_WrAddrA ,  -- IN  std_logic_vector(16-1   downto 0);
        Regs_WrDinA  => Regs_WrDinA ,  -- IN  std_logic_vector(32-1   downto 0);

        Regs_WrEnB   => Regs_WrEnB ,    -- IN  std_logic;
        Regs_WrMaskB => Regs_WrMaskB ,  -- IN  std_logic_vector(2-1   downto 0);
        Regs_WrAddrB => Regs_WrAddrB ,  -- IN  std_logic_vector(16-1   downto 0);
        Regs_WrDinB  => Regs_WrDinB ,  -- IN  std_logic_vector(32-1   downto 0);

        Regs_RdAddr => Regs_RdAddr ,    -- IN  std_logic_vector(15 downto 0);
        Regs_RdQout => Regs_RdQout ,    -- OUT std_logic_vector(31 downto 0);

        -- Downstream DMA transferred bytes count up
        ds_DMA_Bytes_Add => ds_DMA_Bytes_Add ,  -- IN  std_logic;
        ds_DMA_Bytes     => ds_DMA_Bytes ,  -- IN  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

        -- Register values
        DMA_ds_PA         => DMA_ds_PA ,  -- OUT std_logic_vector(63 downto 0);
        DMA_ds_HA         => DMA_ds_HA ,  -- OUT std_logic_vector(63 downto 0);
        DMA_ds_BDA        => DMA_ds_BDA ,  -- OUT std_logic_vector(63 downto 0);
        DMA_ds_Length     => DMA_ds_Length ,  -- OUT std_logic_vector(31 downto 0);
        DMA_ds_Control    => DMA_ds_Control ,  -- OUT std_logic_vector(31 downto 0);
        dsDMA_BDA_eq_Null => dsDMA_BDA_eq_Null ,  -- OUT std_logic;
        DMA_ds_Status     => DMA_ds_Status ,  -- IN  std_logic_vector(31 downto 0);
        DMA_ds_Done       => DMA_ds_Done_i ,  -- IN  std_logic;
        DMA_ds_Tout       => DMA_ds_Tout ,    -- IN  std_logic;

        dsHA_is_64b  => dsHA_is_64b ,   -- OUT std_logic;
        dsBDA_is_64b => dsBDA_is_64b ,  -- OUT std_logic;

        dsLeng_Hi19b_True => dsLeng_Hi19b_True ,  -- OUT std_logic;
        dsLeng_Lo7b_True  => dsLeng_Lo7b_True ,   -- OUT std_logic;

        dsDMA_Start       => dsDMA_Start ,        -- OUT std_logic;
        dsDMA_Stop        => dsDMA_Stop ,         -- OUT std_logic;
        dsDMA_Start2      => dsDMA_Start2 ,       -- OUT std_logic;
        dsDMA_Stop2       => dsDMA_Stop2 ,        -- OUT std_logic;
        dsDMA_Channel_Rst => dsDMA_Channel_Rst ,  -- OUT std_logic;
        dsDMA_Cmd_Ack     => dsDMA_Cmd_Ack ,      -- IN  std_logic;

        -- Upstream DMA transferred bytes count up
        us_DMA_Bytes_Add => us_DMA_Bytes_Add ,  -- IN  std_logic;
        us_DMA_Bytes     => us_DMA_Bytes ,  -- IN  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

        DMA_us_PA         => DMA_us_PA ,  -- OUT std_logic_vector(63 downto 0);
        DMA_us_HA         => DMA_us_HA ,  -- OUT std_logic_vector(63 downto 0);
        DMA_us_BDA        => DMA_us_BDA ,  -- OUT std_logic_vector(63 downto 0);
        DMA_us_Length     => DMA_us_Length ,  -- OUT std_logic_vector(31 downto 0);
        DMA_us_Control    => DMA_us_Control ,  -- OUT std_logic_vector(31 downto 0);
        usDMA_BDA_eq_Null => usDMA_BDA_eq_Null ,  -- OUT std_logic;
        us_MWr_Param_Vec  => us_MWr_Param_Vec ,  -- OUT std_logic_vector(6-1   downto 0);
        DMA_us_Status     => DMA_us_Status ,  -- IN  std_logic_vector(31 downto 0);
        DMA_us_Done       => DMA_us_Done_i ,  -- IN  std_logic;
        DMA_us_Tout       => DMA_us_Tout ,    -- IN  std_logic;

        usHA_is_64b  => usHA_is_64b ,   -- OUT std_logic;
        usBDA_is_64b => usBDA_is_64b ,  -- OUT std_logic;

        usLeng_Hi19b_True => usLeng_Hi19b_True ,  -- OUT std_logic;
        usLeng_Lo7b_True  => usLeng_Lo7b_True ,   -- OUT std_logic;

        usDMA_Start       => usDMA_Start ,        -- OUT std_logic;
        usDMA_Stop        => usDMA_Stop ,         -- OUT std_logic;
        usDMA_Start2      => usDMA_Start2 ,       -- OUT std_logic;
        usDMA_Stop2       => usDMA_Stop2 ,        -- OUT std_logic;
        usDMA_Channel_Rst => usDMA_Channel_Rst ,  -- OUT std_logic;
        usDMA_Cmd_Ack     => usDMA_Cmd_Ack ,      -- IN  std_logic;

        -- Reset signals
        MRd_Channel_Rst => MRd_Channel_Rst ,  -- OUT std_logic;
        Tx_Reset        => Tx_Reset ,         -- OUT std_logic;
        ddr_reset => ddr_reset,
        ddr_axi_reset => ddr_axi_reset,

        -- to Interrupt module
        Sys_IRQ => Sys_IRQ ,            -- OUT std_logic_vector(31 downto 0);

        -- System error and info
        Tx_TimeOut      => Tx_TimeOut ,
        Tx_wb_TimeOut   => Tx_wb_TimeOut ,
        Msg_Routing     => Msg_Routing ,
        pcie_link_width => pcie_link_width ,
        cfg_dcommand    => cfg_dcommand ,
        ddr_sdram_ready => DDR_Ready,
        ddr_s2mm_err => ddr_s2mm_err,
        ddr_mm2s_err => ddr_mm2s_err,
        
        -- DDR AXI status
        ddr_s2mm_sts_tvalid => ddr_s2mm_sts_tvalid,
        ddr_s2mm_sts_tready => ddr_s2mm_sts_tready,
        ddr_s2mm_sts_tdata => ddr_s2mm_sts_tdata,
        ddr_s2mm_sts_tkeep => ddr_s2mm_sts_tkeep,
        ddr_s2mm_sts_tlast => ddr_s2mm_sts_tlast,
        ddr_mm2s_sts_tvalid => ddr_mm2s_sts_tvalid,
        ddr_mm2s_sts_tready => ddr_mm2s_sts_tready,
        ddr_mm2s_sts_tdata => ddr_mm2s_sts_tdata,
        ddr_mm2s_sts_tkeep => ddr_mm2s_sts_tkeep,
        ddr_mm2s_sts_tlast => ddr_mm2s_sts_tlast,

        -- Interrupt Generation Signals
        IG_Reset        => IG_Reset ,
        IG_Host_Clear   => IG_Host_Clear ,
        IG_Latency      => IG_Latency ,
        IG_Num_Assert   => IG_Num_Assert ,
        IG_Num_Deassert => IG_Num_Deassert ,
        IG_Asserting    => IG_Asserting ,

        -- SDRAM and Wishbone paging signals
        sdram_pg => sdram_pg_i,
        wb_pg    => wb_pg_i,

        -- Common
        user_clk    => user_clk ,       -- IN  std_logic;
        user_lnk_up => user_lnk_up ,    -- IN  std_logic,
        user_reset  => user_reset       -- IN  std_logic;
      );

end architecture Behavioral;
