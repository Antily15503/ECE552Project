module WriteDecoder_4_16(
    input [3:0] RegId,
    input WriteReg,
    output [15:0] Wordline
);
//a 4 to 16 decoder that turns a read address into a one-hot 16bit activation mask.
//Depending on WriteReg, either only one bit should be set to a 1 for a given input address or none.

wire [15:0] zeros;
assign zeros[15] = WriteReg;
Shifter shift(.Shift_In(zeros), .Shift_val(RegId), .Mode(1'b0), .Shift_Out(Wordline));
endmodule