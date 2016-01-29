files = ["bpm_pcie.vhd",
        ]

modules = {"local" : ["common/", "pkgs/"],
        "git" : ["https://github.com/lerwys/general-cores.git"]}
# original version hosted at OHWR:
#        "git" : ["git://ohwr.org/hdl-core-lib/general-cores.git"]}

fetchto = "../../ip_cores"

