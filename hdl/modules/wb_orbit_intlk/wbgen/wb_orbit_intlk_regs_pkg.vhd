---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for BPM Orbit Interlock Interface Registers
---------------------------------------------------------------------------------------
-- File           : wb_orbit_intlk_regs_pkg.vhd
-- Author         : auto-generated by wbgen2 from wb_orbit_intlk_regs.wb
-- Created        : Thu Jun 18 16:34:13 2020
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wb_orbit_intlk_regs.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package orbit_intlk_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_orbit_intlk_in_registers is record
    ctrl_reserved_i                          : std_logic_vector(23 downto 0);
    sts_trans_bigger_x_i                     : std_logic;
    sts_trans_bigger_y_i                     : std_logic;
    sts_trans_bigger_ltc_x_i                 : std_logic;
    sts_trans_bigger_ltc_y_i                 : std_logic;
    sts_trans_bigger_any_i                   : std_logic;
    sts_trans_bigger_i                       : std_logic;
    sts_trans_bigger_ltc_i                   : std_logic;
    sts_ang_bigger_x_i                       : std_logic;
    sts_ang_bigger_y_i                       : std_logic;
    sts_ang_bigger_ltc_x_i                   : std_logic;
    sts_ang_bigger_ltc_y_i                   : std_logic;
    sts_ang_bigger_any_i                     : std_logic;
    sts_ang_bigger_i                         : std_logic;
    sts_ang_bigger_ltc_i                     : std_logic;
    sts_intlk_bigger_i                       : std_logic;
    sts_intlk_bigger_ltc_i                   : std_logic;
    sts_reserved_i                           : std_logic_vector(15 downto 0);
    end record;
  
  constant c_orbit_intlk_in_registers_init_value: t_orbit_intlk_in_registers := (
    ctrl_reserved_i => (others => '0'),
    sts_trans_bigger_x_i => '0',
    sts_trans_bigger_y_i => '0',
    sts_trans_bigger_ltc_x_i => '0',
    sts_trans_bigger_ltc_y_i => '0',
    sts_trans_bigger_any_i => '0',
    sts_trans_bigger_i => '0',
    sts_trans_bigger_ltc_i => '0',
    sts_ang_bigger_x_i => '0',
    sts_ang_bigger_y_i => '0',
    sts_ang_bigger_ltc_x_i => '0',
    sts_ang_bigger_ltc_y_i => '0',
    sts_ang_bigger_any_i => '0',
    sts_ang_bigger_i => '0',
    sts_ang_bigger_ltc_i => '0',
    sts_intlk_bigger_i => '0',
    sts_intlk_bigger_ltc_i => '0',
    sts_reserved_i => (others => '0')
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_orbit_intlk_out_registers is record
      ctrl_en_o                                : std_logic;
      ctrl_clr_o                               : std_logic;
      ctrl_min_sum_en_o                        : std_logic;
      ctrl_trans_en_o                          : std_logic;
      ctrl_trans_clr_o                         : std_logic;
      ctrl_ang_en_o                            : std_logic;
      ctrl_ang_clr_o                           : std_logic;
      min_sum_o                                : std_logic_vector(31 downto 0);
      trans_max_x_o                            : std_logic_vector(31 downto 0);
      trans_max_y_o                            : std_logic_vector(31 downto 0);
      ang_max_x_o                              : std_logic_vector(31 downto 0);
      ang_max_y_o                              : std_logic_vector(31 downto 0);
      end record;
    
    constant c_orbit_intlk_out_registers_init_value: t_orbit_intlk_out_registers := (
      ctrl_en_o => '0',
      ctrl_clr_o => '0',
      ctrl_min_sum_en_o => '0',
      ctrl_trans_en_o => '0',
      ctrl_trans_clr_o => '0',
      ctrl_ang_en_o => '0',
      ctrl_ang_clr_o => '0',
      min_sum_o => (others => '0'),
      trans_max_x_o => (others => '0'),
      trans_max_y_o => (others => '0'),
      ang_max_x_o => (others => '0'),
      ang_max_y_o => (others => '0')
      );
    function "or" (left, right: t_orbit_intlk_in_registers) return t_orbit_intlk_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
    function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
end package;

package body orbit_intlk_wbgen2_pkg is
function f_x_to_zero (x:std_logic) return std_logic is
begin
if x = '1' then
return '1';
else
return '0';
end if;
end function;
function f_x_to_zero (x:std_logic_vector) return std_logic_vector is
variable tmp: std_logic_vector(x'length-1 downto 0);
begin
for i in 0 to x'length-1 loop
if(x(i) = 'X' or x(i) = 'U') then
tmp(i):= '0';
else
tmp(i):=x(i);
end if; 
end loop; 
return tmp;
end function;
function "or" (left, right: t_orbit_intlk_in_registers) return t_orbit_intlk_in_registers is
variable tmp: t_orbit_intlk_in_registers;
begin
tmp.ctrl_reserved_i := f_x_to_zero(left.ctrl_reserved_i) or f_x_to_zero(right.ctrl_reserved_i);
tmp.sts_trans_bigger_x_i := f_x_to_zero(left.sts_trans_bigger_x_i) or f_x_to_zero(right.sts_trans_bigger_x_i);
tmp.sts_trans_bigger_y_i := f_x_to_zero(left.sts_trans_bigger_y_i) or f_x_to_zero(right.sts_trans_bigger_y_i);
tmp.sts_trans_bigger_ltc_x_i := f_x_to_zero(left.sts_trans_bigger_ltc_x_i) or f_x_to_zero(right.sts_trans_bigger_ltc_x_i);
tmp.sts_trans_bigger_ltc_y_i := f_x_to_zero(left.sts_trans_bigger_ltc_y_i) or f_x_to_zero(right.sts_trans_bigger_ltc_y_i);
tmp.sts_trans_bigger_any_i := f_x_to_zero(left.sts_trans_bigger_any_i) or f_x_to_zero(right.sts_trans_bigger_any_i);
tmp.sts_trans_bigger_i := f_x_to_zero(left.sts_trans_bigger_i) or f_x_to_zero(right.sts_trans_bigger_i);
tmp.sts_trans_bigger_ltc_i := f_x_to_zero(left.sts_trans_bigger_ltc_i) or f_x_to_zero(right.sts_trans_bigger_ltc_i);
tmp.sts_ang_bigger_x_i := f_x_to_zero(left.sts_ang_bigger_x_i) or f_x_to_zero(right.sts_ang_bigger_x_i);
tmp.sts_ang_bigger_y_i := f_x_to_zero(left.sts_ang_bigger_y_i) or f_x_to_zero(right.sts_ang_bigger_y_i);
tmp.sts_ang_bigger_ltc_x_i := f_x_to_zero(left.sts_ang_bigger_ltc_x_i) or f_x_to_zero(right.sts_ang_bigger_ltc_x_i);
tmp.sts_ang_bigger_ltc_y_i := f_x_to_zero(left.sts_ang_bigger_ltc_y_i) or f_x_to_zero(right.sts_ang_bigger_ltc_y_i);
tmp.sts_ang_bigger_any_i := f_x_to_zero(left.sts_ang_bigger_any_i) or f_x_to_zero(right.sts_ang_bigger_any_i);
tmp.sts_ang_bigger_i := f_x_to_zero(left.sts_ang_bigger_i) or f_x_to_zero(right.sts_ang_bigger_i);
tmp.sts_ang_bigger_ltc_i := f_x_to_zero(left.sts_ang_bigger_ltc_i) or f_x_to_zero(right.sts_ang_bigger_ltc_i);
tmp.sts_intlk_bigger_i := f_x_to_zero(left.sts_intlk_bigger_i) or f_x_to_zero(right.sts_intlk_bigger_i);
tmp.sts_intlk_bigger_ltc_i := f_x_to_zero(left.sts_intlk_bigger_ltc_i) or f_x_to_zero(right.sts_intlk_bigger_ltc_i);
tmp.sts_reserved_i := f_x_to_zero(left.sts_reserved_i) or f_x_to_zero(right.sts_reserved_i);
return tmp;
end function;
end package body;