------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-17-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Data Interface with FMC516 ADC board from Curtis Wright.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-29-10  1.0      lucas.russo        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.genram_pkg.all;
use work.fmc516_pkg.all;

entity fmc516_adc_data is
generic
(
  g_default_adc_data_delay                  : natural := 0;
  g_sim                                     : integer := 0
);
port
(
  sys_clk_i                                 : in std_logic;
  sys_rst_n_i                               : in std_logic;

  -----------------------------
  -- External ports
  -----------------------------

  -- DDR ADC data channels.
  adc_data_p_i                              : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  adc_data_n_i                              : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);

  -----------------------------
  -- Input Clocks from fmc516_adc_clk signals
  -----------------------------
  adc_clk_bufio_i                           : in std_logic;
  adc_clk_bufr_i                            : in std_logic;
  adc_clk_bufg_i                            : in std_logic;
  adc_clk_bufg_rst_n_i                      : in std_logic;

  -----------------------------
  -- ADC Data Delay signals
  -----------------------------
  -- Pulse this to update the delay value
  adc_data_dly_pulse_i                      : in std_logic;
  adc_data_dly_val_i                        : in std_logic_vector(4 downto 0);
  adc_data_dly_val_o                        : out std_logic_vector(4 downto 0);

  -----------------------------
  -- ADC output signals
  -----------------------------
  adc_data_o                                : out std_logic_vector(c_num_adc_bits-1 downto 0);
  adc_data_valid_o                          : out std_logic;
  adc_clk_o                                 : out std_logic
);

end fmc516_adc_data;

architecture rtl of fmc516_adc_data is

  -- Small fifo depth. This FIFO is intended just to cross phase-mismatched
  -- clock domains (BUFR -> BUFG), but frequency locked
  constant async_fifo_size                  : natural := 32;

  -- ADC data signals
  signal adc_data_ddr_ibufds                : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  signal adc_data_ddr_dly                   : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  signal adc_data_sdr                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  -- (* IOB = TRUE *)
  --attribute IOB : string
	--attribute IOB of adc_data_ff: signal is "TRUE";
  signal adc_data_ff                        : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_bufg_sync                 : std_logic_vector(c_num_adc_bits-1 downto 0);

  -- FIFO signals
  signal adc_fifo_full                      : std_logic;
  signal adc_fifo_wr                        : std_logic;
  signal adc_fifo_rd                        : std_logic;
  signal adc_fifo_empty                     : std_logic;

	-- Valid ADC signals
  signal adc_data_valid                     : std_logic;
  signal adc_data_valid_d1                  : std_logic;
begin

  -----------------------------
  -- ADC data signal datapath
  -----------------------------

  gen_adc_data : for i in 0 to (c_num_adc_bits/2)-1 generate
    -- Diferential Clock Buffers for adc input
    cmp_ibufds_adc_data : ibufds
    generic map(
      IOSTANDARD                            => "LVDS_25",
      DIFF_TERM                             => TRUE
    )
    port map(
      i	                                    => adc_data_p_i(i),
      ib                                    => adc_data_n_i(i),
      o	                                    => adc_data_ddr_ibufds(i)
    );

    cmp_iodelay_adc_data : iodelaye1
    generic map(
      IDELAY_TYPE                           => "VAR_LOADABLE",
      IDELAY_VALUE                          => g_default_adc_data_delay,
      SIGNAL_PATTERN                        => "DATA",
      DELAY_SRC                             => "I"
    )
    port map(
      idatain     	                        => adc_data_ddr_ibufds(i),
      dataout     	                        => adc_data_ddr_dly(i),
      c           	                        => sys_clk_i,
      ce          	                        => '0',
      inc         	                        => '0',
      datain      	                        => '0',
      odatain     	                        => '0',
      clkin       	                        => '0',
      rst         	                        => adc_data_dly_pulse_i,
      cntvaluein  	                        => adc_data_dly_val_i,
      cntvalueout 	                        => adc_data_dly_val_o,
      cinvctrl    	                        => '0',
      t           	                        => '1'
    );

    -- DDR to SDR. This component is clocked with BUFIO clock for
    -- maximum performance
    cmp_iddr : iddr
    generic map(
      DDR_CLK_EDGE                          => "SAME_EDGE_PIPELINED"
    )
    port map(
      q1                                    => adc_data_sdr(2*i),
      q2                                    => adc_data_sdr(2*i+1),
      c                                     => adc_clk_bufio_i,
      ce                                    => '1',
      d                                     => adc_data_ddr_dly(i),
      r                                     => '0',
      s                                     => '0'
    );
  end generate;

  -- Data acquisition FF. Should we let the synthesis tool decide if it should
  -- be placed inside IOB or force them?
  -- In Virtex-6 BUFIO and BUFR are guaranteed to by phase-matched as they are
  -- parallel to each other. So, no need for CDC techniques here.
  p_adc_data_ff : process(adc_clk_bufr_i)
  begin
    if (rising_edge (adc_clk_bufr_i)) then
      adc_data_ff <= adc_data_sdr;
    end if;
  end process;

  -- On the other hand, BUFG and BUFR/BUFIO are not guaranteed to be phase-matched,
  -- as they drive independently clock nets. Hence, a FIFO is needed to employ
  -- a clock domain crossing.
  cmp_adc_data_async_fifo	: generic_async_fifo
  generic map(
    g_data_width                            => c_num_adc_bits,
    g_size                                  => async_fifo_size
	)
  port map(
    rst_n_i                                 => sys_rst_n_i,

    -- write port
    clk_wr_i                                => adc_clk_bufr_i,
    d_i                                     => adc_data_ff,
    we_i                                    => adc_fifo_wr,
    wr_full_o                               => adc_fifo_full,

    -- read port
    clk_rd_i                                => adc_clk_bufg_i,
    q_o                                     => adc_data_bufg_sync,
    rd_i                                    => adc_fifo_rd,
    rd_empty_o                              => adc_fifo_empty
	);

  adc_fifo_wr <= not adc_fifo_full;
  adc_fifo_rd <= not adc_fifo_empty;

  -- Generate valid signal for adc_data_o.
  -- Just delay the valid adc_fifo_rd signal as the fifo takes
  -- one clock cycle, after it has registered adc_fifo_rd, to output
  -- data on q_o port
  p_gen_valid : process (adc_clk_bufg_i, adc_clk_bufg_rst_n_i)
  begin
    if adc_clk_bufg_rst_n_i = '0' then
      adc_data_valid <= '0';
      adc_data_valid_d1 <= '0';
    elsif rising_edge (adc_clk_bufg_i) then
      adc_data_valid <= adc_fifo_rd;
      adc_data_valid_d1 <= adc_data_valid;
    end if;
  end process;

  -- Convenient signal for adc capture in later FPGA logic
  adc_clk_o                                 <= adc_clk_bufg_i;
  adc_data_o                                <= adc_data_bufg_sync;
  adc_data_valid_o                          <= adc_data_valid_d1;

end rtl;
