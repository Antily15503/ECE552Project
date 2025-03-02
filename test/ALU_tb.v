module ALU_tb();

    // Inputs
    reg [15:0] ALU_In1, ALU_In2;
    reg [2:0] Opcode;
    
    // Outputs
    wire [15:0] ALU_Out;
    wire [2:0] Flags; // {Z, V, N}
    
    // Instantiate the ALU
    ALU dut (
        .ALU_In1(ALU_In1),
        .ALU_In2(ALU_In2),
        .Opcode(Opcode),
        .ALU_Out(ALU_Out),
        .Flags(Flags)
    );
    
    // Declare variables for test cases
    integer i;
    reg [15:0] expected_out;
    reg [2:0] expected_flags;
    
    // Function to check results and print test status
    task check_result;
        input [15:0] exp_out;
        input [2:0] exp_flags;
        input [127:0] test_name;
        begin
            if ((ALU_Out === exp_out) && (Flags === exp_flags)) begin
                $display("PASS: %s - Out: 0x%h, Flags: %b", test_name, ALU_Out, Flags);
            end else begin
                $display("FAIL: %s", test_name);
                $display("  Expected: Out=0x%h, Flags=%b", exp_out, exp_flags);
                $display("  Got:      Out=0x%h, Flags=%b", ALU_Out, Flags);
            end
        end
    endtask
    
    // Variable declarations
    reg [15:0] result_add, result_sub, result_xor;
    reg overflow_add, overflow_sub;
    reg negative_add, negative_sub;
    reg zero_add, zero_sub, zero_xor, zero_shift;
    
    initial begin
        $display("Starting ALU Tests");
        
        // ------------------------
        // Test ADD (Opcode = 000)
        // ------------------------
        $display("\nTesting ADD operation (Opcode = 000)");
        
        // Normal addition (positive + positive = positive, no overflow)
        ALU_In1 = 16'h0123; ALU_In2 = 16'h0456; Opcode = 3'b000;
        result_add = ALU_In1 + ALU_In2;
        overflow_add = 0; // No overflow
        negative_add = result_add[15]; // Check sign bit
        zero_add = (result_add == 16'h0000); // Check if zero
        expected_out = result_add;
        expected_flags = {zero_add, overflow_add, negative_add};
        #10 check_result(expected_out, expected_flags, "ADD: Positive + Positive");
        
        // Negative + Negative = Negative, no overflow
        ALU_In1 = 16'hF123; ALU_In2 = 16'hF456; Opcode = 3'b000;
        result_add = ALU_In1 + ALU_In2;
        // Check for overflow with signed numbers
        overflow_add = (ALU_In1[15] == ALU_In2[15]) && (ALU_In1[15] != result_add[15]);
        negative_add = result_add[15];
        zero_add = (result_add == 16'h0000);
        expected_out = result_add;
        expected_flags = {zero_add, overflow_add, negative_add};
        #10 check_result(expected_out, expected_flags, "ADD: Negative + Negative");
        
        // Test overflow: Large positive + positive = overflow
        ALU_In1 = 16'h7FFF; ALU_In2 = 16'h0001; Opcode = 3'b000;
        // Checking for saturation (your ALU should saturate to 0x7FFF)
        expected_out = 16'h7FFF; // Saturated to max positive
        expected_flags = {1'b0, 1'b1, 1'b0}; // Z=0, V=1, N=0
        #10 check_result(expected_out, expected_flags, "ADD: Positive overflow with saturation");
        
        // Test underflow: Large negative + negative = underflow
        ALU_In1 = 16'h8000; ALU_In2 = 16'hFFFF; Opcode = 3'b000;
        // Checking for saturation (your ALU should saturate to 0x8000)
        expected_out = 16'h8000; // Saturated to min negative
        expected_flags = {1'b0, 1'b1, 1'b1}; // Z=0, V=1, N=1
        #10 check_result(expected_out, expected_flags, "ADD: Negative overflow with saturation");
        
        // Test Zero result
        ALU_In1 = 16'h0000; ALU_In2 = 16'h0000; Opcode = 3'b000;
        expected_out = 16'h0000;
        expected_flags = {1'b1, 1'b0, 1'b0}; // Z=1, V=0, N=0
        #10 check_result(expected_out, expected_flags, "ADD: Zero result");
        
        // ------------------------
        // Test SUB (Opcode = 001)
        // ------------------------
        $display("\nTesting SUB operation (Opcode = 001)");
        
        // Normal subtraction (positive - smaller positive = positive)
        ALU_In1 = 16'h0456; ALU_In2 = 16'h0123; Opcode = 3'b001;
        result_sub = ALU_In1 - ALU_In2;
        overflow_sub = 0; // No overflow
        negative_sub = result_sub[15];
        zero_sub = (result_sub == 16'h0000);
        expected_out = result_sub;
        expected_flags = {zero_sub, overflow_sub, negative_sub};
        #10 check_result(expected_out, expected_flags, "SUB: Positive - Smaller Positive");
        
        // Positive - Larger positive = Negative
        ALU_In1 = 16'h0123; ALU_In2 = 16'h0456; Opcode = 3'b001;
        result_sub = ALU_In1 - ALU_In2;
        overflow_sub = 0;
        negative_sub = result_sub[15];
        zero_sub = (result_sub == 16'h0000);
        expected_out = result_sub;
        expected_flags = {zero_sub, overflow_sub, negative_sub};
        #10 check_result(expected_out, expected_flags, "SUB: Positive - Larger Positive");
        
        // Test overflow: Largest positive - negative = overflow
        ALU_In1 = 16'h7FFF; ALU_In2 = 16'h8000; Opcode = 3'b001;
        // This should overflow positively and saturate
        expected_out = 16'h7FFF; // Saturated to max positive
        expected_flags = {1'b0, 1'b1, 1'b0}; // Z=0, V=1, N=0
        #10 check_result(expected_out, expected_flags, "SUB: Positive overflow with saturation");
        
        // Test underflow: Largest negative - positive = underflow
        ALU_In1 = 16'h8000; ALU_In2 = 16'h0001; Opcode = 3'b001;
        // This should overflow negatively and saturate
        expected_out = 16'h8000; // Saturated to min negative
        expected_flags = {1'b0, 1'b1, 1'b1}; // Z=0, V=1, N=1
        #10 check_result(expected_out, expected_flags, "SUB: Negative overflow with saturation");
        
        // Test Zero result
        ALU_In1 = 16'h0123; ALU_In2 = 16'h0123; Opcode = 3'b001;
        expected_out = 16'h0000;
        expected_flags = {1'b1, 1'b0, 1'b0}; // Z=1, V=0, N=0
        #10 check_result(expected_out, expected_flags, "SUB: Zero result");
        
        // ------------------------
        // Test XOR (Opcode = 010)
        // ------------------------
        $display("\nTesting XOR operation (Opcode = 010)");
        
        // XOR with non-zero result
        ALU_In1 = 16'hAAAA; ALU_In2 = 16'h5555; Opcode = 3'b010;
        result_xor = ALU_In1 ^ ALU_In2;
        zero_xor = (result_xor == 16'h0000);
        expected_out = result_xor;
        expected_flags = {zero_xor, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "XOR: Non-zero result");
        
        // XOR with zero result
        ALU_In1 = 16'hAAAA; ALU_In2 = 16'hAAAA; Opcode = 3'b010;
        result_xor = ALU_In1 ^ ALU_In2;
        zero_xor = (result_xor == 16'h0000);
        expected_out = result_xor;
        expected_flags = {zero_xor, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "XOR: Zero result");
        
        // ------------------------
        // Test RED (Opcode = 011)
        // ------------------------
        $display("\nTesting RED operation (Opcode = 011)");
        
        // Simple case with all 0s (should produce 0)
        ALU_In1 = 16'h0000; ALU_In2 = 16'h0000; Opcode = 3'b011;
        expected_out = 16'h0000;
        expected_flags = {1'b1, 1'b0, 1'b0}; // Z=1, V=0, N=0
        #10 check_result(expected_out, expected_flags, "RED: All zeros");
        
        // Simple case with 1s in each nibble
        ALU_In1 = 16'h1111; ALU_In2 = 16'h1111; Opcode = 3'b011;
        // Expected: 1+1+1+1+1+1+1+1 = 8 (sign extended to 16'h0008)
        expected_out = 16'h0008;
        expected_flags = {1'b0, 1'b0, 1'b0}; // Z=0, V=0, N=0
        #10 check_result(expected_out, expected_flags, "RED: Simple addition");
        
        // Mixed case
        ALU_In1 = 16'h123F; ALU_In2 = 16'h456A; Opcode = 3'b011;
        // Expected: 1+4+2+5+3+6+F+A = 2E (sign extended to 16'h002E)
        expected_out = 16'h002E;
        expected_flags = {1'b0, 1'b0, 1'b0}; // Z=0, V=0, N=0
        #10 check_result(expected_out, expected_flags, "RED: Mixed values");
        
        // ------------------------
        // Test SLL (Opcode = 100)
        // ------------------------
        $display("\nTesting SLL operation (Opcode = 100)");
        
        // Shift left by 4
        ALU_In1 = 16'h1234; ALU_In2 = 16'h0004; Opcode = 3'b100;
        expected_out = 16'h2340;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "SLL: Shift by 4");
        
        // Shift left by 8
        ALU_In1 = 16'h1234; ALU_In2 = 16'h0008; Opcode = 3'b100;
        expected_out = 16'h3400;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "SLL: Shift by 8");
    
        
        // ------------------------
        // Test SRA (Opcode = 101)
        // ------------------------
        $display("\nTesting SRA operation (Opcode = 101)");
        
        // Shift right arithmetic positive number
        ALU_In1 = 16'h1234; ALU_In2 = 16'h0004; Opcode = 3'b101;
        expected_out = 16'h0123;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "SRA: Positive number shift by 4");
        
        // Shift right arithmetic negative number
        ALU_In1 = 16'h8234; ALU_In2 = 16'h0004; Opcode = 3'b101;
        expected_out = 16'hF823;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "SRA: Negative number shift by 4");
        
        // Shift until small value
        ALU_In1 = 16'h0010; ALU_In2 = 16'h0004; Opcode = 3'b101;
        expected_out = 16'h0001;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "SRA: Shift until small value");
        
        // Shift until zero
        ALU_In1 = 16'h0001; ALU_In2 = 16'h0004; Opcode = 3'b101;
        expected_out = 16'h0000;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "SRA: Shift until zero");
        
        // ------------------------
        // Test ROR (Opcode = 110)
        // ------------------------
        $display("\nTesting ROR operation (Opcode = 110)");
        
        // Rotate right by 4
        ALU_In1 = 16'h1234; ALU_In2 = 16'h0004; Opcode = 3'b110;
        expected_out = 16'h4123;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "ROR: Rotate by 4");
        
        // Rotate right by 8
        ALU_In1 = 16'h1234; ALU_In2 = 16'h0008; Opcode = 3'b110;
        expected_out = 16'h3412;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "ROR: Rotate by 8");
        
        // Rotate right by 16 (should be same as input)
        ALU_In1 = 16'h1234; ALU_In2 = 16'h0010; Opcode = 3'b110;
        expected_out = 16'h1234;
        zero_shift = (expected_out == 16'h0000);
        expected_flags = {zero_shift, 1'b0, 1'b0}; // Only Z flag should change
        #10 check_result(expected_out, expected_flags, "ROR: Rotate by 16");
        
        // ------------------------
        // Test PADDSB (Opcode = 111)
        // ------------------------
        $display("\nTesting PADDSB operation (Opcode = 111)");
        
        // Simple addition (no saturation)
        ALU_In1 = 16'h1234; ALU_In2 = 16'h1111; Opcode = 3'b111;
        // 1+1=2, 2+1=3, 3+1=4, 4+1=5 → 0x2345
        expected_out = 16'h2345;
        expected_flags = {1'b0, 1'b0, 1'b0}; // Flags should not change
        #10 check_result(expected_out, expected_flags, "PADDSB: Simple addition");
        
        // Test with saturation (positive overflow)
        ALU_In1 = 16'h7777; ALU_In2 = 16'h1111; Opcode = 3'b111;
        // 7+1=8(0x8 overflows to 0x7), 7+1=8, 7+1=8, 7+1=8 → 0x7777
        expected_out = 16'h7777;
        expected_flags = {1'b0, 1'b0, 1'b0}; // Flags should not change
        #10 check_result(expected_out, expected_flags, "PADDSB: Positive saturation");
        
        // Test with saturation (negative overflow)
        ALU_In1 = 16'h8888; ALU_In2 = 16'h8888; Opcode = 3'b111;
        // 8(-8)+8(-8)=0x8(-8 saturated), 8+8=0x8, 8+8=0x8, 8+8=0x8 → 0x8888
        expected_out = 16'h8888;
        expected_flags = {1'b0, 1'b0, 1'b0}; // Flags should not change
        #10 check_result(expected_out, expected_flags, "PADDSB: Negative saturation");
        
        // Test with mixed values
        ALU_In1 = 16'h7389; ALU_In2 = 16'h2F78; Opcode = 3'b111;
        // 7+2=9(overflows to 0x7), 3+F=0x2, 8+7=0xF, 9+8=0x11(overflows to 0x8) → 0x72F8
        expected_out = 16'h72F8;
        expected_flags = {1'b0, 1'b0, 1'b0}; // Flags should not change
        #10 check_result(expected_out, expected_flags, "PADDSB: Mixed values");
        
        $display("\nALL ALU TESTS COMPLETED");
        $stop;
    end

endmodule