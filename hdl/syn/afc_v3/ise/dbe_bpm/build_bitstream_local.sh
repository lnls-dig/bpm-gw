#!/bin/bash

COMMAND="(make clean; time make; date) 2>&1 | tee make_output &"

echo $COMMAND
eval $COMMAND
