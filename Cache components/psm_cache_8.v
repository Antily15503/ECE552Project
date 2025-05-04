`default_nettype none
module psm_cache_8(
    input wire [2:0] shift_val,
    output wire [7:0]shift_out
);
wire [7:0] shift;
assign shift = 8'h01; // Default value for shift
wire [7:0] shift_a, shift_b;

assign shift_a = shift_val[2] ? ({shift[3:0], 4'h0}) : shift; // SLL by 4
assign shift_b = shift_val[1] ? ({shift_a[5:0], 2'b00}) : shift_a; // SLL by 2
assign shift_out = shift_val[0] ? ({shift_b[6:0], 1'b0}) : shift_b; // SLL by 1

endmodule
`default_nettype wire