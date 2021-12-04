`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/10/27 17:52:39
// Design Name: 
// Module Name: ALU
//
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input  wire [ 3:0] aluc,
    input  wire [31:0] src1,
    input  wire [31:0] src2,
    output wire [31:0] result,
    output wire zr,
    output wire cy,
    output wire ng,
    output wire of
);

// operator definition

wire op_addu,       op_add,         op_subu,        op_sub;        
wire op_and,        op_or,          op_xor,         op_nor;
wire op_lui,        op_slt,         op_sltu;
wire op_sra,        op_sll,         op_srl;

assign op_addu  = {aluc[3:0] == 4'b0000};
assign op_add   = {aluc[3:0] == 4'b0010};
assign op_subu  = {aluc[3:0] == 4'b0001};
assign op_sub   = {aluc[3:0] == 4'b0011};
assign op_and   = {aluc[3:0] == 4'b0100};
assign op_or    = {aluc[3:0] == 4'b0101};
assign op_xor   = {aluc[3:0] == 4'b0110};
assign op_nor   = {aluc[3:0] == 4'b0111};
assign op_lui   = {aluc[3:0] == 4'b1000} | {aluc[3:0] == 4'b1001};
assign op_slt   = {aluc[3:0] == 4'b1011};
assign op_sltu  = {aluc[3:0] == 4'b1010};
assign op_sll   = {aluc[3:0] == 4'b1111} | {aluc[3:0] == 4'b1110};
assign op_srl   = {aluc[3:0] == 4'b1101};
assign op_sra   = {aluc[3:0] == 4'b1100};

wire [31:0] add_sub_result;
wire [31:0] and_result;
wire [31:0] or_result;
wire [31:0] xor_result;
wire [31:0] nor_result;
wire [31:0] lui_result;
wire [31:0] slt_result;
wire [31:0] sltu_result;
wire [31:0] sll_result;
wire [31:0] srl_result;
wire [31:0] sra_result;

// result assignment

assign and_result   = src1 & src2;
assign or_result    = src1 | src2;
assign xor_result   = src1 ^ src2;
assign nor_result   = ~or_result;
assign lui_result   = { src2[15:0], 16'd0 };

assign sll_result   = src2 << src1[4:0];
assign srl_result   = src2 >> src1[4:0];
assign sra_result   = ($signed(src2)) >>> src1[4:0];

wire [33:0] adder_a, adder_b, adder_bt;
wire [31:0] adder_result;
wire adder_out;
wire [1:0] adder_of;

assign adder_a  = {{2{src1[31]}}, src1};
assign adder_b = {{2{src2[31]}}, src2};
assign adder_bt  = ( op_sub | op_subu | op_slt | op_sltu ) ? ~adder_b + 1'b1 : adder_b;

assign {adder_out, adder_result} = adder_a + adder_bt;
assign adder_of = {adder_out, adder_result[31]};
assign add_sub_result = adder_result;

assign slt_result[31:1] = 31'b0;
assign slt_result[0]  = (src1[31] & ~ src2[31]) | (~(src1[31]^src2[31]) & adder_result[31]);
assign sltu_result[31:1] = 31'b0;
assign sltu_result[0] = (~src1[31] & (src1[31] ^ src2[31])) | (~(src1[31] ^ src2[31]) & adder_out);     // negative result didn't use adder_out

assign result = ({32{ op_add | op_sub | op_addu | op_subu }} & add_sub_result)
            |   ({32{ op_slt }} & slt_result )
            |   ({32{ op_sltu}} & sltu_result)
            |   ({32{ op_and }} & and_result )
            |   ({32{ op_or  }} & or_result  )
            |   ({32{ op_xor }} & xor_result )
            |   ({32{ op_nor }} & nor_result )
            |   ({32{ op_sll }} & sll_result )
            |   ({32{ op_srl }} & srl_result )
            |   ({32{ op_sra }} & sra_result )
            |   ({32{ op_lui }} & lui_result );

// flag assignment

wire            cy_ena, of_ena;
reg     [0:0]   cy_reg, of_reg;
wire    [31:0]  sll_result_last, srl_result_last, sra_result_last;

assign cy_ena = (op_addu | op_subu | op_sltu | op_sll | op_srl | op_sra);
assign of_ena = (op_add | op_sub);

assign sll_result_last   = (src1[4:0] == 4'b0) ? 32'b0 : src2 << (src1[4:0]-1);
assign srl_result_last   = (src1[4:0] == 4'b0) ? 32'b0 : src2 >> (src1[4:0]-1);
assign sra_result_last   = (src1[4:0] == 4'b0) ? 32'b0 : ($signed(src2)) >>> (src1[4:0]-1);


//cy_ena, of_ena, adder_result, sll_result_last[0], srl_result_last[0], sra_result_last[0], sltu_result[0]

always @(*) begin
    if(cy_ena) begin
        cy_reg =    ((op_addu & (src1[31] == 1'b1 | src2[31] == 1'b1) & adder_result[31] == 1'b0) |
                     (op_subu & ((~(src1[31]^src2[31]) & adder_result[31]) |
                                 (src1[31] == 1'b0 & src2[31] == 1'b1))))
            |       ((op_sltu)   & (sltu_result[0] == 1'b1))
            |        (op_sll     & sll_result_last[31])
            |        (op_srl     & srl_result_last[0])
            |        (op_sra     & sra_result_last[0]);
    end
    if(of_ena) begin
        of_reg = adder_of[1] ^ adder_of[0];
    end
end

assign zr = ((op_slt | op_sltu)   & adder_result == 32'b0)
        ||  (~(op_slt | op_sltu) & result == 32'b0);
assign ng =  (op_slt) & (slt_result[0] == 1'b1)
        |   ~(op_slt) & (result[31] == 1'b1);
        
assign cy = cy_reg;
assign of = of_reg;

endmodule
