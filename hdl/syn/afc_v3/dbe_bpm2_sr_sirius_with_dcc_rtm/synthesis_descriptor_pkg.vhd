-- package generated automatically by gen_sdbsyn.py script --
library ieee;
use ieee.std_logic_1164.all;
use work.wishbone_pkg.all;
package synthesis_descriptor_pkg is
constant c_sdb_repo_url : t_sdb_repo_url := (
repo_url => "git@github.com:lnls-dig/bpm-gw.git                             ");
constant c_sdb_top_syn_info : t_sdb_synthesis := (
syn_module_name => "bpm-gw-sr-siriu+",
syn_commit_id => "e0c154f5c490b0c4f581f34c00168742",
syn_tool_name => "VIVADO  ",
syn_tool_version => x"00020183",
syn_date => x"20210809",
syn_username => "LRusso         ");
constant c_sdb_CommsCtrlFPGA_syn_info : t_sdb_synthesis := (
syn_module_name => "CommsCtrlFPGA+  ",
syn_commit_id => "89426785dd8f58a4c8fad66eba97cb00",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");
constant c_sdb_afc_gw_syn_info : t_sdb_synthesis := (
syn_module_name => "afc-gw          ",
syn_commit_id => "59924aeeb39bc77e4814fb70dee3b0fb",
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
constant c_sdb_fofb_ctrl_gw_syn_info : t_sdb_synthesis := (
syn_module_name => "fofb-ctrl-gw    ",
syn_commit_id => "6c6ed2db53036e85a7c263c92016836a",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");
constant c_sdb_general_cores_syn_info : t_sdb_synthesis := (
syn_module_name => "general-cores+  ",
syn_commit_id => "20ade77c41bcb981276a3980858fc557",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");
constant c_sdb_infra_cores_syn_info : t_sdb_synthesis := (
syn_module_name => "infra-cores+    ",
syn_commit_id => "5f8bf2b43dc599aa98547571dd1f0dbb",
syn_tool_name => "        ",
syn_tool_version => x"00000000",
syn_date => x"00000000",
syn_username => "               ");

end package;