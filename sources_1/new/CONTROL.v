`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/04 15:55:24
// Design Name: 
// Module Name: CONTROL
// 
//////////////////////////////////////////////////////////////////////////////////


module cu(
    // operation judgement dependency
    input wire [5:0] op,
    input wire [5:0] func,
    // bypass control signal dependency
    input wire [4:0] id_rsc,
    input wire [4:0] id_rtc,
    input wire [4:0] id_rdc,
    input wire [4:0] exe_rdc,
    input wire [4:0] mem_rdc,
    input wire [4:0] wb_rdc,
    input wire exe_rdc_valid,
    input wire mem_rdc_valid,
    input wire wb_rdc_valid,
    // beq bne jump 
    input wire eq_flag,
    // is src needed after LW instruction
    // pipe lw block
    input wire exe_lw_instr,
    
    // alu control signal 
    output wire [3:0] aluc,
    // mux control signal 
    output wire [2:0] npc_mux_sel,
    output wire [1:0] rs_mux_sel,
    output wire [1:0] rt_mux_sel,
    output wire [1:0] rdc_mux_sel,
    output wire [0:0] ext5_mux_sel,
    output wire [1:0] alu_a_mux_sel,
    output wire [1:0] alu_b_mux_sel,
    output wire [1:0] rd_mux_sel,
    output wire [1:0] lo_mux_sel,
    output wire [1:0] hi_mux_sel,
    output wire mul_sign,
    output wire [1:0] exe_bypass_sel,
    // mem / regfile write signal
    output wire dmem_we,
    output wire rf_we,
    output wire lo_we,
    output wire hi_we,
    // pipeline block signal
    output wire lw_stall,
    output wire bypass_rdc_valid,
    output wire lw_instr
);

wire op_addu, op_add, op_addiu, op_addi;
wire op_subu, op_sub;
wire op_sltu, op_slt, op_sltiu, op_slti;
wire op_and, op_andi, op_or, op_ori, op_xor, op_xori;
wire op_nor, op_lui;
wire op_sll, op_srl, op_sra;
wire op_sllv, op_srlv, op_srav;
wire op_lw, op_sw;
wire op_beq, op_bne;
wire op_j, op_jal, op_jr;
wire op_mult, op_multu;
wire op_mfhi, op_mflo, op_mthi, op_mtlo;


wire instr_no_write;
wire instr_both_visit, instr_rs_visit;

// instruction recognize
assign op_addu      = (op == 6'b000000) && (func == 6'b100001);
assign op_add       = (op == 6'b000000) && (func == 6'b100000);
assign op_addiu     = (op == 6'b001001);
assign op_addi      = (op == 6'b001000);
assign op_subu      = (op == 6'b000000) && (func == 6'b100011);
assign op_sub       = (op == 6'b000000) && (func == 6'b100010);
assign op_sltu      = (op == 6'b000000) && (func == 6'b101011);
assign op_slt       = (op == 6'b000000) && (func == 6'b101010);
assign op_sltiu     = (op == 6'b001011);
assign op_slti      = (op == 6'b001010);
assign op_and       = (op == 6'b000000) && (func == 6'b100100);
assign op_or        = (op == 6'b000000) && (func == 6'b100101);
assign op_xor       = (op == 6'b000000) && (func == 6'b100110);
assign op_nor       = (op == 6'b000000) && (func == 6'b100111);
assign op_andi      = (op == 6'b001100);
assign op_ori       = (op == 6'b001101);
assign op_xori      = (op == 6'b001110);
assign op_lui       = (op == 6'b001111);
assign op_sll       = (op == 6'b000000) && (func == 6'b000000);
assign op_srl       = (op == 6'b000000) && (func == 6'b000010);
assign op_sra       = (op == 6'b000000) && (func == 6'b000011);
assign op_sllv      = (op == 6'b000000) && (func == 6'b000100);
assign op_srlv      = (op == 6'b000000) && (func == 6'b000110);
assign op_srav      = (op == 6'b000000) && (func == 6'b000111);
assign op_lw        = (op == 6'b100011);
assign op_sw        = (op == 6'b101011);
assign op_beq       = (op == 6'b000100);
assign op_bne       = (op == 6'b000101);
assign op_j         = (op == 6'b000010);
assign op_jal       = (op == 6'b000011);
assign op_jr        = (op == 6'b000000) && (func == 6'b001000);
assign op_mult      = (op == 6'b000000) && (func == 6'b011000);
assign op_multu     = (op == 6'b000000) && (func == 6'b011001);
assign op_mfhi      = (op == 6'b000000) && (func == 6'b010000);
assign op_mflo      = (op == 6'b000000) && (func == 6'b010010);
assign op_mthi      = (op == 6'b000000) && (func == 6'b010001);
assign op_mtlo      = (op == 6'b000000) && (func == 6'b010011);



assign instr_no_write = op_sw   | op_beq    | op_bne    | op_j      | 
                        op_jr   | op_mult   | op_multu  | op_mthi   | 
                        op_mtlo;
assign instr_rs_visit = op_jr   | op_addiu  | op_addi   | op_sltiu  | 
                        op_slti | op_andi   | op_ori    | op_xori   |
                        op_sll  | op_srl    | op_sra    | op_mthi   |
                        op_mtlo;
assign instr_both_visit = op_addu   | op_add    | op_subu   | op_sub    |
                          op_sltu   | op_slt    | op_and    | op_or     |
                          op_xor    | op_nor    | op_sllv   | op_srlv   |
                          op_srav   | op_sw     | op_beq    | op_bne    |
                          op_mult   | op_multu;

// alu control
assign aluc = ({4{ op_addu | op_addiu }} & 4'b0000) 
            | ({4{ op_add  | op_addi | 
                   op_lw   | op_sw   | op_jal }} & 4'b0010)
            | ({4{ op_subu            }} & 4'b0001)
            | ({4{ op_sub             }} & 4'b0011)
            | ({4{ op_and  | op_andi  }} & 4'b0100)
            | ({4{ op_or   | op_ori   }} & 4'b0101)
            | ({4{ op_xor  | op_xori  }} & 4'b0110)
            | ({4{ op_nor             }} & 4'b0111)
            | ({4{ op_lui             }} & 4'b1000)
            | ({4{ op_slt  | op_slti  }} & 4'b1011)
            | ({4{ op_sltu | op_sltiu }} & 4'b1010)
            | ({4{ op_sll  | op_sllv  }} & 4'b1111)
            | ({4{ op_srl  | op_srlv  }} & 4'b1101)
            | ({4{ op_sra  | op_srav  }} & 4'b1100);


// mux selection
//assign npc_mux_sel[1] = op_jr   | op_j                  | op_jal;
//assign npc_mux_sel[0] = op_jr   | (op_beq & eq_flag)    | (op_bne & !eq_flag);

assign npc_mux_sel = (op_jr) ? 3'b011 :
                     (op_j | op_jal) ? 3'b010 :
                     ( (op_beq & eq_flag) | (op_bne & !eq_flag) ) ? 3'b001:
                     3'b000;
// bypass control
// pay attention to the prior of bypass
// the bypass should not be activated when 
// 1. segment data is invalid
// 2. segment instrucition has no related register
// 3. segment instrucition related register is $0

assign bypass_rdc_valid = !instr_no_write && (id_rdc != 5'd0);
assign rs_mux_sel = ((instr_rs_visit || instr_both_visit) 
                        && exe_rdc_valid && id_rsc == exe_rdc) ? 2'b01 :
                    ((instr_rs_visit || instr_both_visit) 
                        && mem_rdc_valid && id_rsc == mem_rdc) ? 2'b10 :
                    ((instr_rs_visit || instr_both_visit) 
                        && mem_rdc_valid && id_rsc == wb_rdc ) ? 2'b11 : 
                                                                 2'b00;
assign rt_mux_sel = ((instr_both_visit) && exe_rdc_valid && id_rtc == exe_rdc) ? 2'b01 :
                    ((instr_both_visit) && mem_rdc_valid && id_rtc == mem_rdc) ? 2'b10 :
                    ((instr_both_visit) && wb_rdc_valid  && id_rtc == wb_rdc ) ? 2'b11 : 2'b00;
                    
assign rdc_mux_sel = (op_jal) ? 2'b10 : 
                     (op_addiu | op_addi | op_sltiu | op_slti | op_andi | op_ori |
                      op_xori  | op_lui  | op_lw    | op_sw   | op_beq  | op_bne) ? 
                      2'b01 :
                      2'b00;
assign ext5_mux_sel = ~(op_sllv | op_srlv | op_srav);
assign alu_a_mux_sel = (op_jal) ? 2'b10 : 
                       (op_sll | op_srl | op_sra | op_sllv | op_srlv | op_srav) ? 2'b01 :
                       2'b00;
assign alu_b_mux_sel = (op_jal) ? 2'b11 :
                       (op_andi | op_ori    | op_xori | op_lui) ? 2'b10 :
                       (op_addi | op_addiu  | op_slti | op_sltiu | op_lw   | op_sw) ? 2'b01 :
                       2'b00;
        
assign rd_mux_sel = (op_mflo)   ? 2'b11 :
                    (op_mfhi)   ? 2'b10 :
                    (op_lw)     ? 2'b01 :
                    2'b00;
                    
assign mul_sign = op_mult;
assign lo_mux_sel = (op_mult)   ? 2'b00 :
                    (op_multu)  ? 2'b01 :
                    (op_mtlo)   ? 2'b10 :
                    2'b11;
assign hi_mux_sel = (op_mult)   ? 2'b00 :
                    (op_multu)  ? 2'b01 :
                    (op_mthi)   ? 2'b10 :
                    2'b11;
assign exe_bypass_sel = (op_mflo) ? 2'b10 :
                        (op_mfhi) ? 2'b01 :
                        2'b00;

// memory write signal
assign rf_we = ~(instr_no_write);
assign dmem_we = op_sw;
assign lo_we = op_mtlo | op_mult | op_multu;
assign hi_we = op_mthi | op_mult | op_multu;

// pipeline block signal
// and RAW with LW in exe stage, pipeline should be blocked

assign lw_instr = op_lw;

assign lw_stall = ((exe_lw_instr) && instr_rs_visit && (id_rsc == exe_rdc)) ||
                  ((exe_lw_instr) && instr_both_visit && ((id_rsc == exe_rdc) || (id_rtc == exe_rdc)));

endmodule