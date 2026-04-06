module register_file #(
    parameter MEM_DEPTH  = 16,
    parameter DATA_WIDTH = 8
) (
    input logic clk,
    input logic rstn,
    input logic wr_en,
    input logic [3:0] rd_addr,
    input logic [3:0] rs1_addr,
    input logic [3:0] rs2_addr,
    input logic [7:0] wr_data,
    output logic [7:0] rs1_data,
    output logic [7:0] rs2_data
);

  // Register declaration
  logic [DATA_WIDTH-1:0] reg_array[0:MEM_DEPTH-1];

  // Read logic 
  always_comb begin : RegRead
    rs1_data = (rs1_addr == 4'h0) ? 8'h00 : reg_array[rs1_addr];
    rs2_data = (rs2_addr == 4'h0) ? 8'h00 : reg_array[rs2_addr];
  end


  // Write logic
  always_ff @(posedge clk or negedge rstn) begin
    if (~rstn) begin
      for (int i = 0; i <= MEM_DEPTH - 1; i++) begin
        reg_array[i] <= {DATA_WIDTH{1'b0}};
      end
    end else begin
      if (wr_en && rd_addr != 4'b0000) begin
        reg_array[rd_addr] <= wr_data;
      end
    end
  end



endmodule
