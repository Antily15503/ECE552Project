`default_nettype none
module arbiter(
    input clk, rst_n, // clock and reset signals
    input valid, // data valid signal from data memory
    input [15:0] dmem_address, // address to be read from or written to
    input [15:0] dmem_data, // data to be written to memory
    input imem_read, imem_write, // instruction memory read and write signals
    input [15:0] imem_address, // address to be read from or written to

    output dmem_data_valid, imem_data_valid, // data valid signals to cache to toggle which cache is active
    output dmem_write_done, imem_write_done, // write done signals to cache to signal when cache is done writing
    output [15:0] memory_address, // address to be read from or written to memory
    output [15:0] memory_data, // data from memory to be passed to either caches
    output enable, // signal that enables the memory module
    output wr, //toggles between reading and writing to memory. 1 = write, 0 = read
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
reg [15:0] address_sm;
reg enable_sm, wr_sm, dmem_data_valid_sm, imem_data_valid_sm, dmem_write_done_sm, imem_write_done_sm;
//State machine logic
always (*) begin
    //default values
    case (state)
        00: begin // IDLE
            // TODO: set up idle logic
            //asserting memory signals for idle state
            address = 16'h0000; // address is not used in idle state
            enable = 1'b0; // memory is not enabled in idle state
            wr = 1'b0; // memory set to read as default

            //passing data memory signals to cache
            dmem_data_valid = 1'b0; // data valid signal for data memory
            imem_data_valid = 1'b0; // data valid signal for instruction memory
            dmem_write_done = 1'b0; // write done signal for data memory
            imem_write_done = 1'b0; // write done signal for instruction memory

            //state transition logic
            assign next_state = (dmem_read) ? 2'b01 : // if dmem_read is true, go to DMEM_READ state
                            (imem_read) ? 2'b10 : // if imem_read is true and dmem_read is false, go to IMEM_READ state
                            (dmem_write) ? 2'b11 : // if dmem_write is true and everything else is false, go to DMEM_WRITE state
                            2'b00; // otherwise stay in IDLE state
        end

        01: begin // DMEM_READ
            //asserting memory signals for reading data memory
            address = dmem_address; // data memory address to be read from
            enable = 1'b1;
            wr = 1'b0; // wr = read operation

            //passing data memory signals to cache
            dmem_data_valid = valid; // data valid signal for data memory
            imem_data_valid = 1'b0; // data valid signal for instruction memory
            dmem_write_done = 1'b0; // write done signal for data memory
            imem_write_done = 1'b0; // write done signal for instruction memory

            //state transition logic and transition signal assertions
            next_state = (dmem_read) ? 2'b01 : 2'b00; // if dmem_read is true, stay in DMEM_READ state, otherwise go to IDLE state

        end
        10: begin // IMEM_READ
            //asserting memory signals for reading instruction memory
            address = imem_address; // instruction memory address to be read from
            enable = 1'b1;
            wr = 1'b0; // wr = read operation

            //passing data memory signals to cache
            dmem_data_valid = 1'b0; // data valid signal for data memory
            imem_data_valid = valid; // data valid signal for instruction memory
            dmem_write_done = 1'b0; // write done signal for data memory
            imem_write_done = 1'b0; // write done signal for instruction memory

            //state transition logic
            next_state = (imem_read) ? 2'b10 : 2'b00; // if imem_read is true, stay in IMEM_READ state, otherwise go to IDLE state
        end
        11: begin // DMEM_WRITE
            //asserting memory signals for writing data memory
            address = dmem_address; // data memory address to be written to
            enable = 1'b1;
            wr = 1'b1; // wr = write operation

            //passing data memory signals to cache
            dmem_data_valid = 1'b0; // data valid signal for data memory
            imem_data_valid = 1'b0; // data valid signal for instruction memory
            dmem_write_done = 1'b1; // write done signal for data memory
            imem_write_done = 1'b0; // write done signal for instruction memory

            //state transition logic
            next_state = 2'b00; // write will only take one cycle, so go back to IDLE state after
        end
    endcase
end
// State machine assigns
assign state_ff = state;
assign next_state_ff = next_state;

//signal assignments for memory address and cache
assign memory_address = address_sm;
assign memory_data = dmem_data_sm;
assign wr = wr_sm;
assign enable = enable_sm;
assign dmem_data_valid = dmem_data_valid_sm;
assign imem_data_valid = imem_data_valid_sm;
assign dmem_write_done = dmem_write_done_sm;
assign imem_write_done = imem_write_done_sm;

endmodule
`default_nettype wire