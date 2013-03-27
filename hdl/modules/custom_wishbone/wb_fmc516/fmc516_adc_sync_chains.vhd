------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-18-03
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Synchronization between all data chains to a single clock
--                domain. The necessity of such module has to be better
--                understood, but so far, it does not appear necessary
-------------------------------------------------------------------------------
-- Copyright (c) 2013 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-18-03  1.0      lucas.russo      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.custom_wishbone_pkg.all;
use work.fmc516_pkg.all;

entity fmc516_adc_sync_chains is
generic
(
  g_chain_intercon                          : t_chain_intercon
);
port
(
  sys_clk_i                                 : std_logic;
  sys_rst_n_i                               : std_logic;

  -----------------------------
  -- ADC Data Input signals. Each data chain is synchronous to its
  -- own clock.
  -----------------------------
  adc_data_i                                : t_adc_int_array(c_num_adc_channels-1 downto 0);

  -- Reference clock for synchronization with all data chains
  adc_clk_i                                 : std_logic;

  -----------------------------
  -- ADC output signals. Synchronous to a single clock
  -----------------------------
  adc_data_o                                : : t_adc_out_array(c_num_adc_channels-1 downto 0)
);

end fmc516_adc_sync_chains;

architecture rtl of fmc516_adc_sync_chains is


begin


end rtl;
