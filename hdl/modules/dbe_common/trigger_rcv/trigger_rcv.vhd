-------------------------------------------------------------------------------
-- Title      : Trigger receiver
-- Project    :
-------------------------------------------------------------------------------
-- File       : trigger_rcv.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    :
-- Created    : 2015-11-09
-- Last update: 2015-11-30
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Receives a signal from an FPGA port, debounces the signal and
-- outputs a pulse with a configurable clock width.
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
-- 2015-11-09  1.0      aylons  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gen_pulse is

  port (
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    pulse_i : in  std_logic;
    pulse_o : out std_logic);
end entity gen_pulse;

architecture structural of gen_pulse is

  signal s_state : natural := 0;

begin

  process (clk_i, rst_i)
  begin
    if rst_i = '1' then
      pulse_o <= '0';
      s_state <= 0;
    elsif rising_edge(clk_i) then
      case s_state is
        -- wait for pulse rising edge to output a pulse
        when 0 =>
          if pulse_i = '1' then
            s_state <= 1;
            pulse_o <= '1';
          else
            pulse_o <= '0';
          end if;
        -- return output to '0' and wait for signal unset to begin again
        when 1 =>
          if pulse_i = '0' then
            s_state <= 0;
          end if;
          pulse_o <= '0';
        when others =>
          s_state <= 0;
          pulse_o <= '0';
      end case;
    end if;
  end process;


end architecture structural;

-------------------------------------------------------------------------------
-----------------
----Main entity--
-----------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.gencores_pkg.all;

entity trigger_rcv is
  generic (
    -- Number of glicth filter registers
    g_glitch_len_width : positive := 8;
    -- Width of the output pulse after edge detection
    g_pulse_width      : positive := 1
    );
  port(
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    len_i   : in  std_logic_vector(g_glitch_len_width-1 downto 0);
    data_i  : in  std_logic;
    pulse_o : out std_logic
    );
end entity trigger_rcv;

architecture structural of trigger_rcv is

  signal deglitched : std_logic;
  signal rst_n      : std_logic;

  component gc_dyn_glitch_filt is
    generic (
      g_len_width : natural);
    port (
      clk_i   : in  std_logic;
      rst_n_i : in  std_logic;
      len_i   : in  std_logic_vector(g_len_width-1 downto 0);
      dat_i   : in  std_logic;
      dat_o   : out std_logic);
  end component gc_dyn_glitch_filt;

  component gen_pulse is
    port (
      clk_i   : in  std_logic;
      rst_i   : in  std_logic;
      pulse_i : in  std_logic;
      pulse_o : out std_logic);
  end component gen_pulse;

begin

  rst_n <= not(rst_i);

  cmp_deglitcher : gc_dyn_glitch_filt
    generic map (
      g_len_width => g_glitch_len_width)
    port map (
      clk_i   => clk_i,
      rst_n_i => rst_n,
      len_i   => len_i,
      dat_i   => data_i,
      dat_o   => deglitched);

  cmp_edge_detector : gen_pulse
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      pulse_i => deglitched,
      pulse_o => pulse_o);

end architecture structural;
