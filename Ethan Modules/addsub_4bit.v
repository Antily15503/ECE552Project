module addsub_4bit (
    input [3:0] A, B, //Input values
    input sub, // add-sub indicator
    output [3:0] Sum, //sum output
    output Ovfl //To indicate overflow
);
    //4bit ripple carry adder/subtracter
    //if sub = 0, addition
    //if sub = 1, subtraction

    wire [3:0] Bnot;

    assign Bnot = sub ? ~B : B; //Bnot is an inverted B if subtraction is asserted
    wire [2:0] carry;
    full_adder_1bit FA1 (.A(A[0]), .B(Bnot[0]), .cin(sub), .S(Sum[0]), .cout(carry[0]));
    full_adder_1bit FA2 (.A(A[1]), .B(Bnot[1]), .cin(carry[0]), .S(Sum[1]), .cout(carry[1]));
    full_adder_1bit FA3 (.A(A[2]), .B(Bnot[2]), .cin(carry[1]), .S(Sum[2]), .cout(carry[2]));
    full_adder_1bit FA4 (.A(A[3]), .B(Bnot[3]), .cin(carry[2]), .S(Sum[3]), .cout(cout));

    assign Ovfl = (A[3] == Bnot[3]) & (A[3] ^ Sum[3]); 
    //overflow only occurs if the bits of A and B are the same, but the sign bits of A and Sum are different

endmodule

