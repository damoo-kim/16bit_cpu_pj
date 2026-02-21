`timescale 1ns/1ps

module cpu(clk, rst, sram_dout, sram_addr, sram_din, we);
    //상태 및 명령어 매핑
    parameter T0 = 5'b00000,
            T1 = 5'b00001,
            T2 = 5'b00010,
            T3_reg_reference = 5'b00011,
            T3_mem_indirect = 5'b00100,
            T3_mem_direct = 5'b00101,
            T4_AND = 5'b00110,
            T5_AND= 5'b00111,
            T4_ADD = 5'b01000,
            T5_ADD = 5'b01001,
            T4_LDA = 5'b01010,
            T5_LDA= 5'b01011,
            T4_STA = 5'b01100,
            T4_BUN = 5'b01101,
            T4_BSA = 5'b01110,
            T5_BSA = 5'b01111,
            T4_ISZ= 5'b10000,
            T5_ISZ = 5'b10001,
            T6_ISZ = 5'b10010;


    parameter CLA = 12'b100000000000,
            CLE = 12'b010000000000,
            CMA = 12'b001000000000,
            LDC = 12'b000100000000,
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
    output reg [15:0] sram_din;
    output reg we;
    
    reg [11:0] PC, AR;
    reg [15:0] IR, AC, DR;
    reg E;
    //fsm 방식으로 상태제어, 메모리 레퍼런스 확장 고려해서 그냥 5비트로 함
    reg [4:0] current_state; 
    reg [4:0] next_state;

    wire I;
    wire [2:0] opcode;
    wire [7:0] opcode_one_hot;
    
    opcode_decoder opcode_decoder_0(
        .opcode(opcode), 
        .opcode_one_hot(opcode_one_hot));

    mem_stage mem_stage_0(  
        .AR(AR), 
        .sram_addr(sram_addr));

    id_stage id_stage_0(
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
            we <= 1'b0;
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
                        CIR : begin   
                            AC <= {E, AC[15:1]};
                            E <= AC[0];
                        end
                        CIL : begin 
                            AC <= {AC[14:0], E};
                            E <= AC[15];
                        end
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
                    if(IR[8] == 1)begin
                        AC[7:0] <= IR[7:0];
                    end
                end
                T3_mem_indirect : AR <= sram_dout[11:0];
                T3_mem_direct : /*nothing*/;
                T4_AND : DR <= sram_dout;
                T5_AND : AC <= AC & DR;
                T4_ADD : DR <= sram_dout;
                // 17‑bit adder: 비트 폭을 늘려 캐리(E)를 정확히 저장
                T5_ADD : {E, AC} <= {1'b0, AC} + {1'b0, DR};
                T4_LDA : DR <= sram_dout;
                T5_LDA : AC <= DR;
                T4_STA : begin 
                    we <= 1'b1;
                    sram_din <= AC;
                end
                T4_BUN : PC <= AR;
                T4_BSA : begin 
                    we <= 1'b1;
                    sram_din <= PC;
                    AR <= AR+1;
                end
                T5_BSA : PC <= AR;
                T4_ISZ : DR <= sram_dout;
                T5_ISZ : DR <= DR + 1;
                T6_ISZ : begin 
                    we <= 1'b1;
                    sram_din <= DR;
                    if(DR == 0)begin
                        PC <= PC + 1;
                    end
                end
            endcase
        end
    end
    
    //next stage 정하기
    always @(*)begin
        case(current_state)
            T0 : next_state = T1;
            T1 : next_state = T2;
            T2 : begin 
                if(opcode_one_hot[7] == 1) //레지스터 레퍼런스
                    next_state = T3_reg_reference;
                else begin //메모리 레퍼런스
                    if(I == 1)begin //인다이렉트
                        next_state = T3_mem_indirect;
                    end
                    else begin // 다이렉트
                        next_state = T3_mem_direct;
                    end
                end
            end
            T3_reg_reference : next_state = T0;
            T3_mem_direct, T3_mem_indirect : begin
                //메모리 레퍼런스의 경우 one_hot코드화 한 op코드로 명령어 분기 나눔
                case(opcode_one_hot) 
                    8'b00000001 : next_state = T4_AND;
                    8'b00000010 : next_state = T4_ADD;
                    8'b00000100 : next_state = T4_LDA;
                    8'b00001000 : next_state = T4_STA;
                    8'b00010000 : next_state = T4_BUN;
                    8'b00100000 : next_state = T4_BSA;
                    8'b01000000 : next_state = T4_ISZ;
                    default : next_state = T0;
                endcase
            end
            T4_AND : next_state = T5_AND;
            T5_AND : next_state = T0;
            T4_ADD : next_state = T5_ADD;
            T5_ADD : next_state = T0;
            T4_LDA : next_state = T5_LDA;
            T5_LDA : next_state = T0;
            T4_STA : next_state = T0;
            T4_BUN : next_state = T0;
            T4_BSA : next_state = T5_BSA;
            T5_BSA : next_state = T0;
            T4_ISZ : next_state = T5_ISZ;
            T5_ISZ : next_state = T6_ISZ;
            T6_ISZ : next_state = T0;
            default: next_state = T0;
        endcase
    end
endmodule