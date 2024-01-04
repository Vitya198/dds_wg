module wm_data_slave(

input wire rst_n,
input wire aud_bclk, 
input wire aud_daclrc, 
input wire aud_dacdat,

output logic [7:0] analog_data
//output logic comm_en 
);

logic sample_flag; //Jelezzük, amint jött egy új adat 


logic [4:0] data_index; // 0-tól számolunk felfelé (mert egyesével fogadunk 16 bitet) 
logic [15:0] dac_data_reg; //az adatokat ide mentjük 
logic [8:0] aud_prscl; //a mintavételi frekvenciát állítjuk vele

//assign comm_en = aud_daclrc; //A master jelez, hogy mikor kezdődik az adatátvitel

always @(negedge aud_bclk, negedge rst_n) begin
    if(!rst_n) begin
        data_index    <=  15;
        sample_flag   <=  0;
        dac_data_reg  <=  'd0;
    end 
    else begin
        if(aud_daclrc == 0) begin //Ha van adatátvitel 
            sample_flag <=  1;
            data_index  <=  15;
        end 
        if(sample_flag== 1) begin //Ha engedélyezett az adatfogadás 
            if(data_index > 0) begin 
                dac_data_reg[data_index] <= aud_dacdat; //Mentjük az adatot 
                data_index <= data_index - 1; 
            end 
            else begin 
                dac_data_reg[data_index] <= aud_dacdat; //Mentjük az utolsó adatot 
                sample_flag <= 0; //Jelezzük, hogy jött egy új minta 
            end 
        end
    end
    if(sample_flag==0) begin
        analog_data <= dac_data_reg[15:8];
    end
    
end
endmodule
