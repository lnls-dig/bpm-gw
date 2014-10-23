#!/bin/bash

COMMAND="(hdlmake-devel; make cleanremote; time make remote; make sync; date) 2>&1 | tee make_output &"

echo $COMMAND
eval $COMMAND
