module addsub_16bit (
    input [15:0] A, B, //input values
    input sub, // add-sub indicator
    output [15:0] Sum, //sum output
    output overflow //signal for checking overflow
);

//16bit carry lookahead addder or subtractor
//if sub = 0, addition
//if sub = 1, subtraction
wire [15:0] Bnot; //inverted B
assign Bnot = sub ? ~B : B; //Bnot is an inverted B if subtraction is asserted

wire [15:0] P, G; //propagate and generate signals for carry lookahead
wire [15:0] Carry; //carry signals
wire [15:0] SumRaw; //Sum without overflow check
wire Cout, posOv, negOv; //signals for overflow check

//generate P and G signals
assign P = A ^ Bnot; //if only 1 signal between A or Bnot is 1, then propagate
assign G = A & Bnot; //if both A and Bnot is 1, then generate

//ripple carry signals from P and G
assign Carry[0] = sub;
assign Carry[1] = G[0] | (P[0] & Carry[0]);
assign Carry[2] = G[1] | (P[1] & Carry[1]);
assign Carry[3] = G[2] | (P[2] & Carry[2]);
assign Carry[4] = G[3] | (P[3] & Carry[3]);
assign Carry[5] = G[4] | (P[4] & Carry[4]);
assign Carry[6] = G[5] | (P[5] & Carry[5]);
assign Carry[7] = G[6] | (P[6] & Carry[6]);
assign Carry[8] = G[7] | (P[7] & Carry[7]);
assign Carry[9] = G[8] | (P[8] & Carry[8]);
assign Carry[10] = G[9] | (P[9] & Carry[9]);
assign Carry[11] = G[10] | (P[10] & Carry[10]);
assign Carry[12] = G[11] | (P[11] & Carry[11]);
assign Carry[13] = G[12] | (P[12] & Carry[12]);
assign Carry[14] = G[13] | (P[13] & Carry[13]);
assign Carry[15] = G[14] | (P[14] & Carry[14]);
assign Cout = G[15] | (P[15] & Carry[15]);
assign SumRaw = P ^ Carry; //Generate the sum through P, G, and carry signals

//Overriding Sum if overflow detected
assign posOv = ( (A[15] == 1'b0) & (Bnot[15] == 1'b0) & (SumRaw[15] == 1'b1));
assign negOv = ( (A[15] == 1'b1) & (Bnot[15] == 1'b1) & (SumRaw[15] == 1'b0));
assign overflow = posOv | negOv;
assign Sum = posOv ? (16'h7FFF) : (//16'h7FFF = 0x0111111111111111 
    negOv ? (16'h8000) : ( //16'h8000 = 0x1000000000000000
    SumRaw
    )
);

endmodule