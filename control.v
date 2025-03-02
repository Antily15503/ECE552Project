module control(
    input [3:0] opcode,
    output [2:0] AluOp,
    output RegDst, Branch, MemRead, MemtoReg, ALUSrc, MemWrite, RegWrite, PC, Halt
);

wire regd, branch, memr, memtr, alus, memw, regw, pc, halt;

case (opcode)
    4'b0xxx: begin //ALL ALU INSTRUCTIONS
        assign regd = 1'b1;
        assign branch = 1'b0;
        assign memr = 1'b0;
        assign memtr = 1'b0;
        assign alus = 1'b1;
        assign memw = 1'b0;
        assign regw = 1'b1;
        assign pc = 1'b0;
        assign halt = 1'b0;
    end
    4'b1000: begin //Mem Load
        assign regd = 1'b0;
        assign branch = 1'b0;
        assign memr = 1'b1;
        assign memtr = 1'b1;
        assign alus = 1'b0;
        assign memw = 1'b0;
        assign regw = 1'b1;
        assign pc = 1'b0;
        assign halt = 1'b0;
    end
    4'b1001: begin //Mem Store
        assign regd = 1'b0;
        assign branch = 1'b0;
        assign memr = 1'b0;
        assign memtr = 1'b0;
        assign alus = 1'b0;
        assign memw = 1'b1;
        assign regw = 1'b0;
        assign pc = 1'b0;
        assign halt = 1'b0;
    end
    4'b1010: begin //Mem Load Lower Byte

    end
    4'b1011: begin //Mem Load Upper Byte

    end
    4'b1100: begin //Branch Relative (B)


    end
    4'b1101: begin //Branch Absolute (B)

    end
    4'b1110: begin //Save Program Counter (PCS)
        assign regd = 1'b0;
        assign branch = 1'b0;
        assign memr = 1'b0;
        assign memtr = 1'b0;
        assign alus = 1'b0;
        assign memw = 1'b0;
        assign regw = 1'b0;
        assign pc = 1'b1;
        assign halt = 1'b0;
    end
    4'b1111: begin //Halt
        assign regd = 1'b0;
        assign branch = 1'b0;
        assign memr = 1'b0;
        assign memtr = 1'b0;
        assign alus = 1'b0;
        assign memw = 1'b0;
        assign regw = 1'b0;
        assign pc = 1'b0;
        assign halt = 1'b1;
    end



endcase


endmodule