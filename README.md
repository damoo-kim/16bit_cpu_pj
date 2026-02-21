# 16-bit CPU RTL Design & Data Processing 💻

##  Project Overview
본 프로젝트는 Verilog를 활용하여 16-bit CPU를 RTL 단계에서 설계하고, 시뮬레이션을 통해 동작을 검증한 프로젝트입니다. 커스텀 명령어 세트(ISA)를 기반으로 동작하는 CPU DUT를 구현하였으며, SRAM에 저장된 10개의 학생 성적 데이터를 읽어와 총합을 계산하고 메모리에 다시 저장하는 어셈블리 프로그램을 구동합니다.

- **진행 기간**: 2025. 03 ~ 2025. 04
- **사용 기술**: Verilog, RTL Simulation (Xcelium 등 EDA Tool 활용 가능)
- **주요 목표**: 
- Memory-Reference 및 Register-Reference 명령어 세트의 완벽한 RTL 구현
- SRAM 메모리 맵 구성 및 Testbench를 통한 Memory Dump 환경 구축
- 시뮬레이션 종료 후 연산 결과를 `result.dat` 파일로 추출하여 동작 검증

---

##  Architecture & Memory Map

### Memory Map (SRAM)
| Address (Decimal) | Content | Description |
| :--- | :--- | :--- |
| `0 ~ ` | **Instruction Code** | 성적 합산을 수행하는 Assembly Code를 Binary로 변환하여 로드 |
| `99` | **Final Result** | 최종 성적 합산 결과가 저장되는 주소 |
| `100 ~ 109` | **Data (Scores)** | 학생 10명의 성적 데이터 (e.g., 77, 100, 66, ... 90) |

**1. Memory-Reference Instructions**
* `AND` (0xxx / 8xxx): AND memory word to AC
* `ADD` (1xxx / 9xxx): Add memory word to AC
* `LDA` (2xxx / Axxx): Load memory word to AC
* `STA` (3xxx / Bxxx): Store content of AC in memory
* `BUN` (4xxx / Cxxx): Branch unconditionally
* `BSA` (5xxx / Dxxx): Branch and save return address
* `ISZ` (6xxx / Exxx): Increment and skip if zero

**2. Register-Reference Instructions**
* `CLA` (7800): Clear AC
* `CLE` (7400): Clear E
* `CMA` (7200): Complement AC
* `LDC` (71xx): Load xxx to AC (Immediate Load)
* `CIR` (7080): Circulate right AC and E
* `CIL` (7040): Circulate left AC and E
* `INC` (7020): Increment AC
* `SPA` (7010): Skip next instruction if AC positive
* `SNA` (7008): Skip next instruction if AC negative
* `SZA` (7004): Skip next instruction if AC Zero
* `SZE` (7002): Skip next instruction if E is 0
* `MOV` (7001): Copy AC data to DR