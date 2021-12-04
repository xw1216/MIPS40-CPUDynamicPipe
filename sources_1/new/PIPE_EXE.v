`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/04 12:06:57
// Design Name: 
// Module Name: PIPE_EXE
// 
//////////////////////////////////////////////////////////////////////////////////


module pipe_exe
(
    // clock and pipe control signal input
    input wire clk,
    input wire rst,
    input wire mem_clk,
    input wire mem_allowin,
    input wire id_exe_validto,
    input wire ex_mem,
    input wire ex_wb,
    input wire bypass_rdc_valid_in,
    // flush pipeline
    input wire flush_exe_mem,
    // id pipe data input
    input wire [31:0] pc_in,
    input wire [ 4:0] sa_in,
    input wire [15:0] imm_in,
    input wire [31:0] rs_in,
    input wire [31:0] rt_in,
    input wire [ 4:0] rdc_in,
    // pipe alu mult and mux control
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
    
    
    // pipe control signal
    output wire exe_allowin,
    output wire exe_mem_validto,
    // pipe backward data
    output wire [31:0] pc,
    output wire [31:0] rt,
    output wire [31:0] alu_result,
    output wire [ 4:0] rdc_exe,
    // bypass for id
    output wire [31:0] bypass_exe,
    output wire exe_rdc_valid,
    output wire bypass_rdc_valid,
    // memory write signal out
    output wire dmem_we,
    output wire rf_we,
    // pipe mux signal backward
    output wire [1:0] rd_mux_sel,
    output wire exe_lw_instr,
    output wire exe_mfc0_instr,
    output wire exe_jump_instr,
    // exception trans
    output wire ex,
    output wire [ 4:0] ex_code,
    output wire [ 0:0] cp0_rd_mux_sel,
    output wire cp0_we,
    output wire [ 4:0] cp0_rdc,
    output wire eret_flush,
    output wire branch_delay,
    // hilo register out
    output wire [31:0] lo,
    output wire [31:0] hi

);

reg exe_valid;
wire exe_ready_go;

assign exe_allowin = !exe_valid || (exe_ready_go && mem_allowin);
assign exe_mem_validto = exe_valid && exe_ready_go && (!flush_exe_mem);
assign exe_ready_go = 1;

always @ (posedge clk) begin
    if(rst) begin
        exe_valid <= 1'b0;
    end
    else if(exe_allowin) begin
        exe_valid <= id_exe_validto;
    end
    else begin
    
    end
end

wire [ 4:0] sa;
wire [15:0] imm;
wire [31:0] rs;
wire [ 3:0] aluc;
wire [ 0:0] ext5_sel;
wire [ 1:0] alu_a_sel;
wire [ 1:0] alu_b_sel;
wire [ 1:0] lo_sel;
wire [ 1:0] hi_sel;
wire [ 1:0] exe_bypass_sel;

wire [31:0] ext16_out;
wire [31:0] uext16_out;
wire [31:0] ext5_mux_out;
wire [31:0] alu_a_mux_out;
wire [31:0] alu_b_mux_out;
wire [31:0] lo_mux_out;
wire [31:0] hi_mux_out;
wire [31:0] exe_bypass_mux_out;
wire lw_instr;
wire mfc0_instr;
wire jump_instr;

wire mul_sign;
wire [63:0] mul_prod_sign, mul_prod_unsign;
wire lo_we, hi_we;

wire ex_no_write;
assign ex_no_write = (ex || ex_mem || ex_wb);



exe_pipe_reg exe_pipe_reg
(
    .clk(clk),
    .exe_allowin(id_exe_validto & exe_allowin),
    .bypass_rdc_valid_in(bypass_rdc_valid_in),
    
    .pc_in(pc_in),
    .sa_in(sa_in),
    .imm_in(imm_in),
    .rs_in(rs_in),
    .rt_in(rt_in),
    .rdc_in(rdc_in),
    
    .aluc_in(aluc_in),
    .ext5_sel_in(ext5_sel_in),
    .alu_a_sel_in(alu_a_sel_in),
    .alu_b_sel_in(alu_b_sel_in),
    .rd_mux_sel_in(rd_mux_sel_in),
    .lo_mux_sel_in(lo_mux_sel_in),
    .hi_mux_sel_in(hi_mux_sel_in),
    .mul_sign_in(mul_sign_in),
    .exe_bypass_sel_in(exe_bypass_sel_in),
    // memory write signal in 
    .dmem_we_in(dmem_we_in),
    .rf_we_in(rf_we_in),
    .lw_instr_in(lw_instr_in),
    .jump_instr_in(jump_instr_in),
    .lo_we_in(lo_we_in),
    .hi_we_in(hi_we_in),
    .mfc0_instr_in,
    // exception trans
    .ex_in(ex_in),
    .ex_code_in(ex_code_in),
    .cp0_rd_mux_sel_in(cp0_rd_mux_sel_in),
    .cp0_we_in(cp0_we_in),
    .cp0_rdc_in(cp0_rdc_in),
    .eret_flush_in(eret_flush_in),
    .branch_delay_in(branch_delay_in),
    
    .pc(pc),
    .sa(sa),
    .imm(imm),
    .rs(rs),
    .rt(rt),
    .rdc(rdc_exe),
    
    .aluc(aluc),
    .ext5_sel(ext5_sel),
    .alu_a_sel(alu_a_sel),
    .alu_b_sel(alu_b_sel),
    .rd_mux_sel(rd_mux_sel),
    .lo_sel(lo_sel),
    .hi_sel(hi_sel),
    .mul_sign(mul_sign),
    .exe_bypass_sel(exe_bypass_sel),
    // memory write signal in 
    .dmem_we(dmem_we),
    .rf_we(rf_we),
    .lo_we(lo_we),
    .hi_we(hi_we),
    
    .bypass_rdc_valid(bypass_rdc_valid),
    .lw_instr(lw_instr),
    .mfc0_instr(mfc0_instr),
    .jump_instr(jump_instr),
    // exception trans
    .ex(ex),
    .ex_code(ex_code),
    .cp0_rd_mux_sel(cp0_rd_mux_sel),
    .cp0_we(cp0_we),
    .cp0_rdc(cp0_rdc),
    .eret_flush(eret_flush),
    .branch_delay(branch_delay)
);

assign exe_rdc_valid = bypass_rdc_valid & exe_valid;
assign exe_lw_instr = lw_instr & exe_valid;
assign exe_mfc0_instr = mfc0_instr & exe_valid;
assign exe_jump_instr = jump_instr & exe_valid;

ext16 ext16
(
    .din(imm),
    .dout(ext16_out)
);

uext16 uext16
(
    .din(imm),
    .dout(uext16_out)
);

mux2 ext5_mux(
    .in0({ 27'b0, rs[4:0]}), 
    .in1({ 27'b0, sa}),
    .sel(ext5_sel),
    .out(ext5_mux_out)
);

mux4 alu_a_mux(
    .in0(rs),
    .in1(ext5_mux_out),
    .in2(pc),
    .in3(32'b0),
    .sel(alu_a_sel),
    .out(alu_a_mux_out)
);

mux4 alu_b_mux(
    .in0(rt),
    .in1(ext16_out),
    .in2(uext16_out),
    .in3(32'd8),
    .sel(alu_b_sel),
    .out(alu_b_mux_out)
);

alu alu(
    .aluc(aluc),
    .src1(alu_a_mux_out),
    .src2(alu_b_mux_out),
    .result(alu_result),
    .zr(),
    .cy(),
    .ng(),
    .of()
);

mult mult
(
    .mul_sign(mul_sign),
    .a(rs),
    .b(rt),
    .z(mul_prod_sign),
    .z_unsign(mul_prod_unsign)
);

mux4 lo_mux(
    .in0(mul_prod_sign[31:0]),
    .in1(mul_prod_unsign[31:0]),
    .in2(rt),
    .in3(32'd0),
    .sel(lo_sel),
    .out(lo_mux_out)
);

mux4 hi_mux(
    .in0(mul_prod_sign[63:32]),
    .in1(mul_prod_unsign[63:32]),
    .in2(rt),
    .in3(32'd0),
    .sel(hi_sel),
    .out(hi_mux_out)
);

hilo lo_reg
(
    .clk(mem_clk),
    .we(lo_we & exe_valid & (!ex_no_write)),
    .in(lo_mux_out),
    .out(lo)
);

hilo hi_reg
(
    .clk(mem_clk),
    .we(hi_we & exe_valid & (!ex_no_write)),
    .in(hi_mux_out),
    .out(hi)
);

mux4 exe_bypass_mux(
    .in0(alu_result),
    .in1(hi),
    .in2(lo),
    .in3(32'b0),
    .sel(exe_bypass_sel),
    .out(exe_bypass_mux_out)
);

assign bypass_exe = exe_bypass_mux_out;

endmodule
