library ieee;
use ieee.std_logic_1164.all;

package bpm_pcie_a7_pkg is

  --------------------------------------------------------------------
  -- Constants
  --------------------------------------------------------------------
  -- PCIe Lanes
  constant c_pcie_lanes                       : integer := 4;
  -- PCIE Constants.
  constant c_ddr_dq_width                     : integer := 32;
  constant c_ddr_payload_width                : integer := 256;
  constant c_ddr_dqs_width                    : integer := 4;
  constant c_ddr_dm_width                     : integer := 4;
  constant c_ddr_row_width                    : integer := 16;
  constant c_ddr_bank_width                   : integer := 3;
  constant c_ddr_ck_width                     : integer := 1;
  constant c_ddr_cke_width                    : integer := 1;
  constant c_ddr_odt_width                    : integer := 1;

end bpm_pcie_a7_pkg;
