module cpu_ID(
    //Inputs ================================================
    input clk, rst_n, //Clock and reset signals

    //Instruction and PC =========
    input [15:0] instr, //Current instruction to be decoded, passed from the IF stage
    input [15:0] pc, //Current program counter value from ID stage that came out from the IF/ID register

    //Forwarding Inputs ===========
    input [3:0] IDEX_RegDst, //regwrite destination register of the previous instruction, passed from the EX stage (forwarding)
    input [15:0] IDEX_AluOut, //ALU output of the previous instruction from the EX stage (forwarding)
    input IDEX_RegWrite, //regwrite control signal of the previous instruction, passed from the EX stage (forwarding)

    //Branch Inputs ===============
    input zero, overflow, neg, //ALU flags from the EX stage

    input [15:0] wrData, //Data to be written to the register file, passed from the MEM and WB stage
    input [3:0] regWriteIncomingAddr, //Register address to be written to, passed from the MEM and WB stage
    input regWriteControl, //Control signal to determine whether we allow a register write or not, passed from the MEM and WB stage

    //Output ================================================
    output [15:0] pcBranch, //Branch target address, passed to the EX stage
    //Register related Outputs ============
    output [15:0] regSource1Data, regSource2Data, //Register data from register module to be passed to the EX stage
    output [3:0] regSource1, regSource2, regWrite, //Register addresses that we need to fetch, as well as the register to write to. regSource1, regSource2, and regWrite are all assigned locally, but regWrite gets passed on.
    output [15:0] immEx, //Sign extended immediate value to be passed to the EX stage
    
    //Control related Outputs =============
    output reg [6:0] EXcontrols, //Control signals to be passed to the EX stage
    output reg [1:0] MEMcontrols, //Control signals to be passed to the MEM stage
    output reg [1:0] WBcontrols, //Control signals to be passed to the WB stage
    output branchTake ////Control signal to determine whether we take the branch or not, passed to the IF stage
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
    wire regDst, aluSrc, memToReg, memEnable, memWrite, pcSwitch, lwHalf, writeEnable;
    /*signals used in IF: pcSwitch, branchTake, branchControl, lwHalf
      signals used in EX: aluSrc, regDst, opcode
      signals used in MEM: memEnable, memWrite
      signals used in WB: memToReg, writeEnable*/
    control controlUnit(
        //inputs
        .opcode(opcode),
        //outputs
        .RegDst(regDst),  //used
        .AluSrc(aluSrc),  //used
        .MemtoReg(memToReg),  //used
        .RegWrite(writeEnable),  //used
        .MemEnable(memEnable),  //used
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
    assign immEx = (memEnable | memWrite) ? ({{11{secC[3]}}, secC, 1'b0}) : (
        lwHalf ? {8'h00, instr[7:0]} : {{12{secC[3]}}, secC}
    ); //NOTE: this is logical shifting, not arithmetic shifting
    wire [15:0] regSource1DataRaw;
RegisterFile reg_file(
        .clk(clk),
        .rst(~rst_n),
        .SrcReg1(regSource1),
        .SrcReg2(regSource2),
        .DstReg(regWriteIncomingAddr),
        .SrcData1(regSource1DataRaw),
        .SrcData2(regSource2Data),
        .WriteReg(regWriteControl), //CONTROL SIGNAL FOR REGWRITE: 1 for write, 0 for read
        .DstData(wrData)
    );

//logic for EX to ID forwarding
    assign forwardID = (IDEX_RegDst == 0) && (regSource1 == IDEX_RegDst) && IDEX_RegWrite;
    assign regSource1Data = (forwardID) ? IDEX_AluOut : regSource1DataRaw;

//Control signal bundles
    assign EXcontrols = {pcSwitch, aluSrc, regDst, opcode};
    assign MEMcontrols = {memEnable, memWrite};
    assign WBcontrols = {memToReg, writeEnable};

endmodule