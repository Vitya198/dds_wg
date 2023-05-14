library verilog;
use verilog.vl_types.all;
entity nco is
    generic(
        MAX_ADDR        : integer := 16384;
        STROBE_MAX      : integer := 520
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        nco_en_i        : in     vl_logic;
        tunning_word_i  : in     vl_logic_vector(10 downto 0);
        load_data_in    : in     vl_logic_vector(7 downto 0);
        load_addr_in    : in     vl_logic_vector(13 downto 0);
        load_en_in      : in     vl_logic;
        nco_data_out    : out    vl_logic_vector(7 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MAX_ADDR : constant is 1;
    attribute mti_svvh_generic_type of STROBE_MAX : constant is 1;
end nco;
