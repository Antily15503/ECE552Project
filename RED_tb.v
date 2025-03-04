module RED_tb();
    reg [15:0] A,B;
    wire [15:0] Sum;

    RED iDUT(.A(A),.B(B),.Sum(Sum));

    integer i;
    reg [7:0] a,b,c,d,e,f,g,h;
    reg [15:0] testSum;

    initial begin
        // A = 16'hFFFF;
        // B = 16'hFFFF;
        // a = A[15:12];
        // b = A[11:8];
        // c = A[7:4];
        // d = A[3:0];
        // e = B[15:12];
        // f = B[11:8];
        // g = B[7:4];
        // h = B[3:0];
        // #10
        // testSum = (a+e)+(b+f)+(c+g)+(d+h);
        // $display("TestSum: %h", testSum);
        // $display("Test 1: %h + %h = %h", A,B,Sum);
        // $stop();
        for(i = 1; i <= 20; i = i + 1)begin
            A = $random % 16'hFFFF;
            B = $random % 16'hFFFF;

            a = A[15:12];
            b = A[11:8];
            c = A[7:4];
            d = A[3:0];
            e = B[15:12];
            f = B[11:8];
            g = B[7:4];
            h = B[3:0];
            #10
            
            testSum = (a+e)+(b+f)+(c+g)+(d+h);
        
            $display("Test %0d: Expected: %h, Got: %h", i,testSum,Sum);
            if(testSum !== Sum)begin
                $display("ERR: Test %0d",i);
            end

        end
    end

endmodule
