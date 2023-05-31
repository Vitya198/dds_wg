module reg_shadow_entity(
    input wire clk,
    input wire rst_n,
    input wire set_i,
    input wire [7:0] din_l_i,
    input wire [7:0] din_h_i,

    output logic en_o,
    output logic [15:0] dout_o
);

logic [15:0] reg_d, reg_q;
logic en_d, en_q;

always_ff @( posedge clk, negedge rst_n ) begin 
    if(!rst_n) begin
        reg_q  <=  0;
        en_q   <=  0;
    end
    else begin
        reg_q  <=  reg_d;
        en_q   <=  en_d;
    end
end

always_comb begin
    reg_d  =  reg_q;
    en_d   =  en_q;

    if(set_i) begin
        reg_d   =  {din_h_i, din_l_i};
        en_d    =  1;
    end
    else begin
        en_d    =  0;
    end
end

assign dout_o  =  reg_q;
assign en_o    =  en_q;
endmodule