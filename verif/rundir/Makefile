all:  clean create_env create_libs comp_all run_gui 

create_env:
	mkdir -p ../libs/

create_libs:
	vlib ../libs/fpga_mega_lib
	vlib ../libs/modules_lib
	vlib ../libs/test_lib
	vmap fpga_mega_lib ../libs/fpga_mega_lib
	vmap modules_lib ../libs/modules_lib
	vmap test_lib ../libs/test_lib
	
clean:
	rm -rf ../libs

comp_modules:
	vlog -novopt -incr -work modules_lib ../../rtl/*.v
	vlog -novopt -incr -work modules_lib ../../rtl/*.sv

comp_fpga:
	vlog -novopt -incr -work fpga_mega_lib. ./../fpga/*.v

comp_test:
	vlog -novopt -incr -work test_lib ../tests/dig_core_tb.sv
#vlog -novopt -incr -work test_lib ../tests/wm_i2c_slave.sv
	vlog -novopt -incr -work test_lib ../tests/wm_i2s_slave.sv

comp_all: comp_modules comp_test 

run:
	vsim -novopt +nowarnTSCALE -t 1ps -Lf test_lib -Lf modules_lib test_lib.dig_core_tb

run_gui:
	vsim -novopt +nowarnTSCALE -t 1ps -gui -Lf test_lib  -Lf modules_lib test_lib.dig_core_tb

run_sanity:
	run clean

