`define ADD 4'b0000
`define SUB 4'b0001
`define ADDI 4'b0010
`define AND 4'b0011
`define OR 4'b0100
`define XOR 4'b0101
`define INV 4'b0110
`define SHL 4'b0111
`define SHR 4'b1000
`define LDI 4'b1001 
`define MOV 4'b1010 
`define CMP 4'b1011 
`define JMP 4'b1100 
`define BEQ 4'b1101 
`define BNE 4'b1110 
`define NOP 4'b1111



module instruction_decoder (
    input logic [15:0] instr,
    input logic zero_flag,
    output logic [3:0] opcode,
    output logic [3:0] rd_addr,
    output logic [3:0] rs1_addr,
    output logic [3:0] rs2_addr,
    output logic [7:0] imm,
    output logic [3:0] alu_op,
    output logic reg_wr_en,
    output logic imm_sel,
    output logic branch_en
);

  // Assignment for outputs 
  assign opcode = instr[15:12];
  assign rd_addr = instr[11:8];
  assign rs1_addr = instr[7:4];
  assign rs2_addr = instr[3:0];

  // Sign extension for 4-bit immediate (to 8-bit datapath)
  assign imm = {{4{instr[3]}}, instr[3:0]};


  always_comb begin : instruction_decoder_opcode
    // Default assignments to prevent latches and maintain clarity
    reg_wr_en = 1'b0;
    imm_sel   = 1'b0;
    branch_en = 1'b0;
    alu_op    = 4'b0000;

    case (opcode)
      `ADD: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b0;
        alu_op    = 4'b0000;
      end
      `SUB: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b0;
        alu_op    = 4'b0001;
      end
      `ADDI: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b1;
        alu_op    = 4'b0000; // ALU performs ADD with imm
      end
      `AND: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b0;
        alu_op    = 4'b0011;
      end
      `OR: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b0;
        alu_op    = 4'b0100;
      end
      `XOR: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b0;
        alu_op    = 4'b0101;
      end
      `INV: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b0;
        alu_op    = 4'b0110;
      end
      `SHL: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b1;
        alu_op    = 4'b0111;
      end
      `SHR: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b1;
        alu_op    = 4'b1000;
      end
      `LDI: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b1;
        alu_op    = 4'b1001; // PASS_B in ALU
      end
      `MOV: begin
        reg_wr_en = 1'b1;
        imm_sel   = 1'b0;
        alu_op    = 4'b1010; // PASS_A in ALU
      end
      `CMP: begin
        reg_wr_en = 1'b0; // No writeback
        imm_sel   = 1'b0;
        alu_op    = 4'b0001; // ALU performs SUB
      end
      `JMP: begin
        reg_wr_en = 1'b0;
        imm_sel   = 1'b1;
        branch_en = 1'b1;
        alu_op    = 4'b0000; // PC <- RS1 + IMM
      end
      `BEQ: begin
        reg_wr_en = 1'b0;
        if (zero_flag) branch_en = 1'b1;
      end
      `BNE: begin
        reg_wr_en = 1'b0;
        if (!zero_flag) branch_en = 1'b1;
      end
      `NOP: begin
        // Defaults handle NOP (no write, no branch)
      end
      default: begin
        // Default behavior matches NOP
      end
    endcase
  end

endmodule
