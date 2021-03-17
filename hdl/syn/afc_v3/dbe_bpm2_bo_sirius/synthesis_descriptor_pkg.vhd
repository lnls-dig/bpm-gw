-- package generated automatically by gen_sdbsyn.py script --
library ieee;
use ieee.std_logic_1164.all;
use work.wishbone_pkg.all;
package synthesis_descriptor_pkg is
constant c_sdb_repo_url : t_sdb_repo_url := (
repo_url => "git@github.com:lnls-dig/bpm-gw.git                             ");
constant c_sdb_top_syn_info : t_sdb_synthesis := (
syn_module_name => "bpm-gw-bo-siriu+",
syn_commit_id => "5c336de9cf3ab31769ced168b27a205b",
syn_tool_name => "VIVADO  ",
syn_tool_version => x"00020183",
syn_date => x"20210317",
syn_username => "LRusso         ");
constant c_sdb_afc_gw_syn_info : t_sdb_synthesis := (
syn_module_name => "afc-gw          ",
syn_commit_id => "525406e8ad9d3fc43e45e9de4cd75e79",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");
constant c_sdb_dsp_cores_syn_info : t_sdb_synthesis := (
syn_module_name => "dsp-cores       ",
syn_commit_id => "9437895a59022b83ef574215f03c5b43",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");
constant c_sdb_general_cores_syn_info : t_sdb_synthesis := (
syn_module_name => "general-cores   ",
syn_commit_id => "20ade77c41bcb981276a3980858fc557",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");
constant c_sdb_infra_cores_syn_info : t_sdb_synthesis := (
syn_module_name => "infra-cores     ",
syn_commit_id => "8acae0c571d422468cdc5e2fb5bbc8a6",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");

end package;