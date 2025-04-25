`default_nettype none
module cache(
    input clk, rst_n,
    input [15:0] data_in, //data being written to the cache, from the processor
    input [15:0] address, //address of the cache block that is being accessed, in case of a miss
    input write_enable,  // 1 = store, 0 = load
    output [15:0] data_out //data being read from cache, taken to the processor
);

wire [5:0] tag_bits, set_bits;
wire [3:0] offset;

assign tag_bits = address[15:10];
assign set_bits = address[9:4];
assign offset = address[3:0];

wire [63:0] one_hot_set;
wire [7:0] one_hot_offset;

psm_cache_64 set_shifter(.shift_val(set_bits),.shift_out(one_hot_set));

cache_fill_FSM cache_miss_handler(
    .
);

DataArray data_array(
    .clk(clk),
    .rst(rst_n),
    .DataIn(data_in),
    .Write(write_enable),
    .Block_Enable(),
    .SetEnable(one_hot_set),
    .WordEnable(one_hot_offset),
    .DataOut(data_out)
);

MetaDataArray meta_data_array(
    .
);


endmodule
`default_nettype wire