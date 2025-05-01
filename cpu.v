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
wire [15:0] pc_cache_address;   // [fr I-Cache] address in memory (1) to fetch instruction from instruction memory
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

wire mem_valid;
wire mem_enable;
wire mem_wr;    //toggles between reading and writing to memory. 1 = write, 0 = read

//instantiate the central processor
processor processor(
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc),
    .hlt(hlt)
);

wire inst_read;
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
    .memory_data_valid(pc_valid),       //in (1)
    .memory_read(inst_read),            //out (This was 1'b1???)
    .memory_write(1'b0)                 //out 
);

//instantiate the instruction memory
multicycle_memory memory(
    .clk(clk),
    .rst(rst_n),
    .data_out(dmem_data_valid ? memory_read_data : imem_data_valid ? pc_data),
    .data_in(16'h0000),
    .addr( pc_cache_address),
    .enable(mem_enable),
    .wr(mem_wr),
    .data_valid(mem_valid)
);

wire memory_data_read_bit, memory_data_write_bit;
//instantiate the data cache
cache data_cache(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(write_data),
    .address(write_address),
    .write_enable(write_enable),
    .data_out(data_out),
    .stall(stall),
    .memory_address(memory_address),    //out
    .memory_data(memory_read_data),
    .memory_data_valid( memory_data_valid),      //(1)
    .memory_read(memory_data_read_bit), //(1)
    .memory_write(memory_data_write_bit)
);

arbiter arbiter(
    .clk(clk)
    .rst_n(rst_n)
    .valid(mem_valid)
    .dmem_address(memory_address)
    .dmem_data()            //(1)
    .dmem_read(memory_data_read_bit)
    .dmem_write(memory_data_write_bit)
    .imem_read(inst_read)
    .imem_address(pc_cache_address)

    .dmem_data_valid(memory_data_valid)
    .imem_data_valid(pc_valid)
    .dmem_write_done()     //do we need to add signals to cache?
    .imem_write_done()      //do we need to add signals to cache?
    .memory_address()       //what is this for
    .memory_data(memory_read_data pc_data)
    .enable(mem_enable)
    .wr(mem_wr)
);

//instantiate the data memory
// multicycle_data_memory data_memory(
//     .data_out(memory_read_data), // (1)
//     .data_in(memory_), // (1)
//     .addr(memory_address),
//     .enable(memory_read),
//     .wr(memory_write),
//     .clk(clk),
//     .rst(rst_n),
//     .data_valid(memory_data_valid)
// );

endmodule
`default_nettype wire