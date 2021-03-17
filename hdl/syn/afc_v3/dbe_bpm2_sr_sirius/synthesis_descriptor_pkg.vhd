-- package generated automatically by gen_sdbsyn.py script --
library ieee;
use ieee.std_logic_1164.all;
use work.wishbone_pkg.all;
package synthesis_descriptor_pkg is
constant c_sdb_repo_url : t_sdb_repo_url := (
repo_url => "git@github.com:lnls-dig/bpm-gw.git                             ");
constant c_sdb_top_syn_info : t_sdb_synthesis := (
syn_module_name => "bpm-gw-sr-siriu+",
syn_commit_id => "d31c69aa4891b76635bcbee8178379c5",
syn_tool_name => "VIVADO  ",
syn_tool_version => x"00020183",
syn_date => x"20210204",
syn_username => "LRusso         ");
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
syn_commit_id => "834f32f0c2d1523c8dab68d85e7949c1",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");

end package;