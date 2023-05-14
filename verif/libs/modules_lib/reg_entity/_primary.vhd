library verilog;
use verilog.vl_types.all;
entity reg_entity is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        din_i           : in     vl_logic;
        set_i           : in     vl_logic;
        dout_o          : out    vl_logic
    );
end reg_entity;
