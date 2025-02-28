// Testbench for psa_16bit

module psa_16bit_tb;

reg [15:0] A, B;
wire [15:0] SUM;
wire ERROR;

// Instantiate DUT
psa_16bit iDUT (.a(A), .b(B), .sum(SUM), .error(ERROR));

// Define test vectors
reg [15:0] test_vectors [0:7];
integer i;

initial begin
    // Initializing test cases
    test_vectors[0] = 16'h1234; test_vectors[1] = 16'h4321;
    test_vectors[2] = 16'h5678; test_vectors[3] = 16'h8765;
    test_vectors[4] = 16'h9ABC; test_vectors[5] = 16'hCBA9;
    test_vectors[6] = 16'hFFFF; test_vectors[7] = 16'h0001;

    for (i = 0; i < 4; i = i + 1) begin
        A = test_vectors[i];
        B = test_vectors[i+1];
        #10;
        $display("Test %0d: A=%h, B=%h, SUM=%h, ERROR=%b", i, A, B, SUM, ERROR);
    end

    $stop;
end

endmodule