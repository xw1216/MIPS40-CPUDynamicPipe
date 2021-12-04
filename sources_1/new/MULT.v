`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/08 15:49:00
// Design Name: 
// Module Name: MULT
// 
//////////////////////////////////////////////////////////////////////////////////


module mult
(
    input wire mul_sign,
    input wire [31:0] a,
    input wire [31:0] b,
    output wire [63:0] z,
    output wire [63:0] z_unsign
);

assign z = $signed(a) * $signed(b);
assign z_unsign = a * b;


endmodule
