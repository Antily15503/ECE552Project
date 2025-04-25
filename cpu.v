`default_nettype none
module cpu(
    input clk, rst_n, // clock and reset signals
    output hlt, // halt signal
    output [15:0] pc, // program counter
)
wire [15:0] pc; // program counter
wire hlt; // halt signal

//instantiate the central processor
processor processor(
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc),
    .hlt(hlt)
);

//instantiate the instruction cache 


endmodule
`default_nettype wire