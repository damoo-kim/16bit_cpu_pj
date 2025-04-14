`timescale 1ns/1ps

module top(clk, rst, sel, load, AR);
    
    input clk, rst;
    input [2:0] sel;
    input [5:0] load;
    input [7:0] AR;

    wire [7:0] addr;
    wire [15:0] sram_din;
    wire [15:0] sram_dout;
    wire we;

    cpu cpu_0(
        .clk(clk), 
        .rst(rst), 
        .sel(sel), 
        .load(load), 
        .AR_in(AR),
        .sram_din(sram_din),
        .sram_dout(sram_dout),
        .addr(addr),
        .we(we));

    sram sram_0(
        .clk(clk), 
        .addr(addr), 
        .din(sram_din), 
        .dout(sram_dout), 
        .we(we));

endmodule
