-------------------------------------------------------------------------------
-- Title      : Dynamic Pulse width extender
-- Project    : General Cores library
-------------------------------------------------------------------------------
-- File       : gc_extend_pulse.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN
-- Created    : 2009-09-01
-- Last update: 2012-06-19
-- Platform   : FPGA-generic
-- Standard   : VHDL '93
-------------------------------------------------------------------------------
-- Description:
-- Synchronous pulse extender. Generates a pulse of dynamically programmable width upon
-- detection of a rising edge in the input. The code is based on
-- gc_extend_pulse.vhd created by Tomasz Wlostowskyt, from General Cores library.
-------------------------------------------------------------------------------
--
-- Copyright (c) 2009-2011 CERN
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2015-dec-17 0.9      vfinotti        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

--library work;
--use work.gencores_pkg.all;
--use work.genram_pkg.all;

entity extend_pulse_dyn is

  generic (
    -- output pulse width in clk_i cycles
    g_max_width : natural := 1000
    );
  port (
    clk_i         : in  std_logic;
    rst_n_i       : in  std_logic;
    pulse_i       : in  std_logic;
    pulse_width_i : in  natural;
    -- extended output pulse
    extended_o    : out std_logic := '0');
end extend_pulse_dyn;

architecture rtl of extend_pulse_dyn is

  -- signal cntr         : unsigned(f_log2_size(g_max_width)-1 downto 0);
  signal cntr         : unsigned(32-1 downto 0);
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
        cntr         <= to_unsigned(pulse_width_i - 2, cntr'length);
      elsif cntr /= to_unsigned(0, cntr'length) then
        cntr <= cntr - 1;
      else
        extended_int <= '0';
      end if;
    end if;
  end process extend;

  extended_o <= pulse_i or extended_int;

end rtl;
