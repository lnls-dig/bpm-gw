------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-17-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: ADC differential buffers for clock and data
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-03-12  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.fmc516_pkg.all;

entity fmc516_adc_buf is
port
(
  -----------------------------
  -- External ports
  -----------------------------

  -- ADC clocks. One clock per ADC channel
  adc_clk0_p_i                              : in std_logic;
  adc_clk0_n_i                              : in std_logic;
  adc_clk1_p_i                              : in std_logic;
  adc_clk1_n_i                              : in std_logic;
  adc_clk2_p_i                              : in std_logic;
  adc_clk2_n_i                              : in std_logic;
  adc_clk3_p_i                              : in std_logic;
  adc_clk3_n_i                              : in std_logic;

  -- DDR ADC data channels.
  adc_data_ch0_p_i                          : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch0_n_i                          : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch1_p_i                          : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch1_n_i                          : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch2_p_i                          : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch2_n_i                          : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch3_p_i                          : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch3_n_i                          : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);

  adc_clk0_o                                : out std_logic;
  adc_clk1_o                                : out std_logic;
  adc_clk2_o                                : out std_logic;
  adc_clk3_o                                : out std_logic;

  adc_data_ch0_o                            : out std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch1_o                            : out std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch2_o                            : out std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_ch3_o                            : out std_logic_vector(c_num_adc_bits/2 - 1 downto 0)
);

end fmc516_adc_buf;

architecture rtl of fmc516_adc_buf is

begin

  -----------------------------
  -- ADC clock signal datapath
  -----------------------------
  --cmp_ibufgds_adc_clk0 : ibufgds
  -- An IBUGDS intructs the mapper to use the glabal clock nets
  --(GCLK pins). Therefore, it gives an error for the following
  -- clock topology components, like: BUFIO, BUFR and IODELAY
  cmp_ibufds_adc_clk0 : ibufds
  generic map(
    IOSTANDARD                              => "LVDS_25",
    DIFF_TERM                               => TRUE
  )
  port map(
    i                                       => adc_clk0_p_i,
    ib                                      => adc_clk0_n_i,
    o                                       => adc_clk0_o
  );

  cmp_ibufds_adc_clk1 : ibufds
  generic map(
    IOSTANDARD                              => "LVDS_25",
    DIFF_TERM                               => TRUE
  )
  port map(
    i                                       => adc_clk1_p_i,
    ib                                      => adc_clk1_n_i,
    o                                       => adc_clk1_o
  );

  cmp_ibufds_adc_clk2 : ibufds
  generic map(
    IOSTANDARD                              => "LVDS_25",
    DIFF_TERM                               => TRUE
  )
  port map(
    i                                       => adc_clk2_p_i,
    ib                                      => adc_clk2_n_i,
    o                                       => adc_clk2_o
  );

  cmp_ibufds_adc_clk3 : ibufds
  generic map(
    IOSTANDARD                              => "LVDS_25",
    DIFF_TERM                               => TRUE
  )
  port map(
    i                                       => adc_clk3_p_i,
    ib                                      => adc_clk3_n_i,
    o                                       => adc_clk3_o
  );

  -----------------------------
  -- ADC data signal datapath
  -----------------------------
  gen_adc_data_buf_ch0 : for i in 0 to (c_num_adc_bits/2)-1 generate
    -- Diferential Clock Buffers for adc input
    cmp_ibufds_adc_data_ch0 : ibufds
    generic map(
      IOSTANDARD                            => "LVDS_25",
      DIFF_TERM                             => TRUE
    )
    port map(
      i	                                    => adc_data_ch0_p_i(i),
      ib                                    => adc_data_ch0_n_i(i),
      o	                                    => adc_data_ch0_o(i)
    );

    cmp_ibufds_adc_data_ch1 : ibufds
    generic map(
      IOSTANDARD                            => "LVDS_25",
      DIFF_TERM                             => TRUE
    )
    port map(
      i	                                    => adc_data_ch1_p_i(i),
      ib                                    => adc_data_ch1_n_i(i),
      o	                                    => adc_data_ch1_o(i)
    );

    cmp_ibufds_adc_data_ch2 : ibufds
    generic map(
      IOSTANDARD                            => "LVDS_25",
      DIFF_TERM                             => TRUE
    )
    port map(
      i	                                    => adc_data_ch2_p_i(i),
      ib                                    => adc_data_ch2_n_i(i),
      o	                                    => adc_data_ch2_o(i)
    );

    cmp_ibufds_adc_data_ch3 : ibufds
    generic map(
      IOSTANDARD                            => "LVDS_25",
      DIFF_TERM                             => TRUE
    )
    port map(
      i	                                    => adc_data_ch3_p_i(i),
      ib                                    => adc_data_ch3_n_i(i),
      o	                                    => adc_data_ch3_o(i)
    );

  end generate;

end rtl;
