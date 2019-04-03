filenames = ['pcie_core.xdc', 'ddr_core.xdc', 'dbe_bpm.xdc']
with open('dbe_bpm_gen.xdc', 'w') as outfile:
    for fname in filenames:
        with open(fname) as infile:
            outfile.write(infile.read())

files = [ "dbe_bpm.xcf",
          "dbe_bpm_gen.xdc",
          "dbe_bpm.vhd"
         ];

modules = { "local" :
             ["../../../..",
              "../dbe_bpm_gen"
             ]
          };

