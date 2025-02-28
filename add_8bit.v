module add_8bit (
    input [7:0] A, B,
    input cin,
    output [7:0] sum,
    output cout
);
//8bit ripple carry adder. NO SUBTRACTION

wire [1:0] coutInternal, cinInternal;
assign cinInternal[0] = cin;
assign cinInternal[1] = coutInternal[0];
assign cout = coutInternal[1];

add_4bit adders [4:0] (
    .A(A),
    .B(B),
    .cin(cinInternal),
    .Sum(sum),
    .Cout(coutInternal)
);

endmodule