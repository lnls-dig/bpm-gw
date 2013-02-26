target = "xilinx"
action = "synthesis"

syn_device = "xc6vlx240t"
syn_grade = "-1"
syn_package = "ff1156"
syn_top = "dbe_bpm_fmc516"
#syn_top = "xwb_fmc516"
syn_project = "dbe_bpm_fmc516.xise"
#syn_project = "wb_fmc516.xise"

modules = { "local" : [ "../../top/ml_605/dbe_bpm_fmc516" ] };
#modules = { "local" : [ "../../modules/custom_wishbone/wb_fmc516",
#						"../../"] };
