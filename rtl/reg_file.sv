`default_nettype none
module reg_file (
  
  input  wire          clk,
  input  wire          rst_n,
  
  //UART Protocol Decoder
  input  wire          reg_wr_i,
  input  wire          reg_rd_i,
  input  wire  [7:0]   reg_addr_i,
  input  wire  [7:0]   reg_data_i,

  output logic [7:0]  reg_data_o,
  //nco_control
  output logic        nco_en_o,       
  output logic [10:0] tunning_word_o,       //16 bit (alsó 10 bit használatos)
  output logic [7:0]  dac_scale_o

  //output logic [7:0] debug_data_o
);
//------------------------------------------------------------------------------------------------------------
logic [7:0] reg_data;
logic [7:0] reg_addr;

logic fsm_ctrl_run_en;
logic nco_en;

logic fsm_ctrl_freq_step_l, fsm_ctrl_freq_step_h;
logic [7:0] freq_step_l, freq_step_h;

logic fsm_ctrl_dac_scale;
logic [7:0] dac_scale;

logic reg_shadow_en;
logic [15:0] reg_shadow;

/*-------------------------------------register logics-------------------------------------------------------*/
assign reg_data =  (reg_wr_i) ? reg_data_i :
                                              0;

assign reg_addr =  (reg_wr_i || reg_rd_i) ? reg_addr_i :
                                               0;

/*-------------------------------------register distributions------------------------------------------------*/
//NCO start 0x00 address
assign fsm_ctrl_run_en  = (reg_wr_i ) & (reg_addr  ==  8'd0);
reg_entity i_fsm_ctrl_run(
  .clk            (clk             ),
  .rst_n          (rst_n           ),
  .din_i          (reg_data[0]     ),
  .set_i          (fsm_ctrl_run_en ),
  .dout_o         (nco_en      )
);
assign nco_en_o = nco_en;
//------------------------------------------------------------------------------------------------------------

//Frequency low byte set: 0x01 address
reg x;
assign fsm_ctrl_freq_step_l = (reg_wr_i ) & (reg_addr  ==  8'd1);
reg_array_entity i_fsm_ctrl_freq_step_l(
  .clk     (clk                 ),
  .rst_n   (rst_n               ),
  .din_i   (reg_data            ),
  .set_i   (fsm_ctrl_freq_step_l),
  .en_o    (x                   ),
  .dout_o  (freq_step_l         )
);

//Frequency high byte set: 0x02 address
assign fsm_ctrl_freq_step_h = (reg_wr_i ) & (reg_addr  ==  8'd2) & x;
reg_array_entity i_fsm_ctrl_freq_step_h(
  .clk     (clk                 ),
  .rst_n   (rst_n               ),
  .din_i   (reg_data            ),
  .set_i   (fsm_ctrl_freq_step_h),
  .en_o    (reg_shadow_en       ),
  .dout_o  (freq_step_h         )
);

//Frequency Register Output 
reg_shadow_entity i_reg_shadow(
  .clk      (clk          ),
  .rst_n    (rst_n        ),
  .din_l_i  (freq_step_l  ),
  .din_h_i  (freq_step_h  ),
  .set_i    (reg_shadow_en),
  .dout_o   (reg_shadow   )
);
assign tunning_word_o = reg_shadow[10:0];
//------------------------------------------------------------------------------------------------------------

//dac scale set: 0x05 address
reg y;
assign fsm_ctrl_dac_scale = (reg_wr_i) & (reg_addr == 8'd3);
reg_array_entity i_fsm_ctrl_dac_scale(
  .clk     (clk                 ),
  .rst_n   (rst_n               ),
  .din_i   (reg_data            ),
  .set_i   (fsm_ctrl_dac_scale  ),
  .en_o    (y                   ),
  .dout_o  (dac_scale           )
);
assign dac_scale_o = dac_scale;

//------------------------------------------------------------------------------------------------------------
//Data reading
assign reg_data_o =  ((reg_rd_i)  &&  (reg_addr == 8'd0)) ? {7'd0,nco_en}      : 
                          ((reg_rd_i)  &&  (reg_addr == 8'd1)) ? freq_step_l        :
                          ((reg_rd_i)  &&  (reg_addr == 8'd2)) ? freq_step_h        :
                          ((reg_rd_i)  &&  (reg_addr == 8'd3)) ? dac_scale  :
                                                                                     0;
//------------------------------------------------------------------------------------------------------------
endmodule
`default_nettype wire