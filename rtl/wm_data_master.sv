module wm_data_master(
	
    input 	wire aud_clock_12,
    input 	wire [15:0] aud_data_in,
	input   wire comm_en,

    output 	logic aud_bclk,
    output 	logic aud_daclrc,
    output 	logic aud_dacdat 
);

logic sample_flag;				//Jelezzük, amint jöhet a következő küldendő adat
logic clk_en;					//Beállítjuk az adatátvitelhez szükséges engedélyező jelet és jelző flag-et

logic [4:0] 	data_index;		// 15-től számolunk visszafelé (mert egyesével küldünk át 16 bitet)
logic [15:0] 	dac_data_reg;	//az adatokat betöltjünk ebbe a regiszterbe
logic [8:0] 	aud_prscl;		//a mintavételi frekvenciát állítjuk vele

assign aud_bclk   =   aud_clock_12;	//1:1 átvisszük a 12MHz-es kommunikációs frekvenciát (tehát 12MHz-en kommunikálunk a kodekkel)

always @(negedge aud_clock_12) begin
    aud_daclrc    <=  clk_en;
    if((aud_prscl < 125)) begin     //96k sample rate
		aud_prscl   <=  aud_prscl   +   1;
		clk_en      <=  1;
    end
	else begin
		aud_prscl   <=  0;
		dac_data_reg <=  aud_data_in;   //get sample
		clk_en      <=  0;
	end

    if(clk_en == 0) begin     //send new sample
	sample_flag <=  1;
	data_index  <=  15;
	end

    if(sample_flag == 1)begin
		if(data_index > 0) begin
			aud_dacdat  <=  dac_data_reg[data_index];
			data_index  <=  data_index - 1;
        end else begin 
			aud_dacdat  <=  dac_data_reg[data_index];
			sample_flag <=  0;
		end
	end
end

endmodule