module hazard_detection( // 
    //load to use signals
    input IDEX_MemRead,     // ID/EX.MemRead
    input IDEX_Rd,          // ID/EX.RegisterRd 
    input IFID_Rs,           // IF/ID.RegisterRs
    input IFID_Rt,           // IF/ID.RegisterRt
    output stall
);
    
    //REQUIRES FLUSHING//
    assign stall = MemRead & ((IDEX_Rd == IFID_Rs) | (IDEX_Rd == IFID_Rt)) & (IDEX_Rd != 0);

endmodule
