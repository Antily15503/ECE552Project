module cpu(
    input clk, rst_n,
    output [15:0] pc,
    output hlt
);

/****************************     Instruction Fetch Stage (IF)   *********************************/
//IF stage signals
    wire [15:0] pcD, instr;
    wire [15:0] pc_ID, instr_ID;
    wire flush;
//Instruction Fetch Pipeline Module
    cpu_IF IF(
        .clk(clk),
        .rst_n(rst_n),
        .pcD(pcD),
        .pc(pc),
        .instr(instr)
    );

//Instruction Fetch Pipeline Register
    dff IF_ID [31:0] (
        .q({pcD, instr}),
        .d({pc_ID, instr_ID}),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n | flush)
    );

/****************************     Instruction Decode Stage (ID)   *********************************/
//ID stage signals
    wire [15:0] regAData, regBData, immEx;
    wire [3:0] secA, secB, secC;
    wire [5:0] EXcontrols;
    wire [1:0] MEMcontrols;
    wire [1:0] WBcontrols;

//Instruction Decode Pipeline Module
    cpu_ID ID(
        //Inputs ========
        .clk(clk),
        .rst_n(rst_n),
        .wrData(/*TODO: FILL THIS IN*/),
        .regWrite(/*TODO: FILL THIS IN*/),
        .regWriteData(/*TODO: FILL THIS IN*/),
        .instr(instr_ID),
        .pc(pc_ID),
        .zero(/*TODO: FILL THIS IN*/),
        .overflow(/*TODO: FILL THIS IN*/),
        .neg(/*TODO: FILL THIS IN*/),

        //Outputs =======
        .regAData(regAData),
        .regBData(regBData),
        .immEx(immEx),
        .pcD(pcD),
        .EXcontrols(EXcontrols),
        .MEMcontrols(MEMcontrols),
        .WBcontrols(WBcontrols),
    );


    ////////////////////////DEPRECATED: Move to another pipelining station///////////////////////
    //TWO 2-1 MUXES FOR SELECTING REGISTER WRITE DATA (PC, ALUOUT, or MEMOUT)
    //CONTROL SIGNAL FOR PC: 1 for PC, 0 for everything else
    //CONTROL SIGNAL FOR ALUOUT: 1 for memory output, 0 for ALU output
    reg [15:0] wrDataIntermed;
    wire [15:0] wrData;
    wire [15:0] data_out;
    always @(*) begin
        casex({pcSwitch, memToReg})
            2'b1?: wrDataIntermed = pcD;
            2'b01: wrDataIntermed = data_out;
            2'b00: wrDataIntermed = aluOut;
            default: wrDataIntermed = 16'h0000;
        endcase
    end
    assign wrData = wrDataIntermed;
    //////////////////////////////////////////////////////////

    //Signals for next stage
    wire [6:0] EXcontrols_EX;
    wire [1:0] MEMcontrols_EX;
    wire [1:0] WBcontrols_EX;
    wire [15:0] regAData_EX, regBData_EX, imm_EX, instr_EX;

    //PIPELINE REGISTER: ID/EX
    dff ID_EX [75:0] (
        .q({EXcontrols, MEMcontrols, WBcontrols, regAData, regBData, immEx, instr_ID}),
        .d({EXcontrols_EX, MEMcontrols_EX, WBcontrols_EX, regAData_EX, regBData_EX, imm_EX, instr_EX}),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n)
    );

/****************************     Execution Stage (EX)   *********************************/
//EX stage signals
    wire [15:0] aluOut;
    wire [3:0] regW;
cpu_EX EX(
    //Inputs ========
    .clk(clk),
    .rst_n(rst_n),
    .pc_ID(pc_ID),
    .regAData(regAData_EX),
    .regBData(regBData_EX),
    .immEx(imm_EX),
    .EXcontrols(EXcontrols_EX),
    .instr(instr_EX),

    //Outputs =======
    .aluOut(aluOut),
    .regW(regW),
);

//Signals for next stage
wire [15:0] aluOut_MEM, regBData_MEM;
wire [3:0] regW_MEM;
wire [1:0] MEMcontrols_MEM;
wire [1:0] WBcontrols_MEM;

//PIPELINE REGISTER: EX/MEM
    dff ID_EX [24:0] (
        .q({MEMcontrols_EX, WBcontrols_EX, regBData_EX, aluOut, regW}),
        .d({MEMcontrols_MEM, WBcontrols_MEM, regBData_MEM, aluOut_MEM, regW_MEM}),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n)
    );

/****************************     Memory Access Stage (MEM)   *********************************/
//MEM stage signals
    wire [15:0] dataOut;
    wire memRead, memWrite, lwHalf, halt;

cpu_MEM(
    //Inputs ========
    .clk(clk),
    .rst_n(rst_n),
    .MEMcontrols(MEMcontrols_MEM),

    //Outputs =======
    .dataOut(dataOut),
);

//Signals for next stage
wire [15:0] dataOut_WB;
wire [1:0] WBcontrols_WB;
wire [15:0] aluOut_WB, dataOut_WB;
wire [3:0] regW_WB;

//PIPELINE REGISTER: MEM/WB
    dff ID_EX [??:0] (
        .q({WBcontrols_MEM, aluOut_MEM, dataOut, regW_MEM}),
        .d({WBcontrols_WB, aluOut_WB, dataOut_WB, regW_WB}),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n)
    );

/****************************     Writeback Stage (WB)   *********************************/

assign hlt = halt;


/****************************     Outside Pipeline Modules   *********************************/

hazard_detection hdu(
    .
)



endmodule