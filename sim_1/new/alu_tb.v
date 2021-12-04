`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/10/28 12:51:18
// Design Name: 
// Module Name: alu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_tb();
reg [31:0] a;
reg [31:0] b;
reg [3:0] aluc;
wire [31:0] result;
wire [0:0] zr;
wire [0:0] cy;
wire [0:0] ng;
wire [0:0] of;

alu uut(
.src1(a),
.src2(b),
.aluc(aluc),
.result(result),
.zr(zr),
.cy(cy),
.ng(ng),
.of(of)
);

initial
begin
    // ADDU
    a = 32'hffffffff;
    b = 32'h00000001;
    aluc = 4'b0000;
    
    // SUBU
    #5
    a = 32'h00000000;
    b = 32'h00000001;
    aluc = 4'b0001;
    
    // ADD
    #5
    a = 32'h7fffffff;
    b = 32'h00000001;
    aluc = 4'b0010;
    
    //SUB
    #5
    a = 32'h80000000;
    b = 32'h00000001;
    aluc = 4'b0011;
    
    // AMD
    #5
    a = 32'h55555555;
    b = 32'haaaaaaaa;
    aluc = 4'b0100;
    
    // XOR
    #5
    aluc = 4'b0110;
    
    // NOR
    #5
    aluc = 4'b0111;
    
    // LUI
    #5
    b = 32'hffff0000;
    aluc = 4'b1001;
    
    //SLTU
    #5
    a = 32'hffffffff;
    b = 32'hffffffff;
    aluc = 4'b1010;
    #5
    a = 32'hffff0000;
    #5
    b = 32'h0000ffff;
    
    // SLT
    #5
    a = 32'h0000ffff;
    b = 32'h0000ffff;
    aluc = 4'b1011;
    #5
    a = 32'h00000fff;
    #5
    b = 32'h000000ff;
    
    // SRA
    #5
    a = 32'h00000000;
    b = 32'haaaaaaaa;
    aluc = 4'b1100;
    #5
    a = 32'h00000001;
    #5
    a = 32'h00000002;
    #5
    a = 32'h00000001;
    b = 32'h00000001;
    
    // SRA
    #5
    a = 32'h00000000;
    b = 32'haaaaaaaa;
    aluc = 4'b1101;
    #5
    a = 32'h00000001;
    #5
    a = 32'h00000002;
    #5
    a = 32'h00000001;
    b = 32'h00000001;
    
    // SLL/SLR
    #5
    a = 32'h00000001;
    b = 32'hcccccccc;
    aluc = 4'b1110;
    #5
    a = 32'h00000002;
    
    // ref test
    #5
    a = 32'hffffffff;
    b = 32'h80000000;
    aluc = 4'b0011;
    
    #5
    a = 32'h0000ffff;
    b = 32'h00000000;
    aluc = 4'b0011;
    
    #5
    a = 32'h00000000;
    b = 32'h00000000;
    aluc = 4'b1110;
    
    #5
    a = 32'h00000000;
    b = 32'h00000001;
    aluc = 4'b1010;
    
    #5
    $stop;
end

endmodule

