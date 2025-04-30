`default_nettype none
module arbiter(
    input clk, rst_n, // clock and reset signals
    input dmem_read, dmem_write, // data memory read and write signals
    input [15:0] dmem_address, // address to be read from or written to
    input [15:0] dmem_data, // data to be written to memory
    input imem_read, imem_write, // instruction memory read and write signals
    input [15:0] imem_address, // address to be read from or written to

    output dmem_data_valid, imem_data_valid, // data valid signals to cache to toggle which cache is active
    output dmem_write_done, imem_write_done, // write done signals to cache to signal when cache is done writing
    
);

// ######## STATE MACHINE SIGNALS FOR THE ARBITER #########
// 00: IDLE
// 01: DMEM_READ
// 10: IMEM_READ
// 11: DMEM_WRITE
wire [1:0] state_ff, next_state_ff; 

dff state_flop [1:0] (
    .d(next_state_ff),
    .q(state_ff),
    .wen(1'b1),
    .clk(clk),
    .rst(~rst_n)
);

// State machine signals
reg [1:0] state, next_state;
//State machine logic
always (*) begin
    //default values
    case (state)
        00: begin // IDLE
            // TODO: set up idle logic
        end

        01: begin // DMEM_READ
            next_state = (~)

        end
    endcase

end
// State machine assigns
assign state_ff = state;
assign next_state_ff = next_state;

endmodule
`default_nettype wire