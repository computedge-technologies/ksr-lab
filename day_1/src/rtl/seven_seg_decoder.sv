module seven_seg_decoder (
    input  logic [3:0] bin_in,  // 4-bit binary input
    output logic [7:0] seg_out  // 8-bit segment output (g-f-e-d-c-b-a-dp)
);

  always_comb begin
    case (bin_in)
      4'h0: seg_out = 8'b0011_1111;  // 0
      4'h1: seg_out = 8'b0000_0110;  // 1
      4'h2: seg_out = 8'b0101_1011;  // 2
      4'h3: seg_out = 8'b0100_1111;  // 3
      4'h4: seg_out = 8'b0110_0110;  // 4
      4'h5: seg_out = 8'b0110_1101;  // 5
      4'h6: seg_out = 8'b0111_1101;  // 6
      4'h7: seg_out = 8'b0000_0111;  // 7
      4'h8: seg_out = 8'b0111_1111;  // 8
      4'h9: seg_out = 8'b0110_1111;  // 9
      4'hA: seg_out = 8'b0111_0111;  // A
      4'hB: seg_out = 8'b0111_1100;  // b
      4'hC: seg_out = 8'b0011_1001;  // C
      4'hD: seg_out = 8'b0101_1110;  // d
      4'hE: seg_out = 8'b0111_1001;  // E
      4'hF: seg_out = 8'b0111_0001;  // F
      default: seg_out = 8'b0000_0000;
    endcase
  end

endmodule
