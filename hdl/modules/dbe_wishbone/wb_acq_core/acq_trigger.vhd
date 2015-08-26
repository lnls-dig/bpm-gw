------------------------------------------------------------------------------
-- Title      : Acquisition Trigger Logic
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2015-19-08
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Acquisition trigger logic for hardware trigger (external and data),
--               alignment and delay balancing (for trigger detection)
-------------------------------------------------------------------------------
-- Copyright (c) 2015 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2015-19-08  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.acq_core_pkg.all;

entity acq_trigger is
generic
(
  g_data_in_width                           : natural := 128
);
port
(
  fs_clk_i                                  : in std_logic;
  fs_ce_i                                   : in std_logic;
  fs_rst_n_i                                : in std_logic;

  -- Acquisition input
  acq_data_i                                : in std_logic_vector(g_data_in_width-1 downto 0);
  acq_valid_i                               : in std_logic;
  acq_trig_i                                : in std_logic;

  -- Acquisition data with data + metadata
  acq_data_o                                : out std_logic_vector(g_data_in_width-1 downto 0);
  acq_valid_o                               : out std_logic;
  acq_trig_o                                : out std_logic
);
end acq_trigger;

architecture rtl of acq_trigger is

  signal acq_data                           : std_logic_vector(g_data_in_width-1 downto 0);
  signal acq_valid                          : std_logic;
  signal acq_trig_align                     : std_logic;

  signal acq_data_out                       : std_logic_vector(g_data_in_width-1 downto 0);
  signal acq_valid_out                      : std_logic;
  signal acq_trig_align_out                 : std_logic;

begin

  p_reg_data_in : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        acq_data <= (others => '0');
        acq_valid <= '0';
      else
        acq_valid <= acq_valid_i;

        if acq_valid_i = '1' then
          acq_data <= acq_data_i;
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Trigger Logic
  -----------------------------------------------------------------------------

  -- Hold trigger signal until a valid sample is found
  p_trig_align : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        acq_trig_align <= '0';
      else
        if acq_trig_i = '1' then
          acq_trig_align <= '1';
        elsif acq_valid = '1' then
          acq_trig_align <= '0';
        end if;
      end if;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Output Logic
  -----------------------------------------------------------------------------

  p_reg_trig_data : process (fs_clk_i)
  begin
    if rising_edge(fs_clk_i) then
      if fs_rst_n_i = '0' then
        acq_data_out <= (others => '0');
        acq_valid_out <= '0';
        acq_trig_align_out <= '0';
      else
        acq_data_out <= acq_data;
        acq_valid_out <= acq_valid;
        acq_trig_align_out <= acq_trig_align;
      end if;
    end if;
  end process;

  acq_data_o <= acq_data_out;
  acq_valid_o <= acq_valid_out;
  acq_trig_o <= acq_trig_align_out;

end rtl;
