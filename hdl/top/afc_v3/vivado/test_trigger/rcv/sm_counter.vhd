-------------------------------------------------------------------------------
-- Title      : State machine to counter event
-- Project    :
-------------------------------------------------------------------------------
-- File       : sm_counter.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-12-03
-- Last update: 2016-01-13
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2015 Brazilian Synchrotron Light Laboratory, LNLS/CNPEM

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
-- 2015-12-03  1.0      vfinotti        Created
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Declaring count type in a package
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package types is
  type count_array is array(integer range 7 downto 0) of std_logic_vector(127 downto 0);
end types;

-------------------------------------------------------------------------------
-- Core code
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


library work;
use work.types.all;


entity sm_counter is

  generic (
    g_num_states : natural := 8);
  port (
    clk_i            : in  std_logic;
    data_i           : in  std_logic_vector(g_num_states-1 downto 0);
    current_s_i      : in  unsigned(2 downto 0);
    count_success_o  : out count_array;
    count_fail_o     : out count_array;
    count_repeated_o : out count_array;
    count_others_o   : out count_array);

end entity sm_counter;

architecture behav of sm_counter is

  signal count_success, count_fail, count_repeated, count_others : count_array := (others => (others => '0'));

begin  -- architecture behav

  -- purpose: defines whats happens when a pulse ir received
  -- type   : sequential
  -- inputs : pulse(i), pulse
  -- outputs: counters

  gen_counter : for i in g_num_states-2 downto 1 generate

    sm_counter_i : process (clk_i) is
    begin  -- process sm_counter_i
      if rising_edge(clk_i) then        -- rising clock edge
        if (data_i(i) = '1') then
          case current_s_i is
            when to_unsigned(i,3) =>                   -- pulse properly received
              count_success(i) <= std_logic_vector(unsigned(count_success(i)) + 1);
            when to_unsigned(i+1,3) =>                 -- repeated pulse
              count_repeated(i) <= std_logic_vector(unsigned(count_repeated(i)) + 1);
            when to_unsigned(i-1,3) =>
              count_fail(i-1) <= std_logic_vector(unsigned(count_fail(i-1)) + 1);
            when others =>
              count_others(i) <= std_logic_vector(unsigned(count_others(i)) + 1);
          end case;
        end if;
      end if;
    end process sm_counter_i;
  end generate gen_counter;

-----------------------------------------------------------------------------
-- Generating for index "g_num_states" (preventing index "g_num_states+1" on
-- "count_repeated")
-----------------------------------------------------------------------------

  sm_counter_end : process (clk_i) is
  begin  -- process sm_counter_i
    if rising_edge(clk_i) then          -- rising clock edge
      if (data_i(g_num_states-1) = '1') then
        case current_s_i is
          when to_unsigned(g_num_states-1,3) =>        -- pulse properly received
            count_success(g_num_states-1) <= std_logic_vector(unsigned(count_success(g_num_states-1)) + 1);
          when to_unsigned(0,3) =>                     -- repeated pulse
            count_repeated(g_num_states-1) <= std_logic_vector(unsigned(count_repeated(g_num_states-1)) + 1);
          when to_unsigned(g_num_states-2,3) =>
            count_fail(g_num_states-2) <= std_logic_vector(unsigned(count_fail(g_num_states-2)) + 1);
          when others =>
            count_others(g_num_states-1) <= std_logic_vector(unsigned(count_others(g_num_states-1)) + 1);
        end case;
      end if;
    end if;
  end process sm_counter_end;

-----------------------------------------------------------------------------
-- Generating for index 0 (preventing negative index on "count_fail")
-----------------------------------------------------------------------------

  sm_counter_0 : process (clk_i) is
  begin  -- process sm_counter_i
    if rising_edge(clk_i) then          -- rising clock edge
      if (data_i(0) = '1') then
        case current_s_i is
          when to_unsigned(0,3) =>                     -- pulse properly received
            count_success(0) <= std_logic_vector(unsigned(count_success(0)) + 1);
          when to_unsigned(1,3) =>                     -- repeated pulse
            count_repeated(0) <= std_logic_vector(unsigned(count_repeated(0)) + 1);
          when to_unsigned(g_num_states-1,3) =>
            count_fail(g_num_states-1) <= std_logic_vector(unsigned(count_fail(g_num_states-1)) + 1);
          when others =>
            count_others(0) <= std_logic_vector(unsigned(count_others(0)) + 1);
        end case;
      end if;
    end if;
  end process sm_counter_0;

  count_success_o  <= count_success;
  count_fail_o     <= count_fail;
  count_repeated_o <= count_repeated;
  count_others_o   <= count_others;

end architecture behav;
