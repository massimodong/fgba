set_global_assignment -entity "uart16" -library "lib_uart16" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "uart16" -library "lib_uart16" -name IP_TOOL_VERSION "17.1"
set_global_assignment -entity "uart16" -library "lib_uart16" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_uart16" -name SPD_FILE [file join $::quartus(sip_path) "uart16.spd"]

set_global_assignment -library "lib_uart16" -name MISC_FILE [file join $::quartus(sip_path) "uart16_sim/uart16.vo"]
