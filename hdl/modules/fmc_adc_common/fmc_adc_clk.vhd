------------------------------------------------------------------------------
-- Title      : Wishbone FMC ADC clock Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-29-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Clock Interface with FMC ADC boards.
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
use work.fmc_adc_pkg.all;

entity fmc_adc_clk is
generic
(
    -- The only supported values are VIRTEX6 and 7SERIES
  g_fpga_device                             : string := "VIRTEX6";
  g_delay_type                              : string := "VARIABLE";
  g_adc_clock_period                        : real;
  g_default_adc_clk_delay                   : natural := 0;
  g_with_ref_clk                            : boolean := false;
  g_mmcm_param                              : t_mmcm_param := default_mmcm_param;
  g_with_fn_dly_select                      : boolean := false;
  g_mrcc_pin                                : boolean := false;
  g_with_bufio                              : boolean := true;
  g_with_bufr                               : boolean := true;
  g_sim                                     : integer := 0
);
port
(
  sys_clk_i                                 : in std_logic;
  sys_clk_200Mhz_i                          : in std_logic;
  sys_rst_i                                 : in std_logic;

  -----------------------------
  -- External ports
  -----------------------------

  -- ADC clocks. One clock per ADC channel
  adc_clk_i                                 : in std_logic;

  -----------------------------
  -- ADC Delay signals.
  -----------------------------
  -- ADC fine delay control
  adc_clk_fn_dly_i                          : in t_adc_clk_fn_dly;
  adc_clk_fn_dly_o                          : out t_adc_clk_fn_dly;

  -----------------------------
  -- ADC output signals.
  -----------------------------
  adc_clk_chain_priv_o                        : out t_adc_clk_chain_priv;
  adc_clk_chain_glob_o                        : out t_adc_clk_chain_glob

  -----------------------------
  -- MMCM general signals
  -----------------------------
  --mmcm_adc_locked_o                         : out std_logic
);

end fmc_adc_clk;

architecture rtl of fmc_adc_clk is

  alias c_mmcm_param is g_mmcm_param;

  -- Clock and reset signals
  signal adc_clk_ibufgds                    : std_logic;
  signal adc_clk_ibufgds_dly                : std_logic;

  -- Clock BUFMR signals
  signal adc_clk_bufmr                      : std_logic;

  -- Clock BUFIO/BUFR input signals
  signal adc_clk_bufio_in                   : std_logic;
  signal adc_clk_bufr_in                    : std_logic;
  signal adc_clk_mmcm_in                    : std_logic;

  -- Clock internal signals interconnect
  signal adc_clk_bufio                      : std_logic;
  signal adc_clk_bufr                       : std_logic;
  signal adc_clk_bufg                       : std_logic;
  signal adc_clk2x_bufg                     : std_logic;

  -- Clock MMCM signals
  signal adc_clk_fbin                       : std_logic;
  signal adc_clk_fbout                      : std_logic;
  signal adc_clk_mmcm_out                   : std_logic;
  signal adc_clk2x_mmcm_out                 : std_logic;
  signal mmcm_adc_locked_int                : std_logic;

  -- Clock delay signals
  signal iodelay_update                     : std_logic;
  --signal adc_clk_dly_val_int                : std_logic_vector(4 downto 0);

begin

  -- Check for unsupported generic configs
  -- Supported options
  --BUFIO yes / BUFR no (unsupported)
  --BUFIO no / BUFR yes (OK)
  --BUFIO yes / BUFR yes (OK)
  --BUFIO no / BUFR no (OK)

  assert not (g_with_bufio and not g_with_bufr) report
    "If BUFIO is used, then BUFR must also be!" severity failure;

  -----------------------------
  -- Clock signal datapath
  -----------------------------

  -- Delay for Clock Buffers
  -- From Virtex-6 SelectIO Datasheet:
  -- Sets the type of tap delay line. DEFAULT delay guarantees zero hold times.
  -- FIXED delay sets a static delay value. VAR_LOADABLE dynamically loads tap
  -- values. VARIABLE delay dynamically adjusts the delay value.
  --
  -- HIGH_PERFORMANCE_MODE = TRUE reduces the output
  -- jitter in exchange of increase power dissipation
  gen_adc_clk_virtex6_iodelay : if (g_fpga_device = "VIRTEX6") generate
    gen_adc_clk_var_loadable_iodelay : if (g_delay_type = "VAR_LOADABLE") generate

      cmp_ibufds_clk_iodelay : iodelaye1
      generic map(
        IDELAY_TYPE                             => g_delay_type,
        IDELAY_VALUE                            => g_default_adc_clk_delay,
        SIGNAL_PATTERN                          => "CLOCK",
        HIGH_PERFORMANCE_MODE                   => TRUE,
        DELAY_SRC                               => "I"
      )
      port map(
        idatain                                 => adc_clk_i,
        dataout                                 => adc_clk_ibufgds_dly,
        c                                       => sys_clk_i,
        ce                                      => '0',
        --inc                                     => adc_clk_dly_incdec_i,
        inc                                     => '0',
        datain                                  => '0',
        odatain                                 => '0',
        clkin                                   => '0',
        --rst                                     => adc_clk_dly_pulse_i,
        rst                                     => iodelay_update,
        cntvaluein                              => adc_clk_fn_dly_i.idelay.val,
        cntvalueout                             => adc_clk_fn_dly_o.idelay.val,
        cinvctrl                                => '0',
        t                                       => '1'
      );
    end generate;

    gen_adc_clk_variable_iodelay : if (g_delay_type = "VARIABLE") generate
      cmp_ibufds_clk_iodelay : iodelaye1
      generic map(
        IDELAY_TYPE                             => g_delay_type,
        IDELAY_VALUE                            => g_default_adc_clk_delay,
        SIGNAL_PATTERN                          => "CLOCK",
        HIGH_PERFORMANCE_MODE                   => TRUE,
        DELAY_SRC                               => "I"
      )
      port map(
        idatain                                 => adc_clk_i,
        dataout                                 => adc_clk_ibufgds_dly,
        c                                       => sys_clk_i,
        --ce                                      => adc_clk_dly_pulse_i,
        ce                                      => iodelay_update,
        inc                                     => adc_clk_fn_dly_i.idelay.incdec,
        datain                                  => '0',
        odatain                                 => '0',
        clkin                                   => '0',
        rst                                     => '0',
        cntvaluein                              => adc_clk_fn_dly_i.idelay.val,
        cntvalueout                             => adc_clk_fn_dly_o.idelay.val,
        cinvctrl                                => '0',
        t                                       => '1'
      );
    end generate;

  end generate;

  gen_adc_clk_7series_iodelay : if (g_fpga_device = "7SERIES") generate
    gen_adc_clk_var_load_iodelay : if (g_delay_type = "VAR_LOAD") generate

      cmp_ibufds_clk_iodelay : idelaye2
      generic map (
         CINVCTRL_SEL                        => "FALSE",
         DELAY_SRC                           => "IDATAIN",
         HIGH_PERFORMANCE_MODE               => "TRUE",
         IDELAY_TYPE                         => g_delay_type,
         IDELAY_VALUE                        => g_default_adc_clk_delay,
         PIPE_SEL                            => "FALSE",
         REFCLK_FREQUENCY                    => 200.0,
         SIGNAL_PATTERN                      => "CLOCK"
      )
      port map (
         cntvalueout                         => adc_clk_fn_dly_o.idelay.val,
         dataout                             => adc_clk_ibufgds_dly,
         c                                   => sys_clk_i,
         ce                                  => '1',
         cinvctrl                            => '0',
         cntvaluein                          => adc_clk_fn_dly_i.idelay.val,
         datain                              => '0',
         idatain                             => adc_clk_i,
         inc                                 => '0',
         ld                                  => iodelay_update,
         ldpipeen                            => '0',
         regrst                              => sys_rst_i
      );

    end generate;

    gen_adc_clk_variable_iodelay : if (g_delay_type = "VARIABLE") generate

      cmp_ibufds_clk_iodelay : idelaye2
      generic map (
         CINVCTRL_SEL                        => "FALSE",
         DELAY_SRC                           => "IDATAIN",
         HIGH_PERFORMANCE_MODE               => "TRUE",
         IDELAY_TYPE                         => g_delay_type,
         IDELAY_VALUE                        => g_default_adc_clk_delay,
         PIPE_SEL                            => "FALSE",
         REFCLK_FREQUENCY                    => 200.0,
         SIGNAL_PATTERN                      => "CLOCK"
      )
      port map (
         cntvalueout                         => adc_clk_fn_dly_o.idelay.val,
         dataout                             => adc_clk_ibufgds_dly,
         c                                   => sys_clk_i,
         ce                                  => iodelay_update,
         cinvctrl                            => '0',
         cntvaluein                          => adc_clk_fn_dly_i.idelay.val,
         datain                              => '0',
         idatain                             => adc_clk_i,
         inc                                 => adc_clk_fn_dly_i.idelay.incdec,
         ld                                  => '0',
         ldpipeen                            => '0',
         regrst                              => sys_rst_i
      );

    end generate;
  end generate;

  gen_with_fn_dly_select : if (g_with_fn_dly_select) generate
    iodelay_update <= '1' when adc_clk_fn_dly_i.idelay.pulse = '1' and
                               adc_clk_fn_dly_i.sel.which = '1' else '0';
  end generate;

  gen_without_fn_dly_select : if (not g_with_fn_dly_select) generate
    iodelay_update <= adc_clk_fn_dly_i.idelay.pulse;
  end generate;

  -- Generate BUFMR and connect directly to BUFIO/BUFR
  --
  -- In Xilinx 7-Series devices, BUFIO/BUFR only drives a single clock region.
  -- If BUFIO/BUFR must drive multi clock-regions (up to 3: actual, above and
  -- below), we must instanciate a multi-clock buffer (BUFMR) and then drive
  -- the BUFIO/BUFR as needed.
  gen_bufmr : if (g_fpga_device = "7SERIES") generate

     -- We either have BUFIO + BUFR or just BUFR. We only
     -- have to check for BUFR, then.
    gen_bufmr_7_series : if (g_mrcc_pin) generate

      -- 1-bit output: Clock output (connect to BUFIOs/BUFRs)
      -- 1-bit input: Clock input (Connect to IBUFG)
      cmp_bufmr : bufmr
      port map (
        O                                     => adc_clk_bufmr,
        I                                     => adc_clk_ibufgds_dly
      );

      adc_clk_bufio_in                        <= adc_clk_bufmr;
      adc_clk_bufr_in                         <= adc_clk_bufmr;

    end generate;

    gen_not_bufmr_7_series : if (not g_mrcc_pin) generate

      adc_clk_bufio_in                        <= adc_clk_ibufgds_dly;
      adc_clk_bufr_in                         <= adc_clk_ibufgds_dly;

    end generate;

  end generate;

  -- Do not generate BUFMR and connect the input clock directly to BUFIO/BUFR
  gen_not_bufmr : if (g_fpga_device = "VIRTEX6") generate

    adc_clk_bufio_in                        <= adc_clk_ibufgds_dly;
    adc_clk_bufr_in                         <= adc_clk_ibufgds_dly;
  end generate;

  -- BUFIO (better switching characteristics than BUFR and BUFG).
  -- It can be used just inside ILOGIC blocks resources, such as
  -- an IDDR block.
  gen_with_bufio : if (g_with_bufio) generate

    cmp_adc_clk_bufio : bufio
    port map (
      O                                       => adc_clk_bufio,
      I                                       => adc_clk_bufio_in
    );

  end generate;

  -- BUFR (better switching characteristics than BUFG).
  -- It can drive logic elements (block ram, CLB, DSP tiles,
  -- etc) up to 6 clock regions.
  gen_with_bufr : if (g_with_bufr) generate

    cmp_adc_clk_bufr : bufr
    generic map(
      SIM_DEVICE                              => g_fpga_device,
      BUFR_DIVIDE                             => "BYPASS"
    )
    port map (
      CLR                                     => '0',
      CE                                      => '1',
      I                                       => adc_clk_bufr_in,
      O                                       => adc_clk_bufr
    );

  end generate;

  -- MMCM input clock
  gen_mmcm_clk_fallback_in : if (not g_with_bufr and not g_with_bufio) generate

    adc_clk_mmcm_in <= adc_clk_ibufgds_dly;

  end generate;

  gen_mmcm_clk_in : if (g_with_bufr) generate

    adc_clk_mmcm_in <= adc_clk_bufr;

  end generate;

  gen_with_ref_clk : if (g_with_ref_clk) generate
    -- ADC Clock PLL
    cmp_mmcm_adc_clk : MMCM_ADV
    generic map(
      BANDWIDTH                             => "OPTIMIZED",
      CLKOUT4_CASCADE                       => FALSE,
      CLOCK_HOLD                            => FALSE,
      -- Let the synthesis tools select the best appropriate
      -- compensation method (as dictated in Virtex-6 clocking
      -- resourses guide page 53, note 2)
      --COMPENSATION                          => "ZHOLD",
      STARTUP_WAIT                          => FALSE,
      --DIVCLK_DIVIDE                         => 4,
      DIVCLK_DIVIDE                         => c_mmcm_param.divclk,
      --CLKFBOUT_MULT_F                       => 12.000,
      CLKFBOUT_MULT_F                       => c_mmcm_param.clkbout_mult_f,
      CLKFBOUT_PHASE                        => 0.000,
      CLKFBOUT_USE_FINE_PS                  => FALSE,
      -- adc clock
      --CLKOUT0_DIVIDE_F                      => 3.000,
      CLKOUT0_DIVIDE_F                      => c_mmcm_param.clk0_out_div_f,
      CLKOUT0_PHASE                         => 0.000,
      CLKOUT0_DUTY_CYCLE                    => 0.500,
      CLKOUT0_USE_FINE_PS                   => FALSE,
      -- 2x adc clock.
      --CLKOUT1_DIVIDE                        => 3,
      CLKOUT1_DIVIDE                        => c_mmcm_param.clk1_out_div,
      CLKOUT1_PHASE                         => 0.000,
      CLKOUT1_DUTY_CYCLE                    => 0.500,
      CLKOUT1_USE_FINE_PS                   => FALSE,
      -- 130 MHZ input clock
      CLKIN1_PERIOD                         => c_mmcm_param.clk0_in_period,
      REF_JITTER1                           => 0.10,
      -- Not used. Just to bypass Xilinx errors
      -- Just input 130 MHz input clock
      CLKIN2_PERIOD                         => c_mmcm_param.clk0_in_period,
      REF_JITTER2                           => 0.10
    )
    port map(
      -- Output clocks
      CLKFBOUT                              => adc_clk_fbout,
      CLKFBOUTB                             => open,
      CLKOUT0                               => adc_clk_mmcm_out,
      CLKOUT0B                              => open,
      CLKOUT1                               => adc_clk2x_mmcm_out,
      CLKOUT1B                              => open,
      CLKOUT2                               => open,
      CLKOUT2B                              => open,
      CLKOUT3                               => open,
      CLKOUT3B                              => open,
      CLKOUT4                               => open,
      CLKOUT5                               => open,
      CLKOUT6                               => open,
      -- Input clock control
      CLKFBIN                               => adc_clk_fbin,
      CLKIN1                                => adc_clk_mmcm_in,
      CLKIN2                                => '0',
      -- Tied to always select the primary input clock
      CLKINSEL                              => '1',
      -- Ports for dynamic reconfiguration
      DADDR                                 => (others => '0'),
      DCLK                                  => '0',
      DEN                                   => '0',
      DI                                    => (others => '0'),
      DO                                    => open,
      DRDY                                  => open,
      DWE                                   => '0',
      -- Ports for dynamic phase shift
      PSCLK                                 => '0',
      PSEN                                  => '0',
      PSINCDEC                              => '0',
      PSDONE                                => open,
      -- Other control and status signals
      LOCKED                                => mmcm_adc_locked_int,
      CLKINSTOPPED                          => open,
      CLKFBSTOPPED                          => open,
      PWRDWN                                => '0',
      RST                                   => sys_rst_i
    );

    -- Global clock buffer for MMCM feedback. Deskew MMCM configuration
    cmp_adc_clk_fb_bufg : BUFG
    port map(
      O                                       => adc_clk_fbin,
      I                                       => adc_clk_fbout
    );

    -- Global clock buffer for FPGA logic
    cmp_adc_out_bufg : BUFG
    port map(
      O                                       => adc_clk_bufg,
      I                                       => adc_clk_mmcm_out
    );

    cmp_adc2x_out_bufg : BUFG
    port map(
      O                                       => adc_clk2x_bufg,
      I                                       => adc_clk2x_mmcm_out
    );

  end generate;

  -- Only instantiate BUFG if BUFIO and BUFR not selected and not a reference clock
  gen_without_ref_clk : if (not g_with_ref_clk) generate

    gen_without_bufio_bufr : if (not g_with_bufio and not g_with_bufr) generate

      cmp_noref_clk_bufg : BUFG
      port map(
        O                                       => adc_clk_bufg,
        I                                       => adc_clk_mmcm_in
      );

    end generate;

  end generate;

  -- Clock buffer supported options
  --BUFIO yes / BUFR no (unsupported)
  --BUFIO no / BUFR yes (OK)
  --BUFIO yes / BUFR yes (OK)
  --BUFIO no / BUFR no (OK)

  -- Output clocks.
  -- BUFIO selected
  gen_with_bufio_out : if (g_with_bufio) generate

    adc_clk_chain_priv_o.adc_clk_bufio          <= adc_clk_bufio;

  end generate;

   -- BUFR selected
  gen_with_bufr_out : if (g_with_bufr) generate

    adc_clk_chain_priv_o.adc_clk_bufr           <= adc_clk_bufr;

    -- BUFR selected but BUFIO NOT selected. Output BUFIO clock as BUFR clock
    gen_withou_bufio_out : if (not g_with_bufio) generate

      adc_clk_chain_priv_o.adc_clk_bufio          <= adc_clk_bufr;

    end generate;
  end generate;

  -- BUFR NOT selected and BUFIO NOT selected. Output BUFIO and BUFR as BUFG clock
  gen_withou_bufr_bufio_out : if (not g_with_bufio and not g_with_bufr) generate

    adc_clk_chain_priv_o.adc_clk_bufr          <= adc_clk_bufg;
    adc_clk_chain_priv_o.adc_clk_bufio         <= adc_clk_bufg;

  end generate;

  -- Output Reference ADC clock if selected
  gen_ref_clks : if (g_with_ref_clk) generate

    adc_clk_chain_glob_o.adc_clk_bufg           <= adc_clk_bufg;
    adc_clk_chain_glob_o.adc_clk2x_bufg         <= adc_clk2x_bufg;

  end generate;

  gen_true_mmcm_lock_ref_clk : if (g_with_ref_clk) generate
    adc_clk_chain_glob_o.mmcm_adc_locked      <= mmcm_adc_locked_int;
  end generate;

  gen_false_mmcm_lock_ref_clk : if (not g_with_ref_clk) generate
    adc_clk_chain_glob_o.mmcm_adc_locked      <= '1';
  end generate;

end rtl;
