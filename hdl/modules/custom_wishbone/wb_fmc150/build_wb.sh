#!/bin/bash

wbgen2 -V wb_fmc150_port.vhd -H record -p xfmc150_regs_pkg.vhd -K ../../../sim/regs/xfmc150_regs_regs.vh -s struct -C xfmc150_regs_regs.h -D doc/xfmc150_regs_wb.html xfmc150.wb
