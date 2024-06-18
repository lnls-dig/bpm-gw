puts "Setting all VHDL source files file_type to VHDL 2008"
set_property file_type {VHDL 2008} [get_files -filter {FILE_TYPE == VHDL}]
