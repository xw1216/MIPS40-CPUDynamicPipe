`timescale 1ns / 1ps
// 
// Create Date: 2021/12/04 13:43:58
// Design Name: 
// Module Name: CP0
// 
//////////////////////////////////////////////////////////////////////////////////


module cp0
(
    // input 
    input wire rst,
    input wire clk,
    input wire mem_clk,
    
    input wire cp0_we_in,
    input wire ex_wb_in,
    input wire eret_flush_in,
    input wire branch_delay_wb_in,
    
    input wire [ 4:0] cp0_rdc_in,
    input wire [ 5:0] int_sig_in,
    input wire [31:0] cp0_data_in,
    input wire [31:0] epc_in,
    input wire [ 4:0] ex_code_in,
    
    // output
    output reg ex,
    output wire flush,
    output reg [ 0:0] hlt,
    output reg eret,
    // STATUS region
    output reg [ 0:0] ie,
    output reg [ 0:0] exl,
    output reg [ 7:0] int_mask,
    // CAUSE regoin
    output reg [ 7:0] int_sig,
    // EPC region
    output wire [31:0] epc_out,
    output wire [31:0] cp0_data_out
);

parameter RDC_STATUS  = 5'd12;
parameter RDC_CAUSE = 5'd13;
parameter RDC_EPC = 5'd14;

parameter EX_CODE_INT = 5'h00;
parameter EX_CODE_HLT = 5'h01;
parameter EX_CODE_RESUME = 5'h02;
parameter EX_CODE_ADEL = 5'h04;
parameter EX_CODE_ADES = 5'h05;
parameter EX_CODE_SYS = 5'h08;
parameter EX_CODE_BP = 5'h09;
parameter EX_CODE_RI = 5'h0a;
parameter EX_CODE_OF = 5'h0c;

parameter EX_ENTRY_PC = 32'h0040_0008;
parameter EX_HLT_PC = 32'h0040_0008;

reg cause_bd;
reg [4:0] cause_ex_code;
reg [31:0] epc;

reg cp0_we;
reg [4:0] cp0_rdc;
reg branch_delay_wb;
reg [4:0] ex_code;

always @ (*) begin
    casex(ex_wb_in)
    1'b0: ex = 1'b0;
    1'b1: ex = 1'b1;
    default: ex = 1'b0;
    endcase
    
    casex(eret_flush_in)
    1'b0: eret = 1'b0;
    1'b1: eret = 1'b1;
    default: eret = 1'b0;
    endcase
    
    casex(cp0_we_in)
    1'b0: cp0_we = 1'b0;
    1'b1: cp0_we = 1'b1;
    default: cp0_we = 1'b0;
    endcase
    
    casex(branch_delay_wb_in)
    1'b0: branch_delay_wb = 1'b0;
    1'b1: branch_delay_wb = 1'b1;
    default: branch_delay_wb = 1'b0;
    endcase
    
    casex(cp0_rdc_in)
    RDC_STATUS: cp0_rdc = 5'd12;
    RDC_CAUSE: cp0_rdc = 5'd13;
    RDC_EPC: cp0_rdc = 5'd14;
    default: cp0_rdc = 5'd0;
    endcase
    
    casex(ex_code_in)
    EX_CODE_HLT: ex_code = EX_CODE_HLT;
    EX_CODE_RESUME: ex_code = EX_CODE_RESUME;
    default: ex_code = 5'd0;
    endcase
end


assign flush = eret || ex;
assign epc_out = (ex) ? EX_ENTRY_PC : 
                 (hlt) ? EX_HLT_PC : epc;
assign cp0_data_out = (cp0_rdc == RDC_STATUS) ? ({ 16'h0040, int_mask, 6'h0, exl, ie }) :
                      (cp0_rdc == RDC_CAUSE)  ? ({ cause_bd, 15'h0, int_sig, 1'b0, cause_ex_code, 2'b0 }) :
                      (cp0_rdc == RDC_EPC)    ? (epc) : 32'h0000_0000;

// machine hlt
always @ (posedge mem_clk) begin
    if(rst) begin
        hlt <= 1'b0;
    end
    else if(ex && ex_code == EX_CODE_HLT) begin
        hlt <= 1'b1;
    end
    else if(ex && ex_code == EX_CODE_RESUME) begin
        hlt <= 1'b0;
    end
    else begin end
end

// STATUS region always

// int_mask maintiance
always @ (posedge mem_clk) begin
    if(rst) begin
        int_mask <= 8'b1111_1111;
    end
    else if(cp0_we && cp0_rdc == RDC_STATUS) begin
        int_mask <= cp0_data_in[15:8];
    end
    else begin end
end

// exl maintiance
always @ (posedge mem_clk) begin
    if(rst) begin
        exl <= 1'b0;
    end
    else if(ex) begin
        exl <= 1'b1;
    end
    else if(eret) begin
        exl <= 1'b0;
    end
    else if(cp0_we && cp0_rdc == RDC_STATUS) begin
        exl <= cp0_data_in[1];
    end
    else begin end
end

// ie maintiance
always @ (posedge mem_clk) begin
    if(rst) begin
        ie <= 1'b0;
    end
    else if(cp0_we && cp0_rdc == RDC_STATUS) begin
        ie <= cp0_data_in[0];
    end
    else begin end
end

// CAUSE regoin always

//wire cause ti;

// bd maintiance
always @ (posedge mem_clk) begin
    if(rst) begin
        cause_bd <= 1'b0;
    end
    else if (ex) begin
        cause_bd <= branch_delay_wb;
    end
    else begin end
end

// ip7 ~ ip2 hardware intterupt maintiance
always @ (posedge mem_clk) begin
    if(rst) begin
        int_sig[7:2] <= 6'b0;
    end
    else begin
        int_sig[7:2] <= int_sig_in;
    end
end

// ip1 ~ ip0 software interrupt maintiance
always @ (posedge mem_clk) begin
    if(rst) begin
        int_sig[1:0] <= 2'b0;
    end
    else if (cp0_we && cp0_rdc == RDC_CAUSE) begin
        int_sig[1:0] <= cp0_data_in[9:8];
    end
    else begin end
end

// excode maintiance
always @ (posedge mem_clk) begin
    if(rst) begin
        cause_ex_code <= 5'b0;
    end
    else if(ex) begin
        cause_ex_code <= ex_code;
    end
    else begin end
end

// EPC region

always @ (posedge mem_clk) begin
    // make sure when resume from hlt then epc don't change
    if(rst) begin
        epc <= EX_ENTRY_PC;
    end
    else if(ex) begin
        if(ex_code != EX_CODE_RESUME) begin
            epc <= branch_delay_wb ? epc_in - 32'h4 : epc_in;
        end
    end
    else if(cp0_we && cp0_rdc == RDC_EPC) begin
        epc <= cp0_data_in;
    end
    else begin end
end


endmodule
