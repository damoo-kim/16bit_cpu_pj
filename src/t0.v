`timescale 1ns/1ps

module cpu(clk, rst, sram_dout, sram_addr, sram_din, we);
    //상태 및 명령어 매핑
    parameter T0 = 5'b00000,
            T1 = 5'b00001,
            T2 = 5'b00010,
            T3_reg_reference = 5'b00011;

    parameter CLA = 12'b100000000000,
            CLE = 12'b010000000000,
            CMA = 12'b001000000000,
            CME = 12'b000100000000,
            CIR = 12'b000010000000,
            CIL = 12'b000001000000,
            INC = 12'b000000100000,
            SPA = 12'b000000010000,
            SNA = 12'b000000001000,
            SZA = 12'b000000000100,
            SZE = 12'b000000000010,
            MOV = 12'b000000000001;

    input clk, rst;
    input [15:0] sram_dout;

    output [11:0] sram_addr;
    input [15:0] sram_din;
    output reg we;
    
    reg [11:0] PC, AR;
    reg [15:0] IR, AC, DR;
    reg E;
    //fsm 방식으로 상태제어, 메모리 레퍼런스 확장 고려해서 그냥 5비트로 함
    reg [4:0] current_state; 
    reg [4:0] next_state;

    wire I;
    wire [2:0] opcode;

    mem_stage mem_stage0(  
        .AR(AR), 
        .sram_addr(sram_addr));

    id_stage id_stage0(
        .IR(IR),
        .opcode(opcode),
        .I(I));

    always@ (posedge clk or negedge rst)begin
        if(!rst)begin
            PC <= 12'b0000_0000_0000;
            AR <= 12'b0000_0000_0000;
            IR <= 16'b0000_0000_0000_0000;
            AC <= 16'b0000_0000_0000_0000;
            DR <= 16'b0000_0000_0000_0000;
            current_state <= T0;
            E <= 1'b0;
            we <= 1'b0;
        end
        else begin
            current_state <= next_state;
            case(current_state)
                T0 : AR <= PC;
                T1 : begin 
                    IR <= sram_dout;
                    PC <= PC + 1;
                end
                T2 : AR <= IR[11:0];
                T3_reg_reference : begin      
                    case(IR[11:0])
                        CLA : AC <= 16'b0000_0000_0000_0000;
                        CLE : E <= 1'b0;
                        CMA : AC <= ~AC;
                        CME : E <= ~E;
                        CIR : AC <= {E, AC[15:1]};
                        CIL : AC <= {AC[14:0], E};
                        INC : AC <= AC + 1;
                        SPA : begin //SPA
                            if(AC[15] == 0 && AC != 16'b0)begin
                                PC <= PC + 1;
                            end
                        end
                        SNA : begin //SNA
                            if(AC[15] == 1)begin
                                PC <= PC + 1;
                            end
                        end
                        SZA : begin //SZA
                            if(AC == 16'b0)begin
                                PC <= PC + 1;
                            end
                        end
                        SZE : begin //SZE
                            if(E == 0)begin
                                PC <= PC + 1;
                            end
                        end
                        MOV : DR <= AC;  
                    endcase       
                end
            endcase
        end
    end
    
    //next stage 정하기
    always @(*)begin
        case(current_state)
            T0 : next_state = T1;
            T1 : next_state = T2;
            T2 : next_state = T3_reg_reference;
            T3_reg_reference : next_state = T0;
            default: next_state = T0;
        endcase
    end
endmodule