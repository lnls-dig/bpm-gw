filenames = ['pcie_core.xdc', 'ddr_core.xdc', 'dbe_pbpm.xdc']
with open('dbe_pbpm_gen.xdc', 'w') as outfile:
    for fname in filenames:
        with open(fname) as infile:
            outfile.write(infile.read())

files = [
    "dbe_pbpm.xcf",
    "dbe_pbpm_gen.xdc",
    "dbe_pbpm.vhd"
]

modules = {
    "local" : [
        "../../..",
        "../dbe_bpm_gen"
    ]
}
