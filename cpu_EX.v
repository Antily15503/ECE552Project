module cpu_EX(
    input clk, rst_n,
    input [15:0] pc_ID, instr, 
    input [15:0] regAData, regBData, immEx,
    input [6:0] EXcontrols,
    input memWrite,
    input [15:0] MEM_faddress,       //Address from EX to EX forwarding
    input [15:0] WB_fdata,          //Data from MEM to EX forwarding
    input [1:0] ForwardA, ForwardB, //Forwarding unit mux control signals
    output [15:0] aluOut,
    output [3:0] regW,
    output zero, overflow, neg
);
wire [2:0] opcode;
wire pcSwitch, aluSrc, regDst;
wire [15:0] forward_regAData, forward_regBData; //register data after fowarding muxs

assign forward_regAData = (ForwardA == 2'b10) ? MEM_faddress :
                          (ForwardA == 2'b01) ? WB_fdata :
                          regAData;

assign forward_regBData = (ForwardB == 2'b10) ? MEM_faddress :
                          (ForwardB == 2'b01) ? WB_fdata :
                          regBData;

assign opcode = EXcontrols[3:0];
assign aluSrc = EXcontrols[4]; //CONTROL SIGNAL FOR ALUSRC: 1 for R instructions, 0 for I instructions
assign regDst = EXcontrols[5]; //CONTROL SIGNAL FOR REGDST: 1 for R instructions, 0 for I instructions
assign pcSwitch = EXcontrols[6]; //CONTROL SIGNAL FOR PCSWITCH: 1 to store pc in register, 0 for all other instructions

assign regW = memWrite ? (secA) : (regDst ? (secC) : (secB)); //Register write for a SW instruction 

wire [15:0] in1, in2; //inputs to the ALU
assign in1 = pcSwitch ? pc_ID : forward_regAData; //ALU input 1 is the PC if pcSwitch is 1, otherwise it's the register data
assign in2 = aluSrc ? forward_regBData : immEx; //ALU input 2 is the immediate value if aluSrc is 1, otherwise it's the register data

ALU alu(
        .clk(clk),
        .rst(~rst_n),
        .ALU_In1(in1),
        .ALU_In2(in2), 
        .Opcode(opcode),
        .ALU_Out(aluOut),
        .Flags({zero, overflow, neg})
    );

endmodule