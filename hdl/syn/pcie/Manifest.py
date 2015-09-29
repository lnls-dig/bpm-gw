target = "xilinx"
action = "synthesis"

syn_device = "xc7k325t" #KC705 evalboard
#syn_device = "xc7a200t" #Creotech PCB

syn_package = "ffg900" #KC705 evalboard
#syn_package = "ffg1156" #Creotech PCB

syn_grade = "-2" #-1 for AFC, -2 for AFCK, KC705
syn_top = "top"
syn_project = "bpm_pcie_k7"
#syn_project = "bpm_pcie_a7"
syn_tool = "vivado"

if (syn_device == "xc7k325t"):
    modules = {"local" : ["../../top/pcie",
                          "../../modules/pcie",
                          "../../ip_cores/pcie/7k325ffg900"]}

    files = "kc705.xdc"

if (syn_device == "xc7a200t"):
    modules = {"local" : ["../../top/pcie",
                          "../../modules/pcie",
                          "../../ip_cores/pcie/7a200ffg1156"]}

    files = "xc7a200tffg1156.xdc"

