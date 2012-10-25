if (action == "synthesis"):

    modules = {"local" : ["pcie_core/source"]}

    files = ["bram_x64.ngc",
             "eb_fifo_counted_resized.ngc",
             "mbuf_128x72.ngc",
             "prime_FIFO_plain.ngc",
             "sfifo_15x128.ngc"]

else:

    files = ["bram_x64.vhd",
             "eb_fifo_counted_resized.vhd",
             "mbuf_128x72.vhd",
             "prime_FIFO_plain.vhd",
             "sfifo_15x128.vhd"]
