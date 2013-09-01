library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.adc_pkg.all;


entity fmc150_adc_if is
generic (
    g_sim               : integer := 0
);
port
(
    --clk_200MHz_i        : in  std_logic;
    clk_100MHz_i        : in  std_logic;
    rst_i               : in  std_logic;
    cha_p_i             : in  std_logic_vector(6 downto 0);
    cha_n_i             : in  std_logic_vector(6 downto 0);
    chb_p_i             : in  std_logic_vector(6 downto 0);
    chb_n_i             : in  std_logic_vector(6 downto 0);
    str_p_i             : in  std_logic;
    str_n_i             : in  std_logic;
    cha_data_o          : out std_logic_vector(13 downto 0);
    chb_data_o          : out std_logic_vector(13 downto 0);
    clk_adc_i           : in  std_logic;
    str_o               : out std_logic;
    delay_update_i      : in  std_logic;
    str_cntvalue_i      : in  std_logic_vector(4 downto 0);
    cha_cntvalue_i      : in  std_logic_vector(4 downto 0);
    chb_cntvalue_i      : in  std_logic_vector(4 downto 0);
    str_cntvalue_o      : out std_logic_vector(4 downto 0)
);
end fmc150_adc_if;


architecture rtl of fmc150_adc_if is
    --------------------------------------------------------------------
    -- Signal declaration
    --------------------------------------------------------------------
    -- ADC data strobe
    signal s_adc_str_dly            : std_logic;
    signal s_adc_str                : std_logic;

    -- ADC data streams on Single Data Rate (SDR)
    signal s_adc_cha_sdr            : std_logic_vector(13 downto 0);
    signal s_adc_chb_sdr            : std_logic_vector(13 downto 0);
   
begin

    -- Synthesis Only!
    gen_adc_clk : if (g_sim = 0) generate
        -- ADC data strobe (channel A and B) with adjustable delay
        cmp_adc_str: strobe_lvds
        port map
        (
            clk_ctrl_i => clk_100MHz_i,
            strobe_p_i => str_p_i,
            strobe_n_i => str_n_i,
            strobe_o => s_adc_str_dly,
            ctrl_delay_update_i => delay_update_i,
            ctrl_delay_value_i => str_cntvalue_i,
            ctrl_delay_value_o => str_cntvalue_o
        );   
    end generate;
    
    -- Simulation Only!
    gen_adc_clk_sim : if (g_sim = 1) generate
        s_adc_str_dly <= str_p_i and str_n_i;
    end generate;
    
    -- s_adc_str_dly is a regional clock driven by BUFR.
    -- Must go through a BUFG before other components (BPM DDC)
    -- ADC strobe must be routed on a global net
    --cmp_adc_str_bufg: bufg
    --port map
    --(
    --    i => s_adc_str_dly,
    --    o => s_adc_str
    --);
    
    --str_o <= s_adc_str;
    str_o <= s_adc_str_dly;

    -- ADC channel A with adjustable delay
    cmp_adc_cha: adc_channel_lvds_ddr
    generic map
    (
        C_NBITS => 14,
        C_DEFAULT_DELAY => 15
    )
    port map
    (
        clk_adc_i => s_adc_str_dly,--clk_adc_i,
        clk_ctrl_i => clk_100MHz_i,
        adc_p_i => cha_p_i,
        adc_n_i => cha_n_i,
        adc_data_o => cha_data_o,
        ctrl_delay_update_i => delay_update_i,
        ctrl_delay_value_i => cha_cntvalue_i
    );

    -- ADC channel B with adjustable delay
    cmp_adc_chb: adc_channel_lvds_ddr
    generic map
    (
        C_NBITS => 14,
        C_DEFAULT_DELAY => 15
    )
    port map
    (
        clk_adc_i => s_adc_str_dly,--clk_adc_i,
        clk_ctrl_i => clk_100MHz_i,
        adc_p_i => chb_p_i,
        adc_n_i => chb_n_i,
        adc_data_o => chb_data_o,
        ctrl_delay_update_i => delay_update_i,
        ctrl_delay_value_i => chb_cntvalue_i
    );

end rtl;
