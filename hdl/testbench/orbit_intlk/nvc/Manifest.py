action = "simulation"
sim_tool = "nvc"
top_module = "xwb_orbit_intlk_tb"
target = "xilinx"
syn_device = "xc7a200t"
machine_pkg = "sirius_sr_250M"

modules = {"local" : ["../"]}

nvc_opt = "--std=2008"
nvc_elab_opt = "--no-collapse"

sim_post_cmd = "nvc -r --dump-arrays --exit-severity=error %s --wave=%s.fst --format=fst"%(top_module, top_module)
