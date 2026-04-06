module program_counter (
    // Global signals
    input  logic        clk,
    input  logic        rstn,       // Active-low asynchronous reset

    // Control signals
    input  logic        pc_en,      // PC enable (hold PC when deasserted)
    input  logic        branch_en,  // Branch enable (load branch target)
    input  logic [15:0] branch_target, // Branch/jump target address

    // Output
    output logic [15:0] pc_out      // Current program counter value
);

    // Internal next-PC logic
    logic [15:0] pc_next;

    // Next PC: branch target if branching, otherwise PC + 1
    assign pc_next = branch_en ? branch_target : (pc_out + 16'h0001);

    // Sequential PC register with async active-low reset
    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn)
            pc_out <= 16'h0000;
        else if (pc_en)
            pc_out <= pc_next;
    end

endmodule