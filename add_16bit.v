module add_16bit (
    input [15:0] A, B,
    input cin,
    output [15:0] sum,
    output cout
);
//16bit ripple carry adder. NO SUBTRACTION

wire [3:0] coutInternal, cinInternal;
assign cinInternal[0] = cin;
assign cinInternal[1] = coutInternal[0];
assign cinInternal[2] = coutInternal[1];
assign cinInternal[3] = coutInternal[2];
assign cout = coutInternal[3];

add_4bit adders [4:0] (
    .A(A),
    .B(B),
    .cin(cinInternal),
    .Sum(sum),
    .Cout(coutInternal)
);

endmodule