#!/bin/sh -f
bin_path="/opt/Questa/questasim/bin"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $bin_path/vsim -64 -do "do {questa_simulate.do}" -l simulate.log
