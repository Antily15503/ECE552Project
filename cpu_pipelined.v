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

/****************************     IF/ID Pipeline Registers   *********************************/


    //program counter register
    dff IF_ID_pc [15:0] (.q(pc_ID), .d(pcD), .wen(1'b1), .clk(clk), .rst(~rst_n | flush));
    //instruction register
    dff IF_ID_instr [15:0] (.q(instr_ID), .d(instr), .wen(1'b1), .clk(clk), .rst(~rst_n | flush));

/****************************     Instruction Decode Stage (ID)   *********************************/
//ID stage signals
    wire [15:0] regAData, regBData, immEx, writeData_WB;
    wire [3:0] secA, secB, secC, writeAddress_WB;
    wire [5:0] EXcontrols;
    wire [1:0] MEMcontrols;
    wire [1:0] WBcontrols;
    wire regWrite_WB, 

//Instruction Decode Pipeline Module
    cpu_ID ID(
        //Inputs ========
        .clk(clk),
        .rst_n(rst_n),
        .wrData(writeData_WB),
        .regWrite(regWrite_WB),
        .regWriteAddress(writeAddress_WB),
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
    wire [5:0] EXcontrols_EX;
    wire [1:0] MEMcontrols_EX;
    wire [1:0] WBcontrols_EX;
    wire [15:0] regAData_EX, regBData_EX, imm_EX, instr_EX;

/****************************     ID/EX Pipeline Registers   *********************************/

    //EXcontrols register
    dff ID_EX_EXcontrols [5:0] (.q(EXcontrols_EX), .d(EXcontrols), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //MEMcontrols register
    dff ID_EX_MEMcontrols [1:0] (.q(MEMcontrols_EX), .d(MEMcontrols), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //WBcontrols register
    dff ID_EX_WBcontrols [1:0] (.q(WBcontrols_EX), .d(WBcontrols), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register data from register A
    dff ID_EX_regAData [15:0] (.q(regAData_EX), .d(regAData), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register data from register B
    dff ID_EX_regBData [15:0] (.q(regBData_EX), .d(regBData), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores immediate data from instruction
    dff ID_EX_immEx [15:0] (.q(imm_EX), .d(immEx), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores operation instruction from instruction fetch stage
    dff ID_EX_instr [15:0] (.q(instr_EX), .d(instr_ID), .wen(1'b1), .clk(clk), .rst(~rst_n));


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

/****************************     EX/MEM Pipeline Registers   *********************************/

    //MEMcontrols register
    dff EX_MEM_MEMcontrols [1:0] (.q(MEMcontrols_MEM), .d(MEMcontrols_EX), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //WBcontrols register
    dff EX_MEM_WBcontrols [1:0] (.q(WBcontrols_MEM), .d(WBcontrols_EX), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register data from register B from EX stage
    dff EX_MEM_regBData [15:0] (.q(regBData_MEM), .d(regBData_EX), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores ALU output data
    dff EX_MEM_aluOut [15:0] (.q(aluOut_MEM), .d(aluOut), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register value to be written into register file
    dff EX_MEM_regW [3:0] (.q(regW_MEM), .d(regW), .wen(1'b1), .clk(clk), .rst(~rst_n));

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

/****************************     MEM/WB Pipeline Registers   *********************************/

    //WBcontrols register
    dff MEM_WB_WBcontrols [1:0] (.q(WBcontrols_WB), .d(WBcontrols_MEM), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores data from memory access stage
    dff MEM_WB_dataOut [15:0] (.q(dataOut_WB), .d(dataOut), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores ALU output data
    dff MEM_WB_aluOut [15:0] (.q(aluOut_WB), .d(aluOut_MEM), .wen(1'b1), .clk(clk), .rst(~rst_n));
    //register that stores register value to be written into register file
    dff MEM_WB_regW [3:0] (.q(writeAddress_WB), .d(regW_MEM), .wen(1'b1), .clk(clk), .rst(~rst_n));

/****************************     Writeback Stage (WB)   *********************************/
wire memToReg;
assign regWrite_WB = WBcontrols_WB[1]; //CONTROL SIGNAL FOR REGWRITE: 1 for write, 0 for read
assign memToReg = WBcontrols_WB[0]; //CONTROL SIGNAL FOR MEMTOREG: 1 for memory output, 0 for ALU output
assign writeData_WB = memToReg ? dataOut_WB : aluOut_WB; //write data to register file

/****************************     Outside Pipeline Modules   *********************************/

hazard_detection hdu(
    .
)



endmodule