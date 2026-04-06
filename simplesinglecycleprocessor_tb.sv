`timescale 1ns / 1ps

module simplesinglecycleprocessor_tb;

  // Signals
  logic clk;
  logic rstn;
  logic [7:0] seg0, seg1, seg2, seg3;

  // Instantiate Top-Level Processor
  simplesinglecycleprocessor dut (
      .clk (clk),
      .rstn(rstn),
      .seg0(seg0),
      .seg1(seg1),
      .seg2(seg2),
      .seg3(seg3)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 100MHz clock
  end

  // Test Procedure
  initial begin
    $display("--------------------------------------------------");
    $display("Starting SimpleProc Processor Simulation...");
    $display("--------------------------------------------------");

    // Setup Waveform dump
    $dumpfile("processor_sim.vcd");
    $dumpvars(0, simplesinglecycleprocessor_tb);

    // Reset
    rstn = 0;
    #20;
    rstn = 1;

    // Monitor Register Writes
    $display("Time | PC     | Instruction | Rd | Result | Zero");
    $display("--------------------------------------------------");

    // Run for 100 cycles or until end of program
    begin : test_loop
      bit done = 0;
      for (int i = 0; i < 100 && !done; i++) begin
        @(posedge clk);
        #1;  // Wait for logic to settle
        $display("%4t | %h | %h        | R%0d | %h     | %b", $time, dut.pc_out, dut.instr,
                 dut.rd_addr, dut.alu_result, dut.zero_flag);

        // Check for NOP at high memory or specific exit condition
        if (dut.instr == 16'hF000 && dut.pc_out > 16'h0010) begin
          $display("--------------------------------------------------");
          $display("Program termination detected (NOP).");
          done = 1;
        end
      end
    end

    $display("--------------------------------------------------");
    $display("Simulation Final Register State:");
    for (int j = 0; j < 16; j++) begin
      $display("R%0d: %h", j, dut.u_reg_file.reg_array[j]);
    end
    $display("--------------------------------------------------");

    $finish;
  end

endmodule
