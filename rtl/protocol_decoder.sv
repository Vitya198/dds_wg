`default_nettype none
module protocol_decoder#(
  parameter ADDR_WIDTH  =  12,
  parameter DEPTH       =  4096 //DEPTH :n=14bit ->2^14=16384
)(
input  wire         clk,
input  wire         rst_n,

//UART side
input  wire         rx_done_i,
input  wire         tx_done_i,	
input  wire  [7:0]  rx_data_i,

output logic        tx_wr_o,
output logic  [7:0] tx_data_o,

//Memory
output logic [(ADDR_WIDTH-1):0] wave_addr_o,
output logic [7:0] wave_data_o,
output logic wave_load_en_o,

//System side
input  wire   [7:0] internal_data_i,
output logic        wr_en_o,
output logic        rd_en_o,
output logic [7:0]  reg_addr_o,
output logic [7:0]  reg_data_o
);
//-------------------------------------------------------------------------------------------------

localparam logic [7:0] CMD_NOP  = 8'h00;
localparam logic [7:0] CMD_WR   = 8'h01;
localparam logic [7:0] CMD_RD   = 8'h02;
localparam logic [7:0] CMD_LOAD = 8'h03;
logic [7:0] cmd_type_d, cmd_type_q;

//-------------------------------------------------------------------------------------------------

logic [7:0] addr_d,   addr_q ;
logic [7:0] data_d,   data_q;
logic       wr_en_d, wr_en_q;

logic [(ADDR_WIDTH-1):0] count_d, count_q;
logic [7:0] data_2_tx_d,  data_2_tx_q;
logic       valid_2_tx_d, valid_2_tx_q; 

logic wave_load_en_d, wave_load_en_q;
logic wave_load_en_ff_d, wave_load_en_ff_q;
logic counter_flag_bit;

//-------------------------------------------------------------------------------------------------

typedef enum logic [2:0] {S_TYPE, S_ADD, S_DATA, S_MEM_LOAD} state_t;
state_t state, next_state;

//-------------------------------------------------------------------------------------------------

always_ff @ ( posedge clk, negedge rst_n ) begin
  if(!rst_n) begin
    state         <= S_TYPE;
    cmd_type_q    <= CMD_NOP;
    addr_q        <= 'd0;
    data_q        <= 'd0;
    wr_en_q       <= 'd0;
    count_q       <= 'd0;
    valid_2_tx_q  <= 'd0;
    data_2_tx_q   <= 'd0;
    wave_load_en_q<= 'd0;
    wave_load_en_ff_q<= 'd0; 
  end
  else begin
    state         <= next_state;
    cmd_type_q    <= cmd_type_d;
    addr_q        <= addr_d;
    data_q        <= data_d;
    wr_en_q       <= wr_en_d;
    count_q       <= count_d;
    valid_2_tx_q  <= valid_2_tx_d;
    data_2_tx_q   <= data_2_tx_d;
    wave_load_en_q <= wave_load_en_d;
    wave_load_en_ff_q <= wave_load_en_ff_d;  
  end
end

//-------------------------------------------------------------------------------------------------

always @(*) begin
  next_state   =  state;
  cmd_type_d   =  cmd_type_q;
  addr_d       =  addr_q;  
  data_d       =  data_q;
  wr_en_d      =  wr_en_q;
  count_d      =  count_q;
  valid_2_tx_d =  valid_2_tx_q;
  data_2_tx_d  =  data_2_tx_q;
  wave_load_en_d = wave_load_en_q;
  wave_load_en_ff_d = wave_load_en_ff_q;
  
  if (valid_2_tx_q | tx_done_i ) begin
    valid_2_tx_d = 0;
  end 
  else begin
    valid_2_tx_d = valid_2_tx_q;
  end

  if(wave_load_en_q == 1) begin
    wave_load_en_ff_d = 0;
    wave_load_en_d    = wave_load_en_ff_q;
  end
  else begin
    wave_load_en_d = wave_load_en_q;
    wave_load_en_ff_d = wave_load_en_ff_q;
  end

  case (state)
    S_TYPE: begin
      if (rx_done_i) begin
        if (rx_data_i == CMD_NOP) begin
            next_state = S_TYPE;
            cmd_type_d = rx_data_i;
        end else if (rx_data_i == CMD_WR) begin
            next_state = S_ADD;
            cmd_type_d = rx_data_i;
        end else if (rx_data_i == CMD_RD) begin
            next_state = S_ADD;
            cmd_type_d = rx_data_i;
        end else if (rx_data_i == CMD_LOAD) begin
            next_state = S_MEM_LOAD;
            cmd_type_d = rx_data_i;
            count_d    = 0;
            counter_flag_bit = 1; 
        end
        wr_en_d = 0;  
      end
    end

    S_ADD: begin
      if ( rx_done_i ) begin
        next_state = S_DATA;
        addr_d     = rx_data_i;
      end
    end

    S_DATA:	begin
      if ( rx_done_i ) begin
        next_state  = S_TYPE;
        cmd_type_d  = CMD_NOP;
        if(cmd_type_q == CMD_WR) begin
          data_d  = rx_data_i;
          wr_en_d    = 1; 
        end
        else begin
          data_2_tx_d  = internal_data_i;
          valid_2_tx_d = 1;
        end
      end
    end

    S_MEM_LOAD: begin
      if(rx_done_i) begin
          if (count_q == (DEPTH-1)) begin
            next_state    = S_TYPE;
            cmd_type_d    = CMD_NOP;
            count_d       = 0;
          end
          else begin
            if(counter_flag_bit == 1) begin
              counter_flag_bit = 0;
            end
            else begin
              count_d = count_q + 1;
            end
            data_d      = rx_data_i;
            next_state  = S_MEM_LOAD;
            cmd_type_d  = CMD_LOAD; 
            wave_load_en_d = 1;
            wave_load_en_ff_d = 1;
          end
        end
      end
  endcase
end
//-------------------------------------------------------------------------------------------------
//hullámformával együtt
assign wr_en_o    = wr_en_q;
assign rd_en_o    = wave_load_en_d;
assign reg_data_o = data_q;
assign reg_addr_o = addr_q;

//to Memory
assign wave_addr_o    =  count_q;
assign wave_data_o    =  data_q; 
assign wave_load_en_o =  wave_load_en_q;
//assign wave_load_en_o =  ((cmd_type_q == CMD_LOAD) && (state == S_MEM_LOAD) && rx_done_i);  //BLOCK RAM we bemenetére mehet
//to UART
assign tx_wr_o        = (((cmd_type_q == CMD_LOAD) && (state == S_MEM_LOAD)) || ((cmd_type_q == CMD_RD) && (state == S_DATA)) ) ? valid_2_tx_q : 0; 
assign tx_data_o      = data_2_tx_q;

endmodule
`default_nettype wire   