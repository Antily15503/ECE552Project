module add_4bit (
    input [3:0] A, B, //input values
    input cin, //carry-in bit
    output [3:0] Sum, //sum output
    output Cout //carry-out bit
);
    //4bit carry lookahead adder. NO SUBTRACTION

    wire [3:0] P, G; //propagate and generate signals for carry lookahead
    wire [3:0] C; //carry signals

    assign P = A ^ B; //if only 1 signal between A or B is 1, then propagate
    assign G = A & B; //if both A and B is 1, then generate

    //ripple carry signals from P and G
    assing C[0] = cin;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);
    assign Cout = G[3] | (P[3] & C[3]);

    //generate sum using carry lookahead signals
    assign Sum = P ^ C[3:0];
endmodule