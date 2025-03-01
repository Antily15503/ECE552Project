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
        .rst(rst_n)
    );

// Program Counter incrementer
    wire [15:0] pcInc;
    add_16bit pcIncr(
        .A(pc),
        .B(16'h0040),
        .cin(1'b0),
        .Sum(pcInc),
        .Cout()
    );

//Instruction Memory Accessing DONE
    wire [15:0] instr;
    inst_memory instruction_mem(
            .clk(clk),
            .rst(rst_n),
            .addr(pc),
            .data_out(instr),
            .data_in(16'h0000),
            .wr(1'b0),
            .enable(1'b1)
        );

//Instruction Decoding DONE
    wire [3:0] opcode;
    wire [3:0] regA, regB;
    wire [15:0] imm;

    assign opcode = instr[15:12];
    assign secA = instr[11:8];
    assign secB = instr[7:4];
    assign secC = instr[3:0];

//Jumps and Branch Handling
    

//Control Unit
    wire RegDst, AluSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch;
    wire [2:0] AluOp;
    control(
        //inputs
        .opcode(opcode),
        //outputs
        .AluOp(AluOp),  //used
        .RegDst(RegDst),  //used
        .AluSrc(AluSrc),  //used
        .MemtoReg(MemtoReg),  //used
        .RegWrite(RegWrite),  //used
        .MemRead(MemRead),  //used
        .MemWrite(MemWrite),  //used
        .Branch(Branch),
        .Jump(Jump)
    );

//Register Reading
    wire [15:0] regAData, regBData;
    wire [3:0] regA, regB, regC;
    assign regA = secA;
    assign regB = recB;
    //CONTROL SIGNAL FOR REGDST: 1 for R instructions, 0 for I instructions
    assign regC = RegDst ? (secC) : (secB);
    reg_file(
        .clk(clk),
        .rst(rst_n),
        .src_reg1(regB),
        .src_reg2(regC),
        .dst_reg(regA),
        .src_data1(regAData),
        .src_data2(regBData),
        .write_reg(RegWrite), //CONTROL SIGNAL FOR REGWRITE: 1 for write, 0 for read
        .wrData(MemtoReg ? data_out : aluOut) //CONTROL SIGNAL FOR ALUOUT: 1 for memory output, 0 for ALU output
    );

//Arithmetic Logic Unit UNUSED OUTPUT: Zero
    wire [15:0] aluOut;
    wire [15:0] immEx;
    wire Zero;

    //sign extending immediate value (if applicable)

    assign immEx = {12'h000, secC}; //NOTE: this is logical shifting, not arithmetic shifting

    alu(
        .ALU_In1(regAData),
        .B(AluSrc ? regBData : immEx), //CONTROL SIGNAL FOR ALUSRC: 1 for R instructions, 0 for I instructions
        .ALUOp(ALUOp), //8 possible operations represented by [2:0] ALUOp Signal
        .ALUSrc(ALUSrc),
        .ALUOut(aluOut),
        .Zero(Zero) // zero flag
    );

//Data Memory Access
    wire [15:0] data_out;
    data_memory(
        .clk(clk),
        .rst(rst_n),
        .addr(aluOut),
        .data_out(data_out),
        .data_in(regBData),
        .wr(MemWrite), //CONTROL SIGNAL FOR MEMWRITE: 1 for write, 0 for read
        .enable(MemRead), //CONTROL SIGNAL FOR MEMREAD: 1 for read, 0 for write
    );

endmodule