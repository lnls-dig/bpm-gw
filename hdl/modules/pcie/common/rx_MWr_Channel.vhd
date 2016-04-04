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
use IEEE.STD_LOGIC_MISC.all;

library work;
use work.abb64Package.all;
use work.genram_pkg.all;

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
    MWr_Type    : in std_logic_vector(1 downto 0);
    Tlp_has_4KB : in std_logic;
    mwr_ready   : out std_logic;

    -- Event Buffer write port
    wb_FIFO_we   : out std_logic;
    wb_FIFO_wsof : out std_logic;
    wb_FIFO_weof : out std_logic;
    wb_FIFO_din  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wb_FIFO_full : in std_logic;

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

  constant C_IS_HDR_BIT : integer := C_DBUS_WIDTH;
  constant C_DDR_HIT_BIT : integer := C_IS_HDR_BIT+1;
  constant C_WB_HIT_BIT : integer := C_DDR_HIT_BIT+1;
  constant C_TLAST_BIT : integer := C_WB_HIT_BIT+1;
  constant C_TKEEP_BBOT : integer := C_TLAST_BIT+1;
  constant C_TKEEP_BTOP : integer := C_TKEEP_BBOT+7;
  constant C_ELBUF_WIDTH : integer := C_TKEEP_BTOP+1;
  --CMD will fit into DBUS_WIDTH without problem
  constant C_CMD_SADDR_BBOT : integer := 0;
  constant C_CMD_SADDR_BTOP : integer := 31;
  constant C_CMD_BTT_BBOT : integer := C_CMD_SADDR_BTOP+1;
  constant C_CMD_BTT_BTOP : integer := C_CMD_BTT_BBOT+22;
  constant C_CMD_DRR_BIT : integer := C_CMD_BTT_BTOP+1;
  constant C_CMD_EOF_BIT : integer := C_CMD_DRR_BIT+1;

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
  
  type t_ddr_wr_state is (st_idle,
                          st_cmd,
                          st_data);
                            
  signal ddr_wr_state : t_ddr_wr_state;

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

  signal m_axis_rx_tvalid_i : std_logic;
  signal trn_rsof_n_i       : std_logic;
  signal in_packet_reg      : std_logic;
  signal mwr_ready_i        : std_logic;
  signal m_axis_rx_tlast_i  : std_logic;
  signal m_axis_rx_tlast_r1 : std_logic;
  signal m_axis_rx_tlast_r2 : std_logic;

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
  signal ddr_s2mm_tlast_i : STD_LOGIC;

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

  signal trn_rx_throttle, trn_rx_throttle_r : std_logic;

  -- 1st DW BE = "0000" means the TLP is of zero-length.
  signal MWr_Has_4DW_Header : std_logic;
  signal Tlp_is_Zero_Length : std_logic;
  signal MWr_Leng_in_Bytes  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal mwr_nwords_even_r : std_logic;
  
  --signals of elastic buffer used to accomodate for handshaking delays between DDR/WB "ready" signals
  --and PCIe core data pipeline
  signal elbuf_din : std_logic_vector(C_ELBUF_WIDTH-1 downto 0) := (others => '0');
  signal elbuf_we : std_logic;
  signal elbuf_dout : std_logic_vector(C_ELBUF_WIDTH-1 downto 0);
  signal elbuf_re, elbuf_re_r, elbuf_re_st : std_logic;
  signal elbuf_empty, elbuf_empty_r, elbuf_afull : std_logic;
  
  signal user_reset_n : std_logic;

begin
  
  user_reset_n <= not(user_reset);
  
  mwr_ready <= mwr_ready_i;
  
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
  ddr_s2mm_tlast <= ddr_s2mm_tlast_i;

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
                            (m_axis_rx_tdata_i(31 downto 0) & m_axis_rx_tdata_r1(63 downto 32));
  m_axis_rx_tkeep_fixed <= m_axis_rx_tkeep_r1 when MWr_Has_4DW_Header = '1' else
                            (m_axis_rx_tkeep_i(3 downto 0) & m_axis_rx_tkeep_r1(7 downto 4));

  -- Output to the core as handshaking
  m_axis_rx_tbar_hit_i <= m_axis_rx_tbar_hit;

  -- Output to the core as handshaking
  m_axis_rx_tvalid_i <= m_axis_rx_tvalid;
  m_axis_rx_tready_i <= m_axis_rx_tready;

  -- ( m_axis_rx_tvalid seems never deasserted during packet)
  trn_rx_throttle <= not(m_axis_rx_tvalid_i) or not(m_axis_rx_tready_i);

-- elastic buffer used to accomodate for handshaking delays between DDR/WB "ready" signals
-- and PCIe core data pipeline

  elbuf:
    generic_sync_fifo
      generic map(
        g_data_width => C_ELBUF_WIDTH,
        g_size => 32,
        g_show_ahead => false,
        g_with_empty => true,
        g_with_full => false,
        g_with_almost_empty => false,
        g_with_almost_full => true,
        g_with_count => false,
        g_almost_full_threshold => 24,
        g_with_fifo_inferred => true)
      port map(
        rst_n_i => user_reset_n,
        clk_i => user_clk,
        d_i => elbuf_din,
        we_i => elbuf_we,
        q_o => elbuf_dout,
        rd_i => elbuf_re,
        empty_o => elbuf_empty,
        full_o => open,
        almost_empty_o => open,
        almost_full_o => elbuf_afull,
        count_o => open
        );
        
-- -----------------------------------------------------
--   Delays: m_axis_rx_tdata_i, m_axis_rx_tbar_hit_i, m_axis_rx_tlast_i
-- -----------------------------------------------------
  Sync_Delays_m_axis_rx_tdata_rbar_reof :
  process (user_clk)
  begin
    if rising_edge(user_clk) then
      trn_rx_throttle_r <= trn_rx_throttle;
      
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
    variable tkeep_hmask : std_logic_vector(3 downto 0) := x"0";
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        DDR_space_sel <= '0';
      else
        elbuf_we <= '0';
        elbuf_din <= (others => '0');
        
        case RxMWrTrn_State is
  
          when ST_MWr3_HEAD2 =>
            if m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1'
              and Tlp_is_Zero_Length = '0'
            then
              DDR_Space_Sel <= '1';
              elbuf_din(C_IS_HDR_BIT) <= '1';
              elbuf_din(C_CMD_EOF_BIT) <= '1';
              elbuf_din(C_CMD_DRR_BIT) <= '1';
              elbuf_din(C_CMD_BTT_BTOP downto C_CMD_BTT_BBOT) <= MWr_leng_in_bytes(22 downto 0);
              elbuf_din(C_DDR_HIT_BIT) <= '1';
              elbuf_din(C_CMD_SADDR_BTOP downto C_CMD_SADDR_BBOT) <= sdram_pg(31-C_DDR_PG_WIDTH downto 0) &
                                                                     m_axis_rx_tdata_i(C_DDR_PG_WIDTH-1 downto 0);
              elbuf_we <= not trn_rx_throttle;
              for i in 0 to 3 loop
                tkeep_hmask(i) := not(mwr_leng_in_bytes(2));
              end loop; 
            else
              DDR_Space_Sel <= '0';
              elbuf_we <= '0';
            end if;
                  
          when ST_MWr4_HEAD2 =>
            if m_axis_rx_tbar_hit_r1(CINT_DDR_SPACE_BAR) = '1'
              and Tlp_is_Zero_Length = '0'
            then
              DDR_Space_Sel <= '1';
              elbuf_din(C_IS_HDR_BIT) <= '1';
              elbuf_din(C_CMD_EOF_BIT) <= '1';
              elbuf_din(C_CMD_DRR_BIT) <= '1';
              elbuf_din(C_CMD_BTT_BTOP downto C_CMD_BTT_BBOT) <= MWr_leng_in_bytes(22 downto 0);
              elbuf_din(C_DDR_HIT_BIT) <= '1';
              elbuf_din(C_CMD_SADDR_BTOP downto C_CMD_SADDR_BBOT) <= sdram_pg(31-C_DDR_PG_WIDTH downto 0) &
                                                                     m_axis_rx_tdata_i(32+C_DDR_PG_WIDTH-1 downto 32);
              elbuf_we <= not trn_rx_throttle;
              tkeep_hmask := x"F";
            else
              DDR_Space_Sel <= '0';
              elbuf_we <= '0';
            end if;
            
          --skip over 1st data word because for 4DW hdr we take data from a pipelined stream
          when st_mwr4_1st_data =>
            null;
  
          when others =>
            if trn_rx_throttle_r = '0' and DDR_space_sel = '1' then
            --clear at the end of packet
              ddr_space_sel <= not(m_axis_rx_tlast_r1);
            end if;

            if DDR_Space_Sel = '1' then
              elbuf_din(C_IS_HDR_BIT) <= '0';
              elbuf_din(C_DDR_HIT_BIT) <= '1';
              elbuf_din(C_WB_HIT_BIT) <= '0';
              elbuf_din(C_TKEEP_BTOP downto C_TKEEP_BBOT) <= endian_invert_tkeep(m_axis_rx_tkeep_fixed) and (tkeep_hmask & x"F");
              elbuf_din(C_DBUS_WIDTH-1 downto 0) <= endian_invert_64(m_axis_rx_tdata_fixed);
              if mwr_has_4dw_header = '1' then
                elbuf_din(C_TLAST_BIT) <= m_axis_rx_tlast_r1;
                elbuf_we <= not trn_rx_throttle_r;
              else
                elbuf_din(C_TLAST_BIT) <= (or_reduce(tkeep_hmask) and m_axis_rx_tlast_i) or m_axis_rx_tlast_r1;
                elbuf_we <= (or_reduce(tkeep_hmask) and not(trn_rx_throttle))
                            or (not(trn_rx_throttle_r) and or_reduce(m_axis_rx_tkeep_fixed(3 downto 0)) and m_axis_rx_tlast_r1);                
              end if;
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
            
          --skip over 1st data word because for 4DW hdr we take data from a pipelined stream
          when st_mwr4_1st_data =>
            wb_fifo_we_i <= '0';
            wb_FIFO_wsof_i <= '0';
  
          when others =>
            if m_axis_rx_tlast_r1 = '1' and trn_rx_throttle_r = '0' then
              FIFO_Space_Sel <= '0';
            else
              FIFO_Space_Sel <= FIFO_Space_Sel;
            end if;
            if FIFO_Space_Sel = '1' then
              wb_FIFO_wsof_i <= '0';
              wb_FIFO_weof_i <= (not(mwr_has_4dw_header) and (m_axis_rx_tlast_i or m_axis_rx_tlast_r1))
                                or (mwr_has_4dw_header and m_axis_rx_tlast_r1);
              wb_FIFO_we_i   <= not trn_rx_throttle_r;
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
  
  ddr_write:
  process(user_clk)
    variable first_data : std_logic;
  begin
    if rising_edge(user_clk) then
      if user_reset = '1' then
        ddr_wr_state <= st_idle;
        elbuf_re_st <= '0';
        ddr_s2mm_cmd_tvalid_i <= '0';
        ddr_s2mm_tvalid_i <= '0';
      else
        
        case ddr_wr_state is
          when st_idle =>
            ddr_s2mm_cmd_tvalid_i <= '0';
            ddr_s2mm_tvalid_i <= '0';
            elbuf_re_st <= '1';
            if elbuf_empty = '0' and elbuf_re = '1' then
              ddr_wr_state <= st_cmd;
              elbuf_re_st <= '0';
            end if;
            
          when st_cmd =>
            ddr_s2mm_cmd_saddr <= elbuf_dout(C_CMD_SADDR_BTOP downto C_CMD_SADDR_BBOT);
            ddr_s2mm_cmd_btt <= elbuf_dout(C_CMD_BTT_BTOP downto C_CMD_BTT_BBOT);
            ddr_s2mm_cmd_eof <= elbuf_dout(C_CMD_EOF_BIT);
            ddr_s2mm_cmd_drr <= elbuf_dout(C_CMD_DRR_BIT);
            ddr_s2mm_cmd_tvalid_i <= elbuf_dout(C_IS_HDR_BIT) and elbuf_dout(C_DDR_HIT_BIT);
            elbuf_re_st <= '0';
            elbuf_empty_r <= '1';
            --check if this is really a header, something went horribly if it isn't
            if elbuf_dout(C_IS_HDR_BIT) = '0' then
              ddr_wr_state <= st_idle;
              elbuf_re_st <= '1';
            elsif elbuf_dout(C_IS_HDR_BIT) = '1' and elbuf_dout(C_DDR_HIT_BIT) = '1' and ddr_s2mm_cmd_tready = '1' then
              ddr_wr_state <= st_data;
              elbuf_re_st <= '1';
              first_data := '1';
            end if;
            
          when st_data =>
            ddr_s2mm_cmd_tvalid_i <= '0';
            ddr_s2mm_tlast_i <= elbuf_dout(C_TLAST_BIT);
            ddr_s2mm_tkeep <= elbuf_dout(C_TKEEP_BTOP downto C_TKEEP_BBOT);
            --stop reading if we are at the end of packet
            elbuf_re_st <= not(elbuf_empty) and not(elbuf_dout(C_TLAST_BIT));
            elbuf_empty_r <= elbuf_empty; --have to register only at data phase, otherwise tvalid will come too fast
            if (elbuf_empty = '0' and elbuf_re = '1') or elbuf_dout(C_TLAST_BIT) = '1' then
              --if it's the last word in a packet fifo will be already empty, so push last word unconditionally
              ddr_s2mm_tdata <= elbuf_dout(C_DBUS_WIDTH-1 downto 0);
              ddr_s2mm_tvalid_i <= not(ddr_s2mm_cmd_tvalid_i) and elbuf_re_r; --omit 1st word after command and align delay
              first_data := '0';
            else
              --keep valid to push word currently present on *_tdata, unless it's first word
              ddr_s2mm_tvalid_i <= not(ddr_s2mm_tready) and not(first_data);
            end if;
            if ddr_s2mm_tready = '1' and ddr_s2mm_tvalid_i = '1' and ddr_s2mm_tlast_i = '1' then
              ddr_wr_state <= st_idle;
              ddr_s2mm_tvalid_i <= '0';
              elbuf_re_st <= '1';
            end if;
          
        end case;
      end if;
    end if;
  end process;
  
  elbuf_delay:
  process(user_clk)
  begin
    if rising_edge(user_clk) then
      elbuf_re_r <= elbuf_re;
    end if;
  end process;
  
  --stop reading *in the same clock cycle* that receiver goes out-of-ready
  --or it's last word in packet. Otherwise we'll lose one word, usually a header
  elbuf_re <= (elbuf_re_st and ddr_s2mm_cmd_tready) when ddr_wr_state = st_idle else
              (elbuf_re_st and ddr_s2mm_tready and not(elbuf_dout(C_TLAST_BIT)));
  
  process(user_clk)
  begin
    if rising_edge(user_clk) then
      if DDR_space_sel = '1' then
        mwr_ready_i <= not(elbuf_afull);
      elsif FIFO_space_sel = '1' then
        mwr_ready_i <= not(wb_fifo_full);
      else
        mwr_ready_i <= '1';
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
