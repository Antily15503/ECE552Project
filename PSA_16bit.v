module PSA_16bit (
    input [15:0] A, B, //Input data values
    output [15:0] Sum //Sum output
);

addsub_4bit PSA[3:0] (.A(A), .B(B), .sub(4'b0), .Sum(Sum));


endmodule