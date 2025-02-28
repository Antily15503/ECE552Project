module RED(
    input [15:0] A, B, //Input data values
    output [15:0] Sum //Sum output
);

wire [15:0] SumRaw;

//first level of addition tree
wire [3:0] cout;
add_4bit adder1 (.A(A[3:0]), .B(B[3:0]), .cin(1'b0), .Sum(SumRaw[3:0]), .Cout(cout[0]));
add_4bit adder2 (.A(A[7:4]), .B(B[7:4]), .cin(1'b0), .Sum(SumRaw[7:4]), .Cout(cout[1]));
add_4bit adder3 (.A(A[11:8]), .B(B[11:8]), .cin(1'b0), .Sum(SumRaw[11:8]), .Cout(cout[2]));
add_4bit adder4 (.A(A[15:12]), .B(B[15:12]), .cin(1'b0), .Sum(SumRaw[15:12]), .Cout(cout[3]));

//adding carry bits
add_4bit adderCarry1 (.A({3'b0, cout[0]}), .B(), .cin(1'b0), .Sum(SumRaw), .Cout(cout[4]));

//second level of addition tree
wire [4:0] sumAEBF, sumCGDH;
wire [1:0] cout2;

add_4bit adder5 (.A(SumRaw[3:0]), .B(SumRaw[7:4]), .cin(cout[3]), .Sum(sumAEBF), .Cout(cout2[0]));
add_4bit adder6 (.A(SumRaw[11:8]), .B(SumRaw[15:12]), .cin(cout2[0]), .Sum(sumCGDH), .Cout(cout2[1]));

//final level of addition tree
add_4bit adder7 (.A(sumAEBF), .B(sumCGDH), .cin(cout2[1]), .Sum(Sum), .Cout(cout[4]));

//adding carry bits
add_4bit adder8 (.A(cout2[1]), 

adds



endmodule