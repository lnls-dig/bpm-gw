target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-1"
syn_package = "ffg1156"
syn_top = "dbe_bpm"
syn_project = "dbe_bpm.xise"
syn_tool = "ise"
syn_ise_version = "14.6"

modules = { "local" : [ "../../../top/afc_v1/dbe_bpm" ] };
