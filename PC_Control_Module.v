
// PC Control Module
module pc_control(
    input [2:0] c,        // 3-bit condition code (ccc)
    input [8:0] i,        // 9-bit signed immediate offset
    input [2:0] f,        // Flags (F = {N, V, Z})
    input [15:0] pc_in,   // Current PC value
    output [15:0] pc_out  // Next PC value
);
    // Flags
    wire N = f[2]; // Sign Bit flag
    wire V = f[1]; // Overflow flag
    wire Z = f[0]; // Zero flag

    // Sign-extend and shift offset
    wire [15:0] offset = { {7{i[8]}}, i } << 1; // Sign-extend + left-shift by 1

    // Condition evaluation
    wire condition = 
        ((c == 3'b000) & (Z == 0)) ? 1'b1 :                // Not Equal (Z=0)
        ((c == 3'b001) & (Z == 1)) ? 1'b1 :                // Equal (Z=1)
        ((c == 3'b010) & (Z == 0) & (N == 0)) ? 1'b1 :     // Greater Than (Z=N=0)
        ((c == 3'b011) & (N == 1)) ? 1'b1 :                // Less Than (N=1)
        ((c == 3'b100) & ((Z == 1) | ((Z == 0) & (N == 0)))) ? 1'b1 :  // GTE
        ((c == 3'b101) & ((N == 1) | (Z == 1))) ? 1'b1 :   // LTE
        ((c == 3'b110) & (V == 1)) ? 1'b1 :                // Overflow (V=1)
        (c == 3'b111) ? 1'b1 :                             // Unconditional
        1'b0;

    // Compute PC + 2 and branch target
    wire [15:0] pc_next, pc_branch;
    adder adder1 (.a(pc_in), .b(16'h2), .sum(pc_next));    // PC + 2
    adder adder2 (.a(pc_next), .b(offset), .sum(pc_branch)); // PC + 2 + offset

    // Select PC based on condition
    assign pc_out = condition ? pc_branch : pc_next;

endmodule