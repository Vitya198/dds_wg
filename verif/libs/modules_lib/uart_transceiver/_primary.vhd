library verilog;
use verilog.vl_types.all;
entity uart_transceiver is
    port(
        sys_rst         : in     vl_logic;
        sys_clk         : in     vl_logic;
        uart_rx         : in     vl_logic;
        uart_tx         : out    vl_logic;
        divisor         : in     vl_logic_vector(15 downto 0);
        rx_data         : out    vl_logic_vector(7 downto 0);
        rx_done         : out    vl_logic;
        tx_data         : in     vl_logic_vector(7 downto 0);
        tx_wr           : in     vl_logic;
        tx_done         : out    vl_logic
    );
end uart_transceiver;
