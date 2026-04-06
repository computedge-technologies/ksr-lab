# Top-Level Integration Plan

This document outlines how to integrate the five sub-modules into the top-level `simplesinglecycleprocessor.sv`, including the 7-segment display logic.

## 1. Signal Definitions

You will need internal wires to connect the ports of each module.

```systemverilog
// IF - Instruction Fetch
logic [15:0] pc_val;
logic [15:0] instr;
logic [15:0] pc_target;

// ID - Instruction Decode
logic [3:0] opcode, rd_addr, rs1_addr, rs2_addr, alu_op;
logic [7:0] imm;
logic       reg_wr_en, imm_sel, branch_en;

// EX - Execute
logic [7:0] rs1_data, rs2_data, operand_b, alu_result;
logic       zero_flag, carry_flag;

// 7-Segment Display Signals
logic [7:0] alu_result_low_seg, alu_result_high_seg;
logic [7:0] pc_low_seg, pc_high_seg;
```

## 2. Datapath Connections

### ALU Operand Mux
The ALU's second operand (`operand_b`) is selected based on `imm_sel` from the decoder.
```systemverilog
assign operand_b = imm_sel ? imm : rs2_data;
```

### Branch Target Logic
The `branch_target` for the Program Counter depends on the instruction type:
1. **`JMP`**: Address is calculated by the ALU (`RS1 + IMM`).
2. **`BEQ/BNE`**: Target is relative to the current PC (`PC + sign_ext(IMM4)`).

```systemverilog
// Simple logic to compute target
assign pc_target = (opcode == 4'b1100) ? {8'h00, alu_result} : (pc_val + {{12{instr[3]}}, instr[3:0]});
```

## 3. Module Instantiation Template

### `program_counter`
- `clk`, `rstn`: Global signals.
- `pc_en`: Keep high (`1'b1`) for single-cycle execution.
- `branch_en`, `branch_target`: From decoder and target logic above.
- `pc_out`: Connect to `pc_val`.

### `instruction_mem`
- `addr`: Connect to `pc_val`.
- `instr`: Connect to output `instr`.

### `instruction_decoder`
- `instr`: From memory.
- `zero_flag`: From ALU.
- `opcode`, `rd_addr`, etc.: Basic wiring.

### `register_file`
- `wr_en`, `rd_addr`, `rs1_addr`, `rs2_addr`: From decoder.
- `wr_data`: Connect to `alu_result`.
- `rs1_data`, `rs2_data`: Outputs for ALU.

### `alu`
- `alu_op`, `operand_a`: From decoder and RF.
- `operand_b`: From the mux logic.
- `alu_result`, `zero_flag`: Outputs.

### `seven_seg_decoder` (x4 Instantiations)
- **Unit 0 (seg0)**: Input `alu_result[3:0]`, Output `seg0`.
- **Unit 1 (seg1)**: Input `alu_result[7:4]`, Output `seg1`.
- **Unit 2 (seg2)**: Input `pc_val[3:0]`, Output `seg2`.
- **Unit 3 (seg3)**: Input `pc_val[7:4]`, Output `seg3`.

## 4. Verification Check
After wiring, the processor should be able to:
- Increment PC by 1 on every clock (when `branch_en` is 0).
- Load the calculated `pc_target` when `branch_en` is 1.
- Write ALU results back to the register file (except for `CMP`).
