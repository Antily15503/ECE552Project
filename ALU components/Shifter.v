module Shifter(
    input [15:0] Shift_In,
    input [3:0] Shift_val,
    input [1:0] Mode, //depends on bits [1:0] of opcode: SLL = 00, SRA = 01, ROR = 10
    output [15:0] Shift_Out
);
//an implementation for a shifter, takes advantage of tertiary conditionals and verilog concatenation

wire [15:0] shift_a, shift_b, shift_c, shift_d;

//essentially built from three nested terniary statements, implementing both shift bitchecking, Arithmetic shifting, and etc.
assign shift_a = Shift_val[3] ? (
        Mode == 2'b01 ? {{8{Shift_In[15]}}, Shift_In[15:8]}:    // SRA by 8
        Mode == 2'b00 ? {Shift_In[7:0], 8'h00}:                 // SLL by 8
        {Shift_In[7:0], Shift_In[15:8]}) :                      // ROR by 8
    Shift_In;                                                   // No shift

assign shift_b = Shift_val[2] ? (
        Mode == 2'b01 ? {{4{shift_a[15]}}, shift_a[15:4]}:      // SRA by 4
        Mode == 2'b00 ? {shift_a[11:0], 4'b0000}:               // SLL by 4
        {shift_a[3:0], shift_a[15:4]}) :                        // ROR by 4
    shift_a;                                                    // No shift

assign shift_c = Shift_val[1] ? (
        Mode == 2'b01 ? {{2{shift_b[15]}}, shift_b[15:2]}:      // SRA by 2
        Mode == 2'b00 ? {shift_b[13:0], 2'b00}:                 // SLL by 2
        {shift_b[1:0], shift_b[15:2]}) :                        // ROR by 2                        
    shift_b;                                                    // No shift

assign Shift_Out = Shift_val[0] ? (
        Mode == 2'b01 ? {shift_c[15], shift_c[15:1]}:           // SRA by 1
        Mode == 2'b00 ? {shift_c[14:0], 1'b0}:                  // SLL by 1
        {shift_c[0], shift_c[15:1]}) :                          // ROR by 1
    shift_c;                                                    // No shift

endmodule