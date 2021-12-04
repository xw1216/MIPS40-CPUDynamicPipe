`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/04 12:06:41
// Design Name: 
// Module Name: PIPE_ID
// 
//////////////////////////////////////////////////////////////////////////////////


module pipe_id
(
    // clock and pipe control signal input
    input wire clk,
    input wire rst,
    input wire mem_clk,
    input wire exe_allowin,
    input wire if_id_validto,
    // if pipe data input
    input wire [31:0] pc_in,
    input wire [31:0] instr_in,
    // regfile write input 
    input wire we_wb,
    input wire [31:0] rd_wb,
    input wire [4:0] rdc_wb,
    input wire [4:0] rdc_mem,
    input wire [4:0] rdc_exe,
    // bypass input
    input wire [31:0] bypass_exe,
    input wire [31:0] bypass_mem,
    input wire [31:0] bypass_wb,
    input wire exe_rdc_valid,
    input wire mem_rdc_valid,
    input wire wb_rdc_valid,
    // pipe lw block
    input wire exe_lw_instr,
    // external argument in
    input wire [4:0] arguments,
    
    // pipe control signal
    output wire id_allowin,
    output wire id_exe_validto,
    // pipe backward data
    output wire [31:0] pc_out,
    output wire [31:0] instr_out,
    output wire [4:0] sa,
    output wire [25:0] j_imm,
    output wire [15:0] imm,
    output wire [31:0] rs_mux_out,
    output wire [31:0] rt_mux_out,
    output wire [ 4:0] rdc_mux_out,
    // cu control signal
    output wire [3:0] aluc,
    output wire [2:0] npc_mux_sel,
    output wire [0:0] ext5_mux_sel,
    output wire [1:0] alu_a_mux_sel,
    output wire [1:0] alu_b_mux_sel,
    output wire [1:0] rd_mux_sel,
    // mul and hi lo signal
    output wire [1:0] lo_mux_sel,
    output wire [1:0] hi_mux_sel,
    output wire mul_sign,
    output wire [1:0] exe_bypass_sel,
    // memory write signal
    output wire dmem_we,
    output wire rf_we,
    output wire lo_we,
    output wire hi_we,
    // instruction level bypass valid 
    output wire bypass_rdc_valid,
    output wire lw_instr,
    // throw eggs test result in $1 register 
    output wire [31:0] test_result
    
);

reg id_valid;
wire id_ready_go;

wire lw_stall;

assign id_allowin = !id_valid || (id_ready_go && exe_allowin);
assign id_exe_validto = id_valid && id_ready_go;
assign id_ready_go = !lw_stall;

always @ (posedge clk or posedge rst) begin
    if(rst) begin
        id_valid <= 1'b0;
    end
    else if(id_allowin) begin
        id_valid <= if_id_validto;
    end
    else begin
    
    end
end

wire [ 5:0] op;
wire [ 4:0] rsc, rtc, rdc;
wire [31:0] rs, rt;

wire [ 1:0] rs_mux_sel, rt_mux_sel;
wire [ 1:0] rdc_mux_sel;

wire eq_flag;


id_pipe_reg id_pipe_reg(
    .clk(clk),
    .rst(rst),
    .pc_in(pc_in),
    .instr_in(instr_in),
    // control pipe register write when if is data in IF is valid and ID allow in 
    .id_allowin(if_id_validto & id_allowin),

    .pc_out(pc_out),
    .instr_out(instr_out),
    .op(op),
    .sa(sa),
    .imm(imm),
    .j_imm(j_imm),
    .rsc(rsc),
    .rtc(rtc),
    .rdc(rdc)
);


regfiles regfiles(
    .clk(mem_clk),
    .we(we_wb),
    .rst(rst),
    
    .raddr1(rsc),
    .raddr2(rtc),
    .rdata1(rs),
    .rdata2(rt),
    .test_result(test_result),

    .waddr(rdc_wb),
    .wdata(rd_wb),
    .arguments(arguments)
);

mux4 rs_mux(
    .in0(rs), 
    .in1(bypass_exe), 
    .in2(bypass_mem), 
    .in3(bypass_wb),
    .sel(rs_mux_sel),
    .out(rs_mux_out)
);

mux4 rt_mux(
    .in0(rt),
    .in1(bypass_exe),
    .in2(bypass_mem),
    .in3(bypass_wb),
    .sel(rt_mux_sel),
    .out(rt_mux_out)
);

mux4 #(5) rdc_mux (
    .in0(rdc),
    .in1(rtc),
    .in2(5'd31),
    .in3(5'd0),
    .sel(rdc_mux_sel),
    .out(rdc_mux_out)
);

idEq id_eq
(
    .dina(rs_mux_out),
    .dinb(rt_mux_out),
    .eq(eq_flag)
);

cu cu(
    // input

    // operation judgement dependency
    .op(op),
    .func(imm[5:0]),
    // bypass control signal dependency
    .id_rsc(rsc),
    .id_rtc(rtc),
    .id_rdc(rdc_mux_out),
    .exe_rdc(rdc_exe),
    .mem_rdc(rdc_mem),
    .wb_rdc(rdc_wb),
    .exe_rdc_valid(exe_rdc_valid),
    .mem_rdc_valid(mem_rdc_valid),
    .wb_rdc_valid(wb_rdc_valid),
    // beq bne jump 
    .eq_flag(eq_flag),
    // is src needed after LW instruction
    .exe_lw_instr(exe_lw_instr),
    
    // output
    
    // alu control signal 
    .aluc(aluc),
    // mux control signal 
    .npc_mux_sel(npc_mux_sel),
    .rs_mux_sel(rs_mux_sel),
    .rt_mux_sel(rt_mux_sel),
    .rdc_mux_sel(rdc_mux_sel),
    .ext5_mux_sel(ext5_mux_sel),
    .alu_a_mux_sel(alu_a_mux_sel),
    .alu_b_mux_sel(alu_b_mux_sel),
    .rd_mux_sel(rd_mux_sel),
    .lo_mux_sel(lo_mux_sel),
    .hi_mux_sel(hi_mux_sel),
    .mul_sign(mul_sign),
    .exe_bypass_sel(exe_bypass_sel),
    // mem / regfile write signal
    .dmem_we(dmem_we),
    .rf_we(rf_we),
    .lo_we(lo_we),
    .hi_we(hi_we),
    
    .lw_stall(lw_stall),
    .bypass_rdc_valid(bypass_rdc_valid),
    .lw_instr(lw_instr)
);


endmodule
