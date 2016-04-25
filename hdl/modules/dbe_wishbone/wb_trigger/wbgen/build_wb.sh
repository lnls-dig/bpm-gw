#!/bin/bash

wbgen2 -V wb_slave_trigger.vhd -H record -p wb_slave_trigger_regs_pkg.vhd -K ../../../../sim/regs/wb_slave_trigger_regs.vh -s defines -C wb_slave_trigger_regs.h -f html -D doc/wb_slave_trigger_regs_wb.html wb_trigger.wb
