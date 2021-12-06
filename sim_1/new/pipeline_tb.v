`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/07 19:07:06
// Design Name: 
// Module Name: pipeline_tb
// 
//////////////////////////////////////////////////////////////////////////////////


module pipeline_tb();

wire [31:0] pc, instr;
reg clk, rst;
reg [1:0] interrupt;
reg [5:0] arguments;
wire [3:0] o_test_result;
wire [ 7:0] o_seg;
wire [ 7:0] o_sel;

pipeline uut
(
    .clk_gl(clk),
    .rst(rst),
    // external two interrupt signals
    .interrupt(interrupt),
    .arguments(arguments),

    .pc_out(pc),
    .instr_out(instr),
    .o_test_result(o_test_result),
    .o_seg(o_seg),
    .o_sel(o_sel)
);

initial begin
    clk <= 1'b0;
    forever begin
        #5  clk <= 1'b1;
        #5  clk <= 1'b0;
    end
end

initial begin
    arguments <= 6'd60;
    interrupt <= 2'b00;
    #2
    rst <= 1'b1;
    
    #250
    rst <= 1'b0;
    
    #500
    rst <= 1'b1;
    
    #250 
    rst <= 1'b0;
    
//    #3000
//    interrupt <= 2'b10;
//    #1000
//    interrupt <= 2'b00;
//    #1000
//    interrupt <= 2'b01;
//    #1000
//    interrupt <= 2'b00;
//    #1000
//    interrupt <= 2'b01;
//    #1000
//    interrupt <= 2'b10;
//    #1000
//    interrupt <= 2'b01;
//    #1000
//    interrupt <= 2'b00;
    
    
end

endmodule
