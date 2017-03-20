-- package generated automatically by gen_sdbsyn.py script --
library ieee;
use ieee.std_logic_1164.all;
use work.wishbone_pkg.all;
package synthesis_descriptor_pkg is
constant c_sdb_repo_url : t_sdb_repo_url := (
repo_url => "https://github.com/lnls-dig/bpm-gw.git                         ");
constant c_sdb_top_syn_info : t_sdb_synthesis := (
syn_module_name => "bpm-gw+         ",
syn_commit_id => "960efc8c227ca92489e28547d5adb833",
syn_tool_name => "VIVADO  ",
syn_tool_version => x"00201521",
syn_date => x"20151208",
syn_username => "LRusso         ");
constant c_sdb_dsp_cores_syn_info : t_sdb_synthesis := (
syn_module_name => "dsp-cores+      ",
syn_commit_id => "befc6979e416ef28cc042b3030a8140b",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");
constant c_sdb_etherbone_core_syn_info : t_sdb_synthesis := (
syn_module_name => "etherbone-core  ",
syn_commit_id => "b29565ac63ca92987cd9a9a754b6add8",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");
constant c_sdb_general_cores_syn_info : t_sdb_synthesis := (
syn_module_name => "general-cores   ",
syn_commit_id => "cc53ef7f6c381ca1ce56355b2fd99246",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");

end package;