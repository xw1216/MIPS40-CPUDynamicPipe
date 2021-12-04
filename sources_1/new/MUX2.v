`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/10/27 17:51:30
// Design Name: 
// Module Name: MUX2
// 
//////////////////////////////////////////////////////////////////////////////////


module mux2
#( parameter WIDTH = 32 )
(
    input wire [WIDTH - 1 : 0] in0, in1,
    input wire [0 : 0] sel,
    output wire [WIDTH - 1 : 0] out
);

assign out = ( { WIDTH{sel == 1'd0}} & in0 )
                    |   ( { WIDTH{sel == 1'd1}} & in1 );
endmodule