#!/bin/bash

wbgen2 -V acq_core_regs.vhd -H record -p acq_core_regs_pkg.vhd -K ../../../../sim/regs/wb_acq_core_regs.vh -s struct -C wb_acq_core_regs.h -f html -D doc/wb_acq_core.html acq_core.wb
