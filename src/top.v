`timescale 1ns/1ps

module computer(clk, rst);
    
    input clk, rst;
    
    wire we;
    wire [11:0] sram_addr;
    wire [15:0] sram_dout;
    wire [15:0] sram_dout;

    cpu cpu_0(
        .clk(clk), 
        .rst(rst), 
        .sram_dout(sram_dout),
        .sram_addr(sram_addr),
        .sram_din(sramdin),
        .we(we));

    sram sram_0(
        .clk(clk), 
        .addr(sram_addr), 
        .din(sram_din),
        .dout(sram_dout), 
        .we(we));

endmodule