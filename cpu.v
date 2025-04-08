module cpu(
    input clk, rst_n,
    output [15:0] pc,
    output hlt
);

/****************************     Instruction Fetch Stage (IF)   *********************************/
//IF stage signals
/* [15:0] pcD = program counter value coming into the PC register
   [15:0] pc = program counter value being reported out of the PC combinational logic
   NOTE: pcD is determined by branch logic in cpu_ID.v. Instruction Fetch Stage does not modify either signals.
   NOTE2: flushing is simply the BranchTake signal, since we always assume branches are not taken
*/

    wire [15:0] pcInc, instr;
    wire [15:0] pc_ID, instr_ID;
    wire [15:0] pcBranch; //Branch address from ID stage, from ID stage 
    wire stall, branchTake;
    wire halt, halt_ID;

//Instruction Fetch Pipeline Module (located in cpu_IF.v)
    cpu_IF IF(
        //Inputs ========
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall),
        .branch(branchTake),
        .pc_ID(pc_ID),
        .pcBranch(pcBranch),
        .instr_ID(instr_ID),

        //Outputs =======
        .pcInc(pcInc),            //Output PC
        .pc(pc),             //current PC value
        .instr(instr),       //Instruction from inst memory
        .halt(halt)
    );



/****************************     IF/ID Pipeline Registers   *********************************/
/* NOTE: _ID signals represent signals coming out of the IF/ID Pipeline Registers
   IF/ID register gets ASSERTED either when rst_n is set (active low) or when flush is set (active high).
   Otherwise, register simply passes the pcD and instr signals to the next stage.
*/
    //program counter register
    dff IF_ID_pc [15:0] (.q(pc_ID), .d(pcInc), .wen(1'b1), .clk(clk), .rst(~rst_n | branchTake));
    //instruction register
    dff IF_ID_instr [15:0] (.q(instr_ID), .d(instr), .wen(!(stall & 1'b1)), .clk(clk), .rst(~rst_n | branchTake));
    //passing halt signal through IF/ID
    dff IF_ID_halt (.q(halt_ID), .d(halt), .wen(!(stall & 1'b1)), .clk(clk), .rst(~rst_n | branchTake));

/****************************     Instruction Decode Stage (ID)   *********************************/
//From IF/ID stage signals
/* [15:0] instr_ID = instruction passed from IF stage
   [15:0] pc_ID = current program counter passed from IF stage
*/

    wire [15:0] regSource1Data, regSource2Data, immEx, writeData_WB;    
    wire [3:0] regSource1, regSource2;
    wire [3:0] writeAddress_WB;     //address of register to write to for previous instruction (from WB stage)
    wire [3:0] regW;                //register value to be written into register file for current instruction
    wire [6:0] EXcontrols;
    wire [1:0] MEMcontrols;
    wire [1:0] WBcontrols;
    wire regWrite_WB;


// Signals used in the ID stage:
/* Used By Registers:
   [15:0] regSource1Data = data fetched from register Source1
   [15:0] regSource2Data = data fetched from register Source2
   [15:0] immEx = sign extended immediate value from instruction (depending on instruction)
   [3:0]  writeAddress_WB = register address to be written into register file (from the WB stage)
   [15:0] writeData_WB = data to be written into register file (determined in the WB stage)
   
   Used by Branch Logic:
   [15:0] pcD = pc value calculated from branch logic, sent to the pc register to either increment the pc or branch jump
   {zero, overflow, neg} = flags from the ALU (used in branch logic)

   Output from Control:
   [6:0] EXcontrols = control signals for EX stage:    {pcSwitch, aluSource, regDst, 4 bit opcode}
   [1:0] MEMcontrols = control signals for MEM stage:  {memRead, memWrite}
   [1:0] WBcontrols = control signals for WB stage:    {memToReg, regWrite}
*/

//Instruction Decode Pipeline Module
    cpu_ID ID(
        //Inputs ========
        .clk(clk),
        .rst_n(rst_n),
        .wrData(writeData_WB),
        .regWriteControl(regWrite_WB),
        .regWriteIncomingAddr(writeAddress_WB),
        .instr(instr_ID),
        .pc(pc_ID),
        .zero(zero),
        .overflow(overflow),
        .neg(neg),

        //Outputs =======
        .regSource1Data(regSource1Data),
        .regSource2Data(regSource2Data),
        .regSource1(regSource1),
        .regSource2(regSource2),
        .immEx(immEx),
        .regWrite(regW),
        .pcBranch(pcBranch),
        .EXcontrols(EXcontrols),
        .MEMcontrols(MEMcontrols),
        .WBcontrols(WBcontrols),
        .branchTake(branchTake)
    );

    //Signals for next stage
    wire [6:0] EXcontrols_EX;
    wire [1:0] MEMcontrols_EX;
    wire [1:0] WBcontrols_EX;
    wire [15:0] regSource1Data_EX, regSource2Data_EX, imm_EX, instr_EX, pc_EX;
    wire [3:0] regSource1_EX, regSource2_EX;
    wire [3:0] regW_EX;
    wire halt_EX;

/****************************     ID/EX Pipeline Registers   *********************************/

/* NOTE: _EX signals represent signals coming out of the ID/EX Pipeline Registers
   List of signals we're passing along:
     - control signal bundles (EXcontrols, MEMcontrols, WBcontrols)
     - register data from ID stage (regSource1Data, regSource2Data)
     - immediate data from instruction (immEx)
     - operation instruction from instruction fetch stage to determine write register (instr_ID)
*/
    //EXcontrols register
    dff ID_EX_EXcontrols [6:0] (.q(EXcontrols_EX), .d(EXcontrols), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //MEMcontrols register
    dff ID_EX_MEMcontrols [1:0] (.q(MEMcontrols_EX), .d(MEMcontrols), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //WBcontrols register
    dff ID_EX_WBcontrols [1:0] (.q(WBcontrols_EX), .d(WBcontrols), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register data from register Source1
    dff ID_EX_regSource1Data [15:0] (.q(regSource1Data_EX), .d(regSource1Data), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register data from register Source2
    dff ID_EX_regSource2Data [15:0] (.q(regSource2Data_EX), .d(regSource2Data), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register address for register Source1
    dff ID_EX_regSource1 [3:0] (.q(regSource1_EX), .d(regSource1), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register address for register Source2
    dff ID_EX_regSource2 [3:0] (.q(regSource2_EX), .d(regSource2), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register address to store pc_ID
    dff ID_EX_pc [15:0] (.q(pc_EX), .d(pc_ID), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores immediate data from instruction
    dff ID_EX_immEx [15:0] (.q(imm_EX), .d(immEx), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores operation instruction from instruction fetch stage
    dff ID_EX_instr [15:0] (.q(instr_EX), .d(instr_ID), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register value to be written into register file
    dff ID_EX_regW [3:0] (.q(regW_EX), .d(regW), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //passing halt signal through ID/EX
    dff IF_EX_halt (.q(halt_EX), .d(halt_ID), .wen(!(stall & 1'b1)), .clk(clk), .rst(~rst_n | branchTake));

/****************************     Execution Stage (EX)   *********************************/
//EX stage signals
    wire [15:0] aluOut;
    wire [15:0] aluOut_MEM;
    wire [1:0] ForwardA, ForwardB;

// Signals used in the EX stage:
/* Used By the ALU:
   [15:0] regSource1Data = data fetched from register Source1 in ID stage
   [15:0] regSource2Data = data fetched from register Source2 in ID stage
   [15:0] immEx = sign extended immediate value (for I type instructions)
   [5:0] EXcontrols = control signals for the ALU: {aluSource, regDst, 4 bit opcode}

   Signals from ID/EX we're passing along:
   [1:0] MEMcontrols_EX = control signals for MEM stage:  {memRead, memWrite}
   [2:0] WBcontrols_EX = control signals for WB stage:    {memToReg, regWrite, pcSwitch}
   [15:0] regSource2Data_EX = data fetched from register Source2 in ID stage
   
   Outputs of the ALU:
   [15:0] aluOut = ALU output data
   {zero, overflow, neg} = flags set by the ALU used to resolve branch uncertainty (if branch is taken we need a flush)

   Output of Combinational Logic:
   [3:0] regW = register value to be written into register file (from the EX stage)

*/
cpu_EX EX(
    //Inputs ========
    .clk(clk),
    .rst_n(rst_n),
    .pc_EX(pc_EX),
    .regSource1Data(regSource1Data_EX),
    .regSource2Data(regSource2Data_EX),
    .immEx(imm_EX),
    .EXcontrols(EXcontrols_EX),
    .memWrite(MEMcontrols_EX[0]), //MEMcontrols[0] = memWrite

    //Forwarding Inputs
    .MEM_faddress(aluOut_MEM),  //Address from EX to EX forwarding
    .WB_fdata(writeData_WB),    //Data from MEM to EX forwarding
    .ForwardA(ForwardA),
    .ForwardB(ForwardB),

    //Outputs =======
    .aluOut(aluOut),
    .zero(zero),         //ALU zero flag
    .overflow(overflow), //ALU overflow flag
    .neg(neg)         //ALU negative flag
);

//Signals for next stage
wire [15:0] regSource2Data_MEM;
wire [3:0] regSource2_MEM;
wire [3:0] regW_MEM;
wire [1:0] MEMcontrols_MEM;
wire [1:0] WBcontrols_MEM;
wire ForwardC;
wire halt_MEM;

/****************************     EX/MEM Pipeline Registers   *********************************/
/* NOTE: _MEM signals represent signals coming out of the EX/MEM Pipeline Registers
   List of signals we're passing along:
     - control signal bundles (MEMcontrols, WBcontrols)
     - register Source2 data from ID stage potentially used in memory writing (regSource2Data)
     - ALU output data (aluOut)
     - register value to be written into register file (regW)
*/
    //MEMcontrols register
    dff EX_MEM_MEMcontrols [1:0] (.q(MEMcontrols_MEM), .d(MEMcontrols_EX), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //WBcontrols register
    dff EX_MEM_WBcontrols [1:0] (.q(WBcontrols_MEM), .d(WBcontrols_EX), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register data from register Source2 from EX stage
    dff EX_MEM_regSource2Data [15:0] (.q(regSource2Data_MEM), .d(regSource2Data_EX), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that passes reg B address to MEM stage
    dff EX_MEM_regSource2 [3:0] (.q(regSource2_MEM), .d(regSource2_EX), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores ALU output data
    dff EX_MEM_aluOut [15:0] (.q(aluOut_MEM), .d(aluOut), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register value to be written into register file
    dff EX_MEM_regW [3:0] (.q(regW_MEM), .d(regW_EX), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //passing halt signal through EX/MEM
    dff EX_MEM_halt (.q(halt_MEM), .d(halt_EX), .wen(!(stall & 1'b1)), .clk(clk), .rst(~rst_n | branchTake));


/****************************     Memory Access Stage (MEM)   *********************************/
/* Used By Memory module:
   [15:0] aluOut = ALU output data (used as address for memory access)
   [15:0] regSource2Data = data fetched from register Source2 (used as data to be written into memory)
   [1:0] MEMcontrols = control signals for MEM stage:  {memRead, memWrite}

   Output from Memory module:
   [15:0] dataOut = data fetched from memory (used in WB stage to determine write data)
*/
//MEM stage signals
    wire [15:0] dataOut;
    wire memRead, memWrite, lwHalf;

cpu_MEM MEM(
    //Inputs ========
    .clk(clk),
    .rst_n(rst_n),
    .MEMcontrols(MEMcontrols_MEM),
    .aluOut(aluOut_MEM),
    .regSource2Data(regSource2Data_MEM),
    .ForwardC(ForwardC),
    .WB_fdata(writeData_WB), //Data from MEM to MEM forwarding (CHECK IF RIGHT)
    //Outputs =======
    .dataOut(dataOut)
);

//Signals for next stage
wire [15:0] dataOut_WB, aluOut_WB;
wire [1:0] WBcontrols_WB;
wire halt_WB;

/****************************     MEM/WB Pipeline Registers   *********************************/
/* NOTE: _WB signals represent signals coming out of the MEM/WB Pipeline Registers
   List of signals we're passing along:
     - write back control signal bundle (WBcontrols)
     - data fetched from memory (dataOut)
     - ALU output data (aluOut)
     - register value to be written into register file (regW)
*/
    //WBcontrols register
    dff MEM_WB_WBcontrols [1:0] (.q(WBcontrols_WB), .d(WBcontrols_MEM), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores data from memory access stage
    dff MEM_WB_dataOut [15:0] (.q(dataOut_WB), .d(dataOut), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores ALU output data
    dff MEM_WB_aluOut [15:0] (.q(aluOut_WB), .d(aluOut_MEM), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register value to be written into register file
    dff MEM_WB_regW [3:0] (.q(writeAddress_WB), .d(regW_MEM), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //passing halt signal through MEM/WB
    dff MEM_WB_halt (.q(halt_WB), .d(halt_MEM), .wen(!(stall & 1'b1)), .clk(clk), .rst(~rst_n | branchTake));


/****************************     Writeback Stage (WB)   *********************************/
wire memToReg;

assign regWrite_WB = WBcontrols_WB[0]; //CONTROL SIGNAL FOR REGWRITE: 1 for write, 0 for read
assign memToReg = WBcontrols_WB[1]; //CONTROL SIGNAL FOR MEMTOREG: 1 for memory output, 0 for ALU output
assign writeData_WB = (memToReg) ? dataOut_WB : aluOut_WB; //write data to register file
assign hlt = halt_WB; //assigning halt signal to global cpu output

/****************************     Outside Pipeline Modules   *********************************/

hazard_detection hdu(
    //load to use signals
    .IDEX_MemToReg(WBcontrols_EX[1]),   // ID/EX.MemToReg
    .IDEX_RegWrite(WBcontrols[0]),    // ID/EX.RegWrite
    .IDEX_Rd(regW_EX),                  // ID/EX.RegisterRd 
    .IFID_Rs(regSource1),                 // IF/ID.RegisterRs - READ from inside decode stage instead of pipeline
    .IFID_Rt(regSource2),                 // IF/ID.RegisterRt
    .stall(stall)
);

//DOUBLE CHECK CONNECTIONS
forwarding_unit funit(
    .MemWB_RegWrite(regWrite_WB),
    .MemWB_Rd(writeAddress_WB),
    .EXMem_RegWrite(WBcontrols_MEM[0]), // EX/MEM.RegWrite 
    .EXMem_Rd(regW_MEM),                // EX/MEM.RegisterRd
    .IDEX_Rs(regSource1_EX),              // ID/EX.RegisterRs
    .IDEX_Rt(regSource2_EX),              // ID/EX.RegisterRt
    .EXMem_Rt(regSource2_MEM),            // EX/MEM.RegisterRt
    .MemWB_MemToReg(memToReg),
    .EXMem_MemWrite(MEMcontrols_MEM[0]),


    .ForwardA(ForwardA),        //Output to forwarding mux
    .ForwardB(ForwardB),        //Output to forwarding mux
    .ForwardC(ForwardC)         //Output to forwarding mux 
);



endmodule