`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/06 15:55:40
// Design Name: 
// Module Name: PIPELINE
// 
//////////////////////////////////////////////////////////////////////////////////


module pipeline
(
    input wire clk_gl,
    input wire rst,
    // external two interrupt signals
    input wire [1:0] interrupt,
    input wire [5:0] arguments,
    
    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [3:0] o_test_result,
    output wire [ 7:0] o_seg,
    output wire [ 7:0] o_sel
);

wire clk;
wire mem_clk;

clk_div clk_div(
    .reset(rst),
    .clkin(clk_gl),
    .clk(clk),
    .mem_clk(mem_clk)
);

//clk_div_manual clk_div_manual(
//    .rst(rst),
//    .clkin(clk_gl),
//    .clk(clk),
//    .mem_clk(mem_clk)
//);

wire id_allowin, exe_allowin, 
     mem_allowin, wb_allowin;
wire if_id_validto, id_exe_validto, 
     exe_mem_validto, mem_wb_validto;

wire [31:0] bypass_exe, bypass_mem, bypass_wb;
// TODO: add rdc_valid signal to EXE MEM WB segs and send back to ID
wire exe_rdc_valid, mem_rdc_valid, wb_rdc_valid;
wire bypass_rdc_valid_id, bypass_rdc_valid_exe, 
     bypass_rdc_valid_mem;
     
// TODO: exception info variables and link 
// TODO: add signals to related segment regs
// TODO: edit write signal when valid == 0
wire [ 0:0] ex_id, ex_exe, ex_mem, ex_wb;
wire [ 4:0] ex_code_id, ex_code_exe, ex_code_mem;
wire [ 0:0] cp0_rd_mux_sel_id, cp0_rd_mux_sel_exe,
            cp0_rd_mux_sel_mem;
wire [ 0:0] cp0_we_id, cp0_we_exe, cp0_we_mem;
wire [ 4:0] cp0_rdc_id, cp0_rdc_exe, cp0_rdc_mem;
wire [ 0:0] eret_flush_id, eret_flush_exe, eret_flush_mem;
wire [ 0:0] branch_delay_id, branch_delay_exe, branch_delay_mem;

wire [ 0:0] flush, flush_if_id, flush_id_exe, 
            flush_exe_mem, flush_mem_wb;
// TODO: check pc rt lw mfc0 trans

wire [ 0:0] cp0_flush;
wire [ 0:0] cp0_ie;
wire [ 0:0] cp0_exl;
wire [ 0:0] cp0_hlt;
wire [ 0:0] cp0_eret;
wire [ 7:0] cp0_int_mask;
wire [ 7:0] cp0_int_sig;
wire [31:0] cp0_epc;

// TODO: pc should be transfered to WB

wire [31:0] pc_if, pc_id, pc_exe, pc_mem;
wire [31:0] instr;
wire [ 4:0] sa;
wire [25:0] j_imm;
wire [15:0] imm;
wire [31:0] rs_id;
wire [31:0] rt_id, rt_exe, rt_mem;
wire [ 4:0] rdc_id, rdc_exe, rdc_mem, rdc_wb;
wire [ 3:0] aluc;
wire [ 2:0] npc_mux_sel;
wire [ 0:0] ext5_mux_sel;
wire [ 1:0] alu_a_mux_sel;
wire [ 1:0] alu_b_mux_sel;
wire [ 1:0] rd_mux_sel_id, rd_mux_sel_exe;
wire [ 1:0] lo_mux_sel;
wire [ 1:0] hi_mux_sel;
wire [ 0:0] mul_sign;
wire [ 1:0] exe_bypass_sel;

wire [31:0] alu_result;
wire [31:0] wb_result_mem, wb_result_wb;

wire dmem_we_id, dmem_we_exe;
wire rf_we_id, rf_we_exe, rf_we_mem, rf_we_wb;
wire lo_we, hi_we;

wire lw_instr, exe_lw_instr;
// TODO: add mfc0 pipeline block
wire mfc0_instr, exe_mfc0_instr, mem_mfc0_instr;
wire jump_instr, exe_jump_instr;
wire [35:0] test_result;
//wire [31:0] pc_out;
wire [31:0] hi, lo;

assign pc_out = pc_id;
assign o_test_result = test_result[35:32];
assign flush_if_id = flush;
assign flush_id_exe = flush;
assign flush_exe_mem = flush;
assign flush_mem_wb = flush;

pipe_if pipe_if
(
    // input 
    
    // clock and pipe control signal input
    .clk(clk),
    .mem_clk(mem_clk),
    .rst(rst),
    .id_allowin(id_allowin),
    .flush_if_id(flush_if_id),
    // pc jump data from id
    .rs_pc_in(rs_id),
    .imm_in(j_imm),
    .cp0_epc_in(cp0_epc),
    // mux control signal
    .pc_mux_sel(npc_mux_sel),
    
    // output
    
    // pipe control signal
    .if_id_validto(if_id_validto),
    // instruction fetching data backward
    .pc_out(pc_if),
    .instr(instr)
);

pipe_id pipe_id
(
    // input
    
    // clock and pipe control signal input
    .clk(clk),
    .rst(rst),
    .mem_clk(mem_clk),
    .exe_allowin(exe_allowin),
    .if_id_validto(if_id_validto),
    .flush_id_exe(flush_id_exe),
    // if pipe data input
    .pc_in(pc_if),
    .instr_in(instr),
    // regfile write input 
    .we_wb(rf_we_wb),
    .rd_wb(wb_result_wb),
    .rdc_wb(rdc_wb),
    .rdc_mem(rdc_mem),
    .rdc_exe(rdc_exe),
    // bypass input
    .bypass_exe(bypass_exe),
    .bypass_mem(bypass_mem),
    .bypass_wb(bypass_wb),
    .exe_rdc_valid(exe_rdc_valid),
    .mem_rdc_valid(mem_rdc_valid),
    .wb_rdc_valid(wb_rdc_valid),
    // pipe lw block
    .exe_lw_instr(exe_lw_instr),
    .exe_mfc0_instr(exe_mfc0_instr),
    .mem_mfc0_instr(mem_mfc0_instr),
    .exe_jump_instr(exe_jump_instr),
    // external argument in
    .arguments(arguments),
    // cp0 exception status
    .ex_wb(ex_wb),
    .cp0_flush(cp0_flush),
    .cp0_hlt(cp0_hlt),
    .cp0_eret(cp0_eret),
    .cp0_ie(cp0_ie),
    .cp0_exl(cp0_exl),
    .cp0_int_mask(cp0_int_mask),
    .cp0_int_sig(cp0_int_sig),
    
    // output
    
    // pipe control signal
    .id_allowin(id_allowin),
    .id_exe_validto(id_exe_validto),
    // pipe backward data
    .pc_out(pc_id),
    .instr_out(instr_out),
    .sa(sa),
    .j_imm(j_imm),
    .imm(imm),
    .rs_mux_out(rs_id),
    .rt_mux_out(rt_id),
    .rdc_mux_out(rdc_id),
    // cu control signal
    .aluc(aluc),
    .npc_mux_sel(npc_mux_sel),
    .ext5_mux_sel(ext5_mux_sel),
    .alu_a_mux_sel(alu_a_mux_sel),
    .alu_b_mux_sel(alu_b_mux_sel),
    .rd_mux_sel(rd_mux_sel_id),
    // mul and hi lo signal
    .lo_mux_sel(lo_mux_sel),
    .hi_mux_sel(hi_mux_sel),
    .mul_sign(mul_sign),
    .exe_bypass_sel(exe_bypass_sel),
    // memory write signal
    .dmem_we(dmem_we_id),
    .rf_we(rf_we_id),
    .lo_we(lo_we),
    .hi_we(hi_we),
    // instruction level bypass valid 
    .bypass_rdc_valid(bypass_rdc_valid_id),
    // pipeline block cross segments signal
    .flush(flush),
    .lw_instr(lw_instr),
    .mfc0_instr(mfc0_instr),
    .jump_instr(jump_instr),
    // throw eggs test result in $1 register 
    .test_result(test_result),
    // cp0 exception action output 
    .ex(ex_id),
    .cp0_we(cp0_we_id),
    .ex_code(ex_code_id),
    .cp0_rd_mux_sel(cp0_rd_mux_sel_id),
    .cp0_rdc(cp0_rdc_id),
    .eret_flush(eret_flush_id),
    .branch_delay(branch_delay_id)
);

pipe_exe pipe_exe
(
    // input
    
    // clock and pipe control signal input
    .clk(clk),
    .rst(rst),
    .mem_clk(mem_clk),
    .mem_allowin(mem_allowin),
    .id_exe_validto(id_exe_validto),
    .ex_mem(ex_mem),
    .ex_wb(ex_wb),
    .bypass_rdc_valid_in(bypass_rdc_valid_id),
    
    .flush_exe_mem(flush_exe_mem),
    // id pipe data input
    .pc_in(pc_id),
    .sa_in(sa),
    .imm_in(imm),
    .rs_in(rs_id),
    .rt_in(rt_id),
    .rdc_in(rdc_id),
    // pipe alu and mux control
    .aluc_in(aluc),
    .ext5_sel_in(ext5_mux_sel),
    .alu_a_sel_in(alu_a_mux_sel),
    .alu_b_sel_in(alu_b_mux_sel),
    .rd_mux_sel_in(rd_mux_sel_id),
    .lo_mux_sel_in(lo_mux_sel),
    .hi_mux_sel_in(hi_mux_sel),
    .mul_sign_in(mul_sign),
    .exe_bypass_sel_in(exe_bypass_sel),
    // memory write signal in 
    .dmem_we_in(dmem_we_id),
    .rf_we_in(rf_we_id),
    .lo_we_in(lo_we),
    .hi_we_in(hi_we),
    // specific instruction pipeline block
    .lw_instr_in(lw_instr),
    .mfc0_instr_in(mfc0_instr),
    .jump_instr_in(jump_instr),
    // exception trans
    .ex_in(ex_id),
    .ex_code_in(ex_code_id),
    .cp0_rd_mux_sel_in(cp0_rd_mux_sel_id),
    .cp0_we_in(cp0_we_id),
    .cp0_rdc_in(cp0_rdc_id),
    .eret_flush_in(eret_flush_id),
    .branch_delay_in(branch_delay_id),
    
    // output
    
    // pipe control signal
    .exe_allowin(exe_allowin),
    .exe_mem_validto(exe_mem_validto),
    // pipe backward data
    .pc(pc_exe),
    .rt(rt_exe),
    .alu_result(alu_result),
    .rdc_exe(rdc_exe),
    // bypass for id
    .bypass_exe(bypass_exe),
    .exe_rdc_valid(exe_rdc_valid),
    .bypass_rdc_valid(bypass_rdc_valid_exe),
    // memory write signal out
    .dmem_we(dmem_we_exe),
    .rf_we(rf_we_exe),
    // pipe mux signal backward
    .rd_mux_sel(rd_mux_sel_exe),
    .exe_lw_instr(exe_lw_instr),
    .exe_mfc0_instr(exe_mfc0_instr),
    .exe_jump_instr(exe_jump_instr),
    // exception trans
    .ex(ex_exe),
    .ex_code(ex_code_exe),
    .cp0_rd_mux_sel(cp0_rd_mux_sel_exe),
    .cp0_we(cp0_we_exe),
    .cp0_rdc(cp0_rdc_exe),
    .eret_flush(eret_flush_exe),
    .branch_delay(branch_delay_exe),
    // hilo register out
    .lo(lo),
    .hi(hi)
);


pipe_mem pipe_mem
(
    // input 
    
    // clock and pipe control signal input
    .clk(clk),
    .mem_clk(mem_clk),
    .rst(rst),
    .flush_mem_wb(flush_mem_wb),
    .ex_wb(ex_wb),
    
    .wb_allowin(wb_allowin),
    .exe_mem_validto(exe_mem_validto),
    .bypass_rdc_valid_in(bypass_rdc_valid_exe),
    // memory write signal in 
    .dmem_we_in(dmem_we_exe),
    .rf_we_in(rf_we_exe),
    // exe pipe data input
    .pc_in(pc_exe),
    .rt_in(rt_exe),
    .alu_result_in(alu_result),
    .rdc_exe_in(rdc_exe),
    // pipe mux control
    .rd_mux_sel_in(rd_mux_sel_exe),
    .lo_in(lo),
    .hi_in(hi),
    
    .mfc0_instr_in(exe_mfc0_instr),
    // exception trans
    .ex_in(ex_exe),
    .ex_code_in(ex_code_exe),
    .cp0_rd_mux_sel_in(cp0_rd_mux_sel_exe),
    .cp0_we_in(cp0_we_exe),
    .cp0_rdc_in(cp0_rdc_exe),
    .eret_flush_in(eret_flush_exe),
    .branch_delay_in(branch_delay_exe),
    
    // output
    .pc(pc_mem),
    .rt(rt_mem),
    // pipe control signal
    .mem_allowin(mem_allowin),
    .mem_wb_validto(mem_wb_validto),
    // pipe backward data
    .wb_result(wb_result_mem),
    .rdc_mem(rdc_mem),
    // bypass for id
    .bypass_mem(bypass_mem),
    .mem_rdc_valid(mem_rdc_valid),
    .bypass_rdc_valid(bypass_rdc_valid_mem),
    // memory write signal out
    .rf_we(rf_we_mem),
    
    .mem_mfc0_instr(mem_mfc0_instr),
    // exception trans
    .ex(ex_mem),
    .ex_code(ex_code_mem),
    .cp0_rd_mux_sel(cp0_rd_mux_sel_mem),
    .cp0_we(cp0_we_mem),
    .cp0_rdc(cp0_rdc_mem),
    .eret_flush(eret_flush_mem),
    .branch_delay(branch_delay_mem)
    
);

pipe_wb pipe_wb
(
    // input
    
    // clock and pipe control signal input
    .clk(clk),
    .rst(rst),
    .mem_clk(mem_clk),
    .mem_wb_validto(mem_wb_validto),
    .bypass_rdc_valid_in(bypass_rdc_valid_mem),
    // mem pipe data input
    .wb_result_in(wb_result_mem),
    .rdc_mem_in(rdc_mem),
    // memory write signal in 
    .rf_we_in(rf_we_mem),
    // cp0 input signal
    .cp0_rd_mux_sel_in(cp0_rd_mux_sel_mem),
    .cp0_we_in(cp0_we_mem),
    .ex_wb_in(ex_mem),
    .eret_flush_in(eret_flush_mem),
    .branch_delay_wb_in(branch_delay_mem),
    
    .cp0_rdc_in(cp0_rdc_mem),
    .int_sig_in({interrupt, 4'b0}),
    .cp0_data_in(rt_mem),
    .pc_in(pc_mem),
    .ex_code_in(ex_code_mem),
    
    // output
    
    // pipe control signal
    .wb_allowin(wb_allowin),
    // regfile write back data
    .rdc_wb(rdc_wb),
    .wb_result(wb_result_wb),
    // memory write signal out
    .rf_we(rf_we_wb),
    // bypass for id
    .bypass_wb(bypass_wb),
    .wb_rdc_valid(wb_rdc_valid),
    
    .ex(ex_wb),
    .flush(cp0_flush),
    .hlt(cp0_hlt),
    .eret(cp0_eret),
    // STATUS region
    .ie(cp0_ie),
    .exl(cp0_exl),
    .int_mask(cp0_int_mask),
    // CAUSE regoin
    .int_sig(cp0_int_sig),
    // EPC region
    .epc_out(cp0_epc)
);


seg7display seg7display
(
    .clk(clk_gl),
    .reset(rst),
    .cs(1'b1),
    .i_data(test_result[31:0]),
    .o_seg(o_seg),
    .o_sel(o_sel)
);

endmodule
