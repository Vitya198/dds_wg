module reg_entity(
    input wire clk,
    input wire rst_n,

    //nco control fsm input
    input wire din_i,
    input wire set_i,
    output logic dout_o
);

logic reg_d, reg_q;

always_ff @( posedge clk, negedge rst_n ) begin 
    if(!rst_n) begin
        reg_q  <=  0;
    end
    else begin
        reg_q  <=  reg_d;
    end
end

always_comb begin
    reg_d  =  reg_q;
    if(set_i) begin
        reg_d  =  din_i;
    end
end

assign dout_o  =  reg_q;

endmodule