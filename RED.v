module RED(
    input [15:0] A, B, //Input data values
    output [15:0] Sum //Sum output
);

wire [15:0] SumLv1;
wire [15:0] SumLv2;

//first level of addition tree
wire [3:0] coutLv1;
add_4bit adder_lv1_1 (.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Sum(SumLv1[3:0]), .Cout(coutLv1[0]));
add_4bit adder_lv1_2 (.A(A[7:4]), .B(B[7:4]), .Cin(1'b0), .Sum(SumLv1[7:4]), .Cout(coutLv1[1]));
add_4bit adder_lv1_3 (.A(A[11:8]), .B(B[11:8]), .Cin(1'b0), .Sum(SumLv1[11:8]), .Cout(coutLv1[2]));
add_4bit adder_lv1_4 (.A(A[15:12]), .B(B[15:12]), .Cin(1'b0), .Sum(SumLv1[15:12]), .Cout(coutLv1[3]));

//second level of addition tree
wire [4:0] sumAE, sumBF, sumCG, sumDH;

assign sumAE = {coutLv1[0], SumLv1[3:0]};
assign sumBF = {coutLv1[1], SumLv1[7:4]};
assign sumCG = {coutLv1[2], SumLv1[11:8]};
assign sumDH = {coutLv1[3], SumLv1[15:12]};

wire[1:0] coutLv2;

add_8bit adder_lv2_1 (.A({3'b000, sumAE}), .B({3'b000, sumBF}), .Cin(1'b0), .Sum(SumLv2[7:0]), .Cout(coutLv2[0]));
add_8bit adder_lv2_2 (.A({3'b000, sumCG}), .B({3'b000, sumDH}), .Cin(1'b0), .Sum(SumLv2[15:8]), .Cout(coutLv2[1]));

//final level of addition tree
wire [7:0] SumAEBF, SumCGDH;

assign SumAEBF = {coutLv2[0],SumLv2[7:0]};
assign SumCGDH = {coutLv2[1],SumLv2[15:8]};

wire [7:0] SumRaw;
wire coutLv3;
add_8bit adder_lv3 (.A(SumAEBF), .B(SumCGDH), .Cin(1'b0), .Sum(SumRaw), .Cout(coutLv3));
assign Sum = {coutLv3, SumRaw};

endmodule
