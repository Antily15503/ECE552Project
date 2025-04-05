module pc_logic(
    input [15:0] pcIn, //Program Counter value coming out of the PC register
    input stall, halt //Stall and Halt signal from the hazard detection unit
    input [15:0] pc_ID //Program Counter value coming out of the ID stage
    
    output [15:0] pcD //Program Counter value to be put into the PC register
    output [15:0] pcInc, //Program Counter value + 2
);

//adder to calculate next pc value
//pcInc = pcIn + 2
wire [15:0] pcInc, pcBranch;
add_16bit adder(
    .A(pcIn),
    .B(16'h0002),
    .Sum(pcInc),
    .Cin(1'b0),
    .Cout()
);

//if stall or halt signal is high, we prevent the pc from incrementing, otherwise pc = pc + 2
assign pcD = (stall || halt) ? pcIn : pcInc; 

//if the stall signal is high, we assign the pc value to the ID stage to prevent new instruction from being fetched
assign pcInc = stall ? pc_ID : pcInc;
endmodule