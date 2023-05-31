/*
* DEPTH: 16384
* sampling frequency(fs=96kHz), 
* clock frequency(fclk=50MHz) 
* 50MHz/96kHz = 520, so every 520th clock pulse we put out a strobe pulse. 
* This will be our NCO-s sampling frequency 
*/
module nco#(
    //memory size
    parameter ADDR_WIDTH       =  12, 
    parameter DEPTH            =  4096,  
    //sampling frequency
    parameter STROBE_MAX       =  520    
)(
    input  wire          clk,
    input  wire          rst_n, 

    //NCO control input from Register file
    input   wire          nco_en_i,
    input   wire [10:0]   tunning_word_i,

    //Waveform load
    input wire  [7:0] wave_data_i,
    input wire  [(ADDR_WIDTH-1):0] wave_addr_i,
    input wire  wave_load_en_i,  
    
    //Memory address
    output logic [7:0]  nco_out
);

//-------------------------------------------------------------------------------------------------
//NCO resources
//-------------------------------------------------------------------------------------------------

//FSM control resources
typedef enum logic [2:0] {S_IDLE, S_RUN, S_WAIT, S_WRITE} state_t;
state_t state, next_state;

/*strobe generator resources*/
logic sampling_en;
logic [25:0] str_cnt_d,  str_cnt_q;

/*address counter resources*/
logic [(ADDR_WIDTH-1):0]  addr_cnt_d, addr_cnt_q;

logic [(ADDR_WIDTH-1):0] mem_addr;

logic [7:0] nco_data_out;

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
            if((addr_cnt_q + tunning_word_i) >  (DEPTH-1)) begin
                addr_cnt_d   =   11'd0;
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
//Block ram
//-------------------------------------------------------------------------------------------------
blockram #(ADDR_WIDTH, 8, DEPTH) i_blockram
(
  .clk      (clk             ),
  .we       (wave_load_en_i  ),
	.addr     (mem_addr        ),
  .data_in  (wave_data_i     ),
	.data_out (nco_data_out    )
);

//Sinus LUT address logic
assign mem_addr  =  wave_load_en_i ? wave_addr_i : addr_cnt_q; 
assign nco_out = nco_en_i ? nco_data_out : 0;
endmodule