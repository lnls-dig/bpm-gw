library ieee;
use work.wishbone_pkg.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sdb_meta_pkg is

  ------------------------------------------------------------------------------
  -- Meta-information sdb records
  ------------------------------------------------------------------------------

 -- Top module repository url
  constant c_sdb_repo_url : t_sdb_repo_url := (
    -- url (string, 63 char)
    repo_url => "https://github.com/lerwys/bpm-gw.git                           ");

  -- Synthesis informations
  constant c_sdb_synthesis : t_sdb_synthesis := (
    -- Top module name (string, 16 char)
    syn_module_name  => "dbe_bpm_dsp     ",
    -- Commit ID (hex string, 128-bit = 32 char)
    -- git log -1 --format="%H" | cut -c1-32
    syn_commit_id    => "7d2a6c272fe486df50e1d9b155e76bb0",
    -- Synthesis tool name (string, 8 char)
    syn_tool_name    => "VIVADO  ",
    -- Synthesis tool version (bcd encoded, 32-bit)
    syn_tool_version => x"00020144",
    -- Synthesis date (bcd encoded, 32-bit)
    syn_date         => x"20150303",    -- yyyymmdd
    -- Synthesised by (string, 15 char)
    syn_username     => "lerwys         ");

  -- Integration record
  constant c_sdb_integration : t_sdb_integration := (
    product     => (
      vendor_id => x"1000000000001215",  -- LNLS
      device_id => x"890b17be",          -- echo "bpm-gw" | md5sum | cut -c1-8
      version   => x"00010000",          -- bcd encoded, [31:16] = major, [15:0] = minor
      date      => x"20150303",          -- yyyymmdd
      name      => "bpm-gw             "));

end sdb_meta_pkg;

