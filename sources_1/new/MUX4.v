`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/10/27 17:50:30
// Design Name: 
// Module Name: MUX4
// 
//////////////////////////////////////////////////////////////////////////////////


module mux4
#( parameter WIDTH = 32 )
(
    input wire [WIDTH - 1 : 0] in0, in1, in2, in3,
    input wire [1 : 0] sel,
    output wire [WIDTH - 1 : 0] out
);

assign out = ( { WIDTH{sel == 2'd0}} & in0 )
                    |   ( { WIDTH{sel == 2'd1}} & in1 )
                    |   ( { WIDTH{sel == 2'd2}} & in2 )
                    |   ( { WIDTH{sel == 2'd3}} & in3 );
endmodule