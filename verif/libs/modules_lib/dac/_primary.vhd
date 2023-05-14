library verilog;
use verilog.vl_types.all;
entity dac is
    port(
        nco_data_i      : in     vl_logic_vector(7 downto 0);
        scale           : in     vl_logic_vector(1 downto 0);
        dac_o           : out    vl_logic_vector(9 downto 0)
    );
end dac;
