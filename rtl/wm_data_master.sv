module wm_data_master{
    input wire aud_clock_12,
    input wire [31:0] aud_data_in,

    output logic aud_bk,
    output logic aud_dalr,
    output logic aud_dadat 
};

logic sample_flag;
logic [4:0] data_index;
logic [15:0] da_data;
logic [31:0] da_data_out;
logic [8:0] aud_prscl;
logic clk_en;

assign aud_bk   =   aud_clock_12;

always @(negedge aud_clock_12) begin
    aud_dalr    <=  clk_en;
    if(aud_prscl < 250) begin     //48k sample rate
		aud_prscl   <=  aud_prscl   +   1;
		clk_en      <=  0;
    end
	else begin
		aud_prscl   <=  0;
		da_data_out <=  aud_data_in;   //get sample
		clk_en      <=  1;
	end

    if(clk_en == 1) begin     //send new sample
	sample_flag <=  1;
	data_index  <=  31;
	end

    if(sample_flag == 1)begin
	
		if(data_index>0) begin
			aud_dadat   <=  da_data_out[data_index];
			data_index  <=  data_index-1;
        end else begin 
			aud_dadat   <=  da_data_out[data_index];
			sample_flag <=  1;
		end
	end
end

endmodule