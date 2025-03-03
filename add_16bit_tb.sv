module add_16bit_tb();

logic [15:0] A, B, Sum, SumExpected;
logic sub;
wire overflow;
logic overflowExpected;

addsub_16bit DUT(.A(A), .B(B), .sub(sub), .Sum(Sum), .overflow(overflow));

initial begin
    for (A = 16'h0000; A < 4'b1111; A = A + 1)
    begin
        for (B = 16'h0000; B < 4'b1111; B = B + 1)
        begin
            //ADDITION
            sub = 0;
            #10 {overflowExpected, SumExpected} = A + B;
            if (overflowExpected != overflow) begin
                $display("Adding %h + %h failed! Overflow not equal to Expected. sub = %b, Sum = %h, SumExpected = %h, overflow = %b, overflowExpected = %b", A, B, sub, Sum, SumExpected, overflow, overflowExpected);
            end
            if (SumExpected != Sum) begin
                $display("Adding %h + %h failed! Result not equal to Expected. sub = %b, Sum = %h, SumExpected = %h, overflow = %b, overflowExpected = %b", A, B, sub, Sum, SumExpected, overflow, overflowExpected);
            end
            
            //SUBTRACTION
            sub = 1;
            #10 {overflowExpected, SumExpected} = A - B;
            if (overflowExpected != overflow) begin
                $display("Subtracting %h - %h failed! Overflow not equal to Expected. sub = %b, Sum = %h, SumExpected = %h, overflow = %b, overflowExpected = %b", A, B, sub, Sum, SumExpected, overflow, overflowExpected);
            end
            if (SumExpected != Sum) begin
                $display("Subtracting %h - %h failed! Result not equal to Expected. sub = %b, Sum = %h, SumExpected = %h, overflow = %b, overflowExpected = %b", A, B, sub, Sum, SumExpected, overflow, overflowExpected);
            end
        end
    end
end
endmodule