module cpu_IF(
    input clk, rst_n,
    input [15:0] pcD,
    output [15:0] pc,
    output [15:0] instr
);

// Program Counter signals
/* [15:0] pcD = program counter value coming into the PC register
   [15:0] pc = program counter value coming out of the PC register
   NOTE: pcD is determined by branch logic in cpu_ID.v. Instruction Fetch Stage does not modify either signals.*/
    dff pcFlops [15:0] (
        .q(pc),
        .d(pcD),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n)
    );

//Instruction Memory Accessing
/* [15:0] instr = instruction fetched from instruction memory based on program counter value
   [15:0] pc = program counter value coming out of the PC register
   data_in, wr, and enable are not used in this module. They are hard wired to constants.
*/
    wire [15:0] instr;
    inst_memory instruction_mem(
            .clk(clk),
            .rst(~rst_n),
            .addr(pc),
            .data_out(instr),
            .data_in(16'h0000),
            .wr(1'b0),
            .enable(1'b1)
        );

endmodule