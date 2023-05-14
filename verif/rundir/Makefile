#-------------------------------------------------------------------------------------#
test:  clean create_env create_libs comp_ram run

ram:  clean create_env create_libs comp_ram run_ram_gui 

rom: clean create_env create_libs comp_rom run_rom_gui 

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


#vlog -novopt -incr -work modules_lib ../../rtl/nco_rom.sv
	
comp_fpga:
	vlog -novopt -incr -work fpga_mega_lib ../../fpga/*.v

comp_test:
	vlog -novopt -incr -work test_lib ../tests/dig_core_tb.sv

comp_ram: comp_modules comp_test 

comp_rom: comp_modules comp_test


run:
	vsim -novopt +nowarnTSCALE -t 1ps -Lf test_lib -Lf modules_lib test_lib.dig_core_tb
	
run_ram_gui:
	vsim -novopt +nowarnTSCALE -t 1ps -gui -Lf test_lib  -Lf modules_lib test_lib.dig_core_tb

run_rom_gui:
	vsim -novopt +nowarnTSCALE -t 1ps -do test3.do -gui -Lf test_lib -Lf modules_lib test_lib.dig_core_tb

run_sanity:
	run clean

#-------------------------------------------------------------------------------------#
#just nco test
nco:	clean	create_env_nco	create_libs_nco	comp_all_nco	run_gui_nco 

create_env_nco:
	mkdir -p ../libs/

create_libs_nco:
	vlib ../libs/fpga_mega_lib
	vlib ../libs/modules_lib
	vlib ../libs/test_lib
	vmap fpga_mega_lib ../libs/fpga_mega_lib
	vmap modules_lib ../libs/modules_lib
	vmap test_lib ../libs/test_lib
	
clean:
	rm -rf ../libs

comp_modules_nco:
	vlog -novopt -incr -work modules_lib ../../rtl/nco.sv
	vlog -novopt -incr -work modules_lib ../../rtl/nco_rom.sv

	
comp_fpga_nco:
	vlog -novopt -incr -work fpga_mega_lib ../../fpga/*.v

comp_test_nco:
	vlog -novopt -incr -work test_lib ../tests/nco_tb.sv

comp_all_nco: comp_fpga_nco comp_modules_nco comp_test_nco 

	
run_gui_nco:
	vsim -novopt +nowarnTSCALE -t 1ps -gui -Lf test_lib -Lf fpga_mega_lib -Lf modules_lib test_lib.nco_tb


