module branch(
    input [2:0] condition, // condition code for branch
    input [2:0] Flags, // format: Flags = {zero, overflow, neg}
    input [8:0] I, // instruction immediate value
    input [15:0] pcIn, // current pc value
    input [15:0] branchReg, 
    input branchRegMux,
    input branch,
    output [15:0] pcOut
);
    wire zero, overflow, negative;
    assign zero = Flags[2];
    assign overflow = Flags[1];
    assign negative = Flags[0];


    reg b;
    always @(*) begin
        case (condition)
            3'b000: b = ~zero; //not equal
            3'b001: b = zero; //equal
            3'b010: b = ~|{negative, zero}; //greater than
            3'b011: b = negative; //less than
            3'b100: b = |{zero, ~|{negative, zero}}; //greater than or equal to
            3'b101: b = !(negative | zero); //less than or equal to
            3'b110: b = overflow; //overflow
            3'b111: b = 1'b1; //unconditional branch (jump)
            default: b = 1'b0;
        endcase
    end

    //adder to calculate hypothetical branch address
    add_16bit adder2(
        .A(pcInc),
        .B({{6{I[8]}},I, 1'b0}),
        .Sum(pcBranch),
        .Cin(1'b0),
        .Cout()
    );
    
    wire [15:0] pcOutInternal;
    assign pcOutInternal = (branch & b) ? pcBranch : pcInc;
    assign pcOut = branchRegMux ? branchReg : pcOutInternal;
endmodule