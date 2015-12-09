-------------------------------------------------------------------------------
-- Title      : State machine for the signal transmitter
-- Project    :
-------------------------------------------------------------------------------
-- File       : sm_transm.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2015-12-09
-- Last update: 2015-12-09
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
-- 2015-12-09  1.0      vfinotti        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sm_transm is

  generic (
    g_num_pins         : natural := 8;
    g_cycles_to_change : natural := 4);  -- number of clock cycles to change pins and generate pulse

  port (
    clk_i   : in  std_logic;
    rst_n_i : in  std_logic;
    pulse_o : out std_logic_vector(g_num_pins-1 downto 0));

end sm_transm;

architecture structure of sm_transm is

  signal transm_pulse : std_logic                           := '0';  -- enables pulse to be transmitted
  signal next_pin     : natural range g_num_pins-1 downto 0 := 0;

begin  -- architecture structure

  pr_clk_counter : process (clk_i) is
    variable clk_counter : natural range g_cycles_to_change downto 0 := 0;
  begin  -- process main
    if rising_edge(clk_i) then          -- rising clock edge
      if rst_n_i = '0' then             -- synchronous reset (negative high)
        clk_counter  := 0;
        transm_pulse <= '0';
      else
        if clk_counter < g_cycles_to_change then
          clk_counter  := clk_counter + 1;
          transm_pulse <= '0';
        else                            -- generate pulse and reset counter
          clk_counter  := 0;
          transm_pulse <= '1';
        end if;
      end if;
    end if;
  end process pr_clk_counter;

  pr_pulse_gen : process (clk_i) is
  begin  -- process main
    if rising_edge(clk_i) then          -- rising clock edge
      if rst_n_i = '0' then             -- synchronous reset (active high)
        pulse_o <= (others => '0');
      else
        if (transm_pulse = '1') then
          pulse_o(next_pin) <= '1';
        else
          pulse_o <= (others => '0');
        end if;
      end if;
    end if;
  end process pr_pulse_gen;

  pr_next_pin : process (clk_i) is
  begin  -- process next_pin
    if rising_edge(clk_i) then          -- rising clock edge
      if rst_n_i = '0' then             -- synchronous reset (negativa high)
        next_pin <= 0;
      elsif (transm_pulse = '1') then
        if next_pin < g_num_pins-1 then
          next_pin <= next_pin + 1;
        else
          next_pin <= 0;
        end if;
      end if;
    end if;
  end process pr_next_pin;
end architecture structure;
