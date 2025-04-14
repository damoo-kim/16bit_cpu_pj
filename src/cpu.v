`timescale 1ns/1ps

module cpu(clk, rst, sel, load, AR_in, sram_dout, sram_din, addr, we);

    input clk, rst;
    input [7:0] AR_in;
    input [2:0] sel; //AR:000 IR:001 PC:010 DR:011 AC:100 sram:101
    input [5:0] load; //AR:000001 IR:000010 PC:000100 DR:001000 AC:010000 sram:100000
    input [15:0] sram_dout; // SRAM 출력은 입력으로 받음
    output reg [7:0] addr;
    output reg [15:0] sram_din;
    output reg we;
    
    reg [7:0] AR, PC;
    reg [15:0] IR, DR, AC; 
    reg [15:0] bus; 

    always @(posedge clk, negedge rst)begin
        if(!rst)begin // 레지스터 초기화
            AR <= 8'b0000_0000;
            IR <= 16'b0000_0000_0000_0000;
            PC <= 8'b0000_0000;
            DR <= 16'b0000_0000_0000_0000;
            AC <= 16'b0000_0000_0000_0000;
            we <= 1'b0; 
        end
        else begin 
            //일단 we <= 1'b0 예약,조건이 맞으면 we <= 1'b1로 덮어쓰기 예약,
            //클럭 끝날 때 둘 중 하나만 적용됨
            we <= 1'b0; 
            AR <= AR_in;
            addr <= AR; //필요할때만 addr<=ar수행하게는 못할까?
            
            case(load) // bus 값 load
                6'b000001 : AR <= bus[7:0];
                6'b000010 : IR <= bus;
                6'b000100 : PC <= bus[7:0];
                6'b001000 : DR <= bus;
                6'b010000 : AC <= bus;
                6'b100000 : begin sram_din <= bus; we <= 1'b1; end 
            endcase
        end
    end

    /*
    위에 방식을쓰지 않고 rst와 load를 별개의 always문에서 구현하면 else를 사용하지 않아
    clock gating 측면에서 유리할 거 같음 <-근데 이건 load는 계속 활성화해야하는 신호니까 의미 없을지도?

    이거 아니더라도 위 처럼 else 문안에 case문을 쓰면 mux 2개가 연결되서 생성되기에 critical path가 
    길어져 느려 질거 같아서 분리된 구조로도 구현해봄

    always @(negedge rst)begin
        if(!rst)begin
            AR <= 12'b0000 0000 0000;
            IR <= 16'b0000 0000 0000 0000;
            PC <= 12'b0000 0000 0000;
            DR <= 16'b0000 0000 0000 0000;
            AC <= 16'b0000 0000 0000 0000;
        end
    end

    always @(posedge clk)begin
        case(load)
            6'b000001 : AR <= bus;
            6'b000010 : IR <= bus;
            6'b000100 : PC <= bus;
            6'b001000 : DR <= bus;
            6'b010000 : AC <= bus;
            6'b100000 : begin din <= bus; addr <= AR; we <= 1'b1; end 
        endcase
    end
    */

    always @(*)begin
        case(sel) //버스에 태울값 select
            3'b000 :  bus = {8'b0000_0000, AR};
            3'b001 :  bus = IR;
            3'b010 :  bus = {8'b0000_0000, PC};
            3'b011 :  bus = DR;
            3'b100 :  bus = AC;
            3'b101 :  bus = sram_dout;
            default : bus = 16'b0000_0000_0000_0000;
        endcase
    end

endmodule
