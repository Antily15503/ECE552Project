module ALU (
    input [3:0] ALU_In1, ALU_In2,
    input [1:0] Opcode,
    output [3:0] ALU_Out,
    output Error
);

/* 
    An ALU block implementation with the following opcodes encoded:
    00 : Addition
    01 : Subtraction
    10 : XOR
    11 : NAND
*/

wire [3:0] bitwise;
wire [3:0] sum;

assign bitwise = Opcode[0] ? ~(ALU_In1 & ALU_In2) : (ALU_In1 ^ ALU_In2);
addsub_4bit adder(.A(ALU_In1), .B(ALU_In2), .sub(Opcode[0]), .Sum(sum), .Ovfl(Error));

assign ALU_Out = Opcode[1] ? bitwise : sum;

endmodule