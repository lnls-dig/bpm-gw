target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-1"
syn_package = "ffg1156"
syn_top = "dbe_bpm2"
syn_project = "dbe_bpm2"
syn_tool = "vivado"

files = ["synthesis_descriptor_pkg.vhd"];

# FIXME. We are using the 130M DSP CORES, as we will test it with
# 130 MHz
machine_pkg = "uvx_130M";

modules = { "local" : [ "../../../../top/afc_v3/vivado/dbe_bpm2" ] };

