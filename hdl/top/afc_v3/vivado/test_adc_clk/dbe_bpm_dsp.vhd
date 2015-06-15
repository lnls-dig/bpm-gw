------------------------------------------------------------------------------
-- Title      : Top DSP design
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2013-09-01
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Top design for testing the integration/control of the DSP with
-- FMC130M_4ch board
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2013-09-01  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity dbe_bpm_dsp is
port(
  -----------------------------
  -- FMC1_130m_4ch ports
  -----------------------------

  -- ADC0 LTC2208
  fmc1_adc0_clk_i                            : in std_logic;

  -- FMC LEDs
  fmc1_led1_o                                : out std_logic;
  fmc1_led2_o                                : out std_logic;
  fmc1_led3_o                                : out std_logic;

  -----------------------------
  -- FMC2_130m_4ch ports
  -----------------------------

  -- ADC0 LTC2208
  fmc2_adc0_clk_i                            : in std_logic;

  -- FMC LEDs
  fmc2_led1_o                                : out std_logic;
  fmc2_led2_o                                : out std_logic;
  fmc2_led3_o                                : out std_logic
);
end dbe_bpm_dsp;

architecture rtl of dbe_bpm_dsp is

  constant c_max_count                        : natural := 113000000;

  signal fmc1_adc0_clk_buf                    : std_logic;
  signal fmc2_adc0_clk_buf                    : std_logic;
  signal fmc1_adc0_clk_bufg                   : std_logic;
  signal fmc2_adc0_clk_bufg                   : std_logic;

begin

cmp_ibuf_adc1_clk0 : ibuf
generic map(
  IOSTANDARD                              => "LVCMOS25"
)
port map(
  i                                       => fmc1_adc0_clk_i,
  o                                       => fmc1_adc0_clk_buf
);

cmp_bufg_adc1_clk0 : BUFG
port map(
  O                                       => fmc1_adc0_clk_bufg,
  I                                       => fmc1_adc0_clk_buf
);

cmp_ibuf_adc2_clk0 : ibuf
generic map(
  IOSTANDARD                              => "LVCMOS25"
)
port map(
  i                                       => fmc2_adc0_clk_i,
  o                                       => fmc2_adc0_clk_buf
);

cmp_bufg_adc2_clk0 : BUFG
port map(
  O                                       => fmc2_adc0_clk_bufg,
  I                                       => fmc2_adc0_clk_buf
);

p_counter1 : process(fmc1_adc0_clk_bufg)
   variable count : natural range 0 to c_max_count;
begin
    if rising_edge(fmc1_adc0_clk_bufg) then
        if count < c_max_count/2 then
            count := count + 1;
            fmc1_led1_o <= '1';
        elsif count < c_max_count then
            fmc1_led1_o <= '0';
            count := count + 1;
        else
            fmc1_led1_o <= '1';
            count := 0;
        end if;
    end if;
end process;

fmc1_led2_o <= '0';
fmc1_led3_o <= '0';

p_counter2 : process(fmc2_adc0_clk_bufg)
   variable count : natural range 0 to c_max_count;
begin
    if rising_edge(fmc2_adc0_clk_bufg) then
        if count < c_max_count/2 then
            count := count + 1;
            fmc2_led1_o <= '1';
        elsif count < c_max_count then
            fmc2_led1_o <= '0';
            count := count + 1;
        else
            fmc2_led1_o <= '1';
            count := 0;
        end if;
    end if;
end process;

fmc2_led2_o <= '0';
fmc2_led3_o <= '0';

end rtl;
