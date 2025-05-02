`default_nettype none
module cache(
    input wire clk, rst_n,

    // CPU ports
    input wire [15:0] data_in, //data being written to the cache, from the processor
    input wire [15:0] address, //address of the cache block that is being accessed, in case of a miss
    input wire write_enable,  // 1 = store, 0 = load
    input wire dmem_write_done,
    output wire [15:0] data_out, //data being read from cache, taken to the processor
    output wire stall, //stall signals for the processor

    // Memory ports
    output wire [15:0] memory_address,
    input  wire [15:0] memory_data,
    input  wire memory_data_valid,
    output wire memory_read,
    output wire memory_write
    input wire memory_write_done
);

wire [5:0] tag_bits, set_bits;
wire block_bit;
wire [2:0] offset;
wire write_data_array; //enable write on miss refill only, remains on for the duration of the fill
wire write_tag_array; //enable write at the end of the fill, when we need to write to the metadata array

assign tag_bits = address[15:10];
assign set_bits = address[9:4];
assign block_bit = address[3];
assign offset = address[2:0];

wire [63:0] one_hot_set;
wire [7:0] one_hot_offset;

wire hit;

psm_cache_64 set_shifter(.shift_val(set_bits),.shift_out(one_hot_set));

psm_cache_8 word_shifter(.shift_val(offset),.shift_out(one_hot_offset));

DataArray data_array(
    .clk(clk),
    .rst(rst_n),
    .DataIn(data_in),
    .Write(hit ? write_enable : write_data_array), //???
    .Block_Enable(block_bit),
    .SetEnable(one_hot_set),
    .WordEnable(one_hot_offset),
    .DataOut(data_out)
);

//MetaDataArray
wire [7:0] meta_data_out;


MetaDataArray meta_data_array(
    .clk(clk),
    .rst(rst_n),
    .DataIn(tag_bits),
    .Write(write_tag_array), //might need to be only be on miss
    .BlockEnable(block_bit),
    .SetEnable(one_hot_set),
    .DataOut(meta_data_out)
);

// parse metadata fields
wire meta_tag = meta_data_out[7:2];
wire meta_valid = meta_data_out[1];
wire meta_lru = meta_data_out[0]; // TODO: LRU bit only updated on a miss, should be updating on a hit as well

// detect hits
assign hit = meta_valid & (meta_tag == tag_bits);

//FSM 
wire fsm_busy;

//FSM is only for cache filling in a cache miss, it does not write
cache_fill_FSM cache_miss_handler(
    .clk(clk),
    .rst_n(rst_n),
    .miss_detected(~hit),
    .miss_address(address),
    .memory_data(memory_data),
    .memory_data_valid(memory_data_valid),
    .fsm_busy(fsm_busy),
    .write_data_array(write_data_array),
    .write_tag_array(write_tag_array),
    .memory_address(memory_address)
);

assign stall        = fsm_busy | (~hit & (read_enable | write_enable)) | ~memory_write_done & write_enable;
assign memory_read  = fsm_busy;
assign memory_write = write_enable & hit;

endmodule
`default_nettype wire