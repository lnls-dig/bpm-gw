-------------------------------------------------------------------------------
-- Copyright (c) 2015 Xilinx, Inc.
-- All Rights Reserved
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor     : Xilinx
-- \   \   \/     Version    : 14.7
--  \   \         Application: XILINX CORE Generator
--  /   /         Filename   : chipscope_vio_32.vhd
-- /___/   /\     Timestamp  : Qua Nov 18 17:38:49 BRST 2015
-- \   \  /  \
--  \___\/\___\
--
-- Design Name: VHDL Synthesis Wrapper
-------------------------------------------------------------------------------
-- This wrapper is used to integrate with Project Navigator and PlanAhead

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY chipscope_vio_32 IS
  port (
    CONTROL: inout std_logic_vector(35 downto 0);
    CLK: in std_logic;
    SYNC_OUT: out std_logic_vector(31 downto 0));
END chipscope_vio_32;

ARCHITECTURE chipscope_vio_32_a OF chipscope_vio_32 IS
BEGIN

END chipscope_vio_32_a;
