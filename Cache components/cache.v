`default_nettype none
module cache(
    input clk, rst_n,

    // CPU ports
    input [15:0] data_in, //data being written to the cache, from the processor
    input [15:0] address, //address of the cache block that is being accessed, in case of a miss
    input write_enable,  // 1 = store, 0 = load
    output [15:0] data_out, //data being read from cache, taken to the processor
    output stall,

    // Memory ports
    output [15:0] memory_address,
    input  [15:0] memory_data,
    input  memory_data_valid,
    output memory_read,
    output memory_write
);

wire [5:0] tag_bits, set_bits;
wire block_bit;
wire [2:0] offset;

assign tag_bits = address[15:10];
assign set_bits = address[9:4];
assign block_bit = address[3];
assign offset = address[2:0];

wire [63:0] one_hot_set;
wire [7:0] one_hot_offset;

psm_cache_64 set_shifter(.shift_val(set_bits),.shift_out(one_hot_set));

psm_cache_8 word_shifter(.shift_val(offset),.shift_out(one_hot_offset));

DataArray data_array(
    .clk(clk),
    .rst(rst_n),
    .DataIn(data_in),
    .Write(write_enable),
    .Block_Enable(block_bit),
    .SetEnable(one_hot_set),
    .WordEnable(one_hot_offset),
    .DataOut(data_out)
);

//MetaDataArray
wire [7:0] meta_data_out;
wire write_meta = write_data_array; //enable write on miss refill only
wire hit;

MetaDataArray meta_data_array(
    .clk(clk),
    .rst(rst_n),
    .DataIn(tag_bits),
    .Write(write_meta), //might need to be only be on miss
    .BlockEnable(block_bit),
    .SetEnable(one_hot_set),
    .DataOut(meta_data_out)
);

// parse metadata fields
wire meta_tag = meta_data_out[7:2];
wire meta_valid = meta_data_out[1];
wire meta_lru = meta_data_out[0];

// detect hits
hit = meta_valid & (meta_tag == tag_bits);

//FSM 
wire fsm_busy;
wire write_data_array;
wire write_tag_array; //not sure what this does

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

assign stall        = fsm_busy;
assign memory_read  = fsm_busy;
assign memory_write = write_enable & hit;

endmodule
`default_nettype wire