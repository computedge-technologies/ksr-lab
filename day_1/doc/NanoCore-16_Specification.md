# NanoCore16 — Simple Single-Cycle Processor Specification

## 1. Overview

**NanoCore16** is a 16-bit instruction, 8-bit datapath, single-cycle processor designed for educational purposes. It executes basic arithmetic and logic instructions in a single clock cycle. All instructions are fetched from an instruction memory, decoded, executed through an ALU, and the results are written back to a register file — all within one rising edge of the clock.

---

## 2. Top-Level Parameters

| Parameter         | Value             |
|-------------------|-------------------|
| Instruction Width | 16 bits           |
| Data Width        | 8 bits            |
| Address Width     | 16 bits (PC)      |
| Register Count    | 16 (R0–R15)       |
| Clock             | Single, rising-edge |
| Reset             | Active-low, asynchronous (`rstn`) |

---

## 3. Instruction Set Architecture (ISA)

### 3.1 Instruction Format

All instructions are a fixed 16 bits wide:

```
 15      12  11       8  7        4  3        0
+-----------+----------+----------+-----------+
|  OPCODE   |    Rd    |   RS1    | RS2 / IMM |
+-----------+----------+----------+-----------+
    4 bit      4 bit     4 bit      4 bit
```

| Field  | Bits    | Description                                      |
|--------|---------|--------------------------------------------------|
| OPCODE | [15:12] | Operation code (16 possible instructions)        |
| Rd     | [11:8]  | Destination register index (0–15)                |
| RS1    | [7:4]   | Source register 1 index (0–15)                   |
| RS2    | [3:0]   | Source register 2 index (register-type ops)      |
| IMM4   | [3:0]   | 4-bit signed immediate (−8 to +7, immediate ops) |

### 3.2 Instruction Types

Instructions are grouped into three format types based on how the lower fields are interpreted:

| Type   | Fields Used          | Description                          |
|--------|----------------------|--------------------------------------|
| R-type | `Rd`, `RS1`, `RS2`  | Register-to-register operations      |
| I-type | `Rd`, `RS1`, `IMM4` | Register-immediate operations        |
| J-type | `Rd`, `RS1`, `IMM4` | Branches/jumps (Rd = condition src)  |

### 3.3 Complete Instruction Table (All 16 Opcodes)

#### Arithmetic Instructions

| OPCODE | Mnemonic | Type   | Operation                     | Description                            |
|--------|----------|--------|-------------------------------|----------------------------------------|
| `0000` | `ADD`    | R-type | `Rd ← RS1 + RS2`             | Add two registers                      |
| `0001` | `SUB`    | R-type | `Rd ← RS1 − RS2`             | Subtract RS2 from RS1                  |
| `0010` | `ADDI`   | I-type | `Rd ← RS1 + sign_ext(IMM4)`  | Add register with signed immediate     |

#### Logic Instructions

| OPCODE | Mnemonic | Type   | Operation                     | Description                            |
|--------|----------|--------|-------------------------------|----------------------------------------|
| `0011` | `AND`    | R-type | `Rd ← RS1 & RS2`             | Bitwise AND                            |
| `0100` | `OR`     | R-type | `Rd ← RS1 \| RS2`            | Bitwise OR                             |
| `0101` | `XOR`    | R-type | `Rd ← RS1 ^ RS2`             | Bitwise XOR                            |
| `0110` | `INV`    | R-type | `Rd ← ~RS1`                  | Bitwise NOT (RS2 ignored)              |

#### Shift Instructions

| OPCODE | Mnemonic | Type   | Operation                     | Description                            |
|--------|----------|--------|-------------------------------|----------------------------------------|
| `0111` | `SHL`    | I-type | `Rd ← RS1 << IMM4[2:0]`      | Logical shift left by 0–7              |
| `1000` | `SHR`    | I-type | `Rd ← RS1 >> IMM4[2:0]`      | Logical shift right by 0–7             |

#### Data Movement Instructions

| OPCODE | Mnemonic | Type   | Operation                     | Description                            |
|--------|----------|--------|-------------------------------|----------------------------------------|
| `1001` | `LDI`    | I-type | `Rd ← sign_ext(IMM4)`        | Load signed immediate (−8 to +7)       |
| `1010` | `MOV`    | R-type | `Rd ← RS1`                   | Copy register (RS2 ignored)            |

#### Comparison Instruction

| OPCODE | Mnemonic | Type   | Operation                     | Description                            |
|--------|----------|--------|-------------------------------|----------------------------------------|
| `1011` | `CMP`    | R-type | `flags ← RS1 − RS2`          | Compare: sets zero/carry flags, no writeback |

#### Control Flow Instructions

| OPCODE | Mnemonic | Type   | Operation                     | Description                            |
|--------|----------|--------|-------------------------------|----------------------------------------|
| `1100` | `JMP`    | I-type | `PC ← RS1 + sign_ext(IMM4)`  | Unconditional jump to address          |
| `1101` | `BEQ`    | J-type | `if (zero_flag) PC ← PC + sign_ext(IMM4)` | Branch if equal (zero flag set) |
| `1110` | `BNE`    | J-type | `if (!zero_flag) PC ← PC + sign_ext(IMM4)` | Branch if not equal              |

#### No Operation

| OPCODE | Mnemonic | Type   | Operation                     | Description                            |
|--------|----------|--------|-------------------------------|----------------------------------------|
| `1111` | `NOP`    | —      | No operation                  | PC increments, no register write       |

### 3.4 Instruction Encoding Quick Reference

```
OPCODE  Hex   Mnemonic    Category
──────  ────  ──────────  ────────────────
0000    0x0   ADD         Arithmetic
0001    0x1   SUB         Arithmetic
0010    0x2   ADDI        Arithmetic (imm)
0011    0x3   AND         Logic
0100    0x4   OR          Logic
0101    0x5   XOR         Logic
0110    0x6   INV         Logic
0111    0x7   SHL         Shift (imm)
1000    0x8   SHR         Shift (imm)
1001    0x9   LDI         Data Movement
1010    0xA   MOV         Data Movement
1011    0xB   CMP         Comparison
1100    0xC   JMP         Control Flow
1101    0xD   BEQ         Control Flow
1110    0xE   BNE         Control Flow
1111    0xF   NOP         No Operation
```

### 3.5 Encoding Examples

| Assembly          | Binary Encoding          | Hex    | Explanation                           |
|-------------------|--------------------------|--------|---------------------------------------|
| `ADD R1, R2, R3`  | `0000_0001_0010_0011`    | `0123` | R1 ← R2 + R3                         |
| `SUB R4, R5, R6`  | `0001_0100_0101_0110`    | `1456` | R4 ← R5 − R6                         |
| `ADDI R1, R2, 3`  | `0010_0001_0010_0011`    | `2123` | R1 ← R2 + 3                          |
| `AND R7, R8, R9`  | `0011_0111_1000_1001`    | `3789` | R7 ← R8 & R9                         |
| `LDI R3, 5`       | `1001_0011_0000_0101`    | `9305` | R3 ← 5                               |
| `LDI R3, -2`      | `1001_0011_0000_1110`    | `930E` | R3 ← 0xFE (−2 sign-extended to 8b)   |
| `MOV R1, R2`      | `1010_0001_0010_0000`    | `A120` | R1 ← R2                              |
| `CMP R0, R1, R2`  | `1011_0000_0001_0010`    | `B012` | Flags ← R1 − R2 (no writeback)       |
| `BEQ 3`           | `1101_0000_0000_0011`    | `D003` | If zero_flag: PC ← PC + 3            |
| `JMP R5, 0`       | `1100_0000_0101_0000`    | `C050` | PC ← R5 + 0                          |
| `NOP`             | `1111_0000_0000_0000`    | `F000` | No operation                          |

### 3.6 Register Convention

| Register | Alias  | Description                     |
|----------|--------|---------------------------------|
| R0       | ZERO   | Hardwired to `8'h00` (optional) |
| R1–R15   | —      | General purpose                 |

---

## 4. Datapath Block Diagram

```
                                    ┌──────────────────────────────────────────────────┐
                                    │             Top-Level: simplesinglecycleprocessor│
                                    │                                                  │
  clk ──┬──────────────────────────►│                                                  │
  rstn ─┼──────────────────────────►│                                                  │
         │                          │                                                  │──► seg0[7:0]
         │  ┌───────────┐   pc_out  │  ┌─────────────┐  instr[15:0]                    │──► seg1[7:0]
         ├─►│  Program  │──────────►│─►│ Instruction  │──────────────┐                 │──► seg2[7:0]
         │  │  Counter  │           │  │   Memory     │              │                 │──► seg3[7:0]
         │  └───────────┘           │  └─────────────┘              ▼                  │
         │                          │               ┌──────────────────────┐           │
         │                          │               │  Instruction Decoder │           │
         │                          │               │  (Control Unit)      │           │
         │                          │               └───┬──────┬──────┬───┘            │
         │                          │                   │      │      │                │
         │                          │          alu_op   │ reg_ │  rd  │  rs1, rs2/imm  │
         │                          │                   │ wr_en│ addr │  addr          │
         │                          │                   ▼      ▼      ▼                │
         │  ┌───────────┐  rd1,rd2  │            ┌───────────────┐                     │
         ├─►│  Register │◄─────────►│◄───────────│               │                     │
         │  │   File    │  wr_data  │            │     ALU       │                     │
         │  └───────────┘           │            │               │                     │
         │                          │            └───────┬───────┘                     │
         │                          │                    │ alu_result                  │
         │                          │                    │ alu_flags                   │
         │                          │                    ▼                             │
         │                          │            ┌───────────────┐                     │
         │                          │            │  Seven-Segment│──► seg outputs      │
         │                          │            │  Display Ctrl │                     │
         │                          │            └───────────────┘                     │
         │                          └──────────────────────────────────────────────────┘
```

---

## 5. Module Specifications

---

### 5.1 `program_counter`

**Purpose:** Holds and updates the 16-bit program counter on each clock cycle.

#### Ports

| Port            | Direction | Width | Description                          |
|-----------------|-----------|-------|--------------------------------------|
| `clk`           | input     | 1     | System clock                         |
| `rstn`          | input     | 1     | Active-low async reset               |
| `pc_en`         | input     | 1     | Enable (hold PC when 0)              |
| `branch_en`     | input     | 1     | Load `branch_target` when asserted   |
| `branch_target` | input     | 16    | Target address for branches/jumps    |
| `pc_out`        | output    | 16    | Current PC value                     |

#### Behavior

- **Reset:** `pc_out ← 0x0000`
- **Normal:** `pc_out ← pc_out + 1` (when `pc_en=1`, `branch_en=0`)
- **Branch:** `pc_out ← branch_target` (when `pc_en=1`, `branch_en=1`)
- **Stall:**  `pc_out` holds (when `pc_en=0`)

#### RTL File

[program_counter.sv](file:///home/praba/Projects/NanoCore16/src/rtl/program_counter.sv) — ✅ Already implemented.

---

### 5.2 `instruction_memory`

**Purpose:** ROM that stores the program. Addressed by the PC, outputs the 16-bit instruction word.

#### Ports

| Port       | Direction | Width | Description                             |
|------------|-----------|-------|-----------------------------------------|
| `addr`     | input     | 16    | Read address (from PC)                  |
| `instr`    | output    | 16    | 16-bit instruction word at `addr`       |

#### Behavior

- **Purely combinational** (asynchronous read) — fits the single-cycle model.
- Memory depth: 256 words minimum (address bits [7:0] used, upper bits ignored for small programs).
- Initialized from a hex file via `$readmemh` at simulation start.
- Read-only; no write port.

#### RTL File

`[NEW]` [instruction_memory.sv](file:///home/praba/Projects/NanoCore16/src/rtl/instruction_memory.sv)

---

### 5.3 `instruction_decoder` (Control Unit)

**Purpose:** Decodes the 16-bit instruction into control signals and register/immediate field extraction.

#### Ports

| Port         | Direction | Width | Description                                 |
|--------------|-----------|-------|---------------------------------------------|
| `instr`      | input     | 16    | Full instruction word                       |
| `zero_flag`  | input     | 1     | From ALU (for conditional branches)         |
| `opcode`     | output    | 4     | Extracted opcode `instr[15:12]`             |
| `rd_addr`    | output    | 4     | Destination register `instr[11:8]`          |
| `rs1_addr`   | output    | 4     | Source register 1 `instr[7:4]`              |
| `rs2_addr`   | output    | 4     | Source register 2 `instr[3:0]`              |
| `imm`        | output    | 8     | Sign-extended immediate `{{4{instr[3]}}, instr[3:0]}` |
| `alu_op`     | output    | 4     | ALU operation select (passed from opcode)   |
| `reg_wr_en`  | output    | 1     | Register file write enable                  |
| `imm_sel`    | output    | 1     | 1 = use sign-extended immediate, 0 = use RS2|
| `branch_en`  | output    | 1     | 1 = update PC with branch target            |

#### Behavior

- **Purely combinational.**
- Decodes `opcode` to set `alu_op`, `reg_wr_en`, and `imm_sel`.
- For `NOP`: `reg_wr_en = 0`.
- For `INV`: `imm_sel = 0`, RS2 field is don't-care (ALU ignores operand B).
- For `LDI`: ALU can pass-through the immediate.

#### Control Signal Truth Table

| OPCODE | Mnemonic | `alu_op` | `reg_wr_en` | `imm_sel` | `branch_en` | Notes                    |
|--------|----------|----------|-------------|-----------|-------------|--------------------------|
| 0000   | ADD      | 0000     | 1           | 0         | 0           |                          |
| 0001   | SUB      | 0001     | 1           | 0         | 0           |                          |
| 0010   | ADDI     | 0000     | 1           | 1         | 0           | ALU does ADD with imm    |
| 0011   | AND      | 0011     | 1           | 0         | 0           |                          |
| 0100   | OR       | 0100     | 1           | 0         | 0           |                          |
| 0101   | XOR      | 0101     | 1           | 0         | 0           |                          |
| 0110   | INV      | 0110     | 1           | 0         | 0           | RS2 don't-care           |
| 0111   | SHL      | 0111     | 1           | 1         | 0           | Shift by IMM4[2:0]       |
| 1000   | SHR      | 1000     | 1           | 1         | 0           | Shift by IMM4[2:0]       |
| 1001   | LDI      | 1001     | 1           | 1         | 0           | Pass-through imm         |
| 1010   | MOV      | 1010     | 1           | 0         | 0           | Pass-through RS1         |
| 1011   | CMP      | 0001     | **0**       | 0         | 0           | SUB but no writeback     |
| 1100   | JMP      | xxxx     | 0           | x         | 1           | Unconditional            |
| 1101   | BEQ      | xxxx     | 0           | x         | zero_flag   | Conditional on zero      |
| 1110   | BNE      | xxxx     | 0           | x         | !zero_flag  | Conditional on !zero     |
| 1111   | NOP      | xxxx     | 0           | x         | 0           |                          |

#### RTL File

`[NEW]` [instruction_decoder.sv](file:///home/praba/Projects/NanoCore16/src/rtl/instruction_decoder.sv)

---

### 5.4 `register_file`

**Purpose:** 16-entry × 8-bit register file with 2 read ports and 1 write port.

#### Ports

| Port       | Direction | Width | Description                            |
|------------|-----------|-------|----------------------------------------|
| `clk`      | input     | 1     | System clock                           |
| `rstn`     | input     | 1     | Active-low async reset                 |
| `wr_en`    | input     | 1     | Write enable                           |
| `rd_addr`  | input     | 4     | Write (destination) register address   |
| `rs1_addr` | input     | 4     | Read port 1 address                    |
| `rs2_addr` | input     | 4     | Read port 2 address                    |
| `wr_data`  | input     | 8     | Data to write to `rd_addr`             |
| `rs1_data` | output    | 8     | Data read from `rs1_addr`              |
| `rs2_data` | output    | 8     | Data read from `rs2_addr`              |

#### Behavior

- **Read:** Combinational (asynchronous). `rs1_data = reg[rs1_addr]`, `rs2_data = reg[rs2_addr]`.
- **Write:** On `posedge clk`, if `wr_en == 1`, then `reg[rd_addr] ← wr_data`.
- **Reset:** All 16 registers cleared to `8'h00`.
- **R0 hardwire (optional):** Writes to R0 are ignored; R0 always reads `8'h00`.

#### RTL File

`[NEW]` [register_file.sv](file:///home/praba/Projects/NanoCore16/src/rtl/register_file.sv)

---

### 5.5 `alu`

**Purpose:** Performs the arithmetic and logic operation selected by `alu_op`.

#### Ports

| Port         | Direction | Width | Description                              |
|--------------|-----------|-------|------------------------------------------|
| `alu_op`     | input     | 4     | Operation select                         |
| `operand_a`  | input     | 8     | First operand (from RS1)                 |
| `operand_b`  | input     | 8     | Second operand (from RS2 or sign-ext IMM)|
| `alu_result` | output    | 8     | Computation result                       |
| `zero_flag`  | output    | 1     | 1 if result == 0                         |
| `carry_flag` | output    | 1     | Carry out from ADD/SUB                   |

#### ALU Operations

| `alu_op` | Operation           | Result                        | Flags Updated  |
|----------|---------------------|-------------------------------|----------------|
| 0000     | ADD                 | `operand_a + operand_b`       | zero, carry    |
| 0001     | SUB                 | `operand_a − operand_b`       | zero, carry    |
| 0011     | AND                 | `operand_a & operand_b`       | zero           |
| 0100     | OR                  | `operand_a \| operand_b`      | zero           |
| 0101     | XOR                 | `operand_a ^ operand_b`       | zero           |
| 0110     | INV (NOT)           | `~operand_a`                  | zero           |
| 0111     | SHL                 | `operand_a << operand_b[2:0]` | zero           |
| 1000     | SHR                 | `operand_a >> operand_b[2:0]` | zero           |
| 1001     | PASS_B (for LDI)    | `operand_b`                   | zero           |
| 1010     | PASS_A (for MOV)    | `operand_a`                   | zero           |
| others   | Default: zero       | `8'h00`                       | zero           |

#### Behavior

- **Purely combinational.**
- `zero_flag = (alu_result == 8'h00)`
- `carry_flag` is the 9th bit of the add/sub result; 0 for logic operations.

#### RTL File

`[NEW]` [alu.sv](file:///home/praba/Projects/NanoCore16/src/rtl/alu.sv)

---

### 5.6 `seven_seg_display` (Optional Output Module)

**Purpose:** Drives 4 seven-segment display outputs to show a 16-bit value (e.g., ALU result on seg0/seg1, PC on seg2/seg3).

#### Ports

| Port      | Direction | Width | Description                      |
|-----------|-----------|-------|----------------------------------|
| `data_in` | input     | 16    | 16-bit value to display          |
| `seg0`    | output    | 8     | Segment 0 (nibble 0) encoding   |
| `seg1`    | output    | 8     | Segment 1 (nibble 1) encoding   |
| `seg2`    | output    | 8     | Segment 2 (nibble 2) encoding   |
| `seg3`    | output    | 8     | Segment 3 (nibble 3) encoding   |

#### Behavior

- **Purely combinational.**
- Each nibble (4 bits) of `data_in` is converted to a 7-segment encoding.
- Active-low or active-high encoding (choose based on your FPGA board).

#### RTL File

`[NEW]` [seven_seg_display.sv](file:///home/praba/Projects/NanoCore16/src/rtl/seven_seg_display.sv)

---

### 5.7 `simplesinglecycleprocessor` (Top-Level)

**Purpose:** Top-level module that instantiates and wires all sub-modules together.

#### Ports

| Port   | Direction | Width | Description               |
|--------|-----------|-------|---------------------------|
| `clk`  | input     | 1     | System clock              |
| `rstn` | input     | 1     | Active-low async reset    |
| `seg0` | output    | 8     | Seven-segment display 0   |
| `seg1` | output    | 8     | Seven-segment display 1   |
| `seg2` | output    | 8     | Seven-segment display 2   |
| `seg3` | output    | 8     | Seven-segment display 3   |

#### Internal Wiring Summary

```
PC ──addr──► Instruction Memory ──instr──► Decoder
                                              │
                          ┌───────────────────┼──────────────────┐
                          │ rs1_addr, rs2_addr │  rd_addr, wr_en │
                          ▼                    ▼                 │
                     Register File                               │
                      │          │                               │
                 rs1_data    rs2_data/imm                        │
                      │          │                               │
                      ▼          ▼                               │
                    ┌──────────────┐                             │
                    │     ALU      │                             │
                    └──────┬───────┘                             │
                           │ alu_result ────────────────────────►│
                           │                              wr_data│
                           ▼
                    Seven-Segment Display ──► seg0–seg3
```

#### RTL File

[simplesinglecycleprocessor.sv](file:///home/praba/Projects/NanoCore16/src/rtl/simplesinglecycleprocessor.sv) — Existing, needs refactoring to instantiate sub-modules.

---

## 6. Single-Cycle Timing Diagram

```
         ┌────────┐         ┌────────┐         ┌────────┐
  clk ───┘        └─────────┘        └─────────┘        └───
         ◄─── Cycle N ─────►◄─── Cycle N+1 ───►

        │                   │                   │
        │  ┌─ IF ──────┐   │                   │
        │  │ PC → IMEM  │   │                   │
        │  └────┬───────┘   │                   │
        │       ▼           │                   │
        │  ┌─ ID ──────┐   │                   │
        │  │ Decode     │   │                   │
        │  └────┬───────┘   │                   │
        │       ▼           │                   │
        │  ┌─ EX ──────┐   │                   │
        │  │ ALU Exec   │   │                   │
        │  └────┬───────┘   │                   │
        │       ▼           │                   │
        │  ┌─ WB ──────┐   │                   │
        │  │ Reg Write  │   │                   │
        │  └────────────┘   │                   │
        │                   │                   │
        ▲                   ▲                   ▲
     posedge             posedge             posedge
     PC updates          PC updates          PC updates
     Reg writes          Reg writes
```

All stages (IF → ID → EX → WB) complete combinationally within a single clock cycle. Only the **PC** and **Register File writes** are clocked (on `posedge clk`).

---

## 7. Module Hierarchy & File Listing

```
simplesinglecycleprocessor          (top-level)
├── program_counter                 ✅ Implemented
├── instruction_memory              🔲 To implement
├── instruction_decoder             🔲 To implement
├── register_file                   🔲 To implement
├── alu                             🔲 To implement
└── seven_seg_display               🔲 To implement
```

---

## 8. Verification Plan

| Test                     | Description                                              |
|--------------------------|----------------------------------------------------------|
| Reset test               | Assert `rstn=0`, verify all regs and PC are zeroed       |
| ADD / SUB / ADDI         | Load operands via LDI, execute add/sub variants, check Rd |
| AND / OR / XOR           | Test all logic ops with known operand patterns            |
| INV                      | Verify bitwise inversion, check RS2 is ignored           |
| SHL / SHR                | Shift by 0, 1, 7; verify boundary and zero results       |
| LDI / MOV                | Load immediates (positive & negative), copy between regs  |
| CMP                      | Compare equal/unequal values, verify flags with no writeback |
| JMP                      | Jump to absolute address via register, verify PC changes  |
| BEQ / BNE                | Set flags via CMP, then branch; verify taken/not-taken    |
| NOP                      | Verify no register is modified, PC still increments       |
| Sequential program       | Run a multi-instruction program, verify final state       |
| Flag verification        | Check `zero_flag` and `carry_flag` for boundary cases     |
