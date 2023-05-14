module dds_behaviour_modell(
    input  wire         clk,
    input  wire         raw_reset_n,

    input  wire         rx_i,
    output logic        tx_o,

    input wire [7:0]    load_data_in,
    input wire [13:0]   load_addr_in,
    input wire          load_en_in,

    output logic [7:0]  dig_out    
);

//UART receiver MODELL
class UartReceiver {
private:
  int baudRate_;
  bool rxPin_;

public:
  UartReceiver(int baudRate, bool rxPin) :
    baudRate_(baudRate), rxPin_(rxPin) {}

  bool receive(char& data) {
    // Wait for start bit
    while (!rxPin_);

    // Calculate sampling time based on baud rate
    int samplingTime = 1000000 / baudRate_;
    delayMicroseconds(samplingTime / 2);

    // Sample bits after start bit
    char byte = 0;
    for (int i = 0; i < 8; i++) {
      byte |= rxPin_ << i;
      delayMicroseconds(samplingTime);
    }

    // Wait for stop bit
    delayMicroseconds(samplingTime);
    if (rxPin_) {
      return false; // Stop bit error
    }

    data = byte;
    return true;
  }
};
endclass

class protocol_decoder_and_reg_file {

    private:

    public:
    
};
endclass 
endmodule