/* 
 * =================================================================================================
 * MODULE: NanoCore16 Single-Cycle Processor (Top-Level)
 * =================================================================================================
 * ARCHITECTURE OVERVIEW:
 * NanoCore16 is an 8-bit RISC-style CPU utilizing a 16-bit fixed-length instruction format. 
 * This top-level module serves as the primary integration point for the following sub-modules:
 * 
 * 1. pc_unit        : Manages the 16-bit Program Counter and next-address selection logic.
 * 2. instruction_mem: Stores the program code and provides combinational read access.
 * 3. decoder        : Translates instructions into control signals (opcode, reg-write, imm-sel, etc.).
 * 4. register_file  : A 16x8 GPR file with R0 hardwired to zero for architectural consistency.
 * 5. alu            : Performs all arithmetic, logical, and passing operations.
 * 
 * INSTRUCTION FORMAT (16-bit fixed):
 * +-----------+----------+----------+-----------+
 * |  OPCODE   |    Rd    |   RS1    | RS2 / IMM |
 * +-----------+----------+----------+-----------+
 *    [15:12]    [11:8]     [7:4]      [3:0]
 * 
 * SUPPORTED ISA:
 * - Arithmetic: ADD, SUB, ADDI
 * - Logic     : AND, OR, XOR, INV
 * - Shift     : SHL, SHR
 * - Data      : LDI, MOV
 * - Branch/Jump: JMP, BEQ, BNE, NOP
 * - Compare   : CMP (Sets flags without writeback)
 * 
 * DESIGN PHILOSOPHY:
 * - Modularity: Each stage (Fetch, Decode, Execute, Writeback) is encapsulated.
 * - Single-Cycle: All operations complete in one clock cycle; no pipelining or hazard stalls.
 * - Hardware Zero: R0 implementation follows classic RISC patterns.
 * =================================================================================================
 */

module nanocore16 (
    // Global signals
    input logic clk,
    input logic rstn,

    // Output signals
    output logic [7:0] seg0,
    output logic [7:0] seg1,
    output logic [7:0] seg2,
    output logic [7:0] seg3
);

  /* 
   * STEP 1: Internal Signal Declarations
   * Define intermediate logic for all module interconnections (pc_out, instr, signals).
   */
  logic [15:0] pc_out;  // Connects PC to Memory
  logic [15:0] instr;  // Holds the fetched instruction
  logic [15:0] branch_target;  // Next address on branch/jump
  logic        branch_en;  // Control signal for branch/jump
  logic [15:0] relative_target;

  // decoder outputs
  logic [3:0] opcode, rd_addr, rs1_addr, rs2_addr, alu_op;
  logic [7:0] imm;
  logic reg_wr_en, imm_sel;

  // Register file outputs
  logic [7:0] rs1_data, rs2_data;

  // Feedback/ALU results
  logic [7:0] alu_result;
  logic zero_flag, carry_flag;
  logic [7:0] operand_b;




  /* 
   * STEP 2: Instruction Fetch (IF) Logic
   * Instantiate 'program_counter' and 'instruction_mem'.
   * PC target selection for JMP/Branch happens here.
   */

  // Program counter
  program_counter u_pc (
      .clk          (clk),
      .rstn         (rstn),
      .pc_en        (1'b1),           // PC always set to 1 .
      .branch_en    (branch_en),
      .branch_target(branch_target),
      .pc_out       (pc_out)
  );


  // Instruction Memory
  instruction_mem u_ins_mem (
      .addr (pc_out),
      .instr(instr)
  );

  /* 
   * STEP 3: Instruction Decode (ID) Logic
   * Instantiate 'instruction_decoder' and 'register_file'.
   * Decouple field extraction from control signal logic.
   */

  // Instruction decoder  
  instruction_decoder u_inst_decoder (
      .instr(instr),
      .zero_flag(zero_flag),
      .opcode(opcode),
      .rd_addr(rd_addr),
      .rs1_addr(rs1_addr),
      .rs2_addr(rs2_addr),
      .imm(imm),
      .alu_op(alu_op),
      .reg_wr_en(reg_wr_en),
      .imm_sel(imm_sel),
      .branch_en(branch_en)
  );

  // Register file instantiation
  register_file u_reg_file (
      .clk(clk),
      .rstn(rstn),
      .wr_en(reg_wr_en),
      .rd_addr(rd_addr),
      .rs1_addr(rs1_addr),
      .rs2_addr(rs2_addr),
      .wr_data(alu_result),
      .rs1_data(rs1_data),
      .rs2_data(rs2_data)
  );
  /* 
   * STEP 4: Execution (EX) Logic
   * Instantiate 'alu'.
   * Implement Operand B mux (Register vs. Immediate).
   */

  // ALU integration.
  // operand_b MUX implementaiton, it selects between the operand_b from rs2_data or imm value
  assign operand_b = (imm_sel) ? imm : rs2_data;

  // ALU
  alu u_alu (
      .alu_op(alu_op),
      .operand_a(rs1_data),
      .operand_b(operand_b),
      .alu_result(alu_result),
      .zero_flag(zero_flag),
      .carry_flag(carry_flag)
  );


  /* 
   * STEP 5: Control flow and Writeback
   * Resolve branch/jump targets and connect ALU result to Register File write port.
   */
  assign relative_target = (pc_out + 16'h0001) + {{12{instr[3]}}, instr[3:0]};
  assign branch_target   = (opcode == 4'b1100) ? {8'h00, alu_result} : relative_target;
endmodule
