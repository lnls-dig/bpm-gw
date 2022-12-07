-------------------------------------------------------------------------------
-- Title      : Look-up table sweeper
-- Project    :
-------------------------------------------------------------------------------
-- File       : lut_sweep.vhd
-- Author     : aylons  <aylons@LNLS190>
-- Company    :
-- Created    : 2014-03-07
-- Last update: 2022-12-07
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Sweep look-up table addresses for DDS
-------------------------------------------------------------------------------
-- Copyright (c) 2014
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author            Description
-- 2014-03-07  1.0      aylons            Created
-- 2022-12-07  1.1      guilherme.ricioli Changed reset behavior
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lut_sweep is
  generic (
    -- number of data points of sin/cos files (each)
    g_number_of_points  : natural := 203;

    g_bus_size          : natural := 16 -- must be
                                        -- ceil(log2(g_number_of_points))
  );
  port (
    clk_i               : in  std_logic;
    ce_i                : in  std_logic;
    rst_i               : in  std_logic;
    valid_i             : in  std_logic;
    address_o           : out std_logic_vector(g_bus_size-1 downto 0);
    valid_o             : out std_logic
  );
end entity lut_sweep;

architecture behavioral of lut_sweep is
begin

  -- processes
  process(clk_i)
    variable v_sample_idx : natural range 0 to g_number_of_points := g_number_of_points-1;
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        -- the first valid after reset should output address "0"
        v_sample_idx := g_number_of_points-1;

        valid_o <= '0';

      elsif ce_i = '1' then
        if valid_i = '1' then
          if v_sample_idx = g_number_of_points-1 then
            v_sample_idx := 0;
          else
            v_sample_idx := v_sample_idx + 1;
          end if;
        end if;

        address_o <= std_logic_vector(to_unsigned(v_sample_idx, g_bus_size));
        valid_o <= valid_i;

      end if;
    end if; -- rising_edge(clk_i)
  end process;

end architecture behavioral;
