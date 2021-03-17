#!/bin/bash

# Exit on error
set -e
# Check for uninitialized variables
set -u

# Maximum of 16 chars
SYNTH_INFO_PROJECT="bpm-gw-bo-sirius"
SYNTH_INFO_TOOL="VIVADO"
SYNTH_INFO_VER=$(vivado -version | head -n 1 | cut -d' ' -f2 | cut -d 'v' -f2)

SYNTH_INFO_COMMAND="../../gen_sdbsyn.py --project ${SYNTH_INFO_PROJECT} --tool ${SYNTH_INFO_TOOL} --ver ${SYNTH_INFO_VER}"

# Generate synthesis file
echo $SYNTH_INFO_COMMAND
eval $SYNTH_INFO_COMMAND
