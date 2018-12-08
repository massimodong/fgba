set_global_assignment -entity "smult_add" -library "lib_smult_add" -name IP_TOOL_NAME "altera_mult_add"
set_global_assignment -entity "smult_add" -library "lib_smult_add" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "smult_add" -library "lib_smult_add" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_smult_add" -name SPD_FILE [file join $::quartus(sip_path) "smult_add.spd"]

set_global_assignment -library "lib_smult_add" -name MISC_FILE [file join $::quartus(sip_path) "smult_add_sim/smult_add.v"]
