------------------------------------------------------------------------------
-- Title      : BPM Acquisition Difference Counter
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2014-10-29
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Simple difference counter. It works computing the difference
--              between two counters. When a threshold is hit, a flag is
--              asserted and the counter who hit the threshold does not
--              incremente anymore. After the difference is reduced, the
--              counters resume counting normally
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2014-10-29  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.genram_pkg.all;

entity acq_2_diff_cnt is
generic
(
  -- Threshold in which the counters can differ
  g_threshold_max                           : natural := 2
);
port
(
  clk_i                                     : in  std_logic;
  rst_n_i                                   : in  std_logic;

  cnt0_en_i                                 : in std_logic;
  cnt0_thres_hit_o                          : out std_logic;

  cnt1_en_i                                 : in std_logic;
  cnt1_thres_hit_o                          : out std_logic
);
end acq_2_diff_cnt;

architecture rtl of acq_2_diff_cnt is

  signal diff_cnt0                          : unsigned(f_log2_size(g_threshold_max) downto 0);
  signal diff_cnt0_max                      : std_logic;
  signal diff_cnt0_zero                     : std_logic;

  signal diff_cnt1                          : unsigned(f_log2_size(g_threshold_max) downto 0);
  signal diff_cnt1_max                      : std_logic;
  signal diff_cnt1_zero                     : std_logic;
begin

  -- counter 0 as reference, looking at counter 1
  p_diff_cnt0 : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        diff_cnt0 <= to_unsigned(0, diff_cnt0'length);
      else
        if cnt0_en_i = '1' then           -- counter 0 increments
          -- and counter 1 does not increment
          if cnt1_en_i = '0' and diff_cnt0_max = '0' then
            diff_cnt0 <= diff_cnt0 + 1;   -- diff counter 0 effectively increments
          --else --both pointers increment simultaneouslly. Do nothing in this case
          end if;
        -- counter 0 does not increment and counter 1 increments
        elsif cnt1_en_i = '1' and diff_cnt0_zero = '0' then
          diff_cnt0 <= diff_cnt0 - 1;     -- diff counter 0 effectivelly decrements
          --else -- both pointers does not increment. Do nothing in this case
        end if;
      end if;
    end if;
  end process;

  -- diff counter overflow
  diff_cnt0_max <= '1' when diff_cnt0 = g_threshold_max else '0';
  -- diff counter zero
  diff_cnt0_zero <= '1' when diff_cnt0 = to_unsigned(0, diff_cnt0'length) else '0';

  cnt0_thres_hit_o <= diff_cnt0_max;

  -- counter 1 as reference, looking at counter 1
  p_diff_cnt1 : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        diff_cnt1 <= to_unsigned(0, diff_cnt1'length);
      else
        if cnt1_en_i = '1' then           -- counter 1 increments
          -- and counter 1 does not increment
          if cnt0_en_i = '0' and diff_cnt1_max = '0' then
            diff_cnt1 <= diff_cnt1 + 1;   -- diff counter 1 effectively increments
          --else --both pointers increment simultaneouslly. Do nothing in this case
          end if;
        -- counter 1 does not increment and counter 1 increments
        elsif cnt0_en_i = '1' and diff_cnt1_zero = '0' then
          diff_cnt1 <= diff_cnt1 - 1;     -- diff counter 1 effectivelly decrements
          --else -- both pointers does not increment. Do nothing in this case
        end if;
      end if;
    end if;
  end process;

  -- diff counter overflow
  diff_cnt1_max <= '1' when diff_cnt1 = g_threshold_max else '0';
  -- diff counter zero
  diff_cnt1_zero <= '1' when diff_cnt1 = to_unsigned(0, diff_cnt1'length) else '0';

  cnt1_thres_hit_o <= diff_cnt1_max;

end rtl;
