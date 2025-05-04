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
    output wire [15:0] memory_address,
    output wire [2:0] write_block,
    // output wire state,
    
     
    output wire [2:0] current_block
    
);

wire memory_data_valid_delay1, memory_data_valid_delay2, memory_data_valid_delay3;
dff ff1(.d(memory_data_valid),.q(memory_data_valid_delay1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ff2(.d(memory_data_valid_delay1),.q(memory_data_valid_delay2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff ff3(.d(memory_data_valid_delay2),.q(memory_data_valid_delay3),.wen(1'b1),.clk(clk),.rst(~rst_n));

wire state_ff;
reg nextstate;
dff stateflop(.d(nextstate), .q(state_ff), .wen(1'b1), .clk(clk), .rst(~rst_n));

wire state_delay1, state_delay2, state_delay3, state_delay4, state_delay5, state_delay6, state_delay7, state_delay8;

dff stateff1(.d(state_ff),.q(state_delay1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff stateff2(.d(state_delay1),.q(state_delay2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff stateff3(.d(state_delay2),.q(state_delay3),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff stateff4(.d(state_delay3),.q(state_delay4),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff stateff5(.d(state_delay4),.q(state_delay5),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff stateff6(.d(state_delay5),.q(state_delay6),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff stateff7(.d(state_delay6),.q(state_delay7),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff stateff8(.d(state_delay7),.q(state_delay8),.wen(1'b1),.clk(clk),.rst(~rst_n));

wire [3:0] c1, c2, c3, c4;
assign write_block = c4[2:0];

//logic signals for state machine
reg increment, fsm_busy_sm, write_data_array_sm, write_tag_array_sm;
wire [3:0] count, count_d;
always @(*) begin
    // Default values
    fsm_busy_sm = 1'b0;
    write_data_array_sm = 1'b0;
    write_tag_array_sm = 1'b0;
    increment = 1'b0;
    nextstate = 1'b0;
    case (state_ff)
        0: begin
            fsm_busy_sm = miss_detected;
            nextstate = miss_detected & ~state_delay4;
            write_tag_array_sm = 1'b0;
            
            // if (miss_detected) begin
            //     fsm_busy_sm = 1'b1;
            //     write_tag_array_sm = 1'b0;
            //     nextstate = 1'b1;
            // end else begin
            //     nextstate = 1'b0;
            // end
        end
        1: begin
            fsm_busy_sm = 1'b1;//~(count == 4'h7);
            nextstate = ~((count == 4'h7) && memory_data_valid); 
            increment = ~(count == 4'h7);
            //increment = ~count[3];
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
//assign write_data_array = write_data_array_sm;

//assign write_tag_array = write_tag_array_sm;
wire write_tag_delay1, write_tag_delay2, write_tag_delay3, write_tag_delay4;
dff write_tagff1(.d(state_ff & ~nextstate),.q(write_tag_delay1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff write_tagff2(.d(write_tag_delay1),.q(write_tag_delay2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff write_tagff3(.d(write_tag_delay2),.q(write_tag_delay3),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff write_tagff4(.d(write_tag_delay3),.q(write_tag_delay4),.wen(1'b1),.clk(clk),.rst(~rst_n));
assign write_tag_array = write_tag_delay4;

wire write_data_array1;
wire write_data_array2, write_data_array3;
dff write_data_array_ff(.d(write_data_array_sm),.q(write_data_array1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff write_data_array_ff2(.d(write_data_array1),.q(write_data_array2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff write_data_array_ff3(.d(write_data_array2),.q(write_data_array3),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff write_data_array_ff4(.d(write_data_array3),.q(write_data_array),.wen(1'b1),.clk(clk),.rst(~rst_n));

//incrementer
dff count_reg[3:0] (
    .d((count[2:0] == 3'h7) ? 4'hF : count_d),
    .q(count),
    .wen(1'b1),
    .clk(clk),
    .rst(~rst_n | (state_ff == 1'b0 & ~miss_detected))
);

dff count_reg1[3:0](.d(count),.q(c1),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff count_reg2[3:0](.d(c1),.q(c2),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff count_reg3[3:0](.d(c2),.q(c3),.wen(1'b1),.clk(clk),.rst(~rst_n));
dff count_reg4[3:0](.d(c3),.q(c4),.wen(1'b1),.clk(clk),.rst(~rst_n));


add_4bit count_adder(
    .A(increment ? count : 4'h0),
    .B(increment ? {3'h0, memory_data_valid} : 4'h0),
    // .sub(1'b0),
    .Cin(1'b0),
    .Sum(count_d),
    .Cout()
);

assign current_block = count[2:0];



assign memory_address = {miss_address[15:4], count[2:0], 1'b0};

endmodule
`default_nettype wire