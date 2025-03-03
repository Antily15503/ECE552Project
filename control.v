module control(
    input [3:0] opcode,
    output RegDst, Branch, BranchReg, MemRead, MemtoReg, AluSrc, MemWrite, MemHalf, RegWrite, PC, Halt
);

reg regd, branch, branchr, memr, memtr, memh, alusrc, memw, regw, pc, halt;

always @(*) begin
    casex (opcode)
        4'b0xxx: begin //ALL ALU INSTRUCTIONS
            regd = 1'b1;
            branch = 1'b0;
            branchr = 1'b0;
            memr = 1'b0;
            memtr = 1'b0;
            memh = 1'b0;
            alusrc = 1'b1;
            memw = 1'b0;
            regw = 1'b1;
            pc = 1'b0;
            halt = 1'b0;
        end
        4'b1000: begin //Mem Load
            regd = 1'b0;
            branch = 1'b0;
            branchr = 1'b0;
            memr = 1'b1;
            memtr = 1'b1;
            memh = 1'b0;
            alusrc = 1'b0;
            memw = 1'b0;
            regw = 1'b1;
            pc = 1'b0;
            halt = 1'b0;
        end
        4'b1001: begin //Mem Store
            regd = 1'b0;
            branch = 1'b0;
            branchr = 1'b0;
            memr = 1'b0;
            memtr = 1'b0;
            memh = 1'b0;
            alusrc = 1'b0;
            memw = 1'b1;
            regw = 1'b0;
            pc = 1'b0;
            halt = 1'b0;
        end
        4'b1010: begin //Register Update Lower Byte
            regd = 1'b0;
            branch = 1'b0;
            branchr = 1'b0;
            memr = 1'b0;
            memtr = 1'b0;
            memh = 1'b1;
            alusrc = 1'b0;
            memw = 1'b0;
            regw = 1'b1;
            pc = 1'b0;
            halt = 1'b0;
        end
        4'b1011: begin //Register Update Upper Byte
            regd = 1'b0;
            branch = 1'b0;
            branchr = 1'b0;
            memr = 1'b0;
            memtr = 1'b0;
            memh = 1'b1;
            alusrc = 1'b0;
            memw = 1'b0;
            regw = 1'b1;
            pc = 1'b0;
            halt = 1'b0;
        end
        4'b1100: begin //Branch Relative (B)
            regd = 1'b0;
            branch = 1'b1;
            branchr = 1'b0;
            memr = 1'b0;
            memtr = 1'b0;
            alusrc = 1'b0;
            memh = 1'b0;
            memw = 1'b0;
            regw = 1'b0;
            pc = 1'b0;
            halt = 1'b0;
        end
        4'b1101: begin //Branch through Register (BR)
            regd = 1'b0;
            branch = 1'b1;
            branchr = 1'b1;
            memr = 1'b0;
            memtr = 1'b0;
            alusrc = 1'b0;
            memh = 1'b0;
            memw = 1'b0;
            regw = 1'b0;
            pc = 1'b0;
            halt = 1'b0;
        end
        4'b1110: begin //Save Program Counter (PCS)
            regd = 1'b0;
            branch = 1'b0;
            branchr = 1'b0;
            memr = 1'b0;
            memtr = 1'b0;
            alusrc = 1'b0;
            memh = 1'b0;
            memw = 1'b0;
            regw = 1'b0;
            pc = 1'b1;
            halt = 1'b0;
        end
        4'b1111: begin //Halt
            regd = 1'b0;
            branch = 1'b0;
            branchr = 1'b0;
            memr = 1'b0;
            memtr = 1'b0;
            alusrc = 1'b0;
            memh = 1'b0;
            memw = 1'b0;
            regw = 1'b0;
            pc = 1'b0;
            halt = 1'b1;
        end
        default: begin
            regd = 1'b0;
            branch = 1'b0;
            branchr = 1'b0;
            memr = 1'b0;
            memtr = 1'b0;
            alusrc = 1'b0;
            memh = 1'b0;
            memw = 1'b0;
            regw = 1'b0;
            pc = 1'b0;
            halt = 1'b0;
        end
    endcase
end
assign RegDst = regd;
assign Branch = branch;
assign BranchReg = branchr;
assign MemRead = memr;
assign MemtoReg = memtr;
assign AluSrc = alusrc;
assign MemWrite = memw;
assign RegWrite = regw;
assign PC = pc;
assign Halt = halt;
assign MemHalf = memh;
endmodule