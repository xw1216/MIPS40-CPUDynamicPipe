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
    
    input wire [31:0] pc_in,
    input wire [31:0] rt_in,
    input wire [31:0] alu_result_in,
    input wire [ 4:0] rdc_exe_in,
    
    input wire [ 1:0] rd_mux_sel_in, 
    
    input wire [31:0] lo_in,
    input wire [31:0] hi_in,
    
    input wire mfc0_instr_in,
    // exception trans
    input wire ex_in,
    input wire [ 4:0] ex_code_in,
    input wire [ 0:0] cp0_rd_mux_sel_in,
    input wire cp0_we_in,
    input wire [ 4:0] cp0_rdc_in,
    input wire eret_flush_in,
    input wire branch_delay_in,
    
    output reg dmem_we,
    output reg rf_we,
    
    output reg [31:0] pc,
    output reg [31:0] rt,
    output reg [31:0] alu_result,
    output reg [ 4:0] rdc_mem,
    
    output reg [ 1:0] rd_mux_sel,
    output reg bypass_rdc_valid,
    
    output reg [31:0] lo,
    output reg [31:0] hi,
    
    output reg mfc0_instr,
    // exception trans
    output reg ex,
    output reg [ 4:0] ex_code,
    output reg [ 0:0] cp0_rd_mux_sel,
    output reg cp0_we,
    output reg [ 4:0] cp0_rdc,
    output reg eret_flush,
    output reg branch_delay
);


always @ (posedge clk) begin
    if(mem_allowin) begin
        dmem_we     <= dmem_we_in;
        rf_we       <= rf_we_in;
        pc          <= pc_in;
        rt          <= rt_in;
        alu_result  <= alu_result_in;
        rdc_mem     <= rdc_exe_in;
        rd_mux_sel  <= rd_mux_sel_in;
        bypass_rdc_valid <= bypass_rdc_valid_in;
        hi          <= hi_in;
        lo          <= lo_in;
        
        mfc0_instr      <= mfc0_instr_in;
        ex              <= ex_in;
        ex_code         <= ex_code_in;
        cp0_rd_mux_sel  <= cp0_rd_mux_sel_in;
        cp0_we          <= cp0_we_in;
        cp0_rdc         <= cp0_rdc_in;
        eret_flush      <= eret_flush_in;
        branch_delay    <= branch_delay_in;
    end
end

endmodule
