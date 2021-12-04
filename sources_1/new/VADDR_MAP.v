`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/10/31 15:47:17
// Design Name: 
// Module Name: VADDR_MAP
// 
//////////////////////////////////////////////////////////////////////////////////


module vaddr_mapper
(
    input wire [31:0] vaddr,
    output reg [31:0] addr
);

always @ (*) begin
    if(vaddr[31:20] == 12'h004) begin
        addr = vaddr - 32'h0040_0000;
    end
    else if(vaddr[31:20] == 12'h100) begin
        addr = vaddr - 32'h1001_0000;
    end
    else begin
        addr = vaddr;
    end
end

endmodule
