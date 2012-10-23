------------------------------------------------------------------------------
-- Title      : Minicircuits Serial Controller
------------------------------------------------------------------------------
-- Author     : Daniel de Oliveira Tavares
-- Company    : CNPEM LNLS-DIG
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Automatic Control of Gain in Attenuators
-------------------------------------------------------------------------------
-- Notes: Times required by component
-- fclk = frequency of input clock / g_clkdiv
-- tclkH = floor(g_clkdiv/2) * period of input clock
-- tclkL = ceil(g_clkdiv/2) * period of input clock
-- tLESUP = ceil(g_clkdiv/2) * period of input clock
-- tLEPW = floor(g_clkdiv/2) * period of input clock
-- tSDSUP = floor(g_clkdiv/4) * period of input clock
-- tSDHLD = ceil(g_clkdiv/4) * period of input clock
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author                Description
-- 2012-01-12  1.0      daniel.tavares        Created
-- 2012-10-16  1.1      jose.berkenbrock      Names Adpated 
-------------------------------------------------------------------------------
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

use work.utilities_pkg.all;

entity mc_serial_ctrl is
generic
(
    g_nbits : natural := 6;
    g_clkdiv : natural := 128
);
port
(
    clk_i   : in  std_logic;
    trg_i   : in  std_logic;
    data_i  : in  std_logic_vector(g_nbits-1 downto 0);
    clk_o   : out std_logic;
    data_o  : out std_logic;
    le_o    : out std_logic;
    idle_o  : out std_logic
);
end mc_serial_ctrl;

architecture rtl of mc_serial_ctrl is
    signal idle           : std_logic;
    
    signal bit_cnt          : unsigned(log2(g_nbits+1)-1 downto 0);
    constant c_nbits        : unsigned(log2(g_nbits+1)-1 downto 0) := to_unsigned(g_nbits, log2(g_nbits+1));
    
    signal clk_cnt          : unsigned(log2(g_clkdiv)-1 downto 0);
    constant c_clkdiv       : unsigned(log2(g_clkdiv)-1 downto 0) := to_unsigned(g_clkdiv-1, log2(g_clkdiv));
    constant c_clkdiv_0     : unsigned(log2(g_clkdiv)-1 downto 0) := to_unsigned(0, log2(g_clkdiv));

begin
    p_outputs: process(clk_i)
    begin
        if rising_edge(clk_i) then
            if trg_i = '1' then
                idle <= '0';
                bit_cnt <= c_nbits;
                clk_cnt <= c_clkdiv_0;
                le_o <= '0';
                data_o <= '0';
                clk_o <= '0';
            
            elsif idle = '0' then
                if clk_cnt = 0 then
                    if bit_cnt /= 0 then
                        data_o <= data_i(to_integer(bit_cnt-1));
                    else
                        data_o <= '0';
                    end if;
                elsif clk_cnt = c_clkdiv/4 then
                    if bit_cnt = 0 then
                        le_o <= '1';
                    else
                        clk_o <= '1';
                    end if;
                elsif clk_cnt = (3*c_clkdiv)/4 then
                    if bit_cnt = 0 then
                        le_o <= '0';
                        idle <= '1';
                    else
                        clk_o <= '0';
                    end if;
                end if;
                
                if clk_cnt = c_clkdiv then
                    clk_cnt <= c_clkdiv_0;
                    bit_cnt <= bit_cnt - 1;
                else
                    clk_cnt <= clk_cnt + 1;
                end if;
            end if;
        end if;
    end process;
    
    idle_o <= idle;
    
end rtl;
