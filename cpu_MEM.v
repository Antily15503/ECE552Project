module cpu_MEM(
    input clk, rst_n,
    input [15:0] aluOut, regSource2Data,
    input [1:0] MEMcontrols,
    input ForwardC, //Forwarding unit mux control signal for MEM to MEM
    input [15:0] WB_fdata,           //Data from MEM to MEM forwarding
    output [15:0] dataOut
);

wire memEnable, memWrite;
assign memEnable = MEMcontrols[1]; //CONTROL SIGNAL FOR MEMREAD: 1 for read, 0 for write
assign memWrite = MEMcontrols[0]; //CONTROL SIGNAL FOR MEMWRITE: 1 for write, 0 for read

wire [15:0] forward_regSource2Data; //register data after fowarding mux
assign forward_regSource2Data = (ForwardC) ? WB_fdata : regSource2Data;

//Data Memory Access
    data_memory datamem(
        .clk(clk),
        .rst(~rst_n),
        .addr(aluOut),
        .data_out(dataOut),
        .data_in(forward_regSource2Data),
        .wr(memWrite),
        .enable(memEnable)
    );

endmodule