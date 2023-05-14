library verilog;
use verilog.vl_types.all;
entity reg_file is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        uart_wr_i       : in     vl_logic;
        uart_rd_i       : in     vl_logic;
        uart_addr_i     : in     vl_logic_vector(7 downto 0);
        uart_data_i     : in     vl_logic_vector(7 downto 0);
        reg_file_data_o : out    vl_logic_vector(7 downto 0);
        nco_en_o        : out    vl_logic;
        tunning_word_o  : out    vl_logic_vector(10 downto 0);
        dac_scale_o     : out    vl_logic_vector(1 downto 0)
    );
end reg_file;
