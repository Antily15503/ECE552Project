module forwarding_unit(
    input MemWB_RegWrite,
    input MemWB_RD,
    input EXMem_RegWrite,   // EX/MEM.RegWrite 
    input EXMem_Rd,         // EX/MEM.RegisterRd
    input IDEX_Rs,          // ID/EX.RegisterRs
    input IDEX_Rt,          // ID/EX.RegisterRt
    input EXMem_Rt,         // EX/MEM.RegisterRt

    output [1:0] ForwardA, ForwardB
    output ForwardC,
);

//MEM to EX forwarding
//assign ForwardA[0] = MemWB_RegWrite & (MemWB_RD != 4'h0) & !(EXMem_RegWrite & (EXMem_Rd != 4'h0) & (EXMem_Rd != IDEX_Rs)) & (MemWB_RegWrite == IDEX_Rs);
//assign ForwardB[0] = MemWB_RegWrite & (MemWB_RD != 4'h0) & !(EXMem_RegWrite & (EXMem_Rd != 4'h0) & (EXMem_Rd != IDEX_Rt)) & (MemWB_RegWrite == IDEX_Rt);

//EX TO EX
// if (EX/MEM.RegWrite
//     and (EX/MEM.RegisterRd ≠ 0)
//     and (EX/MEM.RegisterRd = ID/EX.RegisterRs)) then
//     ForwardA = 10  // Forward from EX/MEM pipeline register

//MEM TO MEM
// if ( MEM/WB.RegWrite and (MEM/WB.RegisterRd ≠ 0)
// and (MEM/WB.RegisterRd = EX/MEM.RegisterRt)
// ) enable MEM-to-MEM forwarding;


assign ForwardA = (EXMem_RegWrite & (EXMem_Rd != 4'h0) &    //EX-to-EX forwarding logic
                    (EXMem_Rd) == IDEX_Rs) ? 2'b10:
                  (MemWB_RegWrite & (MemWB_RD != 4'h0) &    //MEM-to-EX forwarding logic
                    !(EXMem_RegWrite & (EXMem_Rd != 4'h0) &
                    (EXMem_Rd != IDEX_Rs)) &
                    (MemWB_RegWrite == IDEX_Rs)) ? 2'b01:
                  2'b00;                                    //No Forwarding

assign ForwardB = (EXMem_RegWrite & (EXMem_Rd != 4'h0) &    //EX-to-EX forwarding logic
                    (EXMem_Rd) == IDEX_Rs) ? 2'b10:
                  (MemWB_RegWrite & (MemWB_RD != 4'h0) &    //MEM-to-EX forwarding logic
                    !(EXMem_RegWrite & (EXMem_Rd != 4'h0) &
                    (EXMem_Rd != IDEX_Rs)) &
                    (MemWB_RegWrite == IDEX_Rs)) ? 2'b01:
                  2'b00;                                    //No Forwarding

//MEM-to-MEM forwarding logic
assign ForwardC = (MemWB_RegWrite & (MemWB_RD != 4'h0) & (MemWB_RD) == EXMem_Rt);

endmodule

