------------------------------------------------------------------------------
-- Title      : Wishbone FMC ADC data Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-29-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Data Interface with FMC ADC boards.
-------------------------------------------------------------------------------
-- Copyright (c) 2012 CNPEM
-- Licensed under GNU Lesser General Public License (LGPL) v3.0
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-- 2012-29-10  1.0      lucas.russo        Created
-- 2013-19-08  1.1      lucas.russo        Refactored to enable use with other FMC ADC boards
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

library work;
use work.genram_pkg.all;
use work.fmc_adc_pkg.all;

entity fmc_adc_data is
generic
(
  g_delay_type                              : string := "VARIABLE";
  g_default_adc_data_delay                  : natural := 0;
  g_with_data_sdr                           : boolean := false;
  g_with_fn_dly_select                      : boolean := false;
  g_sim                                     : integer := 0
);
port
(
  sys_clk_i                                 : in std_logic;
  sys_clk_200Mhz_i                          : in std_logic;
  sys_rst_n_i                               : in std_logic;

  -----------------------------
  -- External ports
  -----------------------------
  -- ADC data channel
  adc_data_i                                : in std_logic_vector(f_num_adc_pins(g_with_data_sdr)-1 downto 0);

  -----------------------------
  -- Input Clocks from fmc_adc_clk signals
  -----------------------------
  adc_clk_chain_priv_i                        : in t_adc_clk_chain_priv;
  adc_clk_chain_glob_i                        : in t_adc_clk_chain_glob;

  -----------------------------
  -- ADC Data Delay signals
  -----------------------------
  adc_data_fn_dly_i                         : in t_adc_data_fn_dly;
  adc_data_fn_dly_o                         : out t_adc_data_fn_dly;

  --adc_data_fe_d1_en_i                       : in std_logic;
  --adc_data_fe_d2_en_i                       : in std_logic;
  --
  --adc_data_rg_d1_en_i                       : in std_logic;
  --adc_data_rg_d2_en_i                       : in std_logic;
  adc_cs_dly_i                              : in t_adc_cs_dly;

  -----------------------------
  -- ADC output signals
  -----------------------------
  adc_out_o                                 : out t_adc_out;

  fifo_debug_valid_o                        : out std_logic;
  fifo_debug_full_o                         : out std_logic;
  fifo_debug_empty_o                        : out std_logic
);

end fmc_adc_data;

architecture rtl of fmc_adc_data is

  subtype t_adc_data_delay is std_logic_vector(1 downto 0);
  type t_adc_data_delay_array is array (natural range<>) of t_adc_data_delay;

  constant dummy_delay_array_low : t_adc_data_delay_array(c_num_adc_bits/2-1 downto 0) :=
                                              ("00", "00", "00", "00", "00",
                                               "00", "00", "00");

  -- Small fifo depth. This FIFO is intended just to cross phase-mismatched
  -- clock domains (BUFR -> BUFG), but frequency locked
  constant async_fifo_size                  : natural := 16;

  -- Number of ADC input pins. This is differente for SDR or DDR ADCs.
  constant c_num_in_adc_pins                : natural := f_num_adc_pins(g_with_data_sdr);

  -- Clock signals
  signal adc_clk_bufio                      : std_logic;
  signal adc_clk_bufr                       : std_logic;
  signal adc_clk_bufg                       : std_logic;
  signal adc_clk2x_bufg                     : std_logic;

  -- ADC data signals
  signal adc_data_ddr_ibufds                : std_logic_vector(c_num_in_adc_pins-1 downto 0);
  signal adc_data_ddr_dly                   : std_logic_vector(c_num_in_adc_pins-1 downto 0);
  signal adc_data_fe_sdr                    : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_sdr                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ff                        : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ff_d1                     : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ff_d2                     : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_bufg_sync                 : std_logic_vector(c_num_adc_bits-1 downto 0);

  --attribute IOB : string;
  --attribute IOB of adc_data_ff: signal is "TRUE";

  -- Fine delay signals
  signal iodelay_update                     : std_logic_vector(c_num_in_adc_pins-1 downto 0);

  -- Coarse Delay signals
  signal adc_data_re                        : std_logic_vector(c_num_adc_bits/2-1 downto 0)
                                                 := (others => '0');  -- ADC data rising edge
  signal adc_data_fe                        : std_logic_vector(c_num_adc_bits/2-1 downto 0)
                                                 := (others => '0');  -- ADC data falling edge
  signal adc_data_fe_d1                     : std_logic_vector(c_num_adc_bits/2-1 downto 0)
                                                 := (others => '0');  -- ADC data falling edge delayed1
  signal adc_data_fe_d2                     : std_logic_vector(c_num_adc_bits/2-1 downto 0)
                                                 := (others => '0');  -- ADC data falling edge delayed2
  signal adc_data_rg_d1                     : std_logic_vector(c_num_adc_bits-1 downto 0)
                                                 := (others => '0');  -- ADC data delayed1
  signal adc_data_rg_d2                     : std_logic_vector(c_num_adc_bits-1 downto 0)
                                                 := (others => '0');  -- ADC data delayed2

  -- Only used for DDR data channel
  signal adc_data_d1                        : t_adc_data_delay_array(c_num_adc_bits/2-1 downto 0)
                                                 := dummy_delay_array_low;  -- ADC data falling edge delayed1
  signal adc_data_d2                        : t_adc_data_delay_array(c_num_adc_bits/2-1 downto 0)
                                                := dummy_delay_array_low;  -- ADC data falling edge delayed2

  -- Used for both SDR and DDR data channel
  signal adc_data_d3                        : std_logic_vector(c_num_adc_bits-1 downto 0)
                                                := (others =>'0');  -- ADC data delayed1
  signal adc_data_d4                        : std_logic_vector(c_num_adc_bits-1 downto 0)
                                                := (others =>'0');  -- ADC data delayed1

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
  signal adc_data_dly_val_int               : std_logic_vector(5*c_num_in_adc_pins-1 downto 0);

  signal sys_rst                            : std_logic;

begin

  --sys_rst <= not sys_rst_n_i;
  adc_clk_bufio <= adc_clk_chain_priv_i.adc_clk_bufio;
  adc_clk_bufr  <= adc_clk_chain_priv_i.adc_clk_bufr;
  adc_clk_bufg  <= adc_clk_chain_glob_i.adc_clk_bufg;
  adc_clk2x_bufg  <= adc_clk_chain_glob_i.adc_clk2x_bufg;

  -----------------------------
  -- ADC data signal datapath
  -----------------------------

  --gen_adc_data : for i in 0 to (c_num_adc_bits/2)-1 generate
  gen_adc_data : for i in 0 to c_num_in_adc_pins-1 generate

    gen_adc_data_var_loadable_iodelay : if (g_delay_type = "VAR_LOADABLE") generate

      cmp_adc_data_iodelay : iodelaye1
      generic map(
        IDELAY_TYPE                           => g_delay_type,
        IDELAY_VALUE                          => g_default_adc_data_delay,
        SIGNAL_PATTERN                        => "DATA",
        HIGH_PERFORMANCE_MODE                 => TRUE,
        DELAY_SRC                             => "I"
      )
      port map(
        --idatain                                 => adc_data_ddr_ibufds(i),
        idatain                               => adc_data_i(i),
        dataout                               => adc_data_ddr_dly(i),
        c                                     => sys_clk_i,
        ce                                    => '0',
        inc                                   => '0',
        datain                                => '0',
        odatain                               => '0',
        clkin                                 => '0',
        rst                                   => iodelay_update(i),
        cntvaluein                            => adc_data_fn_dly_i.idelay.val,
        cntvalueout                           => adc_data_dly_val_int(5*(i+1)-1 downto 5*i),
        cinvctrl                              => '0',
        t                                     => '1'
      );

    end generate;

    gen_adc_data_variable_iodelay : if (g_delay_type = "VARIABLE") generate

      cmp_adc_data_iodelay : iodelaye1
      generic map(
        IDELAY_TYPE                           => g_delay_type,
        IDELAY_VALUE                          => g_default_adc_data_delay,
        SIGNAL_PATTERN                        => "DATA",
        HIGH_PERFORMANCE_MODE                 => TRUE,
        DELAY_SRC                             => "I"
      )
      port map(
        --idatain                                 => adc_data_ddr_ibufds(i),
        idatain                               => adc_data_i(i),
        dataout                               => adc_data_ddr_dly(i),
        c                                     => sys_clk_i,
        --ce                                    => adc_data_dly_pulse_i,
        ce                                    => iodelay_update(i),
        inc                                   => adc_data_fn_dly_i.idelay.incdec,
        datain                                => '0',
        odatain                               => '0',
        clkin                                 => '0',
        rst                                   => '0',
        cntvaluein                            => adc_data_fn_dly_i.idelay.val,
        cntvalueout                           => adc_data_dly_val_int(5*(i+1)-1 downto 5*i),
        cinvctrl                              => '0',
        t                                     => '1'
      );

    end generate;

    gen_with_fn_dly_select : if (g_with_fn_dly_select) generate
      iodelay_update(i) <= '1' when adc_data_fn_dly_i.idelay.pulse = '1' and
                                   adc_data_fn_dly_i.sel.which(i) = '1' else '0';
    end generate;

    gen_without_fn_dly_select : if (not g_with_fn_dly_select) generate
      iodelay_update(i) <= adc_data_fn_dly_i.idelay.pulse;
    end generate;

    -- Data come as SDR. Just passthrough the bits
    gen_with_sdr : if (g_with_data_sdr) generate

      adc_data_fe_sdr(i) <= adc_data_ddr_dly(i);

    end generate;

    gen_with_ddr : if (not g_with_data_sdr) generate
      -- DDR to SDR. This component is clocked with BUFIO clock for
      -- maximum performance.
      -- Note that the rising and falling edges are inverted to each other
      -- as the ISLA216 codes the data in following way:
      --
      -- ODD1a EVEN1a ODD2a EVEN2a ...
      --   ris  fal    ris   fal
      cmp_iddr : iddr
      generic map(
        DDR_CLK_EDGE                          => "SAME_EDGE_PIPELINED"
      )
      port map(
        q1                                    => adc_data_re(i),--adc_data_sdr(2*i+1),
        q2                                    => adc_data_fe(i),--adc_data_sdr(2*i),
        c                                     => adc_clk_bufio,
        --c                                     => adc_clk_bufr_i,
        ce                                    => '1',
        d                                     => adc_data_ddr_dly(i),
        r                                     => '0',
        s                                     => '0'
      );

      -- Delay falling edge of IDDR by 1 or 2 cycles to match the transition bits
      p_delay_fe_delay : process(adc_clk_bufr)
      begin
        if rising_edge (adc_clk_bufr) then
          --if sys_rst_n_i = '0' then
          --  adc_data_fe_d1(i) <= '0';
          --  adc_data_fe_d2(i) <= '0';
          --else
            adc_data_fe_d1(i) <= adc_data_fe(i);
            adc_data_fe_d2(i) <= adc_data_fe_d1(i);
          --end if;
        end if;
      end process;

      -- adc bits delay software-controlled via adc_data_fe_d1_en and adc_data_fe_d2_en
      adc_data_d1(i)(1) <= adc_data_fe_d1(i) when adc_cs_dly_i.adc_data_fe_d1_en = '1' else adc_data_re(i);
      adc_data_d1(i)(0) <= adc_data_re(i) when adc_cs_dly_i.adc_data_fe_d1_en = '1' else adc_data_fe(i);

      adc_data_d2(i)(1) <= adc_data_fe_d2(i) when adc_cs_dly_i.adc_data_fe_d2_en = '1' else adc_data_d1(i)(1);
      adc_data_d2(i)(0) <= adc_data_d1(i)(0);

      -- Grorup all the falling edge delayed bits.
      adc_data_fe_sdr(2*i)  <= adc_data_d2(i)(0);
      adc_data_fe_sdr(2*i+1)  <= adc_data_d2(i)(1);

    end generate;

  end generate;

  -- Output a single value to adc_data_dly_val_o
  adc_data_fn_dly_o.idelay.val <= adc_data_dly_val_int(4 downto 0);

  -- Delay the whole channel by 1 or 2 cycles
  p_delay_rg_delay : process(adc_clk_bufr)
  begin
    if rising_edge (adc_clk_bufr) then
      adc_data_rg_d1 <= adc_data_fe_sdr;
      adc_data_rg_d2 <= adc_data_rg_d1;
    end if;
  end process;

  -- adc data words delay software-controlled via adc_data_rg_d1_en and adc_data_rg_d2_en
  adc_data_d3 <= adc_data_rg_d1 when adc_cs_dly_i.adc_data_rg_d1_en = '1' else adc_data_fe_sdr;
  adc_data_d4 <= adc_data_rg_d2 when adc_cs_dly_i.adc_data_rg_d2_en = '1' else adc_data_d3;

  adc_data_sdr <= adc_data_d4;

  -- Some FF to solve timing problem
  p_adc_data_ff : process(adc_clk_bufr)
  begin
    if rising_edge (adc_clk_bufr) then
      adc_data_ff <= adc_data_sdr;
      adc_data_ff_d1 <= adc_data_ff;
      adc_data_ff_d2 <= adc_data_ff_d1;
    end if;
  end process;

  -- On the other hand, BUFG and BUFR/BUFIO are not guaranteed to be phase-matched,
  -- as they drive independently clock nets. Hence, a FIFO is needed to employ
  -- a clock domain crossing.
  cmp_adc_data_async_fifo : generic_async_fifo
  generic map(
    g_data_width                          => c_num_adc_bits,
    g_size                                => async_fifo_size
  )
  port map(
    --rst_n_i                               => sys_rst_n_i,
    -- We don't need this reset as this FIFO is used for CDC only
    rst_n_i                               => '1',

    -- write port
    clk_wr_i                              => adc_clk_bufr,
    d_i                                   => adc_data_ff_d2,
    --d_i                                   => adc_data_sdr,
    we_i                                  => adc_fifo_wr,
    wr_full_o                             => adc_fifo_full,

    -- read port
    clk_rd_i                              => adc_clk_bufg,
    q_o                                   => adc_data_bufg_sync,
    rd_i                                  => adc_fifo_rd,
    rd_empty_o                            => adc_fifo_empty
  );

  --Generate valid signal for adc_data_o.
  --Just delay the valid adc_fifo_rd signal as the fifo takes
  --one clock cycle, after it has registered adc_fifo_rd, to output
  --data on q_o port
  p_gen_valid : process (adc_clk_bufg)
  begin
    if rising_edge (adc_clk_bufg) then
      adc_data_valid_out <= adc_fifo_rd;

      if adc_fifo_empty = '1' then
        adc_data_valid_out <= '0';
      end if;
    end if;
  end process;

  adc_fifo_wr                               <= '1';
  adc_fifo_rd                               <= '1';

  -- Convenient signal for adc capture in later FPGA logic
  adc_out_o.adc_clk                         <= adc_clk_bufg;
  adc_out_o.adc_clk2x                       <= adc_clk2x_bufg;
  adc_out_o.adc_data                        <= adc_data_bufg_sync;
  adc_out_o.adc_data_valid                  <= adc_data_valid_out;

  -- Debug
  fifo_debug_valid_o                        <= adc_data_valid_out;
  fifo_debug_full_o                         <= adc_fifo_full;
  fifo_debug_empty_o                        <= adc_fifo_empty;

end rtl;
