`define ADD 4'b0000
`define SUB 4'b0001
`define AND 4'b0011
`define OR 4'b0100
`define XOR 4'b0101
`define INV 4'b0110
`define SHL 4'b0111
`define SHR 4'b1000
`define LDI 4'b1001
`define MOV 4'b1010

// Module starts here

module alu (
    input  logic [3:0] alu_op,      // ALU Operations
    input  logic [7:0] operand_a,   // First operand - RS1
    input  logic [7:0] operand_b,   // Second operand - RS2 or sign ext imm
    output logic [7:0] alu_result,  // Computation result
    output logic       zero_flag,   // Zero flag 1 if result == 0
    output logic       carry_flag
);

  logic [7:0] r_result;

  assign alu_result = r_result;
  assign zero_flag  = (r_result == 8'h00) ? 1 : 0;

  always_comb begin
    r_result   = 8'h00;
    carry_flag = 1'b0;
    case (alu_op)
      `ADD: {carry_flag, r_result} = operand_a + operand_b;
      `SUB: {carry_flag, r_result} = operand_a - operand_b;
      `AND: r_result = operand_a & operand_b;
      `OR:  r_result = operand_a | operand_b;
      `XOR: r_result = operand_a ^ operand_b;
      `INV: r_result = ~operand_a;
      `SHL: r_result = operand_a << operand_b[2:0];
      `SHR: r_result = operand_a >> operand_b[2:0];
      `LDI: r_result = operand_b;
      `MOV: r_result = operand_a;
      default: begin
        r_result   = 8'h00;
        carry_flag = 1'b0;
      end
    endcase
  end


endmodule
