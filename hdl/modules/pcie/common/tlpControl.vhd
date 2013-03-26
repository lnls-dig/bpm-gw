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
--use work.busmacro_xc4v_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tlpControl is
  port (

    --  Test pin, emulating DDR data flow discontinuity
    mbuf_UserFull : in  std_logic;
    trn_Blinker   : out std_logic;

    -- DCB protocol interface
    protocol_link_act : in  std_logic_vector(2-1 downto 0);
    protocol_rst      : out std_logic;

    -- Interrupter triggers
    DAQ_irq : in std_logic;
    CTL_irq : in std_logic;
    DLM_irq : in std_logic;

    -- Fabric side: CTL Rx
    ctl_rv : out std_logic;
    ctl_rd : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

    -- Fabric side: CTL Tx
    ctl_ttake : out std_logic;
    ctl_tv    : in  std_logic;
    ctl_td    : in  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
    ctl_tstop : out std_logic;

    ctl_reset  : out std_logic;
    ctl_status : in  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

    -- Fabric side: DLM Rx
    dlm_tv : out std_logic;
    dlm_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

    -- Fabric side: DLM Tx
    dlm_rv : in std_logic;
    dlm_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);


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

    -- SIMONE debug signals
    debug_in_1i : out std_logic_vector(31 downto 0);
    debug_in_2i : out std_logic_vector(31 downto 0);
    debug_in_3i : out std_logic_vector(31 downto 0);
    debug_in_4i : out std_logic_vector(31 downto 0);

    -- Wishbone write interface
    wb_FIFO_we    : out std_logic;
    wb_FIFO_wsof  : out std_logic;
    wb_FIFO_weof  : out std_logic;
    wb_FIFO_din   : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wb_FIFO_ow    : in  std_logic;

    wb_FIFO_data_count : in std_logic_vector(C_FIFO_DC_WIDTH downto 0);

    -- Wishbone Read interface
    wb_rdc_sof  : out std_logic;
    wb_rdc_v    : out std_logic;
    wb_rdc_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wb_rdc_full : in std_logic;

    -- Wisbbone Buffer read port
    wb_FIFO_re    : out std_logic;
    wb_FIFO_empty : in  std_logic;
    wb_FIFO_qout  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    pio_reading_status : out std_logic;
    wb_FIFO_Status     : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wb_FIFO_Rst        : out std_logic;

    H2B_FIFO_Status : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    B2H_FIFO_Status : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    Link_Buf_full : in std_logic;

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

--      DDR_rdD_sof              : IN    std_logic;
--      DDR_rdD_eof              : IN    std_logic;
--      DDR_rdDout_V             : IN    std_logic;
--      DDR_rdDout               : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- DDR payload FIFO Read Port
    DDR_FIFO_RdEn   : out std_logic;
    DDR_FIFO_Empty  : in  std_logic;
    DDR_FIFO_RdQout : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- Data generator table write
    tab_we : out std_logic_vector(2-1 downto 0);
    tab_wa : out std_logic_vector(12-1 downto 0);
    tab_wd : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    DG_is_Running : in  std_logic;
    DG_Reset      : out std_logic;
    DG_Mask       : out std_logic;

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
    -- legacy TRN signal
    trn_tsof_n        : out std_logic;

    Format_Shower : out std_logic;

    -- Interrupt Interface
    cfg_interrupt           : out std_logic;
    cfg_interrupt_rdy       : in  std_logic;
    cfg_interrupt_mmenable  : in  std_logic_vector(2 downto 0);
    cfg_interrupt_msienable : in  std_logic;
    cfg_interrupt_di        : out std_logic_vector(7 downto 0);
    cfg_interrupt_do        : in  std_logic_vector(7 downto 0);
    cfg_interrupt_assert    : out std_logic;

    -- Local signals
    pcie_link_width : in std_logic_vector(CINT_BIT_LWIDTH_IN_GSR_TOP-CINT_BIT_LWIDTH_IN_GSR_BOT downto 0);
    cfg_dcommand    : in std_logic_vector(16-1 downto 0);
    localID         : in std_logic_vector(C_ID_WIDTH-1 downto 0)
    );

end entity tlpControl;



architecture Behavioral of tlpControl is

  signal trn_lnk_up_n_i : std_logic;

---- Rx transaction control
  component rx_Transact
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

--      trn_rfc_ph_av      : IN  std_logic_vector(7 downto 0);
--      trn_rfc_pd_av      : IN  std_logic_vector(11 downto 0);
--      trn_rfc_nph_av     : IN  std_logic_vector(7 downto 0);
--      trn_rfc_npd_av     : IN  std_logic_vector(11 downto 0);
--      trn_rfc_cplh_av    : IN  std_logic_vector(7 downto 0);
--      trn_rfc_cpld_av    : IN  std_logic_vector(11 downto 0);

      -- MRd Channel
      pioCplD_Req  : out std_logic;
      pioCplD_RE   : in  std_logic;
      pioCplD_Qout : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      pio_FC_stop  : in  std_logic;

      -- MRd-downstream packet Channel
      dsMRd_Req  : out std_logic;
      dsMRd_RE   : in  std_logic;
      dsMRd_Qout : out std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- Upstream MWr/MRd Channel
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

      -- Wishbone write port
      wb_FIFO_we   : out std_logic;
      wb_FIFO_wsof : out std_logic;
      wb_FIFO_weof : out std_logic;
      wb_FIFO_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      wb_FIFO_data_count : in  std_logic_vector(C_FIFO_DC_WIDTH downto 0);
      wb_FIFO_Empty      : in  std_logic;
      wb_FIFO_Reading    : in  std_logic;
      pio_reading_status : out std_logic;

      -- Registers Write Port
      Regs_WrEn0   : out std_logic;
      Regs_WrMask0 : out std_logic_vector(2-1 downto 0);
      Regs_WrAddr0 : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin0  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      Regs_WrEn1   : out std_logic;
      Regs_WrMask1 : out std_logic_vector(2-1 downto 0);
      Regs_WrAddr1 : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDin1  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

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

      dsDMA_Start       : in  std_logic;
      dsDMA_Stop        : in  std_logic;
      dsDMA_Start2      : in  std_logic;
      dsDMA_Stop2       : in  std_logic;
      dsDMA_Channel_Rst : in  std_logic;
      dsDMA_Cmd_Ack     : out std_logic;

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

      usDMA_Start       : in  std_logic;
      usDMA_Stop        : in  std_logic;
      usDMA_Start2      : in  std_logic;
      usDMA_Stop2       : in  std_logic;
      usDMA_Channel_Rst : in  std_logic;
      usDMA_Cmd_Ack     : out std_logic;

      MRd_Channel_Rst : in std_logic;

      Sys_IRQ : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);

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

      Link_Buf_full : in std_logic;

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
      cfg_dcommand : in std_logic_vector(16-1 downto 0);
      localID      : in std_logic_vector(C_ID_WIDTH-1 downto 0)
      );
  end component rx_Transact;

  -- Downstream DMA transferred bytes count up
  signal ds_DMA_Bytes_Add : std_logic;
  signal ds_DMA_Bytes     : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);


---- Tx transaction control
  component tx_Transact
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
      trn_tsof_n        : out std_logic;

      -- Upstream DMA transferred bytes count up
      us_DMA_Bytes_Add : out std_logic;
      us_DMA_Bytes     : out std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      -- MRd Channel
      pioCplD_Req  : in  std_logic;
      pioCplD_RE   : out std_logic;
      pioCplD_Qout : in  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      pio_FC_stop  : out std_logic;


      -- MRd-downstream packet Channel
      dsMRd_Req  : in  std_logic;
      dsMRd_RE   : out std_logic;
      dsMRd_Qout : in  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);


      -- Upstream MWr Channel
      usTlp_Req   : in  std_logic;
      usTlp_RE    : out std_logic;
      usTlp_Qout  : in  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
      us_FC_stop  : out std_logic;
      us_Last_sof : out std_logic;
      us_Last_eof : out std_logic;

      -- Irpt Channel
      Irpt_Req  : in  std_logic;
      Irpt_RE   : out std_logic;
      Irpt_Qout : in  std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

      -- Wishbone Read interface
      wb_rdc_sof  : out std_logic;
      wb_rdc_v    : out std_logic;
      wb_rdc_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wb_rdc_full : in std_logic;

      -- Wisbbone Buffer read port
      wb_FIFO_re    : out std_logic;
      wb_FIFO_empty : in  std_logic;
      wb_FIFO_qout  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- With Rx port
      Regs_RdAddr : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_RdQout : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Message routing method
      Msg_Routing : in std_logic_vector(C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT downto 0);

      --  DDR read port
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

      -- Additional
      Tx_TimeOut    : out std_logic;
      Tx_wb_TimeOut : out std_logic;
      Format_Shower : out std_logic;
      Tx_Reset      : in  std_logic;
      mbuf_UserFull : in  std_logic;
      localID       : in  std_logic_vector(C_ID_WIDTH-1 downto 0)
      );
  end component tx_Transact;

  -- Upstream DMA transferred bytes count up
  signal us_DMA_Bytes_Add : std_logic;
  signal us_DMA_Bytes     : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

  -- ------------------------------------------------
  -- United memory space consisting of registers.
  --
  component Regs_Group
    port (

      -- DCB protocol interface
      protocol_link_act : in  std_logic_vector(2-1 downto 0);
      protocol_rst      : out std_logic;

      -- Fabric side: CTL Rx
      ctl_rv : out std_logic;
      ctl_rd : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

      -- Fabric side: CTL Tx
      ctl_ttake : out std_logic;
      ctl_tv    : in  std_logic;
      ctl_td    : in  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
      ctl_tstop : out std_logic;

      ctl_reset  : out std_logic;
      ctl_status : in  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

      -- Fabric side: DLM Rx
      dlm_tv : out std_logic;
      dlm_td : out std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

      -- Fabric side: DLM Tx
      dlm_rv : in std_logic;
      dlm_rd : in std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

      -- Wishbone Buffer status
      wb_FIFO_Status  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      wb_FIFO_Rst     : out std_logic;
      H2B_FIFO_Status : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      B2H_FIFO_Status : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);


      -- Register Write
      Regs_WrEnA   : in std_logic;
      Regs_WrMaskA : in std_logic_vector(2-1 downto 0);
      Regs_WrAddrA : in std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDinA  : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      Regs_WrEnB   : in std_logic;
      Regs_WrMaskB : in std_logic_vector(2-1 downto 0);
      Regs_WrAddrB : in std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_WrDinB  : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      Regs_RdAddr : in  std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_RdQout : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Downstream DMA transferred bytes count up
      ds_DMA_Bytes_Add : in std_logic;
      ds_DMA_Bytes     : in std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      -- Register Values
      DMA_ds_PA         : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_HA         : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_BDA        : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Length     : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Control    : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      dsDMA_BDA_eq_Null : out std_logic;
      DMA_ds_Status     : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_ds_Done       : in  std_logic;
--      DMA_ds_Busy              : IN  std_logic;
      DMA_ds_Tout       : in  std_logic;

      -- Calculation in advance, for better timing
      dsHA_is_64b  : out std_logic;
      dsBDA_is_64b : out std_logic;

      -- Calculation in advance, for better timing
      dsLeng_Hi19b_True : out std_logic;
      dsLeng_Lo7b_True  : out std_logic;

      dsDMA_Start       : out std_logic;
      dsDMA_Stop        : out std_logic;
      dsDMA_Start2      : out std_logic;
      dsDMA_Stop2       : out std_logic;
      dsDMA_Channel_Rst : out std_logic;
      dsDMA_Cmd_Ack     : in  std_logic;

      -- Upstream DMA transferred bytes count up
      us_DMA_Bytes_Add : in std_logic;
      us_DMA_Bytes     : in std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

      DMA_us_PA         : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_HA         : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_BDA        : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Length     : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Control    : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      usDMA_BDA_eq_Null : out std_logic;
      us_MWr_Param_Vec  : out std_logic_vector(6-1 downto 0);
      DMA_us_Status     : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_us_Done       : in  std_logic;
--      DMA_us_Busy              : IN  std_logic;
      DMA_us_Tout       : in  std_logic;

      -- Calculation in advance, for better timing
      usHA_is_64b  : out std_logic;
      usBDA_is_64b : out std_logic;

      -- Calculation in advance, for better timing
      usLeng_Hi19b_True : out std_logic;
      usLeng_Lo7b_True  : out std_logic;

      usDMA_Start       : out std_logic;
      usDMA_Stop        : out std_logic;
      usDMA_Start2      : out std_logic;
      usDMA_Stop2       : out std_logic;
      usDMA_Channel_Rst : out std_logic;
      usDMA_Cmd_Ack     : in  std_logic;

      -- Reset signals
      MRd_Channel_Rst : out std_logic;
      Tx_Reset        : out std_logic;

      -- to Interrupt module
      Sys_IRQ : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DAQ_irq : in  std_logic;
      CTL_irq : in  std_logic;
      DLM_irq : in  std_logic;

      -- System error and info
      wb_FIFO_ow      : in  std_logic;
      Tx_TimeOut      : in  std_logic;
      Tx_wb_TimeOut   : in  std_logic;
      Msg_Routing     : out std_logic_vector(C_GCR_MSG_ROUT_BIT_TOP-C_GCR_MSG_ROUT_BIT_BOT downto 0);
      pcie_link_width : in  std_logic_vector(CINT_BIT_LWIDTH_IN_GSR_TOP-CINT_BIT_LWIDTH_IN_GSR_BOT downto 0);
      cfg_dcommand    : in  std_logic_vector(16-1 downto 0);

      -- Interrupt Generation Signals
      IG_Reset        : out std_logic;
      IG_Host_Clear   : out std_logic;
      IG_Latency      : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Num_Assert   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Num_Deassert : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      IG_Asserting    : in  std_logic;

      -- Data generator control
      DG_is_Running : in  std_logic;
      DG_Reset      : out std_logic;
      DG_Mask       : out std_logic;

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

      -- Common interface
      user_clk    : in std_logic;
      user_lnk_up : in std_logic;
      user_reset  : in std_logic
      );
  end component Regs_Group;


  -- DDR write port
  signal DDR_wr_sof_A   : std_logic;
  signal DDR_wr_eof_A   : std_logic;
  signal DDR_wr_v_A     : std_logic;
  signal DDR_wr_FA_A    : std_logic;
  signal DDR_wr_Shift_A : std_logic;
  signal DDR_wr_Mask_A  : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din_A   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal DDR_wr_sof_B   : std_logic;
  signal DDR_wr_eof_B   : std_logic;
  signal DDR_wr_v_B     : std_logic;
  signal DDR_wr_FA_B    : std_logic;
  signal DDR_wr_Shift_B : std_logic;
  signal DDR_wr_Mask_B  : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din_B   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal DDR_wr_sof_i   : std_logic;
  signal DDR_wr_eof_i   : std_logic;
  signal DDR_wr_v_i     : std_logic;
  signal DDR_wr_FA_i    : std_logic;
  signal DDR_wr_Shift_i : std_logic;
  signal DDR_wr_Mask_i  : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din_i   : std_logic_vector(C_DBUS_WIDTH-1 downto 0)
 := (others => '0');

  signal DDR_wr_sof_A_r1   : std_logic;
  signal DDR_wr_eof_A_r1   : std_logic;
  signal DDR_wr_v_A_r1     : std_logic;
  signal DDR_wr_FA_A_r1    : std_logic;
  signal DDR_wr_Shift_A_r1 : std_logic;
  signal DDR_wr_Mask_A_r1  : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din_A_r1   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal DDR_wr_sof_A_r2   : std_logic;
  signal DDR_wr_eof_A_r2   : std_logic;
  signal DDR_wr_v_A_r2     : std_logic;
  signal DDR_wr_FA_A_r2    : std_logic;
  signal DDR_wr_Shift_A_r2 : std_logic;
  signal DDR_wr_Mask_A_r2  : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din_A_r2   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal DDR_wr_sof_A_r3   : std_logic;
  signal DDR_wr_eof_A_r3   : std_logic;
  signal DDR_wr_v_A_r3     : std_logic;
  signal DDR_wr_FA_A_r3    : std_logic;
  signal DDR_wr_Shift_A_r3 : std_logic;
  signal DDR_wr_Mask_A_r3  : std_logic_vector(2-1 downto 0);
  signal DDR_wr_din_A_r3   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- eb FIFO read enable
  signal wb_FIFO_RdEn_i : std_logic;

  -- Flow control signals
  signal pio_FC_stop : std_logic;
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
  signal DMA_ds_Busy_led_i : std_logic;
  signal cnt_ds_Busy       : std_logic_vector(20-1 downto 0);
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
  signal DMA_us_Busy_led_i : std_logic;
  signal cnt_us_Busy       : std_logic_vector(20-1 downto 0);
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

  -- Test blinker
  signal trn_Blinker_cnt : std_logic_vector(31 downto 0) := (others => '0');

begin

  DDR_wr_v     <= DDR_wr_v_i;
  DDR_wr_sof   <= DDR_wr_sof_i;
  DDR_wr_eof   <= DDR_wr_eof_i;
  DDR_wr_FA    <= DDR_wr_FA_i;
  DDR_wr_Shift <= DDR_wr_Shift_i;
  DDR_wr_Mask  <= DDR_wr_Mask_i;
  DDR_wr_din   <= DDR_wr_din_i;

  trn_Blinker <= trn_Blinker_cnt(26);

  DMA_us_Busy     <= DMA_us_Busy_i;
  DMA_us_Busy_LED <= DMA_us_Busy_led_i;
  DMA_ds_Busy     <= DMA_ds_Busy_i;
  DMA_ds_Busy_LED <= DMA_ds_Busy_led_i;

  wb_FIFO_re <= wb_FIFO_RdEn_i;

  DMA_ds_Done <= DMA_ds_Done_i;
  DMA_us_Done <= DMA_us_Done_i;

  trn_lnk_up_n_i <= not(user_lnk_up);

  -- -------------------------------------------------------
  -- Delay DDR write port A for 2 cycles
  --
  SynDelay_DDR_write_PIO :
  process (user_clk)
  begin
    if user_clk'event and user_clk = '1' then
      DDR_wr_v_A_r1     <= DDR_wr_v_A;
      DDR_wr_sof_A_r1   <= DDR_wr_sof_A;
      DDR_wr_eof_A_r1   <= DDR_wr_eof_A;
      DDR_wr_FA_A_r1    <= DDR_wr_FA_A;
      DDR_wr_Shift_A_r1 <= DDR_wr_Shift_A;
      DDR_wr_Mask_A_r1  <= DDR_wr_Mask_A;
      DDR_wr_din_A_r1   <= DDR_wr_din_A;

      DDR_wr_v_A_r2     <= DDR_wr_v_A_r1;
      DDR_wr_sof_A_r2   <= DDR_wr_sof_A_r1;
      DDR_wr_eof_A_r2   <= DDR_wr_eof_A_r1;
      DDR_wr_FA_A_r2    <= DDR_wr_FA_A_r1;
      DDR_wr_Shift_A_r2 <= DDR_wr_Shift_A_r1;
      DDR_wr_Mask_A_r2  <= DDR_wr_Mask_A_r1;
      DDR_wr_din_A_r2   <= DDR_wr_din_A_r1;

      DDR_wr_v_A_r3     <= DDR_wr_v_A_r2;
      DDR_wr_sof_A_r3   <= DDR_wr_sof_A_r2;
      DDR_wr_eof_A_r3   <= DDR_wr_eof_A_r2;
      DDR_wr_FA_A_r3    <= DDR_wr_FA_A_r2;
      DDR_wr_Shift_A_r3 <= DDR_wr_Shift_A_r2;
      DDR_wr_Mask_A_r3  <= DDR_wr_Mask_A_r2;
      DDR_wr_din_A_r3   <= DDR_wr_din_A_r2;
    end if;
  end process;


  -- -------------------------------------------------------
  -- DDR writes: DDR Writes
  --
  SynProc_DDR_write :
  process (user_clk)
  begin
    if user_clk'event and user_clk = '1' then
      DDR_wr_v_i <= DDR_wr_v_A_r3 or DDR_wr_v_B;
      if DDR_wr_v_A_r3 = '1' then
        DDR_wr_sof_i   <= DDR_wr_sof_A_r3;
        DDR_wr_eof_i   <= DDR_wr_eof_A_r3;
        DDR_wr_FA_i    <= DDR_wr_FA_A_r3;
        DDR_wr_Shift_i <= DDR_wr_Shift_A_r3;
        DDR_wr_Mask_i  <= DDR_wr_Mask_A_r3;
        DDR_wr_din_i   <= DDR_wr_din_A_r3;
      elsif DDR_wr_v_B = '1' then
        DDR_wr_sof_i   <= DDR_wr_sof_B;
        DDR_wr_eof_i   <= DDR_wr_eof_B;
        DDR_wr_FA_i    <= DDR_wr_FA_B;
        DDR_wr_Shift_i <= DDR_wr_Shift_B;
        DDR_wr_Mask_i  <= DDR_wr_Mask_B;
        DDR_wr_din_i   <= DDR_wr_din_B;
      else
        DDR_wr_sof_i   <= DDR_wr_sof_i;
        DDR_wr_eof_i   <= DDR_wr_eof_i;
        DDR_wr_FA_i    <= DDR_wr_FA_i;
        DDR_wr_Shift_i <= DDR_wr_Shift_i;
        DDR_wr_Mask_i  <= DDR_wr_Mask_i;
        DDR_wr_din_i   <= DDR_wr_din_i;
      end if;
    end if;
  end process;

  -- -------------------------------------------------------
  -- trn blink
  --
  SynProc_trn_blinker :
  process (user_clk)
  begin
    if user_clk'event and user_clk = '1' then
      trn_Blinker_cnt <= trn_Blinker_cnt + '1';
    end if;
  end process;

  -- -------------------------------------------------------
  -- DMA upstream Busy display
  --
  SynProc_DMA_us_Busy_LED :
  process (user_clk, DMA_us_Busy_i)
  begin
    if DMA_us_Busy_i = '1' then
      DMA_us_Busy_led_i <= '1';
      cnt_us_Busy       <= (others => '0');
    elsif user_clk'event and user_clk = '1' then
      if cnt_us_Busy = X"80000" then
        DMA_us_Busy_led_i <= '0';
        cnt_us_Busy       <= cnt_us_Busy;
      else
        DMA_us_Busy_led_i <= DMA_us_Busy_led_i;
        cnt_us_Busy       <= cnt_us_Busy + '1';
      end if;
    end if;
  end process;

  -- -------------------------------------------------------
  -- DMA downstream Busy display
  --
  SynProc_DMA_ds_Busy_LED :
  process (user_clk, DMA_ds_Busy_i)
  begin
    if DMA_ds_Busy_i = '1' then
      DMA_ds_Busy_led_i <= '1';
      cnt_ds_Busy       <= (others => '0');
    elsif user_clk'event and user_clk = '1' then
      if cnt_ds_Busy = X"FFFFF" then
        DMA_ds_Busy_led_i <= '0';
        cnt_ds_Busy       <= cnt_ds_Busy;
      else
        DMA_ds_Busy_led_i <= DMA_ds_Busy_led_i;
        cnt_ds_Busy       <= cnt_ds_Busy + '1';
      end if;
    end if;
  end process;

--    DDR_wr_v     <=  DDR_wr_v_A or DDR_wr_v_B;
--    DDR_wr_sof   <=  DDR_wr_sof_A  when DDR_wr_v_A='1'  else  DDR_wr_sof_B;
--    DDR_wr_eof   <=  DDR_wr_eof_A  when DDR_wr_v_A='1'  else  DDR_wr_eof_B;
--    DDR_wr_FA    <=  DDR_wr_FA_A   when DDR_wr_v_A='1'  else  DDR_wr_FA_B;
--    DDR_wr_din   <=  DDR_wr_din_A  when DDR_wr_v_A='1'  else  DDR_wr_din_B;


  -- Rx TLP interface
  rx_Itf :
    rx_Transact
      port map(
        -- Common ports
        user_clk    => user_clk,        -- IN  std_logic,
        user_reset  => trn_lnk_up_n_i ,  -- user_reset,         -- IN  std_logic,
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
        pio_FC_stop  => pio_FC_stop,    -- IN  std_logic;

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


        -- Interrupt Interface
        cfg_interrupt           => cfg_interrupt ,     -- OUT std_logic;
        cfg_interrupt_rdy       => cfg_interrupt_rdy ,       -- IN std_logic;
        cfg_interrupt_mmenable  => cfg_interrupt_mmenable ,  -- IN std_logic_VECTOR(2 downto 0);
        cfg_interrupt_msienable => cfg_interrupt_msienable ,  -- IN std_logic;
        cfg_interrupt_di        => cfg_interrupt_di ,  -- OUT std_logic_VECTOR(7 downto 0);
        cfg_interrupt_do        => cfg_interrupt_do ,  -- IN std_logic_VECTOR(7 downto 0);
        cfg_interrupt_assert    => cfg_interrupt_assert ,    -- OUT std_logic;

        -- Wishbone write port
        wb_FIFO_we   => wb_FIFO_we ,    -- OUT std_logic;
        wb_FIFO_wsof => wb_FIFO_wsof ,  -- OUT std_logic;
        wb_FIFO_weof => wb_FIFO_weof ,  -- OUT std_logic;
        wb_FIFO_din  => wb_FIFO_din ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        wb_FIFO_data_count => wb_FIFO_data_count,  -- IN  std_logic_vector(C_FIFO_DC_WIDTH downto 0);
        wb_FIFO_Empty      => wb_FIFO_Empty ,      -- IN  std_logic;
        wb_FIFO_Reading    => wb_FIFO_RdEn_i ,     -- IN  std_logic;
        pio_reading_status => pio_reading_status ,  -- OUT std_logic;

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
        DDR_wr_sof_A   => DDR_wr_sof_A ,  -- OUT   std_logic;
        DDR_wr_eof_A   => DDR_wr_eof_A ,  -- OUT   std_logic;
        DDR_wr_v_A     => DDR_wr_v_A ,  -- OUT   std_logic;
        DDR_wr_FA_A    => DDR_wr_FA_A ,   -- OUT   std_logic;
        DDR_wr_Shift_A => DDR_wr_Shift_A ,  -- OUT   std_logic;
        DDR_wr_Mask_A  => DDR_wr_Mask_A ,  -- OUT   std_logic_vector(2-1 downto 0);
        DDR_wr_din_A   => DDR_wr_din_A ,  -- OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        DDR_wr_sof_B   => DDR_wr_sof_B ,  -- OUT   std_logic;
        DDR_wr_eof_B   => DDR_wr_eof_B ,  -- OUT   std_logic;
        DDR_wr_v_B     => DDR_wr_v_B ,  -- OUT   std_logic;
        DDR_wr_FA_B    => DDR_wr_FA_B ,   -- OUT   std_logic;
        DDR_wr_Shift_B => DDR_wr_Shift_B ,  -- OUT   std_logic;
        DDR_wr_Mask_B  => DDR_wr_Mask_B ,  -- OUT   std_logic_vector(2-1 downto 0);
        DDR_wr_din_B   => DDR_wr_din_B ,  -- OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        DDR_wr_full => DDR_wr_full ,    -- IN    std_logic;


        Link_Buf_full => Link_Buf_full ,  -- IN    std_logic;


        -- Data generator table write
        tab_we => tab_we ,              -- OUT std_logic_vector(2-1 downto 0);
        tab_wa => tab_wa ,              -- OUT std_logic_vector(12-1 downto 0);
        tab_wd => tab_wd ,  -- OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);

        -- Additional
        cfg_dcommand => cfg_dcommand ,  -- IN  std_logic_vector(15 downto 0)
        localID      => localID         -- IN  std_logic_vector(15 downto 0)
        );

  -- Tx TLP interface
  tx_Itf :
    tx_Transact
      port map(
        -- Common ports
        user_clk    => user_clk,        -- IN  std_logic,
        user_reset  => trn_lnk_up_n_i ,  -- user_reset,         -- IN  std_logic,
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
        trn_tsof_n        => trn_tsof_n,       -- OUT std_logic,

        -- Upstream DMA transferred bytes count up
        us_DMA_Bytes_Add => us_DMA_Bytes_Add,  -- OUT std_logic;
        us_DMA_Bytes     => us_DMA_Bytes,  -- OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+2 downto 0);

        -- MRd Channel
        pioCplD_Req  => pioCplD_Req,    -- IN  std_logic;
        pioCplD_RE   => pioCplD_RE,     -- OUT std_logic;
        pioCplD_Qout => pioCplD_Qout,   -- IN  std_logic_vector(96 downto 0);
        pio_FC_stop  => pio_FC_stop,    -- OUT std_logic;

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
        DDR_rdc_sof   => DDR_rdc_sof ,  -- OUT   std_logic;
        DDR_rdc_eof   => DDR_rdc_eof ,  -- OUT   std_logic;
        DDR_rdc_v     => DDR_rdc_v ,    -- OUT   std_logic;
        DDR_rdc_FA    => DDR_rdc_FA ,   -- OUT   std_logic;
        DDR_rdc_Shift => DDR_rdc_Shift ,  -- OUT   std_logic;
        DDR_rdc_din   => DDR_rdc_din ,  -- OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        DDR_rdc_full  => DDR_rdc_full ,   -- IN    std_logic;

        -- DDR payload FIFO Read Port
        DDR_FIFO_RdEn   => DDR_FIFO_RdEn ,    -- OUT std_logic;
        DDR_FIFO_Empty  => DDR_FIFO_Empty ,   -- IN  std_logic;
        DDR_FIFO_RdQout => DDR_FIFO_RdQout ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--      DDR_rdD_sof         =>  DDR_rdD_sof       ,  -- IN    std_logic;
--      DDR_rdD_eof         =>  DDR_rdD_eof       ,  -- IN    std_logic;
--      DDR_rdDout_V        =>  DDR_rdDout_V      ,  -- IN    std_logic;
--      DDR_rdDout          =>  DDR_rdDout        ,  -- IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);


        -- Additional
        Tx_TimeOut    => Tx_TimeOut,     -- OUT std_logic;
        Tx_wb_TimeOut => Tx_wb_TimeOut,  -- OUT std_logic;
        Format_Shower => Format_Shower,  -- OUT std_logic;
        Tx_Reset      => Tx_Reset,       -- IN  std_logic;
        mbuf_UserFull => mbuf_UserFull,  -- IN  std_logic;
        localID       => localID         -- IN  std_logic_vector(15 downto 0)
        );

  -- ------------------------------------------------
  --   Unified memory space
  -- ------------------------------------------------
  Memory_Space :
    Regs_Group
      port map(

        -- DCB protocol interface
        protocol_link_act => protocol_link_act ,  -- IN  std_logic_vector(2-1 downto 0);
        protocol_rst      => protocol_rst ,       -- OUT std_logic;

        -- Fabric side: CTL Rx
        ctl_rv => ctl_rv ,              -- OUT std_logic;
        ctl_rd => ctl_rd ,  -- OUT std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

        -- Fabric side: CTL Tx
        ctl_ttake => ctl_ttake ,        -- OUT std_logic;
        ctl_tv    => ctl_tv ,           -- IN  std_logic;
        ctl_td    => ctl_td ,  -- IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);
        ctl_tstop => ctl_tstop ,        -- OUT std_logic;

        ctl_reset  => ctl_reset ,       -- OUT std_logic;
        ctl_status => ctl_status ,  -- IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

        -- Fabric side: DLM Rx
        dlm_tv => dlm_tv ,              -- OUT std_logic;
        dlm_td => dlm_td ,  -- OUT std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

        -- Fabric side: DLM Tx
        dlm_rv => dlm_rv ,              -- IN  std_logic;
        dlm_rd => dlm_rd ,  -- IN  std_logic_vector(C_DBUS_WIDTH/2-1 downto 0);

        -- Wishbone Buffer status + reset
        wb_FIFO_Status  => wb_FIFO_Status ,  -- IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
        wb_FIFO_Rst     => wb_FIFO_Rst ,     -- OUT std_logic;
        H2B_FIFO_Status => H2B_FIFO_Status ,
        B2H_FIFO_Status => B2H_FIFO_Status ,

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

        -- to Interrupt module
        Sys_IRQ => Sys_IRQ ,            -- OUT std_logic_vector(31 downto 0);
        DAQ_irq => DAQ_irq ,            -- IN  std_logic;
        CTL_irq => CTL_irq ,            -- IN  std_logic;
        DLM_irq => DLM_irq ,            -- IN  std_logic;

        -- System error and info
        wb_FIFO_ow      => wb_FIFO_ow ,
        Tx_TimeOut      => Tx_TimeOut ,
        Tx_wb_TimeOut   => Tx_wb_TimeOut ,
        Msg_Routing     => Msg_Routing ,
        pcie_link_width => pcie_link_width ,
        cfg_dcommand    => cfg_dcommand ,

        -- Interrupt Generation Signals
        IG_Reset        => IG_Reset ,
        IG_Host_Clear   => IG_Host_Clear ,
        IG_Latency      => IG_Latency ,
        IG_Num_Assert   => IG_Num_Assert ,
        IG_Num_Deassert => IG_Num_Deassert ,
        IG_Asserting    => IG_Asserting ,

        -- Data generator control
        DG_is_Running => DG_is_Running ,
        DG_Reset      => DG_Reset ,
        DG_Mask       => DG_Mask ,

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

        -- Common
        user_clk    => user_clk ,       -- IN  std_logic;
        user_lnk_up => user_lnk_up ,    -- IN  std_logic,
        user_reset  => user_reset       -- IN  std_logic;
        );


end architecture Behavioral;
