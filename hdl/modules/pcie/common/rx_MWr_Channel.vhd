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

    -- SDRAM and Wishbone address page
    sdram_pg : in std_logic_vector(31 downto 0);
    wb_pg    : in std_logic_vector(31 downto 0);

    -- from pre-process module
    MWr_Type          : in std_logic_vector(1 downto 0);
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
    ddr_s2mm_cmd_tvalid : out STD_LOGIC;
    ddr_s2mm_cmd_tready : in STD_LOGIC;
    ddr_s2mm_cmd_tdata : out STD_LOGIC_VECTOR(71 DOWNTO 0);
    ddr_s2mm_tdata : out STD_LOGIC_VECTOR(63 DOWNTO 0);
    ddr_s2mm_tkeep : out STD_LOGIC_VECTOR(7 DOWNTO 0);
    ddr_s2mm_tlast : out STD_LOGIC;
    ddr_s2mm_tvalid : out STD_LOGIC;
    ddr_s2mm_tready : in STD_LOGIC;

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
--                               , ST_MWr_LAST_DATA
                                 );

  -- State variables
  signal RxMWrTrn_NextState : RxMWrTrnStates;
  signal RxMWrTrn_State     : RxMWrTrnStates;

  -- trn_rx stubs
  signal m_axis_rx_tdata_i : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal m_axis_rx_tdata_r1 : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal m_axis_rx_tdata_r2 : std_logic_vector (C_DBUS_WIDTH-1 downto 0);
  signal m_axis_rx_tdata_fixed : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal m_axis_rx_tkeep_i  : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal m_axis_rx_tkeep_r1 : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal m_axis_rx_tkeep_r2 : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal m_axis_rx_tkeep_fixed : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);

  signal m_axis_rx_tbar_hit_i  : std_logic_vector (C_BAR_NUMBER-1 downto 0);
  signal m_axis_rx_tbar_hit_r1 : std_logic_vector (C_BAR_NUMBER-1 downto 0);

  signal m_axis_rx_tvalid_i  : std_logic;
  signal trn_rsof_n_i        : std_logic;
  signal in_packet_reg       : std_logic;
  signal m_axis_rx_tlast_i   : std_logic;
  signal m_axis_rx_tlast_r1  : std_logic;
  signal m_axis_rx_tlast_r2  : std_logic;

  -- packet RAM and packet FIFOs selection signals
  signal FIFO_Space_Sel : std_logic;
  signal DDR_Space_Sel  : std_logic;
  signal REGS_Space_Sel : std_logic;

  -- DDR write port
  signal ddr_s2mm_cmd_tvalid_i : STD_LOGIC;
  signal ddr_s2mm_cmd_btt : std_logic_vector(22 downto 0);
  signal ddr_s2mm_cmd_eof : std_logic;
  signal ddr_s2mm_cmd_drr : std_logic;
  signal ddr_s2mm_cmd_saddr : std_logic_vector(31 downto 0);
  signal ddr_s2mm_tvalid_i : STD_LOGIC;

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

  -- 1st DW BE = "0000" means the TLP is of zero-length.
  signal MWr_Has_4DW_Header : std_logic;
  signal Tlp_is_Zero_Length : std_logic;
  signal MWr_Leng_in_Bytes  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal mwr_nwords_even_r : std_logic;

begin

  -- Event Buffer write
  wb_FIFO_we   <= wb_FIFO_we_i;
  wb_FIFO_wsof <= wb_FIFO_wsof_i;
  wb_FIFO_weof <= wb_FIFO_weof_i;
  wb_FIFO_din  <= wb_FIFO_din_i;

  -- DDR
  ddr_s2mm_cmd_tvalid <= ddr_s2mm_cmd_tvalid_i;
  ddr_s2mm_cmd_tdata(22 downto 0) <= ddr_s2mm_cmd_btt;
  ddr_s2mm_cmd_tdata(23) <= '1'; --ddr_mm2s_cmd_type;
  ddr_s2mm_cmd_tdata(29 downto 24) <= "000000"; --ddr_mm2s_cmd_dsa;
  ddr_s2mm_cmd_tdata(30) <= ddr_s2mm_cmd_eof;
  ddr_s2mm_cmd_tdata(31) <= ddr_s2mm_cmd_drr;
  ddr_s2mm_cmd_tdata(63 downto 32) <= ddr_s2mm_cmd_saddr;
  ddr_s2mm_cmd_tdata(67 downto 64) <= "0000"; --tag
  ddr_s2mm_cmd_tdata(71 downto 68) <= (others => '0');
  ddr_s2mm_tvalid <= ddr_s2mm_tvalid_i;

  -- Registers writing
  Regs_WrEn   <= Regs_WrEn_i;
  Regs_WrMask <= Regs_WrMask_i;
  Regs_WrAddr <= Regs_WrAddr_i;
  Regs_WrDin  <= Regs_WrDin_i;          -- Mem_WrData;

  -- TLP info stubs
  m_axis_rx_tdata_i <= m_axis_rx_tdata;
  m_axis_rx_tlast_i <= m_axis_rx_tlast;
  m_axis_rx_tkeep_i <= m_axis_rx_tkeep;

  m_axis_rx_tdata_fixed <= m_axis_rx_tdata_r1 when MWr_Has_4DW_Header = '1' else
                            (m_axis_rx_tdata_r1(31 downto 0) & m_axis_rx_tdata_r2(63 downto 32));
  m_axis_rx_tkeep_fixed <= m_axis_rx_tkeep_r1 when MWr_Has_4DW_Header = '1' else
                            (m_axis_rx_tkeep_r1(3 downto 0) & m_axis_rx_tkeep_r2(7 downto 4));

  -- Output to the core as handshaking
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
    if rising_edge(user_clk) then
      if trn_rx_throttle = '0' then
        m_axis_rx_tlast_r1    <= m_axis_rx_tlast_i;
        m_axis_rx_tlast_r2    <= m_axis_rx_tlast_r1;
        m_axis_rx_tdata_r1    <= m_axis_rx_tdata_i;
        m_axis_rx_tdata_r2    <= m_axis_rx_tdata_r1;
        m_axis_rx_tkeep_r1    <= m_axis_rx_tkeep_i;
        m_axis_rx_tkeep_r2    <= m_axis_rx_tkeep_r1;
        m_axis_rx_tbar_hit_r1 <= m_axis_rx_tbar_hit_i;
      end if;
    end if;
  end process;

-- -----------------------------------------------------------------------
-- States synchronous
--
  Syn_RxTrn_States :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        RxMWrTrn_State <= ST_MWr_RESET;
      else
        RxMWrTrn_State <= RxMWrTrn_NextState;
      end if;
    end if;
  end process;


-- Next States
  Comb_RxTrn_NextStates :
  process (
    RxMWrTrn_State
    , MWr_Type
    , trn_rx_throttle
    , m_axis_rx_tlast_i
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
              RxMWrTrn_NextState <= ST_MWr_IDLE;
          end case;  -- MWr_Type
        else
          RxMWrTrn_NextState <= ST_MWr_IDLE;
        end if;

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
          RxMWrTrn_NextState <= ST_MWr_IDLE;
        else
          RxMWrTrn_NextState <= ST_MWr_DATA;
        end if;

      when ST_MWr_DATA_THROTTLE =>
        if trn_rx_throttle = '1' then
          RxMWrTrn_NextState <= ST_MWr_DATA_THROTTLE;
        elsif m_axis_rx_tlast_i = '1' then
          RxMWrTrn_NextState <= ST_MWr_IDLE;
        else
          RxMWrTrn_NextState <= ST_MWr_DATA;
        end if;

      when others =>
        RxMWrTrn_NextState <= ST_MWr_RESET;

    end case;

  end process;

-- ----------------------------------------------
-- registers Write Enable
--
  RxFSM_Output_Regs_Write_En :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        Regs_WrEn_i   <= '0';
        Regs_WrMask_i <= (others => '0');
        Regs_WrAddr_i <= (others => '1');
        Regs_WrDin_i  <= (others => '0');
      else
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
    end if;

  end process;

-- -----------------------------------------------------------------------
-- Capture: REGS_Space_Sel
--
  Syn_Capture_REGS_Space_Sel :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        REGS_Space_Sel <= '0';
      else
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
    end if;
  end process;

-- -----------------------------------------------------------------------
-- Capture: MWr_Has_4DW_Header
--        : Tlp_is_Zero_Length
--
  Syn_Capture_MWr_Has_4DW_Header :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        MWr_Has_4DW_Header <= '0';
        Tlp_is_Zero_Length <= '0';
      else
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
    end if;
  end process;

-- -----------------------------------------------------------------------
-- Capture: MWr_Leng_in_Bytes
--
  Syn_Capture_MWr_Length_in_Bytes :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        MWr_Leng_in_Bytes <= (others => '0');
      else
        if trn_rsof_n_i = '0' then
          -- Assume no 4KB length for MWr
          MWr_Leng_in_Bytes(C_TLP_FLD_WIDTH_OF_LENG+2 downto 2) <=
            Tlp_has_4KB & m_axis_rx_tdata_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT);
        else
          MWr_Leng_in_Bytes <= MWr_Leng_in_Bytes;
        end if;
      end if;
    end if;
  end process;
  
  process(user_clk)
  begin
    if rising_edge(user_clk) then
      mwr_nwords_even_r <= mwr_leng_in_bytes(2);
    end if;
  end process;

-- ----------------------------------------------
--  Synchronous outputs:  DDR Space Select     --
-- ----------------------------------------------
  RxFSM_Output_DDR_Space_Selected :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        ddr_s2mm_cmd_tvalid_i <= '0';
        ddr_s2mm_tvalid_i <= '0';
        DDR_space_sel <= '0';
      else
      
        ddr_s2mm_cmd_tvalid_i <= '0';
        ddr_s2mm_tvalid_i <= '0';
        if ddr_space_sel = '1' then
          ddr_s2mm_tdata <= endian_invert_64(m_axis_rx_tdata_fixed);
          ddr_s2mm_tkeep <= endian_invert_tkeep(m_axis_rx_tkeep_fixed);
          --r1 in 4DW hdr case, r1 or r2 in 3DW hdr case
          ddr_s2mm_tlast <= m_axis_rx_tlast_r1 or m_axis_rx_tlast_r2;
        end if;
        
        case RxMWrTrn_State is
  
          when ST_MWr3_HEAD2 =>
            if m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1'
              and Tlp_is_Zero_Length = '0'
            then
              DDR_Space_Sel <= '1';
              ddr_s2mm_cmd_tvalid_i <= not trn_rx_throttle;
              ddr_s2mm_cmd_btt <= MWr_leng_in_bytes(22 downto 0);
              ddr_s2mm_cmd_saddr <= sdram_pg(31-C_DDR_PG_WIDTH downto 0) &
                                    m_axis_rx_tdata_i(C_DDR_PG_WIDTH-1 downto 0);
              ddr_s2mm_cmd_eof <= '1';
              ddr_s2mm_cmd_drr <= '1';
            else
              DDR_Space_Sel <= '0';
            end if;
            --deal with the last data beat from previous TLP
            if trn_rx_throttle = '0' then
              ddr_s2mm_tvalid_i <= DDR_space_sel; 
            end if;
            
          when ST_MWr4_HEAD2 =>
            if m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1'
              and Tlp_is_Zero_Length = '0'
            then
              DDR_Space_Sel <= '1';
              ddr_s2mm_cmd_tvalid_i <= not trn_rx_throttle;
              ddr_s2mm_cmd_btt <= MWr_leng_in_bytes(22 downto 0);
              ddr_s2mm_cmd_saddr <= sdram_pg(31-C_DDR_PG_WIDTH downto 0) &
                                    m_axis_rx_tdata_i(32+C_DDR_PG_WIDTH-1 downto 32);
              ddr_s2mm_cmd_eof <= '1';
              ddr_s2mm_cmd_drr <= '1';
            else
              DDR_Space_Sel <= '0';
            end if;
            
          --skip over 1st data word because we take data from a pipelined stream
          when st_mwr4_1st_data =>
            null;
          when st_mwr_1st_data =>
            null;
  
          when others =>
            if trn_rx_throttle = '0' and DDR_space_sel = '1' then
            --clear at the end of packet
              ddr_space_sel <= not((m_axis_rx_tlast_r1 and ddr_s2mm_cmd_btt(2)) or
                                (m_axis_rx_tlast_r1 and not(ddr_s2mm_cmd_btt(2))));
            end if;

            if DDR_Space_Sel = '1' then
              ddr_s2mm_tvalid_i <= not trn_rx_throttle;
            end if;

        end case;
      end if;
    end if;

  end process;

-- ----------------------------------------------
--  Synchronous outputs:  WB FIFO Select       --
-- ----------------------------------------------
  RxFSM_Output_FIFO_Space_Selected :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        FIFO_Space_Sel <= '0';
        wb_FIFO_we_i   <= '0';
        wb_FIFO_wsof_i <= '0';
        wb_FIFO_weof_i <= '0';
        wb_FIFO_din_i  <= (others => '0');
      else
        case RxMWrTrn_State is
  
          when ST_MWr3_HEAD2 =>
            if m_axis_rx_tbar_hit_r1(CINT_FIFO_SPACE_BAR) = '1'
              and Tlp_is_Zero_Length = '0'
            then
              FIFO_Space_Sel <= '1';
              wb_FIFO_we_i   <= not trn_rx_throttle;
              wb_FIFO_wsof_i <= '1';
              wb_FIFO_weof_i <= '0';
              wb_FIFO_din_i  <= MWr_Leng_in_Bytes(31 downto 0) & wb_pg(31-C_WB_PG_WIDTH downto 0) &
                                m_axis_rx_tdata_i(C_WB_PG_WIDTH-1 downto 0);
            else
              FIFO_Space_Sel <= '0';
              wb_FIFO_we_i   <= '0';
              wb_FIFO_wsof_i <= '0';
              wb_FIFO_weof_i <= '0';
            end if;
  
          when ST_MWr_1ST_DATA =>
            FIFO_Space_Sel <= FIFO_Space_Sel;
            wb_FIFO_we_i   <= '0';
            wb_FIFO_wsof_i <= '0';
            wb_FIFO_weof_i <= '0';
            wb_FIFO_din_i  <= wb_FIFO_din_i;
  
  
          when ST_MWr4_HEAD2 =>
            if m_axis_rx_tbar_hit_r1(CINT_FIFO_SPACE_BAR) = '1'
              and Tlp_is_Zero_Length = '0'
            then
              FIFO_Space_Sel <= '1';
              wb_FIFO_we_i   <= not trn_rx_throttle;
              wb_FIFO_wsof_i <= '1';
              wb_FIFO_weof_i <= '0';
              wb_FIFO_din_i  <= MWr_Leng_in_Bytes(31 downto 0) & wb_pg(31-C_WB_PG_WIDTH downto 0) &
                                m_axis_rx_tdata_i(32+C_WB_PG_WIDTH-1 downto 32);
            else
              FIFO_Space_Sel <= '0';
              wb_FIFO_we_i   <= '0';
              wb_FIFO_wsof_i <= '0';
              wb_FIFO_weof_i <= '0';
            end if;
  
          when ST_MWr4_1ST_DATA =>
            FIFO_Space_Sel <= FIFO_Space_Sel;
            wb_FIFO_we_i   <= '0';
            wb_FIFO_wsof_i <= '0';
            wb_FIFO_weof_i <= '0';
            wb_FIFO_din_i  <= wb_FIFO_din_i;
  
          when others =>
            if m_axis_rx_tlast_r1 = '1' and trn_rx_throttle = '0' then
              FIFO_Space_Sel <= '0';
            else
              FIFO_Space_Sel <= FIFO_Space_Sel;
            end if;
            if FIFO_Space_Sel = '1' then
              wb_FIFO_wsof_i <= '0';
              wb_FIFO_weof_i <= m_axis_rx_tlast_r1;
              wb_FIFO_we_i   <= not trn_rx_throttle;
              wb_FIFO_din_i  <= Endian_Invert_64(m_axis_rx_tdata_fixed);
            else
              wb_FIFO_wsof_i <= '0';
              wb_FIFO_weof_i <= '0';
              wb_FIFO_we_i   <= '0';
              wb_FIFO_din_i  <= wb_FIFO_din_i;
            end if;
  
        end case;
      end if;
    end if;

  end process;

  -- ---------------------------------
  -- Regenerate trn_rsof_n signal as in old TRN core
  --
  TRN_rsof_n_make :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        in_packet_reg <= '0';
      else
        if (m_axis_rx_tvalid and m_axis_rx_tready) = '1' then
          in_packet_reg <= not(m_axis_rx_tlast);
        end if;
      end if;
    end if;
  end process;
  trn_rsof_n_i <= not(m_axis_rx_tvalid and not(in_packet_reg));

end architecture Behavioral;
