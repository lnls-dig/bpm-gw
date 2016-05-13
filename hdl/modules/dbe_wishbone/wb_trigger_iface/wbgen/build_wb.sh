#!/bin/bash

wbgen2 -V wb_trigger_iface_regs.vhd -H record -p wb_trigger_iface_regs_pkg.vhd -K ../../../../sim/regs/wb_trigger_iface_regs.vh -s defines -C wb_trigger_iface_regs.h -f html -D doc/wb_trigger_iface_regs_wb.html wb_trigger_iface.wb
