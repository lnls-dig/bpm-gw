------------------------------------------------------------------------------
-- Title      : Wishbone FMC516 ADC Interface
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2012-17-10
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
	g_default_adc_clk_delay                		: natural := 0;
	g_sim                                   	: integer := 0
);
port
(
	sys_clk_i                               	: in std_logic;
	sys_rst_i                             		: in std_logic;
			
	-----------------------------
	-- External ports
	-----------------------------
	
	-- ADC clocks. One clock per ADC channel
	adc_clk_p_i                        				: in std_logic;
	adc_clk_n_i                        				: in std_logic;
	
	-----------------------------
	-- ADC Delay signals.
	-----------------------------
	-- Pulse this to update the delay value
	adc_clk_dly_pulse_i                    		: in std_logic;
	adc_clk_dly_val_i                      		: in std_logic_vector(4 downto 0);
	adc_clk_dly_val_o                      		: out std_logic_vector(4 downto 0);
	
	-----------------------------
	-- ADC output signals.
	-----------------------------
	adc_clk_bufio_o                        		: out std_logic;
	adc_clk_bufr_o                        		: out std_logic;
	adc_clk_bufg_o                        		: out std_logic;

	-----------------------------
	-- MMCM general signals
	-----------------------------
	mmcm_adc_locked_o                       	: out std_logic;
);

end fmc516_adc_iface;

architecture rtl of fmc516_adc_clk is

  constant c_num_adc_channels               : natural := 4;
  alias c_num_adc_bits                      is g_num_adc_bits;

  -- Clock and reset signals
  signal adc_clk_ibufgds                		: std_logic;
  signal adc_clk_ibufgds_dly             		: std_logic;
  signal sys_rst                            : std_logic;

  -- Clock internal signals interconnect
  signal adc_clk_bufio                  		: std_logic;
  signal adc_clk_bufr                   		: std_logic;
  signal adc_clk_bufg	 											: std_logic;

  -- Clock MMCM signals
  signal adc_clk_fbin                      	: std_logic;
  signal adc_clk_fbout                     	: std_logic;
  signal adc_clk_mmcm_2x_out               	: std_logic;
  signal adc_clk_mmcm_out                   : std_logic; 

begin
  -----------------------------
  -- Clock signal datapath
  -----------------------------

  -- Diferential Clock Buffers (IBUFGDS = IBUFDS)
  -- IBUFGDS is just a different name for IBUFDS
  cmp_ibufgds_clk : ibufgds
  generic map
  (
    IOSTANDARD                              => "LVDS_25",
    DIFF_TERM                               => TRUE
  )
  port map
  (
    i  																			=> adc_clk_p_i,
    ib 																			=> adc_clk_n_i,
    o  																			=> adc_clk_ibufgds
  );

  -- Delay for Clock Buffers
  -- From Virtex-6 SelectIO Datasheet:
  -- Sets the type of tap delay line. DEFAULT delay 
  -- guarantees zero hold times. FIXED delay sets a 
  -- static delay value. VAR_LOADABLE dynamically
  -- loads tap values. VARIABLE delay dynamically
  -- adjusts the delay value.
  --
  -- HIGH_PERFORMANCE_MODE = TRUE reduces the output
  -- jitter on exchange of increase power dissipation
  cmp_ibufgds_clk1_iodelay : iodelaye1
  generic map
  (
    IDELAY_TYPE                             => "VAR_LOADABLE",
    IDELAY_VALUE                            => g_default_adc_clk_delay,
    SIGNAL_PATTERN                          => "CLOCK",
    HIGH_PERFORMANCE_MODE                   => TRUE,
    DELAY_SRC                               => "I"
  )
  port map
  (
    idatain                                 => adc_clk_ibufgds,
    dataout                                 => adc_clk_ibufgds_dly,
    c                                       => sys_clk_i,
    ce                                      => '0',
    inc                                     => '0',
    datain                                  => '0',
    odatain                                 => '0',
    clkin                                   => '0',
    rst                                     => adc_clk_dly_pulse_i,
    cntvaluein                              => adc_clk_dly_val_i,
    cntvalueout                             => adc_clk_dly_val_o,
    cinvctrl                                => '0',
    t                                       => '1'
  );

  -- BUFIO (better switching characteristics than BUFR and BUFG).
  -- It can be used just inside ILOGIC blocks resources, such as
  -- an IDDR block.
  cmp_adc_clk1_bufio : bufio
  port map (
    O                                       => adc_clk_bufio,
    I                                       => adc_clk_ibufgds_dly
  );

  -- BUFR (better switching characteristics than BUFG).
  -- It can drive logic elements (block ram, CLB, DSP tiles,
  -- etc) up to 6 clock regions.
  cmp_adc_clk1_bufr : bufr  
	generic map
	(
		SIM_DEVICE 	=> "VIRTEX6",
		BUFR_DIVIDE => "BYPASS"
	)
	port map 
	(
		clr  	                                  => '0',
		ce 	 	                                  => '1',
		i 		                                  => adc_clk_ibufgds_dly,
		o 		                                  => adc_clk_bufr
	);

  -- ADC Clock PLL
  cmp_mmcm_adc_clk1 : MMCM_ADV
  generic map
  (
      BANDWIDTH                             => "OPTIMIZED",
      CLKOUT4_CASCADE                       => FALSE,
      CLOCK_HOLD                            => FALSE,
      -- Let the synthesis tools select the best appropriate
      -- compensation method (as dictated in Virtex-6 clocking
      -- resourses guide page 53, note 2)
      --COMPENSATION         => "ZHOLD",
      STARTUP_WAIT                          => FALSE,
      DIVCLK_DIVIDE                         => 1,
      CLKFBOUT_MULT_F                       => 16.000,
      CLKFBOUT_PHASE                        => 0.000,
      CLKFBOUT_USE_FINE_PS                  => FALSE,
      CLKOUT0_DIVIDE_F                      => 8.000,
      CLKOUT0_PHASE                         => 0.000,
      CLKOUT0_DUTY_CYCLE                    => 0.500,
      CLKOUT0_USE_FINE_PS                   => FALSE,
      CLKOUT1_DIVIDE                        => 16,
      CLKOUT1_PHASE                         => 0.000,
      CLKOUT1_DUTY_CYCLE                    => 0.500,
      CLKOUT1_USE_FINE_PS                   => FALSE,
      -- 250 MHZ input clock
      CLKIN1_PERIOD                         => 4.0,
      REF_JITTER1                           => 0.010,
      -- Not used. Just to bypass Xilinx errors
      -- Just input 250 MHz input clock
      CLKIN2_PERIOD                         => 4.0,
      REF_JITTER2                           => 0.010
  )
  port map
  (
      -- Output clocks
      CLKFBOUT                              => adc_clk_fbout,
      CLKFBOUTB                             => open,
      CLKOUT0                               => adc_clk_mmcm_out,
      CLKOUT0B                              => open,
      CLKOUT1                               => open,
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
  cmp_clkf_bufg : BUFG
  port map
  (
    O                                       => adc_clk_fbin,
    I                                       => adc_clk_fbout
  );

  -- Global clock buffer for FPGA logic
  cmp_adc_str_out_bufg : BUFG
  port map
  (
		O                                       => adc_clk_bufg,
		I                                       => adc_clk_mmcm_out
  );

	-- Output clocks
	adc_clk_bufio_o    												<= adc_clk_bufio;
	adc_clk_bufr_o    												<= adc_clk_bufr;
	adc_clk_bufg_o     												<= adc_clk_bufg;

end rtl;
