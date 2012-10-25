target = "xilinx"
action = "simulation"

syn_project = "bpm_pcie_sim.xise"
#top_module = "tf64_pcie_axi"
modules = {"local" : ["../../modules/pcie",
                      "../../ip_cores/pcie/7k325ffg900"]}

files = "tf64_pcie_axi.v"
