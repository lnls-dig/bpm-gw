--------------------------------------------------------------------------------
-- Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor: Xilinx
-- \   \   \/     Version: P.40xd
--  \   \         Application: netgen
--  /   /         Filename: prime_FIFO_plain.vhd
-- /___/   /\     Timestamp: Wed Oct 24 18:23:17 2012
-- \   \  /  \ 
--  \___\/\___\
--             
-- Command	: -w -sim -ofmt vhdl /home/adrian/praca/pcie_brazil/PC/hdlmake/ip_cores/7k325ffg900/tmp/_cg/prime_FIFO_plain.ngc /home/adrian/praca/pcie_brazil/PC/hdlmake/ip_cores/7k325ffg900/tmp/_cg/prime_FIFO_plain.vhd 
-- Device	: 7k325tffg900-2
-- Input file	: /home/adrian/praca/pcie_brazil/PC/hdlmake/ip_cores/7k325ffg900/tmp/_cg/prime_FIFO_plain.ngc
-- Output file	: /home/adrian/praca/pcie_brazil/PC/hdlmake/ip_cores/7k325ffg900/tmp/_cg/prime_FIFO_plain.vhd
-- # of Entities	: 1
-- Design Name	: prime_FIFO_plain
-- Xilinx	: /opt/Xilinx/14.3/ISE_DS/ISE/
--             
-- Purpose:    
--     This VHDL netlist is a verification model and uses simulation 
--     primitives which may not represent the true implementation of the 
--     device, however the netlist is functionally correct and should not 
--     be modified. This file cannot be synthesized and should only be used 
--     with supported simulation tools.
--             
-- Reference:  
--     Command Line Tools User Guide, Chapter 23
--     Synthesis and Simulation Design Guide, Chapter 6
--             
--------------------------------------------------------------------------------


-- synthesis translate_off
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
use UNISIM.VPKG.ALL;

entity prime_FIFO_plain is
  port (
    rst : in STD_LOGIC := 'X'; 
    wr_clk : in STD_LOGIC := 'X'; 
    rd_clk : in STD_LOGIC := 'X'; 
    wr_en : in STD_LOGIC := 'X'; 
    rd_en : in STD_LOGIC := 'X'; 
    full : out STD_LOGIC; 
    empty : out STD_LOGIC; 
    prog_full : out STD_LOGIC; 
    din : in STD_LOGIC_VECTOR ( 71 downto 0 ); 
    dout : out STD_LOGIC_VECTOR ( 71 downto 0 ) 
  );
end prime_FIFO_plain;

architecture STRUCTURE of prime_FIFO_plain is
  signal N1 : STD_LOGIC; 
  signal NlwRenamedSig_OI_empty : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_reg_GND_25_o_MUX_2_o : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg_GND_25_o_MUX_1_o : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_reg_161 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg_168 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp : STD_LOGIC; 
  signal N2 : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_Mshreg_power_on_wr_rst_0_171 : STD_LOGIC; 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTEMPTY_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED : STD_LOGIC;
 
  signal NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_Mshreg_power_on_wr_rst_0_Q15_UNCONNECTED : STD_LOGIC; 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_power_on_wr_rst : STD_LOGIC_VECTOR ( 0 downto 0 ); 
  signal U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb : STD_LOGIC_VECTOR ( 4 downto 0 ); 
begin
  empty <= NlwRenamedSig_OI_empty;
  XST_GND : GND
    port map (
      G => N1
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_reg : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => rd_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_reg_GND_25_o_MUX_2_o,
      PRE => rst,
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_reg_161
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg : FDP
    generic map(
      INIT => '0'
    )
    port map (
      C => wr_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg_GND_25_o_MUX_1_o,
      PRE => rst,
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg_168
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => rd_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_reg_161,
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(4)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => rd_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(4),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(3)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => rd_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(3),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(2)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => rd_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(2),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(1)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => rd_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(1),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(0)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb_4 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => wr_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg_168,
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(4)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb_3 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => wr_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(4),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(3)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb_2 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => wr_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(3),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(2)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb_1 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => wr_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(2),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(1)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb_0 : FD
    generic map(
      INIT => '0'
    )
    port map (
      C => wr_clk,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(1),
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(0)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1 : FIFO36E1
    generic map(
      ALMOST_EMPTY_OFFSET => X"0005",
      ALMOST_FULL_OFFSET => X"0010",
      DATA_WIDTH => 72,
      DO_REG => 1,
      EN_ECC_READ => FALSE,
      EN_ECC_WRITE => FALSE,
      EN_SYN => FALSE,
      FIFO_MODE => "FIFO36_72",
      FIRST_WORD_FALL_THROUGH => FALSE,
      INIT => X"000000000000000000",
      SIM_DEVICE => "7SERIES",
      SRVAL => X"000000000000000000"
    )
    port map (
      ALMOSTEMPTY => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ALMOSTEMPTY_UNCONNECTED
,
      ALMOSTFULL => prog_full,
      DBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_DBITERR_UNCONNECTED,
      EMPTY => NlwRenamedSig_OI_empty,
      FULL => full,
      INJECTDBITERR => N1,
      INJECTSBITERR => N1,
      RDCLK => rd_clk,
      RDEN => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp,
      RDERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDERR_UNCONNECTED,
      REGCE => N1,
      RST => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0),
      RSTREG => N1,
      SBITERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_SBITERR_UNCONNECTED,
      WRCLK => wr_clk,
      WREN => wr_en,
      WRERR => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRERR_UNCONNECTED,
      DI(63) => din(67),
      DI(62) => din(66),
      DI(61) => din(65),
      DI(60) => din(64),
      DI(59) => din(63),
      DI(58) => din(62),
      DI(57) => din(61),
      DI(56) => din(60),
      DI(55) => din(59),
      DI(54) => din(58),
      DI(53) => din(57),
      DI(52) => din(56),
      DI(51) => din(55),
      DI(50) => din(54),
      DI(49) => din(53),
      DI(48) => din(52),
      DI(47) => din(51),
      DI(46) => din(50),
      DI(45) => din(49),
      DI(44) => din(48),
      DI(43) => din(47),
      DI(42) => din(46),
      DI(41) => din(45),
      DI(40) => din(44),
      DI(39) => din(43),
      DI(38) => din(42),
      DI(37) => din(41),
      DI(36) => din(40),
      DI(35) => din(39),
      DI(34) => din(38),
      DI(33) => din(37),
      DI(32) => din(36),
      DI(31) => din(31),
      DI(30) => din(30),
      DI(29) => din(29),
      DI(28) => din(28),
      DI(27) => din(27),
      DI(26) => din(26),
      DI(25) => din(25),
      DI(24) => din(24),
      DI(23) => din(23),
      DI(22) => din(22),
      DI(21) => din(21),
      DI(20) => din(20),
      DI(19) => din(19),
      DI(18) => din(18),
      DI(17) => din(17),
      DI(16) => din(16),
      DI(15) => din(15),
      DI(14) => din(14),
      DI(13) => din(13),
      DI(12) => din(12),
      DI(11) => din(11),
      DI(10) => din(10),
      DI(9) => din(9),
      DI(8) => din(8),
      DI(7) => din(7),
      DI(6) => din(6),
      DI(5) => din(5),
      DI(4) => din(4),
      DI(3) => din(3),
      DI(2) => din(2),
      DI(1) => din(1),
      DI(0) => din(0),
      DIP(7) => din(71),
      DIP(6) => din(70),
      DIP(5) => din(69),
      DIP(4) => din(68),
      DIP(3) => din(35),
      DIP(2) => din(34),
      DIP(1) => din(33),
      DIP(0) => din(32),
      DO(63) => dout(67),
      DO(62) => dout(66),
      DO(61) => dout(65),
      DO(60) => dout(64),
      DO(59) => dout(63),
      DO(58) => dout(62),
      DO(57) => dout(61),
      DO(56) => dout(60),
      DO(55) => dout(59),
      DO(54) => dout(58),
      DO(53) => dout(57),
      DO(52) => dout(56),
      DO(51) => dout(55),
      DO(50) => dout(54),
      DO(49) => dout(53),
      DO(48) => dout(52),
      DO(47) => dout(51),
      DO(46) => dout(50),
      DO(45) => dout(49),
      DO(44) => dout(48),
      DO(43) => dout(47),
      DO(42) => dout(46),
      DO(41) => dout(45),
      DO(40) => dout(44),
      DO(39) => dout(43),
      DO(38) => dout(42),
      DO(37) => dout(41),
      DO(36) => dout(40),
      DO(35) => dout(39),
      DO(34) => dout(38),
      DO(33) => dout(37),
      DO(32) => dout(36),
      DO(31) => dout(31),
      DO(30) => dout(30),
      DO(29) => dout(29),
      DO(28) => dout(28),
      DO(27) => dout(27),
      DO(26) => dout(26),
      DO(25) => dout(25),
      DO(24) => dout(24),
      DO(23) => dout(23),
      DO(22) => dout(22),
      DO(21) => dout(21),
      DO(20) => dout(20),
      DO(19) => dout(19),
      DO(18) => dout(18),
      DO(17) => dout(17),
      DO(16) => dout(16),
      DO(15) => dout(15),
      DO(14) => dout(14),
      DO(13) => dout(13),
      DO(12) => dout(12),
      DO(11) => dout(11),
      DO(10) => dout(10),
      DO(9) => dout(9),
      DO(8) => dout(8),
      DO(7) => dout(7),
      DO(6) => dout(6),
      DO(5) => dout(5),
      DO(4) => dout(4),
      DO(3) => dout(3),
      DO(2) => dout(2),
      DO(1) => dout(1),
      DO(0) => dout(0),
      DOP(7) => dout(71),
      DOP(6) => dout(70),
      DOP(5) => dout(69),
      DOP(4) => dout(68),
      DOP(3) => dout(35),
      DOP(2) => dout(34),
      DOP(1) => dout(33),
      DOP(0) => dout(32),
      ECCPARITY(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_7_UNCONNECTED
,
      ECCPARITY(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_6_UNCONNECTED
,
      ECCPARITY(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_5_UNCONNECTED
,
      ECCPARITY(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_4_UNCONNECTED
,
      ECCPARITY(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_3_UNCONNECTED
,
      ECCPARITY(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_2_UNCONNECTED
,
      ECCPARITY(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_1_UNCONNECTED
,
      ECCPARITY(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_ECCPARITY_0_UNCONNECTED
,
      RDCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_12_UNCONNECTED
,
      RDCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_11_UNCONNECTED
,
      RDCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_10_UNCONNECTED
,
      RDCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_9_UNCONNECTED
,
      RDCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_8_UNCONNECTED
,
      RDCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_7_UNCONNECTED
,
      RDCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_6_UNCONNECTED
,
      RDCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_5_UNCONNECTED
,
      RDCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_4_UNCONNECTED
,
      RDCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_3_UNCONNECTED
,
      RDCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_2_UNCONNECTED
,
      RDCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_1_UNCONNECTED
,
      RDCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_RDCOUNT_0_UNCONNECTED
,
      WRCOUNT(12) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_12_UNCONNECTED
,
      WRCOUNT(11) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_11_UNCONNECTED
,
      WRCOUNT(10) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_10_UNCONNECTED
,
      WRCOUNT(9) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_9_UNCONNECTED
,
      WRCOUNT(8) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_8_UNCONNECTED
,
      WRCOUNT(7) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_7_UNCONNECTED
,
      WRCOUNT(6) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_6_UNCONNECTED
,
      WRCOUNT(5) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_5_UNCONNECTED
,
      WRCOUNT(4) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_4_UNCONNECTED
,
      WRCOUNT(3) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_3_UNCONNECTED
,
      WRCOUNT(2) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_2_UNCONNECTED
,
      WRCOUNT(1) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_1_UNCONNECTED
,
      WRCOUNT(0) => 
NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_gf36e1_inst_sngfifo36e1_WRCOUNT_0_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_Mmux_rd_rst_reg_GND_25_o_MUX_2_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_fb(0),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_reg_161,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_rd_rst_reg_GND_25_o_MUX_2_o
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_Mmux_wr_rst_reg_GND_25_o_MUX_1_o11 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_fb(0),
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg_168,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg_GND_25_o_MUX_1_o
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_WR_RST_I_1_1 : LUT2
    generic map(
      INIT => X"E"
    )
    port map (
      I0 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_wr_rst_reg_168,
      I1 => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_power_on_wr_rst(0),
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_wr_rst_i(0)
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp1 : LUT2
    generic map(
      INIT => X"4"
    )
    port map (
      I0 => NlwRenamedSig_OI_empty,
      I1 => rd_en,
      O => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_v6_fifo_fblk_gextw_1_gnll_fifo_inst_extd_gonep_inst_prim_rden_tmp
    );
  XST_VCC : VCC
    port map (
      P => N2
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_Mshreg_power_on_wr_rst_0 : SRLC16E
    generic map(
      INIT => X"001F"
    )
    port map (
      A0 => N1,
      A1 => N1,
      A2 => N2,
      A3 => N1,
      CE => N2,
      CLK => wr_clk,
      D => N1,
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_Mshreg_power_on_wr_rst_0_171,
      Q15 => NLW_U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_Mshreg_power_on_wr_rst_0_Q15_UNCONNECTED
    );
  U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_power_on_wr_rst_0 : FDE
    generic map(
      INIT => '1'
    )
    port map (
      C => wr_clk,
      CE => N2,
      D => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_Mshreg_power_on_wr_rst_0_171,
      Q => U0_xst_fifo_generator_gconvfifo_rf_gbiv5_bi_rstbt_power_on_wr_rst(0)
    );

end STRUCTURE;

-- synthesis translate_on
