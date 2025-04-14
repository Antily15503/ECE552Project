`default_nettype none
/**
* This is the branch module for the 16-bit processor. It calculates the branch address based on the 
* current program counter (pcIn), instruction immediate value (I), and determines if the branch should be taken
* based on the condition code and flags. The module also includes a multiplexer to determine branch whether the
* instruction is B or BR
*
* Inputs:
* - [2:0]  condition: specifies the branch condition (e.g., equal, not equal, etc.)
* - [2:0]  Flags:status flags {zero, overflow, neg}
* - [8:0]  I: immediate value from the instruction, NOT sign extended.
* - [15:0] pcIn: current program counter value associated with the current instruction (branch or non-branching)
* - [15:0] branchRegData: data from the register file for relative branching (only used in BR instructions)
* -        branchRegMux: control signal to select between calculated branch address (B) or register data (BR)
* -        branch: control signal to indicate if the instruction is a branch instruction
*
* Outputs:
* - [15:0] pcOut: output pc value after branch calculations
* -        branchTake: control signal indicating if the branch should be taken (1) or not (0)
**/

module branch(
    input [2:0] condition, // condition code for branch
    input [2:0] Flags, // format: Flags = {zero, overflow, neg}
    input [8:0] I, // instruction immediate value
    input [15:0] pcIn, // current pc value
    input [15:0] branchRegData, // data from register file for relative branching
    input branchRegMux,
    input branch,
    output [15:0] pcOut,
    output branchTake
);
    wire zero, overflow, negative;
    assign zero = Flags[2];
    assign overflow = Flags[1];
    assign negative = Flags[0];

    //logic to determine if branch should be taken based on condition code and flags
    reg b;
    always @(*) begin
        case (condition)
            3'b000: b = ~zero; //not equal
            3'b001: b = zero; //equal
            3'b010: b = ~|{negative, zero}; //greater than
            3'b011: b = negative; //less than
            3'b100: b = |{zero, ~|{negative, zero}}; //greater than or equal to
            3'b101: b = !(negative | zero); //less than or equal to
            3'b110: b = overflow; //overflow
            3'b111: b = 1'b1; //unconditional branch (jump)
            default: b = 1'b0;
        endcase
    end

    //adder to calculate hypothetical branch address
    wire [15:0] pcBranch;
    add_16bit adder2(
        .A(pcIn),
        .B({{6{I[8]}},I, 1'b0}),
        .Sum(pcBranch),
        .Cin(1'b0),
        .Cout()
    );
    //logic to determine if a branch instruction exists and if branch is taken
    assign branchTake = branch & b;
    //mux to select between branch address and register data
    assign pcOut = branchRegMux ? branchRegData : pcBranch; 
endmodule

`default_nettype wire