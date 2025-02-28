module addsub_4bit (
    input  [3:0] a,       // 4-bit input A
    input  [3:0] b,       // 4-bit input B
    input  is_sub,        // 1 = subtract
    output [3:0] sum,     // 4-bit sum
    output ovfl           // Overflow indicator
);

    wire [3:0] b_xor;
    wire [3:0] cout;

    assign b_xor = b ^ {4{is_sub}};  // Two's complement: XOR with is_sub
    full_adder_1bit fa0 (.a(a[0]), .b(b_xor[0]), .cin(is_sub),   .sum(sum[0]), .cout(cout[0]));
    full_adder_1bit fa1 (.a(a[1]), .b(b_xor[1]), .cin(cout[0]), .sum(sum[1]), .cout(cout[1]));
    full_adder_1bit fa2 (.a(a[2]), .b(b_xor[2]), .cin(cout[1]), .sum(sum[2]), .cout(cout[2]));
    full_adder_1bit fa3 (.a(a[3]), .b(b_xor[3]), .cin(cout[2]), .sum(sum[3]), .cout(cout[3]));

    // Overflow detection: when carry in and carry out of MSB differ
    assign ovfl = cout[2] ^ cout[3];

endmodule
