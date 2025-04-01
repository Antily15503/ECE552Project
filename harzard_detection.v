module hazard_detection(input MemRead, input IDEX_Rt, input IFID_Rs, input IFID_Rt, output stall);
    assign stall = MemRead & ((IDEX_Rt == IFID_Rs) | (IDEX_Rt == IFID_Rt));

endmodule
