module blockram #(
	parameter ADDR_WIDTH 	= 12,
    parameter DATA_WIDTH 	= 8,
    parameter DEPTH 		= 4096
)(
	input 	wire clk,
	input 	wire we,

	input 	wire  [(ADDR_WIDTH - 1) : 0] addr,
	input	wire  [(DATA_WIDTH - 1) : 0] data_in,
	output  logic [(DATA_WIDTH - 1) : 0] data_out
);

//-------------------------------------------------------------------------------------------------

logic [(DATA_WIDTH - 1) : 0] content [0 : (DEPTH-1)];

//-------------------------------------------------------------------------------------------------
/*
initial begin
	$readmemh("memory.hex", content);	
end
*/
//-------------------------------------------------------------------------------------------------
always_ff @ (posedge clk) begin
	if ( we ) begin
		content[addr] <= data_in;
	end 	
end

assign data_out = content[addr];
  
endmodule
