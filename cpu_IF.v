module cpu_IF(
    input clk, rst_n,
    input [15:0] pcD,
    output [15:0] pc,
    output [15:0] instr
);

// Program Counter signals
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

RegisterFile reg_file(
        .clk(clk),
        .rst(~rst_n),
        .SrcReg1(regB),
        .SrcReg2(regC),
        .DstReg(regA),
        .SrcData1(regAData),
        .SrcData2(regBData),
        .WriteReg(regWrite_WB), //CONTROL SIGNAL FOR REGWRITE: 1 for write, 0 for read
        .DstData(wrData_WB)
    );

endmodule