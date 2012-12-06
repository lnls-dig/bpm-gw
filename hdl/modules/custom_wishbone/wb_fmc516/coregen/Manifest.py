# Select between synthesis or simulation components
if (action == "synthesis" ):
    if(target == "xilinx" and syn_device[0:4].upper()=="XC6V"):
        files = ["cdc_fifo.ngc"];
    else:
        print "WARNING: Device not supported for synthesis using the FMC516 core!"
elif (action == "simulation"):
    if (target == "xilinx"):
	    files = ["cdc_fifo.vhd"];
    else:
        print "WARNING: Device not supported for simulation using the FMC516 core!"




