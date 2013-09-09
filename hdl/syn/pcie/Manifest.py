target = "xilinx"
action = "synthesis"

#syn_device = "xc7k325t" #KC705 evalboard
#syn_device = "xc7a200t" #Creotech PCB
syn_device = "xc6vlx240t" #ML605

#syn_package = "ffg900" #KC705 evalboard
#syn_package = "ffg1156" #Creotech PCB
syn_package = "ff1156" #ML605

syn_grade = "-1"
syn_top = "bpm_pcie_ml605"
syn_project = "bpm_pcie_ml605.xise"

if (syn_device == "xc7k325t"):
    modules = {"local" : ["../../top/pcie",
                          "../../modules/pcie",
                          "../../ip_cores/pcie/7k325ffg900"]}

    files = "xc7k325ffg900.ucf"

if (syn_device == "xc7a200t"):
    modules = {"local" : ["../../top/pcie",
                          "../../modules/pcie",
                          "../../ip_cores/pcie/7a200ffg1156"]}

    files = "xc7a200tffg1156.ucf"

if (syn_device == "xc6vlx240t"):
    modules = {"local" : ["../../top/pcie",
                          "../../modules/pcie",
                          "../../ip_cores/pcie/ml605"]}

    files = "ml605.ucf"
