----------------------------------------------------------------------------------
-- Company: 
-- Engineer   :    wgao, LI5, Univ. Mannheim
-- 
-- Create Date:    07.12.2006 
-- Design Name: 
-- Module Name:    Tx_Output_Arbitor - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies:
--
-- Revision 2.00 - Dimension elastized by GENERATE.  10.07.2007
-- 
-- Revision 1.30 - abbPackage used.  26.06.2007
-- 
-- Revision 1.20 - Timing better.  29.01.2007
-- 
-- Revision 1.10 - Current States drive.  12.01.2007
-- 
-- Revision 1.00 - first release. 14.12.2006
-- 
-- Additional Comments:
--                      Dimension can be easily expanded.
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.abb64Package.all;


-----------  Top entity   ---------------
entity Tx_Output_Arbitor is
  port (
    rst_n : in std_logic;
    clk   : in std_logic;

    arbtake : in std_logic;             -- take a valid arbitration by the user
    Req     : in std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);  -- similar to FIFO not-empty

    bufread : out std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);  -- Read FIFO
    Ack     : out std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0)  -- tells who is the winner
    );
end Tx_Output_Arbitor;


architecture Behavioral of Tx_Output_Arbitor is

  type ArbStates is (
    aSt_Reset
    , aSt_Idle
    , aSt_ReadOne
    , aSt_Ready
    );

  signal Arb_FSM    : ArbStates;
  signal Arb_FSM_NS : ArbStates;

  type PriorMatrix is array (C_ARBITRATE_WIDTH-1 downto 0)
    of std_logic_vector (C_ARBITRATE_WIDTH-1 downto 0);

  signal ChPriority : PriorMatrix;

  signal Prior_Init_Value : PriorMatrix;

  signal Wide_Req : PriorMatrix;

  signal Wide_Req_turned : PriorMatrix;


  signal take_i : std_logic;
  signal Req_i  : std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);

  signal Req_r1 : std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);

  signal read_prep   : std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);
  signal read_i      : std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);
  signal Indice_prep : std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);
  signal Indice_i    : std_logic_vector(C_ARBITRATE_WIDTH-1 downto 0);

  signal Champion_Vector : std_logic_vector (C_ARBITRATE_WIDTH-1 downto 0);

begin

  bufread <= read_i;
  Ack     <= Indice_i;

  take_i <= arbtake;
  Req_i  <= Req;

  -- ------------------------------------------------------------
  Prior_Init_Value(0) <= C_LOWEST_PRIORITY;
  Gen_Prior_Init_Values :
  for i in 1 to C_ARBITRATE_WIDTH-1 generate
    Prior_Init_Value(i) <= Prior_Init_Value(i-1)(C_ARBITRATE_WIDTH-2 downto 0) & '1';
  end generate;

  -- ------------------------------------------------------------
  --  Mask the requests
  -- 
  Gen_Wide_Requests :
  for i in 0 to C_ARBITRATE_WIDTH-1 generate
    Wide_Req(i) <= ChPriority(i) when Req_i(i) = '1'
                   else C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
  end generate;

-- ------------------------------------
-- Synchronous Delay: Req
--
  Synch_Delay_Req :
  process(clk)
  begin
    if rising_edge(clk) then
      Req_r1 <= Req_i;
    end if;
  end process;

-- ------------------------------------
-- Synchronous: States
--
  Seq_FSM_NextState :
  process(clk)
  begin
    if rising_edge(clk) then
      if (rst_n = '0') then
        Arb_FSM <= aSt_Reset;
      else
        Arb_FSM <= Arb_FSM_NS;
      end if;
    end if;
  end process;

-- ------------------------------------
-- Combinatorial: Next States
--
  Comb_FSM_NextState :
  process (
    Arb_FSM
    , take_i
    , Req_r1
    )
  begin
    case Arb_FSM is

      when aSt_Reset =>
        Arb_FSM_NS <= aSt_Idle;

      when aSt_Idle =>
        if Req_r1 = C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0) then
          Arb_FSM_NS <= aSt_Idle;
        else
          Arb_FSM_NS <= aSt_ReadOne;
        end if;

      when aSt_ReadOne =>
        if Req_r1 = C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0) then  -- Ghost Request !!!
          Arb_FSM_NS <= aSt_Idle;
        else
          Arb_FSM_NS <= aSt_Ready;
        end if;

      when aSt_Ready =>
        if take_i = '0' then
          Arb_FSM_NS <= aSt_Ready;
        elsif Req_r1 = C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0) then
          Arb_FSM_NS <= aSt_Idle;
        else
          Arb_FSM_NS <= aSt_ReadOne;
        end if;

      when others =>
        Arb_FSM_NS <= aSt_Reset;

    end case;

  end process;

-- --------------------------------------------------
-- Turn the Request-Array Around
--
  Turn_the_Request_Array_Around :
  for i in 0 to C_ARBITRATE_WIDTH-1 generate
    Dimension_2nd :
    for j in 0 to C_ARBITRATE_WIDTH-1 generate
      Wide_Req_turned(i)(j) <= Wide_Req(j)(i);
    end generate;
  end generate;

-- --------------------------------------------------
-- Synchronous Calculation: Champion_Vector
--
  Sync_Champion_Vector :
  process(clk)
  begin
    if rising_edge(clk) then

      for i in 0 to C_ARBITRATE_WIDTH-1 loop
        if Wide_Req_turned(i) = C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0) then
          Champion_Vector(i) <= '0';
        else
          Champion_Vector(i) <= '1';
        end if;
      end loop;

    end if;
  end process;

-- --------------------------------------------------
--  Prepare the buffer read signal: read_i
-- 
  Gen_Read_Signals :
  for i in 0 to C_ARBITRATE_WIDTH-1 generate
    read_prep(i) <= '1' when Champion_Vector = ChPriority(i) else '0';
  end generate;

-- --------------------------------------------------
-- FSM Output :  Buffer read_i and Indice_i
--
  FSM_Output_read_Indice :
  process (clk)
  begin
    if rising_edge(clk) then
      if (rst_n = '0') then
        read_i      <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
        Indice_prep <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
        Indice_i    <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
      else
        case Arb_FSM is
  
          when aSt_ReadOne =>
            read_i      <= read_prep;
            Indice_prep <= read_prep;
            Indice_i    <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
  
          when aSt_Ready =>
            read_i      <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
            Indice_prep <= Indice_prep;
            if take_i = '1' then
              Indice_i <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
            else
              Indice_i <= Indice_prep;
            end if;
  
          when others =>
            read_i      <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
            Indice_prep <= Indice_prep;
            Indice_i    <= C_ALL_ZEROS(C_ARBITRATE_WIDTH-1 downto 0);
  
        end case;
      end if;
    end if;
  end process;

-- --------------------------------------------------
--
  Gen_Modify_Priorities :

  for i in 0 to C_ARBITRATE_WIDTH-1 generate

    Proc_Priority_Cycling :
    process (clk)
    begin
      if rising_edge(clk) then
        if (rst_n = '0') then
          ChPriority(i) <= Prior_Init_Value(i);
        else
          case Arb_FSM is
  
            when aSt_ReadOne =>
              if ChPriority(i) = Champion_Vector then
                ChPriority(i) <= C_LOWEST_PRIORITY;
              elsif (ChPriority(i) and Champion_Vector) = Champion_Vector then
                ChPriority(i) <= ChPriority(i);
              else
                ChPriority(i) <= ChPriority(i)(C_ARBITRATE_WIDTH-2 downto 0) & '1';
              end if;
  
            when others =>
              ChPriority(i) <= ChPriority(i);
  
          end case;
        end if;
      end if;
    end process;

  end generate;

end architecture Behavioral;
