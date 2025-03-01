module branch(
    input [2:0] condition,
    input zero, overflow, negative,
    output branch
);

wire b;
case (condition)
    3'b000: assign b = ~zero; //not equal
    3'b001: assign b = zero; //equal
    3'b010: assign b = ~|{negative, zero}; //greater than
    3'b011: assign b = negative; //less than
    3'b100: assign b = |{zero, ~|{negative, zero}}; //greater than or equal to
    3'b101: assign b = !(negative | zero); //less than or equal to
    3'b110: assign b = overflow; //overflow
    default: assign b = 1'b0; //default to no branch
endcase
assign branch = b;
endmodule