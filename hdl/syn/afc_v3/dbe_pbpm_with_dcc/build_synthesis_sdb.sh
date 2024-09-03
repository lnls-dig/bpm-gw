#!/bin/bash

# Exit on error
set -e
# Check for uninitialized variables
set -u

SYNTH_INFO_PROJECT="pbpm-gw"
SYNTH_INFO_TOOL="VIVADO"
SYNTH_INFO_VER=$(vivado -version | grep 'Vivado v[0-9]\{4\}.*' -m 1 | cut -d' ' -f2 | cut -d 'v' -f2)

SYNTH_INFO_COMMAND="../../gen_sdbsyn.py --project ${SYNTH_INFO_PROJECT} --tool ${SYNTH_INFO_TOOL} --ver ${SYNTH_INFO_VER}"

# Generate synthesis file
echo $SYNTH_INFO_COMMAND
eval $SYNTH_INFO_COMMAND
