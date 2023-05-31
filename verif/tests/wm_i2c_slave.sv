module wm_i2c_slave(
    input wire clk,
    input wire rst_n,

    //system interface
    output wire [15:0] i2c_data;


    //comm interface
    inout tri i2c_sda,
    input wire i2c_scl
);

logic is_address_received;
logic is_data_received;
logic ack;
logic [15:0] data_register;


assign i2c_sda = (ack) ? 0 : 1;

typedef enum logic [7:0] {IDLE, START_CONDITION, RECEIVE_ADDR, SEND_1_ACK, RECEIVE_FIRST_BYTE, SEND_2_ACK, RECEIVE_SECOND_BYTE, SEND_3_ACK, STOP_CONDITION } state_t;
state_t state;

always @(posedge i2c_scl) begin
    if()
end

endmodule