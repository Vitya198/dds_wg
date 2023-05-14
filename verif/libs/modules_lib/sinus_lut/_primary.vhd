library verilog;
use verilog.vl_types.all;
entity sinus_lut is
    generic(
        ADDR_WIDTH      : integer := 14;
        DATA_WIDTH      : integer := 8;
        DEPTH           : integer := 16384
    );
    port(
        clk             : in     vl_logic;
        we              : in     vl_logic;
        addr            : in     vl_logic_vector;
        data_in         : in     vl_logic_vector;
        data_out        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DEPTH : constant is 1;
end sinus_lut;
