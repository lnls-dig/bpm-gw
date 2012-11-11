#!/bin/bash

wbgen2 -V wb_fmc516_port.vhd -H record -p xfmc516_regs_pkg.vhd -K ../../../sim/regs/xfmc516_regs.vh -s struct -C wb_fmc516.h -D doc/xfmc516_regs_wb.html xfmc516.wb
