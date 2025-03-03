module ALU (
    input [15:0] ALU_In1, ALU_In2,
    input [3:0] Opcode,
    output reg [15:0] ALU_Out,
    output [2:0] Flags // Zero(Z) = bit2, Overflow (V) = bit1, and Sign (N) = bit0
);
    wire [15:0] adder_out;
    wire [15:0] xor_out;
    wire [15:0] shift_out;
    wire [15:0] red_out;
    wire [15:0] paddsub_out;
    wire overflow;
    wire overflow_paddsb; //might need for V flag

    //adder/subtractor
    addsub_16bit adder_sub(
        .A(ALU_In1),
        .B(ALU_In2),
        .sub(Opcode[0]),
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

    always @(*) begin
        casex(Opcode)
            4'b0000: ALU_Out = adder_out;   // ADD
            4'b0001: ALU_Out = adder_out;   // SUB
            4'b0010: ALU_Out = xor_out;     // XOR
            4'b0011: ALU_Out = red_out;     // RED
            4'b0100: ALU_Out = shift_out;   // SLL
            4'b0101: ALU_Out = shift_out;   // SRA
            4'b0110: ALU_Out = shift_out;   // ROR
            4'b0111: ALU_Out = paddsub_out; // PADDSB
            4'b100x: ALU_Out = adder_out;   // MOV
            4'b1010: ALU_Out = ((ALU_In1 & 16'hFF00) | ALU_In2[7:0]); //LLB
            4'b1011: ALU_Out = ((ALU_In1 & 16'h00FF) | ALU_In2[7:0]<<8); //LHB
            default: ALU_Out = 16'h0000;
        endcase
    end

    assign Flags[2] = (ALU_Out == 16'h0000);                                    //Z flag
    assign Flags[1] = (Opcode == 4'b0000 | Opcode == 4'b0001) ? overflow : 1'b0;  //V flag
    assign Flags[0] = (Opcode == 4'b0000 | Opcode == 4'b0001) ? ALU_Out[15] : 1'b0; //N flag                                              //N flag

endmodule