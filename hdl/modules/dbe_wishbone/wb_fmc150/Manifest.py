files = ["wb_fmc150.vhd", "xwb_fmc150.vhd", "xfmc150_regs_pkg.vhd", "wb_fmc150_port.vhd"];

# Select between synthesis or simulation components
if (action == "synthesis" ):
    if(target == "xilinx" and syn_device[0:4].upper()=="XC6V"):
        modules = {"local" : [ "adc", "fmc150", "netlist"]}
    else:
        print ("WARNING: Device not supported for synthesis using the FMC150 core!")
elif (action == "simulation"):
    if (target == "xilinx"):
        modules = {"local" : [ "adc", "fmc150", "sim"]}
    else:
        print ("WARNING: Device not supported for simulation using the FMC150 core!")
else:
    print ("WARNING: Device not supported using the FMC150 core!")



