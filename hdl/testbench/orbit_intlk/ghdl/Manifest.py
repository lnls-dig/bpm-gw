action = "simulation"
sim_tool = "ghdl"
top_module = "xwb_orbit_intlk_tb"
target = "xilinx"
syn_device = "xc7a200t"
machine_pkg = "sirius_sr_250M"

modules = {"local" : ["../"]}

ghdl_opt = "--std=08 -frelaxed -fsynopsys"

sim_post_cmd = "ghdl -r --std=08 %s --wave=%s.ghw"%(top_module, top_module)
