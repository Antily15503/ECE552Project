`default_nettype none

/**
* This is the ALU module for the 16-bit processor. It calculates and generates the ALU output based on
* the opcode and the two inputs. Some instructions can also update flag bits (Zero, Sign, Overflow).
* 
* Inputs:
* -        clk: clock signal
* -        rst: reset signal
* - [15:0] ALU_In1: first input to the ALU
* - [15:0] ALU_In2: second input to the ALU
* - [3:0]  Opcode: operation code that determines the operation to be performed
*
* Outputs:
* - [15:0] ALU_Out: output of the ALU after performing the operation specified by Opcode
* - [2:0]  Flags: 3-bit output representing the status flags {Zero, Overflow, Sign}
**/
module ALU (
    input clk, rst,
    input [15:0] ALU_In1, ALU_In2,
    input [3:0] Opcode,
    output [15:0] ALU_Out,
    output [2:0] Flags // Zero(Z) = bit2, Overflow (V) = bit1, and Sign (N) = bit0
);

    // wire busses that store potential outputs of the ALU
    wire [15:0] adder_out;
    wire [15:0] xor_out;
    wire [15:0] shift_out;
    wire [15:0] red_out;
    wire [15:0] paddsub_out;

    //wires that store other signals
    wire overflow;
    wire overflow_paddsb; //might need for V flag
    wire sub;

    //ALU internal adder/subtractor
    //Note: subtraction is done by setting sub to 1
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

    //ALU control unit, determines which operation to use, and which flags to set
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
    wire [2:0] Flags_q;

    //Flags register, stores the status of the ALU and flops them on the clock edge
    dff zero_dff(
        .q(Flags_q[2]),
        .d(ALU_Out == 16'h0000),
        .wen(zeroEnable),
        .clk(clk),
        .rst(rst)
    );
    dff overflow_dff(
        .q(Flags_q[1]),
        .d(overflow),
        .wen(overflowEnable),
        .clk(clk),
        .rst(rst)
    );
    dff neg_dff(
        .q(Flags_q[0]),
        .d(ALU_Out[15]),
        .wen(negEnable),
        .clk(clk),
        .rst(rst)
    );

    assign Flags[0] = negEnable ? ALU_Out[15] : Flags_q[0]; //N flag bypassing
    assign Flags[1] = overflowEnable ? overflow : Flags_q[1]; //V flag bypassing
    assign Flags[2] = zeroEnable ? (ALU_Out == 16'h0000) : Flags_q[2]; //Z flag bypassing
endmodule

`default_nettype wire