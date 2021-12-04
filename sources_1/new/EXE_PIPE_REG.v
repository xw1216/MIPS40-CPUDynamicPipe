`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/05 09:32:37
// Design Name: 
// Module Name: EXE_PIPE_REG
// 
//////////////////////////////////////////////////////////////////////////////////


module exe_pipe_reg
(
    input wire clk,
    input wire exe_allowin,
    input wire bypass_rdc_valid_in,
    
    input wire [31:0] pc_in,
    input wire [ 4:0] sa_in,
    input wire [15:0] imm_in,
    input wire [31:0] rs_in,
    input wire [31:0] rt_in,
    input wire [ 4:0] rdc_in,
    
    input wire [ 3:0] aluc_in,
    input wire [ 0:0] ext5_sel_in,
    input wire [ 1:0] alu_a_sel_in,
    input wire [ 1:0] alu_b_sel_in,
    input wire [ 1:0] rd_mux_sel_in,
    input wire [ 1:0] lo_mux_sel_in,
    input wire [ 1:0] hi_mux_sel_in,
    input wire mul_sign_in,
    input wire [ 1:0] exe_bypass_sel_in,
    // memory write signal in 
    input wire dmem_we_in,
    input wire rf_we_in,
    input wire lo_we_in,
    input wire hi_we_in,
    // specific instruction pipeline block
    input wire lw_instr_in,
    input wire mfc0_instr_in,
    input wire jump_instr_in,
    // exception trans
    input wire ex_in,
    input wire [ 4:0] ex_code_in,
    input wire [ 0:0] cp0_rd_mux_sel_in,
    input wire cp0_we_in,
    input wire [ 4:0] cp0_rdc_in,
    input wire eret_flush_in,
    input wire branch_delay_in,
    
    output reg [31:0] pc,
    output reg [ 4:0] sa,
    output reg [15:0] imm,
    output reg [31:0] rs,
    output reg [31:0] rt,
    output reg [ 4:0] rdc,
    
    output reg [ 3:0] aluc,
    output reg [ 0:0] ext5_sel,
    output reg [ 1:0] alu_a_sel,
    output reg [ 1:0] alu_b_sel,
    output reg [ 1:0] rd_mux_sel,
    output reg [ 1:0] lo_sel,
    output reg [ 1:0] hi_sel,
    output reg [ 0:0] mul_sign,
    output reg [ 1:0] exe_bypass_sel,
    // memory write signal in 
    output reg dmem_we,
    output reg rf_we,
    output reg lo_we,
    output reg hi_we,
    // bypass
    output reg bypass_rdc_valid,
    output reg lw_instr,
    output reg mfc0_instr,
    output reg jump_instr,
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
    if(exe_allowin) begin
        pc  <= pc_in;
        sa  <= sa_in;
        imm <= imm_in;
        rs  <= rs_in;
        rt  <= rt_in;
        rdc <= rdc_in;
        
        aluc <= aluc_in;
        ext5_sel <= ext5_sel_in;
        alu_a_sel <= alu_a_sel_in;
        alu_b_sel <= alu_b_sel_in;
        rd_mux_sel <= rd_mux_sel_in;
        lo_sel  <= lo_mux_sel_in;
        hi_sel  <= hi_mux_sel_in;
        mul_sign <= mul_sign_in;
        exe_bypass_sel <= exe_bypass_sel_in;
        
        dmem_we <= dmem_we_in;
        rf_we <= rf_we_in;
        lo_we <= lo_we_in;
        hi_we <= hi_we_in;
        
        bypass_rdc_valid <= bypass_rdc_valid_in;
        lw_instr <= lw_instr_in;
        mfc0_instr <= mfc0_instr_in;
        jump_instr <= jump_instr_in;
        
        ex <= ex_in;
        ex_code <= ex_code_in;
        cp0_rd_mux_sel <= cp0_rd_mux_sel_in;
        cp0_we <= cp0_we_in;
        cp0_rdc <= cp0_rdc_in;
        eret_flush <= eret_flush_in;
        branch_delay <= branch_delay_in;
    end
end

endmodule
