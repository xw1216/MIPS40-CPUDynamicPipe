`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Create Date: 2021/10/31 14:42:05
// Design Name: 
// Module Name: regfile_tb
// 
//////////////////////////////////////////////////////////////////////////////////


module regfile_tb();
    
reg [0:0] clk;
reg [0:0] we;
reg [0:0] rst;

reg [4:0] raddr1;
reg [4:0] raddr2;

wire [31:0] rdata1;
wire [31:0] rdata2;

reg [4:0] waddr;
reg [31:0] wdata;

regfiles uut(
    .clk(clk),
    .we(we),
    .rst(rst),
    .raddr1(raddr1),
    .raddr2(raddr2),
    .rdata1(rdata1),
    .rdata2(rdata2),
    .waddr(waddr),
    .wdata(wdata)
);

// set clock
initial
begin
    clk = 0;
    forever
    begin
        #5 clk = 1;
        #5 clk = 0;
    end
end

// init 
initial
begin
    rst = 1;
    we = 0;
    raddr1 = 0;
    raddr2 = 0;
end

// test data
initial
begin
    #5 
    rst = 0;
    we = 1;
    waddr = 0;
    wdata = 32'h0000ffff;
    
    #10
    we = 1;
    waddr = 1;
    wdata = 32'hffff0000;
    
    #10
    we = 0;
    raddr1 = 0;
    raddr2 = 1;
    
    #10
    we = 1;
    waddr = 3;
    wdata = 32'h0f0f0f0f;
    
    #10
    waddr = 4;
    wdata = 32'hffffffff;
    
    #10
    we = 0;
    raddr1 = 3;
    raddr2 = 4;
    
    #10
    rst = 1;
    we = 0;
    
    #10
    $stop;
end

endmodule
