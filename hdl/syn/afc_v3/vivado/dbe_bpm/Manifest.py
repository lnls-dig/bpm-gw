target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-2"
syn_package = "ffg1156"
syn_top = "dbe_bpm"
syn_project = "dbe_bpm"
syn_tool = "vivado"

files = ["synthesis_descriptor_pkg.vhd"];

machine_pkg = "uvx_130M"

modules = { "local" : [ "../../../../top/afc_v3/vivado/dbe_bpm" ] };

