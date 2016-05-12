------------------------------------------------------------------------
-- Title      : Wishbone Trigger Interface
-- Project    :
-------------------------------------------------------------------------------
-- File       : trigger_resolver.vhd
-- Author     : Lucas Russo  <lerwys@gmail.com>
-- Company    : Brazilian Synchrotron Light Laboratory, LNLS/CNPEM
-- Created    : 2016-05-11
-- Last update:
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Top module for the Wishbone Trigger MUX interface
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
-- 2016-05-11  1.0      lerwys          Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
-- Main Wishbone Definitions
use work.wishbone_pkg.all;
-- Custom Wishbone Modules
use work.dbe_wishbone_pkg.all;
-- Reset Synch
use work.dbe_common_pkg.all;
-- Trigger types
use work.trigger_pkg.all;

entity trigger_resolver is
  generic (
    g_trig_num             : natural := 8;
    g_num_mux_interfaces   : natural := 2;
    g_out_resolver         : string := "fanout";
    g_in_resolver          : string := "or"
  );
  port (
    clk_i   : in std_logic;
    rst_n_i : in std_logic;

    -------------------------------
    --- Trigger ports
    -------------------------------

    trig_resolved_out_o : out t_trig_channel_array(g_trig_num-1 downto 0);
    trig_resolved_in_i  : in  t_trig_channel_array(g_trig_num-1 downto 0);

    trig_mux_out_o : out t_trig_channel_array2d(g_num_mux_interfaces-1 downto 0, g_trig_num-1 downto 0);
    trig_mux_in_i  : in  t_trig_channel_array2d(g_num_mux_interfaces-1 downto 0, g_trig_num-1 downto 0)
  );
end entity trigger_resolver;

architecture rtl of trigger_resolver is

  signal trig_mux_out_int : t_trig_channel_array2d(g_num_mux_interfaces-1 downto 0, g_trig_num-1 downto 0);
  signal trig_mux_in_int  : t_trig_channel_array(g_trig_num-1 downto 0);

  -- Trigger ordered by interfaces
  subtype t_trig_interface_pulses is std_logic_vector(g_num_mux_interfaces-1 downto 0);
  type t_trig_interface_pulses_array is array (natural range <>) of t_trig_interface_pulses;

  signal trig_mux_in_interface_pulses : t_trig_interface_pulses_array(g_trig_num-1 downto 0);

  -- From general-cores wb_crossbar module
  -- If any of the bits are '1', the whole thing is '1'
  -- This function makes the check explicitly have logarithmic depth.
  function f_vector_OR(x : std_logic_vector)
    return std_logic
  is
    constant len : integer := x'length;
    constant mid : integer := len / 2;
    alias y : std_logic_vector(len-1 downto 0) is x;
  begin
    if len = 1
    then return y(0);
    else return f_vector_OR(y(len-1 downto mid)) or
                f_vector_OR(y(mid-1 downto 0));
    end if;
  end f_vector_OR;

begin  -- architecture rtl

  assert (g_out_resolver = "fanout") -- Output Resolver
  report "[trigger_resolver] only g_out_resolver equal to ""fanout"" is supported!"
  severity failure;

  assert (g_in_resolver = "or") -- Input Resolver
  report "[trigger_resolver] only g_in_resolver equal to ""or"" is supported!"
  severity failure;

  -- Generate Output
  gen_output_interfaces : for i in 0 to g_num_mux_interfaces-1 generate
    gen_output_trigger_channels : for j in 0 to g_trig_num-1 generate

      gen_output_resolver_fanout : if g_out_resolver = "fanout" generate
        p_output : process (clk_i)
        begin
          if rising_edge(clk_i) then
            if rst_n_i = '0' then
              trig_mux_out_int (i, j) <= c_trig_channel_dummy;
            else
              trig_mux_out_int (i, j) <= trig_resolved_in_i(j);
            end if;
          end if;
        end process;
      end generate;

    end generate;
  end generate;

  trig_mux_out_o <= trig_mux_out_int;

  -- Reorder input channels
  gen_reorder_trigger_channels : for j in 0 to g_trig_num-1 generate
    gen_input_interfaces : for i in 0 to g_num_mux_interfaces-1 generate

      trig_mux_in_interface_pulses(j)(i) <= trig_mux_in_i(i, j).pulse;

    end generate;
  end generate;

  -- Generate Inputs
  gen_input_trigger_channels : for j in 0 to g_trig_num-1 generate
    gen_input_resolver_or : if g_in_resolver = "or" generate
      p_input : process (clk_i)
      begin
        if rising_edge(clk_i) then
          if rst_n_i = '0' then
            trig_mux_in_int(j) <= c_trig_channel_dummy;
          else
            trig_mux_in_int(j).pulse <= f_vector_OR(trig_mux_in_interface_pulses(j));
          end if;
        end if;
      end process;
    end generate;
  end generate;

  trig_resolved_out_o <= trig_mux_in_int;

end architecture rtl;
