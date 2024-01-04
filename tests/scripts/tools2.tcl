#proc create_libs {} {
#  vlib ../fpga_mega_lib
#  vlib ../modules_lib
#  vlib ../test_lib
#  vmap fpga_mega_lib ../fpga_mega_lib
#  vmap modules_lib ../modules_lib
#  vmap test_lib ../test_lib
#} 

#proc comp_mega {} {
#    vlog -novopt -incr -work fpga_mega_lib ../fpga_mega/*.v 
#	}
#
#
#proc comp_modules {} {
#    vlog -novopt -incr -work modules_lib ../modules/*.v 
#	}	
#	
#proc comp_test {} {
#    vlog -novopt -incr -work test_lib ./*.v 
#	}
#
#
#proc comp_all {} {
#	comp_mega
#	comp_modules
#	comp_test
#}	
#
#
#proc load_sim {} {
#    vsim -novopt +nowarnTSCALE -t 1ps -Lf fpga_mega_lib -Lf modules_lib -Lf test_lib test_lib.RAM_tb		# RAM_tb: left entity
#	do ram1.do
#}
#
#proc run_sim  {} {
#  restart -f
#  run
#}
#
#proc del_libs  {} {
#  vmap -del fpga_mega_lib
#  vdel -all -lib ../fpga_mega_lib
#  vmap -del modules_lib
#  vdel -all -lib ../modules_lib
#  vmap -del test_lib
#  vdel -all -lib ../test_lib
#
#}



proc create_libs {} {
  vlib ../libs/modules_lib
  vlib ../libs/test_lib
  vmap modules_lib ../libs/modules_lib
  vmap test_lib ../libs/test_lib
} 


proc comp_modules {} {
    vlog -novopt -incr -work modules_lib ../../rtl/uart_transceiver.v
    vlog -novopt -incr -work modules_lib ../../rtl/dig_core.sv
    vlog -novopt -incr -work modules_lib ../../rtl/reg_fsm.sv

}	


proc comp_test {} {
    vlog -novopt -incr -work test_lib ../tests/dig_core_tb.sv
}


proc load_sim {} {
    vsim -novopt +nowarnTSCALE -t 1ps -Lf fpga_mega_lib -Lf test_lib -Lf modules_lib test_lib.dig_core_tb	
}

