library verilog;
use verilog.vl_types.all;
entity protocol_decoder is
    generic(
        MAX_ADDR        : integer := 16384
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        rx_done_i       : in     vl_logic;
        tx_done_i       : in     vl_logic;
        rx_data_i       : in     vl_logic_vector(7 downto 0);
        tx_wr_o         : out    vl_logic;
        tx_data_o       : out    vl_logic_vector(7 downto 0);
        reg_file_data_i : in     vl_logic_vector(7 downto 0);
        wr_en_o         : out    vl_logic;
        rd_en_o         : out    vl_logic;
        reg_addr_o      : out    vl_logic_vector(7 downto 0);
        reg_data_o      : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MAX_ADDR : constant is 1;
end protocol_decoder;
