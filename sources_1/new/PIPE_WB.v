`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/04 12:07:44
// Design Name: 
// Module Name: PIPE_WB
// 
//////////////////////////////////////////////////////////////////////////////////


module pipe_wb
(
    input wire clk,
    input wire rst,
    input wire mem_clk,
    
    input wire mem_wb_validto,
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
    
    output wire wb_allowin,
    
    output wire [ 4:0] rdc_wb,
    output wire [31:0] wb_result,
    
    output wire rf_we,
    
    output wire [31:0] bypass_wb,
    output wire wb_rdc_valid,
    
    output wire ex,
    output wire flush,
    output wire hlt,
    output wire eret,
    // STATUS region
    output wire [ 0:0] ie,
    output wire [ 0:0] exl,
    output wire [ 7:0] int_mask,
    // CAUSE regoin
    output wire [ 7:0] int_sig,
    // EPC region
    output wire [31:0] epc_out
);

reg wb_valid;
wire wb_ready_go;

wire cp0_rd_mux_sel;
wire cp0_we;
wire ex_wb;
wire eret_flush;
wire branch_delay_wb;

wire [ 4:0] cp0_rdc;
wire [ 5:0] int_sig;
wire [31:0] cp0_data;
wire [31:0] pc;
wire [ 4:0] ex_code;

wire [31:0] wb_result_temp;
wire rf_we_temp;
wire [31:0] cp0_data_out;

assign wb_allowin = !wb_valid || wb_ready_go;
assign wb_ready_go = 1;

always @ (posedge clk) begin
    if(rst) begin
        wb_valid <= 1'b0;
    end
    else if(wb_allowin) begin
        wb_valid <= mem_wb_validto;
    end
end

wire bypass_rdc_valid;

wb_pipe_reg wb_pipe_reg
(
    .clk(clk),
    .wb_allowin(mem_wb_validto & wb_allowin),
    .bypass_rdc_valid_in(bypass_rdc_valid_in),
    
    .wb_result_in(wb_result_in),
    .rdc_mem_in(rdc_mem_in),
    
    .rf_we_in(rf_we_in),
    
    .cp0_rd_mux_sel_in(cp0_rd_mux_sel_in),
    .cp0_we_in(cp0_we_in),
    .ex_wb_in(ex_wb_in),
    .eret_flush_in(eret_flush_in),
    .branch_delay_wb_in(branch_delay_wb_in),
    
    .cp0_rdc_in(cp0_rdc_in),
    .int_sig_in(int_sig_in),
    .cp0_data_in(cp0_data_in),
    .pc_in(pc_in),
    .ex_code_in(ex_code_in),
    
    .wb_result(wb_result_temp),
    .rdc_wb(rdc_wb),
    .rf_we(rf_we_temp),
    .bypass_rdc_valid(bypass_rdc_valid),
    
    .cp0_rd_mux_sel(cp0_rd_mux_sel),
    .cp0_we(cp0_we),
    .ex_wb(ex_wb),
    .eret_flush(eret_flush),
    .branch_delay_wb(branch_delay_wb),
    
    .cp0_rdc(cp0_rdc),
    .int_sig(int_sig),
    .cp0_data(cp0_data),
    .pc(pc),
    .ex_code(ex_code)
);

mux2 wb_result_mux
(
    .in0(wb_result_temp), 
    .in1(cp0_data_out),
    .sel(cp0_rd_mux_sel),
    .out(wb_result)
);

assign rf_we = rf_we_temp & (!ex_wb) & wb_valid;

assign wb_rdc_valid = bypass_rdc_valid & wb_valid;

assign bypass_wb = wb_result;

cp0 cp0
(
    // input 
    .rst(rst),
    .clk(clk),
    .mem_clk(mem_clk),
    
    .cp0_we(cp0_we && wb_valid),
    .ex_wb_in(ex_wb && wb_valid),
    .eret_flush_in(eret_flush && wb_valid),
    .branch_delay_wb(branch_delay),
    
    .cp0_rdc_in(cp0_rdc),
    .int_sig_in(int_sig),
    .cp0_data_in(cp0_data),
    .epc_in(pc),
    .ex_code_in(ex_code),
    
    // output
    .ex(ex),
    .flush(flush),
    .hlt(hlt),
    .eret(eret),
    // STATUS region
    .ie(ie),
    .exl(exl),
    .int_mask(int_mask),
    // CAUSE regoin
    .int_sig(int_sig),
    // EPC region
    .epc_out(epc_out),
    .cp0_data_out(cp0_data_out)
);

endmodule
