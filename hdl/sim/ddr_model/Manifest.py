#don't specify parameters file, because it's only included, not compiled
files = ["wiredly.v"]

if (target == "xilinx" and syn_device[0:4].upper()=="XC7A"): # Artix7
    modules = { "local" : ["artix7"] }
    print("[sim:ddr_model] Using FPGA family: " + syn_device)
elif (target == "xilinx" and syn_device[0:4].upper()=="XC7K"): # Kintex7
    modules = { "local" : ["kintex7"] }
    print("[sim:ddr_model] Using FPGA family: " + syn_device)
else:
    print("[sim:ddr_model] Unsupported FPGA family: " + syn_device)
