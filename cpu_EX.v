module cpu_EX(
    input clk, rst_n,
    input [15:0] pc_ID,
    input [15:0] regAData, regBData, immEx,
    input [6:0] EXcontrols,
    
);

ALU alu(
        .clk(clk),
        .rst(~rst_n),
        .ALU_In1(regAData),
        .ALU_In2(aluSrc ? regBData : immEx), //CONTROL SIGNAL FOR ALUSRC: 1 for R instructions, 0 for I instructions
        .Opcode(opcode), //8 possible operations represented by [2:0] of Opcode Signal
        .ALU_Out(aluOut),
        .Flags({zero, overflow, neg})
    );


endmodule