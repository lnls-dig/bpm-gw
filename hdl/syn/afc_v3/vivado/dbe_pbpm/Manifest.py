target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-1"
syn_package = "ffg1156"
syn_top = "dbe_pbpm"
syn_project = "dbe_pbpm"
syn_tool = "vivado"

files = ["synthesis_descriptor_pkg.vhd"];

# Doesn't matter got PBPM
machine_pkg = "uvx_250M"

modules = { "local" : [ "../../../../top/afc_v3/vivado/dbe_pbpm" ] };

