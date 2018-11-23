onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/clk_50mhz
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/seq_pc
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/cpu_state
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/instr
add wave -noupdate -radix hexadecimal -childformat {{{/fgba_vlg_tst/i1/cpu/r[15]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[14]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[13]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[12]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[11]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[10]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[9]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[8]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[7]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[6]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[5]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[4]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[3]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[2]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[1]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/r[0]} -radix hexadecimal}} -expand -subitemconfig {{/fgba_vlg_tst/i1/cpu/r[15]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[14]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[13]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[12]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[11]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[10]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[9]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[8]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[7]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[6]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[5]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[4]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[3]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[2]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[1]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/r[0]} {-height 16 -radix hexadecimal}} /fgba_vlg_tst/i1/cpu/r
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/admode1
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/admode2
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mem_write
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mem_width
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mem_read
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mem_ok
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mem_data
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mem_addr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/update_cpsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/spsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/cpsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/m_user
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/m_undf
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/m_sys
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/m_supv
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/m_irq
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/m_fiq
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/m_abort
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/msr_new_spsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/msr_new_cpsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/msr_mask
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/msr_bytemask
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/shifter_operand
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/shifter_carry_out
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/shift_amount
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/saved_instr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/rotate_amount
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/rn
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/regf_bank6
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/regf_bank2
add wave -noupdate -radix hexadecimal -childformat {{{/fgba_vlg_tst/i1/cpu/regf[7]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/regf[6]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/regf[5]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/regf[4]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/regf[3]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/regf[2]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/regf[1]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/regf[0]} -radix hexadecimal}} -subitemconfig {{/fgba_vlg_tst/i1/cpu/regf[7]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/regf[6]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/regf[5]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/regf[4]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/regf[3]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/regf[2]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/regf[1]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/regf[0]} {-height 16 -radix hexadecimal}} /fgba_vlg_tst/i1/cpu/regf
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/reg_spsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/reg_pc
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/reg_cpsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/rd
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/opcode
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/offset
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/next_pc
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mode2_address_offset
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mode2_address
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mode2_W
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mode2_U
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mode2_P
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mode2_L
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/mode2_B
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/itype
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/immed_8
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/i_b
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_z
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_v
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_t
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_q
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_n
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_m
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_j
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_i
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_ge
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_f
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_e
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_c
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/f_a
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/data_load
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/cr_spsrw
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/cr_spsrd
add wave -noupdate -radix hexadecimal -childformat {{{/fgba_vlg_tst/i1/cpu/cr_regw[15]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[14]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[13]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[12]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[11]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[10]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[9]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[8]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[7]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[6]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[5]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[4]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[3]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[2]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[1]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regw[0]} -radix hexadecimal}} -subitemconfig {{/fgba_vlg_tst/i1/cpu/cr_regw[15]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[14]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[13]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[12]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[11]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[10]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[9]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[8]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[7]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[6]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[5]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[4]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[3]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[2]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[1]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regw[0]} {-height 16 -radix hexadecimal}} /fgba_vlg_tst/i1/cpu/cr_regw
add wave -noupdate -radix hexadecimal -childformat {{{/fgba_vlg_tst/i1/cpu/cr_regd[15]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[14]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[13]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[12]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[11]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[10]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[9]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[8]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[7]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[6]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[5]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[4]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[3]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[2]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[1]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/cr_regd[0]} -radix hexadecimal}} -subitemconfig {{/fgba_vlg_tst/i1/cpu/cr_regd[15]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[14]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[13]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[12]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[11]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[10]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[9]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[8]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[7]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[6]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[5]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[4]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[3]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[2]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[1]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/cr_regd[0]} {-height 16 -radix hexadecimal}} /fgba_vlg_tst/i1/cpu/cr_regd
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/cr_cpsrw
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/cr_cpsrd
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/cond_pass
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/cond
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/c_saved_instr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/c_regf_bank6
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/c_regf_bank2
add wave -noupdate -radix hexadecimal -childformat {{{/fgba_vlg_tst/i1/cpu/c_regf[7]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/c_regf[6]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/c_regf[5]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/c_regf[4]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/c_regf[3]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/c_regf[2]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/c_regf[1]} -radix hexadecimal} {{/fgba_vlg_tst/i1/cpu/c_regf[0]} -radix hexadecimal}} -subitemconfig {{/fgba_vlg_tst/i1/cpu/c_regf[7]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/c_regf[6]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/c_regf[5]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/c_regf[4]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/c_regf[3]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/c_regf[2]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/c_regf[1]} {-height 16 -radix hexadecimal} {/fgba_vlg_tst/i1/cpu/c_regf[0]} {-height 16 -radix hexadecimal}} /fgba_vlg_tst/i1/cpu/c_regf
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/c_reg_spsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/c_reg_pc
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/c_reg_cpsr
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/c_next_state
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/bank6id
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/alu_out
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/admode1_shifter_operand
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/admode1_shifter_carry_out
add wave -noupdate -radix hexadecimal /fgba_vlg_tst/i1/cpu/addr_load
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1062 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 343
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {480 ps} {1297 ps}
