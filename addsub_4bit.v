module addsub_4bit (
    input [3:0] A, B, //input values
    input sub, // add-sub indicator
    output [3:0] Sum, //sum output
    output Cout //carry-out bit
);
    //4bit carry lookahead adder/subtracter
    //if sub = 0, addition
    //if sub = 1, subtraction

    wire [3:0] P, G; //propagate and generate signals for carry lookahead
    wire [3:0] Bnot, SumRaw;
    wire [3:0] C; //carry signals
    wire posOv, negOv; //signals for overflow check

    assign Bnot = sub ? ~B : B; //Bnot is an inverted B if subtraction is asserted
    assign P = A ^ Bnot; //if only 1 signal between A or Bnot is 1, then propagate
    assign G = A & Bnot; //if both A and Bnot is 1, then generate

    //ripple carry signals from P and G
    assing C[0] = sub;
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & C[1]);
    assign C[3] = G[2] | (P[2] & C[2]);
    assign Cout = G[3] | (P[3] & C[3]);
    assign SumRaw = P ^ C;

    //Overriding Sum if overflow detected
    assign posOv = ( (A[3] == 1'b0) && (Bnot[3] == 1'b0) && (SumRaw[3] == 1'b1));
    assign negOv = ( (A[3] == 1'b1) && (Bnot[3] == 1'b1) && (SumRaw[3] == 1'b0));
    assign Sum = posOv ? (4'h7) : ( //4'h7 = 0x0111
        negOv ? (4'h8) : ( //4'h8 = 0x1000
            SumRaw
        )
    );
endmodule

