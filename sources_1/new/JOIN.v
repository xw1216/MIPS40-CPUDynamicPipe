`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/04 12:39:14
// Design Name: 
// Module Name: JOIN
// 
//////////////////////////////////////////////////////////////////////////////////


module j_join
(
    input wire [3:0] pc_slot_in,
    input wire [25:0] imm_in,
    output wire [31:0] dout
);

assign dout = {pc_slot_in[3:0], imm_in[25:0], 2'b00};

endmodule
