module addsub_16bit_tb();
    reg [15:0] A,B;
    reg sub;
    wire [15:0] Sum;
    wire overflow;
   
    addsub_16bit iDUT(.A(A),.B(B),.sub(sub),.Sum(Sum),.overflow(overflow));

    reg [15:0] testSum;
    integer i;
    initial begin
        // A = 16'hFFFF;
        // B = 16'hFFFF;
        for(i = 1; i <= 20; i = i + 1)begin    
            A = $random % 16'hFFFF;
            B = $random % 16'hFFFF;
            sub = 0;
            #10

            testSum = A + B;
            $display("Test Sum: %h", testSum);
            $display("Test %0d: %h + %h = %h with ovfl: %b", i, A, B, Sum, overflow);
        end

        for(i = 20; i <= 40; i = i + 1)begin    
            A = $random % 16'hFFFF;
            B = $random % 16'hFFFF;
            sub = 1;
            #10

            testSum = A - B;
            $display("Test Sum: %h", testSum);
            $display("Test %0d: %h + %h = %h with ovfl: %b", i, A, B, Sum, overflow);
        end



    end



endmodule
