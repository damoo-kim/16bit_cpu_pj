`timescale 1ns/1ps

module sram(clk, addr, din, dout, we);

    input clk, we;
    input [7:0] addr;
    input [15:0] din;
    output reg [15:0] dout;
    reg [15:0] debug_mem0, debug_mem1, debug_mem2;
    
    reg [15:0] mem [0:127];
    
    always @(posedge clk)begin
        if(we)begin
            mem[addr] <= din;
        end
    end

    always @(*)begin //sensitivity에 *쓰는걸 권장, * == (we, addr, mem[addr])
        if(!we)begin
            dout = #1 mem[addr];
        end
        debug_mem0 = mem[0];
        debug_mem1 = mem[1];
        debug_mem2 = mem[2];
    end
    
endmodule
