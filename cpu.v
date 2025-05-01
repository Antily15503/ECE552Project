`default_nettype none
module cpu(
    input wire clk, rst_n, // clock and reset signals
    output wire hlt, // halt signal
    output wire [15:0] pc // program counter
);
wire [15:0] pc; // program counter (1)
wire hlt; // halt signal (1)

//signals used by the instruction cache and memory
wire [15:0] pc;                 // [from CPU]   program counter used to fetch instruction
wire [15:0] instruction;        // [to CPU]     fetched instruction from instruction cache according to pc
wire [15:0] pc_data;            // [to I-Cache] data fetched from instruction memory 
wire [15:0] pc_cache_address;   // [fr I-Cache] address to fetch instruction from instruction memory
wire pc_stall;                  // [to CPU]     stall signal for instruction cache
wire pc_valid;                  // [fr I-Cache] data valid signal for instruction memory

//signals used by data cache and memory
wire [15:0] write_data;     // [from CPU]   data to be written to memory
wire [15:0] write_address;  // [from CPU]   address to be written to memory
wire write_enable;          // [from CPU]   write enable signal
wire [15:0] data_out;       // [to CPU]     data read from memory 
wire stall;                 // [to CPU]     stall signal for data cache
wire [15:0] memory_address; // [fr D-Cache] address to be read from memory 
wire [15:0] memory_data;    // [fr D-Cache] data read from memory 
wire memory_data_valid;     // [fr D-Cache] data valid signal for data memory 
wire memory_read_data;      // [to D-Cache] data read from memory


//instantiate the central processor
processor processor(
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc),
    .hlt(hlt)
);

//instantiate the instruction cache 
cache instruction_cache(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(),
    .address(pc),
    .write_enable(1'b0),
    .data_out(instruction),
    .stall(pc_stall),
    .memory_address(pc_cache_address),  //out
    .memory_data(pc_data),              //in
    .memory_data_valid(pc_valid),       //in
    .memory_read(1'b1),                 //out
    .memory_write(1'b0)                 //out
);

//instantiate the instruction memory
multicycle_instruction_memory instruction_memory(
    .clk(clk),
    .rst(rst_n),
    .data_out(pc_data),
    .data_in(16'h0000),
    .addr(pc_cache_address),
    .enable(1'b1),
    .wr(1'b0),
    .data_valid(pc_valid)
);

//instantiate the data cache
cache data_cache(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(write_data),
    .address(write_address),
    .write_enable(write_enable),
    .data_out(data_out),
    .stall(stall),
    .memory_address(memory_address),
    .memory_data(memory_read_data),
    .memory_data_valid(memory_data_valid),
    .memory_read(), //(1)
    .memory_write()
);

//instantiate the data memory
multicycle_data_memory data_memory(
    .data_out(memory_read_data), // (1)
    .data_in(memory_), // (1)
    .addr(memory_address),
    .enable(memory_read),
    .wr(memory_write),
    .clk(clk),
    .rst(rst_n),
    .data_valid(memory_data_valid)
);

endmodule
`default_nettype wire