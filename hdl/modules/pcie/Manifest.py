files = ["bpm_pcie.vhd",
        ]

modules = {"git" : ["https://github.com/lnls-dig/general-cores.git"]}
# original version hosted at OHWR:
#        "git" : ["git://ohwr.org/hdl-core-lib/general-cores.git"]}

fetchto = "../../ip_cores"

files = ["common/", "pkgs/"]
