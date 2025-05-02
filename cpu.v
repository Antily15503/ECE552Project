`default_nettype none
module cpu(
    input wire clk, rst_n, // clock and reset signals
    output wire hlt, // halt signal
    output wire [15:0] pc // program counter
);
//signals used by the instruction cache and memory
wire [15:0] pcAddr;             // [from CPU]   program counter used to fetch instruction
wire [15:0] instruction;        // [to CPU]     fetched instruction from instruction cache according to pc
wire [15:0] pc_data;            // [to I-Cache] data fetched from instruction memory 
wire [15:0] pc_cache_address;   // [fr I-Cache] address in memory (1) to fetch instruction from instruction memory
wire pc_stall, data_stall;      // [to CPU]     stall signal from instruction and data cache
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

wire [15:0] data_arbiter_to_mem, data_mem_to_arbiter;
wire [15:0] addr_arbiter_to_mem;

//instantiate the central processor
processor processor(
    .clk(clk),
    .rst_n(rst_n),
    .pc(pc),
    .instruction(instruction),
    .pcStall(pc_stall),
    .dataStall(data_stall),
);

wire inst_read;
//instantiate the instruction cache 
cache instruction_cache(
    .clk(clk),
    .rst_n(rst_n),
    .data_in(),
    .address(pcAddr),
    .write_enable(1'b0),
    .data_out(instruction),
    .stall(pc_stall),
    .memory_address(pc_cache_address),  //out
    .memory_data(pc_data),              //in
    .memory_data_valid(pc_valid),       //in
    .memory_read(inst_read),            //out
    .memory_write(1'b0),                //disabled 
    .memory_read_data(1'b1)      //in   //disabled
);

//instantiate the instruction memory
multicycle_memory memory(
    .clk(clk),
    .rst(rst_n),
    .data_out(data_mem_to_arbiter),
    .data_in(data_arbiter_to_mem),
    .addr(addr_arbiter_to_mem),
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
    .stall(data_stall),
    .memory_address(memory_address),    //out
    .memory_data(memory_read_data),
    .memory_data_valid(memory_data_valid),      
    .memory_read(memory_data_read_bit), 
    .memory_write(memory_data_write_bit),
    .mem_write_done(dmem_write_done), //in
);

//wire dmem_write_done, imem_write_done;
arbiter arbiter(
    .clk(clk),
    .rst_n(rst_n),
    .valid(mem_valid),
    .dmem_address(memory_address),
    .data_to_write(data_out),
    .data_to_arbiter(data_mem_to_arbiter),
    .dmem_read(memory_data_read_bit),
    .dmem_write(memory_data_write_bit),
    .imem_read(inst_read),
    .imem_address(pc_cache_address),

    .dmem_data_valid(memory_data_valid),
    .imem_data_valid(pc_valid),
    .dmem_write_done(dmem_write_done),      //do we need to add signals to cache?
    .memory_address(addr_arbiter_to_mem),
    .data_to_cache(memory_read_data pc_data),   //(1)
    .write_to_memory(data_arbiter_to_mem),
    .enable(mem_enable),
    .wr(mem_wr)
);

assign pc = pcAddr; // assign the program counter to the output
endmodule
`default_nettype wire