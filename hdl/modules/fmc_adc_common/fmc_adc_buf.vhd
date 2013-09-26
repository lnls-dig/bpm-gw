------------------------------------------------------------------------------
-- Title      : Wishbone FMC ADC buffers Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-17-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: ADC differential buffers for clock and data.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-03-12  1.0      lucas.russo        Created
-- 2013-19-08  1.1      lucas.russo        Refactored to enable use with other FMC ADC boards
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.fmc_adc_pkg.all;

entity fmc_adc_buf is
generic
(
  g_with_clk_single_ended                   : boolean := false;
  g_with_data_single_ended                  : boolean := false;
  g_with_data_sdr                           : boolean := false
);
port
(
  -----------------------------
  -- External ports
  -----------------------------

  -- ADC differential clocks. One clock per ADC channel
  adc_clk0_p_i                              : in std_logic := '0';
  adc_clk0_n_i                              : in std_logic := '0';
  adc_clk1_p_i                              : in std_logic := '0';
  adc_clk1_n_i                              : in std_logic := '0';
  adc_clk2_p_i                              : in std_logic := '0';
  adc_clk2_n_i                              : in std_logic := '0';
  adc_clk3_p_i                              : in std_logic := '0';
  adc_clk3_n_i                              : in std_logic := '0';

  -- ADC single ended clocks. One clock per ADC channel
  adc_clk0_i                                : in std_logic := '0';
  adc_clk1_i                                : in std_logic := '0';
  adc_clk2_i                                : in std_logic := '0';
  adc_clk3_i                                : in std_logic := '0';

  -- Differential ADC data channels.
  adc_data_ch0_p_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch0_n_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch1_p_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch1_n_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch2_p_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch2_n_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch3_p_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch3_n_i                          : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');

  -- Single ended ADC data channels.
  adc_data_ch0_i                            : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch1_i                            : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch2_i                            : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');
  adc_data_ch3_i                            : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0) := (others => '0');

  -- Output clocks
  adc_clk0_o                                : out std_logic;
  adc_clk1_o                                : out std_logic;
  adc_clk2_o                                : out std_logic;
  adc_clk3_o                                : out std_logic;

  -- Output data
  adc_data_ch0_o                            : out std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
  adc_data_ch1_o                            : out std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
  adc_data_ch2_o                            : out std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0);
  adc_data_ch3_o                            : out std_logic_vector(f_num_adc_pins(g_with_data_sdr) - 1 downto 0)
);
end fmc_adc_buf;

architecture rtl of fmc_adc_buf is

  -- Number of ADC input pins. This is differente for SDR or DDR ADCs.
  constant c_num_in_adc_pins                : natural := f_num_adc_pins(g_with_data_sdr);

  signal adc_clk0_p_t                       : std_logic;
  signal adc_clk0_n_t                       : std_logic;
  signal adc_clk1_p_t                       : std_logic;
  signal adc_clk1_n_t                       : std_logic;
  signal adc_clk2_p_t                       : std_logic;
  signal adc_clk2_n_t                       : std_logic;
  signal adc_clk3_p_t                       : std_logic;
  signal adc_clk3_n_t                       : std_logic;

  signal adc_data_ch0_p_t                   : std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);
  signal adc_data_ch0_n_t                   : std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);
  signal adc_data_ch1_p_t                   : std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);
  signal adc_data_ch1_n_t                   : std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);
  signal adc_data_ch2_p_t                   : std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);
  signal adc_data_ch2_n_t                   : std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);
  signal adc_data_ch3_p_t                   : std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);
  signal adc_data_ch3_n_t                   : std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);


begin

  -- Clock Input
  gen_with_input_clk_single_ended : if (g_with_clk_single_ended) generate

    adc_clk0_p_t                            <= adc_clk0_i;
    adc_clk1_p_t                            <= adc_clk1_i;
    adc_clk2_p_t                            <= adc_clk2_i;
    adc_clk3_p_t                            <= adc_clk3_i;

  end generate;

  gen_without_input_clk_single_ended : if (not g_with_clk_single_ended) generate

    adc_clk0_p_t                            <= adc_clk0_p_i;
    adc_clk0_n_t                            <= adc_clk0_n_i;
    adc_clk1_p_t                            <= adc_clk1_p_i;
    adc_clk1_n_t                            <= adc_clk1_n_i;
    adc_clk2_p_t                            <= adc_clk2_p_i;
    adc_clk2_n_t                            <= adc_clk2_n_i;
    adc_clk3_p_t                            <= adc_clk3_p_i;
    adc_clk3_n_t                            <= adc_clk3_n_i;

  end generate;

  -- Data Input
  gen_with_input_data_single_ended : if (g_with_data_single_ended) generate

    adc_data_ch0_p_t                        <= adc_data_ch0_i;
    adc_data_ch1_p_t                        <= adc_data_ch1_i;
    adc_data_ch2_p_t                        <= adc_data_ch2_i;
    adc_data_ch3_p_t                        <= adc_data_ch3_i;

  end generate;

  gen_without_input_data_single_ended : if (not g_with_data_single_ended) generate

    adc_data_ch0_p_t                        <= adc_data_ch0_p_i;
    adc_data_ch0_n_t                        <= adc_data_ch0_n_i;
    adc_data_ch1_p_t                        <= adc_data_ch1_p_i;
    adc_data_ch1_n_t                        <= adc_data_ch1_n_i;
    adc_data_ch2_p_t                        <= adc_data_ch2_p_i;
    adc_data_ch2_n_t                        <= adc_data_ch2_n_i;
    adc_data_ch3_p_t                        <= adc_data_ch3_p_i;
    adc_data_ch3_n_t                        <= adc_data_ch3_n_i;

  end generate;

  -----------------------------
  -- ADC clock signal datapath
  -----------------------------

  gen_with_clk_single_ended : if (g_with_clk_single_ended) generate

    cmp_ibuf_adc_clk0 : ibuf
    generic map(
      IOSTANDARD                              => "LVDS_25"
    )
    port map(
      i                                       => adc_clk0_p_t,
      o                                       => adc_clk0_o
    );

    cmp_ibuf_adc_clk1 : ibuf
    generic map(
      IOSTANDARD                              => "LVDS_25"
    )
    port map(
      i                                       => adc_clk1_p_t,
      o                                       => adc_clk1_o
    );

    cmp_ibuf_adc_clk2 : ibuf
    generic map(
      IOSTANDARD                              => "LVDS_25"
    )
    port map(
      i                                       => adc_clk2_p_t,
      o                                       => adc_clk2_o
    );

    cmp_ibuf_adc_clk3 : ibuf
    generic map(
      IOSTANDARD                              => "LVDS_25"
    )
    port map(
      i                                       => adc_clk3_p_t,
      o                                       => adc_clk3_o
    );

  end generate;

  -- An IBUGDS intructs the mapper to use the glabal clock nets
  --(GCLK pins). Therefore, it gives an error for the following
  -- clock topology components, like: BUFIO, BUFR and IODELAY
  gen_with_clk_diff : if (not g_with_clk_single_ended) generate

    cmp_ibufds_adc_clk0 : ibufds
    generic map(
      IOSTANDARD                              => "LVDS_25",
      DIFF_TERM                               => TRUE
    )
    port map(
      i                                       => adc_clk0_p_t,
      ib                                      => adc_clk0_n_t,
      o                                       => adc_clk0_o
    );

    cmp_ibufds_adc_clk1 : ibufds
    generic map(
      IOSTANDARD                              => "LVDS_25",
      DIFF_TERM                               => TRUE
    )
    port map(
      i                                       => adc_clk1_p_t,
      ib                                      => adc_clk1_n_t,
      o                                       => adc_clk1_o
    );

    cmp_ibufds_adc_clk2 : ibufds
    generic map(
      IOSTANDARD                              => "LVDS_25",
      DIFF_TERM                               => TRUE
    )
    port map(
      i                                       => adc_clk2_p_t,
      ib                                      => adc_clk2_n_t,
      o                                       => adc_clk2_o
    );

    cmp_ibufds_adc_clk3 : ibufds
    generic map(
      IOSTANDARD                              => "LVDS_25",
      DIFF_TERM                               => TRUE
    )
    port map(
      i                                       => adc_clk3_p_t,
      ib                                      => adc_clk3_n_t,
      o                                       => adc_clk3_o
    );

  end generate;

  -----------------------------
  -- ADC data signal datapath
  -----------------------------

  gen_with_data_single_ended : if (g_with_data_single_ended) generate

    gen_adc_data_buf : for i in 0 to c_num_in_adc_pins-1 generate

      cmp_ibuf_adc_data_ch0 : ibuf
      generic map(
        IOSTANDARD                            => "LVDS_25"
      )
      port map(
        i                                     => adc_data_ch0_p_t(i),
        o                                     => adc_data_ch0_o(i)
      );

      cmp_ibuf_adc_data_ch1 : ibuf
      generic map(
        IOSTANDARD                            => "LVDS_25"
      )
      port map(
        i                                     => adc_data_ch1_p_t(i),
        o                                     => adc_data_ch1_o(i)
      );

      cmp_ibuf_adc_data_ch2 : ibuf
      generic map(
        IOSTANDARD                            => "LVDS_25"
      )
      port map(
        i                                     => adc_data_ch2_p_t(i),
        o                                     => adc_data_ch2_o(i)
      );

      cmp_ibuf_adc_data_ch3 : ibuf
      generic map(
        IOSTANDARD                            => "LVDS_25"
      )
      port map(
        i                                     => adc_data_ch3_p_t(i),
        o                                     => adc_data_ch3_o(i)
      );

    end generate;

  end generate;

  gen_with_data_diff : if (not g_with_data_single_ended) generate

    gen_adc_data_buf : for i in 0 to c_num_in_adc_pins-1 generate

      cmp_ibufds_adc_data_ch0 : ibufds
      generic map(
        IOSTANDARD                            => "LVDS_25",
        DIFF_TERM                             => TRUE
      )
      port map(
        i                                     => adc_data_ch0_p_t(i),
        ib                                    => adc_data_ch0_n_t(i),
        o                                     => adc_data_ch0_o(i)
      );

      cmp_ibufds_adc_data_ch1 : ibufds
      generic map(
        IOSTANDARD                            => "LVDS_25",
        DIFF_TERM                             => TRUE
      )
      port map(
        i                                     => adc_data_ch1_p_t(i),
        ib                                    => adc_data_ch1_n_t(i),
        o                                     => adc_data_ch1_o(i)
      );

      cmp_ibufds_adc_data_ch2 : ibufds
      generic map(
        IOSTANDARD                            => "LVDS_25",
        DIFF_TERM                             => TRUE
      )
      port map(
        i                                     => adc_data_ch2_p_t(i),
        ib                                    => adc_data_ch2_n_t(i),
        o                                     => adc_data_ch2_o(i)
      );

      cmp_ibufds_adc_data_ch3 : ibufds
      generic map(
        IOSTANDARD                            => "LVDS_25",
        DIFF_TERM                             => TRUE
      )
      port map(
        i                                     => adc_data_ch3_p_t(i),
        ib                                    => adc_data_ch3_n_t(i),
        o                                     => adc_data_ch3_o(i)
      );

    end generate;

  end generate;

end rtl;
