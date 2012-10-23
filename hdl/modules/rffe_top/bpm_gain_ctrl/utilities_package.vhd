------------------------------------------------------------------------------
-- Title      : Utilities Package
------------------------------------------------------------------------------
-- Component  : find_msb
-- Description: 
------------------------------------------------------------------------------
-- Component  : data_generator
-- Description: 
------------------------------------------------------------------------------
-- Component  : log2
-- Description: 
------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utilities_pkg is

    function find_msb (signal arg: in std_logic_vector; signal sign: in std_logic) return std_logic_vector;
    function log2(arg : natural) return natural;
    
    component data_generator is
    generic
    (
        g_data_width  : natural range 2 to 48 := 25
    );
    port
    (
        clk_i           : in std_logic;
        rst_i           : in std_logic;
        data_init_i     : in std_logic_vector(g_data_width-1 downto 0);
        data_step_i     : in std_logic_vector(g_data_width-1 downto 0);
        niterations_i   : in std_logic_vector(9 downto 0);
        data_o          : out std_logic_vector(g_data_width-1 downto 0);
        trg_o           : out std_logic
    );
    end component;

end utilities_pkg;

package body utilities_pkg is

    function find_msb (signal arg: in std_logic_vector; signal sign: in std_logic) return std_logic_vector is
        variable v_index: natural := arg'left;
        
    begin
        while true loop
            if arg(v_index) = not(sign) then
                exit;
            elsif v_index = 0 then
                exit;
            end if;
            v_index := v_index - 1;
        end loop;

        return std_logic_vector(to_unsigned(v_index,log2(arg'length)+1));
    end find_msb;


    function log2(arg : natural) return natural is
        variable v_result : natural ;
        variable v_index  : natural := 0;
        
    begin
        while true loop
            if 2**v_index >= arg then
                v_result := v_index;
                exit ;
            end if ;
            v_index := v_index + 1;
        end loop ;
      
        return v_index;    
    end function;

end utilities_pkg;


----------------------------------------------------------------------------------------------
-- data_generator
----------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
    
entity data_generator is
generic
(
    g_data_width  : natural range 2 to 48
);
port
(
    clk_i           : in std_logic;
    rst_i           : in std_logic;
    data_init_i     : in std_logic_vector(g_data_width-1 downto 0);
    data_step_i     : in std_logic_vector(g_data_width-1 downto 0);
    niterations_i   : in std_logic_vector(9 downto 0);
    data_o          : out std_logic_vector(g_data_width-1 downto 0);
    trg_o           : out std_logic
);
end data_generator;

architecture rtl of data_generator is

    signal iterations_cnt      : unsigned(9 downto 0);
    signal data_cnt            : signed(g_data_width-1 downto 0);
    
begin
    p_counter: process(rst_i, clk_i)
    begin
        if rst_i = '1' then
            iterations_cnt <= unsigned(niterations_i);
            data_cnt <= signed(data_init_i);
        elsif rising_edge(clk_i) then
            if iterations_cnt = 0 then
                trg_o <= '1';
                data_cnt <= data_cnt + signed(data_step_i);
                iterations_cnt <= unsigned(niterations_i);
            else
                trg_o <= '0';
                iterations_cnt <= iterations_cnt - 1;
            end if;
        end if;
    end process;
    
    data_o <= std_logic_vector(data_cnt);
end rtl;