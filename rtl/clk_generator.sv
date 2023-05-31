module clk_generator(
  input  wire clk_50,
  input wire rst_n,
  output logic clk_12
);

  logic [3:0] counter;
  logic clk_out;

  always @(posedge clk_50, negedge rst_n) begin
    if(!rst_n) begin
      counter <= 4'd0;
      clk_out <= 0;
    end
    else begin
      if (counter == 4'd1) begin
        counter <= 4'd0;
        clk_out <= ~clk_out;
      end
      else begin
        counter <= counter + 1;
      end
    end
  end

  assign clk_12 = clk_out;

  endmodule