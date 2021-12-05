`timescale 1ns / 1ps
// 
// Create Date: 2021/11/08 11:33:55
// Design Name: 
// Module Name: clk_div_manual
// 
//////////////////////////////////////////////////////////////////////////////////


module clk_div_manual
(
    input wire rst,
    input wire clkin,
    output reg clk,
    output reg mem_clk
);

reg [ 4:0] rst_counter; 
reg [23:0] counter;

always @ (posedge rst or posedge clkin) begin
    if(rst) begin
//        clk <= 1'b0;
//        mem_clk <= 1'b1;
        counter <= 24'd0;
        rst_counter <= rst_counter + 1;
        if(rst_counter == 5'd2) begin
            clk <= 1'b1;
            mem_clk <= 1'b0;
        end
        else begin
            clk <= 1'b0;
            mem_clk <= 1'b1;
        end
    end
    else begin
        rst_counter <= 5'd0;
        // map 50MHz to 100Hz 24'd500000
        if(counter >= 24'd500000) begin
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
