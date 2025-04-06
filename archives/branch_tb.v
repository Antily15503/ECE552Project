module branch_tb();

    reg [2:0] Conditions, Flags;
    reg [8:0] I;
    reg [15:0] pcIn, branchReg;
    wire [15:0] pcOut;
    reg branchRegMux;

    branch iDUT(.condition(Conditions),.Flags(Flags),.I(I),.pcIn(pcIn),.branchReg(branchReg),.branchRegMux(branchRegMux),.pcOut(pcOut));

    initial begin
        pcIn = 16'h0000;
        Conditions = 3'b111;
        Flags = 3'b000;
        I = 9'b000000000;
        branchReg = 16'h0000;
        branchRegMux = 1'b0;
        #10

        if (pcOut == pcIn + 2)begin
            $display("Test Passed");
        end else begin
            $display("Test Failed");
        end
        $stop();


    end

endmodule