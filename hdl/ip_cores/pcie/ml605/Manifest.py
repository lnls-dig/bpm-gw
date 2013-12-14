if (action == "synthesis"):

    files = ["bram_x64.ngc",
             "mbuf_128x72.ngc",
             "prime_FIFO_plain.ngc",
             "sfifo_15x128.ngc"]

else:

    files = ["bram_x64.vhd",
             "mbuf_128x72.vhd",
             "prime_FIFO_plain.vhd",
             "sfifo_15x128.vhd"]

modules = {"local" : ["pcie_core/source",
                      "ddr_v6/user_design"]}
