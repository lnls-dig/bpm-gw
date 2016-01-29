target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-1"
syn_package = "ffg1156"
syn_top = "dbe_bpm"
syn_project = "dbe_bpm.xise"
syn_tool = "ise"

machine_pkg = "uvx_130M"

modules = { "local" : [ "../../../top/afc_v3/dbe_bpm" ] };

