module instruction_mem #(
    parameter MEM_DEPTH = 256
) (
    input  logic [15:0] addr,
    output logic [15:0] instr
);

  // memory declaration
  logic [15:0] mem[0:MEM_DEPTH-1];

  // initialize the memory
  initial begin
    $readmempath(".");
    $readmemh("/home/praba/Projects/NanoCore16/src/rtl/inst_mem.hex", mem);
  end

  // Read the memory data
  assign instr = mem[addr[7:0]];



endmodule
