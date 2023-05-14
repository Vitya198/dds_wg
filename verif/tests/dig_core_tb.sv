`timescale 1ns/10ps
module dig_core_tb();

parameter  NUMBER_OF_WAVEFORM_DATA = 4096;

//Commands
localparam logic [7:0] CMD_NOP  = 8'h00;
localparam logic [7:0] CMD_WR   = 8'h01;
localparam logic [7:0] CMD_RD   = 8'h02;

//Inputs
logic           clk_i;
logic           rst_n_i;
logic           tx_wr_i;
logic [7:0]     tx_data_i;
logic           rx;
                  
//Outputs
logic           tx_done_o;
logic           rx_done_o;
logic [7:0]     rx_data_o;
logic           tx;
logic [7:0]     dig_out;
logic [9:0]     debug_o_1;
logic [9:0]     debug_o_2;

logic [7:0]    load_data;
logic [13:0]   load_addr;
logic          load_en;

uart_transceiver uart_model(
    .sys_clk (clk_i         ),
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

dds_dig_core dut(
    .clk        (clk_i      ),
    .raw_reset_n(rst_n_i    ),
    .rx_i       (rx         ),
    .tx_o       (tx         ),

    .load_en_in  (load_en    ),
    .load_addr_in(load_addr  ),
    .load_data_in(load_data  ), 

    .dig_out    (dig_out    ),
    .debug_o_1  (debug_o_1  ),
    .debug_o_2  (debug_o_2  )
);
//---------------------------------------------------------------------------------------
/*Wave data generating*/
//---------------------------------------------------------------------------------------

real yt [0:(NUMBER_OF_WAVEFORM_DATA-1)];
logic [7:0] two_comp [0:(NUMBER_OF_WAVEFORM_DATA-1)];

real pi = 3.14159265359;
real fs = 96e3;
real dt = 1/fs;
real f = 23.4375;
int N =  NUMBER_OF_WAVEFORM_DATA;
int nt [0:(NUMBER_OF_WAVEFORM_DATA-1)];
real xt [0:(NUMBER_OF_WAVEFORM_DATA-1)];
int i;

logic [7:0] yt_scaled;
int yt_int;
logic [7:0] yt_bin;

task wave_generate();
  for (i = 0; i < N; i = i + 1) begin
    nt[i] = i;
    xt[i] = nt[i] * dt;
    yt[i] = $cos(2 * pi * f * xt[i]);
    yt_scaled = ((yt[i] + 1) / 2) * 127.5;
    yt_int = $floor(yt_scaled);
    yt_bin = $bits(yt_int);
    two_comp[i] = $signed(yt_int);
    #1ns;
  end
endtask
 //$display("%d", two_comp[i]);

//---------------------------------------------------------------------------------------
/*Verifikációs modell*/
//---------------------------------------------------------------------------------------
dds_behaviour_modell vut(
    .clk        (clk_i      ),
    .raw_reset_n(rst_n_i    ),
    .rx_i       (rx         ),
    .tx_o       (tx         ),

    .load_en_in  (load_en    ),
    .load_addr_in(load_addr  ),
    .load_data_in(load_data  ), 

    .dig_out    (dig_out    ),
    .debug_o_1  (debug_o_1  ),
    .debug_o_2  (debug_o_2  )
);
//---------------------------------------------------------------------------------------
/*READ*/
//---------------------------------------------------------------------------------------
logic [7:0] received_data;
task receive();
    @(posedge rx_done_o);
    #1ns;
endtask
//---------------------------------------------------------------------------------------
/*WRITE*/
//---------------------------------------------------------------------------------------
task send_bytes(input logic [7:0] data [], int num_of_data );
 
    for(int x = 0; x < num_of_data; x++)begin
        tx_data_i = data[x];
        //test data valid pulse 
        @(posedge clk_i);
        #1ns;	 //  Data clock to Q
        tx_wr_i =   1; 
        @(posedge clk_i);
        #1ns;	 //  Data clock to Q
        tx_wr_i =   0;  
        @(posedge tx_done_o);
        #1ns;
    end
endtask

task send_waveform_data(input logic [7:0] data [], int num_of_data);

    // write test data to blockram
    for (int i = 0; i < num_of_data; i++) begin
        @(posedge clk_i);
        load_en = 1;
        load_addr = i;
        load_data = data[i];
    end

    // disable blockram write enable
    @(posedge clk_i);
    load_en = 0;

endtask


//---------------------------------------------------------------------------------------
/*TEST*/
//---------------------------------------------------------------------------------------
initial begin
clk_i       =   0;
rst_n_i     =   0;
tx_data_i   =   0;
tx_wr_i     =   0;
load_en     =   0;

#1us;
rst_n_i     =   1;

//test comes here

    //CMD = LOAD, DATA ==> waveform 
    wave_generate();
    #1ns;  
    send_waveform_data(two_comp, NUMBER_OF_WAVEFORM_DATA);
    #1ns;

    //CMD = WR, ADDR = 0x01, DATA = 8'd1 -> NCO engedélyezés 
    send_bytes({CMD_WR, 8'h00, 8'h01}, 3);

    #1ns;
    //CMD = WR, ADDR = 0x02/0x03, DATA = 'd16 -> M=16 
    send_bytes({CMD_WR, 8'h01, 8'h10}, 3);

    #1ns;
    send_bytes({CMD_WR, 8'h02, 8'h00}, 3);


    #1ms;
    //CMD = WR, ADDR = 0x02/0x03, DATA = 'd16 -> M=16 
    send_bytes({CMD_WR, 8'h01, 8'h33}, 3);

    #1ns;
    send_bytes({CMD_WR, 8'h02, 8'h01}, 3);


    //Comparation comes here
    



// end of test
#10ms;
//$finish;
end

//---------------------------------------------------------------------------------------
/*Create Clock*/
//---------------------------------------------------------------------------------------
always begin 
    clk_i = 0;
    #10ns;
    clk_i= 1;
    #10ns;
end 
endmodule

