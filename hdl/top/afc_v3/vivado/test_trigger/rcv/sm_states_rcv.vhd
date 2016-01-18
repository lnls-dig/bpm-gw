-------------------------------------------------------------------------------
-- Title      : State Machine for next state
-- Project    :
-------------------------------------------------------------------------------
-- File       : sm_states_rcv.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-12-03
-- Last update: 2016-01-12
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Define next state for the trigger_rcv
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity sm_states_rcv is

  generic (
    g_num_states : positive := 8);      -- number of states
  port (
    clk_i       : in  std_logic;
    rst_n_i     : in  std_logic;
    data_i      : in  std_logic_vector(g_num_states-1 downto 0);
    current_s_o : out unsigned(2 downto 0));
end entity sm_states_rcv;

architecture behav of sm_states_rcv is

  signal current_s : unsigned(2 downto 0);

begin  -- architecture behav
  sm_states_process : process (clk_i) is
  begin  -- process sm_next_process
    if rising_edge(clk_i) then          -- rising clock edge
      if rst_n_i = '0' then             -- synchronous reset (active high)
        current_s <= to_unsigned(0,3);
      else

        case current_s is

          when to_unsigned(0,3) =>
            if data_i(0) = '1' then     --change state
              current_s <= to_unsigned(1,3);
            else
              current_s <= to_unsigned(0,3);
            end if;

          when to_unsigned(1,3) =>
            if data_i(1) = '1' then     --change state
              current_s <= to_unsigned(2,3);
            else
              current_s <= to_unsigned(1,3);
            end if;

          when to_unsigned(2,3) =>
            if data_i(2) = '1' then     --change state
              current_s <= to_unsigned(3,3);
            else
              current_s <= to_unsigned(2,3);
            end if;

          when to_unsigned(3,3) =>
            if data_i(3) = '1' then     --change state
              current_s <= to_unsigned(4,3);
            else
              current_s <= to_unsigned(3,3);
            end if;

          when to_unsigned(4,3) =>
            if data_i(4) = '1' then     --change state
              current_s <= to_unsigned(5,3);
            else
              current_s <= to_unsigned(4,3);
            end if;

          when to_unsigned(5,3) =>
            if data_i(5) = '1' then     --change state
              current_s <= to_unsigned(6,3);
            else
              current_s <= to_unsigned(5,3);
            end if;

          when to_unsigned(6,3) =>
            if data_i(6) = '1' then     --change state
              current_s <= to_unsigned(7,3);
            else
              current_s <= to_unsigned(6,3);
            end if;

          when to_unsigned(7,3) =>
            if data_i(7) = '1' then     --change state
              current_s <= to_unsigned(0,3);
            else
              current_s <= to_unsigned(7,3);
            end if;

          when others =>
            current_s <= to_unsigned(0,3);
        end case;

      end if;
    end if;
  end process sm_states_process;

  current_s_o <= current_s;

end architecture behav;
