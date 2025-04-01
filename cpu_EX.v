module cpu_EX(
    input clk, rst_n,
    input [15:0] pc_ID, instr,
    input [15:0] regAData, regBData, immEx,
    input [6:0] EXcontrols,
    output [15:0] aluOut,
    output [3:0] regW
);
wire [2:0] opcode;
wire aluSrc, regDst;

assign opcode = EXcontrols[3:0];
assign aluSrc = EXcontrols[4]; //CONTROL SIGNAL FOR ALUSRC: 1 for R instructions, 0 for I instructions
assign regDst = EXcontrols[5]; //CONTROL SIGNAL FOR REGDST: 1 for R instructions, 0 for I instructions

assign regW = memWrite ? (secA) : (regDst ? (secC) : (secB));

ALU alu(
        .clk(clk),
        .rst(~rst_n),
        .ALU_In1(regAData),
        .ALU_In2(aluSrc ? regBData : immEx), 
        .Opcode(opcode),
        .ALU_Out(aluOut),
        .Flags({zero, overflow, neg})
    );

endmodule