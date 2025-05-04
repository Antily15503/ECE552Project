`default_nettype none
module cpu_IF(
    //Inputs ================================================
    input wire clk, rst_n, //Clock and reset signals
    input wire stall, //Stall is used to hold the pc, asserted if instr = HALT
    input wire pc_stall,
    input wire data_stall, 
    input wire branch, //branch is used to determine if we need to branch to a different address. Comes from ID stage
    input wire [15:0] pc_ID, pcBranch, instr_ID, //pc_ID is the program counter value coming from the ID stage, pcBranch is the branch target address (if we take a branch), and instr_ID is the instruction from the ID stage.
    input wire [15:0] instr_I_cache,
    //Outputs ================================================
    output wire [15:0] pc, pcInc, //Program counter value coming out of the PC register and the incremented program counter value (pc + 2)
    output wire [15:0] instr, //Instruction fetched from instruction memory based on program counter value
    output wire halt //Halt signal, which is true if the instruction is a halt instruction (0xFxxx)
);


/* PROGRAM COUNTER SIGNALS:
   [15:0] pc = program counter value strictly coming out of the PC register
   [15:0] pcD = program counter value going into the PC register, assuming there is no branching
   [15:0] pc_ID = program counter value coming from the ID stage, used in case a stall signal is asserted
   [15:0] pcInc = program counter value that's incremented by 2, 
   [15:0] pcNext = program counter value strictly going into the PC register, either pcD or pcBranch (if there is branching)

   NOTE: pcInc -> pc_ID is what gets used in subsequent stages, and pcD is what gets stored at the execution of the next instruction*/
    wire [15:0] pcD, pcNext;
    // wire halt;
    pc_logic pcCombinationalLogic(
        .pcIn(pc),
        .pcD(pcD),
        .stall(stall),
        .pc_stall(pc_stall),
        .data_stall(data_stall),
        .halt(halt),
        .pc_ID(pc_ID),
        .pcInc(pcInc)
    );
// Program Branch Logic
    assign pcNext = (branch & ~pc_stall) ? pcBranch : pcD; // If branch is true, use the branch address, otherwise use the incremented address

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
//wire [15:0] instrRaw; // replaced with insturction data_out from I cache
    
    // inst_memory instruction_mem(
    //         .clk(clk),
    //         .rst(~rst_n),
    //         .addr(pc),
    //         .data_out(instrRaw),
    //         .data_in(16'h0000),
    //         .wr(1'b0),
    //         .enable(1'b1)
    //     );

wire [15:0] pre_instr;
/* If stall is true, assign instruction to the instruction from the ID stage (instr_ID)
//if branch is true, assign it to a NOP instruction (0xA000), otherwise use the instruction fetched from memory*/
assign pre_instr = ( data_stall) ? (instr_ID) : (branch ? 16'hA000 : (pc_stall ? 16'hA000 : instr_I_cache));
assign instr = stall ? instr_ID : pre_instr;

assign halt = &(instr[15:12]); // Halt instruction is 1111xxxx, so if the upper 4 bits are all 1s, halt is true

endmodule 
`default_nettype wire