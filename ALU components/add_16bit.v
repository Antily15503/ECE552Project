module add_16bit (
    input [15:0] A, B,
    input Cin,
    output [15:0] Sum,
    output Cout
);
//16bit ripple carry adder. NO SUBTRACTION

wire [3:0] coutInternal, cinInternal;
assign cinInternal[0] = Cin;
assign cinInternal[1] = coutInternal[0];
assign cinInternal[2] = coutInternal[1];
assign cinInternal[3] = coutInternal[2];
assign Cout = coutInternal[3];

add_4bit adders [3:0] (
    .A(A),
    .B(B),
    .Cin(cinInternal),
    .Sum(Sum),
    .Cout(coutInternal)
);

endmodule