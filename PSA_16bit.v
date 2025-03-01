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

addsub_4bit iAdder0 (.a(a[15:12]), .b(b[15:12]), .sum(sum[15:12]), .ovfl(ovfl3));
addsub_4bit iAdder1 (.a(a[11:8]),  .b(b[11:8]),  .sum(sum[11:8]),  .ovfl(ovfl2));
addsub_4bit iAdder2 (.a(a[7:4]),   .b(b[7:4]),   .sum(sum[7:4]),   .ovfl(ovfl1));
addsub_4bit iAdder3 (.a(a[3:0]),   .b(b[3:0]),   .sum(sum[3:0]),   .ovfl(ovfl0));

// Detect any overflow
assign error = ovfl0 | ovfl1 | ovfl2 | ovfl3;

endmodule
