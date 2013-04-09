----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Design Name:
-- Module Name:    rx_MWr_Transact - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
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

entity rx_MWr_Transact is
  port (
    -- Transaction receive interface
    m_axis_rx_tlast    : in std_logic;
    m_axis_rx_tdata    : in std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    m_axis_rx_tkeep    : in std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
    m_axis_rx_terrfwd  : in std_logic;
    m_axis_rx_tvalid   : in std_logic;
    m_axis_rx_tready   : in std_logic;  -- !!
    m_axis_rx_tbar_hit : in std_logic_vector(C_BAR_NUMBER-1 downto 0);
--      trn_rfc_ph_av      : IN  std_logic_vector(7 downto 0);
--      trn_rfc_pd_av      : IN  std_logic_vector(11 downto 0);
--      trn_rfc_nph_av     : IN  std_logic_vector(7 downto 0);
--      trn_rfc_npd_av     : IN  std_logic_vector(11 downto 0);
--      trn_rfc_cplh_av    : IN  std_logic_vector(7 downto 0);
--      trn_rfc_cpld_av    : IN  std_logic_vector(11 downto 0);

    -- from pre-process module
    IOWr_Type         : in std_logic;
    MWr_Type          : in std_logic_vector(1 downto 0);
    Tlp_straddles_4KB : in std_logic;
--      Last_DW_of_TLP     : IN  std_logic;
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

    -- Common ports
    user_clk    : in std_logic;
    user_reset  : in std_logic;
    user_lnk_up : in std_logic
    );

end entity rx_MWr_Transact;


architecture Behavioral of rx_MWr_Transact is


  type RxMWrTrnStates is (ST_MWr_RESET
                                 , ST_MWr_IDLE
--                               , ST_MWr3_HEAD1
--                               , ST_MWr4_HEAD1
                                 , ST_MWr3_HEAD2
                                 , ST_MWr4_HEAD2
--                               , ST_MWr4_HEAD3
--                               , ST_MWr_Last_HEAD
                                 , ST_MWr4_1ST_DATA
                                 , ST_MWr_1ST_DATA
                                 , ST_MWr_1ST_DATA_THROTTLE
                                 , ST_MWr_DATA
                                 , ST_MWr_DATA_THROTTLE
                                 , ST_MWr_LAST_DATA
                                 );

  -- State variables
  signal RxMWrTrn_NextState : RxMWrTrnStates;
  signal RxMWrTrn_State     : RxMWrTrnStates;

  -- trn_rx stubs
  signal m_axis_rx_tdata_i  : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal m_axis_rx_tdata_r1 : std_logic_vector (C_DBUS_WIDTH-1 downto 0);

  signal m_axis_rx_tkeep_i  : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal m_axis_rx_tkeep_r1 : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);

  signal m_axis_rx_tbar_hit_i  : std_logic_vector (C_BAR_NUMBER-1 downto 0);
  signal m_axis_rx_tbar_hit_r1 : std_logic_vector (C_BAR_NUMBER-1 downto 0);

  signal m_axis_rx_tvalid_i  : std_logic;
  signal m_axis_rx_terrfwd_i : std_logic;
  signal trn_rsof_n_i        : std_logic;
  signal in_packet_reg       : std_logic;
  signal m_axis_rx_tlast_i   : std_logic;
  signal m_axis_rx_tvalid_r1 : std_logic;
  signal m_axis_rx_tlast_r1  : std_logic;


  -- packet RAM and packet FIFOs selection signals
  signal FIFO_Space_Sel : std_logic;
  signal DDR_Space_Sel  : std_logic;
  signal REGS_Space_Sel : std_logic;

  -- DDR write port
  signal DDR_wr_sof_i       : std_logic;
  signal DDR_wr_eof_i       : std_logic;
  signal DDR_wr_v_i         : std_logic;
  signal DDR_wr_FA_i        : std_logic;
  signal DDR_wr_Shift_i     : std_logic;
  signal DDR_wr_Mask_i      : std_logic_vector(2-1 downto 0);
  signal ddr_wr_1st_mask_hi : std_logic;
  signal DDR_wr_din_i       : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_wr_full_i      : std_logic;

  -- Data generator sequence table write
  signal dg_table_Sel : std_logic;
  signal tab_wa_odd   : std_logic;
  signal tab_we_i     : std_logic_vector(2-1 downto 0);
  signal tab_wa_i     : std_logic_vector(12-1 downto 0);
  signal tab_wd_i     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Event Buffer write port
  signal wb_FIFO_we_i   : std_logic;
  signal wb_FIFO_wsof_i : std_logic;
  signal wb_FIFO_weof_i : std_logic;
  signal wb_FIFO_din_i  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  --
  signal Regs_WrEn_i   : std_logic;
  signal Regs_WrMask_i : std_logic_vector(2-1 downto 0);
  signal Regs_WrAddr_i : std_logic_vector(C_EP_AWIDTH-1 downto 0);
  signal Regs_WrDin_i  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal m_axis_rx_tready_i : std_logic;

  signal trn_rx_throttle    : std_logic;
  signal trn_rx_throttle_r1 : std_logic;

  -- 1st DW BE = "0000" means the TLP is of zero-length.
  signal MWr_Has_4DW_Header : std_logic;
  signal Tlp_is_Zero_Length : std_logic;
  signal MWr_Leng_in_Bytes  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

begin

  -- Event Buffer write
  wb_FIFO_we   <= wb_FIFO_we_i;
  wb_FIFO_wsof <= wb_FIFO_wsof_i;
  wb_FIFO_weof <= wb_FIFO_weof_i;
  wb_FIFO_din  <= wb_FIFO_din_i;

  -- DDR
  DDR_wr_sof    <= DDR_wr_sof_i;
  DDR_wr_eof    <= DDR_wr_eof_i;
  DDR_wr_v      <= DDR_wr_v_i;
  DDR_wr_FA     <= DDR_wr_FA_i;
  DDR_wr_Shift  <= DDR_wr_Shift_i;
  DDR_wr_Mask   <= DDR_wr_Mask_i;
  DDR_wr_din    <= DDR_wr_din_i;
  DDR_wr_full_i <= DDR_wr_full;

  -- Data generator table
  tab_we <= tab_we_i;
  tab_wa <= tab_wa_i;
  tab_wd <= tab_wd_i;

  -- Registers writing
  Regs_WrEn   <= Regs_WrEn_i;
  Regs_WrMask <= Regs_WrMask_i;
  Regs_WrAddr <= Regs_WrAddr_i;
  Regs_WrDin  <= Regs_WrDin_i;          -- Mem_WrData;



  -- TLP info stubs
  m_axis_rx_tdata_i <= m_axis_rx_tdata;
  m_axis_rx_tlast_i <= m_axis_rx_tlast;
  m_axis_rx_tkeep_i <= m_axis_rx_tkeep;


  -- Output to the core as handshaking
  m_axis_rx_terrfwd_i  <= m_axis_rx_terrfwd;
  m_axis_rx_tbar_hit_i <= m_axis_rx_tbar_hit;

  -- Output to the core as handshaking
  m_axis_rx_tvalid_i <= m_axis_rx_tvalid;
  m_axis_rx_tready_i <= m_axis_rx_tready;


  -- ( m_axis_rx_tvalid seems never deasserted during packet)
  trn_rx_throttle <= not(m_axis_rx_tvalid_i) or not(m_axis_rx_tready_i);


-- -----------------------------------------------------
--   Delays: m_axis_rx_tdata_i, m_axis_rx_tbar_hit_i, m_axis_rx_tlast_i
-- -----------------------------------------------------
  Sync_Delays_m_axis_rx_tdata_rbar_reof :
  process (user_clk)
  begin
    if user_clk'event and user_clk = '1' then
      m_axis_rx_tvalid_r1   <= m_axis_rx_tvalid_i;
      m_axis_rx_tlast_r1    <= m_axis_rx_tlast_i;
      m_axis_rx_tdata_r1    <= m_axis_rx_tdata_i;
      m_axis_rx_tkeep_r1    <= m_axis_rx_tkeep_i;
      m_axis_rx_tbar_hit_r1 <= m_axis_rx_tbar_hit_i;
      trn_rx_throttle_r1    <= trn_rx_throttle;
    end if;
  end process;


-- -----------------------------------------------------------------------
-- States synchronous
--
  Syn_RxTrn_States :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      RxMWrTrn_State <= ST_MWr_RESET;
    elsif user_clk'event and user_clk = '1' then
      RxMWrTrn_State <= RxMWrTrn_NextState;
    end if;
  end process;


-- Next States
  Comb_RxTrn_NextStates :
  process (
    RxMWrTrn_State
    , MWr_Type
--           , IOWr_Type
    , Tlp_straddles_4KB
    , trn_rx_throttle
    , m_axis_rx_tlast_i
--           , Last_DW_of_TLP
    )
  begin
    case RxMWrTrn_State is

      when ST_MWr_RESET =>
        RxMWrTrn_NextState <= ST_MWr_IDLE;

      when ST_MWr_IDLE =>
        if trn_rx_throttle = '0' then
          case MWr_Type is
            when C_TLP_TYPE_IS_MWR_H3 =>
              RxMWrTrn_NextState <= ST_MWr3_HEAD2;
            when C_TLP_TYPE_IS_MWR_H4 =>
              RxMWrTrn_NextState <= ST_MWr4_HEAD2;
            when others =>
--               if IOWr_Type='1' then   -- Temp taking IOWr as MWr3
--                 RxMWrTrn_NextState <= ST_MWr3_HEAD1;
--               else
              RxMWrTrn_NextState <= ST_MWr_IDLE;
--               end if;
          end case;  -- MWr_Type
        else
          RxMWrTrn_NextState <= ST_MWr_IDLE;
        end if;


--        when ST_MWr3_HEAD1 =>
--           if trn_rx_throttle = '1' then
--              RxMWrTrn_NextState <= ST_MWr3_HEAD1;
--           else
--              RxMWrTrn_NextState <= ST_MWr3_HEAD2;
--           end if;

--        when ST_MWr4_HEAD1 =>
--           if trn_rx_throttle = '1' then
--              RxMWrTrn_NextState <= ST_MWr4_HEAD1;
--           else
--              RxMWrTrn_NextState <= ST_MWr4_HEAD2;
--           end if;


      when ST_MWr3_HEAD2 =>
        if trn_rx_throttle = '1' then
          RxMWrTrn_NextState <= ST_MWr3_HEAD2;
        elsif m_axis_rx_tlast_i = '1' then
          RxMWrTrn_NextState <= ST_MWr_IDLE;      -- ST_MWr_LAST_DATA;
        else
          RxMWrTrn_NextState <= ST_MWr_1ST_DATA;  -- ST_MWr_Last_HEAD;
        end if;

      when ST_MWr4_HEAD2 =>
        if trn_rx_throttle = '1' then
          RxMWrTrn_NextState <= ST_MWr4_HEAD2;
        else
          RxMWrTrn_NextState <= ST_MWr4_1ST_DATA;  -- ST_MWr4_HEAD3;
        end if;

--        when ST_MWr4_HEAD3 =>
--           if trn_rx_throttle = '1' then
--              RxMWrTrn_NextState <= ST_MWr4_HEAD3;
--           else
--              RxMWrTrn_NextState <= ST_MWr_Last_HEAD;
--           end if;


--        when ST_MWr_Last_HEAD =>
--           if trn_rx_throttle = '1' then
--              RxMWrTrn_NextState <= ST_MWr_Last_HEAD;
--           elsif Tlp_straddles_4KB = '1' then      -- !!
--              RxMWrTrn_NextState <= ST_MWr_IDLE;
----           elsif Last_DW_of_TLP='1' then
----              RxMWrTrn_NextState <= ST_MWr_LAST_DATA;
--           elsif m_axis_rx_tlast_i = '1' then
--              RxMWrTrn_NextState <= ST_MWr_LAST_DATA;
--           else
--              RxMWrTrn_NextState <= ST_MWr_1ST_DATA;
--           end if;


      when ST_MWr_1ST_DATA =>
        if trn_rx_throttle = '1' then
          RxMWrTrn_NextState <= ST_MWr_1ST_DATA_THROTTLE;
        elsif m_axis_rx_tlast_i = '1' then
          RxMWrTrn_NextState <= ST_MWr_IDLE;  -- ST_MWr_LAST_DATA;
        else
          RxMWrTrn_NextState <= ST_MWr_DATA;
        end if;

      when ST_MWr4_1ST_DATA =>
        if trn_rx_throttle = '1' then
          RxMWrTrn_NextState <= ST_MWr_1ST_DATA_THROTTLE;
        elsif m_axis_rx_tlast_i = '1' then
          RxMWrTrn_NextState <= ST_MWr_IDLE;  -- ST_MWr_LAST_DATA;
        else
          RxMWrTrn_NextState <= ST_MWr_DATA;
        end if;

      when ST_MWr_1ST_DATA_THROTTLE =>
        if trn_rx_throttle = '1' then
          RxMWrTrn_NextState <= ST_MWr_1ST_DATA_THROTTLE;
        elsif m_axis_rx_tlast_i = '1' then
          RxMWrTrn_NextState <= ST_MWr_IDLE;  -- ST_MWr_LAST_DATA;
        else
          RxMWrTrn_NextState <= ST_MWr_DATA;
        end if;


      when ST_MWr_DATA =>
        if trn_rx_throttle = '1' then
          RxMWrTrn_NextState <= ST_MWr_DATA_THROTTLE;
        elsif m_axis_rx_tlast_i = '1' then
          RxMWrTrn_NextState <= ST_MWr_LAST_DATA;
        else
          RxMWrTrn_NextState <= ST_MWr_DATA;
        end if;


      when ST_MWr_DATA_THROTTLE =>
        if trn_rx_throttle = '1' then
          RxMWrTrn_NextState <= ST_MWr_DATA_THROTTLE;
        elsif m_axis_rx_tlast_i = '1' then
          RxMWrTrn_NextState <= ST_MWr_LAST_DATA;
        else
          RxMWrTrn_NextState <= ST_MWr_DATA;
        end if;


      when ST_MWr_LAST_DATA =>          -- Same as ST_MWr_IDLE, to support
                                        --  back-to-back transactions
        case MWr_Type is
          when C_TLP_TYPE_IS_MWR_H3 =>
            RxMWrTrn_NextState <= ST_MWr3_HEAD2;
          when C_TLP_TYPE_IS_MWR_H4 =>
            RxMWrTrn_NextState <= ST_MWr4_HEAD2;
          when others =>
--               if IOWr_Type='1' then
--                 RxMWrTrn_NextState <= ST_MWr3_HEAD1;
--               else
            RxMWrTrn_NextState <= ST_MWr_IDLE;
--               end if;
        end case;  -- MWr_Type

      when others =>
        RxMWrTrn_NextState <= ST_MWr_RESET;

    end case;

  end process;

-- ----------------------------------------------
-- registers Write Enable
--
  RxFSM_Output_Regs_Write_En :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      Regs_WrEn_i   <= '0';
      Regs_WrMask_i <= (others => '0');
      Regs_WrAddr_i <= (others => '1');
      Regs_WrDin_i  <= (others => '0');

    elsif user_clk'event and user_clk = '1' then

      case RxMWrTrn_State is

        when ST_MWr3_HEAD2 =>
          if REGS_Space_Sel = '1' then
            Regs_WrEn_i   <= not trn_rx_throttle;
            Regs_WrMask_i <= "01";
            Regs_WrAddr_i <= m_axis_rx_tdata_i(C_EP_AWIDTH-1 downto 2) & "00";
            Regs_WrDin_i  <= Endian_Invert_64(m_axis_rx_tdata_i(63 downto 32) & X"00000000");
          else
            Regs_WrEn_i   <= '0';
            Regs_WrMask_i <= (others => '0');
            Regs_WrAddr_i <= (others => '1');
            Regs_WrDin_i  <= (others => '0');
          end if;

        when ST_MWr4_HEAD2 =>
          if REGS_Space_Sel = '1' then
            Regs_WrEn_i   <= '0';
            Regs_WrMask_i <= (others => '0');
            Regs_WrAddr_i <= m_axis_rx_tdata_i(32+C_EP_AWIDTH-1 downto 32+2) &"00";
            Regs_WrDin_i  <= Endian_Invert_64(m_axis_rx_tdata_i);
          else
            Regs_WrEn_i   <= '0';
            Regs_WrMask_i <= (others => '0');
            Regs_WrAddr_i <= (others => '1');
            Regs_WrDin_i  <= (others => '0');
          end if;

        when ST_MWr_1ST_DATA =>
          if REGS_Space_Sel = '1' then
            Regs_WrEn_i  <= not trn_rx_throttle;
            Regs_WrDin_i <= Endian_Invert_64 (m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata(63 downto 32));
            if m_axis_rx_tlast_i = '1' then
              Regs_WrMask_i <= '0' & (m_axis_rx_tkeep_i(3) and m_axis_rx_tkeep_i(0));
            else
              Regs_WrMask_i <= (others => '0');
            end if;
            if MWr_Has_4DW_Header = '1' then
              Regs_WrAddr_i <= Regs_WrAddr_i;
            else
              Regs_WrAddr_i <= Regs_WrAddr_i + CONV_STD_LOGIC_VECTOR(4, C_EP_AWIDTH);
            end if;
          else
            Regs_WrEn_i   <= '0';
            Regs_WrMask_i <= (others => '0');
            Regs_WrAddr_i <= (others => '1');
            Regs_WrDin_i  <= (others => '0');
          end if;

        when ST_MWr4_1ST_DATA =>
          if REGS_Space_Sel = '1' then
            Regs_WrEn_i  <= not trn_rx_throttle;
            Regs_WrDin_i <= Endian_Invert_64 (m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata(63 downto 32));
            if m_axis_rx_tlast_i = '1' then
              Regs_WrMask_i <= '0' & (m_axis_rx_tkeep_i(3) and m_axis_rx_tkeep_i(0));
            else
              Regs_WrMask_i <= (others => '0');
            end if;
--                  if MWr_Has_4DW_Header='1' then
            Regs_WrAddr_i <= Regs_WrAddr_i;
--                  else
--                    Regs_WrAddr_i  <= Regs_WrAddr_i + CONV_STD_LOGIC_VECTOR(4, C_EP_AWIDTH);
--                  end if;
          else
            Regs_WrEn_i   <= '0';
            Regs_WrMask_i <= (others => '0');
            Regs_WrAddr_i <= (others => '1');
            Regs_WrDin_i  <= (others => '0');
          end if;

        when ST_MWr_1ST_DATA_THROTTLE =>
          if REGS_Space_Sel = '1' then
            Regs_WrEn_i  <= not trn_rx_throttle;
            Regs_WrDin_i <= Endian_Invert_64 (m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata(63 downto 32));
            if m_axis_rx_tlast_i = '1' then
              Regs_WrMask_i <= '0' & (m_axis_rx_tkeep_i(3) and m_axis_rx_tkeep_i(0));
            else
              Regs_WrMask_i <= (others => '0');
            end if;
--                  if MWr_Has_4DW_Header='1' then
            Regs_WrAddr_i <= Regs_WrAddr_i;
--                  else
--                    Regs_WrAddr_i  <= Regs_WrAddr_i + CONV_STD_LOGIC_VECTOR(4, C_EP_AWIDTH);
--                  end if;
          else
            Regs_WrEn_i   <= '0';
            Regs_WrMask_i <= (others => '0');
            Regs_WrAddr_i <= (others => '1');
            Regs_WrDin_i  <= (others => '0');
          end if;

        when ST_MWr_DATA =>
          if REGS_Space_Sel = '1' then
            Regs_WrEn_i <= not trn_rx_throttle;  -- '1';
            if m_axis_rx_tlast_i = '1' then
              Regs_WrMask_i <= '0' & (m_axis_rx_tkeep_i(3) and m_axis_rx_tkeep_i(0));
            else
              Regs_WrMask_i <= (others => '0');
            end if;
            Regs_WrAddr_i <= Regs_WrAddr_i + CONV_STD_LOGIC_VECTOR(8, C_EP_AWIDTH);
            Regs_WrDin_i  <= Endian_Invert_64 (m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata(63 downto 32));
          else
            Regs_WrEn_i   <= '0';
            Regs_WrMask_i <= (others => '0');
            Regs_WrAddr_i <= (others => '1');
            Regs_WrDin_i  <= (others => '0');
          end if;


        when ST_MWr_DATA_THROTTLE =>
          if REGS_Space_Sel = '1' then
            Regs_WrEn_i <= not trn_rx_throttle;  -- '1';
            if m_axis_rx_tlast_i = '1' then
              Regs_WrMask_i <= '0' & (m_axis_rx_tkeep_i(3) and m_axis_rx_tkeep_i(0));
            else
              Regs_WrMask_i <= (others => '0');
            end if;
            Regs_WrAddr_i <= Regs_WrAddr_i;  -- + CONV_STD_LOGIC_VECTOR(8, C_EP_AWIDTH);
            Regs_WrDin_i  <= Endian_Invert_64 (m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata(63 downto 32));
          else
            Regs_WrEn_i   <= '0';
            Regs_WrMask_i <= (others => '0');
            Regs_WrAddr_i <= (others => '1');
            Regs_WrDin_i  <= (others => '0');
          end if;


        when others =>
          Regs_WrEn_i   <= '0';
          Regs_WrMask_i <= (others => '0');
          Regs_WrAddr_i <= (others => '1');
          Regs_WrDin_i  <= (others => '0');

      end case;

    end if;

  end process;

-- -----------------------------------------------------------------------
-- Capture: REGS_Space_Sel
--
  Syn_Capture_REGS_Space_Sel :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      REGS_Space_Sel <= '0';
    elsif user_clk'event and user_clk = '1' then
      if trn_rsof_n_i = '0' then
        REGS_Space_Sel <= (m_axis_rx_tdata_i(C_TLP_1ST_BE_BIT_BOT+3)
                                 or m_axis_rx_tdata_i(C_TLP_1ST_BE_BIT_BOT+2)
                                 or m_axis_rx_tdata_i(C_TLP_1ST_BE_BIT_BOT+1)
                                 or m_axis_rx_tdata_i(C_TLP_1ST_BE_BIT_BOT+0))
                                and m_axis_rx_tbar_hit_i(CINT_REGS_SPACE_BAR);
      else
        REGS_Space_Sel <= REGS_Space_Sel;
      end if;
    end if;
  end process;

-- -----------------------------------------------------------------------
-- Capture: MWr_Has_4DW_Header
--        : Tlp_is_Zero_Length
--
  Syn_Capture_MWr_Has_4DW_Header :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      MWr_Has_4DW_Header <= '0';
      Tlp_is_Zero_Length <= '0';
    elsif user_clk'event and user_clk = '1' then
      if trn_rsof_n_i = '0' then
        MWr_Has_4DW_Header <= m_axis_rx_tdata_i(C_TLP_FMT_BIT_BOT);
        Tlp_is_Zero_Length <= not(m_axis_rx_tdata_i(C_TLP_1ST_BE_BIT_BOT+3)
                                    or m_axis_rx_tdata_i(C_TLP_1ST_BE_BIT_BOT+2)
                                    or m_axis_rx_tdata_i(C_TLP_1ST_BE_BIT_BOT+1)
                                    or m_axis_rx_tdata_i(C_TLP_1ST_BE_BIT_BOT+0));
      else
        MWr_Has_4DW_Header <= MWr_Has_4DW_Header;
        Tlp_is_Zero_Length <= Tlp_is_Zero_Length;
      end if;
    end if;
  end process;

-- -----------------------------------------------------------------------
-- Capture: MWr_Leng_in_Bytes
--
  Syn_Capture_MWr_Length_in_Bytes :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      MWr_Leng_in_Bytes <= (others => '0');
    elsif user_clk'event and user_clk = '1' then
      if trn_rsof_n_i = '0' then
        -- Assume no 4KB length for MWr
        MWr_Leng_in_Bytes(C_TLP_FLD_WIDTH_OF_LENG+2 downto 2) <=
          Tlp_has_4KB & m_axis_rx_tdata_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT);
      else
        MWr_Leng_in_Bytes <= MWr_Leng_in_Bytes;
      end if;
    end if;
  end process;

-- ----------------------------------------------
--  Synchronous outputs:  DDR Space Select     --
-- ----------------------------------------------
  RxFSM_Output_DDR_Space_Selected :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      DDR_Space_Sel      <= '0';
      DDR_wr_sof_i       <= '0';
      DDR_wr_eof_i       <= '0';
      DDR_wr_v_i         <= '0';
      DDR_wr_FA_i        <= '0';
      DDR_wr_Shift_i     <= '0';
      DDR_wr_Mask_i      <= (others => '0');
      DDR_wr_din_i       <= (others => '0');
      ddr_wr_1st_mask_hi <= '0';

    elsif user_clk'event and user_clk = '1' then

      case RxMWrTrn_State is

        when ST_MWr3_HEAD2 =>
          if m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1'
            and Tlp_is_Zero_Length = '0'
          then
            DDR_Space_Sel      <= '1';
            DDR_wr_sof_i       <= '1';
            DDR_wr_eof_i       <= '0';
            DDR_wr_v_i         <= m_axis_rx_tvalid_i;
            DDR_wr_FA_i        <= '0';
            DDR_wr_Shift_i     <= not m_axis_rx_tdata_i(2);
            DDR_wr_Mask_i      <= (others => '0');
            ddr_wr_1st_mask_hi <= '1';
            DDR_wr_din_i       <= MWr_Leng_in_Bytes(31 downto 0) & m_axis_rx_tdata_i(31 downto 0);
          else
            DDR_Space_Sel      <= '0';
            DDR_wr_sof_i       <= '0';
            DDR_wr_eof_i       <= '0';
            DDR_wr_v_i         <= '0';
            DDR_wr_FA_i        <= '0';
            DDR_wr_Shift_i     <= '0';
            DDR_wr_Mask_i      <= (others => '0');
            ddr_wr_1st_mask_hi <= '0';
            DDR_wr_din_i       <= MWr_Leng_in_Bytes(31 downto 0) & m_axis_rx_tdata_i(31 downto 0);
          end if;

        when ST_MWr4_HEAD2 =>
          if m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1'
            and Tlp_is_Zero_Length = '0'
          then
            DDR_Space_Sel      <= '1';
            DDR_wr_sof_i       <= '1';
            DDR_wr_eof_i       <= '0';
            DDR_wr_v_i         <= m_axis_rx_tvalid_i;
            DDR_wr_FA_i        <= '0';
            DDR_wr_Shift_i     <= m_axis_rx_tdata_i(2+32);
            DDR_wr_Mask_i      <= (others => '0');
            ddr_wr_1st_mask_hi <= '0';
            DDR_wr_din_i       <= MWr_Leng_in_Bytes(31 downto 0) & m_axis_rx_tdata_i(63 downto 32);
          else
            DDR_Space_Sel      <= '0';
            DDR_wr_sof_i       <= '0';
            DDR_wr_eof_i       <= '0';
            DDR_wr_v_i         <= '0';
            DDR_wr_FA_i        <= '0';
            DDR_wr_Shift_i     <= '0';
            DDR_wr_Mask_i      <= (others => '0');
            ddr_wr_1st_mask_hi <= '0';
            DDR_wr_din_i       <= MWr_Leng_in_Bytes(31 downto 0) & m_axis_rx_tdata_i(63 downto 32);
          end if;

        when ST_MWr4_1ST_DATA =>
          DDR_Space_Sel      <= DDR_Space_Sel;
          DDR_wr_sof_i       <= '0';
          DDR_wr_eof_i       <= '0';
          DDR_wr_v_i         <= '0';
          DDR_wr_FA_i        <= '0';
          DDR_wr_Shift_i     <= '0';
          DDR_wr_Mask_i      <= (others => '0');
          ddr_wr_1st_mask_hi <= '0';
          DDR_wr_din_i       <= (others => '0');


        when others =>
          if m_axis_rx_tlast_r1 = '1' then
            DDR_Space_Sel <= '0';
          else
            DDR_Space_Sel <= DDR_Space_Sel;
          end if;

          if DDR_Space_Sel = '1' then
            DDR_wr_sof_i   <= '0';
            DDR_wr_eof_i   <= m_axis_rx_tlast_r1;
            DDR_wr_v_i     <= not trn_rx_throttle_r1;  -- m_axis_rx_tvalid_r1;
            DDR_wr_FA_i    <= '0';
            DDR_wr_Shift_i <= '0';
            DDR_wr_Mask_i  <= not(m_axis_rx_tkeep_r1(4)) & (not(m_axis_rx_tkeep_r1(0)) or ddr_wr_1st_mask_hi);
            DDR_wr_din_i   <= Endian_Invert_64 (m_axis_rx_tdata_r1(63 downto 32) & m_axis_rx_tdata_r1(31 downto 0));
          else
            DDR_wr_sof_i   <= '0';
            DDR_wr_eof_i   <= '0';
            DDR_wr_v_i     <= '0';
            DDR_wr_FA_i    <= '0';
            DDR_wr_Shift_i <= '0';
            DDR_wr_Mask_i  <= (others => '0');
            DDR_wr_din_i   <= Endian_Invert_64 (m_axis_rx_tdata_r1(63 downto 32) & m_axis_rx_tdata_r1(31 downto 0));
          end if;
          if DDR_wr_v_i = '1' then
            ddr_wr_1st_mask_hi <= '0';
          else
            ddr_wr_1st_mask_hi <= ddr_wr_1st_mask_hi;
          end if;

      end case;

    end if;

  end process;

-- ----------------------------------------------
--  Synchronous outputs:  DGen Table write     --
-- ----------------------------------------------
  RxFSM_Output_DGen_Table_write :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      --  Assume every PIO MWr contains only 1 DW(32 bits) payload
      dg_table_Sel <= '0';
      tab_we_i     <= (others => '0');
      tab_wa_i     <= (others => '0');
      tab_wd_i     <= (others => '0');
      tab_wa_odd   <= '0';

    elsif user_clk'event and user_clk = '1' then

      case RxMWrTrn_State is

        when ST_MWr3_HEAD2 =>
          if m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1'
            and Tlp_is_Zero_Length = '0'
          then
            dg_table_Sel <= m_axis_rx_tdata_i(19+32) and m_axis_rx_tdata_i(18+32) and not m_axis_rx_tdata_i(17+32) and not m_axis_rx_tdata_i(16+32);  -- any expression
            tab_we_i     <= (m_axis_rx_tdata_i(19) and m_axis_rx_tdata_i(18) and not m_axis_rx_tdata_i(17) and not m_axis_rx_tdata_i(16) and not m_axis_rx_tdata_i(2))
                              & (m_axis_rx_tdata_i(19) and m_axis_rx_tdata_i(18) and not m_axis_rx_tdata_i(17) and not m_axis_rx_tdata_i(16) and m_axis_rx_tdata_i(2));
            tab_wa_i   <= m_axis_rx_tdata_i(3+11 downto 3);
            tab_wa_odd <= m_axis_rx_tdata_i(2);
            tab_wd_i   <= Endian_Invert_64 ((m_axis_rx_tdata_i(63 downto 32) & m_axis_rx_tdata_i(63 downto 32)));
          else
            dg_table_Sel <= '0';
            tab_we_i     <= (others => '0');
            tab_wa_i     <= m_axis_rx_tdata_i(3+11 downto 3);
            tab_wa_odd   <= m_axis_rx_tdata_i(2);
            tab_wd_i     <= Endian_Invert_64 ((m_axis_rx_tdata_i(63 downto 32) & m_axis_rx_tdata_i(63 downto 32)));
          end if;

        when ST_MWr4_HEAD2 =>
          if m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1'
            and Tlp_is_Zero_Length = '0'
          then
            dg_table_Sel <= m_axis_rx_tdata_i(32+19) and m_axis_rx_tdata_i(32+18) and not m_axis_rx_tdata_i(32+17) and not m_axis_rx_tdata_i(32+16);
            tab_we_i     <= (others => '0');
            tab_wa_i     <= m_axis_rx_tdata_i(32+3+11 downto 32+3);
            tab_wa_odd   <= m_axis_rx_tdata_i(32+2);
            tab_wd_i     <= Endian_Invert_64 ((m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata_i(31 downto 0)));
          else
            dg_table_Sel <= '0';
            tab_we_i     <= (others => '0');
            tab_wa_i     <= m_axis_rx_tdata_i(32+3+11 downto 32+3);
            tab_wa_odd   <= m_axis_rx_tdata_i(32+2);
            tab_wd_i     <= Endian_Invert_64 ((m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata_i(31 downto 0)));
          end if;

        when ST_MWr4_1ST_DATA =>
          dg_table_Sel <= dg_table_Sel;
          tab_we_i     <= (dg_table_Sel and not trn_rx_throttle and not tab_wa_odd)
                            & (dg_table_Sel and not trn_rx_throttle and tab_wa_odd);
          tab_wa_i   <= tab_wa_i;
          tab_wa_odd <= tab_wa_odd;
          tab_wd_i   <= Endian_Invert_64 ((m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata_i(31 downto 0)));

        when ST_MWr_1ST_DATA_THROTTLE =>
          dg_table_Sel <= dg_table_Sel;
          tab_we_i     <= (dg_table_Sel and not trn_rx_throttle and not tab_wa_odd)
                            & (dg_table_Sel and not trn_rx_throttle and tab_wa_odd);
          tab_wa_i   <= tab_wa_i;
          tab_wa_odd <= tab_wa_odd;
          tab_wd_i   <= Endian_Invert_64 ((m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata_i(31 downto 0)));

        when others =>
          dg_table_Sel <= '0';
          tab_we_i     <= (others => '0');
          tab_wa_i     <= tab_wa_i;
          tab_wa_odd   <= tab_wa_odd;
          tab_wd_i     <= Endian_Invert_64 ((m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata_i(31 downto 0)));

      end case;

    end if;

  end process;

-- ----------------------------------------------
--  Synchronous outputs:  WB FIFO Select       --
-- ----------------------------------------------
  RxFSM_Output_FIFO_Space_Selected :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      FIFO_Space_Sel <= '0';
      wb_FIFO_we_i   <= '0';
      wb_FIFO_wsof_i <= '0';
      wb_FIFO_weof_i <= '0';
      wb_FIFO_din_i  <= (others => '0');

    elsif user_clk'event and user_clk = '1' then

      case RxMWrTrn_State is

        when ST_MWr3_HEAD2 =>
          if m_axis_rx_tbar_hit_r1(CINT_FIFO_SPACE_BAR) = '1'
            and Tlp_is_Zero_Length = '0'
          then
            FIFO_Space_Sel <= '1';
            wb_FIFO_we_i   <= '1';
            wb_FIFO_wsof_i <= '1';
            wb_FIFO_weof_i <= '0';
            wb_FIFO_din_i  <= MWr_Leng_in_Bytes(31 downto 0) & m_axis_rx_tdata_i(31 downto 0);
          else
            FIFO_Space_Sel <= '0';
            wb_FIFO_we_i   <= '0';
            wb_FIFO_wsof_i <= '0';
            wb_FIFO_weof_i <= '0';
            wb_FIFO_din_i  <= MWr_Leng_in_Bytes(31 downto 0) & m_axis_rx_tdata_i(31 downto 0);
          end if;

        when ST_MWr_1ST_DATA =>
          FIFO_Space_Sel <= FIFO_Space_Sel;
          wb_FIFO_we_i   <= '0';
          wb_FIFO_wsof_i <= '0';
          wb_FIFO_weof_i <= '0';
          wb_FIFO_din_i  <= Endian_Invert_64((m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata_r1(63 downto 32)));


        when ST_MWr4_HEAD2 =>
          if m_axis_rx_tbar_hit_r1(CINT_FIFO_SPACE_BAR) = '1'
            and Tlp_is_Zero_Length = '0'
          then
            FIFO_Space_Sel <= '1';
            wb_FIFO_we_i   <= m_axis_rx_tvalid_i;
            wb_FIFO_wsof_i <= '1';
            wb_FIFO_weof_i <= '0';
            wb_FIFO_din_i  <= MWr_Leng_in_Bytes(31 downto 0) & m_axis_rx_tdata_i(63 downto 32);
          else
            FIFO_Space_Sel <= '0';
            wb_FIFO_we_i   <= '0';
            wb_FIFO_wsof_i <= '0';
            wb_FIFO_weof_i <= '0';
            wb_FIFO_din_i  <= (others => '0');
          end if;

        when ST_MWr4_1ST_DATA =>
          FIFO_Space_Sel <= '0';
          wb_FIFO_we_i   <= '0';  -- trn_rx_throttle;
          wb_FIFO_wsof_i <= '0';  -- trn_rx_throttle;
          wb_FIFO_weof_i <= '0';  -- trn_rx_throttle;
          wb_FIFO_din_i  <= wb_FIFO_din_i;

        when others =>
          if m_axis_rx_tlast_r1 = '1' then
            FIFO_Space_Sel <= '0';
          else
            FIFO_Space_Sel <= FIFO_Space_Sel;
          end if;
          if FIFO_Space_Sel = '1' then
            wb_FIFO_wsof_i <= '0';
            wb_FIFO_weof_i <= m_axis_rx_tlast_r1;
            wb_FIFO_we_i   <= not trn_rx_throttle_r1;  -- m_axis_rx_tvalid_r1;
            wb_FIFO_din_i  <= Endian_Invert_64(m_axis_rx_tdata_r1(63 downto 32) & m_axis_rx_tdata_r1(31 downto 0));
          else
            wb_FIFO_wsof_i <= '0';
            wb_FIFO_weof_i <= '0';
            wb_FIFO_we_i   <= '0';
            wb_FIFO_din_i  <= Endian_Invert_64 (m_axis_rx_tdata_r1(63 downto 32) & m_axis_rx_tdata_r1(31 downto 0));
          end if;

      end case;

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
      if (m_axis_rx_tvalid and m_axis_rx_tready) = '1' then
        in_packet_reg <= not(m_axis_rx_tlast);
      end if;
    end if;
  end process;
  trn_rsof_n_i <= not(m_axis_rx_tvalid and not(in_packet_reg));

end architecture Behavioral;
