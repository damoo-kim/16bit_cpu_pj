`timescale 1ns/1ps
module tb_top();
    reg clk, rst;
    reg [7:0] AR;
    reg [2:0] sel;
    reg [5:0] load;

    top top_0(
        .clk(clk), 
        .rst(rst), 
        .sel(sel), 
        .load(load), 
        .AR(AR));

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #1 rst = 1'b0;
        #1 rst = 1'b1;
        $dumpfile("sim/top_wave.vcd");  // 파형 저장
        $dumpvars(0, tb_top);      // 전체 변수 저장

        $readmemh("sram.dat", tb_top.top_0.sram_0.mem);
        sel = 3'b101; AR = 8'b0000_0000;
        #8 load = 6'b000010; 
        #10 sel = 3'b001; AR = 8'b0000_0001; load = 6'b100000;
        #10 sel = 3'b101; 
        #10 load = 6'b010000;
        #10
        $finish;
    end
endmodule
