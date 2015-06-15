def __dirs():
	dirs = []

	if (target == "xilinx" and syn_device[0:4].upper()=="XC6V"):
		dirs.extend(["virtex6/chipscope", "virtex6/ip_cores"]);
	elif (target == "xilinx" and syn_device[0:4].upper()=="XC7A"):
		dirs.extend(["artix7/chipscope", "artix7/ip_cores"]);
	#else: #add paltform here and generate the corresponding ip cores
	return dirs

modules = {
    "local" : __dirs()
           }
