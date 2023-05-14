library verilog;
use verilog.vl_types.all;
entity reg_array_entity is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        set_i           : in     vl_logic;
        din_i           : in     vl_logic_vector(7 downto 0);
        en_o            : out    vl_logic;
        dout_o          : out    vl_logic_vector(7 downto 0)
    );
end reg_array_entity;
