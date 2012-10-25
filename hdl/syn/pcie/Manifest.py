target = "xilinx"
action = "synthesis"

syn_device = "xc7k325t"
syn_grade = "-2"
syn_package = "ffg900"
syn_top = "bpm_pcie_k7"
syn_project = "bpm_pcie_k7.xise"

modules = {"local" : ["../../top/pcie",
                      "../../modules/pcie",
                      "../../ip_cores/pcie/7k325ffg900"]}

files = "xc7k325ffg900.ucf"
