#!/bin/bash

COMMAND="(time make; date) 2>&1 | tee make_output &"

echo $COMMAND
eval $COMMAND
