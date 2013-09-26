------------------------------------------------------------------------------
-- Title      : Wishbone FMC ADC Fine Delay Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-23-08
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: ADC Fine delay interface between wishbone and internal IDELAY interface
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-23-08  1.0      lucas.russo      Initial Version
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.fmc_adc_pkg.all;

entity fmc_adc_dly_iface is
generic
(
  g_with_var_loadable                       : boolean := true;
  g_with_variable                           : boolean := true;
  g_with_fn_dly_select                      : boolean := false
);
port
(
  rst_n_i                                   : in std_logic;
  clk_sys_i                                 : in std_logic;

  adc_fn_dly_wb_ctl_i                       : in t_adc_fn_dly_wb_ctl;
  adc_fn_dly_o                              : out t_adc_fn_dly
);
end fmc_adc_dly_iface;

architecture rtl of fmc_adc_dly_iface is

  signal adc_loadable_dly_pulse_clk_int     : std_logic;
  signal adc_loadable_dly_pulse_data_int    : std_logic;

  signal adc_var_dly_pulse_clk_int          : std_logic;
  signal adc_var_dly_pulse_data_int         : std_logic;

begin

  -- Var Loadable Interface
  gen_with_var_loadable : if (g_with_var_loadable) generate

    p_adc_loadable_dly : process (clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_n_i = '0' then
          adc_fn_dly_o.clk_chain.idelay.val <= (others => '0');
          adc_fn_dly_o.data_chain.idelay.val <= (others => '0');
          adc_loadable_dly_pulse_clk_int <= '0';
          adc_loadable_dly_pulse_data_int <= '0';
        else
          -- write to clock register delay
          if adc_fn_dly_wb_ctl_i.clk_chain.loadable.load = '1' then
            adc_fn_dly_o.clk_chain.idelay.val <= adc_fn_dly_wb_ctl_i.clk_chain.loadable.val;
          end if;

          -- write to data register delay
          if adc_fn_dly_wb_ctl_i.data_chain.loadable.load = '1' then
            adc_fn_dly_o.data_chain.idelay.val <= adc_fn_dly_wb_ctl_i.data_chain.loadable.val;
          end if;

          -- Keep delay symmetric between var loadable and variable interfaces
          adc_loadable_dly_pulse_clk_int  <= adc_fn_dly_wb_ctl_i.clk_chain.loadable.pulse;
          adc_loadable_dly_pulse_data_int <= adc_fn_dly_wb_ctl_i.data_chain.loadable.pulse;

        end if;
      end if;
    end process;

  end generate;

  -- Fill with dummy signals
  gen_without_var_loadable : if (not g_with_var_loadable) generate

    adc_loadable_dly_pulse_clk_int  <= '0';
    adc_loadable_dly_pulse_data_int <= '0';

  end generate;

  -- Variable interface
  gen_with_variable_loadable : if (g_with_variable) generate

    p_adc_variable_dly : process (clk_sys_i)
    begin
      if rising_edge(clk_sys_i) then
        if rst_n_i = '0' then
          adc_fn_dly_o.clk_chain.idelay.incdec <= '0';
          adc_fn_dly_o.data_chain.idelay.incdec <= '0';
          adc_var_dly_pulse_clk_int <= '0';
          adc_var_dly_pulse_data_int <= '0';
        else

          -- Increment/Decrement clk delays
          if adc_fn_dly_wb_ctl_i.clk_chain.var.inc = '1' then
            adc_fn_dly_o.clk_chain.idelay.incdec <= '1';
            adc_var_dly_pulse_clk_int <= '1';
          elsif adc_fn_dly_wb_ctl_i.clk_chain.var.dec = '1' then
            adc_fn_dly_o.clk_chain.idelay.incdec <= '0';
            adc_var_dly_pulse_clk_int <= '1';
          else
            adc_fn_dly_o.clk_chain.idelay.incdec <= '0';
            adc_var_dly_pulse_clk_int <= '0';
          end if;

          -- Increment/Decrement data delays
          if adc_fn_dly_wb_ctl_i.data_chain.var.inc = '1' then
            adc_fn_dly_o.data_chain.idelay.incdec <= '1';
            adc_var_dly_pulse_data_int <= '1';
          elsif adc_fn_dly_wb_ctl_i.data_chain.var.dec = '1' then
            adc_fn_dly_o.data_chain.idelay.incdec <= '0';
            adc_var_dly_pulse_data_int <= '1';
          else
            adc_fn_dly_o.data_chain.idelay.incdec <= '0';
            adc_var_dly_pulse_data_int <= '0';
          end if;

        end if;
      end if;
    end process;

  end generate;

  -- Fill with dummy signals
  gen_without_variable : if (not g_with_variable) generate

    adc_var_dly_pulse_clk_int  <= '0';
    adc_var_dly_pulse_data_int <= '0';

  end generate;

  -- Unify pulse from both interfaces
  adc_fn_dly_o.clk_chain.idelay.pulse <= adc_loadable_dly_pulse_clk_int or
                                                      adc_var_dly_pulse_clk_int;
  adc_fn_dly_o.data_chain.idelay.pulse <= adc_loadable_dly_pulse_data_int or
                                                      adc_var_dly_pulse_data_int;

  -- Passthrough select signals
  gen_with_fn_dly_select : if (g_with_fn_dly_select) generate

    adc_fn_dly_o.clk_chain.sel.which <= adc_fn_dly_wb_ctl_i.clk_chain.sel.which;
    adc_fn_dly_o.data_chain.sel.which <= adc_fn_dly_wb_ctl_i.data_chain.sel.which;

  end generate;

end rtl;
