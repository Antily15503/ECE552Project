`default_nettype none
module psm_cache(
    input [5:0] shift_val,
    output [63:0]shift_out
);

assign shift = 64'h0000000000000001; // Default value for shift
wire [63:0] shift_a, shift_b, shift_c, shift_d, shift_e;

assign shift_a = shift_val[5] ? ({shift[31:0], 32'h00000000}) : shift; // SLL by 32
assign shift_b = shift_val[4] ? ({shift_a[47:0], 16'h0000}) : shift_a; // SLL by 16
assign shift_c = shift_val[3] ? ({shift_b[55:0], 8'h00}) : shift_b; // SLL by 8
assign shift_d = shift_val[2] ? ({shift_c[59:0], 4'h0}) : shift_c; // SLL by 4
assign shift_e = shift_val[1] ? ({shift_d[61:0], 2'b00}) : shift_d; // SLL by 2
assign shift_out = shift_val[0] ? ({shift_e[62:0], 1'b0}) : shift_e; // SLL by 1

endmodule
`default_nettype wire