#!/bin/bash

wbgen2 -V wb_orbit_intlk_regs.vhd -H record -p wb_orbit_intlk_regs_pkg.vhd -K ../../../sim/regs/wb_orbit_intlk_regs.vh -s defines -C orbit_intlk_regs.h -f html -D doc/orbit_intlk_regs_wb.html wb_orbit_intlk_regs.wb
