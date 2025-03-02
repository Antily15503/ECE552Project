module add_8bit (
    input [7:0] A, B,
    input Cin,
    output [7:0] Sum,
    output Cout
);
//8bit ripple carry adder. NO SUBTRACTION

wire internalCarry;


add_4bit lower(
    .A(A[3:0]),
    .B(B[3:0]),
    .Cin(Cin),
    .Sum(Sum[3:0]),
    .Cout(internalCarry)
);

add_4bit upper(
    .A(A[7:4]),
    .B(B[7:4]),
    .Cin(internalCarry),
    .Sum(Sum[7:4]),
    .Cout(Cout)
);

endmodule