module RegisterFile(
    input clk, rst, writeReg,
    input [3:0] srcReg1, srcReg2, dstReg,
    input [15:0] dstData,
    inout [15:0] srcData1, srcData2
);

//a register module consisting of an array of 16 x 16 bitcells.

wire [15:0] srcAdd1, srcAdd2, dstDataClear, dR;
ReadDecoder_4_16 r1decode (.RegId(srcReg1), .Wordline(srcAdd1));
ReadDecoder_4_16 r2decode (.RegId(srcReg2), .Wordline(srcAdd2));

WriteDecoder_4_16 wdecode (.RegId(dstReg), .WriteReg(writeReg), .Wordline(dR));

//register write-before-read bypssing logic
assign srcData1 = (writeReg & (dstReg == srcReg1)? dstData : srcData1);
assign srcData2 = (writeReg & (dstReg == srcReg2)? dstData : srcData2);

//zero register never touched guarantee
assign dstDataClear = (dstReg == 0)? 16'h0000 : dstData;

Register regMain[15:0] (.clk({16{clk}}),
                         .rst({16{rst}}),
                         .writeReg(dR),
                         .D({16{dstDataClear}}),
                         .readEnable1(srcAdd1),
                         .readEnable2(srcAdd2),
                         .Bitline1(srcData1),
                         .Bitline2(srcData2));

endmodule