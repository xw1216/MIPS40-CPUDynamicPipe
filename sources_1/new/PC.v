`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/10/31 15:36:47
// Design Name: 
// Module Name: PC
// 
//////////////////////////////////////////////////////////////////////////////////


module pc(
    input wire clk,
    input wire rst,
    input wire allowin,
    
    input wire  [31:0] npc,
    output reg  [31:0] pc
);

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        pc <= 32'h0040_0000;
    end
    else if (allowin & ~rst) begin
        pc <= npc;
    end
    else begin
    
    end
end

endmodule
