----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name:    tx_Mem_Reader - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
--
-- Revision 1.00 - first release. 20.03.2008
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

entity tx_Mem_Reader is
  port (
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
    -- Wishbone Read interface
    wb_rdc_sof  : out std_logic;
    wb_rdc_v    : out std_logic;
    wb_rdc_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wb_rdc_full : in std_logic;
    -- Wisbbone Buffer read port
    wb_FIFO_re    : out std_logic;
    wb_FIFO_empty : in  std_logic;
    wb_FIFO_qout  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    -- Register Read interface
    Regs_RdAddr : out std_logic_vector(C_EP_AWIDTH-1 downto 0);
    Regs_RdQout : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    -- Read Command interface
    RdNumber        : in  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
    RdNumber_eq_One : in  std_logic;
    RdNumber_eq_Two : in  std_logic;
    StartAddr       : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    Shift_1st_QWord : in  std_logic;
    is_CplD         : in  std_logic;
    BAR_value       : in  std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
    RdCmd_Req       : in  std_logic;
    RdCmd_Ack       : out std_logic;
    -- Output port of the memory buffer
    mbuf_Din      : out std_logic_vector(C_DBUS_WIDTH*9/8-1 downto 0);
    mbuf_WE       : out std_logic;
    mbuf_Full     : in  std_logic;
    mbuf_aFull    : in  std_logic;

    -- Common ports
    Tx_TimeOut    : out std_logic;
    Tx_wb_TimeOut : out std_logic;
    mReader_Rst_n : in  std_logic;
    user_clk      : in  std_logic
    );

end tx_Mem_Reader;


architecture Behavioral of tx_Mem_Reader is

  type mReaderStates is (St_mR_Idle,      -- Memory reader Idle
                         St_mR_CmdLatch,  -- Capture the read command
                         St_mR_Transfer,  -- Acknowlege the command request
                         St_mR_wb_A,      -- Wishbone access state A
                         St_mR_DDR_A,     -- DDR access state A
                         St_mR_DDR_C,     -- DDR access state C
                         St_mR_Last       -- Last word is reached
                         );
  -- State variables
  signal TxMReader_State : mReaderStates;

  type t_64b_array is array (natural range<>) of std_logic_vector(63 downto 0);
  -- DDR Read Interface
  signal ddr_mm2s_cmd_tvalid_i : STD_LOGIC := '0';
  signal ddr_mm2s_cmd_wtt : std_logic_vector(20 downto 0) := (others => '0');
  signal ddr_mm2s_cmd_dsa : std_logic_vector(5 downto 0) := (others => '0');
  signal ddr_mm2s_cmd_eof : std_logic := '0';
  signal ddr_mm2s_cmd_drr : std_logic := '0';
  signal ddr_mm2s_cmd_saddr : std_logic_vector(31 downto 0) := (others => '0');
  
  -- DDR payload FIFO Read Port
  signal ddr_mm2s_tdata_r: t_64b_array(1 downto 0);
  signal ddr_mm2s_tready_i : STD_LOGIC;
  signal ddr_mm2s_tlast_r : std_logic_vector(1 downto 0);
  signal ddr_mm2s_tready_r : std_logic_vector(1 downto 0);
  
  signal ddr_FIFO_Hit          : std_logic;
  signal ddr_FIFO_Write_mbuf   : std_logic;
  signal ddr_FIFO_Write_mbuf_r : std_logic_vector(1 downto 0);

  -- Register read address
  signal Regs_RdAddr_i      : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal Regs_RdEn          : std_logic;
  signal Regs_Hit           : std_logic;
  signal Regs_Write_mbuf_r : std_logic_vector(2 downto 0);

  -- Wishbone interface
  signal wb_rdc_sof_i              : std_logic;
  signal wb_rdc_v_i                : std_logic;
  signal wb_rdc_din_i              : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wb_rdc_full_i             : std_logic;
  signal wb_FIFO_Hit               : std_logic;
  signal wb_FIFO_Write_mbuf_r      : std_logic_vector(2 downto 0);
  signal wb_FIFO_re_i              : std_logic;
  signal wb_FIFO_RdEn_Mask_rise    : std_logic;
  signal wb_FIFO_RdEn_Mask_rise_r1 : std_logic;
  signal wb_FIFO_RdEn_Mask_rise_r2 : std_logic;
  signal wb_FIFO_RdEn_Mask_rise_r3 : std_logic;
  signal wb_FIFO_RdEn_Mask         : std_logic;
  signal wb_FIFO_RdEn_Mask_r1      : std_logic;
  signal wb_FIFO_RdEn_Mask_r2      : std_logic;
  signal wb_FIFO_Rd_1Dw            : std_logic;
  signal wb_FIFO_qout_r1           : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal wb_FIFO_qout_shift        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Memory data outputs
  signal wb_FIFO_Dout_wire : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_Dout_wire     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal Regs_RdQout_wire  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal mbuf_Din_wire_OR  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Output port of the memory buffer
  signal mbuf_Din_i      : std_logic_vector(C_DBUS_WIDTH*9/8-1 downto 0);
  signal mbuf_WE_i       : std_logic;
  signal mbuf_Full_i     : std_logic;
  signal mbuf_aFull_i    : std_logic;
  signal mbuf_aFull_r1   : std_logic;

  -- Read command request and acknowledge
  signal RdCmd_Req_i : std_logic;
  signal RdCmd_Ack_i : std_logic;

  signal Shift_1st_QWord_k : std_logic;
  signal is_CplD_k         : std_logic;
  signal may_be_MWr_k      : std_logic;

  signal regs_Rd_Counter     : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
  signal regs_Rd_Cntr_eq_One : std_logic;
  signal regs_Rd_Cntr_eq_Two : std_logic;
  signal DDR_Rd_Counter      : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
  signal DDR_Rd_Cntr_eq_One  : std_logic;

  signal wb_FIFO_Rd_Counter     : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
  signal wb_FIFO_Rd_Cntr_eq_Two : std_logic;

  signal Address_var  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal Address_step : std_logic_vector(4-1 downto 0);
  signal TxTLP_eof_n  : std_logic;
  signal TxTLP_eof_n_r1 : std_logic;

  signal TimeOut_Counter : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal TO_Cnt_Rst      : std_logic;
  signal Tx_TimeOut_i    : std_logic;
  signal Tx_wb_TimeOut_i : std_logic := '0';


begin

  -- read command REQ + ACK
  RdCmd_Req_i <= RdCmd_Req;
  RdCmd_Ack   <= RdCmd_Ack_i;

  -- Time out signal out
  Tx_TimeOut    <= Tx_TimeOut_i;
  Tx_wb_TimeOut <= Tx_wb_TimeOut_i;

------------------------------------------------------------
---             Memory read control
------------------------------------------------------------

  -- Wishbone Buffer read
  wb_FIFO_re    <= wb_FIFO_re_i;
  wb_rdc_sof    <= wb_rdc_sof_i;
  wb_rdc_v      <= wb_rdc_v_i;
  wb_rdc_din    <= wb_rdc_din_i;
  wb_rdc_full_i <= wb_rdc_full;

  -- DDR FIFO Read
  ddr_mm2s_cmd_tvalid <= ddr_mm2s_cmd_tvalid_i;
  ddr_mm2s_cmd_tdata(22 downto 0) <= ddr_mm2s_cmd_wtt & "00";
  ddr_mm2s_cmd_tdata(23) <= '1'; --ddr_mm2s_cmd_type;
  ddr_mm2s_cmd_tdata(29 downto 24) <= ddr_mm2s_cmd_dsa;
  ddr_mm2s_cmd_tdata(30) <= ddr_mm2s_cmd_eof;
  ddr_mm2s_cmd_tdata(31) <= ddr_mm2s_cmd_drr;
  ddr_mm2s_cmd_tdata(63 downto 32) <= ddr_mm2s_cmd_saddr;
  ddr_mm2s_cmd_tdata(67 downto 64) <= "0000"; --tag
  ddr_mm2s_cmd_tdata(71 downto 68) <= (others => '0'); 

  ddr_mm2s_tready <= ddr_mm2s_tready_i;

  -- Register address for read
  Regs_RdAddr <= Regs_RdAddr_i;

  -- Memory buffer write port
  mbuf_Din     <= mbuf_Din_i;
  mbuf_WE      <= mbuf_WE_i;
  mbuf_Full_i  <= mbuf_Full;
  mbuf_aFull_i <= mbuf_aFull;
  --
  Regs_RdAddr_i <= Address_var(C_EP_AWIDTH-1 downto 0);

  delay_ddr_mm2s:
  process(user_clk)
  begin
    if rising_edge(user_clk) then
      ddr_mm2s_tdata_r(0) <= ddr_mm2s_tdata;
      ddr_mm2s_tdata_r(1) <= ddr_mm2s_tdata_r(0);
      ddr_mm2s_tlast_r(0) <= ddr_mm2s_tlast;
      ddr_mm2s_tlast_r(1) <= ddr_mm2s_tlast_r(0);
      ddr_mm2s_tready_r(0) <= ddr_mm2s_tready_i;
      ddr_mm2s_tready_r(1) <= ddr_mm2s_tready_r(0);
    end if;
  end process;
-----------------------------------------------------
-- Synchronous Delay: mbuf_aFull
--
  Synchron_Delay_mbuf_aFull :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      mbuf_aFull_r1 <= mbuf_aFull_i or mbuf_Full_i;
    end if;
  end process;

-- ---------------------------------------------------
-- State Machine: Tx Memory read control
--
  mR_FSM_Control :
  process (user_clk)
  begin

    if rising_edge(user_clk) then
      if mReader_Rst_n = '0' then
        ddr_mm2s_cmd_tvalid_i <= '0';
        ddr_mm2s_tready_i <= '0';
  
        wb_rdc_sof_i <= '0';
        wb_rdc_v_i   <= '0';
        wb_rdc_din_i <= (others => '0');
  
        wb_FIFO_Hit       <= '0';
        wb_FIFO_re_i      <= '0';
        wb_FIFO_RdEn_Mask <= '0';
  
        DDR_FIFO_Hit       <= '0';
        Regs_Hit           <= '0';
        Regs_RdEn          <= '0';
        regs_Rd_Counter    <= (others => '0');
        DDR_Rd_Counter     <= (others => '0');
        DDR_Rd_Cntr_eq_One <= '0';
  
        wb_FIFO_Rd_Counter     <= (others => '0');
        wb_FIFO_Rd_Cntr_eq_Two <= '0';
  
        regs_Rd_Cntr_eq_One <= '0';
        regs_Rd_Cntr_eq_Two <= '0';
  
        Shift_1st_QWord_k <= '0';
        is_CplD_k         <= '0';
        may_be_MWr_k      <= '0';
  
        Address_var <= (others => '1');
        TxTLP_eof_n <= '1';
  
        TO_Cnt_Rst <= '1';
  
        RdCmd_Ack_i     <= '0';
        TxMReader_State <= St_mR_Idle;

      else
        case TxMReader_State is
  
          when St_mR_Idle =>
            if RdCmd_Req_i = '0' then
              TxMReader_State <= St_mR_Idle;
              wb_FIFO_Hit     <= '0';
              ddr_fifo_hit    <= '0';
              Regs_Hit        <= '0';
              Regs_RdEn       <= '0';
              TxTLP_eof_n     <= '1';
              Address_var     <= (others => '1');
              RdCmd_Ack_i     <= '0';
              is_CplD_k       <= '0';
              may_be_MWr_k    <= '0';
            else
              RdCmd_Ack_i       <= '1';
              Shift_1st_QWord_k <= Shift_1st_QWord;
              is_CplD_k         <= is_CplD;
              may_be_MWr_k      <= not is_CplD;
              TxTLP_eof_n       <= '1';
              if BAR_value(C_ENCODE_BAR_NUMBER-1 downto 0)
                 = CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER)
              then
                wb_FIFO_Hit     <= '0';
                DDR_FIFO_Hit    <= '1';
                Regs_Hit        <= '0';
                Regs_RdEn       <= '0';
                Address_var     <= Address_var;
                TxMReader_State <= St_mR_DDR_A;
              elsif BAR_value(C_ENCODE_BAR_NUMBER-1 downto 0)
                 = CONV_STD_LOGIC_VECTOR(CINT_REGS_SPACE_BAR, C_ENCODE_BAR_NUMBER)
              then
                wb_FIFO_Hit  <= '0';
                DDR_FIFO_Hit <= '0';
                Regs_Hit     <= '1';
                Regs_RdEn    <= '1';
                if Shift_1st_QWord = '1' then
                  Address_var(C_EP_AWIDTH-1 downto 0) <= StartAddr(C_EP_AWIDTH-1 downto 0) - "100";
                else
                  Address_var(C_EP_AWIDTH-1 downto 0) <= StartAddr(C_EP_AWIDTH-1 downto 0);
                end if;
                TxMReader_State <= St_mR_CmdLatch;
              elsif BAR_value(C_ENCODE_BAR_NUMBER-1 downto 0)
                 = CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER)
              then
                wb_FIFO_Hit     <= '1';
                DDR_FIFO_Hit    <= '0';
                Regs_Hit        <= '0';
                Regs_RdEn       <= '0';
                Address_var     <= Address_var;
                TxMReader_State <= St_mR_wb_A;
              else
                wb_FIFO_Hit     <= '0';
                DDR_FIFO_Hit    <= '0';
                Regs_Hit        <= '0';
                Regs_RdEn       <= '0';
                Address_var     <= Address_var;
                TxMReader_State <= St_mR_CmdLatch;
              end if;
  
            end if;
  
          when St_mR_DDR_A =>
            ddr_mm2s_cmd_tvalid_i <= '1';
            ddr_mm2s_cmd_wtt(RdNumber'range) <= RdNumber;
            ddr_mm2s_cmd_drr <= '1';
            ddr_mm2s_cmd_dsa <= (others => '0');
            ddr_mm2s_cmd_dsa(2) <= shift_1st_qword_k;
            ddr_mm2s_cmd_eof <= '1';
            ddr_mm2s_cmd_saddr <= StartAddr(C_DBUS_WIDTH-1-32 downto 0);
            Regs_RdEn       <= '0';
            TxTLP_eof_n     <= '1';
            RdCmd_Ack_i     <= '1';
            TxMReader_State <= St_mR_DDR_C;  -- St_mR_DDR_B;
  
          when St_mR_wb_A =>
            wb_rdc_sof_i <= '1';
            wb_rdc_v_i   <= '1';
            wb_rdc_din_i <= C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_TLP_FLD_WIDTH_OF_LENG+2+32)
                                 & RdNumber & "00"
                                 & StartAddr(C_DBUS_WIDTH-1-32 downto 0);
            Regs_RdEn    <= '0';
            wb_FIFO_re_i <= '0';
            TxTLP_eof_n  <= '1';
            RdCmd_Ack_i  <= '1';
            if wb_rdc_full_i = '0' then
              TxMReader_State <= St_mR_DDR_C;
            else
              TxMReader_State <= St_mR_wb_A;
            end if;
  
          when St_mR_DDR_C =>
            ddr_mm2s_cmd_tvalid_i <= '0';
            wb_rdc_sof_i  <= '0';
            wb_rdc_v_i    <= '0';
            wb_rdc_din_i  <= wb_rdc_din_i;
            RdCmd_Ack_i   <= '0';
            TxTLP_eof_n   <= '1';
            if DDR_FIFO_Hit = '1' and ddr_mm2s_tvalid = '0' and Tx_TimeOut_i = '0' then
              TxMReader_State <= St_mR_DDR_C;
            elsif wb_FIFO_Hit = '1' and wb_FIFO_empty = '1' and Tx_wb_TimeOut_i = '0' then
              TxMReader_State <= St_mR_DDR_C;
            else
              TxMReader_State <= St_mR_CmdLatch;
            end if;
  
          when St_mR_CmdLatch =>
            RdCmd_Ack_i <= '0';
            if regs_Rd_Cntr_eq_One = '1' then
              Regs_RdEn       <= '0';
              Address_var     <= Address_var;
              TxTLP_eof_n     <= '0';
              TxMReader_State <= St_mR_Last;
            elsif regs_Rd_Cntr_eq_Two = '1' then
              if Shift_1st_QWord_k = '1' then
                TxMReader_State                     <= St_mR_Transfer;
                Regs_RdEn                           <= Regs_RdEn;  -- '1';
                TxTLP_eof_n                         <= '1';
                Address_var(C_EP_AWIDTH-1 downto 0) <= Address_var(C_EP_AWIDTH-1 downto 0) + "1000";
              else
                TxMReader_State                     <= St_mR_Last;
                Regs_RdEn                           <= '0';
                TxTLP_eof_n                         <= '0';
                Address_var(C_EP_AWIDTH-1 downto 0) <= Address_var(C_EP_AWIDTH-1 downto 0) + "1000";
              end if;
            elsif DDR_FIFO_Hit = '1' and ddr_mm2s_tlast_r(0) = '1' and ddr_mm2s_tready_r(0) = '1' then
              TxTLP_eof_n <= '0';
              TxMReader_State <= St_mR_Transfer;
            else
              Regs_RdEn                           <= Regs_RdEn;
              Address_var(C_EP_AWIDTH-1 downto 0) <= Address_var(C_EP_AWIDTH-1 downto 0) + "1000";
              TxTLP_eof_n                         <= '1';
              TxMReader_State                     <= St_mR_Transfer;
            end if;
  
          when St_mR_Transfer =>
            RdCmd_Ack_i <= '0';
            Regs_RdEn <= '0';
            if DDR_FIFO_Hit = '1' then
              if ddr_mm2s_tlast_r(0) = '1' and ddr_mm2s_tready_r(0) = '1' then
                TxTLP_eof_n <= '0';
              end if;
              if ddr_mm2s_tlast_r(1) = '1' and ddr_mm2s_tready_r(1) = '1' then
                TxMReader_State <= St_mR_Last;
              end if;
            elsif wb_FIFO_Hit = '1' and wb_FIFO_RdEn_Mask = '1' then
              Address_var     <= Address_var;
              TxTLP_eof_n     <= '0';
              TxMReader_State <= St_mR_Last;
            elsif wb_FIFO_Hit = '0' and regs_Rd_Cntr_eq_One = '1' then
              Address_var     <= Address_var;
              TxTLP_eof_n     <= '0';
              TxMReader_State <= St_mR_Last;
            elsif wb_FIFO_Hit = '0' and regs_Rd_Cntr_eq_Two = '1' then
              Address_var     <= Address_var;
              TxTLP_eof_n     <= '0';
              TxMReader_State <= St_mR_Last;
            elsif mbuf_aFull_r1 = '1' then
              Address_var     <= Address_var;
              TxTLP_eof_n     <= TxTLP_eof_n;
              TxMReader_State <= St_mR_Transfer;
            else
              Address_var(C_EP_AWIDTH-1 downto 0) <= Address_var(C_EP_AWIDTH-1 downto 0) + "1000";
              Regs_RdEn                           <= Regs_Hit;
              TxTLP_eof_n                         <= TxTLP_eof_n;
              TxMReader_State                     <= St_mR_Transfer;
            end if;
  
          when St_mR_Last =>
            Regs_RdEn       <= '0';
            TxTLP_eof_n     <= (not DDR_FIFO_Hit) and (not wb_FIFO_Hit);
            RdCmd_Ack_i     <= '0';
            TxMReader_State <= St_mR_Idle;
  
          when others =>
            Address_var     <= Address_var;
            wb_FIFO_Hit     <= '0';
            Regs_RdEn       <= '0';
            TxTLP_eof_n     <= '1';
            RdCmd_Ack_i     <= '0';
            TxMReader_State <= St_mR_Idle;
  
        end case;
  
        case TxMReader_State is
          when St_mR_Idle =>
            TO_Cnt_Rst <= '1';
  
          when others =>
            TO_Cnt_Rst <= '0';
  
        end case;
  
        case TxMReader_State is
          when St_mR_Idle =>
            ddr_mm2s_tready_i <= '0';
            
          when St_mR_Last =>
            ddr_mm2s_tready_i <= '0';
            
          when others =>
            if (DDR_Rd_Cntr_eq_One = '1' and Tx_TimeOut_i = '1')
              or (ddr_mm2s_tready_i = '1' and ddr_mm2s_tlast = '1')
            then
              ddr_mm2s_tready_i <= '0';
            else
              ddr_mm2s_tready_i <= DDR_FIFO_Hit and not mbuf_aFull_r1;
            end if;
        end case;
  
        case TxMReader_State is
  
          when St_mR_Idle =>
            wb_FIFO_re_i      <= '0';
            wb_FIFO_RdEn_Mask <= '0';
  
          when others =>
            if wb_FIFO_Rd_Cntr_eq_Two = '1'
              and (wb_FIFO_empty = '0' or Tx_wb_TimeOut_i = '1')
              and wb_FIFO_re_i = '1'
            then
              wb_FIFO_RdEn_Mask <= '1';
              wb_FIFO_re_i      <= '0';
            else
              wb_FIFO_RdEn_Mask <= wb_FIFO_RdEn_Mask;
              wb_FIFO_re_i      <= wb_FIFO_Hit
                                     and not mbuf_aFull_r1
                                     and not wb_FIFO_RdEn_Mask;
            end if;
        end case;
  
        case TxMReader_State is
  
          when St_mR_Idle =>
            if RdCmd_Req_i = '1' and
              BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0)
               /= CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER-1)
            then
              regs_Rd_Counter     <= RdNumber;
              regs_Rd_Cntr_eq_One <= RdNumber_eq_One;
              regs_Rd_Cntr_eq_Two <= RdNumber_eq_Two;
            else
              regs_Rd_Counter     <= (others => '0');
              regs_Rd_Cntr_eq_One <= '0';
              regs_Rd_Cntr_eq_Two <= '0';
            end if;
  
          when St_mR_CmdLatch =>
            if DDR_FIFO_Hit = '0' then
              if Shift_1st_QWord_k = '1' then
                regs_Rd_Counter <= regs_Rd_Counter - '1';
                if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG) then
                  regs_Rd_Cntr_eq_One <= '1';
                else
                  regs_Rd_Cntr_eq_One <= '0';
                end if;
                if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(3, C_TLP_FLD_WIDTH_OF_LENG) then
                  regs_Rd_Cntr_eq_Two <= '1';
                else
                  regs_Rd_Cntr_eq_Two <= '0';
                end if;
              else
                regs_Rd_Counter <= regs_Rd_Counter - "10";  -- '1';
                if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(3, C_TLP_FLD_WIDTH_OF_LENG) then
                  regs_Rd_Cntr_eq_One <= '1';
                else
                  regs_Rd_Cntr_eq_One <= '0';
                end if;
                if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(4, C_TLP_FLD_WIDTH_OF_LENG) then
                  regs_Rd_Cntr_eq_Two <= '1';
                else
                  regs_Rd_Cntr_eq_Two <= '0';
                end if;
              end if;
            else
              regs_Rd_Counter     <= regs_Rd_Counter;
              regs_Rd_Cntr_eq_One <= regs_Rd_Cntr_eq_One;
              regs_Rd_Cntr_eq_Two <= regs_Rd_Cntr_eq_Two;
            end if;
  
          when St_mR_Transfer =>
            if DDR_FIFO_Hit = '0'
              and mbuf_aFull_r1 = '0'
            then
              regs_Rd_Counter <= regs_Rd_Counter - "10";  -- '1';
              if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) then
                regs_Rd_Cntr_eq_One <= '1';
              elsif regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG) then
                regs_Rd_Cntr_eq_One <= '1';
              elsif regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(3, C_TLP_FLD_WIDTH_OF_LENG) then
                regs_Rd_Cntr_eq_One <= '1';
              else
                regs_Rd_Cntr_eq_One <= '0';
              end if;
              if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(4, C_TLP_FLD_WIDTH_OF_LENG) then
                regs_Rd_Cntr_eq_Two <= '1';
              else
                regs_Rd_Cntr_eq_Two <= '0';
              end if;
            else
              regs_Rd_Counter     <= regs_Rd_Counter;
              regs_Rd_Cntr_eq_One <= regs_Rd_Cntr_eq_One;
              regs_Rd_Cntr_eq_Two <= regs_Rd_Cntr_eq_Two;
            end if;
  
          when others =>
            regs_Rd_Counter     <= regs_Rd_Counter;
            regs_Rd_Cntr_eq_One <= regs_Rd_Cntr_eq_One;
            regs_Rd_Cntr_eq_Two <= regs_Rd_Cntr_eq_Two;
  
        end case;
 
        case TxMReader_State is
          when St_mR_Idle =>
            if RdCmd_Req_i = '1' and
              BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0)
               = CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER-1)
            then
              if RdNumber(0) = '1' then
                DDR_Rd_Counter     <= RdNumber + '1';
                DDR_Rd_Cntr_eq_One <= RdNumber_eq_One;
              elsif Shift_1st_QWord = '1' then
                DDR_Rd_Counter     <= RdNumber + "10";
                DDR_Rd_Cntr_eq_One <= RdNumber_eq_One;
              else
                DDR_Rd_Counter     <= RdNumber;
                DDR_Rd_Cntr_eq_One <= RdNumber_eq_One or RdNumber_eq_Two;
              end if;
            else
              DDR_Rd_Counter     <= (others => '0');
              DDR_Rd_Cntr_eq_One <= '0';
            end if;
  
          when others =>
            if Tx_TimeOut_i = '1' then
              DDR_Rd_Counter <= DDR_Rd_Counter - "10";  -- '1';
              if DDR_Rd_Counter = CONV_STD_LOGIC_VECTOR(4, C_TLP_FLD_WIDTH_OF_LENG) then
                DDR_Rd_Cntr_eq_One <= '1';
              else
                DDR_Rd_Cntr_eq_One <= '0';
              end if;
            else
              DDR_Rd_Counter     <= DDR_Rd_Counter;
              DDR_Rd_Cntr_eq_One <= DDR_Rd_Cntr_eq_One;
            end if;
  
        end case;
  
        case TxMReader_State is
          when St_mR_Idle =>
            if RdCmd_Req_i = '1' and
              BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0)
               = CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER-1)
            then
              if RdNumber_eq_One = '1' then
                wb_FIFO_Rd_Counter     <= RdNumber + '1';
                wb_FIFO_Rd_Cntr_eq_Two <= '1';
                wb_FIFO_Rd_1Dw         <= '1';
              else
                wb_FIFO_Rd_Counter     <= RdNumber;
                wb_FIFO_Rd_Cntr_eq_Two <= RdNumber_eq_Two;  -- or RdNumber_eq_One;
                wb_FIFO_Rd_1Dw         <= '0';
              end if;
            else
              wb_FIFO_Rd_Counter     <= (others => '0');
              wb_FIFO_Rd_Cntr_eq_Two <= '0';
              wb_FIFO_Rd_1Dw         <= '0';
            end if;
  
          when others =>
            wb_FIFO_Rd_1Dw <= wb_FIFO_Rd_1Dw;
            if (wb_FIFO_empty = '0' or Tx_wb_TimeOut_i = '1') and wb_FIFO_re_i = '1'
            then
              wb_FIFO_Rd_Counter <= wb_FIFO_Rd_Counter - "10";  -- '1';
              if wb_FIFO_Rd_Counter = CONV_STD_LOGIC_VECTOR(4, C_TLP_FLD_WIDTH_OF_LENG) then
                wb_FIFO_Rd_Cntr_eq_Two <= '1';
              else
                wb_FIFO_Rd_Cntr_eq_Two <= '0';
              end if;
            else
              wb_FIFO_Rd_Counter     <= wb_FIFO_Rd_Counter;
              wb_FIFO_Rd_Cntr_eq_Two <= wb_FIFO_Rd_Cntr_eq_Two;
            end if;
  
        end case;
      end if;
    end if;
  end process;


-----------------------------------------------------
-- Synchronous Delay: mbuf_writes
--
  Synchron_Delay_mbuf_writes :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      Regs_Write_mbuf_r(0) <= Regs_RdEn;
      Regs_Write_mbuf_r(2 downto 1) <= Regs_Write_mbuf_r(1 downto 0);

      DDR_FIFO_Write_mbuf_r(0) <= Tx_TimeOut_i or (ddr_mm2s_tready_i and ddr_mm2s_tvalid);
      DDR_FIFO_Write_mbuf_r(1) <= DDR_FIFO_Write_mbuf_r(0);

      wb_FIFO_Write_mbuf_r(0)  <= wb_FIFO_re_i and (not wb_FIFO_empty or Tx_wb_TimeOut_i);
      wb_FIFO_Write_mbuf_r(2 downto 1) <= wb_FIFO_Write_mbuf_r(1 downto 0);

      wb_FIFO_RdEn_Mask_r1 <= wb_FIFO_RdEn_Mask;
      wb_FIFO_RdEn_Mask_r2 <= wb_FIFO_RdEn_Mask_r1;
    end if;
  end process;


--------------------------------------------------------------------------
--  Wires to be OR'ed to build mbuf_Din
--------------------------------------------------------------------------

  wb_FIFO_Dout_wire <= wb_FIFO_qout_r1 when (wb_FIFO_Hit = '1' and Shift_1st_QWord_k = '0')
                           else wb_FIFO_qout_shift when (wb_FIFO_Hit = '1' and Shift_1st_QWord_k = '1')
                           else (others => '0');
  DDR_Dout_wire    <= ddr_mm2s_tdata_r(1) when DDR_FIFO_Hit = '1' else (others => '0');
  Regs_RdQout_wire <= (Regs_RdQout(C_DBUS_WIDTH/2-1 downto 0) & Regs_RdQout(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2))  --watch out!
                           when Regs_Hit = '1' else (others => '0');

  mbuf_Din_wire_OR <= wb_FIFO_Dout_wire or DDR_Dout_wire or Regs_RdQout_wire;

-----------------------------------------------------
-- Synchronous Delay: mbuf_WE
--
  Synchron_Delay_mbuf_WE :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      mbuf_WE_i <= DDR_FIFO_Write_mbuf_r(1)
                   or Regs_Write_mbuf_r(1)
                   or (wb_FIFO_Write_mbuf_r(1) or (Shift_1st_QWord_k and wb_FIFO_RdEn_Mask_rise_r1));
    end if;
  end process;

-----------------------------------------------------
-- Synchronous Delay: TxTLP_eof_n
--
  Synchron_Delay_TxTLP_eof_n :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      TxTLP_eof_n_r1 <= TxTLP_eof_n;
    end if;
  end process;

-----------------------------------------------------
-- Synchronous Delay: wb_FIFO_qout
--
  Synchron_Delay_wb_FIFO_qout :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      wb_FIFO_RdEn_Mask_rise    <= wb_FIFO_RdEn_Mask and not wb_FIFO_RdEn_Mask_r1;
      wb_FIFO_RdEn_Mask_rise_r1 <= wb_FIFO_RdEn_Mask_rise;
      wb_FIFO_RdEn_Mask_rise_r2 <= wb_FIFO_RdEn_Mask_rise_r1;
      wb_FIFO_qout_r1           <= wb_FIFO_qout;
      wb_FIFO_qout_shift        <= wb_FIFO_qout(C_DBUS_WIDTH/2-1 downto 0)
                                   & wb_FIFO_qout_r1(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2);
    end if;
  end process;

-----------------------------------------------------
-- Synchronous Delay: mbuf_Din
--
  Synchron_Delay_mbuf_Din :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if mReader_Rst_n = '0' then
        mbuf_Din_i <= (C_DBUS_WIDTH => '1', others => '0');
      else
        if Tx_TimeOut_i = '1' and DDR_FIFO_Hit = '1' then
          mbuf_Din_i(C_DBUS_WIDTH-1 downto 0) <= (others => '1');
        elsif Tx_wb_TimeOut_i = '1' and wb_FIFO_Hit = '1' and is_CplD_k = '1' then
          mbuf_Din_i(C_DBUS_WIDTH-1 downto 0) <= (others => '1');
        elsif Tx_wb_TimeOut_i = '1' and wb_FIFO_Hit = '1' and may_be_MWr_k = '1' then
          mbuf_Din_i(C_DBUS_WIDTH-1 downto 0) <= (others => '1');
        else
          mbuf_Din_i(C_DBUS_WIDTH-1 downto 0) <= Endian_Invert_64(mbuf_Din_wire_OR);
        end if;
  
        if DDR_FIFO_Hit = '1' then
          mbuf_din_i(C_TXMEM_KEEP_BIT)  <= not(TxTLP_eof_n);
          mbuf_din_i(C_TXMEM_TLAST_BIT) <= TxTLP_eof_n;
        elsif wb_FIFO_Hit = '1' then
          if Shift_1st_QWord_k = '1' and wb_FIFO_Rd_1Dw = '0' then
            mbuf_din_i(C_TXMEM_TLAST_BIT) <= not wb_FIFO_RdEn_Mask_r2;
            mbuf_din_i(C_TXMEM_KEEP_BIT) <= wb_FIFO_RdEn_Mask_r2;
          else
            mbuf_din_i(C_TXMEM_TLAST_BIT) <= not wb_FIFO_RdEn_Mask_r1;
            mbuf_din_i(C_TXMEM_KEEP_BIT) <= wb_FIFO_RdEn_Mask_r1;
          end if;
        else
          mbuf_din_i(C_TXMEM_TLAST_BIT) <= TxTLP_eof_n_r1;
          mbuf_din_i(C_TXMEM_KEEP_BIT) <= not(TxTLP_eof_n_r1);
        end if;
      end if;
    end if;
  end process;

-----------------------------------------------------
-- Synchronous: Time-out counter
--
  Synchron_TimeOut_Counter :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if TO_Cnt_Rst = '1' then
        TimeOut_Counter <= (others => '0');
      else
        TimeOut_Counter(21 downto 0) <= TimeOut_Counter(21 downto 0) + '1';
      end if;
    end if;
  end process;

-----------------------------------------------------
-- Synchronous: Tx_TimeOut
--
  SynchOUT_Tx_TimeOut :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if mReader_Rst_n = '0' then
        Tx_TimeOut_i <= '0';
      else
        if TimeOut_Counter(21 downto 6) = X"FFFF" and DDR_FIFO_Hit = '1' then
          Tx_TimeOut_i <= '1';
        else
          Tx_TimeOut_i <= Tx_TimeOut_i;
        end if;
      end if;
    end if;
  end process;

-----------------------------------------------------
-- Synchronous: Tx_wb_TimeOut
--
  SynchOUT_Tx_wb_TimeOut :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if mReader_Rst_n = '0' then
        Tx_wb_TimeOut_i <= '0';
      else
        if TimeOut_Counter(21 downto 6) = X"FFFF" and wb_FIFO_Hit = '1' then
          Tx_wb_TimeOut_i <= '1';
        else
          Tx_wb_TimeOut_i <= Tx_wb_TimeOut_i;
        end if;
      end if;
    end if;
  end process;

end architecture Behavioral;
