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
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.abb64Package.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram_DDRs_Control_loopback is
  generic (
    C_ASYNFIFO_WIDTH : integer := 72;
    P_SIMULATION     : boolean := true
    );
  port (

--           -- Pins
--           DDR_CLKn                 : OUT   std_logic;
--           DDR_CLK                  : OUT   std_logic;
--           DDR_CKE                  : OUT   std_logic;
--           DDR_CSn                  : OUT   std_logic;
--           DDR_RASn                 : OUT   std_logic;
--           DDR_CASn                 : OUT   std_logic;
--           DDR_WEn                  : OUT   std_logic;
--           DDR_BankAddr             : OUT   std_logic_vector(C_DDR_BANK_AWIDTH-1 downto 0);
--           DDR_Addr                 : OUT   std_logic_vector(C_DDR_AWIDTH-1 downto 0);
--           DDR_DM                   : OUT   std_logic_vector(C_DDR_DWIDTH/8-1 downto 0);
--           DDR_DQ                   : INOUT std_logic_vector(C_DDR_DWIDTH-1 downto 0);
--           DDR_DQS                  : INOUT std_logic_vector(C_DDR_DWIDTH/8-1 downto 0);

    -- DMA interface
    DDR_wr_sof   : in  std_logic;
    DDR_wr_eof   : in  std_logic;
    DDR_wr_v     : in  std_logic;
    DDR_wr_FA    : in  std_logic;
    DDR_wr_Shift : in  std_logic;
    DDR_wr_Mask  : in  std_logic_vector(2-1 downto 0);
    DDR_wr_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DDR_wr_full  : out std_logic;

    DDR_rdc_sof   : in  std_logic;
    DDR_rdc_eof   : in  std_logic;
    DDR_rdc_v     : in  std_logic;
    DDR_rdc_FA    : in  std_logic;
    DDR_rdc_Shift : in  std_logic;
    DDR_rdc_din   : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
    DDR_rdc_full  : out std_logic;

--           DDR_rdD_sof              : OUT   std_logic;
--           DDR_rdD_eof              : OUT   std_logic;
--           DDR_rdDout_V             : OUT   std_logic;
--           DDR_rdDout               : OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- DDR payload FIFO Read Port
    DDR_FIFO_RdEn   : in  std_logic;
    DDR_FIFO_Empty  : out std_logic;
    DDR_FIFO_RdQout : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

    -- Common interface
    DDR_Ready   : out std_logic;
    DDR_blinker : out std_logic;
    Sim_Zeichen : out std_logic;

    mem_clk    : in std_logic;
    user_clk   : in std_logic;
    user_reset : in std_logic
    );
end entity bram_DDRs_Control_loopback;


architecture Behavioral of bram_DDRs_Control_loopback is

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------
  component DDR_ClkGen
    port(
      ddr_Clock        : out std_logic;
      ddr_Clock_n      : out std_logic;
      ddr_Clock90      : out std_logic;
      ddr_Clock90_n    : out std_logic;
      Clk_ddr_rddata   : out std_logic;
      Clk_ddr_rddata_n : out std_logic;

      ddr_DCM_locked : out std_logic;

      clk_in     : in std_logic;
      user_reset : in std_logic
      );
  end component;

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------

  component asyn_rw_FIFO72
--    GENERIC (
--             OUTPUT_REGISTERED  : BOOLEAN
--            );
    port(
      wClk  : in  std_logic;
      wEn   : in  std_logic;
      Din   : in  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
      aFull : out std_logic;
      Full  : out std_logic;

      rClk   : in  std_logic;
      rEn    : in  std_logic;
      Qout   : out std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
      aEmpty : out std_logic;
      Empty  : out std_logic;

      Rst : in std_logic
      );
  end component;

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

--  component fifo_512x36_v4_2
--    port (
--    wr_clk      : IN  std_logic;
--    wr_en       : IN  std_logic;
--    din         : IN  std_logic_VECTOR(35 downto 0);
--    prog_full   : OUT std_logic;
--    full        : OUT std_logic;
--
--    rd_clk      : IN  std_logic;
--    rd_en       : IN  std_logic;
--    dout        : OUT std_logic_VECTOR(35 downto 0);
--    prog_empty  : OUT std_logic;
--    empty       : OUT std_logic;
--
--    rst         : IN  std_logic
--    );
--  end component;

  component fifo_512x72_v4_4
    port (
      wr_clk    : in  std_logic;
      wr_en     : in  std_logic;
      din       : in  std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
      prog_full : out std_logic;
      full      : out std_logic;

      rd_clk : in  std_logic;
      rd_en  : in  std_logic;
      dout   : out std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
--    prog_empty  : OUT std_logic;
      empty  : out std_logic;

      rst : in std_logic
      );
  end component;

  ---- Dual-port block RAM for packets
  ---    Core output registered
  --
--  component v5bram4096x32
--    port (
--      clka           : IN  std_logic;
--      addra          : IN  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
--      wea            : IN  std_logic_vector(0 downto 0);
--      dina           : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--      douta          : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--
--      clkb           : IN  std_logic;
--      addrb          : IN  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
--      web            : IN  std_logic_vector(0 downto 0);
--      dinb           : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
--      doutb          : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0)
--    );
--  end component;

  component bram_x64
    port (
      clka  : in  std_logic;
      addra : in  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
      wea   : in  std_logic_vector(7 downto 0);
      dina  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      douta : out std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      clkb  : in  std_logic;
      addrb : in  std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
      web   : in  std_logic_vector(7 downto 0);
      dinb  : in  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      doutb : out std_logic_vector(C_DBUS_WIDTH-1 downto 0)
      );
  end component;

  -- Blinking  -_-_-_-_-_-_-_-_-_-_-_-_-_-_-
  component DDR_Blink
    port(
      DDR_Blinker : out std_logic;

      DDR_Write : in std_logic;
      DDR_Read  : in std_logic;
      DDR_Both  : in std_logic;

      ddr_Clock : in std_logic;
      DDr_Rst_n : in std_logic
      );
  end component;

  -- ---------------------------------------------------------------------
  signal ddr_DCM_locked : std_logic;
  --  -- ---------------------------------------------------------------------
  signal Rst_i          : std_logic;
  --  -- ---------------------------------------------------------------------
  signal DDR_Ready_i    : std_logic;
  --  -- ---------------------------------------------------------------------
  signal ddr_Clock      : std_logic;
  signal ddr_Clock_n    : std_logic;
  signal ddr_Clock90    : std_logic;
  signal ddr_Clock90_n  : std_logic;

  signal Clk_ddr_rddata   : std_logic;
  signal Clk_ddr_rddata_n : std_logic;

  -- -- --  Write Pipe Channel
  signal wpipe_wEn        : std_logic;
  signal wpipe_Din        : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal wpipe_aFull      : std_logic;
  signal wpipe_Full       : std_logic;
  --  Earlier calculate for better timing
  signal DDR_wr_Cross_Row : std_logic;
  signal DDR_wr_din_r1    : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_write_ALC    : std_logic_vector(11-1 downto 0);

  signal wpipe_rEn        : std_logic;
  signal wpipe_Qout       : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
--  signal  wpipe_aEmpty          :  std_logic;
  signal wpipe_Empty      : std_logic;
  signal wpipe_Qout_latch : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);

  -- -- --  Read Pipe Command Channel
  signal rpipec_wEn       : std_logic;
  signal rpipec_Din       : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal rpipec_aFull     : std_logic;
  signal rpipec_Full      : std_logic;
  --  Earlier calculate for better timing
  signal DDR_rd_Cross_Row : std_logic;
  signal DDR_rdc_din_r1   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal DDR_read_ALC     : std_logic_vector(11-1 downto 0);

  signal rpipec_rEn   : std_logic;
  signal rpipec_Qout  : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
--  signal  rpipec_aEmpty         :  std_logic;
  signal rpipec_Empty : std_logic;

  -- -- --  Read Pipe Data Channel
  signal rpiped_wEn   : std_logic;
  signal rpiped_Din   : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
  signal rpiped_aFull : std_logic;
  signal rpiped_Full  : std_logic;

--  signal  rpiped_rEn            :  std_logic;
  signal rpiped_Qout : std_logic_vector(C_ASYNFIFO_WIDTH-1 downto 0);
--  signal  rpiped_aEmpty         :  std_logic;
--  signal  rpiped_Empty          :  std_logic;

  --   write State machine
  type bram_wrStates is (wrST_bram_RESET
                         , wrST_bram_IDLE
--                                 , wrST_bram_Address
                         , wrST_bram_1st_Data
                         , wrST_bram_1st_Data_b2b
                         , wrST_bram_more_Data
                         , wrST_bram_last_DW
                         );

  -- State variables
  signal pseudo_DDR_wr_State : bram_wrStates;

  --       Block RAM
  signal pRAM_weA   : std_logic_vector(7 downto 0);
  signal pRAM_addrA : std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
  signal pRAM_dinA  : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal pRAM_doutA : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal pRAM_weB           : std_logic_vector(7 downto 0);
  signal pRAM_addrB         : std_logic_vector(C_PRAM_AWIDTH-1 downto 0);
  signal pRAM_dinB          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal pRAM_doutB         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal pRAM_doutB_r1      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal pRAM_doutB_shifted : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  signal wpipe_qout_lo32b : std_logic_vector(33-1 downto 0);
  signal wpipe_QW_Aligned : std_logic;
  signal pRAM_AddrA_Inc   : std_logic;
  signal wpipe_read_valid : std_logic;

  --   read State machine
  type bram_rdStates is (rdST_bram_RESET
                         , rdST_bram_IDLE
                         , rdST_bram_b4_LA
                         , rdST_bram_LA
--                                 , rdST_bram_b4_Length
--                                 , rdST_bram_Length
--                                 , rdST_bram_b4_Address
--                                 , rdST_bram_Address
                         , rdST_bram_Data
--                                 , rdST_bram_Data_shift
                         );

  -- State variables
  signal pseudo_DDR_rd_State : bram_rdStates;

  signal rpiped_rd_counter  : std_logic_vector(10-1 downto 0);
  signal rpiped_wEn_b3      : std_logic;
  signal rpiped_wEn_b2      : std_logic;
  signal rpiped_wEn_b1      : std_logic;
  signal rpiped_wr_EOF      : std_logic;
  signal rpipec_read_valid  : std_logic;
  signal rpiped_wr_skew     : std_logic;
  signal rpiped_wr_postpone : std_logic;

  signal simone_debug : std_logic;

begin

  
  Rst_i     <= user_reset;
  DDR_Ready <= DDR_Ready_i;

  pRAM_doutB_shifted <= pRAM_doutB_r1(32-1 downto 0) & pRAM_doutB(64-1 downto 32);

  --  Delay
  Syn_Shifting_pRAM_doutB :
  process (user_clk)
  begin
    if user_clk'event and user_clk = '1' then
      pRAM_doutB_r1 <= pRAM_doutB;
    end if;
  end process;

  -- -----------------------------------------------
  --
  Syn_DDR_CKE :
  process (user_clk, Rst_i)
  begin
    if Rst_i = '1' then
      DDR_Ready_i <= '0';
    elsif user_clk'event and user_clk = '1' then
      DDR_Ready_i <= '1';               -- ddr_DCM_locked;
    end if;
  end process;

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------
--  DDR_Clock_Generator: 
--  DDR_ClkGen
--  PORT MAP(
--           ddr_Clock            =>  ddr_Clock             , -- OUT   std_logic;
--           ddr_Clock_n          =>  ddr_Clock_n           , -- OUT   std_logic;
--           ddr_Clock90          =>  ddr_Clock90           , -- OUT   std_logic;
--           ddr_Clock90_n        =>  ddr_Clock90_n         , -- OUT   std_logic;
--           Clk_ddr_rddata       =>  Clk_ddr_rddata        , -- OUT   std_logic;
--           Clk_ddr_rddata_n     =>  Clk_ddr_rddata_n      , -- OUT   std_logic;
--           ddr_DCM_locked       =>  ddr_DCM_locked        , -- OUT   std_logic;
--                                
--           clk_in               =>  mem_clk               , -- IN    std_logic;
--           user_reset          =>  user_reset             -- IN    std_logic
--          );


  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------
--  DDR_pipe_write_fifo:
--  asyn_rw_FIFO
--  GENERIC MAP (
--               OUTPUT_REGISTERED    => TRUE
--              )
--  PORT MAP(
--           wClk          =>  user_clk         ,
--           wEn           =>  wpipe_wEn       ,
--           Din           =>  wpipe_Din       ,
--           aFull         =>  wpipe_aFull     ,
--           Full          =>  wpipe_Full      ,
--
--           rClk          =>  ddr_Clock       ,  -- ddr_Clock_n     ,
--           rEn           =>  wpipe_rEn       ,
--           Qout          =>  wpipe_Qout      ,
--           aEmpty        =>  wpipe_aEmpty    ,
--           Empty         =>  wpipe_Empty     ,
--
--           Rst           =>  Rst_i           
--          );

--  DDR_pipe_write_fifo:
--  asyn_rw_FIFO72
--  PORT MAP(
--           wClk          =>  user_clk       ,
--           wEn           =>  wpipe_wEn     ,
--           Din           =>  wpipe_Din     ,
--           aFull         =>  wpipe_aFull   ,
--           Full          =>  open          ,
--
--           rClk          =>  ddr_Clock     ,
--           rEn           =>  wpipe_rEn     ,
--           Qout          =>  wpipe_Qout    ,
--           aEmpty        =>  open          ,
--           Empty         =>  wpipe_Empty   ,
--
--           Rst           =>  Rst_i          
--          );

  DDR_pipe_write_fifo :
    prime_fifo_plain
      port map(
        wr_clk    => user_clk ,         -- IN  std_logic;
        wr_en     => wpipe_wEn ,        -- IN  std_logic;
        din       => wpipe_Din ,        -- IN  std_logic_VECTOR(35 downto 0);
        prog_full => wpipe_aFull ,      -- OUT std_logic;
        full      => wpipe_Full ,       -- OUT std_logic;

        rd_clk => user_clk ,            -- IN  std_logic;
        rd_en  => wpipe_rEn ,           -- IN  std_logic;
        dout   => wpipe_Qout ,          -- OUT std_logic_VECTOR(35 downto 0);
        empty  => wpipe_Empty ,         -- OUT std_logic;

        rst => Rst_i                    -- IN  std_logic
        );


  wpipe_wEn   <= DDR_wr_v;
  wpipe_Din   <= DDR_wr_Mask & DDR_wr_Shift & '0' & DDR_wr_sof & DDR_wr_eof & DDR_wr_Cross_Row & DDR_wr_FA & DDR_wr_din;
  DDR_wr_full <= wpipe_aFull;
  Sim_Zeichen <= simone_debug;          --S wpipe_Empty;

  Syn_DDR_wrD_Cross_Row :
  process (user_clk)
  begin
    if user_clk'event and user_clk = '1' then
      DDR_wr_din_r1(64-1 downto 10) <= (others => '0');
      DDR_wr_din_r1(9 downto 0)     <= DDR_wr_din(9 downto 0) - "100";     
    end if;
  end process;

  DDR_write_ALC    <= (DDR_wr_din_r1(10 downto 2) &"00") + ('0' & DDR_wr_din(9 downto 2) &"00");
  DDR_wr_Cross_Row <= '0';              -- DDR_write_ALC(10);

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------

--  DDR_pipe_read_C_fifo:
--  asyn_rw_FIFO
--  GENERIC MAP (
--               OUTPUT_REGISTERED    => TRUE
--              )
--  PORT MAP(
--           wClk          =>  user_clk         ,
--           wEn           =>  rpipec_wEn      ,
--           Din           =>  rpipec_Din      ,
--           aFull         =>  rpipec_aFull    ,
--           Full          =>  rpipec_Full     ,
--
--           rClk          =>  ddr_Clock       ,  -- ddr_Clock_n     ,
--           rEn           =>  rpipec_rEn      ,
--           Qout          =>  rpipec_Qout     ,
--           aEmpty        =>  rpipec_aEmpty   ,
--           Empty         =>  rpipec_Empty    ,
--
--           Rst           =>  Rst_i           
--          );
--

--  DDR_pipe_read_C_fifo:
--  asyn_rw_FIFO72
--  PORT MAP(
--           wClk          =>  user_clk       ,
--           wEn           =>  rpipec_wEn     ,
--           Din           =>  rpipec_Din     ,
--           aFull         =>  rpipec_aFull   ,
--           Full          =>  open          ,
--
--           rClk          =>  ddr_Clock     ,
--           rEn           =>  rpipec_rEn     ,
--           Qout          =>  rpipec_Qout    ,
--           aEmpty        =>  open          ,
--           Empty         =>  rpipec_Empty   ,
--
--           Rst           =>  Rst_i          
--          );

  DDR_pipe_read_C_fifo :
    prime_fifo_plain
      port map(
        wr_clk    => user_clk ,         -- IN  std_logic;
        wr_en     => rpipec_wEn ,       -- IN  std_logic;
        din       => rpipec_Din ,       -- IN  std_logic_VECTOR(35 downto 0);
        prog_full => rpipec_aFull ,     -- OUT std_logic;
        full      => open,  --rpipec_Full    , -- OUT std_logic;

        rd_clk => user_clk ,            -- IN  std_logic;
        rd_en  => rpipec_rEn ,          -- IN  std_logic;
        dout   => rpipec_Qout ,         -- OUT std_logic_VECTOR(35 downto 0);
        empty  => rpipec_Empty ,        -- OUT std_logic;

        rst => Rst_i                    -- IN  std_logic
        );

  rpipec_wEn   <= DDR_rdc_v;
  rpipec_Din   <= "00" & DDR_rdc_Shift & '0' & DDR_rdc_sof & DDR_rdc_eof & DDR_rd_Cross_Row & DDR_rdc_FA & DDR_rdc_din;
  DDR_rdc_full <= rpipec_aFull;

  Syn_DDR_rdC_Cross_Row :
  process (user_clk)
  begin
    if user_clk'event and user_clk = '1' then
      DDR_rdc_din_r1(64-1 downto 10) <= (others => '0');
      DDR_rdc_din_r1(9 downto 0)     <= DDR_rdc_din(9 downto 0) - "100";     
    end if;
  end process;

  DDR_read_ALC     <= (DDR_rdc_din_r1(10 downto 2) &"00") + ('0' & DDR_rdc_din(9 downto 2) &"00");
  DDR_rd_Cross_Row <= '0';              -- DDR_read_ALC(10);

  -- ----------------------------------------------------------------------------
  -- 
  -- ----------------------------------------------------------------------------
--  DDR_pipe_read_D_fifo:
--  asyn_rw_FIFO
--  GENERIC MAP (
--               OUTPUT_REGISTERED    => TRUE
--              )
--  PORT MAP(
--           wClk          =>  ddr_Clock,       -- Clk_ddr_rddata  ,  -- ddr_Clock       ,  -- ddr_Clock_n     ,
--           wEn           =>  rpiped_wEn      ,
--           Din           =>  rpiped_Din      ,
--           aFull         =>  rpiped_aFull    ,
--           Full          =>  rpiped_Full     ,
--
--           rClk          =>  user_clk         ,
--           rEn           =>  DDR_FIFO_RdEn   ,  -- rpiped_rEn      ,
--           Qout          =>  rpiped_Qout     ,
--           aEmpty        =>  open            ,  -- rpiped_aEmpty   ,
--           Empty         =>  DDR_FIFO_Empty  ,  -- rpiped_Empty    ,
--
--           Rst           =>  Rst_i           
--          );

--  DDR_pipe_read_D_fifo:
--  asyn_rw_FIFO72
--  PORT MAP(
--           wClk          =>  ddr_Clock       ,
--           wEn           =>  rpiped_wEn     ,
--           Din           =>  rpiped_Din     ,
--           aFull         =>  rpiped_aFull   ,
--           Full          =>  open          ,
--
--           rClk          =>  user_clk     ,
--           rEn           =>  DDR_FIFO_RdEn     ,
--           Qout          =>  rpiped_Qout    ,
--           aEmpty        =>  open          ,
--           Empty         =>  DDR_FIFO_Empty   ,
--
--           Rst           =>  Rst_i          
--          );

  DDR_pipe_read_D_fifo :
    prime_fifo_plain
      port map(
        wr_clk    => user_clk ,         -- IN  std_logic;
        wr_en     => rpiped_wEn ,       -- IN  std_logic;
        din       => rpiped_Din ,       -- IN  std_logic_VECTOR(35 downto 0);
        prog_full => rpiped_aFull ,     -- OUT std_logic;
        full      => open,  -- rpiped_Full     , -- OUT std_logic;

        rd_clk => user_clk ,            -- IN  std_logic;
        rd_en  => DDR_FIFO_RdEn ,       -- IN  std_logic;
        dout   => rpiped_Qout ,         -- OUT std_logic_VECTOR(35 downto 0);
        empty  => DDR_FIFO_Empty ,      -- OUT std_logic;

        rst => Rst_i                    -- IN  std_logic
        );

  DDR_FIFO_RdQout <= rpiped_Qout(C_DBUS_WIDTH-1 downto 0);

  -- -------------------------------------------------
  -- pkt_RAM instantiate
  -- 
  pkt_RAM :
    bram_x64
      port map (
        clka  => user_clk ,
        addra => pRAM_addrA ,
        wea   => pRAM_weA ,
        dina  => pRAM_dinA ,
        douta => pRAM_doutA ,

        clkb  => user_clk ,
        addrb => pRAM_addrB ,
        web   => pRAM_weB ,
        dinb  => pRAM_dinB ,
        doutb => pRAM_doutB
        );

  pRAM_weB  <= X"00";
  pRAM_dinB <= (others => '0');

-- ------------------------------------------------
-- write States synchronous
--
  Syn_Pseudo_DDR_wr_States :
  process (user_clk, user_reset)
  begin
    if user_reset = '1' then
      pseudo_DDR_wr_State <= wrST_bram_RESET;
      pRAM_addrA          <= (others => '1');
      pRAM_weA            <= (others => '0');
      pRAM_dinA           <= (others => '0');
      wpipe_qout_lo32b    <= (others => '0');
      wpipe_QW_Aligned    <= '1';
      pRAM_AddrA_Inc      <= '1';

    elsif user_clk'event and user_clk = '1' then

      case pseudo_DDR_wr_State is

        when wrST_bram_RESET =>
          pseudo_DDR_wr_State <= wrST_bram_IDLE;
          pRAM_addrA          <= (others => '1');
          wpipe_QW_Aligned    <= '1';
          wpipe_qout_lo32b    <= (others => '0');
          pRAM_weA            <= (others => '0');
          pRAM_dinA           <= (others => '0');
          pRAM_AddrA_Inc      <= '1';

        when wrST_bram_IDLE =>
          pRAM_addrA       <= wpipe_Qout(14 downto 3);
          pRAM_AddrA_Inc   <= wpipe_Qout(2);
          wpipe_QW_Aligned <= not wpipe_Qout(69);
          wpipe_qout_lo32b <= (32     => '1', others => '0');
          pRAM_weA         <= (others => '0');
          pRAM_dinA        <= pRAM_dinA;
          if wpipe_read_valid = '1' then
            pseudo_DDR_wr_State <= wrST_bram_1st_Data;  -- wrST_bram_Address;
          else
            pseudo_DDR_wr_State <= wrST_bram_IDLE;
          end if;


        when wrST_bram_1st_Data =>
          pRAM_addrA <= pRAM_addrA;
          if wpipe_read_valid = '0' then
            pseudo_DDR_wr_State <= wrST_bram_1st_Data;
            pRAM_weA            <= (others => '0');  --pRAM_weA;
            pRAM_dinA           <= pRAM_dinA;
          elsif wpipe_Qout(66) = '1' then            -- eof
            if wpipe_QW_Aligned = '1' then
              pseudo_DDR_wr_State <= wrST_bram_IDLE;
              pRAM_weA <= not (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              pRAM_dinA <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
            elsif wpipe_Qout(70) = '1' then          -- mask(0)
              pseudo_DDR_wr_State <= wrST_bram_IDLE;
              pRAM_weA <= not (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_dinA <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
            elsif wpipe_Qout(71) = '1' then          -- mask(1)
              pseudo_DDR_wr_State <= wrST_bram_IDLE;
              pRAM_weA            <= X"F0";
              pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1-32 downto 0) & X"00000000";
            else
              pseudo_DDR_wr_State <= wrST_bram_last_DW;
              pRAM_weA <= not (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_dinA        <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
              wpipe_qout_lo32b <= '0' & wpipe_Qout(32-1 downto 0);
            end if;
          else
            if wpipe_QW_Aligned = '1' then
              pseudo_DDR_wr_State <= wrST_bram_more_Data;
              pRAM_weA <= not (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              pRAM_dinA <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
            elsif pRAM_AddrA_Inc = '1' then
              pseudo_DDR_wr_State <= wrST_bram_more_Data;
              pRAM_weA <= not (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_dinA        <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
              wpipe_qout_lo32b <= '0' & wpipe_Qout(32-1 downto 0);
            else
              pseudo_DDR_wr_State <= wrST_bram_1st_Data;
              pRAM_AddrA_Inc      <= '1';
              pRAM_weA            <= X"00";
              pRAM_dinA           <= pRAM_dinA;
              wpipe_qout_lo32b    <= wpipe_Qout(70) & wpipe_Qout(32-1 downto 0);
            end if;
          end if;

        when wrST_bram_more_Data =>
          if wpipe_read_valid = '0' then
            pseudo_DDR_wr_State <= wrST_bram_more_Data;  -- wrST_bram_1st_Data;
            pRAM_weA            <= (others => '0');      --pRAM_weA;
            pRAM_addrA          <= pRAM_addrA;
            pRAM_dinA           <= pRAM_dinA;
          elsif wpipe_Qout(66) = '1' then                -- eof
            if wpipe_QW_Aligned = '1' then
              pseudo_DDR_wr_State <= wrST_bram_IDLE;
              pRAM_weA <= not (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              pRAM_addrA <= pRAM_addrA + '1';
              pRAM_dinA  <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
            elsif wpipe_Qout(70) = '1' then              -- mask(0)
              pseudo_DDR_wr_State <= wrST_bram_IDLE;
              pRAM_weA <= not (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_addrA <= pRAM_addrA + '1';
              pRAM_dinA  <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
            else
              pseudo_DDR_wr_State <= wrST_bram_last_DW;
              pRAM_weA <= not (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_addrA       <= pRAM_addrA + '1';
              pRAM_dinA        <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
              wpipe_qout_lo32b <= '0' & wpipe_Qout(32-1 downto 0);
            end if;
          else
            if wpipe_QW_Aligned = '1' then
              pseudo_DDR_wr_State <= wrST_bram_more_Data;
              pRAM_weA <= not (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              pRAM_addrA <= pRAM_addrA + '1';
              pRAM_dinA  <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
            else
              pseudo_DDR_wr_State <= wrST_bram_more_Data;
              pRAM_weA <= not (wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32) & wpipe_qout_lo32b(32)
                               & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_addrA       <= pRAM_addrA + '1';
              pRAM_dinA        <= wpipe_qout_lo32b(32-1 downto 0) & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
              wpipe_qout_lo32b <= '0' & wpipe_Qout(32-1 downto 0);
            end if;
          end if;

        when wrST_bram_last_DW =>
--             pseudo_DDR_wr_State   <= wrST_bram_IDLE;
          pRAM_weA   <= X"F0";
          pRAM_addrA <= pRAM_addrA + '1';
          pRAM_dinA  <= wpipe_qout_lo32b(32-1 downto 0) & X"00000000";
          if wpipe_read_valid = '1' then
            pseudo_DDR_wr_State <= wrST_bram_1st_Data_b2b;  -- wrST_bram_Address;
            wpipe_Qout_latch    <= wpipe_Qout;
          else
            pseudo_DDR_wr_State <= wrST_bram_IDLE;
            wpipe_Qout_latch    <= wpipe_Qout;
          end if;

        when wrST_bram_1st_Data_b2b =>
          pRAM_addrA       <= wpipe_Qout_latch(14 downto 3);
          wpipe_QW_Aligned <= not wpipe_Qout_latch(69);
          if wpipe_read_valid = '0' then
            pseudo_DDR_wr_State <= wrST_bram_1st_Data;
            pRAM_weA            <= (others => '0');  --pRAM_weA;
            pRAM_dinA           <= pRAM_dinA;
            pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
            wpipe_qout_lo32b    <= (32     => '1', others => '0');
          elsif wpipe_Qout(66) = '1' then            -- eof
            if wpipe_Qout_latch(69) = '0' then       -- wpipe_QW_Aligned
              pseudo_DDR_wr_State <= wrST_bram_IDLE;
              pRAM_weA <= not (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              pRAM_dinA        <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
              pRAM_AddrA_Inc   <= wpipe_Qout_latch(2);
              wpipe_qout_lo32b <= (32 => '1', others => '0');
            elsif wpipe_Qout(70) = '1' then          -- mask(0)
              pseudo_DDR_wr_State <= wrST_bram_IDLE;
              pRAM_weA            <= not (X"f" & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_dinA        <= X"00000000" & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
              pRAM_AddrA_Inc   <= wpipe_Qout_latch(2);
              wpipe_qout_lo32b <= (32 => '1', others => '0');
            elsif wpipe_Qout(71) = '1' then          -- mask(1)
              pseudo_DDR_wr_State <= wrST_bram_IDLE;
              pRAM_weA            <= X"F0";
              pRAM_dinA           <= wpipe_Qout(C_DBUS_WIDTH-1-32 downto 0) & X"00000000";
              pRAM_AddrA_Inc      <= wpipe_Qout_latch(2);
              wpipe_qout_lo32b    <= (32 => '1', others => '0');
            else
              pseudo_DDR_wr_State <= wrST_bram_last_DW;
              pRAM_weA            <= not (X"f" & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_dinA        <= X"00000000" & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
              pRAM_AddrA_Inc   <= wpipe_Qout_latch(2);
              wpipe_qout_lo32b <= '0' & wpipe_Qout(32-1 downto 0);
            end if;
          else
            if wpipe_Qout_latch(69) = '0' then       -- wpipe_QW_Aligned
              pseudo_DDR_wr_State <= wrST_bram_more_Data;
              pRAM_weA <= not (wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71)
                               & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70) & wpipe_Qout(70));
              pRAM_dinA        <= wpipe_Qout(C_DBUS_WIDTH-1 downto 0);
              pRAM_AddrA_Inc   <= wpipe_Qout_latch(2);
              wpipe_qout_lo32b <= (32 => '1', others => '0');
            elsif wpipe_Qout_latch(2) = '1' then     -- pRAM_AddrA_Inc
              pseudo_DDR_wr_State <= wrST_bram_more_Data;
              pRAM_weA            <= not (X"f" & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71) & wpipe_Qout(71));
              pRAM_dinA        <= X"00000000" & wpipe_Qout(C_DBUS_WIDTH-1 downto 32);
              pRAM_AddrA_Inc   <= wpipe_Qout_latch(2);
              wpipe_qout_lo32b <= '0' & wpipe_Qout(32-1 downto 0);
            else
              pseudo_DDR_wr_State <= wrST_bram_1st_Data;
              pRAM_AddrA_Inc      <= '1';
              pRAM_weA            <= X"00";
              pRAM_dinA           <= pRAM_dinA;
              wpipe_qout_lo32b    <= wpipe_Qout(70) & wpipe_Qout(32-1 downto 0);
            end if;
          end if;

        when others =>
          pseudo_DDR_wr_State <= wrST_bram_RESET;
          pRAM_addrA          <= (others => '1');
          pRAM_weA            <= (others => '0');
          pRAM_dinA           <= (others => '0');
          wpipe_qout_lo32b    <= (others => '0');
          wpipe_QW_Aligned    <= '1';
          pRAM_AddrA_Inc      <= '1';

      end case;

    end if;
  end process;

  -- 
  Syn_wPipe_read :
  process (user_clk, DDR_Ready_i)
  begin
    if DDR_Ready_i = '0' then
      wpipe_rEn        <= '0';
      wpipe_read_valid <= '0';

    elsif user_clk'event and user_clk = '1' then

      wpipe_rEn        <= '1';
      wpipe_read_valid <= wpipe_rEn and not wpipe_Empty;

    end if;
  end process;

  -- 
  Syn_rPipeC_read :
  process (user_clk, DDR_Ready_i)
  begin
    if DDR_Ready_i = '0' then
      rpipec_read_valid  <= '0';
      rpiped_wr_postpone <= '0';
      rpiped_wr_skew     <= '0';

    elsif user_clk'event and user_clk = '1' then

      rpipec_read_valid <= rpipec_rEn and not rpipec_Empty;
      if rpipec_read_valid = '1' then
        rpiped_wr_postpone <= rpipec_Qout(2) and not rpipec_Qout(69);
        rpiped_wr_skew     <= rpipec_Qout(69) xor rpipec_Qout(2);
      else
        rpiped_wr_postpone <= rpiped_wr_postpone;
        rpiped_wr_skew     <= rpiped_wr_skew;
      end if;

    end if;
  end process;

-- ------------------------------------------------
-- Read States synchronous
--
  Syn_Pseudo_DDR_rd_States :
  process (user_clk, DDR_Ready_i)
  begin
    if DDR_Ready_i = '0' then
      pseudo_DDR_rd_State <= rdST_bram_RESET;
      rpipec_rEn          <= '0';
      pRAM_addrB          <= (others => '1');
      rpiped_rd_counter   <= (others => '0');
      rpiped_wEn_b3       <= '0';
      rpiped_wr_EOF       <= '0';

    elsif user_clk'event and user_clk = '1' then

      case pseudo_DDR_rd_State is

        when rdST_bram_RESET =>
          pseudo_DDR_rd_State <= rdST_bram_IDLE;
          rpipec_rEn          <= '0';
          pRAM_addrB          <= (others => '1');
          rpiped_rd_counter   <= (others => '0');
          rpiped_wEn_b3       <= '0';
          rpiped_wr_EOF       <= '0';

        when rdST_bram_IDLE =>
          pRAM_addrB        <= pRAM_addrB;
          rpiped_rd_counter <= (others => '0');
          rpiped_wEn_b3     <= '0';
          rpiped_wr_EOF     <= '0';
          if rpipec_Empty = '0' then
            rpipec_rEn          <= '1';
            pseudo_DDR_rd_State <= rdST_bram_b4_LA;  --rdST_bram_b4_Length;
          else
            rpipec_rEn          <= '0';
            pseudo_DDR_rd_State <= rdST_bram_IDLE;
          end if;

        when rdST_bram_b4_LA =>
          pRAM_addrB          <= pRAM_addrB;
          rpiped_rd_counter   <= (others => '0');
          rpiped_wEn_b3       <= '0';
          rpiped_wr_EOF       <= '0';
          rpipec_rEn          <= '0';
          pseudo_DDR_rd_State <= rdST_bram_LA;

        when rdST_bram_LA =>
          rpipec_rEn    <= '0';
          pRAM_addrB    <= rpipec_Qout(14 downto 3);
          rpiped_wr_EOF <= '0';
          rpiped_wEn_b3 <= '0';
          if rpipec_Qout(2+32) = '1' then
            rpiped_rd_counter <= rpipec_Qout(11+32 downto 2+32) + '1';
          elsif rpipec_Qout(2) = '1' and rpipec_Qout(69) = '1' then
            rpiped_rd_counter <= rpipec_Qout(11+32 downto 2+32) + "10";
          elsif rpipec_Qout(2) = '0' and rpipec_Qout(69) = '1' then
            rpiped_rd_counter <= rpipec_Qout(11+32 downto 2+32) + "10";
          elsif rpipec_Qout(2) = '1' and rpipec_Qout(69) = '0' then
            rpiped_rd_counter <= rpipec_Qout(11+32 downto 2+32);
          else
            rpiped_rd_counter <= rpipec_Qout(11+32 downto 2+32);
          end if;

--             elsif rpipec_Qout(2)='1' then
--               rpiped_rd_counter     <= rpipec_Qout(11+32 downto 2+32) + "10";
--             elsif rpipec_Qout(69)='1' then
--               rpiped_rd_counter     <= rpipec_Qout(11+32 downto 2+32) + "10";
--             else
--               rpiped_rd_counter     <= rpipec_Qout(11+32 downto 2+32);
--             end if;
          pseudo_DDR_rd_State <= rdST_bram_Data;


        when rdST_bram_Data =>
          rpipec_rEn <= '0';
          if rpiped_rd_counter = CONV_STD_LOGIC_VECTOR(2, 10) then
            pRAM_addrB          <= pRAM_addrB + '1';
            rpiped_rd_counter   <= rpiped_rd_counter;
            rpiped_wEn_b3       <= '1';
            rpiped_wr_EOF       <= '1';
            pseudo_DDR_rd_State <= rdST_bram_IDLE;
          elsif rpiped_aFull = '1' then
            pRAM_addrB          <= pRAM_addrB;
            rpiped_rd_counter   <= rpiped_rd_counter;
            rpiped_wEn_b3       <= '0';
            rpiped_wr_EOF       <= '0';
            pseudo_DDR_rd_State <= rdST_bram_Data;
          else
            pRAM_addrB          <= pRAM_addrB + '1';
            rpiped_rd_counter   <= rpiped_rd_counter - "10";     
            rpiped_wEn_b3       <= '1';
            rpiped_wr_EOF       <= '0';
            pseudo_DDR_rd_State <= rdST_bram_Data;
          end if;

        when others =>
          rpipec_rEn          <= '0';
          pRAM_addrB          <= pRAM_addrB;
          rpiped_rd_counter   <= rpiped_rd_counter;
          rpiped_wEn_b3       <= '0';
          rpiped_wr_EOF       <= '0';
          pseudo_DDR_rd_State <= rdST_bram_RESET;

      end case;

    end if;
  end process;

  Syn_Pseudo_DDR_rdd_write :
  process (user_clk, DDR_Ready_i)
  begin
    if DDR_Ready_i = '0' then
      rpiped_wEn_b1 <= '0';
      rpiped_wEn_b2 <= '0';
      rpiped_wEn    <= '0';
      rpiped_Din    <= (others => '0');

    elsif user_clk'event and user_clk = '1' then

      rpiped_wEn_b2 <= rpiped_wEn_b3;
      rpiped_wEn_b1 <= rpiped_wEn_b2;
      if rpiped_wr_skew = '1' then
--           rpiped_wEn         <= rpiped_wEn_b2;
        rpiped_wEn <= (rpiped_wEn_b2 and not rpiped_wr_postpone)
                      or (rpiped_wEn_b1 and rpiped_wr_postpone);
        rpiped_Din <= "0000" & '0' & rpiped_wr_EOF & "00" & pRAM_doutB_shifted;
      else
--           rpiped_wEn         <= rpiped_wEn_b2;
        rpiped_wEn <= (rpiped_wEn_b2 and not rpiped_wr_postpone)
                      or (rpiped_wEn_b1 and rpiped_wr_postpone);
        rpiped_Din <= "0000" & '0' & rpiped_wr_EOF & "00" & pRAM_doutB;
      end if;

    end if;
  end process;

  -- 
  DDR_Blinker_Module :
    DDR_Blink
      port map(
        DDR_Blinker => DDR_Blinker ,

        DDR_Write => wpipe_rEn ,
        DDR_Read  => rpiped_wEn ,
        DDR_Both  => '0' ,

        ddr_Clock => user_clk ,
        DDr_Rst_n => DDR_Ready_i        -- DDR_CKE_i      
        );

end architecture Behavioral;
