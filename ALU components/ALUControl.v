module ALUControl(
    input [3:0] Opcode, 
    input [15:0] adder_out, xor_out, shift_out, red_out, paddsub_out, ALU_In1, ALU_In2,
    output reg [15:0] ALU_Out,
    output reg sub,
    output reg zeroEnable,
    output reg overflowEnable,
    output reg negEnable
);
    always @(*) begin
        casex(Opcode)
            4'b0000: begin
                ALU_Out = adder_out;   // ADD
                sub = 1'b0;
                zeroEnable = 1'b1;
                overflowEnable = 1'b1;
                negEnable = 1'b1;
            end
            4'b0001: begin
                ALU_Out = adder_out;   // SUB
                sub = 1'b1;
                zeroEnable = 1'b1;
                overflowEnable = 1'b1;
                negEnable = 1'b1;
            end
            4'b0010: begin 
                ALU_Out = xor_out;     // XOR
                zeroEnable = 1'b1;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
            end
            4'b0011: begin 
                ALU_Out = red_out;     // RED
                zeroEnable = 1'b0;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
            end
            4'b0100: begin 
                ALU_Out = shift_out;   // SLL
                zeroEnable = 1'b1;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
            end
            4'b0101: begin 
                ALU_Out = shift_out;   // SRA
                zeroEnable = 1'b1;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
            end
            4'b0110: begin 
                ALU_Out = shift_out;   // ROR
                zeroEnable = 1'b1;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
            end
            4'b0111: begin 
                ALU_Out = paddsub_out; // PADDSB
                zeroEnable = 1'b0;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
            end
            4'b100x: begin 
                ALU_Out = adder_out;   // MOV
                sub = 1'b0;
                zeroEnable = 1'b0;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
            end
            4'b1010: begin 
                zeroEnable = 1'b0;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
                ALU_Out = ((ALU_In1 & 16'hFF00) | ALU_In2[7:0]); //LLB
            end
            4'b1011: begin 
                zeroEnable = 1'b0;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
                ALU_Out = ((ALU_In1 & 16'h00FF) | ALU_In2[7:0]<<8); //LHB
            end
            4'b1110: begin
                zeroEnable = 1'b0;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
                ALU_Out = adder_out; //LLB
            end
            
            default: begin 
                zeroEnable = 1'b0;
                overflowEnable = 1'b0;
                negEnable = 1'b0;
                ALU_Out = 16'hFFFF;
            end
        endcase
    end

endmodule