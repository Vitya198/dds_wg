//////////////////////////////////////////////////////////
//        Digital Interface: DSP, 16 bit, slave mode    //
//		WM_i2c_data(15 downto 9)<="0000111";            //
//		WM_i2c_data(8 downto 0)<="000010011";	        //
//                                                      //
//        HEADPHONE VOLUME                              //
//		WM_i2c_data(15 downto 9)<="0000010";            //
//		WM_i2c_data(8 downto 0)<="101111001";           //
//                                                      //
//        ADC of, DAC on, Linout ON, Power ON           //
//		WM_i2c_data(15 downto 9)<="0000110";            //
//		WM_i2c_data(8 downto 0)<="000000111";           //
//                                                      //
//        USB mode                                      //
//		WM_i2c_data(15 downto 9)<="0001000";            //
//		WM_i2c_data(8 downto 0)<="000000001";           //
//                                                      //
//      activ interface                                 //
//		WM_i2c_data(15 downto 9)<="0001001";            //
//		WM_i2c_data(8 downto 0)<="111111111";           //
//                                                      //
//        Enable DAC to LINOUT                          //
//		WM_i2c_data(15 downto 9)<="0000100";            //
//		WM_i2c_data(8 downto 0)<="000010010";           //
//                                                      //
//        remove mute DAC                               //
//		WM_i2c_data(15 downto 9)<="0000101";            //
//		WM_i2c_data(8 downto 0)<="000000000";           //
//                                                      //
//		   reset                                        //
//		WM_i2c_data(15 downto 9)<="0001111";            //
//		WM_i2c_data(8 downto 0)<="000000000";           //
//                                                      //
//////////////////////////////////////////////////////////

module dds_dig_core(

    /*-----------WM873 pins-----------*/
    output logic AUD_BLCK,
    output logic AUD_XCL,
    input  logic AUD_ADClRCK,
    output logic AUD_DACLKCR,
    output logic AUT_DACDAT,


    /*-----------Control pins-----------*/
    input  wire         clk,
    input  wire         raw_reset_n,

    input  wire         rx_i,
    output logic        tx_o,


    output logic        FPGA_I2C_SCLK,
    output logic tri    FPGA_I2C_SDAT,

    output logic [9:0]  debug_o_1  //led
);

/*set baudrate*/ 
parameter                fclk      =  50000000; //50MHz
parameter                baudrate  =  9600;    
localparam logic [15:0]  divisor   =  fclk/baudrate/16; //parameter for uart

//-------------------------------------------------------------------------------------------------
/*Resources*/
//-------------------------------------------------------------------------------------------------

/*reset sync resources*/
logic as_reset_n;
logic ff1, ff2;

/*UART resources*/
logic rx_done, tx_done;  


/*protocol decoder resources*/
logic [7:0]  rx_data; 
logic [7:0]  tx_data;    
logic [7:0]  reg_addr;
logic [7:0]  reg_data; 

logic tx_wr;             //írás engedélyezés a pc-re (uarton)
logic rd_en,   wr_en;    //olvasás/írás a regiszter fájlból/fájlba 


/*register file resources*/
logic [7:0]  reg_file_data;   


/*nco resources*/
logic        nco_en;
logic [10:0] tunning_word;  
logic [7:0]  nco_out; 


//WM_DAC 
logic [2:0]  bitprsc; 
logic [31:0] aud_mono;
logic [17:0] read_addr; //240254:=0;
logic [17:0] ROM_ADDR;
logic [15:0] ROM_OUT; 
logic clock_12pll;
logic WM_i2c_busy;
logic WM_i2c_done;
logic WM_i2c_send_flag;
logic [15:0] WM_i2c_data;
logic DA_CLR;

//-------------------------------------------------------------------------------------------------
//Asyncron reset (as_reset_n)
//-------------------------------------------------------------------------------------------------

always @(posedge clk, negedge raw_reset_n) begin
    if(!raw_reset_n) begin
        ff1 <=  0;
        ff2 <=  0;
    end
    else begin
        ff1 <=  1;
        ff2 <=  ff1;
    end   
end
assign as_reset_n  =  ff2;

//-------------------------------------------------------------------------------------------------
//UART Transceiver
//-------------------------------------------------------------------------------------------------
reg_transceiver i_reg_transcevier(
    .sys_clk    (clk          ),
    .sys_rst    (!as_reset_n  ),
    .divisor    (divisor      ),
    .reg_rx    (rx_i         ),
    .reg_tx    (tx_o         ),

    .rx_done    (rx_done      ),   
    .rx_data    (rx_data      ),

    .tx_done    (tx_done      ),
    .tx_data    (tx_data      ), 
    .tx_wr      (tx_wr        )
);

//-------------------------------------------------------------------------------------------------
//Protocol decoder
//-------------------------------------------------------------------------------------------------
protocol_decoder i_protocol_decoder(    
    .clk         (clk         ),
    .rst_n       (as_reset_n  ),

    /*UART oldal*/
    .rx_done_i   (rx_done     ),
    .tx_done_i   (tx_done     ),
    .rx_data_i   (rx_data     ),

    /*rendszer oldal*/
    .internal_data_i(reg_file_data),

    .tx_wr_o     (tx_wr       ),
    .tx_data_o   (tx_data     ),

    .wr_en_o     (wr_en       ),
    .rd_en_o     (rd_en       ),
    .reg_addr_o  (reg_addr    ),
    .reg_data_o  (reg_data    ) 
);

//-------------------------------------------------------------------------------------------------
//Register File
//-------------------------------------------------------------------------------------------------
reg_file i_reg_file(
    .clk              (clk           ),
    .rst_n            (as_reset_n    ),
    
    /*UART Protocol Decoder*/
    .reg_wr_i        (wr_en         ),
    .reg_rd_i        (rd_en         ),
    .reg_addr_i      (reg_addr      ),
    .reg_data_i      (reg_data      ),
    .reg_data_o       (reg_file_data ),

    /*NCO control*/
    .nco_en_o         (nco_en       ),
    .tunning_word_o   (tunning_word )
);

//-------------------------------------------------------------------------------------------------
//Numerically Controlled Oscillator (8 bit data out)
//-------------------------------------------------------------------------------------------------
nco i_nco(
    .clk            (clk            ),
    .rst_n          (as_reset_n     ),  
    
    //input
    .nco_en_i       (nco_en         ),
    .tunning_word_i (tunning_word   ),
    
    //output     
    .nco_data_out   (nco_out        ),
    .sampling_en    (start          )
);

assign debug_out = nco_out;
assign logic [15:0] scale_data_out = {nco_out,8'd0};


//-------------------------------------------------------------------------------------------------
/*WM Control Interface*/
//-------------------------------------------------------------------------------------------------
wm_i2c_master i_wm_i2c_master(
    
);

//-------------------------------------------------------------------------------------------------
/*WM DAC Interface*/
//-------------------------------------------------------------------------------------------------

wm_data_master i_wm_data_master(

);




endmodule