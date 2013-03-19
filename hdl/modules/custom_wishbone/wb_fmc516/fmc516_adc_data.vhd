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
  sys_clk_200Mhz_i                          : in std_logic;
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
  adc_clk2x_o                               : out std_logic;

  fifo_debug_valid_o                        : out std_logic;
  fifo_debug_full_o                         : out std_logic;
  fifo_debug_empty_o                        : out std_logic
);

end fmc516_adc_data;

architecture rtl of fmc516_adc_data is

  subtype t_adc_data_delay is std_logic_vector(1 downto 0);
  type t_adc_data_delay_array is array (natural range<>) of t_adc_data_delay;

  -- Small fifo depth. This FIFO is intended just to cross phase-mismatched
  -- clock domains (BUFR -> BUFG), but frequency locked
  constant async_fifo_size                  : natural := 16;

  -- ADC data signals
  signal adc_data_ddr_ibufds                : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  signal adc_data_ddr_dly                   : std_logic_vector(c_num_adc_bits/2 - 1 downto 0);
  signal adc_data_sdr                       : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ff                        : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_ff_d1                     : std_logic_vector(c_num_adc_bits-1 downto 0);
  --signal adc_data_ff_d2                     : std_logic_vector(c_num_adc_bits-1 downto 0);
  signal adc_data_bufg_sync                 : std_logic_vector(c_num_adc_bits-1 downto 0);

  -- Delay signals
  signal adc_data_re                        : std_logic_vector(c_num_adc_bits-1 downto 0);  -- ADC data rising edge
  signal adc_data_fe                        : std_logic_vector(c_num_adc_bits-1 downto 0);  -- ADC data falling edge

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

  -- Built-in FIFO, 512-deep, 16-wide
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

  -- Distributed RAM FIFO, 16-deep, 16-wide
  component adc_data_cdc_fifo
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

  sys_rst <= not sys_rst_n_i;

  -----------------------------
  -- ADC data signal datapath
  -----------------------------

  gen_adc_data : for i in 0 to (c_num_adc_bits/2)-1 generate
    gen_adc_data_var_loadable_iodelay : if g_delay_type = "VAR_LOADABLE" generate

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
        --c                                     => sys_clk_200Mhz_i,
        --c                                     => sys_clk_i,
        c                                     => adc_clk_bufg_i,
        --ce                                    => adc_data_dly_pulse_i,
        ce                                    => '0',
        inc                                   => '0',
        datain                                => '0',
        odatain                               => '0',
        clkin                                 => '0',
        rst                                   => adc_data_dly_pulse_i,
        cntvaluein                            => adc_data_dly_val_i,
        cntvalueout                           => adc_data_dly_val_int(5*(i+1)-1 downto 5*i),
        cinvctrl                              => '0',
        t                                     => '1'
      );

    end generate;

    gen_adc_data_variable_iodelay : if g_delay_type = "VARIABLE" generate

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
        --c                                     => sys_clk_200Mhz_i,
        c                                     => sys_clk_i,
        --c                                     => adc_clk_bufg_i,
        ce                                    => adc_data_dly_pulse_i,
        inc                                   => adc_data_dly_incdec_i,
        datain                                => '0',
        odatain                               => '0',
        clkin                                 => '0',
        rst                                   => '0',
        cntvaluein                            => adc_data_dly_val_i,
        cntvalueout                           => adc_data_dly_val_int(5*(i+1)-1 downto 5*i),
        cinvctrl                              => '0',
        t                                     => '1'
      );

    end generate;

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
      q1                                    => adc_data_sdr(2*i+1),--adc_data_re(i),
      q2                                    => adc_data_sdr(2*i),--adc_data_fe(i),
      c                                     => adc_clk_bufio_i,
      --c                                     => adc_clk_bufr_i,
      ce                                    => '1',
      d                                     => adc_data_ddr_dly(i),
      r                                     => '0',
      s                                     => '0'
    );
  end generate;

  -- Output a single value to adc_data_dly_val_o
  adc_data_dly_val_o <= adc_data_dly_val_int(4 downto 0);

  -- Delay falling edge of IDDR by 1 or 2 cycles to match the transition bits
  gen_adc_data_dly_comp : for i in 0 to (c_num_adc_bits/2)-1 generate

    p_delay_fe_delay : process(adc_clk_bufr_i)
    begin
      if rising_edge (adc_clk_bufr_i) then
        if sys_rst_n_i = '0' then
          adc_data_fe_d1(i) <= '0';
          adc_data_fe_d2(i) <= '0';
        else
          adc_data_fe_d1(i) <= adc_data_fe(i);
          adc_data_fe_d2(i) <= adc_data_fe_d1(i);
        end if;
      end if;
    end process;

    -- adc bits delay software-controlled via adc_data_fe_d1_en and adc_data_fe_d2_en
    adc_data_d1(i)(1) <= adc_data_fe_d1(i) when adc_data_fe_d1_en_i = '1' else adc_data_re(i);
    adc_data_d1(i)(0) <= adc_data_re(i) when adc_data_fe_d1_en_i = '1' else adc_data_fe(i);

    adc_data_d2(i)(1) <= adc_data_fe_d2(i) when adc_data_fe_d2_en_i = '1' else adc_data_d1(i)(1);
    adc_data_d2(i)(0) <= adc_data_d1(i)(0);

    -- Grorup all the delayed bits.
    adc_data_sdr(2*i)  <= adc_data_d2(i)(0);
    adc_data_sdr(2*i+1)  <= adc_data_d2(i)(1);

  end generate;

  -- Some FF to solve timing problem
  p_adc_data_ff : process(adc_clk_bufr_i)
  begin
    if rising_edge (adc_clk_bufr_i) then
       if sys_rst_n_i = '0' then
         adc_data_ff <= (others => '0');
         adc_data_ff_d1 <= (others => '0');
         --adc_data_ff_d2 <= (others => '0');
       else
         adc_data_ff <= adc_data_sdr;
         adc_data_ff_d1 <= adc_data_ff;
         --adc_data_ff_d2 <= adc_data_ff_d1;
       end if;
    end if;
  end process;

  -- On the other hand, BUFG and BUFR/BUFIO are not guaranteed to be phase-matched,
  -- as they drive independently clock nets. Hence, a FIFO is needed to employ
  -- a clock domain crossing.
  gen_generic_bufr_bufg_fifo : if g_sim = 0 generate
    -- Xilinx coregen async 250 MHz fifo, 512 depth, 16-bit width,
    -- built-in fifo primitive, stardard fifo (no fall through)
    --cmp_adc_data_async_fifo : cdc_fifo
    --port map (
    --  rst                                   => sys_rst,
    --
    --  -- write port
    --  wr_clk                                => adc_clk_bufr_i,
    --  din                                   => adc_data_ff_d1,
    --  wr_en                                 => adc_fifo_wr,
    --  full                                  => adc_fifo_full,
    --
    --  -- read port
    --  rd_clk                                => adc_clk_bufg_i,
    --  dout                                  => adc_data_bufg_sync,
    --  rd_en                                 => adc_fifo_rd,
    --  valid                                 => adc_fifo_valid,
    --  empty                                 => adc_fifo_empty
    --);

    -- Xilinx coregen async 250 MHz fifo, 16 depth, 16-bit width,
    -- distributed ram primitive, stardard fifo (no fall through),
    -- cycle accurate simulation model
    --cmp_adc_data_async_fifo : adc_data_cdc_fifo
    --port map (
    --  rst                                   => sys_rst,
    --
    --  -- write port
    --  wr_clk                                => adc_clk_bufr_i,
    --  din                                   => adc_data_ff_d1,
    --  wr_en                                 => adc_fifo_wr,
    --  full                                  => adc_fifo_full,
    --
    --  -- read port
    --  rd_clk                                => adc_clk_bufg_i,
    --  dout                                  => adc_data_bufg_sync,
    --  rd_en                                 => adc_fifo_rd,
    --  valid                                 => adc_fifo_valid,
    --  empty                                 => adc_fifo_empty
    --);
    --
    --adc_data_valid_out                      <= adc_fifo_valid;

    cmp_adc_data_async_fifo : generic_async_fifo
    generic map(
      g_data_width                          => c_num_adc_bits,
      g_size                                => async_fifo_size
    )
    port map(
      rst_n_i                               => sys_rst_n_i,

      -- write port
      clk_wr_i                              => adc_clk_bufr_i,
      d_i                                   => adc_data_ff_d1,
      we_i                                  => adc_fifo_wr,
      wr_full_o                             => adc_fifo_full,

      -- read port
      clk_rd_i                              => adc_clk_bufg_i,
      q_o                                   => adc_data_bufg_sync,
      rd_i                                  => adc_fifo_rd,
      rd_empty_o                            => adc_fifo_empty
    );

  end generate;

  -- Instanciate a inferred async fifo as the xilinx primitives
  -- are not cycle accurate in behavioural simulation for ISim
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
      d_i                                     => adc_data_ff_d1,
      we_i                                    => adc_fifo_wr,
      wr_full_o                               => adc_fifo_full,

      -- read port
      clk_rd_i                                => adc_clk_bufg_i,
      q_o                                     => adc_data_bufg_sync,
      rd_i                                    => adc_fifo_rd,
      rd_empty_o                              => adc_fifo_empty
    );

  end generate;

  --Generate valid signal for adc_data_o.
  --Just delay the valid adc_fifo_rd signal as the fifo takes
  --one clock cycle, after it has registered adc_fifo_rd, to output
  --data on q_o port
  p_gen_valid : process (adc_clk_bufg_i)
  begin
    if rising_edge (adc_clk_bufg_i) then
      if sys_rst_n_i = '0' then
        adc_data_valid_out <= '0';
      else
        adc_data_valid_out <= adc_fifo_rd;
      end if;
    end if;
  end process;

  adc_fifo_wr                               <= not adc_fifo_full;
  adc_fifo_rd                               <= not adc_fifo_empty;

  -- Convenient signal for adc capture in later FPGA logic
  adc_clk_o                                 <= adc_clk_bufg_i;
  adc_clk2x_o                               <= adc_clk2x_bufg_i;
  adc_data_o                                <= adc_data_bufg_sync;
  adc_data_valid_o                          <= adc_data_valid_out;

  -- Debug
  fifo_debug_valid_o                        <= adc_data_valid_out;
  fifo_debug_full_o                         <= adc_fifo_full;
  fifo_debug_empty_o                        <= adc_fifo_empty;

end rtl;
