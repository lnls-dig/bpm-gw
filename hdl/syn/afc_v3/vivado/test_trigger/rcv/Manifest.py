target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-1"
syn_package = "ffg1156"
syn_top = "test_trigger_rcv"
syn_project = "test_trigger_rcv"
syn_tool = "vivado"

machine_pkg = "uvx_130M"

modules = { "local" : [ "../../../../../top/afc_v3/vivado/test_trigger/rcv/" ] };

