library ieee;
use ieee.std_logic_1164.all;

package bpm_pcie_k7_const_pkg is

  --------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------
  -- PCIe Lanes
  constant c_pcie_lanes                       : integer := 4;

  -- PCIE Constants from Xilinx COREGEN
  constant c_ddr_dq_width                     : integer := 64;
  constant c_ddr_payload_width                : integer := 512;
  constant c_ddr_dqs_width                    : integer := 8;
  constant c_ddr_dm_width                     : integer := 8;
  constant c_ddr_row_width                    : integer := 14;
  constant c_ddr_bank_width                   : integer := 3;
  constant c_ddr_ck_width                     : integer := 1;
  constant c_ddr_cke_width                    : integer := 1;
  constant c_ddr_odt_width                    : integer := 1;

  constant c_ddr_addr_width                   : integer := 28;

end bpm_pcie_k7_const_pkg;
