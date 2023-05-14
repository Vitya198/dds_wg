library verilog;
use verilog.vl_types.all;
entity dds_dig_core is
    generic(
        fclk            : integer := 50000000;
        baudrate        : integer := 9600
    );
    port(
        clk             : in     vl_logic;
        raw_reset_n     : in     vl_logic;
        rx_i            : in     vl_logic;
        tx_o            : out    vl_logic;
        load_data_in    : in     vl_logic_vector(7 downto 0);
        load_addr_in    : in     vl_logic_vector(13 downto 0);
        load_en_in      : in     vl_logic;
        dig_out         : out    vl_logic_vector(7 downto 0);
        debug_o_1       : out    vl_logic_vector(9 downto 0);
        debug_o_2       : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of fclk : constant is 1;
    attribute mti_svvh_generic_type of baudrate : constant is 1;
end dds_dig_core;
