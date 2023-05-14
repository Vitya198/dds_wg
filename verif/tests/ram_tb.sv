`default_nettype none

module ram_tb;
    parameter ADDR_WIDTH = 13;
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8192;

    reg clk;
    reg we;
    reg cs;
    reg [ADDR_WIDTH - 1 : 0] addr;
    reg [DATA_WIDTH - 1 : 0] tb_data;

    wire [DATA_WIDTH - 1 : 0] data;

 
ram	ram(
    .clk     ( clk      ),
    .we      ( we       ),
    .cs      ( cs       ),
	.addr    ( addr     ),
	.data    ( tb_data  ),
	.q_out   ( data     )
);

localparam CLK_PERIOD = 10ns;
always #(CLK_PERIOD/2) clk=~clk;


initial begin
    {clk, we, cs, addr, tb_data} <= 0;

    repeat (2) @ (posedge clk);

    for (integer i = 0; i < 2**ADDR_WIDTH; i = i+1) begin
        repeat (1) @(posedge clk) addr <= i; we <= 1; cs <= 1; tb_data <= $random;
    end

    
    for (integer i = 0; i < 2**ADDR_WIDTH; i = i+1) begin
        repeat (1) @(posedge clk) addr <= i; we <= 0; cs <= 1;
    end

    #200ns ;
end

endmodule
`default_nettype wire
