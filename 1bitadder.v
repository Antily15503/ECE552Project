module full_adder_1bit (
    input a,        // 1-bit input A
    input b,        // 1-bit input B
    input cin,      // Carry in
    output sum,     // Sum
    output cout     // Carry out
);
    assign sum = a ^ b ^ cin;  // XOR produces the sum bit
    assign cout = (a & b) | (a & cin) | (b & cin);  // Carry out logic
endmodule
