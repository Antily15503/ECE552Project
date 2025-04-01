module cpu_MEM(
    input clk, rst_n,
    input [15:0] aluOut, regBData,
    input [1:0] MEMcontrols,
    output [15:0] dataOut
);

wire memRead, memWrite, lwHalf;
assign memRead = MEMcontrols[1]; //CONTROL SIGNAL FOR MEMREAD: 1 for read, 0 for write
assign memWrite = MEMcontrols[0]; //CONTROL SIGNAL FOR MEMWRITE: 1 for write, 0 for read

//Data Memory Access
    data_memory datamem(
        .clk(clk),
        .rst(~rst_n),
        .addr(aluOut),
        .data_out(dataOut),
        .data_in(regBData),
        .wr(memWrite),
        .enable(memRead)
    );

endmodule