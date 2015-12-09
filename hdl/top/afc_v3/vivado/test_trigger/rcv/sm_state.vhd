-------------------------------------------------------------------------------
-- Title      : Machine state that controls state changes
-- Project    :
-------------------------------------------------------------------------------
-- File       : sm_state.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-12-03
-- Last update: 2015-12-03
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sm_state is

  generic (
    g_num_states : natural := 8);

  port (
    current_s_i : in  natural;
    data_i      : in  std_logic_vector(g_num_states-1 downto 0);
    next_s_o    : out natural);

end entity sm_state;

architecture behav of sm_state is

  signal next_s, current_s : natural range 0 to g_num_states-1 := 0;
  signal data              : std_logic_vector(g_num_states-1 downto 0);

begin  -- architecture behav

-- purpose: Machine state that controls the state
  -- type   : sequential
  -- inputs : next_s
  sm_state : process (current_s, data) is
  begin  -- process state_mach

    case current_s is

      when 0 =>
        if data(0) = '1' then
          next_s <= 1;
        else
          next_s <= 0;
        end if;

      when 1 =>
        if data(1) = '1' then
          next_s <= 2;
        else
          next_s <= 1;
        end if;

      when 2 =>
        if data(2) = '1' then
          next_s <= 3;
        else
          next_s <= 2;
        end if;

      when 3 =>
        if data(3) = '1' then
          next_s <= 4;
        else
          next_s <= 3;
        end if;

      when 4 =>
        if data(4) = '1' then
          next_s <= 5;
        else
          next_s <= 4;
        end if;

      when 5 =>
        if data(5) = '1' then
          next_s <= 6;
        else
          next_s <= 5;
        end if;

      when 6 =>
        if data(6) = '1' then
          next_s <= 7;
        else
          next_s <= 6;
        end if;

      when 7 =>
        if data(7) = '1' then
          next_s <= 0;
        else
          next_s <= 7;
        end if;

      when others =>
        next_s <= 0;
    end case;

  end process sm_state;

  current_s <= current_s_i;
  next_s_o  <= next_s;
  data      <= data_i;

end architecture behav;
