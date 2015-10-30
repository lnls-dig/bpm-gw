#!/bin/bash

SYNTH_INFO_PROJECT="bpm-gw"
SYNTH_INFO_TOOL="VIVADO"
SYNTH_INFO_VER=$(vivado -version | head -n 1 | cut -d' ' -f2 | cut -d 'v' -f2)

SYNTH_INFO_COMMAND="../../../gen_sdbsyn.py --project ${SYNTH_INFO_PROJECT} --tool ${SYNTH_INFO_TOOL} --ver ${SYNTH_INFO_VER}"
COMMAND="(hdlmake; make cleanremote; time make remote; make sync; date) 2>&1 | tee make_output &"

# Generate synthesis file
echo $SYNTH_INFO_COMMAND
eval $SYNTH_INFO_COMMAND

echo $COMMAND
eval $COMMAND
