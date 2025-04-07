module cpu_ID(
    input clk, rst_n,
    input [15:0] wrData,
    input [3:0] regWriteIncomingAddr,
    input regWriteControl,
    input [15:0] instr,
    input [15:0] pc,
    input zero, overflow, neg,
    output [15:0] pcBranch,
    output [15:0] regSource1Data, regSource2Data,
    output [3:0] regSource1, regSource2, regWrite
    output [15:0] immEx,
    output reg [6:0] EXcontrols,
    output reg [1:0] MEMcontrols,
    output reg [1:0] WBcontrols,
    output branchTake
);

//Instruction Decoding
    wire [3:0] opcode;
    wire [3:0] secA, secB, secC;

    assign opcode = instr[15:12];
    assign secA = instr[11:8];
    assign secB = instr[7:4];
    assign secC = instr[3:0];

//Branch Handling
    //branch module
    wire branchControl, branch;
    wire [15:0] pcBranchRelative;
    assign pcBranchRelative= regSource1Data;
    branch branchSelect(
        //inputs
        .condition(secA[3:1]),
        .Flags({zero, overflow, neg}),
        .branchRegMux(branchControl),
        .branch(branch),
        .I(instr[8:0]),
        .branchRegData(pcBranchRelative),
        .pcIn(pc),

        //outputs
        .pcOut(pcBranch),
        .branchTake(branchTake)
    );

//Control Unit
    wire regDst, aluSrc, memToReg, memRead, memWrite, pcSwitch, lwHalf, writeEnable;
    /*signals used in IF: pcSwitch, branchTake, branchControl, lwHalf
      signals used in EX: aluSrc, regDst, opcode
      signals used in MEM: memRead, memWrite
      signals used in WB: memToReg, writeEnable*/
    control controlUnit(
        //inputs
        .opcode(opcode),
        //outputs
        .RegDst(regDst),  //used
        .AluSrc(aluSrc),  //used
        .MemtoReg(memToReg),  //used
        .RegWrite(writeEnable),  //used
        .MemRead(memRead),  //used
        .MemWrite(memWrite),  //used
        .MemHalf(lwHalf), //used
        .Branch(branch), //used
        .BranchReg(branchControl), //used
        .PC(pcSwitch) //used
    );

//Register Reading
    assign regWrite = secA;
    //CONTROL SIGNAL FOR REGDST
    //1 for R instructions, 0 for I instructions
    
    //combination logic for determining which register to read from
    assign regSource2 = memWrite ? (secA) : (regDst ? (secC) : (secB));

    //Comb Logic for Register Immediate Value Updating
    //1 to assign regSource1 to instr[11:8] (only in load half), 0 to assign regSource1 to instr[7:4]
    assign  regSource1 = lwHalf ? secA : secB;

    //sign extending immediate value (if applicable)
    assign immEx = (memRead | memWrite) ? ({{11{secC[3]}}, secC, 1'b0}) : (
        lwHalf ? {8'h00, instr[7:0]} : {{12{secC[3]}}, secC}
    ); //NOTE: this is logical shifting, not arithmetic shifting
RegisterFile reg_file(
        .clk(clk),
        .rst(~rst_n),
        .SrcReg1(regSource1),
        .SrcReg2(regSource2),
        .DstReg(regWriteIncomingAddr),
        .SrcData1(regSource1Data),
        .SrcData2(regSource2Data),
        .WriteReg(regWriteControl), //CONTROL SIGNAL FOR REGWRITE: 1 for write, 0 for read
        .DstData(wrData)
    );

//Control signal bundles
    assign EXcontrols = {pcSwitch, aluSrc, regDst, opcode};
    assign MEMcontrols = {memRead, memWrite};
    assign WBcontrols = {memToReg, writeEnable};

endmodule