module opcode_decoder(opcode, opcode_one_hot);
    input [2:0] opcode; 
    output [7:0] opcode_one_hot;

    assign opcode_ont_hot = 8'b1 << opcode;

endmodule