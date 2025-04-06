module hazard_detection( // 
    //load to use signals
    input IDEX_MemRead,     // ID/EX.MemRead
    input [3:0] IDEX_Rd,          // ID/EX.RegisterRd 
    input [15:0] IFID_Rs,           // IF/ID.RegisterRs
    input [15:0] IFID_Rt,           // IF/ID.RegisterRt
    input IFID_MemWrite,
    output stall
);
    
    //REQUIRES FLUSHING//
    assign stall = IDEX_MemRead & ((IDEX_Rd == IFID_Rs) | (IDEX_Rd == IFID_Rt)) & (IDEX_Rd != 0);

    

endmodule
