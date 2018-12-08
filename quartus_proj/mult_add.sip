set_global_assignment -entity "mult_add" -library "lib_mult_add" -name IP_TOOL_NAME "altera_mult_add"
set_global_assignment -entity "mult_add" -library "lib_mult_add" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "mult_add" -library "lib_mult_add" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_mult_add" -name SPD_FILE [file join $::quartus(sip_path) "mult_add.spd"]

set_global_assignment -library "lib_mult_add" -name MISC_FILE [file join $::quartus(sip_path) "mult_add_sim/mult_add.v"]
