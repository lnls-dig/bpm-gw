action = "simulation"
sim_tool = "modelsim"
top_module = "mixer_tb"
target = "xilinx"
syn_device = "xc7a200t"

vcom_opt = "-2008"

sim_post_cmd = "vsim -c -do run.do"

machine_pkg = "sirius_sr_250M"

modules = {"local" : ["../"]}
