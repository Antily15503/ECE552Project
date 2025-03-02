module branch(
    input [2:0] condition,
    input [2:0] Flags, // Zero(Z) = bit2, Overflow (V) = bit1, and Sign (N) = bit0
    output branch
);
    wire zero, overflow, negative;

    assign zero = Flags[2];
    assign overflow = Flags[1];
    assign negative = Flags[0];
    reg b;
    always @(*) begin
        case (condition)
            3'b000: assign b = ~zero; //not equal
            3'b001: assign b = zero; //equal
            3'b010: assign b = ~|{negative, zero}; //greater than
            3'b011: assign b = negative; //less than
            3'b100: assign b = |{zero, ~|{negative, zero}}; //greater than or equal to
            3'b101: assign b = !(negative | zero); //less than or equal to
            3'b110: assign b = overflow; //overflow
            3'b111: assign b = 1'b1; //default to branch (jump)
            default: assign b = 1'b0;
        endcase
    end
    assign branch = b;
endmodule