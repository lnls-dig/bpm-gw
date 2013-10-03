----------------------------------------------------------------------------------
-- Company:  ZITI
-- Engineer:  wgao
--
-- Create Date:    12:29:46 04/15/2008
-- Design Name:
-- Module Name:    bram_DDRs_Control - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;

library work;
use work.abb64Package.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DDRs_Control is
  generic (
    C_ASYNFIFO_WIDTH : integer := 72;
    DATA_WIDTH       : integer := 64;
    ADDR_WIDTH       : integer;
    P_SIMULATION     : string  := "FALSE";
    DDR_DQ_WIDTH     : integer;
    DDR_PAYLOAD_WIDTH : integer
    );
  port (
    -- FPGA interface --
    wr_clk   : in  std_logic;
    wr_eof   : in  std_logic;
    wr_v     : in  std_logic;
    wr_shift : in  std_logic;
    wr_mask  : in  std_logic_vector(2-1 downto 0);
    wr_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    wr_full  : out std_logic;

    rd_clk    : in  std_logic;
    rdc_v     : in  std_logic;
    rdc_shift : in  std_logic;
    rdc_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    rdc_full  : out std_logic;

    -- DDR payload FIFO Read Port
    rdd_fifo_rden  : in  std_logic;
    rdd_fifo_empty : out std_logic;
    rdd_fifo_dout  : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- Memory controller interface --
    memc_cmd_rdy   : in   std_logic;
    memc_cmd_en    : out  std_logic;
    memc_cmd_instr : out  std_logic_vector(2 downto 0);
    memc_cmd_addr  : out  std_logic_vector(ADDR_WIDTH-1 downto 0);
    memc_wr_en     : out  std_logic;
    memc_wr_end    : out  std_logic;
    memc_wr_mask   : out  std_logic_vector(DDR_PAYLOAD_WIDTH/8-1 downto 0);
    memc_wr_data   : out  std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
    memc_wr_rdy    : in   std_logic;
    memc_rd_en     : out  std_logic;
    memc_rd_data   : in   std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
    memc_rd_valid  : in   std_logic;

    -- Memory arbiter interface
    memarb_acc_req : out std_logic;
    memarb_acc_gnt : in  std_logic;

    memc_ui_clk : in std_logic;
    ddr_rdy     : in std_logic;
    reset       : in std_logic
    );
end entity DDRs_Control;


architecture Behavioral of DDRs_Control is

  constant DDRAM_RDCNT_DECVAL  : integer := DDR_PAYLOAD_WIDTH/C_DBUS_WIDTH;--2DW counted
  constant DDRAM_ADDR_INCVAL   : integer := DDRAM_RDCNT_DECVAL*8;--byte counted
  constant DDRAM_ADDR_DECSHIFT : integer := C_DBUS_WIDTH/DDR_DQ_WIDTH;

  constant WPIPE_F2M_ASHIFT_BTOP : integer := integer(log2(real(DDR_PAYLOAD_WIDTH)))-4;
  constant WPIPE_F2M_ASHIFT_BBOT : integer := WPIPE_F2M_ASHIFT_BTOP-2;
  constant RPIPE_ASHIFT_BTOP     : integer := integer(log2(real(DDR_DQ_WIDTH)))-1;
  constant RPIPE_ASHIFT_BBOT     : integer := RPIPE_ASHIFT_BTOP-2;
  constant MEMC_ADDR_BBOT_LIMIT  : integer := integer(log2(real(DDR_PAYLOAD_WIDTH/DDR_DQ_WIDTH)));
  constant MEMC_ADDR_BTOP_LIMIT  : integer := 5 - MEMC_ADDR_BBOT_LIMIT; --change C_DDR_IAWIDTH and it will break

  -- ----------------------------------------------------------------------------
  --
  -- ----------------------------------------------------------------------------
  component prime_FIFO_plain
    port (
      wr_clk    : in  std_logic;
      wr_en     : in  std_logic;
      din       : in  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
      full      : out std_logic;
      prog_full : out std_logic;
      rd_clk    : in  std_logic;
      rd_en     : in  std_logic;
      dout      : out std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
      empty     : out std_logic;
      rst       : in  std_logic
      );
  end component;

  COMPONENT sfifo_15x128
    PORT (
      clk        : IN STD_LOGIC;
      rst        : IN STD_LOGIC;
      din        : IN STD_LOGIC_VECTOR(127 DOWNTO 0);
      wr_en      : IN STD_LOGIC;
      rd_en      : IN STD_LOGIC;
      dout       : OUT STD_LOGIC_VECTOR(127 DOWNTO 0);
      full       : OUT STD_LOGIC;
      empty      : OUT STD_LOGIC;
      prog_full  : OUT STD_LOGIC;
      prog_empty : OUT STD_LOGIC
      );
  END COMPONENT;

  --  -- ---------------------------------------------------------------------
  signal Rst_i : std_logic;
  signal rst_n : std_logic;
  --  -- ---------------------------------------------------------------------
  --  -- ---------------------------------------------------------------------

  --   write State machine
  type ddr_wrStates is (wrST_bram_RESET
                          , wrST_Idle
                          , wrST_ACC_REQ
                          , wrST_Address
                          , wrST_1st_Data
                          , wrST_1st_Data_b2b
                          , wrST_more_Data
                          , wrST_last_Dw
                          );

  -- State variables
  signal DDR_wr_state : ddr_wrStates;

  -- -- --  Write Pipe Channel
  signal wpipe_wEn          : std_logic;
  signal wpipe_Din          : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal wpipe_aFull        : std_logic;
  signal wpipe_Full         : std_logic;
  signal wpipe_rEn          : std_logic;
  signal wpipe_rd_en        : std_logic;
  signal wpipe_ren_stopnow  : std_logic;
  signal wpipe_Qout         : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal wpipe_Empty        : std_logic;
  signal wpipe_Qout_latch   : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal wpipe_qout_lo32b   : std_logic_vector(33-1 downto 0);
  signal wpipe_qout_hi32b   : std_logic_vector(33-1 downto 0);
  signal wpipe_QW_Aligned   : std_logic;
  signal wpipe_read_valid   : std_logic;
  signal wpipe_wr_en        : std_logic;
  signal ddram_wr_data      : std_logic_vector(memc_wr_data'range);
  signal ddram_wr_addr      : unsigned(C_DDR_IAWIDTH-1 downto 0);
  signal ddram_wr_valid     : std_logic;
  signal ddram_wr_mask      : std_logic_vector(memc_wr_mask'range);
  signal ddram_wr_cmd_valid : std_logic;
  signal wpipe_f2m_empty    : std_logic;
  signal wpipe_f2m_empty_r1 : std_logic;
  signal wpipe_f2m_empty_r2 : std_logic;
  signal wpipe_f2m_qout     : std_logic_vector(127 downto 0);
  signal wpipe_f2m_din      : std_logic_vector(127 downto 0) := (others => '0');
  signal wpipe_f2m_rd_en    : std_logic;
  signal wpipe_f2m_rd       : std_logic;
  signal wpipe_f2m_rd_fin   : std_logic;
  signal wpipe_f2m_cnt      : unsigned(3 downto 0);
  signal wpipe_wr_mask      : std_logic_vector(DATA_WIDTH/8-1 downto 0);
  signal wpipe_wr_data      : std_logic_vector(DATA_WIDTH-1 downto 0);
  signal wpipe_wr_sof       : std_logic;
  signal wpipe_wr_pause     : std_logic;
  signal wpipe_f2m_full     : std_logic;
  signal wpipe_f2m_valid    : std_logic;
  signal wpipe_arb_req      : std_logic;
  signal wpipe_f2m_arb_req  : std_logic;
  signal wpipe_wr_eof       : std_logic;
  signal wpipe_fill_eof     : std_logic;
  signal pRAM_addra_inc     : std_logic;
  signal wpipe_f2m_shift_start : unsigned(2 downto 0);

  --   read State machine
  type ddr_rdstates is (rdst_RESET
                         , rdst_IDLE
                         , rdst_ACC_REQ
                         , rdst_b4_LA
                         , rdst_LA
                         , rdst_CMD
                         , rdst_DATA
                         , rdst_WAIT
                         , rdst_LAST_QW
                         );

  -- State variables
  signal DDR_rd_state : ddr_rdstates;

  signal rpiped_rd_cnt         : unsigned(C_TLP_FLD_WIDTH_OF_LENG-2 downto 0); --2DW counter
  signal rpiped_rd_cnt_latch   : unsigned(rpiped_rd_cnt'range);
  signal rpiped_wr_EOF         : std_logic;
  signal rpipec_read_valid     : std_logic;
  signal rpiped_wr_skew        : std_logic;
  signal rpiped_written        : std_logic;
  signal rpiped_written_r      : std_logic;
  signal rpiped_written_r2     : std_logic;
  signal rpiped_rdconv_cnt     : unsigned(4 downto 0);
  signal rpiped_rd_shift_start : unsigned(5 downto 0) := (others => '0');
  signal rpiped_omit           : std_logic;
  signal rpiped_omit_skew      : std_logic;

  -- -- --  Read Pipe Command Channel
  signal rpipec_wEn    : std_logic;
  signal rpipec_Din    : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal rpipec_aFull  : std_logic;
  signal rpipec_rEn    : std_logic;
  signal rpipec_Qout   : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal rpipec_Empty  : std_logic;
  signal ddram_rd_addr : unsigned(C_DDR_IAWIDTH-1 downto 0);
  signal rpipe_arb_req : std_logic;

  -- -- --  Read Pipe Data Channel
  signal rpiped_wen      : std_logic;
  signal rpiped_wen_last : std_logic := '0';
  signal rpiped_wr_en    : std_logic;
  signal rpiped_Din      : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal rpiped_aFull    : std_logic;
  signal rpiped_Qout     : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);

  -- DDR UI & width conversion signals
  signal memc_rd_addr      : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal memc_rd_cmd       : std_logic;
  signal memc_rd_data_r1   : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal memc_rd_data_r2   : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal memc_rd_data_r3   : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal memc_rd_data_conv : std_logic_vector(DDR_PAYLOAD_WIDTH-1 downto 0);
  signal memc_rd_shift_r   : std_logic_vector(31 downto 0);
  signal memc_wr_addr      : unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
  signal memc_wr_data_en   : std_logic;
  signal memc_wr_cmd_en    : std_logic;
  signal memarb_acc_req_i  : std_logic;

begin

  Rst_i <= reset or not(ddr_rdy);
  rst_n <= not(rst_i);

  -- memc_*_addr address LSb is DQ_WIDTH aligned, but addresses passed to DDR core need to be PAYLOAD_WIDTH aligned
  -- while ddram_*_addr have byte alignment
  memc_rd_addr(ADDR_WIDTH-1 downto MEMC_ADDR_BBOT_LIMIT) <= '0' &
    ddram_rd_addr(ddram_rd_addr'left downto WPIPE_F2M_ASHIFT_BTOP+1);
  memc_wr_addr(ADDR_WIDTH-1 downto MEMC_ADDR_BBOT_LIMIT) <= '0' &
    ddram_wr_addr(ddram_wr_addr'left downto RPIPE_ASHIFT_BTOP+1);

  memc_cmd_en      <= memc_rd_cmd or memc_wr_cmd_en;
  memc_cmd_instr   <= "00" & memc_rd_cmd;
  memc_cmd_addr    <= std_logic_vector(memc_wr_addr) when memc_wr_cmd_en = '1' else std_logic_vector(memc_rd_addr);
  memc_wr_en       <= memc_wr_data_en;
  memc_wr_end      <= memc_wr_data_en;
  memc_wr_data     <= ddram_wr_data;
  memc_wr_mask     <= ddram_wr_mask;
  memarb_acc_req_i <= wpipe_arb_req or wpipe_f2m_arb_req or rpipe_arb_req;
  memarb_acc_req   <= memarb_acc_req_i;

  -- ----------------------------------------------------------------------------
  --
  -- ----------------------------------------------------------------------------
  DDR_pipe_write_fifo :
    prime_FIFO_plain
      port map(
        wr_clk    => wr_clk,         -- IN  std_logic;
        wr_en     => wpipe_wEn,        -- IN  std_logic;
        din       => wpipe_Din,        -- IN  std_logic_VECTOR(35 downto 0);
        prog_full => wpipe_aFull,      -- OUT std_logic;
        full      => wpipe_Full,       -- OUT std_logic;

        rd_clk => memc_ui_clk,            -- IN  std_logic;
        rd_en  => wpipe_rd_en,           -- IN  std_logic;
        dout   => wpipe_Qout,          -- OUT std_logic_VECTOR(35 downto 0);
        empty  => wpipe_Empty,         -- OUT std_logic;

        rst => Rst_i                    -- IN  std_logic
        );

  wpipe_wEn <= wr_v;
  wpipe_Din <= wr_mask & wr_shift & '0' & '0' & wr_eof & '0' & '0' & wr_din;
  wr_full   <= wpipe_aFull;
  wpipe_rd_en <= wpipe_rEn and not(wpipe_ren_stopnow) and not(wpipe_f2m_full);
  -- ----------------------------------------------------------------------------
  --
  -- ----------------------------------------------------------------------------
  DDR_pipe_write_f2m_fifo :
    sfifo_15x128
      PORT MAP (
        clk        => memc_ui_clk,
        rst        => Rst_i,
        din        => wpipe_f2m_din,
        wr_en      => wpipe_wr_en,
        rd_en      => wpipe_f2m_rd_en,
        dout       => wpipe_f2m_qout,
        full       => open,
        empty      => wpipe_f2m_empty,
        prog_full  => wpipe_f2m_full,
        prog_empty => open
        );

  wpipe_f2m_din(74-1 downto 0) <= wpipe_wr_eof & wpipe_wr_sof & wpipe_wr_mask & wpipe_wr_data;
  --stall FIFO readout when data was written, but command wasn't yet
  --or if EOF bit is valid
  --or if it's last word in a DDR_PAYLOAD_WIDTH block
  wpipe_f2m_rd_en <= wpipe_f2m_rd and memc_wr_rdy and not(not(ddram_wr_valid) and ddram_wr_cmd_valid)
                     and not(wpipe_f2m_qout(73) and wpipe_f2m_valid)
                     and wpipe_f2m_rd_fin;

  wpipe_f2m_rd_fin <= '0' when wpipe_f2m_cnt >= (DDR_PAYLOAD_WIDTH/C_DBUS_WIDTH - 1) and wpipe_f2m_valid = '1' else '1';
  --keep requesting arbiter access if there's any data left to write
  wpipe_f2m_arb_req <= '1' when ((wpipe_f2m_cnt /= 0) or wpipe_f2m_empty_r2 = '0' or wpipe_f2m_empty_r1 = '0'
                       or wpipe_f2m_empty = '0') else '0';
  memc_wr_data_en   <= ddram_wr_valid;
  memc_wr_cmd_en    <= ddram_wr_cmd_valid;
  -- ----------------------------------------------------------------------------
  --
  -- ----------------------------------------------------------------------------
  DDR_pipe_read_C_fifo :
    prime_FIFO_plain
      port map(
        wr_clk    => rd_clk,         -- IN  std_logic;
        wr_en     => rpipec_wEn,       -- IN  std_logic;
        din       => rpipec_Din,       -- IN  std_logic_VECTOR(35 downto 0);
        prog_full => rpipec_aFull,     -- OUT std_logic;
        full      => open,  --rpipec_Full    , -- OUT std_logic;

        rd_clk => memc_ui_clk,            -- IN  std_logic;
        rd_en  => rpipec_rEn,          -- IN  std_logic;
        dout   => rpipec_Qout,         -- OUT std_logic_VECTOR(35 downto 0);
        empty  => rpipec_Empty,        -- OUT std_logic;

        rst => Rst_i                    -- IN  std_logic
        );

  rpipec_wEn <= rdc_v;
  rpipec_Din <= "00" & rdc_shift & '0' & '0' & '0' & '0' & '0' & rdc_din;
  rdc_full   <= rpipec_aFull;

  -- ----------------------------------------------------------------------------
  --
  -- ----------------------------------------------------------------------------
  DDR_pipe_read_D_fifo :
    prime_FIFO_plain
      port map(
        wr_clk    => memc_ui_clk,         -- IN  std_logic;
        wr_en     => rpiped_wr_en,       -- IN  std_logic;
        din       => rpiped_Din,       -- IN  std_logic_VECTOR(35 downto 0);
        prog_full => rpiped_aFull,     -- OUT std_logic;
        full      => open,  -- rpiped_Full     , -- OUT std_logic;

        rd_clk => rd_clk,            -- IN  std_logic;
        rd_en  => rdd_fifo_rden,       -- IN  std_logic;
        dout   => rpiped_Qout,         -- OUT std_logic_VECTOR(35 downto 0);
        empty  => rdd_fifo_empty,      -- OUT std_logic;

        rst => Rst_i                    -- IN  std_logic
        );

  rdd_fifo_dout <= rpiped_Qout(C_DBUS_WIDTH-1 downto 0);
  rpiped_wr_en <= rpiped_wen or rpiped_wen_last;

-- ------------------------------------------------
-- write States synchronous
--
  DDR_wr_States :
  process (memc_ui_clk, rst_i)
  begin
    if rst_i = '1' then
      DDR_wr_state  <= wrST_bram_RESET;
      wpipe_rEn     <= '0';
      wpipe_wr_en   <= '0';
      wpipe_arb_req <= '0';

    elsif memc_ui_clk'event and memc_ui_clk = '1' then

      case DDR_wr_state is

        when wrST_bram_RESET =>
          DDR_wr_state  <= wrST_Idle;
          wpipe_rEn     <= '0';
          wpipe_wr_en   <= '0';
          wpipe_arb_req <= '0';

        when wrST_Idle =>
          wpipe_rEn     <= '0';
          wpipe_wr_en   <= '0';
          wpipe_arb_req <= '0';
          --don't request access if memory read is in progress
          if wpipe_Empty = '0' and rpipe_arb_req = '0' then
            DDR_wr_state <= wrST_ACC_REQ;
          else
            DDR_wr_state <= wrST_Idle;
          end if;

        when wrST_ACC_REQ =>
          wpipe_rEn     <= '0';
          wpipe_wr_en   <= '0';
          wpipe_arb_req <= '1';
          if memarb_acc_gnt = '1' then
            DDR_wr_state <= wrST_Address;
          else
            DDR_wr_state <= wrST_ACC_REQ;
          end if;

        when wrST_Address =>
          pRAM_AddrA_Inc   <= wpipe_Qout(2);
          wpipe_QW_Aligned <= not wpipe_Qout(69);
          wpipe_qout_lo32b <= (32 => '1', others => '0');
          wpipe_qout_hi32b <= (32 => '1', others => '0');
          wpipe_wr_mask    <= (others => '1');
          wpipe_wr_data    <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
          wpipe_rEn        <= not(wpipe_f2m_full);
          wpipe_arb_req    <= '1';
          wpipe_wr_sof     <= '1';
          wpipe_wr_eof     <= '0';
          if wpipe_read_valid = '1' then
            DDR_wr_state <= wrST_1st_Data;
            wpipe_wr_en  <= '1';
          else
            DDR_wr_state <= wrST_Address;
            wpipe_wr_en  <= '0';
          end if;

        when wrST_1st_Data =>
          wpipe_rEn     <= not(wpipe_wr_pause or wpipe_f2m_full) and pRAM_AddrA_Inc;
          wpipe_arb_req <= '1';
          wpipe_wr_sof  <= '0';

          if wpipe_read_valid = '0' then
            DDR_wr_state  <= wrST_1st_Data;
            wpipe_wr_mask <= wpipe_wr_mask;
            wpipe_wr_data <= wpipe_wr_data;
            wpipe_wr_en   <= '0';
          elsif wpipe_Qout(66) = '1' then            -- eof
            wpipe_wr_en <= '1';
            if wpipe_QW_Aligned = '1' then
              DDR_wr_state  <= wrST_Idle;
              wpipe_wr_eof  <= '1';
              wpipe_rEn     <= '0';
              wpipe_wr_mask <= (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              wpipe_wr_data <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
            elsif wpipe_Qout(70) = '1' then          -- mask(0)
              DDR_wr_state  <= wrST_Idle;
              wpipe_wr_eof  <= '1';
              wpipe_rEn     <= '0';
              wpipe_wr_mask <= (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              wpipe_wr_data <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
            elsif wpipe_Qout(71) = '1' then          -- mask(1)
              DDR_wr_state  <= wrST_Idle;
              wpipe_wr_eof  <= '1';
              wpipe_rEn     <= '0';
              wpipe_wr_mask <= X"0" & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32);
              wpipe_wr_data <= wpipe_Qout(C_DBUS_WIDTH-1-32 downto 0) & wpipe_qout_hi32b(32-1 downto 0);
            else
              DDR_wr_state     <= wrST_last_Dw;
              wpipe_wr_eof     <= '0';
              wpipe_wr_mask    <= (wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                                  & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                                  & wpipe_qout_lo32b(32));
              wpipe_wr_data    <= wpipe_Qout(C_DBUS_WIDTH/2-1 downto 0) & wpipe_qout_lo32b(32-1 downto 0);
              wpipe_qout_hi32b <= wpipe_Qout(71) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
            end if;
          else
            wpipe_wr_eof <= '0';
            wpipe_qout_hi32b <= wpipe_Qout(71) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
            if wpipe_QW_Aligned = '1' then
              DDR_wr_state  <= wrST_more_Data;
              wpipe_wr_en   <= '1';
              wpipe_wr_mask <= (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              wpipe_wr_data <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
            elsif pRAM_AddrA_Inc = '1' then
              DDR_wr_state  <= wrST_more_Data;
              wpipe_wr_en   <= '1';
              wpipe_wr_mask <= (wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                               & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32)
                               & wpipe_qout_hi32b(32));
              wpipe_wr_data    <= wpipe_Qout(32-1 downto 0) & wpipe_qout_hi32b(32-1 downto 0);
              wpipe_qout_lo32b <= wpipe_Qout(70) & wpipe_Qout(32-1 downto 0);
            else
              DDR_wr_state     <= wrST_1st_Data;
              wpipe_wr_en      <= '0';
              pRAM_AddrA_Inc   <= '1';
              wpipe_wr_mask    <= X"FF";
              wpipe_wr_data    <= wpipe_wr_data;
              wpipe_qout_lo32b <= wpipe_Qout(70) & wpipe_Qout(32-1 downto 0);
            end if;
          end if;

        when wrST_more_Data =>
          wpipe_rEn     <= not(wpipe_wr_pause or wpipe_f2m_full);
          wpipe_arb_req <= '1';
          wpipe_wr_sof  <= '0';

          if wpipe_read_valid = '0' then
            DDR_wr_state  <= wrST_more_Data;  -- wrST_1st_Data;
            wpipe_wr_mask <= (others => '1');      --wpipe_wr_mask;
            wpipe_wr_data <= wpipe_wr_data;
            wpipe_wr_en   <= '0';
          elsif wpipe_Qout(66) = '1' then                -- eof
            wpipe_wr_en      <= '1';
            wpipe_rEn        <= '0'; --!!! insert 1 cycle break, so the state machine can catch up with data flow
            wpipe_qout_hi32b <= wpipe_Qout(71) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
            if wpipe_QW_Aligned = '1' then
              DDR_wr_state  <= wrST_Idle;
              wpipe_wr_eof  <= '1';
              wpipe_rEn     <= '0';
              wpipe_wr_mask <= (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              wpipe_wr_data  <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
            elsif wpipe_Qout(70) = '1' then              -- mask(0)
              DDR_wr_state  <= wrST_Idle;
              wpipe_wr_eof  <= '1';
              wpipe_rEn     <= '0';
              wpipe_wr_mask <= (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              wpipe_wr_data <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
            elsif wpipe_Qout(71) = '1' then -- mask(1)
              DDR_wr_state  <= wrST_Idle;
              wpipe_wr_eof  <= '1';
              wpipe_wr_mask <= (wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                               & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32)
                               & wpipe_qout_hi32b(32));
              wpipe_wr_data    <= wpipe_Qout(32-1 downto 0) & wpipe_qout_hi32b(32-1 downto 0);
            else
              DDR_wr_state  <= wrST_last_Dw;
              wpipe_wr_eof  <= '0';
              wpipe_wr_mask <= (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              wpipe_wr_data    <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
              wpipe_qout_lo32b <= '0' & wpipe_Qout(32-1 downto 0);
            end if;
          else
            wpipe_wr_en      <= '1';
            wpipe_wr_eof     <= '0';
            wpipe_qout_hi32b <= wpipe_Qout(71) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
            if wpipe_QW_Aligned = '1' then
              DDR_wr_state  <= wrST_more_Data;
              wpipe_wr_mask <= (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              wpipe_wr_data <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
            else
              DDR_wr_state  <= wrST_more_Data;
              --wpipe_wr_mask <= (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
              --wpipe_wr_mask <= wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               --& wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70);
              wpipe_wr_mask <= (wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70)
                               & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32) & wpipe_qout_hi32b(32)
                               & wpipe_qout_hi32b(32));
              wpipe_wr_data    <= wpipe_Qout(32-1 downto 0) & wpipe_qout_hi32b(32-1 downto 0);
              wpipe_qout_lo32b <= '0' & wpipe_Qout(32-1 downto 0);
            end if;
          end if;

        when wrST_last_Dw =>
          wpipe_rEn     <= '0';
          DDR_wr_state  <= wrST_Idle;
          wpipe_wr_mask <= X"F0";
          wpipe_wr_data <= wpipe_Qout(32-1 downto 0) & wpipe_qout_hi32b(32-1 downto 0);
          wpipe_wr_en   <= '1';
          wpipe_arb_req <= '1';
          wpipe_wr_sof  <= '0';
          wpipe_wr_eof  <= '1';

        when others =>
          DDR_wr_state     <= wrST_bram_RESET;
          wpipe_wr_mask    <= (others => '1');
          wpipe_wr_data    <= (others => '0');
          wpipe_qout_lo32b <= (others => '0');
          wpipe_QW_Aligned <= '1';
          wpipe_wr_en      <= '0';
          pRAM_AddrA_Inc   <= '1';
          wpipe_arb_req    <= '0';

      end case;

    end if;
  end process;

  --
  Syn_wPipe_read :
  process (memc_ui_clk, rst_n)
  begin
    if rst_n = '0' then
      wpipe_read_valid <= '0';
    elsif memc_ui_clk'event and memc_ui_clk = '1' then
      wpipe_read_valid <= wpipe_rd_en and not wpipe_Empty;
    end if;
  end process;
  -- we have to stop reading FIFO in the same clock cycle that valid EOF flag is present,
  -- otherwise we lose one word
  wpipe_ren_stopnow <= wpipe_read_valid and wpipe_Qout(66);

  Syn_wPipe_f2m :
  process (memc_ui_clk, rst_n)
  begin
    if rst_n = '0' then
      wpipe_f2m_valid    <= '0';
      wpipe_f2m_empty_r1 <= '0';
      wpipe_f2m_empty_r2 <= '0';
    elsif rising_edge(memc_ui_clk) then
      wpipe_f2m_valid    <= wpipe_f2m_rd_en and not wpipe_f2m_empty;
      wpipe_f2m_empty_r1 <= wpipe_f2m_empty;
      wpipe_f2m_empty_r2 <= wpipe_f2m_empty_r1;
    end if;
  end process;

  Syn_wPipe_memc_wr :
  process (memc_ui_clk, rst_n)
  begin
    if rising_edge(memc_ui_clk) then
      if rst_n = '0' then
        wpipe_f2m_rd    <= '0';
        ddram_wr_valid  <= '0';
        ddram_wr_cmd_valid <= '0';
        wpipe_f2m_cnt   <= (others => '0');
        wpipe_fill_eof  <= '0';
      else
        wpipe_wr_pause  <= not(memc_cmd_rdy);
        ddram_wr_addr   <= ddram_wr_addr;
        ddram_wr_valid  <= ddram_wr_valid;
        ddram_wr_cmd_valid <= ddram_wr_cmd_valid;
        if wpipe_f2m_cnt = DDR_PAYLOAD_WIDTH/C_DBUS_WIDTH then
          wpipe_f2m_rd   <= '0';
          wpipe_f2m_cnt  <= wpipe_f2m_cnt;
          wpipe_fill_eof <= '0';
          if memc_wr_rdy = '1' and ddram_wr_valid = '1' then
            ddram_wr_valid <= '0';
          end if;
          if memc_cmd_rdy = '1' and ddram_wr_cmd_valid = '1' then
            ddram_wr_cmd_valid <= '0';
            wpipe_f2m_cnt      <= (others => '0');
            ddram_wr_addr      <= ddram_wr_addr + DDRAM_ADDR_INCVAL - wpipe_f2m_shift_start;
            wpipe_f2m_shift_start <= (others => '0'); --no longer needed after 1st write
          end if;
        else
          ddram_wr_valid     <= '0';
          ddram_wr_cmd_valid <= '0';
          if wpipe_fill_eof = '0' then
            wpipe_f2m_rd   <= '1';
            wpipe_fill_eof <= wpipe_fill_eof;
            if wpipe_f2m_valid = '1' then
              ddram_wr_data(to_integer(wpipe_f2m_cnt+1)*C_DBUS_WIDTH - 1 downto to_integer(wpipe_f2m_cnt)*C_DBUS_WIDTH) <=
                wpipe_f2m_qout(DATA_WIDTH-1 downto 0);
              ddram_wr_mask(to_integer(wpipe_f2m_cnt+1)*C_DBUS_WIDTH/8 - 1 downto to_integer(wpipe_f2m_cnt)*C_DBUS_WIDTH/8) <=
                wpipe_f2m_qout(DATA_WIDTH+8-1 downto DATA_WIDTH);
              if wpipe_f2m_qout(73) = '1' then --wpipe_wr_eof
                wpipe_fill_eof <= '1';
                wpipe_f2m_rd   <= '0';
              end if;
              if wpipe_f2m_qout(72) = '1' then --wpipe_wr_sof
                --because first write access can be unaligned with respect to DDR core PAYLOAD_WIDTH
                --we have to preload respective registers with correct values
                wpipe_f2m_cnt         <= (others => '0');
                wpipe_f2m_cnt(WPIPE_F2M_ASHIFT_BBOT-1 downto 0) <=
                  unsigned(wpipe_f2m_qout(WPIPE_F2M_ASHIFT_BTOP downto 3));
                ddram_wr_mask         <= (others => '1');
                ddram_wr_addr         <= unsigned(wpipe_f2m_qout(C_DDR_IAWIDTH-1 downto 0));
                wpipe_f2m_shift_start <= unsigned(wpipe_f2m_qout(WPIPE_F2M_ASHIFT_BTOP downto WPIPE_F2M_ASHIFT_BBOT));
              else
                wpipe_f2m_cnt <= wpipe_f2m_cnt + 1;
              end if;
              if wpipe_f2m_cnt = (DDR_PAYLOAD_WIDTH/C_DBUS_WIDTH - 1) then
                ddram_wr_valid     <= '1';
                ddram_wr_cmd_valid <= '1';
                wpipe_f2m_rd       <= '0';
              end if;
            else
              wpipe_f2m_cnt <= wpipe_f2m_cnt;
              ddram_wr_data <= ddram_wr_data;
              ddram_wr_mask <= ddram_wr_mask;
            end if;
          else
            ddram_wr_data <= ddram_wr_data;
            ddram_wr_mask(to_integer(wpipe_f2m_cnt+1)*C_DBUS_WIDTH/8 - 1 downto to_integer(wpipe_f2m_cnt)*C_DBUS_WIDTH/8) <= x"FF";
            wpipe_f2m_cnt <= wpipe_f2m_cnt + 1;
            wpipe_f2m_rd  <= '0';
            if wpipe_f2m_cnt = (DDR_PAYLOAD_WIDTH/C_DBUS_WIDTH - 1) then
              ddram_wr_valid     <= '1';
              ddram_wr_cmd_valid <= '1';
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

  --
  Syn_rPipeC_read :
  process (memc_ui_clk, rst_n)
  begin
    if rst_n = '0' then
      rpipec_read_valid <= '0';
      rpiped_wr_skew    <= '0';
    elsif memc_ui_clk'event and memc_ui_clk = '1' then
      rpipec_read_valid <= rpipec_rEn and not rpipec_Empty;
      if rpipec_read_valid = '1' then
        rpiped_wr_skew <= rpipec_Qout(69) and not(rpipec_Qout(2));
      else
        rpiped_wr_skew <= rpiped_wr_skew;
      end if;
    end if;
  end process;

-- ------------------------------------------------
-- Read States synchronous
--
  DDR_rd_States :
  process (memc_ui_clk, rst_n)
  begin
    if rst_n = '0' then
      DDR_rd_state  <= rdst_RESET;
      rpipec_rEn    <= '0';
      ddram_rd_addr <= (others => '0');
      rpiped_rd_cnt <= (others => '0');
      rpiped_wr_EOF <= '0';
      memc_rd_cmd   <= '0';

    elsif memc_ui_clk'event and memc_ui_clk = '1' then

      case DDR_rd_state is

        when rdst_RESET =>
          DDR_rd_state    <= rdst_IDLE;
          rpipec_rEn      <= '0';
          ddram_rd_addr   <= (others => '0');
          rpiped_rd_cnt   <= (others => '0');
          rpiped_wr_EOF   <= '0';
          rpipe_arb_req   <= '0';
          memc_rd_cmd     <= '0';
          rpiped_wen_last <= '0';

        when rdst_IDLE =>
          ddram_rd_addr   <= (others => '0');
          rpiped_rd_cnt   <= (others => '0');
          rpiped_wr_EOF   <= rpiped_wr_EOF;
          rpipec_rEn      <= '0';
          memc_rd_cmd     <= '0';
          rpiped_wen_last <= '0';
          --don't start if our module has write operation running
          if rpipec_Empty = '0' and memarb_acc_req_i = '0' then
            rpipe_arb_req <= '1';
            DDR_rd_state  <= rdst_ACC_REQ;
          else
            rpipe_arb_req <= '0';
            DDR_rd_state  <= rdst_IDLE;
          end if;

        when rdst_ACC_REQ =>
          ddram_rd_addr <= (others => '0');
          rpiped_rd_cnt <= (others => '0');
          rpiped_wr_EOF <= '0';
          rpipe_arb_req <= '1';
          memc_rd_cmd   <= '0';
          if memarb_acc_gnt = '1' then
            rpipec_rEn   <= '1';
            DDR_rd_state <= rdst_b4_LA;
          else
            rpipec_rEn   <= '0';
            DDR_rd_state <= rdst_ACC_REQ;
          end if;

        when rdst_b4_LA =>
          ddram_rd_addr <= (others => '0');
          rpiped_rd_cnt <= (others => '0');
          rpiped_wr_EOF <= '0';
          rpipec_rEn    <= '0';
          rpipe_arb_req <= '1';
          memc_rd_cmd   <= '0';
          DDR_rd_state  <= rdst_LA;

        when rdst_LA =>
          rpipec_rEn    <= '0';
          ddram_rd_addr <= unsigned(rpipec_Qout(C_DDR_IAWIDTH - 1 downto 0));
          rpiped_rd_shift_start(RPIPE_ASHIFT_BBOT-1 downto 0) <= unsigned(rpipec_Qout(RPIPE_ASHIFT_BTOP downto 3));
          rpiped_wr_EOF <= '0';
          rpipe_arb_req <= '1';
          memc_rd_cmd   <= '0';
          -- because we operate on QW data chunks, add one in case of odd number of DW to read
          if rpipec_Qout(69) = '1' then --rdc_shift
            rpiped_rd_cnt <= unsigned(rpipec_Qout(11+32 downto 3+32)) + 1;
          else
            rpiped_rd_cnt <= unsigned(rpipec_Qout(11+32 downto 3+32)) + unsigned(rpipec_Qout(2+32 downto 2+32));
          end if;
          DDR_rd_state  <= rdst_CMD;

        when rdst_CMD =>
          rpipec_rEn    <= '0';
          ddram_rd_addr <= ddram_rd_addr;
          rpiped_wr_EOF <= '0';
          rpipe_arb_req <= '1';
          rpiped_rd_cnt <= rpiped_rd_cnt;
          if memc_cmd_rdy = '1' and memc_rd_cmd = '1' then
            memc_rd_cmd  <= '0';
            DDR_rd_state <= rdst_DATA;
          else
            memc_rd_cmd  <= '1';
            DDR_rd_state <= rdst_CMD;
          end if;

        when rdst_DATA =>
          rpipec_rEn    <= '0';
          rpipe_arb_req <= '1';
          memc_rd_cmd   <= '0';
          DDR_rd_state  <= DDR_rd_state;
          if rpiped_rd_cnt <= to_unsigned(DDRAM_RDCNT_DECVAL, rpiped_rd_cnt'length) then
            rpiped_wr_EOF <= '1';
            rpiped_rd_cnt <= rpiped_rd_cnt;
            ddram_rd_addr <= ddram_rd_addr;
            if memc_rd_valid = '1' then --wait until data arrives before relinquishing access
              if (rpiped_rd_shift_start >= DDRAM_RDCNT_DECVAL - 1) and rpiped_rd_cnt(0) = '0' then
                --reading last QW from PAYLOAD_WIDTH block needs a bit of special handling
                DDR_rd_state <= rdst_LAST_QW;
              else
                DDR_rd_state <= rdst_IDLE;
              end if;
            end if;
          else
            rpiped_wr_EOF <= '0';
            if memc_rd_valid = '1' then
              DDR_rd_state <= rdst_WAIT;
            end if;
          end if;

        when rdst_WAIT =>
          if rpiped_written = '1' then
            -- if read access data_count/address combination spans across more than one DDR_PAYLOAD_WIDTH,
            -- we try to make only the first access unaligned, rpiped_rd_shift_start should be equal 0
            -- after first access
            ddram_rd_addr <= ddram_rd_addr + DDRAM_ADDR_INCVAL - rpiped_rd_shift_start*DDRAM_ADDR_DECSHIFT;
            rpiped_rd_cnt <= rpiped_rd_cnt - DDRAM_RDCNT_DECVAL + rpiped_rd_shift_start;
            rpiped_rd_shift_start <= (others => '0');
            DDR_rd_state  <= rdst_CMD;
          else
            ddram_rd_addr <= ddram_rd_addr;
            rpiped_rd_cnt <= rpiped_rd_cnt;
            DDR_rd_state  <= rdst_WAIT;
          end if;

        when rdst_LAST_QW =>
          if rpiped_wen = '1' then
            rpiped_wen_last <= '1';
            DDR_rd_state    <= rdst_IDLE;
          end if;

        when others =>
          rpipec_rEn    <= '0';
          ddram_rd_addr <= ddram_rd_addr;
          rpiped_rd_cnt <= rpiped_rd_cnt;
          rpiped_wr_EOF <= '0';
          rpipe_arb_req <= '0';
          memc_rd_cmd   <= '0';
          DDR_rd_state  <= rdst_RESET;

      end case;

    end if;
  end process;

  DDR_rdd_write :
  process (memc_ui_clk, rst_n)
  begin
    if rst_n = '0' then
      rpiped_wen        <= '0';
      rpiped_written_r  <= '1';
      rpiped_rdconv_cnt <= (others => '1');
    else
      if rising_edge(memc_ui_clk) then
        rpiped_written_r  <= rpiped_written;
        rpiped_written_r2 <= rpiped_written_r;
        if memc_rd_valid = '1' then
          memc_rd_data_r1     <= memc_rd_data_conv;
          rpiped_rd_cnt_latch <= rpiped_rd_cnt + rpiped_rd_shift_start;
          --FIXME: assuming that DATAWIDTH is multiple of DBUS_WIDTH
          rpiped_rdconv_cnt   <= (others => '0');
        end if;
        if rpiped_written_r = '0' and rpiped_afull = '0' then
          rpiped_rdconv_cnt <= rpiped_rdconv_cnt + 1;
          --memc_rd_data_r1   <= memc_rd_data_r1(memc_rd_data_r1'left - C_DBUS_WIDTH downto 0) & (others => '0');
          memc_rd_data_r1(memc_rd_data_r1'left downto C_DBUS_WIDTH) <=
            memc_rd_data_r1(memc_rd_data_r1'left - C_DBUS_WIDTH downto 0);
          memc_rd_data_r1(C_DBUS_WIDTH -1 downto 0) <= (others => '0');
          memc_rd_shift_r <= memc_rd_data_r1(memc_rd_data_r1'left - 32 downto memc_rd_data_r1'left - C_DBUS_WIDTH + 1);
        end if;
        if (rpiped_written_r or rpiped_afull) = '0' then
          memc_rd_data_r2 <= memc_rd_data_r1;
        end if;
        if (rpiped_written_r or rpiped_written_r2 or rpiped_afull) = '0' then
          memc_rd_data_r3 <= memc_rd_data_r2;
        end if;
        if rpiped_wr_skew = '1' then
          rpiped_wen <= not(rpiped_written_r or rpiped_written_r2 or rpiped_afull) and not(rpiped_omit_skew);
          rpiped_Din <= "0000" & '0' & (rpiped_wr_EOF and rpiped_written) & "00" & memc_rd_shift_r &
                        memc_rd_data_r3(memc_rd_data_r3'left downto memc_rd_data_r3'left - 32+1);
        else
          rpiped_wen <= not(rpiped_written or rpiped_written_r or rpiped_afull) and not(rpiped_omit);
          rpiped_Din <= "0000" & '0' & (rpiped_wr_EOF and rpiped_written) & "00" &
                        memc_rd_data_r1(memc_rd_data_r1'left downto memc_rd_data_r1'left - C_DBUS_WIDTH+1);
        end if;
      end if;
    end if;
  end process;
  rpiped_written <= '1' when rpiped_rdconv_cnt >= (rpiped_rd_cnt_latch) or
                            rpiped_rdconv_cnt >= DDR_PAYLOAD_WIDTH/C_DBUS_WIDTH else '0';

  rpiped_omit_skew <= '1' when rpiped_rd_shift_start >= rpiped_rdconv_cnt else '0';
  rpiped_omit      <= '1' when rpiped_rd_shift_start > rpiped_rdconv_cnt else '0';

  --FIXME: assuming that DATAWIDTH is multiple of DBUS_WIDTH
  memc_rd_data_connect:
  for i in 0 to DDR_PAYLOAD_WIDTH/C_DBUS_WIDTH -1 generate
    constant ratio : integer := DDR_PAYLOAD_WIDTH/C_DBUS_WIDTH;
  begin
    memc_rd_data_conv((ratio - i)*C_DBUS_WIDTH-1 downto ((ratio - i - 1)*C_DBUS_WIDTH)) <=
      memc_rd_data(C_DBUS_WIDTH*(i+1) - 1 downto C_DBUS_WIDTH*i);
  end generate;

end architecture Behavioral;
