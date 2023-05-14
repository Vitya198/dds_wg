# Reading C:/altera/13.0sp1/modelsim_ase/tcl/vsim/pref.tcl 
# vsim +nowarnTSCALE -Lf test_lib -Lf modules_lib -gui -t 1ps -novopt test_lib.dig_core_tb 
# Loading sv_std.std
# Loading test_lib.dig_core_tb
# Loading modules_lib.uart_transceiver
# Loading modules_lib.dig_core
# Loading modules_lib.reg_fsm
# Loading modules_lib.reg_file
# Loading modules_lib.reg_entity
# Loading modules_lib.reg_array_entity
# Loading modules_lib.reg_shadow_entity
# Loading modules_lib.main_fsm
# Loading modules_lib.nco
# Loading modules_lib.nco_rom
# ** Warning: (vsim-3017) ../../rtl/dig_core.sv(80): [TFMPC] - Too few port connections. Expected 11, found 10.
# 
#         Region: /dig_core_tb/dut/i_reg_file
# ** Warning: (vsim-3015) ../../rtl/dig_core.sv(80): [PCDPC] - Port size (8 or 8) does not match connection size (1) for port 'internal_data_i'. The port definition is at: ../../rtl/reg_file.sv(10).
# 
#         Region: /dig_core_tb/dut/i_reg_file
# ** Warning: (vsim-3015) ../../rtl/dig_core.sv(80): [PCDPC] - Port size (17 or 17) does not match connection size (11) for port 'frequency_o'. The port definition is at: ../../rtl/reg_file.sv(19).
# 
#         Region: /dig_core_tb/dut/i_reg_file
# ** Warning: (vsim-3722) ../../rtl/dig_core.sv(80): [TFMPC] - Missing connection for port 'internal_addr_i'.
# 
add wave -position end  sim:/dig_core_tb/clk_i
add wave -position end  sim:/dig_core_tb/rst_n_i
add wave -position end  sim:/dig_core_tb/tx_wr_i
add wave -position end  sim:/dig_core_tb/tx_data_i
add wave -position end  sim:/dig_core_tb/rx
add wave -position end  sim:/dig_core_tb/tx_done_o
add wave -position end  sim:/dig_core_tb/rx_done_o
add wave -position end  sim:/dig_core_tb/rx_data_o
add wave -position end  sim:/dig_core_tb/tx
add wave -position end  sim:/dig_core_tb/dig_out
add wave -position end  sim:/dig_core_tb/dut/i_reg_file/freq_step_l
add wave -position end  sim:/dig_core_tb/dut/i_reg_file/freq_step_h
add wave -position end  sim:/dig_core_tb/dut/i_reg_file/frequency_o
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_run_en_i
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_load_en_i
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_freq_step_i
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_we_o
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_en_o
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/fsm_set_o
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_we_d
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_we_q
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_en_d
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/nco_en_q
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/state
add wave -position end  sim:/dig_core_tb/dut/i_main_fsm/next_state
add wave -position end  sim:/dig_core_tb/dut/i_nco/freq_step_i
add wave -position end  sim:/dig_core_tb/dut/i_nco/data_i
add wave -position end  sim:/dig_core_tb/dut/i_nco/ready_d
add wave -position end  sim:/dig_core_tb/dut/i_nco/ready_q
add wave -position end  sim:/dig_core_tb/dut/i_nco/data_wr_q
add wave -position end  sim:/dig_core_tb/dut/i_nco/state
add wave -position end  sim:/dig_core_tb/dut/i_nco/next_state
add wave -position end  sim:/dig_core_tb/dut/i_nco/we_i
add wave -position end  sim:/dig_core_tb/dut/i_nco/sys_en
add wave -position end  sim:/dig_core_tb/dut/i_nco/data_o
run 30ms