`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/07 19:07:06
// Design Name: 
// Module Name: pipeline_tb
// 
//////////////////////////////////////////////////////////////////////////////////


module pipeline_tb();

//wire [31:0] pc, instr;
reg clk, rst;
reg [15:0] arguments;
wire [15:0] o_test_result;
wire [ 7:0] o_seg;
wire [ 7:0] o_sel;

pipeline uut
(
    .clk_gl(clk),
    .rst(rst),
    
//    .pc_out(pc),
//    .instr_out(instr),
    .arguments(arguments),
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
    arguments[15:8] <= 8'd3;
    arguments[ 7:0] <= 8'd25;
    #2
    rst <= 1'b1;
    # 100000
    rst <= 1'b0;
end

endmodule
