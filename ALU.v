module ALU (
    input clk, rst,
    input [15:0] ALU_In1, ALU_In2,
    input [3:0] Opcode,
    output [15:0] ALU_Out,
    output [2:0] Flags // Zero(Z) = bit2, Overflow (V) = bit1, and Sign (N) = bit0
);
    wire [15:0] adder_out;
    wire [15:0] xor_out;
    wire [15:0] shift_out;
    wire [15:0] red_out;
    wire [15:0] paddsub_out;
    wire overflow;
    wire overflow_paddsb; //might need for V flag
    wire sub;

    //adder/subtractor
    addsub_16bit adder_sub(
        .A(ALU_In1),
        .B(ALU_In2),
        .sub(sub),
        .Sum(adder_out),
        .overflow(overflow)
    );

    //XOR instruction
    assign xor_out = ALU_In1 ^ ALU_In2;

    //shifer
    Shifter shifter_unit(
        .Shift_In(ALU_In1),
        .Shift_val(ALU_In2[3:0]),
        .Mode(Opcode[1:0]),
        .Shift_Out(shift_out)
    );

    //PADDSB instruction
    psa_16bit paddsub_unit(
        .a(ALU_In1),
        .b(ALU_In2),
        .sum(paddsub_out),
        .error(overflow_paddsb)
    );

    //reduction unit
    RED red_unit(
        .A(ALU_In1),
        .B(ALU_In2),
        .Sum(red_out)
    );

    wire zeroEnable, overflowEnable, negEnable; //output of case
    ALUControl ALUcase(.Opcode(Opcode),
                       .adder_out(adder_out),
                       .xor_out(xor_out),
                       .shift_out(shift_out),
                       .red_out(red_out),
                       .paddsub_out(paddsub_out),
                       .ALU_In1(ALU_In1),
                       .ALU_In2(ALU_In2),
                       .ALU_Out(ALU_Out),
                       .sub(sub),
                       .zeroEnable(zeroEnable),
                       .overflowEnable(overflowEnable),
                       .negEnable(negEnable));
    dff zero_dff(
        .q(Flags[2]),
        .d(ALU_Out == 16'h0000),
        .wen(zeroEnable),
        .clk(clk),
        .rst(rst)
    );
    dff overflow_dff(
        .q(Flags[1]),
        .d(overflow),
        .wen(overflowEnable),
        .clk(clk),
        .rst(rst)
    );
    dff neg_dff(
        .q(Flags[0]),
        .d(ALU_Out[15]),
        .wen(negEnable),
        .clk(clk),
        .rst(rst)
    );

    

endmodule