library ieee;
use ieee.std_logic_1164.all;

package adc_pkg is
    --------------------------------------------------------------------
    -- Components
    --------------------------------------------------------------------
    component strobe_lvds is
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
    end component;

    component adc_channel_lvds_ddr is
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
    end component;

end adc_pkg;