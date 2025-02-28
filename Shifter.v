module Shifter(
    input [15:0] Shift_In,
    input [3:0] Shift_val,
    input Mode,
    output [15:0] Shift_Out
);
//an implementation for a shifter, takes advantage of tertiary conditionals and verilog concatenation

wire [15:0] shift_a, shift_b, shift_c, shift_d;

//essentially built from three nested terniary statements, implementing both shift bitchecking, Arithmetic shifting, and etc.
assign shift_a = Shift_val[3] ? (
    Mode ? (
        {{8{Shift_In[15]}}, Shift_In[15:8]}
        ) : {Shift_In[7:0], 8'h00}
) : Shift_In;

assign shift_b = Shift_val[2] ? (
    Mode ? (
        {{4{shift_a[15]}}, shift_a[15:4]}
    ) : {shift_a[11:0], 4'b0000}
) : shift_a;

assign shift_c = Shift_val[1] ? (
    Mode ? (
        {{2{shift_b[15]}}, shift_b[15:2]}
    ) : {shift_b[13:0], 2'b00}
) : shift_b;

assign Shift_Out = Shift_val[0] ? (
    Mode ? {
        {shift_c[15], shift_c[15:1]}
    } : {shift_c[14:0], 1'b0}
) : shift_c;

endmodule