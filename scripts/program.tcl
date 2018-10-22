# command line args
set bitfile [lindex $argv 0]

open_hw
connect_hw_server -url localhost:3121
current_hw_target [get_hw_targets *Digilent*]
set_property PARAM.FREQUENCY 30000000 [get_hw_targets *Digilent*]
open_hw_target
current_hw_device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices] 0]
set_property PROGRAM.FILE $bitfile [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
