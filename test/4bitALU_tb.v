`timescale 1ns / 1ps

module alu_4bit_tb;

    // Inputs
    reg [3:0] a, b;
    reg [2:0] op;  // Assuming 3-bit opcode for different operations

    // Outputs
    wire [3:0] result;
    wire ovfl, zero;

    // Instantiate the ALU module
    alu_4bit uut (
        .a(a), 
        .b(b), 
        .op(op), 
        .result(result), 
        .ovfl(ovfl),
        .zero(zero)
    );

    initial begin
        // Test case 1: Addition (5 + 3)
        a = 4'b0101; b = 4'b0011; op = 3'b000;
        #10;
        $display("Test 1: %d + %d = %d, Overflow: %b, Zero: %b", a, b, result, ovfl, zero);

        // Test case 2: Subtraction (7 - 2)
        a = 4'b0111; b = 4'b0010; op = 3'b001;
        #10;
        $display("Test 2: %d - %d = %d, Overflow: %b, Zero: %b", a, b, result, ovfl, zero);

        // Test case 3: AND operation
        a = 4'b1101; b = 4'b1011; op = 3'b010;
        #10;
        $display("Test 3: %b & %b = %b", a, b, result);

        // Test case 4: OR operation
        a = 4'b1101; b = 4'b1011; op = 3'b011;
        #10;
        $display("Test 4: %b | %b = %b", a, b, result);

        // Test case 5: XOR operation
        a = 4'b1101; b = 4'b1011; op = 3'b100;
        #10;
        $display("Test 5: %b ^ %b = %b", a, b, result);

        // Test case 6: Multiplication (2 * 3)
        a = 4'b0010; b = 4'b0011; op = 3'b101;
        #10;
        $display("Test 6: %d * %d = %d, Overflow: %b", a, b, result, ovfl);

        // Test case 7: Zero result check (Subtract same numbers)
        a = 4'b1010; b = 4'b1010; op = 3'b001;
        #10;
        $display("Test 7: %d - %d = %d, Zero: %b", a, b, result, zero);

        // Finish simulation
        $stop;
    end

endmodule
