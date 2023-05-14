module wm_i2c_master{
    input wire clk,
    input wire rst_n,

    input wire [7:0]    i2c_addr,
    input wire [15:0]   i2c_data,
    input wire          i2c_send_flag,

    output logic tri i2c_sda,
    output logic i2c_done,
    output logic i2c_busy,
    output logic i2c_scl
};

logic [7:0] clk_prs = 0;
logic clk_en; 
logic ack_en;   
logic clk_i2c;
logic get_ack;

logic [15:0] data_index;


typedef enum logic [7:0] {st0,st1,st2,st3,st4,st5,st6,st7,st8 } state_t;
state_t state;

//generate two clocks for i2c and data transitions
always @(posedge clk) begin
    if(clk_prs<250) begin
        clk_prs <= clk_prs+1;
    end else begin
        clk_prs <= 0;
    end

    if(clk_prs<125) begin      //50 % duty cylce clock for i2c
        clk_i2c <= 'd1;
    end else begin
        clk_i2c <= 'd0;
    end
    if(clk_prs==62) begin    //clock for ack  on SCL=HIGH
        ack_en <= 'd1;
    end else begin
        ack_en <= 'd1;
    end
    
    if(clk_prs) begin          //clock for data on SCL=LOW
        clk_en<=1
    end else begin
        clk_en <=0;
    end
end


always @(posedge clk) begin
    if(clk_en==1) begin
        i2c_scl<=clk_i2c;
    end
    //ack on SCL=HIGH
    if(ack_en=1) begin
        case(state):
        st3: begin
            if(i2c_sda) begin
                state<=st4; //ack
                data_index<=15;
            end
            else begin
                clk_en<=0;  
                state<=st0; //nack
            end
        end

        st5: begin
            if(i2c_sda==0) begin
                state<=st6; //ack
                data_index<=7;
            end
            else begin
                clk_en<=0;
                state<=st0; //nack
            end
        end

        st7: begin
            if(i2c_sda==0) begin
                state<=st8; //ack
            end
            else begin
                clk_en<=0;
                state<=st0; //nack
            end
        end
        endcase
    end

    //data tranfer on SCL=LOW
    if(clk_en =1) begin
        case(state):

        st0: begin      //stand by
            i2c_sda<=1;
			i2c_busy<=0;
			i2c_done<=0;
			if(i2c_send_flag==1)begin
			    state<=st1;
			    i2c_busy<=1;
			end
        end

        st1: begin  //start  condition
            i2c_sda<=0;
			state<=st2;
			data_index<=7;
        end

        st2: begin  //send addr
            clk_en<='1';    //start clocking i2c_scl
            if(data_index>0) begin
                data_index<=data_index-1;
                i2c_sda<=i2c_addr[data_index];
            end
            else begin
                i2c_sda<=i2c_addr[data_index];
                get_ack<=1;
            end

            if(get_ack==1) begin
                get_ack<=0;
                state<=st3;
                s2c_sda<='z;
            end
        end

        st4: begin  //send 1st 8 bit
            if(data_index>8) begin
                data_index<=data_index-1;
                i2c_sda<=i2c_data[data_index];
            end
            else begin
                i2c_sda<=i2c_data[data_index];
				get_ack<=1;
            end

            if(get_ack==1) begin
                get_ack<=0;
                state<=st5;
                i2c_sda<='z;
            end
        end

        st6: begin  //send 2nd 8 bit
            if(data_in>0) begin
                data_index<=data_index-1;
				i2c_sda<=i2c_data[data_index];
            end
            else begin
                i2c_sda<=i2c_data[data_index];
				get_ack<='1'
            end

            if(get_ack==1) begin
                get_ack<=0;
                state<=st7;
                i2c_sda<='z;
            end
        end

        st8: begin  //stop condition
            clk_en<=0;
			i2c_sda<=0;
			state<=st0;
			i2c_done<=1;
        end
        endcase
    end
end
endmodule