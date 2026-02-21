`timescale 1ns/1ps

module ctrl_unit(opcode);
    input opcode;
    
    always @(opcode)begin
        case(opcode) // bus 값 load
            4'b0111 : reg_op;
            default : ;
        endcase
    end

endmodule