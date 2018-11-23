transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/fgba.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/cpu_armv4t.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/alu.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/admode1_shifter.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/vram.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/vgac.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/graphic.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/admode2_shifter.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/cond_check.v}
vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/memory.v}

vlog -vlog01compat -work work +incdir+/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/simulation/modelsim {/home/massimo/W/nju/verilog/gba/fgba/quartus_proj/simulation/modelsim/fgba.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  fgba_vlg_tst

add wave *
view structure
view signals
run 1 ns
