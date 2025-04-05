module cpu_MEM(
    input clk, rst_n,
    input [15:0] aluOut, regBData,
    input [1:0] MEMcontrols,
    input ForwardC, //Forwarding unit mux control signal for MEM to MEM
    input [15:0] WB_fdata,           //Data from MEM to MEM forwarding
    output [15:0] dataOut
);

wire memRead, memWrite, lwHalf;
assign memRead = MEMcontrols[1]; //CONTROL SIGNAL FOR MEMREAD: 1 for read, 0 for write
assign memWrite = MEMcontrols[0]; //CONTROL SIGNAL FOR MEMWRITE: 1 for write, 0 for read

wire [15:0] forward_regBData; //register data after fowarding mux
assign forward_regBData = (ForwardC) WB_fdata : regBData;

//Data Memory Access
    data_memory datamem(
        .clk(clk),
        .rst(~rst_n),
        .addr(aluOut),
        .data_out(dataOut),
        .data_in(forward_regBData),
        .wr(memWrite),
        .enable(memRead)
    );

endmodule