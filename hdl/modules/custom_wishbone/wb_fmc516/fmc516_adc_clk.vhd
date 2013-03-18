------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-29-10
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Clock Interface with FMC516 ADC board from Curtis Wright.
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

entity fmc516_adc_clk is
generic
(
    -- The only supported values are VIRTEX6 and 7SERIES
  g_fpga_device                             : string := "VIRTEX6";
  g_delay_type                              : string := "VARIABLE";
  g_adc_clock_period                        : real;
  g_default_adc_clk_delay                   : natural := 0;
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
  -- idelay var_loadable interface
  adc_clk_dly_val_i                         : in std_logic_vector(4 downto 0);
  adc_clk_dly_val_o                         : out std_logic_vector(4 downto 0);

  -- idelay variable interface
  adc_clk_dly_incdec_i                      : in std_logic;

  -- Pulse this to update the delay value or reset to its default (depending
  -- if idelay is in variable or var_loadable mode)
  adc_clk_dly_pulse_i                       : in std_logic;

  -----------------------------
  -- ADC output signals.
  -----------------------------
  adc_clk_bufio_o                           : out std_logic;
  adc_clk_bufr_o                            : out std_logic;
  adc_clk_bufg_o                            : out std_logic;
  adc_clk2x_bufg_o                          : out std_logic;

  -----------------------------
  -- MMCM general signals
  -----------------------------
  mmcm_adc_locked_o                         : out std_logic
);

end fmc516_adc_clk;

architecture rtl of fmc516_adc_clk is

  -- Clock and reset signals
  signal adc_clk_ibufgds                    : std_logic;
  signal adc_clk_ibufgds_dly                : std_logic;

  -- Clock BUFMR signals
  signal adc_clk_bufmr                      : std_logic;

  -- Clock BUFIO/BUFR input signals
  signal adc_clk_bufio_in                   : std_logic;
  signal adc_clk_bufr_in                    : std_logic;

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


begin
  -----------------------------
  -- Clock signal datapath
  -----------------------------

  -- Diferential Clock Buffers (IBUFGDS = IBUFDS)
  -- IBUFGDS is just a different name for IBUFDS
  --cmp_ibufgds_clk : ibufgds
  --generic map(
  --  IOSTANDARD                              => "LVDS_25",
  --  DIFF_TERM                               => TRUE
  --)
  --port map(
  --  i                                       => adc_clk_p_i,
  --  ib                                      => adc_clk_n_i,
  --  o                                       => adc_clk_ibufgds
  --);

  -- Delay for Clock Buffers
  -- From Virtex-6 SelectIO Datasheet:
  -- Sets the type of tap delay line. DEFAULT delay guarantees zero hold times.
  -- FIXED delay sets a static delay value. VAR_LOADABLE dynamically loads tap
  -- values. VARIABLE delay dynamically adjusts the delay value.
  --
  -- HIGH_PERFORMANCE_MODE = TRUE reduces the output
  -- jitter in exchange of increase power dissipation
  cmp_ibufds_clk_iodelay : iodelaye1
  generic map(
    IDELAY_TYPE                             => g_delay_type,
    IDELAY_VALUE                            => g_default_adc_clk_delay,
    SIGNAL_PATTERN                          => "CLOCK",
    HIGH_PERFORMANCE_MODE                   => TRUE,
    DELAY_SRC                               => "I"
  )
  port map(
    --idatain                                 => adc_clk_ibufgds,
    idatain                                 => adc_clk_i,
    dataout                                 => adc_clk_ibufgds_dly,
    -- FIX THIS CLOCK!
    c                                       => sys_clk_200Mhz_i,
    --ce                                      => adc_clk_dly_pulse_i,
    ce                                      => '0',
    inc                                     => adc_clk_dly_incdec_i,
    datain                                  => '0',
    odatain                                 => '0',
    clkin                                   => '0',
    rst                                     => adc_clk_dly_pulse_i,
    cntvaluein                              => adc_clk_dly_val_i,
    cntvalueout                             => adc_clk_dly_val_o,
    cinvctrl                                => '0',
    t                                       => '1'
  );

  -- Generate BUFMR and connect directly to BUFIO/BUFR
  --
  -- In Xilinx 7-Series devices, BUFIO/BUFR only drives a single clock region.
  -- If BUFIO/BUFR must drive multi clock-regions (up to 3: actual, above and
  -- below), we must instanciate a multi-clock buffer (BUFMR) and then drive
  -- the BUFIO/BUFR as needed.
  gen_bufmr : if g_fpga_device = "7SERIES" generate

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

  -- Do not generate BUFMR and connect the input clock directly to BUFIO/BUFR
  gen_not_bufmr : if g_fpga_device = "VIRTEX6" generate

    adc_clk_bufio_in                        <= adc_clk_ibufgds_dly;
    adc_clk_bufr_in                         <= adc_clk_ibufgds_dly;
  end generate;

  -- BUFIO (better switching characteristics than BUFR and BUFG).
  -- It can be used just inside ILOGIC blocks resources, such as
  -- an IDDR block.
  cmp_adc_clk_bufio : bufio
  port map (
    O                                       => adc_clk_bufio,
    I                                       => adc_clk_bufio_in
  );

  -- BUFR (better switching characteristics than BUFG).
  -- It can drive logic elements (block ram, CLB, DSP tiles,
  -- etc) up to 6 clock regions.
  cmp_adc_clk_bufr : bufr
  generic map(
    SIM_DEVICE                                 => g_fpga_device,
    BUFR_DIVIDE                             => "BYPASS"
  )
  port map (
    CLR                                     => '0',
    CE                                      => '1',
    I                                       => adc_clk_bufr_in,
    O                                       => adc_clk_bufr
  );

  -- ADC Clock PLL. Caution here!
  cmp_mmcm_adc_clk : MMCM_ADV
  generic map(
    BANDWIDTH                             => "OPTIMIZED",
    CLKOUT4_CASCADE                       => FALSE,
    CLOCK_HOLD                            => FALSE,
    -- Let the synthesis tools select the best appropriate
    -- compensation method (as dictated in Virtex-6 clocking
    -- resourses guide page 53, note 2)
    COMPENSATION                          => "ZHOLD",
    STARTUP_WAIT                          => FALSE,
    DIVCLK_DIVIDE                         => 4,
    CLKFBOUT_MULT_F                       => 12.000,
    CLKFBOUT_PHASE                        => 0.000,
    CLKFBOUT_USE_FINE_PS                  => FALSE,
    -- adc clock
    CLKOUT0_DIVIDE_F                      => 3.000,
    CLKOUT0_PHASE                         => 0.000,
    CLKOUT0_DUTY_CYCLE                    => 0.500,
    CLKOUT0_USE_FINE_PS                   => FALSE,
    -- 2x adc clock. This should not be 2x. FIX
    --CLKOUT1_DIVIDE                        => 2,
    CLKOUT1_DIVIDE                        => 3,
    CLKOUT1_PHASE                         => 0.000,
    CLKOUT1_DUTY_CYCLE                    => 0.500,
    CLKOUT1_USE_FINE_PS                   => FALSE,
    -- 250 MHZ input clock
    CLKIN1_PERIOD                         => g_adc_clock_period,
    REF_JITTER1                           => 0.10,
    -- Not used. Just to bypass Xilinx errors
    -- Just input 250 MHz input clock
    CLKIN2_PERIOD                         => g_adc_clock_period,
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
    CLKIN1                                => adc_clk_bufr,
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
    LOCKED                                => mmcm_adc_locked_o,
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

  -- Output clocks
  adc_clk_bufio_o                           <= adc_clk_bufio;
  adc_clk_bufr_o                            <= adc_clk_bufr;
  adc_clk_bufg_o                            <= adc_clk_bufg;
  adc_clk2x_bufg_o                          <= adc_clk2x_bufg;


end rtl;
