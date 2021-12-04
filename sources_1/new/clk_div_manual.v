`timescale 1ns / 1ps
// 
// Create Date: 2021/11/08 11:33:55
// Design Name: 
// Module Name: clk_div_manual
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_div_manual
(
    input wire reset,
    input wire clkin,
    output reg clk,
    output reg mem_clk
);

reg [23:0] counter;

always @ (posedge reset or posedge clkin) begin
    if(reset) begin
        clk <= 1'b0;
        mem_clk <= 1'b1;
        counter <= 24'd0;
    end
    else begin
        // map 100MHz to 10000Hz
        if(counter >= 24'd10000) begin
            clk <= ~clk;
            mem_clk <= ~mem_clk;
            counter <= 24'd0;
        end
        else begin
            counter <= counter + 1;
        end
    end

end


endmodule
