-------------------------------------------------------------------------------
-- Title      : Dynamic pulse width extender
-- Project    :
-------------------------------------------------------------------------------
-- File       : extend_pulse_dyn.vhd
-- Author     : Vitor Finotti Ferreira  <vfinotti@finotti-Inspiron-7520>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2016-01-22
-- Last update: 2016-01-27
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Synchronous pulse extender. Generates a pulse of dynamically programmable width upon
-- detection of a rising edge in the input. The code is based on
-- gc_extend_pulse.vhd created by Tomasz Wlostowskyt, from General Cores library.
-------------------------------------------------------------------------------
-- Copyright (c) 2016 Brazilian Synchrotron Light Laboratory, LNLS/CNPEM

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
-- Date        Version  Author          Description
-- 2015-dec-17 0.9      vfinotti        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

entity extend_pulse_dyn is

  generic (
    -- output pulse width in clk_i cycles
    g_width_bus_size : natural := 32
    );
  port (
    clk_i         : in  std_logic;
    rst_n_i       : in  std_logic;
    pulse_i       : in  std_logic;
    pulse_width_i : in  unsigned(g_width_bus_size-1 downto 0);
    -- extended output pulse
    extended_o    : out std_logic := '0');
end extend_pulse_dyn;

architecture rtl of extend_pulse_dyn is

  signal cntr         : unsigned(g_width_bus_size-1 downto 0);
  signal extended_int : std_logic;

begin  -- rtl

  extend : process (clk_i, rst_n_i)
  begin  -- process extend
    if rst_n_i = '0' then                   -- asynchronous reset (active low)
      extended_int <= '0';
      cntr         <= (others => '0');
    elsif clk_i'event and clk_i = '1' then  -- rising clock edge
      if(pulse_i = '1') then
        extended_int <= '1';
        cntr         <= pulse_width_i - 2;
      elsif cntr /= to_unsigned(0, cntr'length) then
        cntr <= cntr - 1;
      else
        extended_int <= '0';
      end if;
    end if;
  end process extend;

  extended_o <= pulse_i or extended_int;

end rtl;
