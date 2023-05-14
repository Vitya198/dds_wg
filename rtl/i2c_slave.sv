module i2c_slave (
    input   wire    sclk,
    input   wire    sdat,
    
    output  logic [15:0] data_out
);

  reg [3:0] bit_counter;
  reg [15:0] data_reg;
  reg start_condition;
  reg address_match;

  always @(posedge sclk) begin
    if (start_condition) begin
      if (bit_counter < 4'b1111) begin
        data_reg <= {data_reg[14:0], sdat};
        bit_counter <= bit_counter + 1;
      end
      else if (bit_counter == 4'b1111) begin
        address_match <= (data_reg[7:1] == address);
        bit_counter <= bit_counter + 1;
      end
      else if (bit_counter == 4'b0000) begin
        if (address_match) begin
          data_out <= data_reg;
        end
        else begin
          data_out <= 16'b0;
        end
        start_condition <= 1'b0;
      end
    end
    else begin
      if (sdat == 1'b0 && sclk == 1'b1) begin
        start_condition <= 1'b1;
        bit_counter <= 4'b0000;
        data_reg <= 16'b0;
        address_match <= 1'b0;
      end
    end
  end

endmodule
