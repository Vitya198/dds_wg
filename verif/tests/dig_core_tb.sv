`timescale 1ns/10ps
module dig_core_tb();

parameter ADDR_WIDTH                =  9;
parameter DATA_WIDTH                =  8;
parameter DEPTH                     =  256;  
parameter SYSTEM_CLOCK              =  50000000; 
parameter SAMPLE_FREQ               =  96000;
parameter baudrate                  =  9600;
parameter NUMBER_OF_WAVEFORM_DATA   = DEPTH;

//Commands
localparam logic [7:0] CMD_NOP  = 8'h00;
localparam logic [7:0] CMD_WR   = 8'h01;
localparam logic [7:0] CMD_RD   = 8'h02;
localparam logic [7:0] CMD_LOAD = 8'h03;

//Inputs
logic           clk_50;
logic           rst_n_i;
logic           tx_wr_i;
logic [7:0]     tx_data_i;
logic           rx;

//Outputs
logic           tx_done_o;
logic           rx_done_o;
logic [7:0]     rx_data_o;
logic           tx;
logic [9:0]     debug;

logic FPGA_I2C_SCLK;
logic FPGA_I2C_SDAT;             //tri state 
logic FPGA_I2S_BCLK;
logic FPGA_I2S_DACLRC;
logic FPGA_I2S_DACDAT;

logic [7:0] received_data;

wire i2c_sda_out;
assign FPGA_I2C_SDAT = i2c_sda_out;

logic [7:0] analog_data;


uart_transceiver uart_model(
    .sys_clk (clk_50        ),
    .sys_rst (!rst_n_i      ),
    .divisor (16'd326       ),
    .uart_rx (tx            ),
    .uart_tx (rx            ),
    .tx_data (tx_data_i     ),
    .rx_data (rx_data_o     ),
    .tx_wr   (tx_wr_i       ),
    .tx_done (tx_done_o     ),
    .rx_done (rx_done_o     )
);

dds_dig_core #(
    ADDR_WIDTH,         
    DATA_WIDTH,      
    DEPTH,                 
    SYSTEM_CLOCK,           
    SAMPLE_FREQ,          
    baudrate     
) dut (
    .clk            (clk_50      ),
    .raw_reset_n    (rst_n_i    ),
    .rx_i           (rx         ),
    .tx_o           (tx         ),

    .FPGA_I2C_SCLK  (FPGA_I2C_SCLK  ),
    .FPGA_I2C_SDAT  (i2c_sda_out    ),
    .FPGA_I2S_BCLK  (FPGA_I2S_BCLK  ),
    .FPGA_I2S_DACLRC(FPGA_I2S_DACLRC),
    .FPGA_I2S_DACDAT(FPGA_I2S_DACDAT),
    .debug_out      (debug          )
);

wm_data_slave wm_data_slave_model(
    .aud_bclk(FPGA_I2S_BCLK),
    .aud_daclrc(FPGA_I2S_DACLRC),
    .aud_dacdat(FPGA_I2S_DACDAT),
    .rst_n(rst_n_i),

    .analog_data(analog_data)
);

//---------------------------------------------------------------------------------------
/*Wave generating*/
//---------------------------------------------------------------------------------------
//real yt [0:(DEPTH-1)];


real pi = 3.14159265359;
real fs = 96e3;
real dt = 1/fs;
real f  = 375;
int  N  =  NUMBER_OF_WAVEFORM_DATA;
int  nt [0:(NUMBER_OF_WAVEFORM_DATA-1)];
real xt [0:(NUMBER_OF_WAVEFORM_DATA-1)];
real cos_val [0:(NUMBER_OF_WAVEFORM_DATA-1)];
int  scaled_val [0:(NUMBER_OF_WAVEFORM_DATA-1)];
logic signed [7:0] yt[0:(NUMBER_OF_WAVEFORM_DATA-1)];
task wave_generate();
  for (int i = 0; i < N; i = i + 1) begin
    nt[i] = i;
    xt[i] = nt[i] * dt;

    // Először kiszámítjuk a koszinusz értékét
    cos_val[i] = $cos(2 * pi * f * xt[i]);
    // Megfelelő skálázás és lekerekítés
    scaled_val[i] = $floor(cos_val[i] *127);
    yt[i] = scaled_val[i];
    //yt[i] = scaled_val[i] & 8'b11111111;
    $display("y[%0d] = %b : %d",i, yt[i], yt[i]);
    #1ns;
  end
endtask
//---------------------------------------------------------------------------------------
/*Send Waveform data*/
//---------------------------------------------------------------------------------------
task send_waveform_data(input logic signed [7:0] waveform_data [], int num_of_data);
    send_bytes({CMD_LOAD}, 1); //loading data
    #1ns;
    for (int i = 0; i < num_of_data; i++) begin
        send_bytes({waveform_data[i]}, 1);
        $display("addr: %d data: %d", i , waveform_data[i]);
    end  
endtask
//---------------------------------------------------------------------------------------
/*READ*/
//---------------------------------------------------------------------------------------
task receive();
    @(posedge rx_done_o);
    received_data = rx_data_o;
    $display(received_data);
endtask
//---------------------------------------------------------------------------------------
/*WRITE*/
//---------------------------------------------------------------------------------------
task send_bytes(input logic [7:0] data [], int num_of_data );
    for(int x = 0; x < num_of_data; x++)begin
        tx_data_i = data[x];
        //test data valid pulse 
        @(posedge clk_50);
        //#1ns;	 //  Data clock to Q
        tx_wr_i =   1; 
        @(posedge clk_50);
        //#1ns;	 //  Data clock to Q
        tx_wr_i =   0;  
        @(posedge tx_done_o);
        //#1ns;
    end
endtask
//---------------------------------------------------------------------------------------
/*TEST*/
//---------------------------------------------------------------------------------------
initial begin
    clk_50       =   0;
    rst_n_i     =   0;
    tx_data_i   =   0;
    tx_wr_i     =   0;

    #1us;
    rst_n_i     =   1;
    
//----------------------------------Send waveform data----------------------------------//
    
    #1ns;  
    wave_generate();
    #1ns;  
    send_waveform_data(yt, NUMBER_OF_WAVEFORM_DATA);
    #1ns;
    $display("End of data");

//-----------------------------wm873 dac setting data send-----------------------------//
/*
    //Digital Interface: DSP, 16 bit, slave mode
    //		00001110                 
    //		00010001	
    send_bytes({CMD_WR, 8'h03, 8'b00001110  }, 3);
    #1ns;
    send_bytes({CMD_WR, 8'h04, 8'b00010001}, 3);
    #10ns;
    // HEADPHONE VOLUME                            
    //		00001010                 
    //		01111001  
    send_bytes({CMD_WR, 8'h03, 8'h }, 3);
    #1ns;
    send_bytes({CMD_WR, 8'h04, 8'h }, 3);
    #10ns;
    //ADC of, DAC on, Linout ON, Power ON        
    //		00001100                 
    //		00000111   
    send_bytes({CMD_WR, 8'h03, 8'h}, 3);
    #1ns;
    send_bytes({CMD_WR, 8'h04, 8'h }, 3);
    #10ns;
    //Sampling control: USB mode                                    
    //		0001000 0                 
    //		00011101  
    send_bytes({CMD_WR, 8'h03, 8'h }, 3);
    #1ns;
    send_bytes({CMD_WR, 8'h04, 8'h }, 3);
    #10ns;
    //RIGHT HEADPHONE OUT: activ interface                             
    //		0001001 1               
    //		01111001
    send_bytes({CMD_WR, 8'h03, 8'h }, 3);
    #1ns;
    send_bytes({CMD_WR, 8'h04, 8'h }, 3);
    #10ns;
    //Enable DAC to LINOUT                        
    //		00001000                 
    //		00010010  
    send_bytes({CMD_WR, 8'h03, 8'h }, 3);
    #1ns;
    send_bytes({CMD_WR, 8'h04, 8'h }, 3);
    #10ns;
    //remove mute DAC                             
    //		00001010                 
    //		00000000    
    send_bytes({CMD_WR, 8'h03, 8'h }, 3);
    #1ns;
    send_bytes({CMD_WR, 8'h04, 8'h }, 3);
    #10ns;
*/
//------------------------------------Test-----------------------------------//

    send_bytes({CMD_NOP}, 1);
    #1ns;

    send_bytes({CMD_WR, 8'h03, 8'b00001110  }, 3);
    #1ns;
    send_bytes({CMD_WR, 8'h04, 8'b00010001}, 3);
    #10ns;

    //CMD = WR, ADDR = 0x01, DATA = 8'd1 -> NCO engedélyezés 
    send_bytes({CMD_WR, 8'h00, 8'h01}, 3);

    #1ns;
    //CMD = WR, ADDR = 0x02/0x03, DATA = '
    send_bytes({CMD_WR, 8'h01, 8'h01}, 3);

    #1ns;
    send_bytes({CMD_WR, 8'h02, 8'h00}, 3);
   
   
    #5ms;
    //CMD = WR, ADDR = 0x02/0x03, DATA = 'd5
    send_bytes({CMD_WR, 8'h01, 8'h05}, 3);

    #1ns;
    send_bytes({CMD_WR, 8'h02, 8'h00}, 3);

                                    //10
    #10ms;
    send_bytes({CMD_WR, 8'h01, 8'h0A}, 3);

    #1ns;
    send_bytes({CMD_WR, 8'h02, 8'h00}, 3);

// end of test
#10ms;
//$finish;
end

//---------------------------------------------------------------------------------------
/*Create Clock*/
//---------------------------------------------------------------------------------------
//50MHz
always begin 
    clk_50 = 0;
    #10ns;
    clk_50= 1;
    #10ns;
end 

//12MHz
/*
always begin
    clk_12_pll = 0;
    #41.67ns;
    clk_12_pll = 1;
    #41.67ns;
end*/
endmodule
