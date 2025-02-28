module cpu(
    input clk, rst_n,
    output [15:0] pc,
    output hlt
);

// Program Counter signals
wire [15:0] pcD;

dff pcFlops [15:0] (
    .q(pc),
    .d(pcD),
    .wen(1'b1),
    .clk(clk),
    .rst(rst_n)
);

// Program Counter incrementer
add_4bit pcInc (
    .A(pc),
    .B(4'b0100),
    .cin(1'b0),
    .Sum(pcD),
    .Cout()
);

inst_memory(
    .data_out()
    
)

endmodule