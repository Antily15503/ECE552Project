`timescale 1ns / 1ps

module addsub_4bit_tb;
    
    // Inputs
    reg [3:0] a;
    reg [3:0] b;
    reg is_sub;
    
    // Outputs
    wire [3:0] sum;
    wire ovfl;
    
    // Instantiate the 4-bit adder-subtractor module
    addsub_4bit uut (
        .a(a), 
        .b(b), 
        .is_sub(is_sub), 
        .sum(sum), 
        .ovfl(ovfl)
    );

    initial begin
        // Test case 1: 5 + 3
        a = 4'b0101; b = 4'b0011; is_sub = 0;
        #10;
        $display("Test 1: %d + %d = %d, Overflow: %b", a, b, sum, ovfl);

        // Test case 2: 7 - 2
        a = 4'b0111; b = 4'b0010; is_sub = 1;
        #10;
        $display("Test 2: %d - %d = %d, Overflow: %b", a, b, sum, ovfl);

        // Test case 3: 8 - 9 (negative result)
        a = 4'b1000; b = 4'b1001; is_sub = 1;
        #10;
        $display("Test 3: %d - %d = %d, Overflow: %b", a, b, sum, ovfl);

        // Test case 4: Overflow case (7 + 7)
        a = 4'b0111; b = 4'b0111; is_sub = 0;
        #10;
        $display("Test 4: %d + %d = %d, Overflow: %b", a, b, sum, ovfl);

        // Test case 5: Overflow case (negative result)
        a = 4'b1000; b = 4'b0111; is_sub = 1;
        #10;
        $display("Test 5: %d - %d = %d, Overflow: %b", a, b, sum, ovfl);

        // Finish simulation
        $stop;
    end

endmodule
