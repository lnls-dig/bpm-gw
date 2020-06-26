action = "simulation"
target = "xilinx"
syn_device = "xc7a200t"
sim_tool = "modelsim"
top_module = "mixer_bench"

modules = {"local" : ["../../", "../../ip_cores/general-cores/","../../sim/test_pkg/"]}

files = ["mixer_bench.vhd"]
