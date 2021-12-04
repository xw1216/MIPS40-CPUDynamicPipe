`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/10/27 17:52:14
// Design Name: 
// Module Name: REGFILES
// 
//////////////////////////////////////////////////////////////////////////////////


module regfiles
(
    input wire clk,
    input wire we,
    input wire rst,
    
    input   wire [ 4:0]  raddr1,
    input   wire [ 4:0]  raddr2,
    output  wire [31:0]  rdata1,
    output  wire [31:0]  rdata2,
    output  wire [31:0]  test_result,

    input   wire [ 4:0]  waddr,
    input   wire [31:0]  wdata,
    input   wire [ 4:0]  arguments
);

reg [31:0] reg_array[31:0];

always @(posedge clk or posedge rst) begin
    if(rst) begin
        // pre-loaded matrix rows and cols from external switches
        reg_array[0] <= 32'b0;
        reg_array[2] <= { 28'd0, arguments[4:0] };
    end
    else if(we) begin
        if(~(waddr == 5'd0)) begin
            reg_array[waddr] <= wdata;
        end
    end
end

assign rdata1 = (raddr1 == 5'd0) ? 32'b0 : reg_array[raddr1];
assign rdata2 = (raddr2 == 5'd0) ? 32'b0 : reg_array[raddr2];
assign test_result = reg_array[5'd1];

endmodule
