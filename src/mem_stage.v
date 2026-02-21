module mem_stage(AR, sram_addr);
    input [11:0] AR; 
    output [11:0] sram_addr;

    assign sram_addr = AR;// AR값을 sram으로 보냄

endmodule