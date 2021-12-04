`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/04 13:44:33
// Design Name: 
// Module Name: ID_PIPE_REG
// 
//////////////////////////////////////////////////////////////////////////////////


module id_pipe_reg
(
    input wire clk,
    input wire rst,
    input wire [31:0] pc_in,
    input wire [31:0] instr_in,
    input wire id_allowin,

    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [ 5:0] op,
    output wire [ 4:0] sa,
    output wire [15:0] imm,
    output wire [25:0] j_imm,
    output wire [ 4:0] rsc,
    output wire [ 4:0] rtc,
    output wire [ 4:0] rdc
);


reg [31:0] pc, instr;

// cache the pipeline signal and data
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        pc      <= 32'h003f_fffc;
        instr   <= 32'h0000_0000;
    end
    else if(id_allowin) begin
        pc      <= pc_in;
        instr   <= instr_in;
    end
    else begin
    
    end
end

// dispatcher all the op data segment
assign pc_out    = pc;
assign instr_out = instr;
assign op        = instr[31:26];
assign imm       = instr[15: 0];
assign j_imm     = instr[25: 0];
assign sa        = instr[10: 6];
assign rsc       = instr[25:21];
assign rtc       = instr[20:16];
assign rdc       = instr[15:11];


endmodule
