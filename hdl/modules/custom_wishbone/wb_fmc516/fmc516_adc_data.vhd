------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-29-10
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
  g_delay_type                              : string := "VARIABLE";
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
  adc_data_i                                : in std_logic_vector(c_num_adc_bits/2 - 1 downto 0);

  -----------------------------
  -- Input Clocks from fmc516_adc_clk signals
  -----------------------------
  adc_clk_bufio_i                           : in std_logic;
  adc_clk_bufr_i                            : in std_logic;
  adc_clk_bufg_i                            : in std_logic;
  adc_clk2x_bufg_i                          : in std_logic;
  --adc_clk_bufg_rst_n_i                      : in std_logic;

  -----------------------------
  -- ADC Data Delay signals
  -----------------------------
  -- idelay var_loadable interface
  adc_data_dly_val_i                        : in std_logic_vector(4 downto 0);
  adc_data_dly_val_o                        : out std_logic_vector(4 downto 0);

  -- idelay variable interface
  adc_data_dly_incdec_i                     : in std_logic;

  -- Pulse this to update the delay value or reset to its default (depending
  -- if idelay is in variable or var_loadable mode)
  adc_data_dly_pulse_i                      : in std_logic;

  -----------------------------
  -- ADC output signals
  -----------------------------
  adc_data_o                                : out std_logic_vector(c_num_adc_bits-1 downto 0);
  adc_data_valid_o                          : out std_logic;
  adc_clk_o                                 : out std_logic;
  adc_clk2x_o                               : out std_logic
);

end fmc516_adc_data;

architecture rtl of fmc516_adc_data is

  -- Small fifo depth. This FIFO is intended just to cross phase-mismatched
  -- clock domains (BUFR -> BUFG), but frequency locked
  constant async_fifo_size                  : natural := 16;

  -- ADC data signals
  signal adc_data_ddr_ibufds                : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  signal adc_data_ddr_dly                   : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  signal adc_data_sdr                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ff                        : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_bufg_sync                 : std_logic_vector(c_num_adc_bits-1 downto 0);

  -- FIFO signals
  signal adc_fifo_full                      : std_logic;
  signal adc_fifo_wr                        : std_logic;
  signal adc_fifo_rd                        : std_logic;
  signal adc_fifo_empty                     : std_logic;
  signal adc_fifo_valid                     : std_logic;

	-- Valid ADC signals
  signal adc_data_valid                     : std_logic;
  signal adc_data_valid_out                 : std_logic;

  -- Delay internal signals
  signal adc_data_dly_val_int               : std_logic_vector(5*(c_num_adc_bits/2)-1 downto 0);

  signal sys_rst                            : std_logic;

  --attribute IOB : string;
	--attribute IOB of adc_data_ff: signal is "TRUE";

  component cdc_fifo
  port (
    rst         : in std_logic;
    wr_clk      : in std_logic;
    rd_clk      : in std_logic;
    din         : in std_logic_vector(15 downto 0);
    wr_en       : in std_logic;
    rd_en       : in std_logic;
    dout        : out std_logic_vector(15 downto 0);
    full        : out std_logic;
    empty       : out std_logic;
    valid       : out std_logic
  );
  end component;
begin

  -----------------------------
  -- ADC data signal datapath
  -----------------------------

  gen_adc_data : for i in 0 to (c_num_adc_bits/2)-1 generate
    cmp_adc_data_iodelay : iodelaye1
    generic map(
      IDELAY_TYPE                           => g_delay_type,
      IDELAY_VALUE                          => g_default_adc_data_delay,
      SIGNAL_PATTERN                        => "DATA",
      HIGH_PERFORMANCE_MODE                 => TRUE,
      DELAY_SRC                             => "I"
    )
    port map(
      --idatain     	                        => adc_data_ddr_ibufds(i),
      idatain     	                        => adc_data_i(i),
      dataout     	                        => adc_data_ddr_dly(i),
      c           	                        => sys_clk_i,
      ce          	                        => adc_data_dly_pulse_i,
      inc         	                        => adc_data_dly_incdec_i,
      datain      	                        => '0',
      odatain     	                        => '0',
      clkin       	                        => '0',
      rst         	                        => adc_data_dly_pulse_i,
      cntvaluein  	                        => adc_data_dly_val_i,
      cntvalueout 	                        => adc_data_dly_val_int(5*(i+1)-1 downto 5*i),
      cinvctrl    	                        => '0',
      t           	                        => '1'
    );

    -- Output a single value to adc_data_dly_val_o
    adc_data_dly_val_o <= adc_data_dly_val_int(4 downto 0);

    -- DDR to SDR. This component is clocked with BUFIO clock for
    -- maximum performance
    cmp_iddr : iddr
    generic map(
      DDR_CLK_EDGE                          => "SAME_EDGE_PIPELINED"
    )
    port map(
      q1                                    => adc_data_sdr(2*i),
      q2                                    => adc_data_sdr(2*i+1),
      --c                                     => adc_clk_bufio_i,
      c                                     => adc_clk_bufr_i,
      ce                                    => '1',
      d                                     => adc_data_ddr_dly(i),
      r                                     => '0',
      s                                     => '0'
    );
  end generate;

  p_adc_data_ff : process(adc_clk_bufr_i, sys_rst_n_i)
  begin
    if sys_rst_n_i = '0' then
      adc_data_ff <= (others => '0');
    elsif rising_edge (adc_clk_bufr_i) then
      adc_data_ff <= adc_data_sdr;
    end if;
  end process;

  -- On the other hand, BUFG and BUFR/BUFIO are not guaranteed to be phase-matched,
  -- as they drive independently clock nets. Hence, a FIFO is needed to employ
  -- a clock domain crossing.
  gen_generic_bufr_bufg_fifo : if g_sim = 0 generate
    -- Xilinx coregen async 250 MHz fifo, 512 depth, 16-bit width,
    -- built-in fifo primitive, stardard fifo (no fall through)
    cmp_adc_data_async_fifo : cdc_fifo
    port map (
      rst                                   => sys_rst,

      -- write port
      wr_clk                                => adc_clk_bufr_i,
      din                                   => adc_data_ff,
      wr_en 		                            => adc_fifo_wr,
      full                                  => adc_fifo_full,

      -- read port
      rd_clk                                => adc_clk_bufg_i,
      dout                                  => adc_data_bufg_sync,
      rd_en                                 => adc_fifo_rd,
      valid                                 => adc_fifo_valid,
      empty                                 => adc_fifo_empty
    );

    adc_data_valid_out                      <= adc_fifo_valid;

    --cmp_adc_data_async_fifo	: generic_async_fifo
    --generic map(
    --  g_data_width                          => c_num_adc_bits,
    --  g_size                                => async_fifo_size
    --)
    --port map(
    --  rst_n_i                               => sys_rst_n_i,
    --
    --  -- write port
    --  clk_wr_i                              => adc_clk_bufr_i,
    --  d_i                                   => adc_data_ff,
    --  --d_i                                   => adc_data_ff0,
    --  we_i                                  => adc_fifo_wr,
    --  wr_full_o                             => adc_fifo_full,
    --
    --  -- read port
    --  clk_rd_i                              => adc_clk_bufg_i,
    --  q_o                                   => adc_data_bufg_sync,
    --  rd_i                                  => adc_fifo_rd,
    --  rd_empty_o                            => adc_fifo_empty
    --);

    -- Generate valid signal for adc_data_o.
    -- Just delay the valid adc_fifo_rd signal as the fifo takes
    -- one clock cycle, after it has registered adc_fifo_rd, to output
    -- data on q_o port
    --p_gen_valid : process (adc_clk_bufg_i, sys_rst_n_i)
    --begin
    --  if sys_rst_n_i = '0' then
    --    adc_data_valid <= '0';
    --    adc_data_valid_out <= '0';
    --  elsif rising_edge (adc_clk_bufg_i) then
    --    adc_data_valid <= adc_fifo_rd;
    --    adc_data_valid_out <= adc_data_valid;
    --  end if;
    --end process;
  end generate;

  -- Instanciate a inferred async fifo as the xilinx primitives
  -- are not cycle accurate in behavioural simulation (at least for ISim)
  gen_inferred_bufr_bufg_fifo : if g_sim = 1 generate
    cmp_inferred_async_fifo : inferred_async_fifo
    generic map (
      g_data_width                            => c_num_adc_bits,
      g_size                                  => async_fifo_size,
      g_almost_empty_threshold                => 3,
      g_almost_full_threshold                 => async_fifo_size-3
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

    -- Generate valid signal for adc_data_o.
    -- Just delay the valid adc_fifo_rd signal as the fifo takes
    -- one clock cycle, after it has registered adc_fifo_rd, to output
    -- data on q_o port
    p_gen_valid : process (adc_clk_bufg_i, sys_rst_n_i)
    begin
      if sys_rst_n_i = '0' then
        adc_data_valid <= '0';
        adc_data_valid_out <= '0';
      elsif rising_edge (adc_clk_bufg_i) then
        adc_data_valid <= adc_fifo_rd;
        adc_data_valid_out <= adc_data_valid;
      end if;
    end process;
  end generate;

  adc_fifo_wr <= not adc_fifo_full;
  adc_fifo_rd <= not adc_fifo_empty;

  -- Convenient signal for adc capture in later FPGA logic
  adc_clk_o                                 <= adc_clk_bufg_i;
  adc_clk2x_o                               <= adc_clk2x_bufg_i;
  adc_data_o                                <= adc_data_bufg_sync;
  --adc_data_o                                <= adc_data_ff3;
  adc_data_valid_o                          <= adc_data_valid_out;
  --adc_data_valid_o                          <= '1';

end rtl;
