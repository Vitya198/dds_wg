`default_nettype none
module dds_dig_core(
    input  wire         clk,
    input  wire         raw_reset_n,

    input  wire         rx_i,
    output logic        tx_o,

    input wire [7:0]    load_data_in,
    input wire [13:0]   load_addr_in,
    input wire          load_en_in,

    output logic [7:0]  dig_out,    //nco 
    output logic [9:0]  debug_o_1,  //led
    output logic [7:0]  debug_o_2   
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


/*DAC resources*/
logic [14:0] dac_out;
logic [7:0] dac_scale;



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
    .tunning_word_o   (tunning_word ),

    /*DAC control*/
    .dac_scale_o      (dac_scale     )
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

//-------------------------------------------------------------------------------------------------
//Digital-Analog Converter scaling logic (10 bit data out)
//-------------------------------------------------------------------------------------------------
dac i_dac(
    .nco_data_i (nco_out    ),
    .scale      (dac_scale  ),
    .dac_o      (dac_out    )
);

//-------------------------------------------------------------------------------------------------
//Output logics
//-------------------------------------------------------------------------------------------------
logic miso, mosi, sck, start, busy, new_data;
spi i_spi(
    .clk        (clk),
    .rst        (as_reset_n),
    
    //input
    .miso       (miso   ),
    .start      (start  ),
    .data_in    ('d0    ),

    //output
    .mosi       (mosi   ),
    .sck        (sck    ),
    .data_out   (dac_out),
    .busy       (busy   ),
    .new_data   (new_data)
);

//-------------------------------------------------------------------------------------------------
//Output logics
//-------------------------------------------------------------------------------------------------

assign dig_out      = mosi;
assign debug_o_1    = dac_out;
assign debug_o_2    = reg_data;


endmodule
`default_nettype wire  