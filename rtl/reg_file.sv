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

  output logic         i2c_data_en_o,
  output logic [15:0]  i2c_data_o

  //output logic [7:0] debug_data_o
);
//------------------------------------------------------------------------------------------------------------
logic [7:0] reg_data;
logic [7:0] reg_addr;

/*NCO enable resources*/
logic fsm_ctrl_run_en;
logic nco_en;

/*Frequency step resources*/
logic fsm_ctrl_freq_step_l, fsm_ctrl_freq_step_h;
logic [7:0] freq_step_l, freq_step_h;
logic freq_reg_shadow_en;
logic [15:0] freq_reg_shadow;
logic freq_en;

/*DAC control data resources*/
logic fsm_ctrl_i2c_data_l, fsm_ctrl_i2c_data_h;
logic [7:0] i2c_data_l, i2c_data_h;
logic i2c_reg_shadow_en;
logic [15:0] i2c_reg_shadow;
logic i2c_en;
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
  .dout_o         (nco_en          )
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
assign fsm_ctrl_freq_step_h = (reg_wr_i ) & (reg_addr  ==  8'd2);
reg_array_entity i_fsm_ctrl_freq_step_h(
  .clk     (clk                   ),
  .rst_n   (rst_n                 ),
  .din_i   (reg_data              ),
  .set_i   (fsm_ctrl_freq_step_h  ),
  .en_o    (freq_reg_shadow_en    ),
  .dout_o  (freq_step_h           )
);

//Frequency Register Output 
reg_shadow_entity i_freq_reg_shadow(
  .clk      (clk                ),
  .rst_n    (rst_n              ),
  .din_l_i  (freq_step_l        ),
  .din_h_i  (freq_step_h        ),
  .set_i    (freq_reg_shadow_en ),
  .en_o     (freq_en            ),
  .dout_o   (freq_reg_shadow    )
);
assign tunning_word_o = freq_reg_shadow[10:0];
//------------------------------------------------------------------------------------------------------------
//DAC low byte set: 0x03 address
reg y;
assign fsm_ctrl_i2c_data_l = (reg_wr_i ) & (reg_addr  ==  8'd3);
reg_array_entity i_fsm_ctrl_i2c_data_l(
  .clk     (clk                 ),
  .rst_n   (rst_n               ),
  .din_i   (reg_data            ),
  .set_i   (fsm_ctrl_i2c_data_l ),
  .en_o    (y                   ),
  .dout_o  (i2c_data_l          )
);

//DAC high byte set: 0x04 address
assign fsm_ctrl_i2c_data_h = (reg_wr_i ) & (reg_addr  ==  8'd4);
reg_array_entity i_fsm_ctrl_i2c_data_h(
  .clk     (clk                 ),
  .rst_n   (rst_n               ),
  .din_i   (reg_data            ),
  .set_i   (fsm_ctrl_i2c_data_h ),
  .en_o    (i2c_reg_shadow_en   ),
  .dout_o  (i2c_data_h          )
);

//DAC Register Output 
reg_shadow_entity i_i2c_reg_shadow(
  .clk      (clk                ),
  .rst_n    (rst_n              ),
  .din_l_i  (i2c_data_l         ),
  .din_h_i  (i2c_data_h         ),
  .set_i    (i2c_reg_shadow_en  ),

  .en_o     (i2c_en             ),
  .dout_o   (i2c_reg_shadow     )
);

assign i2c_data_o = i2c_reg_shadow;
assign i2c_data_en_o = i2c_en;
//------------------------------------------------------------------------------------------------------------
//Data reading
assign reg_data_o =   ((reg_rd_i)  &&  (reg_addr == 8'd0)) ? {7'd0,nco_en}      : 
                      ((reg_rd_i)  &&  (reg_addr == 8'd1)) ? freq_step_l        :
                      ((reg_rd_i)  &&  (reg_addr == 8'd2)) ? freq_step_h        :
                      ((reg_rd_i)  &&  (reg_addr == 8'd3)) ? i2c_data_l         :
                      ((reg_rd_i)  &&  (reg_addr == 8'd4)) ? i2c_data_h         :
                                                                                  0;
//------------------------------------------------------------------------------------------------------------
endmodule
`default_nettype wire