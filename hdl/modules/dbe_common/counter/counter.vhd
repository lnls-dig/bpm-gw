-------------------------------------------------------------------------------
-- Title      : Simple counter
-- Project    : 
-------------------------------------------------------------------------------
-- File       : counter.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    : 
-- Created    : 2015-11-11
-- Last update: 2015-11-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Simple counter for testing, with clock enable
-------------------------------------------------------------------------------
-- Copyright (c) 2015     

-- This program is free software: you can redistribute it and/or
-- modify it under the terms of the GNU Lesser General Public License
-- as published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General Public
-- License along with this program. If not, see
-- <http://www.gnu.org/licenses/>.

-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2015-11-11  1.0      aylons  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity counter is
  generic(
    g_output_width : positive := 8
    );
  port(
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    ce_i    : in  std_logic;
    up_i    : in  std_logic;
    down_i  : in  std_logic;
    count_o : out std_logic_vector(g_output_width-1 downto 0)
    );
end counter;

architecture behavioural of counter is
  signal count : unsigned(g_output_width-1 downto 0) := to_unsigned(0, g_output_width);
begin

  counter : process(clk_i)
  begin

    if clk_i = '1' and ce_i = '1' then
      if rst_i = '1' then
        count <= to_unsigned(0, g_output_width);
      else

        if up_i = '1' then
          count <= count + 1;
        elsif down_i = '1' then
          count <= count - 1;
        end if;

      end if;  --rst
    end if;  -- clk

  end process;

  count_o <= std_logic_vector(count);

end architecture behavioural;

