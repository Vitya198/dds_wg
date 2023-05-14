/*
* DEPTH: 16384
* sampling frequency(fs=96kHz), 
* clock frequency(fclk=50MHz) 
* 50MHz/96kHz = 520, so every 520th clock pulse we put out a strobe pulse. 
* This will be our NCO-s sampling frequency 
*/
module nco#(
  parameter MAX_ADDR        =  4096,  //DEPTH
  parameter STROBE_MAX      =  520    
)(
    input  wire          clk,
    input  wire          rst_n, 

    //NCO control input from Register file
    input   wire          nco_en_i,
    input   wire [10:0]   tunning_word_i,
    //input   wire          prn_en_i,
    input wire [7:0]    load_data_in,
    input wire [11:0]   load_addr_in,
    input wire          load_en_in,
    //Memory address
    output logic [7:0]  nco_data_out
);

//-------------------------------------------------------------------------------------------------
//NCO resources
//-------------------------------------------------------------------------------------------------

//FSM control resources
typedef enum logic [2:0] {S_IDLE, S_RUN, S_WAIT, S_WRITE} state_t;
state_t state, next_state;

/*strobe generator resources*/
//logic sampling_en;
logic [25:0] str_cnt_d,  str_cnt_q;

/*address counter resources*/
logic [13:0] addr_cnt_d, addr_cnt_q;
logic [7:0]  data_wr_d,  data_wr_q;

logic [13:0] sinus_addr;

//-------------------------------------------------------------------------------------------------
/*PRN (Pseudo-random Noise) generator*/
//-------------------------------------------------------------------------------------------------
/*
  //PRN generátor
  reg [13:0] prn_sequence;
  always @(posedge clk) begin
    prn_sequence <= {prn_sequence[13:0], prn_sequence[10] ^ prn_sequence[7]}; // XOR kapu a PRN generátorban
  end

//-------------------------------------------------------------------------------------------------
/*Strobe generator, sampling frequency*/
//-------------------------------------------------------------------------------------------------
 always @(*) begin
  str_cnt_d  =  str_cnt_q;

  if(sampling_en) begin
    str_cnt_d   =   0;
  end
  else begin
    str_cnt_d   =   str_cnt_q   +   1;
  end
end

always_ff @(posedge clk or negedge rst_n) begin 
  if(!rst_n) begin
    str_cnt_q   <=  26'd0;
  end
  else begin
    str_cnt_q   <=  str_cnt_d;    
  end
end
 
assign sampling_en   =   (str_cnt_q == STROBE_MAX);

//-------------------------------------------------------------------------------------------------
//Phase accumulator
//-------------------------------------------------------------------------------------------------
always_ff @( posedge clk, negedge rst_n ) begin
  
  if(!rst_n) begin
    state           <=  S_IDLE;
    addr_cnt_q      <=  0;
  end
  
  else begin
    if(nco_en_i) begin
        state       <= next_state;
        addr_cnt_q  <=  addr_cnt_d;
    end
  end
end

//-------------------------------------------------------------------------------------------------

 always @(*) begin
    next_state  =  state;
    addr_cnt_d  =  addr_cnt_q;

  case(state)
    S_IDLE: begin
      if(nco_en_i) begin
        next_state = S_RUN;
      end
    end


    S_RUN: begin
      if(!nco_en_i) begin
        addr_cnt_d =  0;
        next_state =  S_IDLE;
      end
      else begin
        if(tunning_word_i!=0) begin
            if(addr_cnt_q  >=  MAX_ADDR) begin
                addr_cnt_d   =   10'd0;
            end
            else begin
                if(sampling_en) begin
                    addr_cnt_d  =  addr_cnt_q  +  tunning_word_i;
                end
            end
        end
        else begin
          next_state = S_WAIT;
        end
      end
    end

    S_WAIT: begin
      if(tunning_word_i != 0) begin
        next_state = S_RUN;
      end
      else begin
        next_state = S_WAIT;
      end
    end
  endcase
end

//-------------------------------------------------------------------------------------------------
//Sinus table (blockram)
//-------------------------------------------------------------------------------------------------
sinus_lut i_sinus_lut (
  .clk      ( clk             ),
  .we       ( load_en_in      ),
	.addr     ( sinus_addr      ),
	.data_in  ( load_data_in    ),
	.data_out ( nco_data_out    )
);

//Sinus LUT address logic
assign sinus_addr  =  (load_en_in) ? load_addr_in : addr_cnt_q ;  //Write or 

endmodule