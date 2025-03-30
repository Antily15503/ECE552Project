// Parallel Subword Adder

module psa_16bit (
    input  wire [15:0] a,
    input  wire [15:0] b,
    output wire [15:0] sum,
    output wire error
);

// 4-bit signed addition using bitwise operations
wire [3:0] sum0, sum1, sum2, sum3;
wire ovfl0, ovfl1, ovfl2, ovfl3;

addsub_4bit iAdder0 (.A(a[15:12]), .B(b[15:12]), .Sum(sum[15:12]), .Cout(ovfl3), .sub(1'b0));
addsub_4bit iAdder1 (.A(a[11:8]),  .B(b[11:8]),  .Sum(sum[11:8]),  .Cout(ovfl2), .sub(1'b0));
addsub_4bit iAdder2 (.A(a[7:4]),   .B(b[7:4]),   .Sum(sum[7:4]),   .Cout(ovfl1), .sub(1'b0));
addsub_4bit iAdder3 (.A(a[3:0]),   .B(b[3:0]),   .Sum(sum[3:0]),   .Cout(ovfl0), .sub(1'b0));

// Detect any overflow
assign error = ovfl0 | ovfl1 | ovfl2 | ovfl3;

endmodule
