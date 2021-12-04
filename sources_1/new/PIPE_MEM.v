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
    
    input wire wb_allowin,
    input wire exe_mem_validto,
    input wire bypass_rdc_valid_in,
    
    input wire dmem_we_in,
    input wire rf_we_in,
    
    input wire [31:0] rt_in,
    input wire [31:0] alu_result_in,
    input wire [ 4:0] rdc_exe_in,
    
    input wire [ 1:0] rd_mux_sel_in,
    
    input wire [31:0] lo_in,
    input wire [31:0] hi_in,
    
    output wire mem_allowin,
    output wire mem_wb_validto,
    
    output wire [31:0] wb_result,
    output wire [ 4:0] rdc_mem,
    
    output wire [31:0] bypass_mem,
    output wire mem_rdc_valid,
    output wire bypass_rdc_valid,
    output wire rf_we
    
);

reg mem_valid;
wire mem_ready_go;

assign mem_allowin = !mem_valid || (mem_ready_go && wb_allowin);
assign mem_wb_validto = mem_valid && mem_ready_go;
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
wire [31:0] rt;
wire [31:0] alu_result;
wire [ 1:0] rd_mux_sel;
wire [31:0] dmem_mapper_out;
wire [31:0] dmem_out;
wire [31:0] hi, lo;


mem_pipe_reg mem_pipe_reg
(
    .clk(clk),
    .mem_allowin(exe_mem_validto & mem_allowin),
    .bypass_rdc_valid_in(bypass_rdc_valid_in),
    
    .dmem_we_in(dmem_we_in),
    .rf_we_in(rf_we_in),
    
    .rt_in(rt_in),
    .alu_result_in(alu_result_in),
    .rdc_exe_in(rdc_exe_in),
    
    .rd_mux_sel_in(rd_mux_sel_in), 
    .lo_in(lo_in),
    .hi_in(hi_in),
    
    .dmem_we(dmem_we),
    .rf_we(rf_we),
    
    .rt(rt),
    .alu_result(alu_result),
    .rdc_mem(rdc_mem),
    
    .rd_mux_sel(rd_mux_sel),
    .bypass_rdc_valid(bypass_rdc_valid),
    .lo(lo),
    .hi(hi)
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
    .wea(dmem_we),
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
