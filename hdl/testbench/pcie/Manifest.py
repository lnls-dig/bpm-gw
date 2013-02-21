import os as __os
import shutil as __shutil

def __import_verilog_lib():
    xilinx_dir = __os.getenv("XILINX");
    if xilinx_dir == None:
        print("XILINX variable not set")
        __os.exit(-1)

    if __os.path.isdir("work"):
        return

    verilog_lib = xilinx_dir + "/ISE/verilog/src/glbl.v"
    print("Copying " + verilog_lib)
    #__os.mkdir("work")
    __shutil.copy(verilog_lib, ".")


target = "xilinx"
action = "simulation"
vlog_opt = "-i ../../sim/pcie -d SIMULATION"
# ENABLE_GT has to be set until I figure out a way
# to force ISIM to work in PIPE simulation mode
vlog_opt += " -d ENABLE_GT"
# DDR model options
vlog_opt += " -i ../../sim/ddr_model -d x1Gb -d sg125 -d x8"
vsim_opt = "-testplusarg TESTNAME=tf64_pcie_axi"

__import_verilog_lib()
files = ["board.v",
         "glbl.v"]

#top_module = "tf64_pcie_axi"
modules = {"local" : ["../../modules/pcie",
                      "../../ip_cores/pcie/7k325ffg900",
                      "../../sim/pcie",
                      "../../sim/ddr_model",
                      "../../top/pcie"]}

