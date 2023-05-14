module dac (
    input wire [7:0] nco_data_i,
    input wire [7:0] scale,

    output logic [14:0] dac_o
);

always @(*) begin
  case(scale)
    0: begin
      dac_o = {6'd0, nco_data_i};  
    end
    1: begin
      dac_o = {5'd0,nco_data_i, 1'd0};
    end
    2: begin
      dac_o = {4'd0,nco_data_i,2'd0};
    end
    3: begin
      dac_o = {3'd0,nco_data_i, 3'd0};
    end
    4: begin
      dac_o = {2'd0,nco_data_i, 4'd0};
    end
    5: begin
      dac_o = {1'd0,nco_data_i, 5'd0};
    end
    6: begin
      dac_o = {nco_data_i,6'd0};
    end

    default: begin
      dac_o = {nco_data_i,6'd0};
    end 
  endcase
end
endmodule
