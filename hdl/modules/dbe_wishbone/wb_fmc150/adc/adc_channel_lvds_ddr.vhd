library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity adc_channel_lvds_ddr is
generic
(
    C_NBITS             : natural := 16;
    C_DEFAULT_DELAY     : natural := 0
);
port
(
    clk_adc_i           : in  std_logic;
    clk_ctrl_i          : in  std_logic;
    adc_p_i             : in  std_logic_vector(C_NBITS/2 - 1 downto 0);
    adc_n_i             : in  std_logic_vector(C_NBITS/2 - 1 downto 0);
    adc_data_o          : out std_logic_vector(C_NBITS - 1 downto 0);
    ctrl_delay_update_i : in  std_logic;
    ctrl_delay_value_i  : in  std_logic_vector(4 downto 0)
);

end adc_channel_lvds_ddr;

architecture rtl of adc_channel_lvds_ddr is

    signal s_adc_raw        : std_logic_vector(C_NBITS/2 - 1 downto 0);
    signal s_adc_ddr        : std_logic_vector(C_NBITS/2 - 1 downto 0);
    signal s_adc_ddr_dly    : std_logic_vector(C_NBITS/2 - 1 downto 0);
    
begin

    gen_adc_lvds_ddr : for i in 0 to (C_NBITS/2)-1 generate

        -- Differential input buffer with termination (LVDS)
        cmp_ibufds : ibufds
        generic map
        (
            IOSTANDARD => "LVDS_25",
            DIFF_TERM  => TRUE
        )
        port map
        (
            i  => adc_p_i(i),
            ib => adc_n_i(i),
            o  => s_adc_ddr(i)
        );
    
        -- Input delay
        cmp_iodelay : iodelaye1
        generic map
        (
            IDELAY_TYPE     => "VAR_LOADABLE",
            IDELAY_VALUE    => C_DEFAULT_DELAY,
            SIGNAL_PATTERN  => "DATA",
            DELAY_SRC       => "I"
        )
        port map
        (
            idatain     => s_adc_ddr(i),
            dataout     => s_adc_ddr_dly(i),
            c           => clk_ctrl_i,
            ce          => '0',
            inc         => '0',
            datain      => '0',
            odatain     => '0',
            clkin       => '0',
            rst         => ctrl_delay_update_i,
            cntvaluein  => ctrl_delay_value_i,
            cntvalueout => open,
            cinvctrl    => '0',
            t           => '1'
        );
    
        -- DDR to SDR
        cmp_iddr : iddr
        generic map
        (
            DDR_CLK_EDGE => "SAME_EDGE_PIPELINED"
        )
        port map
        (
            q1 => adc_data_o(2*i),
            q2 => adc_data_o(2*i+1),
            c  => clk_adc_i,
            ce => '1',
            d  => s_adc_ddr_dly(i),
            r  => '0',
            s  => '0'
        );
    
    end generate;
    
end rtl;