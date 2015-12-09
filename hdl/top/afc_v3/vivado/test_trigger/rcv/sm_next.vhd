-------------------------------------------------------------------------------
-- Title      : State Machine for next state
-- Project    :
-------------------------------------------------------------------------------
-- File       : sm_next.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-12-03
-- Last update: 2015-12-03
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

entity sm_next is

  generic (
    g_num_states : positive := 8);           -- number of states
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    next_s_i    : in  natural;
    current_s_o : out natural);
end entity sm_next;

architecture behav of sm_next is

  signal next_s, current_s : natural range 0 to g_num_states-1 := 0;

begin  -- architecture behav
  sm_next_process : process (clk_i) is
  begin  -- process sm_next_process
    if rising_edge(clk_i) then          -- rising clock edge
      if rst_i = '1' then               -- synchronous reset (active high)
        current_s <= 0;
      else
        current_s <= next_s;
      end if;
    end if;
  end process sm_next_process;

  current_s_o <= current_s;
  next_s      <= next_s_i;

end architecture behav;
