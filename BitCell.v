module BitCell(
    input clk, rst, D, WriteEnable, ReadEnable1, ReadEnable2,
    inout Bitline1, Bitline2
);
//implementation of a bitcell within a register
wire q;

dff dffb (.q(q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst)); //flip flop

//disables the current bitcell if Readenable is not enabled
assign Bitline1 = ReadEnable1 ? q : 1'bz;
assign Bitline2 = ReadEnable2 ? q : 1'bz;

endmodule