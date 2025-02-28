module RED(
    input [15:0] A, B, //Input data values
    output [15:0] Sum //Sum output
);

wire [15:0] SumLv1;

//first level of addition tree
wire [3:0] coutLv1;
add_4bit adder_lv1_1 (.A(A[3:0]), .B(B[3:0]), .cin(1'b0), .Sum(SumLv1[3:0]), .coutLv1(coutLv1[0]));
add_4bit adder_lv1_2 (.A(A[7:4]), .B(B[7:4]), .cin(1'b0), .Sum(SumLv1[7:4]), .coutLv1(coutLv1[1]));
add_4bit adder_lv1_3 (.A(A[11:8]), .B(B[11:8]), .cin(1'b0), .Sum(SumLv1[11:8]), .coutLv1(coutLv1[2]));
add_4bit adder_lv1_4 (.A(A[15:12]), .B(B[15:12]), .cin(1'b0), .Sum(SumLv1[15:12]), .coutLv1(coutLv1[3]));

//second level of addition tree
wire [4:0] sumAE, sumBF, sumCG, sumDH;
wire [7:0] SumAEBF, SumCGDH;
assign sumAE = {coutLv1[0], SumLv1[3:0]};
assign sumBF = {coutLv1[1], SumLv1[7:4]};
assign sumCG = {coutLv1[2], SumLv1[11:8]};
assign sumDH = {coutLv1[3], SumLv1[15:12]};

add_8bit adder_lv2_1 (.A({3'b000, sumAE}), .B({3'b000, sumBF}), .cin(1'b0), .Sum(SumAEBF), .coutLv1());
add_8bit adder_lv2_2 (.A({3'b000, sumCG}), .B({3'b000, sumDH}), .cin(1'b0), .Sum(SumCGDH), .coutLv1());

//final level of addition tree

wire [7:0] SumRaw;

add_8bit adder_lv3 (.A(SumAEBF), .B(SumCGDH), .cin(1'b0), .Sum(SumRaw), .coutLv1());
assign Sum = {8'h00, SumRaw};

endmodule