`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/04 12:07:28
// Design Name: 
// Module Name: PIPE_MEM
// 
//////////////////////////////////////////////////////////////////////////////////


module pipe_mem
(
    input wire clk,
    input wire mem_clk,
    input wire rst,
    input wire flush_mem_wb,
    input wire ex_wb,
    
    input wire wb_allowin,
    input wire exe_mem_validto,
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
    
    output wire [31:0] pc,
    output wire [31:0] rt,
    
    output wire mem_allowin,
    output wire mem_wb_validto,
    
    output wire [31:0] wb_result,
    output wire [ 4:0] rdc_mem,
    
    output wire [31:0] bypass_mem,
    output wire mem_rdc_valid,
    output wire bypass_rdc_valid,
    output wire rf_we,
    
    output wire mem_mfc0_instr,
    // exception trans
    output wire ex,
    output wire [ 4:0] ex_code,
    output wire [ 0:0] cp0_rd_mux_sel,
    output wire cp0_we,
    output wire [ 4:0] cp0_rdc,
    output wire eret_flush,
    output wire branch_delay
    
);

reg mem_valid;
wire mem_ready_go;

assign mem_allowin = !mem_valid || (mem_ready_go && wb_allowin);
assign mem_wb_validto = mem_valid && mem_ready_go && (!flush_mem_wb);
assign mem_ready_go = 1;

always @ (posedge clk) begin
    if(rst) begin
        mem_valid <= 1'b0;
    end
    else if(mem_allowin) begin
        mem_valid <= exe_mem_validto;
    end
end

wire dmem_we;
wire [31:0] alu_result;
wire [ 1:0] rd_mux_sel;
wire [31:0] dmem_mapper_out;
wire [31:0] dmem_out;
wire [31:0] hi, lo;

wire mfc0_instr;
assign mem_mfc0_instr = mfc0_instr & mem_valid;

wire ex_no_write;
assign ex_no_write = ex || ex_wb;

mem_pipe_reg mem_pipe_reg
(
    .clk(clk),
    .mem_allowin(exe_mem_validto & mem_allowin),
    .bypass_rdc_valid_in(bypass_rdc_valid_in),
    
    .dmem_we_in(dmem_we_in),
    .rf_we_in(rf_we_in),
    
    .pc_in(pc_in),
    .rt_in(rt_in),
    .alu_result_in(alu_result_in),
    .rdc_exe_in(rdc_exe_in),
    
    .rd_mux_sel_in(rd_mux_sel_in), 
    
    .lo_in(lo_in),
    .hi_in(hi_in),
    
    .mfc0_instr_in(mfc0_instr_in),
    // exception trans
    .ex_in(ex_in),
    .ex_code_in(ex_code_in),
    .cp0_rd_mux_sel_in(cp0_rd_mux_sel_in),
    .cp0_we_in(cp0_we_in),
    .cp0_rdc_in(cp0_rdc_in),
    .eret_flush_in(eret_flush_in),
    .branch_delay_in(branch_delay_in),
    
    .dmem_we(dmem_we),
    .rf_we(rf_we),
    
    .pc(pc),
    .rt(rt),
    .alu_result(alu_result),
    .rdc_mem(rdc_mem),
    
    .rd_mux_sel(rd_mux_sel),
    .bypass_rdc_valid(bypass_rdc_valid),
    
    .lo(lo),
    .hi(hi),
    
    .mfc0_instr(mfc0_instr),
    // exception trans
    .ex(ex),
    .ex_code(ex_code),
    .cp0_rd_mux_sel(cp0_rd_mux_sel),
    .cp0_we(cp0_we),
    .cp0_rdc(cp0_rdc),
    .eret_flush(eret_flush),
    .branch_delay(branch_delay)
);

assign mem_rdc_valid = bypass_rdc_valid & mem_valid;

// data addr may can be customized
vaddr_mapper dmem_mapper(
    .vaddr(alu_result),
    .addr(dmem_mapper_out)
);

dmem dmem(
    .clka(mem_clk),
    .addra(dmem_mapper_out[12:2]),
    .dina(rt),
    .wea(dmem_we && (!ex_no_write) && mem_valid),
    .douta(dmem_out)
);

mux4 rd_mux(
    .in0(alu_result),
    .in1(dmem_out),
    .in2(hi),
    .in3(lo),
    .sel(rd_mux_sel),
    .out(wb_result)
);

assign bypass_mem = wb_result;

endmodule
