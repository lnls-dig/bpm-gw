filenames = ['pcie_core.xdc', 'ddr_core.xdc', 'dbe_bpm2.xdc']
with open('dbe_bpm2_gen.xdc', 'w') as outfile:
    for fname in filenames:
        with open(fname) as infile:
            outfile.write(infile.read())

files = [ "dbe_bpm2.xcf",
          "dbe_bpm2_gen.xdc",
          "dbe_bpm2.vhd"
         ];

modules = { "local" :
             ["../../../..",
              "../dbe_bpm_gen"
             ]
          };

