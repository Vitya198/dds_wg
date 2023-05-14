library verilog;
use verilog.vl_types.all;
entity dig_core_tb is
    generic(
        NUMBER_OF_WAVEFORM_DATA: integer := 16384
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of NUMBER_OF_WAVEFORM_DATA : constant is 1;
end dig_core_tb;
