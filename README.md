# Sirius Beam Position Monitor FPGA firmware

## Project Folder Organization

```
*
|
|-- hdl:
|    |   HDL (Verilog/VHDL) cores related to the BPM.
|    |
|    |-- ip_cores:
|    |    |   Third party reusable modules, primarily Open hardware
|    |    |     modules (http://www.ohwr.org).
|    |    |
|    |    |-- etherbone-core:
|    |    |       Connects two Wishbone buses, either a true hardware bus
|    |    |         or emulated software bus, through Ethernet.
|    |    |-- general-cores (fork from original project):
|    |            General reusable modules.
|    |
|    |-- modules:
|    |    |   Modules specific to BPM hardware.
|    |    |
|    |    |-- custom_common:
|    |    |       Common (reusable) modules to BPM hardware and possibly
|    |    |         to other designs.
|    |    |-- custom_wishbone:
|    |            Wishbone modules to BPM hardware.
|    |
|    |-- platform:
|    |        Platform-specific code, such as Xilinx Chipscope wrappers.
|    |
|    |-- sim:
|    |        Generic simulation files, reusable Bus Functional Modules (BFMs),
|    |          constants definitions.
|    |
|    |-- syn:
|    |        Synthesis specific files (user constraints files and top design
|    |          specification).
|    |
|    |-- testbench:
|    |        Testbenches for modules and top level designs. May use modules
|    |          defined elsewhere (specific within the 'sim" directory).
|    |
|    |-- top:
|             Top design modules.
```

## Cloning Instructions

This repository makes use of git submodules, located at 'hdl/ip_cores' folder:
  hdl/ip_cores/general-cores
  hdl/ip_cores/etherbone-core
  hdl/ip_cores/dsp-cores
  hdl/ip_cores/infra-cores

To clone the whole repository use the following command:

    git clone --recursive git://github.com/lnls-dig/bpm-gw.git (read only)

  or

    git clone --recursive git@github.com:lnls-dig/bpm-gw.git (read+write)

For older versions of Git (<1.6.5), use the following:

    git clone git://github.com/lnls-dig/bpm-gw.git

or

    git clone git@github.com:lnls-dig/bpm-gw.git

    git submodule init
    git submodule update

To update each submodule within this project use:

    git submodule foreach git rebase origin master

## Simulation Instructions

Go to a testbench directory. It must have a top manifest file:

    cd hdl/testbench/path_to_testbench

Run the following commands. You must have hdlmake command available
in your PATH environment variable.

Create the simualation makefile

    hdlmake

Compile the project

    make

Execute the simulation with GUI and aditional commands

    vsim -do run.do &

## Synthesis Instructions

Go to a syn directory. It must have a synthesis manifest file:

    cd hdl/syn/path_to_syn_design

Run the following commands. You must have hdlmake command available
in your PATH environment variable.

    ./build_bitstream_local.sh

## Known Issues

wb_fmc150/sim/: This folder containts behavioral simulation models
  for memories (ROMs). However, the xilinx initialization file (.mif)
  paths are absolute to a specific machine! You either have to change
  the path to match your machine or figure a way to specifies a relative
  path (specifiying only the name of the mif file does not work as the
  simulator is not called within this folder). Try a relative path based
  on the simulation folder.
