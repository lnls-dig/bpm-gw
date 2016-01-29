import os as __os
import shutil as __shutil

target = "xilinx"
action = "simulation"
sim_tool = "modelsim"
top_module = "board"
#pickup correct top file
syn_device = "xc7k325t"
#syn_device = "xc7a200t"

vlog_opt = "+incdir+../../sim/pcie +define+SIMULATION +define+ENABLE_GT"
# DDR model options
vlog_opt += " +incdir+../../sim/ddr_model +define+x1Gb +define+sg125 +define+x8"
vlog_opt += " -incr $(XILINX_VIVADO)/data/verilog/src/glbl.v"
vsim_opt = "+TESTNAME=tf64_pcie_axi -t fs -novopt +notimingchecks -L unisims_ver -L secureip -L unimacro_ver glbl"

files = ["board.v"]

modules = {"local" : ["../../modules/pcie",
                      "../../ip_cores/pcie/7k325ffg900",
                      "../../sim/pcie",
                      "../../sim/ddr_model",
                      "../../top/pcie"]}

