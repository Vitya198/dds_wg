
`default_nettype none
module dds_dig_core#(
    parameter ADDR_WIDTH           =  10, 
    parameter DATA_WIDTH           =  8,
    parameter DEPTH                =  1024,  
    parameter SYSTEM_CLOCK         =  50000000, 
    parameter SAMPLE_FREQ          =  96000,
    parameter baudrate             =  9600
)(
    /*-----------WM873 pins-----------*/
    //I2C interface for control
    output logic        FPGA_I2C_SCLK,
    inout  tri          FPGA_I2C_SDAT,    //tri state 

    //I2S interface for data
    output logic        FPGA_I2S_BCLK,
    output logic        FPGA_I2S_DACLRC,
    output logic        FPGA_I2S_DACDAT,

    //output logic        FPGA_I2S_ADCLRC,
    //input  wire         FPGA_I2S_ADC_DAT,

    /*-----------Control pins-----------*/
    input  wire         clk, 
    input  wire         raw_reset_n,

    //UART Interface
    input  wire         rx_i,
    output logic        tx_o,
    
    //debug interface
    output logic [9:0]  debug_out  //led
);

wire i2c_sdat;
assign FPGA_I2C_SDAT = i2c_sdat;

/*set baudrate*/    
localparam logic [15:0]  divisor   =  SYSTEM_CLOCK/baudrate/16; //parameter for uart
/*set sampling frequency*/
localparam STROBE_MAX = SYSTEM_CLOCK/SAMPLE_FREQ;
/*set wm873 write address*/
localparam logic [7:0] wm_i2c_addr = 'd35;

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
logic [15:0] i2c_data;
logic i2c_data_en;

/*nco resources*/
logic [7:0] wave_data;
logic [(ADDR_WIDTH-1):0] wave_addr;
logic wave_load_en;
logic nco_en;
logic [10:0] tunning_word;  
logic [7:0]  nco_out; 

logic [15:0] scale_data_out;

/*WM_DAC*/
logic [2:0]  bitprsc; 
logic [17:0] read_addr; //240254:=0;
 

logic wm_i2c_send_flag;
logic [15:0] wm_i2c_data;
logic wm_i2c_busy;
logic wm_i2c_done;
logic DA_CLR;
logic clk_12_pll;
//-------------------------------------------------------------------------------------------------
/*Asynchronous reset (as_reset_n)*/
//------------------------------------------------------------------------------------------------
always @(posedge clk, negedge raw_reset_n) begin
    if(!raw_reset_n) begin
        ff1 <= 0;
        ff2 <= 0;
    end
    else begin
        ff1 <= 1;
        ff2 <= ff1;
    end   
end
assign as_reset_n  =  ff2;
//-------------------------------------------------------------------------------------------------
/*UART Transceiver*/
//-------------------------------------------------------------------------------------------------
uart_transceiver i_uart_transcevier(
    .sys_clk    (clk          ),
    .sys_rst    (!as_reset_n  ),
    .divisor    (divisor      ),

    .uart_rx    (rx_i         ),
    .uart_tx    (tx_o         ),

    .rx_done    (rx_done      ),   
    .rx_data    (rx_data      ),

    .tx_done    (tx_done      ),
    .tx_data    (tx_data      ), 
    .tx_wr      (tx_wr        )
);
//-------------------------------------------------------------------------------------------------
/*Protocol decoder*/
//-------------------------------------------------------------------------------------------------
protocol_decoder#( ADDR_WIDTH, DEPTH) i_protocol_decoder 
(    
    .clk         (clk         ),
    .rst_n       (as_reset_n  ),

    /*UART oldal*/
    .rx_done_i   (rx_done     ),
    .tx_done_i   (tx_done     ),
    .rx_data_i   (rx_data     ),

    .wave_data_o    (wave_data   ),
    .wave_addr_o    (wave_addr   ),
    .wave_load_en_o (wave_load_en),

    /*rendszer oldal*/
    .internal_data_i(reg_file_data  ),

    .tx_wr_o     (tx_wr       ),
    .tx_data_o   (tx_data     ),

    .wr_en_o     (wr_en       ),
    .rd_en_o     (rd_en       ),
    .reg_addr_o  (reg_addr    ),
    .reg_data_o  (reg_data    ) 
);
//-------------------------------------------------------------------------------------------------
/*Register File*/
//-------------------------------------------------------------------------------------------------
reg_file i_reg_file(
    .clk             (clk           ),
    .rst_n           (as_reset_n    ),
    
    /*UART Protocol Decoder*/
    .reg_wr_i        (wr_en         ),
    .reg_rd_i        (rd_en         ),
    .reg_addr_i      (reg_addr      ),
    .reg_data_i      (reg_data      ),
    .reg_data_o      (reg_file_data ),

    /*NCO control*/
    .nco_en_o        (nco_en        ),
    .tunning_word_o  (tunning_word  ),

    .i2c_data_o      (i2c_data      ),
    .i2c_data_en_o   (i2c_data_en   )
);
//-------------------------------------------------------------------------------------------------
/*Numerically Controlled Oscillator (8 bit data out)*/
//-------------------------------------------------------------------------------------------------
nco #(ADDR_WIDTH, DEPTH, STROBE_MAX) i_nco 
(
    .clk            (clk            ),
    .rst_n          (as_reset_n     ),  
    
    //load
    .wave_data_i    (wave_data   ),
    .wave_addr_i    (wave_addr   ),
    .wave_load_en_i (wave_load_en),
    
    //input
    .nco_en_i       (nco_en         ),
    .tunning_word_i (tunning_word   ),
    
    //output     
    .nco_out        (nco_out        )
);

assign debug_out      = nco_out;
assign scale_data_out = {nco_out,8'd0};

//-------------------------------------------------------------------------------------------------
/*WM I2C Interface and data control*/
//-------------------------------------------------------------------------------------------------
always @(posedge clk or negedge as_reset_n) begin
    if(!as_reset_n) begin
        wm_i2c_send_flag <= 0;
    end
    else begin
        if (wm_i2c_busy == 0) begin
            if (i2c_data_en == 1) begin
                wm_i2c_data <= i2c_data;
                wm_i2c_send_flag <= 1;
            end
            else begin
                wm_i2c_send_flag <= 0;
            end
        end
        else begin
            wm_i2c_send_flag <= 0;
        end
    end
end


wm_i2c_master i_wm_i2c_master(
    .clk            (clk             ),
    .rst_n          (as_reset_n      ),
    
    .i2c_addr       (wm_i2c_addr     ),
    .i2c_data       (wm_i2c_data     ),
    .i2c_send_flag  (wm_i2c_send_flag),
    
    .i2c_done       (wm_i2c_done     ),
    .i2c_busy       (wm_i2c_busy     ),

    .i2c_sda        (i2c_sdat        ),
    .i2c_scl        (FPGA_I2C_SCLK   )
);
//-------------------------------------------------------------------------------------------------
/*12MHz PLL*/
//-------------------------------------------------------------------------------------------------
/*pll i_pll(
    .inclk0        (clk        ),
    .c0            (clk_12_pll )
);*/
//-------------------------------------------------------------------------------------------------
/*WM I2S Interface and data control*/
//-------------------------------------------------------------------------------------------------
clk_generator  i_clk_generator(
    .clk_50(clk),
    .rst_n(as_reset_n),
    .clk_12(clk_12_pll)
);

wm_data_master i_wm_data_master(
    .aud_clock_12   (clk_12_pll      ),
    .aud_data_in    (scale_data_out  ),
    .comm_en        (nco_en          ),

    .aud_bclk       (FPGA_I2S_BCLK   ),
    .aud_daclrc     (FPGA_I2S_DACLRC ),
    .aud_dacdat     (FPGA_I2S_DACDAT )
);

endmodule
`default_nettype wire