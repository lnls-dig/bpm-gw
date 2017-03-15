---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for Control and status registers for FMC PICO 1M 4CH
---------------------------------------------------------------------------------------
-- File           : fmc_pico1m_4ch_regs_pkg.vhd
-- Author         : auto-generated by wbgen2 from fmc_pico1m_4ch_regs.wb
-- Created        : Tue Dec  8 15:27:17 2015
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE fmc_pico1m_4ch_regs.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package wb_fmc_pico1m_4ch_csr_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_wb_fmc_pico1m_4ch_csr_in_registers is record
    fmc_status_prsnt_i                       : std_logic;
    fmc_status_pg_m2c_i                      : std_logic;
    data0_val_i                              : std_logic_vector(31 downto 0);
    data1_val_i                              : std_logic_vector(31 downto 0);
    data2_val_i                              : std_logic_vector(31 downto 0);
    data3_val_i                              : std_logic_vector(31 downto 0);
    end record;
  
  constant c_wb_fmc_pico1m_4ch_csr_in_registers_init_value: t_wb_fmc_pico1m_4ch_csr_in_registers := (
    fmc_status_prsnt_i => '0',
    fmc_status_pg_m2c_i => '0',
    data0_val_i => (others => '0'),
    data1_val_i => (others => '0'),
    data2_val_i => (others => '0'),
    data3_val_i => (others => '0')
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_wb_fmc_pico1m_4ch_csr_out_registers is record
      fmc_ctl_led1_o                           : std_logic;
      fmc_ctl_led2_o                           : std_logic;
      rng_ctl_r0_o                             : std_logic;
      rng_ctl_r1_o                             : std_logic;
      rng_ctl_r2_o                             : std_logic;
      rng_ctl_r3_o                             : std_logic;
      end record;
    
    constant c_wb_fmc_pico1m_4ch_csr_out_registers_init_value: t_wb_fmc_pico1m_4ch_csr_out_registers := (
      fmc_ctl_led1_o => '0',
      fmc_ctl_led2_o => '0',
      rng_ctl_r0_o => '0',
      rng_ctl_r1_o => '0',
      rng_ctl_r2_o => '0',
      rng_ctl_r3_o => '0'
      );
    function "or" (left, right: t_wb_fmc_pico1m_4ch_csr_in_registers) return t_wb_fmc_pico1m_4ch_csr_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
    function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
end package;

package body wb_fmc_pico1m_4ch_csr_wbgen2_pkg is
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
function "or" (left, right: t_wb_fmc_pico1m_4ch_csr_in_registers) return t_wb_fmc_pico1m_4ch_csr_in_registers is
variable tmp: t_wb_fmc_pico1m_4ch_csr_in_registers;
begin
tmp.fmc_status_prsnt_i := f_x_to_zero(left.fmc_status_prsnt_i) or f_x_to_zero(right.fmc_status_prsnt_i);
tmp.fmc_status_pg_m2c_i := f_x_to_zero(left.fmc_status_pg_m2c_i) or f_x_to_zero(right.fmc_status_pg_m2c_i);
tmp.data0_val_i := f_x_to_zero(left.data0_val_i) or f_x_to_zero(right.data0_val_i);
tmp.data1_val_i := f_x_to_zero(left.data1_val_i) or f_x_to_zero(right.data1_val_i);
tmp.data2_val_i := f_x_to_zero(left.data2_val_i) or f_x_to_zero(right.data2_val_i);
tmp.data3_val_i := f_x_to_zero(left.data3_val_i) or f_x_to_zero(right.data3_val_i);
return tmp;
end function;
end package body;
