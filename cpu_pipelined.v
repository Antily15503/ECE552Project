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
    wire [6:0] EXcontrols;
    wire [2:0] MEMcontrols;
    wire [1:0] WBcontrols;

//Instruction Decode Pipeline Module
    cpu_ID ID(
        .clk(clk),
        .rst_n(rst_n),
        .wrData(/*TODO: FILL THIS IN*/),
        .regWrite(/*TODO: FILL THIS IN*/),
        .instr(instr_ID),
        .pc(pc_ID),
        .regAData(regAData),
        .regBData(regBData),
        .immEx(immEx),
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
    wire [2:0] MEMcontrols_EX;
    wire [1:0] WBcontrols_EX;
    wire [15:0] regAData_EX, regBData_EX, imm_EX;

    //PIPELINE REGISTER: ID/EX
    dff ID_EX [59:0] (
        .q({EXcontrols, MEMcontrols, WBcontrols, regAData, regBData, immEx}),
        .d({EXcontrols_EX, MEMcontrols_EX, WBcontrols_EX, regAData_EX, regBData_EX, imm_EX}),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n)
    );

/****************************     Execution Stage (EX)   *********************************/

cpu_EX EX(
    .clk(clk),
    .rst_n(rst_n),
    .pc_ID(pc_ID),
    .regAData(regAData_EX),
    .regBData(regBData_EX),
    .immEx(imm_EX),
    .EXcontrols(EXcontrols_EX),
);

//Signals for next stage
wire [2:0] MEMcontrols_MEM;
wire [1:0] WBcontrols_MEM;
wire [15:0] regAData_EX, regBData_EX;

//PIPELINE REGISTER: EX/MEM
    dff ID_EX [??:0] (
        .q({MEMcontrols_EX, WBcontrols_EX}),
        .d({MEMcontrols_MEM, WBcontrols_MEM}),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n)
    );

/****************************     Memory Access Stage (MEM)   *********************************/

//Data Memory Access
    data_memory datamem(
        .clk(clk),
        .rst(~rst_n),
        .addr(aluOut),
        .data_out(data_out),
        .data_in(regBData),
        .wr(memWrite), //CONTROL SIGNAL FOR MEMWRITE: 1 for write, 0 for read
        .enable(memRead) //CONTROL SIGNAL FOR MEMREAD: 1 for read, 0 for write
    );

/****************************     Writeback Stage (WB)   *********************************/

assign hlt = halt;


/****************************     Outside Pipeline Modules   *********************************/



endmodule