`timescale 1ns/1ps
module sine_wave(Clk,data_out);
//declare input and output
    input Clk;
    output [7:0] data_out;
//declare the sine ROM - 30 registers each 8 bit wide.  
    reg [7:0] sine [0:29];
//Internal signals  
    integer i;  
    reg [7:0] data_out; 
//Initialize the sine rom with samples. 
    initial begin
        i = 0;
        sine[0] = 0;
        sine[1] = 16;
        sine[2] = 31;
        sine[3] = 45;
        sine[4] = 58;
        sine[5] = 67;
        sine[6] = 74;
        sine[7] = 77;
        sine[8] = 77;
        sine[9] = 74;
        sine[10] = 67;
        sine[11] = 58;
        sine[12] = 45;
        sine[13] = 31;
        sine[14] = 16;
        sine[15] = 0;
        sine[16] = -16;
        sine[17] = -31;
        sine[18] = -45;
        sine[19] = -58;
        sine[20] = -67;
        sine[21] = -74;
        sine[22] = -77;
        sine[23] = -77;
        sine[24] = -74;
        sine[25] = -67;
        sine[26] = -58;
        sine[27] = -45;
        sine[28] = -31;
        sine[29] = -16;
    end
    
    //At every positive edge of the clock, output a sine wave sample.
    always@ (posedge Clk)
    begin
        data_out = sine[i];
        i = i+ 1;
        if(i == 30)
            i = 0;
    end

endmodule

module Multiplexer(
    input [7:0] in0,  // First input (Grounded, 0)
    input [7:0] in1,  // Second input (Sine wave)
    input sel,        // Selection signal (Enable from PISO)
    output reg [7:0] out
);
    always @(*) begin
        if (sel)
            out = in1;  // Select sine wave
        else
            out = in0;  // Select ground (0)
    end
endmodule
module PISO (
    input clk,               // Clock signal
    input reset,             // Reset signal
    input load,              // Load enable
    input [7:0] parallel_in, // 8-bit parallel data input
    output reg serial_out    // Serial data output
);
    reg [7:0] shift_reg; // Internal shift register

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the shift register
            shift_reg <= 8'b0;
            serial_out <= 1'b0;
        end else if (load) begin
            // Load parallel data into the shift register
            shift_reg <= parallel_in;
        end else begin
            // Shift data to the right
            serial_out <= shift_reg[0];
            shift_reg <= shift_reg >> 1;
        end
    end
endmodule


// Top Module Connecting All Components
module TopModule(
    input clk,
    input clk2, 
    input clk3,          // Global clock
    input reset,            // Reset signal for PISO
    input [7:0] parallel_in, // Parallel input to PISO
    input load,             // Load enable signal for PISO
    output [7:0] mux_out,
    inout piso_out,
    inout [7:0] data_out,
    inout [7:0] data_out2
);
     // Sine wave output from the sine wave generator
              // Serial output from PISO

    // Instantiate the sine wave generator
    sine_wave sineGen (
        .Clk(clk2),
        .data_out(data_out)
    );
    sine_wave sinegen2 (
        .Clk(clk3),
        .data_out(data_out2));

    // Instantiate the PISO module
    PISO piso (
        .clk(clk),
        .reset(reset),
        .load(load),
        .parallel_in(parallel_in),
        .serial_out(piso_out)
    );

    // Instantiate the multiplexer
    Multiplexer mux (
        .in0(data_out2),         // Grounded input
        .in1(data_out),    // Sine wave input
        .sel(piso_out),     // Enable signal from PISO
        .out(mux_out)
    );
endmodule
