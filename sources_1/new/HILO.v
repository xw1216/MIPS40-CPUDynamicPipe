`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/08 15:57:00
// Design Name: 
// Module Name: HILO
// Project Name: 
// 
//////////////////////////////////////////////////////////////////////////////////


module hilo
(
    input wire clk,
    input wire we,
    input wire [31:0] in,
    output reg [31:0] out
);

always @(posedge clk) begin
    if(we) begin
        out <= in;
    end
end

endmodule
