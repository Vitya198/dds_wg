# Reading C:/altera/13.0sp1/modelsim_ase/tcl/vsim/pref.tcl 
# vsim +nowarnTSCALE -Lf test_lib -Lf fpga_mega_lib -Lf modules_lib -gui -t 1ps -novopt test_lib.nco_tb 
# Loading sv_std.std
# Loading test_lib.nco_tb
# Loading modules_lib.nco
# Loading modules_lib.nco_rom
add wave -position end  sim:/nco_tb/nco_dut/i_nco_rom/address
add wave -position end  sim:/nco_tb/nco_dut/i_nco_rom/data_out
run 2ms
run 10ms
