module ALU (
    input [15:0] ALU_In1, ALU_In2,
    input [2:0] Opcode,
    output [15:0] ALU_Out,
    input Cin,
    //input inv1, inv2, //inversons for subtraction (may need to delete for CLA)
    output Z_Flag, N_Flag, V_Flag,
    output Error
);
    wire [15:0] adder_out;
    wire [15:0] xor_out;
    wire [15:0] shift_out;
    wire [15:0] red_out;
    wire [15:0] paddsub_out;
    
    //wire [15:0] In1_PostInversion, In2_PostInversion; //may need to delete for CLA

    //assign In1_PostInversion = invA ? ~ALU_In1 : ALU_In1;
    //assign In2_PostInversion = inv2 ? ~ALU_In2 : ALU_In2;

    //adder/subtractor
    addsub_16bit adder_sub(
        .A(ALU_In1),
        .B(ALU_In2),
        .sub(Opcode[0]),
        .Sum(adder_out),
    );

    //XOR instruction
    assign xor_out = ALU_In1 ^ ALU_Out;

    //shifer
    Shifter shifter_unit(
        .Shift_In(ALU_In1),
        .Shift_val(ALU_In2[3:0]),
        .Mode(Op[1:0]),
        .Shift_Out(shift_out)
    );

    //PADDSB instruction
    paddsub paddsub_unit(
        .a(ALU_In1),
        .b(ALU_In2),
        .sum(paddsub_out)
    );

    //reduction unit
    RED red_unit(
        .A(ALU_In1),
        .B(ALU_In2),
        .Sum(red_out)
    );

    always @(*) begin
        case(Opcode)
            3'b000: ALU_Out = adder_out;   // ADD
            3'b001: ALU_Out = adder_out;   // SUB (using invB and Cin=1)
            3'b010: ALU_Out = xor_out;     // XOR
            3'b011: ALU_Out = red_out;     // RED
            3'b100: ALU_Out = shift_out;   // SLL
            3'b101: ALU_Out = shift_out;   // SRA
            3'b110: ALU_Out = shift_out;   // ROR
            3'b111: ALU_Out = paddsb_out;  // PADDSB
            default: ALU_Out = 16'h0000;
        endcase
    end

endmodule