`timescale 1ns/1ps
module tb_top();
    reg clk, rst;
    integer sram_pointer, reg_pointer;

    top top_0(
        .clk(clk), 
        .load(load), );

    always #5 clk = ~clk;

    initial begin
        $readmemb("input.txt", tb_top.top_0.sram_0.mem);

        clk = 1'b0;
        rst = 1'b1;
        #1 rst = 1'b0;
        #1 rst = 1'b1;
        sel = 3'b101;
        #8load = 6'b000010; 
        #10 sel = 3'b001; load = 6'b100000;
        #10 sel = 3'b101;
        #10 load = 6'b010000;
        
        #10 sram_pointer = $fopen("sram.dat");
        reg_pointer = $fopen("reg.dat");
        
        $fdisplay(sram_pointer, "%d", tb_top.top_0.sram_0.mem[0]);
        $fdisplay(sram_pointer, "%d", tb_top.top_0.sram_0.mem[1]);
        $fdisplay(sram_pointer, "%d", tb_top.top_0.sram_0.mem[2]);
        $fdisplay(sram_pointer, "%d", tb_top.top_0.sram_0.mem[3]);
        
        $fdisplay(reg_pointer, "IR: %d", tb_top.top_0.cpu_0.IR);
        $fdisplay(reg_pointer, "DR: %d", tb_top.top_0.cpu_0.DR);
        $fdisplay(reg_pointer, "AC: %d", tb_top.top_0.cpu_0.AC);
        $fdisplay(reg_pointer, "AR: %d", tb_top.top_0.cpu_0.AR);
        $fdisplay(reg_pointer, "PC: %d", tb_top.top_0.cpu_0.PC);
        
        #10 $fclose("sram.dat"); $fclose("reg.dat");
        $finish;
    end
endmodule