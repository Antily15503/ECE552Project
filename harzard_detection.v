module hazard_detection( // 
    //load to use signals
    input clk, rst_n,
    input [3:0] instr,
    input branch,
    input IDEX_MemToReg,           // ID/EX.MemReg
    input [3:0] IDEX_Rd,           // ID/EX.RegisterRd 
    input [3:0] IFID_Rs,           // IF/ID.RegisterRs
    input [3:0] IFID_Rt,           // IF/ID.RegisterRt
    input IDEX_RegWrite,
    output stall
);
    
    assign stall1 = IDEX_RegWrite & IDEX_MemToReg & ((IDEX_Rd == IFID_Rs) | (IDEX_Rd == IFID_Rt)) & (IDEX_Rd != 0);
    assign stall2 = IDEX_MemToReg & (IDEX_Rd != 0) & (IFID_Rs == IDEX_Rd) && (instr == 4'hD) && branch;
    wire stallstate;
    dff state(
        .clk(clk),
        .rst(rst_n),
        .d(~stallstate & stall2),
        .q(stallstate),
        .wen(1'b1)
    );

    assign stall = stall2 | stall1 | stallstate;
endmodule
