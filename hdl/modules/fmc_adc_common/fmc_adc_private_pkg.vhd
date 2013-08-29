------------------------------------------------------------------------------
-- Title      : Wishbone FMC ADC Private Package
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-22-08
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Private definitions package for the FMC ADC boards.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-22-08  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.wishbone_pkg.all;
use work.fmc_adc_pkg.all;

package fmc_adc_private_pkg is

  --------------------------------------------------------------------
  -- Specific definitions
  --------------------------------------------------------------------

  -- Internal structure for generate statements

  -- ADC Data/Clock delay registers for generate statements
  type t_adc_fn_dly_int is record
    adc_clk_dly : std_logic_vector(4 downto 0);
    adc_clk_dly_inc : std_logic;
    adc_clk_dly_dec : std_logic;
    adc_clk_load : std_logic;
    adc_clk_dly_sel : std_logic;
    adc_data_dly : std_logic_vector(4 downto 0);
    adc_data_dly_inc : std_logic;
    adc_data_dly_dec : std_logic;
    adc_data_load : std_logic;
    adc_data_dly_sel : std_logic_vector(c_num_adc_bits-1 downto 0);
  end record;

  type t_adc_fn_dly_int_array  is array (natural range<>) of t_adc_fn_dly_int;

end fmc_adc_private_pkg;


--package body fmc_adc_private_pkg is
--
--end fmc_adc_private_pkg;
