write_cfgmem -force -format mcs -size 32 -interface SPIx4 -loadbit {up 0x00000000 SYN_PROJECT.bit } -file SYN_PROJECT.mcs

open_hw
connect_hw_server -url "localhost:3121"
create_hw_target flash_afcv3
open_hw_target

create_hw_device -part xc7a200t
create_hw_cfgmem -hw_device [lindex [get_hw_devices] 0] -mem_dev  [lindex [get_cfgmem_parts {mt25ql256-spi-x1_x2_x4}] 0]

set_property PROGRAM.ADDRESS_RANGE  {use_file} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.FILES [list "SYN_PROJECT.mcs" ] [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0]]
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-up} [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.BLANK_CHECK  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.ERASE  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.CFG_PROGRAM  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.VERIFY  1 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
set_property PROGRAM.CHECKSUM  0 [ get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]

startgroup
if {![string equal \
        [get_property PROGRAM.HW_CFGMEM_TYPE [lindex [get_hw_devices] 0]] \
        [get_property MEM_TYPE [get_property CFGMEM_PART [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]]]
    ]} {
        create_hw_bitstream -hw_device [lindex [get_hw_devices] 0] [get_property \
            PROGRAM.HW_CFGMEM_BITFILE [ lindex [get_hw_devices] 0]];
            program_hw_devices [lindex [get_hw_devices] 0];
    };

program_hw_cfgmem -hw_cfgmem [get_property PROGRAM.HW_CFGMEM [lindex [get_hw_devices] 0 ]]
write_hw_svf "SYN_PROJECT.svf"

close_hw_target
exit
