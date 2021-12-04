`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/05 09:33:30
// Design Name: 
// Module Name: WB_PIPE_REG
// 
//////////////////////////////////////////////////////////////////////////////////


module wb_pipe_reg
(
    input wire clk,
    input wire wb_allowin,
    input wire bypass_rdc_valid_in,
    
    input wire [31:0] wb_result_in,
    input wire [ 4:0] rdc_mem_in,
    
    input wire rf_we_in,
    
    input wire cp0_rd_mux_sel_in,
    input wire cp0_we_in,
    input wire ex_wb_in,
    input wire eret_flush_in,
    input wire branch_delay_wb_in,
    
    input wire [ 4:0] cp0_rdc_in,
    input wire [ 5:0] int_sig_in,
    input wire [31:0] cp0_data_in,
    input wire [31:0] pc_in,
    input wire [ 4:0] ex_code_in,
    
    output reg [31:0] wb_result,
    output reg [ 4:0] rdc_wb,
    output reg rf_we,
    output reg bypass_rdc_valid,
    
    output reg cp0_rd_mux_sel,
    output reg cp0_we,
    output reg ex_wb,
    output reg eret_flush,
    output reg branch_delay_wb,
    
    output reg [ 4:0] cp0_rdc,
    output reg [ 5:0] int_sig,
    output reg [31:0] cp0_data,
    output reg [31:0] pc,
    output reg [ 4:0] ex_code
);

always @ (posedge clk) begin
    if(wb_allowin) begin
        wb_result   <= wb_result_in;
        rdc_wb      <= rdc_mem_in;
        rf_we       <= rf_we_in;
        bypass_rdc_valid <= bypass_rdc_valid_in;
        
        cp0_rd_mux_sel <= cp0_rd_mux_sel_in;
        cp0_we <= cp0_we_in;
        ex_wb <= ex_wb_in;
        eret_flush <= eret_flush_in;
        branch_delay_wb <= branch_delay_wb_in;
        cp0_rdc <= cp0_rdc_in;
        int_sig <= int_sig_in;
        cp0_data <= cp0_data_in;
        pc <= pc_in;
        ex_code <= ex_code_in;
    end
end

endmodule
