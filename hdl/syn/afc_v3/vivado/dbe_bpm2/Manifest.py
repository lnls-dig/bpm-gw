target = "xilinx"
action = "synthesis"

syn_device = "xc7a200t"
syn_grade = "-2"
syn_package = "ffg1156"
syn_top = "dbe_bpm2"
syn_project = "dbe_bpm2"
syn_tool = "vivado"
syn_properties = [
    ["steps.synth_design.args.more options", "-verbose"],
    ["steps.opt_design.args.verbose", "1"],
    ["steps.opt_design.args.directive", "Explore"],
    ["steps.place_design.args.directive", "Explore"],
    ["steps.place_design.args.more options", "-verbose"],
    ["steps.phys_opt_design.args.directive", "AlternateFlowWithRetiming"],
    ["steps.phys_opt_design.args.more options", "-verbose"],
    ["steps.route_design.args.directive", "Explore"],
    ["steps.route_design.args.more options", "-verbose"],
    ["steps.post_route_phys_opt_design.args.directive", "AddRetime"],
    ["steps.post_route_phys_opt_design.args.more options", "-verbose"],
    ["steps.write_bitstream.args.verbose", "1"]]

import os
import sys
if os.path.isfile("synthesis_descriptor_pkg.vhd"):
    files = ["synthesis_descriptor_pkg.vhd"];
else:
    sys.exit("Generate the SDB descriptor before using HDLMake (./build_synthesis_sdb.sh)")

machine_pkg = "uvx_250M";

modules = { "local" : [ "../../../../top/afc_v3/vivado/dbe_bpm2" ] };
