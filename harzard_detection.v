module hazard_detection( // 
    //load to use signals
    input IDEX_MemToReg,           // ID/EX.MemReg
    input [3:0] IDEX_Rd,           // ID/EX.RegisterRd 
    input [3:0] IFID_Rs,           // IF/ID.RegisterRs
    input [3:0] IFID_Rt,           // IF/ID.RegisterRt
    input IDEX_RegWrite,
    output stall
);
    
    assign stall = IDEX_RegWrite & IDEX_MemToReg & ((IDEX_Rd == IFID_Rs) | (IDEX_Rd == IFID_Rt)) & (IDEX_Rd != 0);
    
    

endmodule
