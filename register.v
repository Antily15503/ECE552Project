module Register(
    input clk, rst, writeReg, readEnable1, readEnable2,
    input [15:0] D,
    inout [15:0] Bitline1, Bitline2
);
//basically 15 bitcells
BitCell bits[15:0] (.clk({16{clk}}),
                    .rst({16{rst}}),
                    .D(D),
                    .WriteEnable({16{writeReg}}),
                    .ReadEnable1({16{readEnable1}}),
                    .ReadEnable2({16{readEnable2}}),
                    .Bitline1(Bitline1),
                    .Bitline2(Bitline2));

endmodule