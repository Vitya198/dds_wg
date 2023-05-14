module wm8731_i2c_controller (
  input   wire  clk,
  input   wire  rst_n,
  input   wire  csb,
  output logic  sclk,
  output logic  sdata
);
endmodule



module i2c_master (
  input wire clk,
  input wire rst_n,
  input wire [15:0] data_in,
  
  output reg sclk,
  output reg sdat
);

logic [3:0] bit_counter;
logic [15:0] data_reg;
logic start_condition;
logic [7:0] address;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      bit_counter <= 4'b0000;
      data_reg <= 16'b0;
      start_condition <= 1'b0;
      address <= 8'b0;
      sclk <= 1'b0;
      sdat <= 1'b1;
    end
    else begin
      if (start_condition) begin
        if (bit_counter < 4'b1000) begin
          sclk <= 1'b1;
          sdat <= data_reg[15];
          data_reg <= {data_reg[14:0], 1'b0};
          bit_counter <= bit_counter + 1;
        end
        else if (bit_counter == 4'b1000) begin
          sclk <= 1'b1;
          sdat <= 1'b0;  // Start condition: SDAT transition from high to low
          bit_counter <= bit_counter + 1;
        end
        else if (bit_counter == 4'b1001) begin
          sclk <= 1'b1;
          sdat <= 1'b1;  // Stop condition: SDAT transition from low to high
          start_condition <= 1'b0;
          bit_counter <= 4'b0000;
        end
      end
      else begin
        sclk <= 1'b0;
        sdat <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if (start_condition) begin
      address <= address + 1;
    end
    else begin
      address <= data_in[7:0];
    end
  end

  always @(posedge clk) begin
    if (!rst_n) begin
      start_condition <= 1'b0;
    end
    else begin
      start_condition <= (address != data_in[7:0]);
    end
  end

  always @(posedge clk) begin
    if (start_condition) begin
      data_reg <= data_in;
    end
  end

endmodule
