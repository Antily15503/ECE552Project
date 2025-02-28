`include "cla_4bit.v"

// paddsub module declaration
module paddsub (
    input [15:0] a,
    input [15:0] b,
    output[15:0]sum
);

wire [3:0] ovfl; // overflow flag for each 4-bit cla
wire [3:0] sum_part[0:3]; //sum parts for each 4-bit cla

cla_4bit cla0(
.a(a[3:0]),
.b(b[3:0]),
.sum(sum_part[0]),
.ovfl(ovfl[0]),
.is_sub(1'b0)
);

cla_4bit cla1(
.a(a[7:4]),
.b(b[7:4]),
.sum(sum_part[1]),
.ovfl(ovfl[1]),
.is_sub(1'b0)
);

cla_4bit cla2(
.a(a[11:8]),
.b(b[11:8]),
.sum(sum_part[2]),
.ovfl(ovfl[2]),
.is_sub(1'b0)
);

cla_4bit cla3(
.a(a[15:12]),
.b(b[15:12]),
.sum(sum_part[3]),
.ovfl(ovfl[3]),
.is_sub(1'b0)
);

//saturating values in case of overflow
assign sum[3:0] = (ovfl[0])?((a[3] == 0)?(4'b0111):(4'b1000)):sum_part[0];
assign sum[7:4] = (ovfl[1])?((a[7] == 0)?(4'b0111):(4'b1000)):sum_part[1];
assign sum[11:8] = (ovfl[2])?((a[11] == 0)?(4'b0111):(4'b1000)):sum_part[2];
assign sum[15:12] = (ovfl[3])?((a[15] == 0)?(4'b0111):(4'b1000)):sum_part[3];

endmodule
