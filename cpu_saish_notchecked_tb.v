`timescale 1ns/1ps

module cpu_tb();

// Clock and Reset Signals
reg clk;
reg rst_n;

// CPU Outputs
wire [15:0] pc;
wire hlt;

// Instantiate CPU
cpu dut (
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc),
    .hlt(hlt)
);

// Clock Generation (50 MHz)
initial begin
    clk = 0;
    forever #10 clk = ~clk; // 20ns period = 50MHz
end

// Simulation Control
initial begin
    // Initialize and Reset
    rst_n = 0; // Active low reset
    #25; // Hold reset for 25ns (2.5 clock cycles)
    rst_n = 1;

    // Run until HLT is detected
    wait(hlt); // Wait for HLT instruction
    #50; // Allow final pipeline stages
    
    $display("HLT detected at PC = 0x%h", pc);
    $finish;
end

// PC Monitoring
always @(posedge clk) begin
    $display("[%0t] PC = 0x%04h", $time, pc);
end

// Timeout Safety
initial begin
    #500000; // 500µs timeout
    $display("Simulation timeout!");
    $finish;
end

endmodule
