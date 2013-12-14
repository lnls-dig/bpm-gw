--*****************************************************************************
-- (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
--*****************************************************************************
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: 3.92
--  \   \         Application: MIG
--  /   /         Filename: infrastructure.v
-- /___/   /\     Date Last Modified: $Date: 2011/06/02 07:18:11 $
-- \   \  /  \    Date Created:Tue Jun 30 2009
--  \___\/\___\
--
--Device: Virtex-6
--Design Name: DDR3 SDRAM
--Purpose:
--   Clock generation/distribution and reset synchronization
--Reference:
--Revision History:
--*****************************************************************************

--******************************************************************************
--**$Id: infrastructure.vhd,v 1.1 2011/06/02 07:18:11 mishra Exp $
--**$Date: 2011/06/02 07:18:11 $
--**$Author: mishra $
--**$Revision: 1.1 $
--**$Source: /devl/xcs/repo/env/Databases/ip/src2/O/mig_v3_9/data/dlib/virtex6/ddr3_sdram/vhdl/rtl/ip_top/infrastructure.vhd,v $
--******************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library unisim;
use unisim.vcomponents.all;

library std;
use std.textio.all;

entity infrastructure is
  generic (
   TCQ                : integer := 100;            -- clk->out delay (sim only)
   CLK_PERIOD         : integer := 3000;           -- Internal (fabric) clk period
   nCK_PER_CLK        : integer := 2;              -- External (memory) clock period =
                                                -- CLK_PERIOD/nCK_PER_CLK
   INPUT_CLK_TYPE     : string  := "DIFFERENTIAL"; -- input clock type
                                                -- "DIFFERENTIAL","SINGLE_ENDED"
   MMCM_ADV_BANDWIDTH : string  := "OPTIMIZED"; -- MMCM programming algorithm
   CLKFBOUT_MULT_F    : integer := 2;              -- write PLL VCO multiplier
   DIVCLK_DIVIDE      : integer := 1;              -- write PLL VCO divisor
   CLKOUT_DIVIDE      : integer := 2;              -- VCO output divisor for fast
                                                -- (memory) clocks
   RST_ACT_LOW        : integer := 1
   );
  port (
   -- Clock inputs
   mmcm_clk           : in  std_logic;   -- System clock diff input
   -- System reset input
   sys_rst            : in  std_logic;   -- core reset from user application
   -- MMCM/IDELAYCTRL Lock status
   iodelay_ctrl_rdy   : in  std_logic;   -- IDELAYCTRL lock status
   -- Clock outputs
   clk_mem            : out std_logic;  -- 2x logic clock
   clk                : out std_logic;  -- 1x logic clock
   clk_rd_base        : out std_logic;  -- 2x base read clock
   -- Reset outputs
   rstdiv0            : out std_logic;  -- Reset CLK and CLKDIV logic (incl I/O)
   -- Phase Shift Interface
   PSDONE             : out std_logic;
   PSEN               : in  std_logic;
   PSINCDEC           : in  std_logic
   );
end entity infrastructure;

architecture arch_infrastructure of infrastructure is
  -- # of clock cycles to delay deassertion of reset. Needs to be a fairly
  -- high number not so much for metastability protection, but to give time
  -- for reset (i.e. stable clock cycles) to propagate through all state
  -- machines and to all control signals (i.e. not all control signals have
  -- resets, instead they rely on base state logic being reset, and the effect
  -- of that reset propagating through the logic). Need this because we may not
  -- be getting stable clock cycles while reset asserted (i.e. since reset
  -- depends on DCM lock status)
  -- COMMENTED, RC, 01/13/09 - causes pack error in MAP w/ larger #
  constant RST_SYNC_NUM     : integer := 15;
  -- constant RST_SYNC_NUM : integer := 25;;
  -- Round up for clk reset delay to ensure that CLKDIV reset deassertion
  -- occurs at same time or after CLK reset deassertion (still need to
  -- consider route delay - add one or two extra cycles to be sure!)
  constant RST_DIV_SYNC_NUM : integer := (RST_SYNC_NUM+1)/2;

  constant CLKIN1_PERIOD    : real
             := real((CLKFBOUT_MULT_F * CLK_PERIOD))/
             real(DIVCLK_DIVIDE * CLKOUT_DIVIDE * nCK_PER_CLK * 1000);  -- in ns

  constant VCO_PERIOD       : integer
             := (DIVCLK_DIVIDE * CLK_PERIOD)/(CLKFBOUT_MULT_F * nCK_PER_CLK);

  constant CLKOUT0_DIVIDE_F : integer := CLKOUT_DIVIDE;
  constant CLKOUT1_DIVIDE   : integer := CLKOUT_DIVIDE * nCK_PER_CLK;
  constant CLKOUT2_DIVIDE   : integer := CLKOUT_DIVIDE;

  constant CLKOUT0_PERIOD   : integer := VCO_PERIOD * CLKOUT0_DIVIDE_F;
  constant CLKOUT1_PERIOD   : integer := VCO_PERIOD * CLKOUT1_DIVIDE  ;
  constant CLKOUT2_PERIOD   : integer := VCO_PERIOD * CLKOUT2_DIVIDE  ;

  signal clk_bufg             : std_logic;
  signal clk_mem_bufg         : std_logic;
  signal clk_mem_pll          : std_logic;
  signal clk_pll              : std_logic;
  signal clkfbout_pll         : std_logic;
  signal pll_lock             : std_logic;
                                -- synthesis syn_maxfan = 10
  signal rstdiv0_sync_r       : std_logic_vector(RST_DIV_SYNC_NUM-1 downto 0);
                                -- synthesis syn_maxfan = 10
  signal rst_tmp              : std_logic;
  signal sys_rst_act_hi       : std_logic;

  attribute syn_maxfan : integer;
  attribute syn_maxfan of rstdiv0_sync_r : signal is 10 ;

  begin

  sys_rst_act_hi <= (not sys_rst) when(RST_ACT_LOW = 1) else (sys_rst);

  --synthesis translate_off
  print : process is
   variable my_line : line;
    begin
    write(my_line, string'("############# Write Clocks MMCM_ADV Parameters #############"));
    writeline(output, my_line);
    write(my_line, string'("nCK_PER_CLK      = "));
    write(my_line, nCK_PER_CLK);
    writeline(output, my_line);
    write(my_line, string'("CLK_PERIOD      = "));
    write(my_line, CLK_PERIOD);
    writeline(output, my_line);
    write(my_line, string'("CLKIN1_PERIOD      = "));
    write(my_line, CLKIN1_PERIOD);
    writeline(output, my_line);
    write(my_line, string'("DIVCLK_DIVIDE      = "));
    write(my_line, DIVCLK_DIVIDE);
    writeline(output, my_line);
    write(my_line, string'("CLKFBOUT_MULT_F      = "));
    write(my_line, CLKFBOUT_MULT_F);
    writeline(output, my_line);
    write(my_line, string'("VCO_PERIOD      = "));
    write(my_line, VCO_PERIOD);
    writeline(output, my_line);
    write(my_line, string'("CLKOUT0_DIVIDE_F      = "));
    write(my_line, CLKOUT0_DIVIDE_F);
    writeline(output, my_line);
    write(my_line, string'("CLKOUT1_DIVIDE      = "));
    write(my_line, CLKOUT1_DIVIDE);
    writeline(output, my_line);
    write(my_line, string'("CLKOUT2_DIVIDE      = "));
    write(my_line, CLKOUT2_DIVIDE);
    writeline(output, my_line);
    write(my_line, string'("CLKOUT0_PERIOD      = "));
    write(my_line, CLKOUT0_PERIOD);
    writeline(output, my_line);
    write(my_line, string'("CLKOUT1_PERIOD      = "));
    write(my_line, CLKOUT1_PERIOD);
    writeline(output, my_line);
    write(my_line, string'("CLKOUT2_PERIOD      = "));
    write(my_line, CLKOUT2_PERIOD);
    writeline(output, my_line);
    write(my_line, string'("############################################################"));
    writeline(output, my_line);
    wait;
  end process print;
  --synthesis translate_on

  --***************************************************************************
  -- Assign global clocks:
  --   1. clk_mem : Full rate (used only for IOB)
  --   2. clk     : Half rate (used for majority of internal logic)
  --***************************************************************************

  clk_mem <= clk_mem_bufg;
  clk     <= clk_bufg;

  --***************************************************************************
  -- Global base clock generation and distribution
  --***************************************************************************

  --*****************************************************************
  -- NOTES ON CALCULTING PROPER VCO FREQUENCY
  --  1. VCO frequency =
  --     1/((DIVCLK_DIVIDE * CLK_PERIOD)/(CLKFBOUT_MULT_F * nCK_PER_CLK))
  --  2. VCO frequency must be in the range [800MHz, 1.2MHz] for -1 part.
  --     The lower limit of 800MHz is greater than the lower supported
  --     frequency of 400MHz according to the datasheet because the MMCM
  --     jitter performance improves significantly when the VCO is operatin
  --     above 800MHz. For speed grades faster than -1, the max VCO frequency
  --     will be highe, and the multiply and divide factors can be adjusted
  --     according (in general to run the VCO as fast as possible).
  --*****************************************************************

  u_mmcm_adv : MMCM_ADV
    generic map (
      BANDWIDTH             => MMCM_ADV_BANDWIDTH,
      CLOCK_HOLD            => FALSE,
      COMPENSATION          => "INTERNAL",
      REF_JITTER1           => 0.005,
      REF_JITTER2           => 0.005,
      STARTUP_WAIT          => FALSE,

      CLKIN1_PERIOD         => CLKIN1_PERIOD,
      CLKIN2_PERIOD         => 10.000,

      CLKFBOUT_MULT_F       => real(CLKFBOUT_MULT_F),
      DIVCLK_DIVIDE         => DIVCLK_DIVIDE,

      CLKFBOUT_PHASE        => 0.000,
      CLKFBOUT_USE_FINE_PS  => FALSE,

      CLKOUT0_DIVIDE_F      => real(CLKOUT0_DIVIDE_F),
      CLKOUT0_DUTY_CYCLE    => 0.500,
      CLKOUT0_PHASE         => 0.000,
      CLKOUT0_USE_FINE_PS   => FALSE,

      CLKOUT1_DIVIDE        => CLKOUT1_DIVIDE,
      CLKOUT1_DUTY_CYCLE    => 0.500,
      CLKOUT1_PHASE         => 0.000,
      CLKOUT1_USE_FINE_PS   => FALSE,

      CLKOUT2_DIVIDE        => CLKOUT2_DIVIDE,
      CLKOUT2_DUTY_CYCLE    => 0.500,
      CLKOUT2_PHASE         => 0.000,
      CLKOUT2_USE_FINE_PS   => TRUE,

      CLKOUT3_DIVIDE        => 1,
      CLKOUT3_DUTY_CYCLE    => 0.500,
      CLKOUT3_PHASE         => 0.000,
      CLKOUT3_USE_FINE_PS   => FALSE,

      CLKOUT4_CASCADE       => FALSE,
      CLKOUT4_DIVIDE        => 1,
      CLKOUT4_DUTY_CYCLE    => 0.500,
      CLKOUT4_PHASE         => 0.000,
      CLKOUT4_USE_FINE_PS   => FALSE,

      CLKOUT5_DIVIDE        => 1,
      CLKOUT5_DUTY_CYCLE    => 0.500,
      CLKOUT5_PHASE         => 0.000,
      CLKOUT5_USE_FINE_PS   => FALSE,

      CLKOUT6_DIVIDE        => 1,
      CLKOUT6_DUTY_CYCLE    => 0.500,
      CLKOUT6_PHASE         => 0.000,
      CLKOUT6_USE_FINE_PS   => FALSE
     )
      port map (
       CLKFBOUT     => clkfbout_pll,
       CLKFBOUTB    => open,
       CLKFBSTOPPED => open,
       CLKINSTOPPED => open,
       CLKOUT0      => clk_mem_pll,
       CLKOUT0B     => open,
       CLKOUT1      => clk_pll,
       CLKOUT1B     => open,
       CLKOUT2      => clk_rd_base,   -- Performance path for inner columns
       CLKOUT2B     => open,
       CLKOUT3      => open,   -- Performance path for outer columns
       CLKOUT3B     => open,
       CLKOUT4      => open,
       CLKOUT5      => open,
       CLKOUT6      => open,
       DO           => open,
       DRDY         => open,
       LOCKED       => pll_lock,
       PSDONE       => PSDONE,
       CLKFBIN      => clkfbout_pll,
       CLKIN1       => mmcm_clk,
       CLKIN2       => '0',
       CLKINSEL     => '1',
       DADDR        => (others => '0'),
       DCLK         => '0',
       DEN          => '0',
       DI           => x"0000",
       DWE          => '0',
       PSCLK        => clk_bufg,
       PSEN         => PSEN,
       PSINCDEC     => PSINCDEC,
       PWRDWN       => '0',
       RST          => sys_rst_act_hi
       );

  u_bufg_clk0 : BUFG
    port map (
     O => clk_mem_bufg,
     I => clk_mem_pll
     );

  u_bufg_clkdiv0 : BUFG
    port map (
     O => clk_bufg,
     I => clk_pll
     );

  --***************************************************************************
  -- RESET SYNCHRONIZATION DESCRIPTION:
  --  Various resets are generated to ensure that:
  --   1. All resets are synchronously deasserted with respect to the clock
  --      domain they are interfacing to. There are several different clock
  --      domains - each one will receive a synchronized reset.
  --   2. The reset deassertion order starts with deassertion of SYS_RST,
  --      followed by deassertion of resets for various parts of the design
  --      (see "RESET ORDER" below) based on the lock status of MMCMs.
  -- RESET ORDER:
  --   1. User deasserts SYS_RST
  --   2. Reset MMCM and IDELAYCTRL
  --   3. Wait for MMCM and IDELAYCTRL to lock
  --   4. Release reset for all I/O primitives and internal logic
  -- OTHER NOTES:
  --   1. Asynchronously assert reset. This way we can assert reset even if
  --      there is no clock (needed for things like 3-stating output buffers
  --      to prevent initial bus contention). Reset deassertion is synchronous.
  --***************************************************************************

  --*****************************************************************
  -- CLK and CLKDIV logic reset
  --*****************************************************************

  -- Wait for both PLL's and IDELAYCTRL to lock
   rst_tmp <= sys_rst_act_hi or (not pll_lock) or (not iodelay_ctrl_rdy);

  process(clk_bufg, rst_tmp)
  begin
    if (rst_tmp = '1') then
      rstdiv0_sync_r <= (others => '1') after (TCQ)*1 ps;
    elsif(clk_bufg'event and clk_bufg = '1') then
      rstdiv0_sync_r <= (rstdiv0_sync_r(RST_DIV_SYNC_NUM-2 downto 0) & '0') after (TCQ)*1 ps;
    end if;
  end process;

  rstdiv0 <= rstdiv0_sync_r(RST_DIV_SYNC_NUM-1);

end architecture arch_infrastructure;
