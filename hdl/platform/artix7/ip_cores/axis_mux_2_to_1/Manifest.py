if (action == "synthesis"):
    files = ["axis_mux_2_to_1.ngc"]
else:
    files = ["axis_mux_2_to_1.vhd"]
    modules = {"local" : ["hdl/verilog"]}

