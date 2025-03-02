module branch(
    input [2:0] condition,
    input [2:0] Flags, // Zero(Z) = bit2, Overflow (V) = bit1, and Sign (N) = bit0
    input [8:0] I,
    input [15:0] pcIn,
    input [15:0] branchReg,
    input branchRegMux,
    output [15:0] pcOut
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
            3'b111: assign b = 1'b1; //unconditional branch (jump)
            default: assign b = 1'b0;
        endcase
    end
    
    //adder to calculate hypothetical branch address
    wire [15:0] pcBranch, pcOutRaw;
    add_16bit adder(
        .A(pcIn),
        .B({{6{I[8]}},I, 1'b0}),
        .S(pcBranch)
    );
    assign pcOutRaw = b ? pcBranch : pcIn;
endmodule