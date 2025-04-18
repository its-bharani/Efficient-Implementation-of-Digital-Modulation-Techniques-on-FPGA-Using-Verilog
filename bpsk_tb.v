module tb();
  reg clk;
  reg clk2;
  //reg clk3;
  reg reset;
  reg [7:0] parallel_in;
  reg load;
  wire [7:0] mux_out;
  wire piso_out;
  wire [7:0] data_out;
  wire [7:0] data_out2;
  
  TopModule dut(clk,clk2,reset,parallel_in,load,mux_out,piso_out,data_out,data_out2);
 
  initial begin
    clk=0;
    forever #10 clk=~clk;
  end
  initial begin
    clk2=0;
    forever #0.1 clk2=~clk2;
  end
  //initial begin
  //clk3=0;
  //forever #0.1 clk3=~clk3;
  //end
  initial begin
    $dumpfile("top.vcd");
     $dumpvars;
  
    reset=1;
    #10 reset=0; load=1;
    parallel_in=1001_1001;
    #10 load=0;
  end
  initial begin
    #2000
    $finish();
  end
endmodule
