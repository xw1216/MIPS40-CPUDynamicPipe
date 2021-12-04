`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/05 09:33:04
// Design Name: 
// Module Name: MEM_PIPE_REG
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_pipe_reg
(
    input wire clk,
    input wire mem_allowin,
    input wire bypass_rdc_valid_in,
    
    input wire dmem_we_in,
    input wire rf_we_in,
    
    input wire [31:0] rt_in,
    input wire [31:0] alu_result_in,
    input wire [ 4:0] rdc_exe_in,
    
    input wire [ 1:0] rd_mux_sel_in, 
    
    input wire [31:0] lo_in,
    input wire [31:0] hi_in,
    
    output reg dmem_we,
    output reg rf_we,
    
    output reg [31:0] rt,
    output reg [31:0] alu_result,
    output reg [ 4:0] rdc_mem,
    
    output reg [ 1:0] rd_mux_sel,
    output reg bypass_rdc_valid,
    
    output reg [31:0] lo,
    output reg [31:0] hi
);


always @ (posedge clk) begin
    if(mem_allowin) begin
        dmem_we     <= dmem_we_in;
        rf_we       <= rf_we_in;
        rt          <= rt_in;
        alu_result  <= alu_result_in;
        rdc_mem     <= rdc_exe_in;
        rd_mux_sel  <= rd_mux_sel_in;
        bypass_rdc_valid <= bypass_rdc_valid_in;
        hi          <= hi_in;
        lo          <= lo_in;
    end
end

endmodule
