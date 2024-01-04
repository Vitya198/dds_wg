module wm_i2c_master(
    input wire clk,
    input wire rst_n,

    //control interface
    input wire [7:0]    i2c_addr,
    input wire [15:0]   i2c_data,
    input wire          i2c_send_flag,

    output logic i2c_done,
    output logic i2c_busy,

    //Comm interface
    inout  tri       i2c_sda,   //kétirányú adatvonal
    output logic     i2c_scl
);

//---------------------------------------------------------------

logic [7:0] clk_prs = 0;
logic clk_en;
logic ack_en;
logic clk_i2c;
logic get_ack;
logic [15:0] data_index;

logic i2c_sda_q;
assign i2c_sda = i2c_sda_q;

typedef enum logic [7:0] {IDLE, START_CONDITION, SEND_ADDR, WAIT_FOR_1_ACK, SEND_FIRST_BYTE, WAIT_FOR_2_ACK, SEND_SECOND_BYTE, WAIT_FOR_3_ACK, STOP_CONDITION } state_t;
state_t state;

//generate two clocks for i2c and data transitions
always @(posedge clk) begin
    if(clk_prs < 250) begin
        clk_prs <= clk_prs+1;
    end else begin
        clk_prs <= 0;
    end

    if(clk_prs < 125) begin     //50 % duty cylce clock for i2c
        clk_i2c <= 'd1;
    end else begin
        clk_i2c <= 'd0;
    end

    if(clk_prs == 62) begin     //clock for ack on SCL=HIGH
        ack_en <= 'd1;
    end else begin
        ack_en <= 'd0;
    end
    
    if(clk_prs) begin           //clock for data on SCL=LOW
        clk_en  <=  1;
    end else begin
        clk_en  <=  0;
    end


    if(clk_en == 1) begin
        i2c_scl <=  clk_i2c;
    end
    //ack on SCL=HIGH
    if(ack_en == 1) begin
        case(state)
        WAIT_FOR_1_ACK: begin
            if(i2c_sda_q == 0) begin
                state       <=  SEND_FIRST_BYTE; //ack
                data_index  <=  15;
            end
            else begin
                clk_en  <=  0;  
                state   <=  IDLE; //nack
            end
        end

        WAIT_FOR_2_ACK: begin
            if(i2c_sda_q == 0) begin
                state       <=  SEND_SECOND_BYTE; //ack
                data_index  <=  7;
            end
            else begin
                clk_en  <=  0;
                state   <=  IDLE; //nack
            end
        end

        WAIT_FOR_3_ACK: begin
            if(i2c_sda_q == 0) begin
                state   <=  STOP_CONDITION ; //ack
            end
            else begin
                clk_en  <=  0;
                state   <=  IDLE; //nack
            end
        end
        endcase
    end

    //data tranfer on SCL=LOW
    if(clk_en == 1) begin
        case(state)

        IDLE: begin      //stand by
            i2c_sda_q   <=  1'b1;
			i2c_busy    <=  0;
			i2c_done    <=  0;
			if(i2c_send_flag == 1)begin
			    state       <=  START_CONDITION;
			    i2c_busy    <=  1;
			end
        end

        START_CONDITION: begin  //start  condition
            i2c_sda_q     <=  1'b0;
			state       <=  SEND_ADDR;
			data_index  <=  7;
        end

        SEND_ADDR: begin  //send addr
            clk_en  <=  1;    //start clocking i2c_scl
            if(data_index > 0) begin
                data_index  <=  data_index - 1;
                i2c_sda_q     <=  i2c_addr[data_index];
            end
            else begin
                i2c_sda_q     <=  i2c_addr[data_index];
                get_ack     <=  1;
            end

            if(get_ack == 1) begin
                get_ack     <=  0;
                state       <=  WAIT_FOR_1_ACK;
                i2c_sda_q     <=  1'bZ;
            end
        end

        SEND_FIRST_BYTE: begin  //send 1st 8 bit
            if(data_index > 8) begin
                data_index  <=  data_index - 1;
                i2c_sda_q     <=  i2c_data[data_index];
            end
            else begin
                i2c_sda_q     <=  i2c_data[data_index];
				get_ack     <=  1;
            end

            if(get_ack == 1) begin
                get_ack     <=  0;
                state       <=  WAIT_FOR_2_ACK;
                i2c_sda_q     <=  1'bZ;
            end
        end

        SEND_SECOND_BYTE: begin  //send 2nd 8 bit
            if(data_index > 0) begin
                data_index  <=  data_index - 1;
				i2c_sda_q     <=  i2c_data[data_index];
            end
            else begin
                i2c_sda_q     <=  i2c_data[data_index];
				get_ack     <=  1;
            end

            if(get_ack == 1) begin
                get_ack     <=  0;
                state       <=  WAIT_FOR_3_ACK;
                i2c_sda_q     <=  1'bZ;
            end
        end

        STOP_CONDITION: begin  //stop condition
            clk_en      <=  0;
			i2c_sda_q     <=  1'b0;
			state       <=  IDLE;
			i2c_done    <=  1;
        end
        endcase
    end
end
endmodule