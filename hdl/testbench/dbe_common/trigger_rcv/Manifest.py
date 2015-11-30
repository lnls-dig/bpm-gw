action = "simulation"
sim_tool = "modelsim"

top_module = "trigger_rcv_tb"
machine_pkg = "uvx_130M"


target = "xilinx"
syn_device = "xc7a200t"

modules = {"local" : ["../../../"]}

files = ["trigger_rcv_tb.vhd"]
