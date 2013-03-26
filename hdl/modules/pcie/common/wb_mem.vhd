-- -----------------------------------------
--
-- Simple generic wishbone memory module
--
-- Created by: abyszuk
--
--------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB_MEM is
  generic(
    AWIDTH : natural range 2 to 29;
    DWIDTH : natural range 8 to 128
  );
  port(
-- WISHBONE SLAVE interface:
-- Single-Port RAM with Asynchronous Read
--
  CLK_I : in  std_logic;
  ACK_O : out std_logic;
  ADR_I : in  std_logic_vector(AWIDTH-1 downto 0);
  DAT_I : in  std_logic_vector(DWIDTH-1 downto 0);
  DAT_O : out std_logic_vector(DWIDTH-1 downto 0);
  STB_I : in  std_logic;
  WE_I  : in  std_logic
  );
end entity WB_MEM;

architecture rtl of WB_MEM is

    type ram_type is array (2**AWIDTH downto 0) of std_logic_vector(DWIDTH-1 downto 0);
    signal RAM : ram_type;

begin

REG: process(CLK_I)
begin
  if(rising_edge(CLK_I)) then
    if((STB_I and WE_I) = '1') then
      RAM(to_integer(unsigned(ADR_I))) <= DAT_I;
    end if;
  end if;
end process REG;

  ACK_O <= STB_I;
  DAT_O <= RAM(to_integer(unsigned(ADR_I)));

end architecture rtl;
