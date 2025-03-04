module cpu(
    input clk, rst_n,
    output [15:0] pc,
    output hlt
);

// Program Counter signals
    wire [15:0] pcD;
    dff pcFlops [15:0] (
        .q(pc),
        .d(pcD),
        .wen(1'b1),
        .clk(clk),
        .rst(~rst_n)
    );

//Instruction Memory Accessing DONE
    wire [15:0] instr;
    inst_memory instruction_mem(
            .clk(clk),
            .rst(~rst_n),
            .addr(pc),
            .data_out(instr),
            .data_in(16'h0000),
            .wr(1'b0),
            .enable(1'b1)
        );

//Instruction Decoding DONE
    wire [3:0] opcode;
    wire [3:0] secA, secB, secC;

    assign opcode = instr[15:12];
    assign secA = instr[11:8];
    assign secB = instr[7:4];
    assign secC = instr[3:0];

//Branch Handling DONE
    //branch module
    wire [15:0] pcBranch, regBData;
    wire BranchReg, Branch, halt;
    wire Zero, Neg, Overflow;
    branch branchSelect(
        .condition(secA[3:1]),
        .Flags({Zero, Overflow, Neg}),
        .branchRegMux(BranchReg),
        .branch(Branch),
        .I(instr[8:0]),
        .branchReg(regBData),
        .pcIn(pc),
        .pcOut(pcD)
    );

//Control Unit
    wire RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, pcswitch, lwhalf;
    wire alusss;
    control controlUnit(
        //inputs
        .opcode(opcode),
        //outputs
        .RegDst(RegDst),  //used
        .AluSrc(AluSrc),  //used
        .MemtoReg(MemtoReg),  //used
        .RegWrite(RegWrite),  //used
        .MemRead(MemRead),  //used
        .MemWrite(MemWrite),  //used
        .MemHalf(lwhalf), //used
        .Branch(Branch), //used
        .BranchReg(BranchReg), //used
        .PC(pcswitch), //used
        .Halt(halt) //used
    );

//Register Reading
    wire [15:0] regAData;
    wire [15:0] aluOut;
    wire [3:0] regA, regB, regC;
    assign regA = secA;
    //CONTROL SIGNAL FOR REGDST: 1 for R instructions, 0 for I instructions
    assign regC = RegDst ? (secC) : (secB);

    //Comb Logic for Register Immediate Value Updating
    assign  regB = lwhalf ? secA : secB;
    
    //TWO 2-1 MUXES FOR SELECTING REGISTER WRITE DATA (PC, ALUOUT, or MEMOUT)
    //CONTROL SIGNAL FOR PC: 1 for PC, 0 for everything else
    //CONTROL SIGNAL FOR ALUOUT: 1 for memory output, 0 for ALU output
    reg [15:0] wrDataIntermed;
    wire [15:0] wrData;
    wire [15:0] data_out;
    always @(*) begin
        casex({pcswitch, MemtoReg})
            2'b1?: wrDataIntermed = pcD;
            2'b01: wrDataIntermed = data_out;
            2'b00: wrDataIntermed = aluOut;
            default: wrDataIntermed = 16'h0000;
        endcase
    end
    assign wrData = wrDataIntermed;

    RegisterFile reg_file(
        .clk(clk),
        .rst(~rst_n),
        .SrcReg1(regB),
        .SrcReg2(regC),
        .DstReg(regA),
        .SrcData1(regAData),
        .SrcData2(regBData),
        .WriteReg(RegWrite), //CONTROL SIGNAL FOR REGWRITE: 1 for write, 0 for read
        .DstData(wrData)
    );


//Arithmetic Logic Unit DONE
    wire [15:0] immEx;
    

    //sign extending immediate value (if applicable)
    assign immEx = lwhalf ? {8'h00, instr[7:0]} : {{12{secC[3]}}, secC}; //NOTE: this is logical shifting, not arithmetic shifting

    ALU alu(
        .ALU_In1(regAData),
        .ALU_In2(AluSrc ? regBData : immEx), //CONTROL SIGNAL FOR ALUSRC: 1 for R instructions, 0 for I instructions
        .Opcode(opcode), //8 possible operations represented by [2:0] of Opcode Signal
        .ALU_Out(aluOut),
        .Flags({Zero, Overflow, Neg})
    );

//Data Memory Access
    data_memory datamem(
        .clk(clk),
        .rst(~rst_n),
        .addr(aluOut),
        .data_out(data_out),
        .data_in(regBData),
        .wr(MemWrite), //CONTROL SIGNAL FOR MEMWRITE: 1 for write, 0 for read
        .enable(MemRead) //CONTROL SIGNAL FOR MEMREAD: 1 for read, 0 for write
    );

assign hlt = halt;

endmodule