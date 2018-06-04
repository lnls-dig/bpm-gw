target = "xilinx"
action = "synthesis"

language = "vhdl"

syn_device = "xc7a200t"
syn_grade = "-2"
syn_package = "ffg1156"
syn_top = "dbe_bpm"
syn_project = "dbe_bpm"
syn_tool = "vivado"
syn_properties = [
    ["steps.synth_design.args.more options", "-verbose"],
    ["steps.synth_design.args.retiming", "1"],
    ["steps.synth_design.args.assert", "1"],
    ["steps.opt_design.args.verbose", "1"],
    ["steps.opt_design.args.directive", "Explore"],
    ["steps.opt_design.is_enabled", "1"],
    ["steps.place_design.args.directive", "Explore"],
    ["steps.place_design.args.more options", "-verbose"],
    ["steps.phys_opt_design.args.directive", "AlternateFlowWithRetiming"],
    ["steps.phys_opt_design.args.more options", "-verbose"],
    ["steps.phys_opt_design.is_enabled", "1"],
    ["steps.route_design.args.directive", "Explore"],
    ["steps.route_design.args.more options", "-verbose"],
    ["steps.post_route_phys_opt_design.args.directive", "AddRetime"],
    ["steps.post_route_phys_opt_design.args.more options", "-verbose"],
    ["steps.post_route_phys_opt_design.is_enabled", "1"],
    ["steps.write_bitstream.args.verbose", "1"]]

import os
import sys
if os.path.isfile("synthesis_descriptor_pkg.vhd"):
    files = ["synthesis_descriptor_pkg.vhd"];
else:
    sys.exit("Generate the SDB descriptor before using HDLMake (./build_synthesis_sdb.sh)")

machine_pkg = "uvx_sr_130M"

modules = { "local" : [ "../../../../top/afc_v3/vivado/dbe_bpm" ] };
