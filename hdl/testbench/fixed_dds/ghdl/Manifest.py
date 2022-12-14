action = "simulation"
sim_tool = "ghdl"
top_module = "fixed_dds_tb"
target = "xilinx"
syn_device = "xc7a200t"

machine_pkg = "sirius_sr_250M"

modules = {"local" : ["../"]}

ghdl_opt = "--std=08 -frelaxed -fsynopsys"

sim_post_cmd = "ghdl -r --std=08 %s --wave=%s.ghw --assert-level=error" % (top_module, top_module)
