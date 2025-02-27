module full_adder_1bit (
    input A, B, cin,
    output S, cout
);
    //Full Adder Implementation for one bit

    assign S = A ^ B ^ cin;
    assign cout = ( A & B ) | ( (A ^ B) & cin); 
    //Note: cout gets asserted if:
    //A, B are both equal to 1 (generate)
    //only 1 signal (either A or B) is 1, and cin is 1 (propagate)

endmodule