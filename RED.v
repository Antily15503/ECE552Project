module RED(
    input [15:0] A, B, //Input data values
    output [15:0] Sum //Sum output
);

wire [15:0] SumLv1;
wire [7:0] SumLv2;

//first level of addition tree
wire [3:0] coutLv1;
add_4bit adder_lv1_1 (.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Sum(SumLv1[3:0]), .Cout(coutLv1[0]));
add_4bit adder_lv1_2 (.A(A[7:4]), .B(B[7:4]), .Cin(1'b0), .Sum(SumLv1[7:4]), .Cout(coutLv1[1]));
add_4bit adder_lv1_3 (.A(A[11:8]), .B(B[11:8]), .Cin(1'b0), .Sum(SumLv1[11:8]), .Cout(coutLv1[2]));
add_4bit adder_lv1_4 (.A(A[15:12]), .B(B[15:12]), .Cin(1'b0), .Sum(SumLv1[15:12]), .Cout(coutLv1[3]));

//second level of addition tree
wire [4:0] AE, BF, CG, DH;
wire [7:0] sumAEBF, sumCGDH;

assign AE = {coutLv1[0], SumLv1[3:0]};
assign BF = {coutLv1[1], SumLv1[7:4]};
assign CG = {coutLv1[2], SumLv1[11:8]};
assign DH = {coutLv1[3], SumLv1[15:12]};

add_8bit adder_lv2_1 (.A({{3{AE[4]}}, AE}), .B({{3{BF[4]}}, BF}), .Cin(1'b0), .Sum(sumAEBF), .Cout());
add_8bit adder_lv2_2 (.A({{3{CG[4]}}, CG}), .B({{3{DH[4]}}, DH}), .Cin(1'b0), .Sum(sumCGDH), .Cout());

//final level of addition tree
wire [5:0] AEBF, CGDH;

assign AEBF = {sumAEBF[5:0]};
assign CGDH = {sumCGDH[5:0]};

add_8bit adder_lv3 (.A({{2{AEBF[5]}}, AEBF}), .B({{2{CGDH[5]}}, CGDH}), .Cin(1'b0), .Sum(SumLv2), .Cout());

assign Sum = {{8{SumLv2[7]}}, SumLv2};

endmodule
