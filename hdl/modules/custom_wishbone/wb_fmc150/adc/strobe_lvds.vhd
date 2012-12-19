-----------------------------------------------------------------------------------
-- <description>
--
-- Author: Daniel Tavares (daniel.tavares@lnls.br)
-- Company: Brazilian Synchrotron Light Laboratory, Campinas, Brazil
-----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity strobe_lvds is
generic
(
    C_DEFAULT_DELAY     : natural := 0
);
port
(
    clk_ctrl_i          : in  std_logic;
    strobe_p_i          : in  std_logic;
    strobe_n_i          : in  std_logic;
    strobe_o            : out std_logic;
    ctrl_delay_update_i : in  std_logic;
    ctrl_delay_value_i  : in  std_logic_vector(4 downto 0);
    ctrl_delay_value_o  : out std_logic_vector(4 downto 0)
);

end strobe_lvds;

architecture rtl of strobe_lvds is

    signal s_strobe_l : std_logic;
    signal s_strobe_dly : std_logic;
    
begin

    cmp_ibufgds : ibufds
    generic map
    (
        IOSTANDARD => "LVDS_25",
        DIFF_TERM  => TRUE
    )
    port map
    (
        i  => strobe_p_i,
        ib => strobe_n_i,
        o  => s_strobe_l
    );
    
    cmp_iodelay : iodelaye1
    generic map
    (
        IDELAY_TYPE     => "VAR_LOADABLE",
        IDELAY_VALUE    => C_DEFAULT_DELAY,
        SIGNAL_PATTERN  => "CLOCK",
        DELAY_SRC       => "I"
    )
    port map
    (
        idatain     => s_strobe_l,
        dataout     => s_strobe_dly,
        c           => clk_ctrl_i,
        ce          => '0',
        inc         => '0',
        datain      => '0',
        odatain     => '0',
        clkin       => '0',
        rst         => ctrl_delay_update_i,
        cntvaluein  => ctrl_delay_value_i,
        cntvalueout => ctrl_delay_value_o,
        cinvctrl    => '0',
        t           => '1'
    );
    
    cmp_bufr : bufr  
    generic map
    (
        SIM_DEVICE     => "VIRTEX6",
        BUFR_DIVIDE => "BYPASS"
    )
    port map 
    (
        clr      => '1',
        ce          => '1',
        i         => s_strobe_dly,
        o         => strobe_o
    );

end rtl;