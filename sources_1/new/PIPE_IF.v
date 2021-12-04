`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/11/04 12:06:22
// Design Name: 
// Module Name: PIPE_IF
// 
//////////////////////////////////////////////////////////////////////////////////


module pipe_if
(
    input wire clk,
    input wire mem_clk,
    input wire rst,
    input wire id_allowin,
    input wire flush_if_id,
    
    input wire [31:0] rs_pc_in,
    input wire [25:0] imm_in,
    input wire [31:0] cp0_epc_in,
    input wire [ 2:0] pc_mux_sel,
    
    output wire if_id_validto,
    output wire [31:0] pc_out,
    output wire [31:0] instr
);


wire [31:0] npc_mux_out;
wire [31:0] npc_add_out;
wire [31:0] eq_add_out;
wire [31:0] ext18_out;
wire [31:0] join_out;
wire [31:0] imem_mapper_out;

wire if_allowin;
wire if_valid;
wire if_ready_go;


assign if_allowin = !if_valid || (if_ready_go && id_allowin);
assign if_valid = 1;
assign if_ready_go = 1;
assign if_id_validto = if_valid && if_ready_go && (!flush_if_id);

mux8 npc_mux(
        .in0(npc_add_out), 
        .in1(eq_add_out), 
        .in2(join_out), 
        .in3(rs_pc_in),
        .in4(cp0_epc_in),
        .in5(),
        .in6(),
        .in7(),
        .sel(pc_mux_sel),
        .out(npc_mux_out)
);

pc pc(
    .clk(clk),
    .rst(rst),
    .allowin(if_allowin),

    .npc(npc_mux_out),
    .pc(pc_out)
);

// npc provider

ext18 ext18(
    .din(imm_in[15:0]),
    .dout(ext18_out)
);

adder npc_add(
    .dina(pc_out),
    .dinb(32'h4),
    .dout(npc_add_out)
);

adder eq_add(
    .dina(pc_out),
    .dinb(ext18_out),
    .dout(eq_add_out)
);

j_join j_join(
        .pc_slot_in(pc_out[31:28]),
        .imm_in(imm_in),
        .dout(join_out)
);

// instruction fetching

// when testing, the code segment should mapped to 0x0000_0000
// while when running os, the code segment should mapped to 0x1FC0_0000
vaddr_mapper imem_mapper(
    .vaddr(pc_out),
    .addr(imem_mapper_out)
);

imem imem(
    .clka(mem_clk),
    .addra(imem_mapper_out[12:2]),
    .dina(32'd0),
    .wea(1'b0),
    .douta(instr)
);

endmodule
