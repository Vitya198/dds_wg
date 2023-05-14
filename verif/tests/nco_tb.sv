module nco_tb();
//Inputs
logic         clk;
logic         rst_n;
logic         we;
logic         sys_en;
logic [7:0]   data_in;
logic [10:0]  freq_step;

//Outputs
logic wr_done;
logic [7:0] data_out;

logic [7:0] testvectors [12:0];

//nco Inst
nco nco_dut(
    .clk         (clk),
    .rst_n       (rst_n),
    .we_i        (we),
    .sys_en      (sys_en),
    .data_i      (data_in),
    .freq_step_i (freq_step),
    .wr_done     (wr_done),
    .data_o      (data_out)
);

int i;
int j;
real fs = 96e3;
real dt = 1 / fs; 
real f  = 100;
real N  = 6000;
real pi = 3.14159265359;
//vetors: ???
real nt [$];
real xt;
real yt [$];

//---------------------------------------------------
initial begin
  for (i=0;i<N;i=i+1) begin
    xt    = 2*pi*f*dt*i;
    yt[i] =127* $sin(xt);    //$cos(2*pi*f*i*dt);
    $display("%0d",  $realtobits(yt[i]));
  end
end
  //nt = np.arange(N);
  //xt = nt*dt;
  //yt = 128*np.cos(2*np.pi*f*xt);
  //testvectors = $cast(yt[i]);  

//---------------------------------------------------
initial begin
clk       =  0;
rst_n     =  0;
sys_en    =  0;
we        =  0;
freq_step =  0;
#1us;
rst_n   =  1;

//test comes here
  sys_en    =  1;
  #1ns;  
  we        =  0;
  #1ns;  
  freq_step =  11'd10;
  #1ns;
  we  = 1;

  //$readmemh("waveform_gen_behav_modell.py", testvectors):
  if(we == 1 & sys_en == 1) begin
    for(j = 0; j  < N; j ++) begin
      data_in = yt[j]; //8 bit
      @(posedge clk);

    end
  end
  #5ns
  we = 0;
  #5ms;
  sys_en = 0;
  //end of the test
  #10ns;
end 
//---------------------------------------------------
always begin 
 clk = 0;
 #10ns;
 clk = 1;
 #10ns;
end 
//---------------------------------------------------
endmodule