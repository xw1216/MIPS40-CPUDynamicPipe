`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/10/27 16:52:30
// Design Name: 
// Module Name: MUX8
// 
//////////////////////////////////////////////////////////////////////////////////


module mux8
#( parameter WIDTH = 32 )
(
    input wire [WIDTH - 1 : 0] in0, in1, in2, in3, in4, in5, in6, in7,
    input wire [2 : 0] sel,
    output wire [WIDTH - 1 : 0] out
);

assign out = ( { WIDTH{sel == 3'd0}} & in0 )
                    |   ( { WIDTH{sel == 3'd1}} & in1 )
                    |   ( { WIDTH{sel == 3'd2}} & in2 )
                    |   ( { WIDTH{sel == 3'd3}} & in3 )
                    |   ( { WIDTH{sel == 3'd4}} & in4 )
                    |   ( { WIDTH{sel == 3'd5}} & in5 )
                    |   ( { WIDTH{sel == 3'd6}} & in6 )
                    |   ( { WIDTH{sel == 3'd7}} & in7 );
endmodule
