`default_nettype none
module cache_fill_FSM(
    input wire clk, rst_n,
    input wire miss_detected,
    input wire [15:0] miss_address,
    input wire [15:0] memory_data,
    input wire memory_data_valid,
    output wire fsm_busy,
    output wire write_data_array,
    output wire write_tag_array,
    output wire [15:0] memory_address
);

wire state_ff, nextstate_ff;

dff stateflop(
    .d(nextstate_ff),
    .q(state_ff),
    .wen(1'b1),
    .clk(clk),
    .rst(~rst_n)
);

//logic signals for state machine
reg increment, fsm_busy_sm, write_data_array_sm, write_tag_array_sm, state, nextstate;
wire [3:0] count, count_d;
always @(*) begin
    // Default values
    fsm_busy_sm = 1'b0;
    write_data_array_sm = 1'b0;
    write_tag_array_sm = 1'b0;
    increment = 1'b0;
    state = 0;
    nextstate = 0;
    case (state)
        0: begin
            fsm_busy_sm = miss_detected;
            nextstate = miss_detected;
            write_tag_array_sm = ~miss_detected;
            
            // if (miss_detected) begin
            //     fsm_busy_sm = 1'b1;
            //     write_tag_array_sm = 1'b0;
            //     nextstate = 1'b1;
            // end else begin
            //     nextstate = 1'b0;
            // end
        end
        1: begin
            fsm_busy_sm = ~count[3];
            nextstate = ~count[3];
            increment = ~count[3];
            write_data_array_sm = ~count[3]; //might cause issues
            write_tag_array_sm = count[3];

            // if (count[3]) begin
            //     //fsm_busy_sm = 1'b0;
            //     //write_tag_array_sm = 1'b1;
            //     //nextstate = 1'b0;
            //     //increment = 1'b0;
            // end else begin
            //     //fsm_busy_sm = 1'b1;
            //     //write_data_array_sm = 1'b1;
            //     //write_tag_array_sm = 1'b0;
            //     //increment = 1'b1;
            //     //nextstate = 1'b1;
            // end
        end
        default: nextstate = 1'b0;
    endcase
end
assign fsm_busy = fsm_busy_sm;
assign write_data_array = write_data_array_sm;
assign write_tag_array = write_tag_array_sm;
assign state_ff = state;
assign nextstate_ff = nextstate;

//incrementer
dff count_reg[3:0] (
    .d(count_d),
    .q(count),
    .wen(1'b1),
    .clk(clk),
    .rst(~rst_n & ~miss_detected)
);
addsub_4bit count_adder(
    .A(increment ? count : 4'h0),
    .B(increment ? {3'h0, memory_data_valid} : 4'h0),
    .sub(1'b0),
    .Sum(count_d),
    .Cout()
);

assign memory_address = {miss_address[15:4], count[2:0], 1'b0};

endmodule
`default_nettype wire