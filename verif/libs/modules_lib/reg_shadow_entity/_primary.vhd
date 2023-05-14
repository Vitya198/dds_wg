library verilog;
use verilog.vl_types.all;
entity reg_shadow_entity is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        set_i           : in     vl_logic;
        din_l_i         : in     vl_logic_vector(7 downto 0);
        din_h_i         : in     vl_logic_vector(7 downto 0);
        dout_o          : out    vl_logic_vector(15 downto 0)
    );
end reg_shadow_entity;
