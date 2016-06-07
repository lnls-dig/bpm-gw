#!/bin/bash

# Exit on error
set -e
# Check for uninitialized variables
set -u

PROJECT=dbe_bpm

# Build synthesis SDB
./build_synthesis_sdb.sh

# Generate .xpr project
vivado -mode batch -source ${PROJECT}.tcl

# Write tcl commands to generate bitstream
echo "open_project ${PROJECT}.xpr" > run.tcl
echo "reset_run synth_1" >> run.tcl
echo "reset_run impl_1" >> run.tcl
echo "launch_runs synth_1" >> run.tcl
echo "wait_on_run synth_1" >> run.tcl
echo "launch_runs impl_1" >> run.tcl
echo "wait_on_run impl_1" >> run.tcl
echo "launch_runs impl_1 -to_step write_bitstream" >> run.tcl
echo "wait_on_run impl_1" >> run.tcl
echo "exit" >> run.tcl

# Execute vivado toolchain and copy bitstream
COMMAND="(time vivado -mode tcl -source run.tcl; \
    cp ${PROJECT}.runs/impl_1/${PROJECT}.bit ${PROJECT}.bit; \
    date | tee make_output &)"

echo $COMMAND
eval $COMMAND
