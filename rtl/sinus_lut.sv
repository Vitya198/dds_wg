module sinus_lut #(
	parameter ADDR_WIDTH = 11,
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 4096
)(
	input 	wire clk,
	input 	wire we,

	input 	wire  [(ADDR_WIDTH - 1) : 0] addr,
	input 	wire  [(DATA_WIDTH - 1) : 0] data_in,
	output 	logic [(DATA_WIDTH - 1) : 0] data_out
);

//-------------------------------------------------------------------------------------------------

logic [(DATA_WIDTH - 1) : 0] content [0 : (DEPTH-1)];

//-------------------------------------------------------------------------------------------------

initial begin
	$readmemb("sin_lut_data.txt", content)	 // np.savetxt('sin_lut_data.txt', data, fmt='%1.4f')
end


always_ff @ (posedge clk) begin
	if ( we ) content[addr] <= data_in;
	
end

assign data_out = content[addr];
  
endmodule
//------------------------------------------------------------------------------------------------- 