module cpu_IF(
    input clk, rst_n, stall, branch,
    input [15:0] pc_ID, pcBranch,
    output [15:0] pcNext, pcInc,
    output [15:0] instr
);


// Program Counter logic
/* PROGRAM COUNTER SIGNALS:
   [15:0] pcD = program counter value going into the PC register, assuming there is no branching
   [15:0] pc_ID = program counter value coming from the ID stage, used in case a stall signal is asserted
   [15:0] pcInc = program counter value that's incremented by 2, 
   [15:0] pc = program counter value strictly coming out of the PC register
   [15:0] pcNext = program counter value strictly going into the PC register, either pcD or pcBranch (if there is branching)

   NOTE: pcInc -> pc_ID is what gets used in subsequent stages, and pcD is what gets stored at the execution of the next instruction*/
    wire [15:0] pcD;
    wire halt;
    pc_logic pcCombinationalLogic(
        .pcIn(pc),
        .pcD(pcD),
        .stall(stall),
        .halt(halt),
        .pc_ID(pc_ID),
        .pcInc(pcInc)
    );
// Program Branch Logic
    assign pcNext = branch ? pcBranch : pcD; // If branch is true, use the branch address, otherwise use the incremented address

// Program Counter Register
    dff pcFlops [15:0] (
        .q(pc),
        .d(pcNext),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n)
    );

//Instruction Memory Accessing
/* [15:0] instr = instruction fetched from instruction memory based on program counter value
   [15:0] pc = program counter value coming out of the PC register
   data_in, wr, and enable are not used in this module. They are hard wired to constants.
*/
    inst_memory instruction_mem(
            .clk(clk),
            .rst(~rst_n),
            .addr(pc),
            .data_out(instr),
            .data_in(16'h0000),
            .wr(1'b0),
            .enable(1'b1)
        );

assign halt = &(instr[15:12]); // Halt instruction is 1111xxxx, so if the upper 4 bits are all 1s, halt is true

endmodule