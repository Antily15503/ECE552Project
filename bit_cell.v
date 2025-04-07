module bit_cell (
    input clk,
    input rst,
    input d,
    input wren,
    input rden1,
    input rden2,
    inout bitline1,
    inout bitline2
);
    wire bit_out;

    dff iBit (
        .clk(clk),
        .rst(rst),
        .wen(wren),
        .d(d),
        .q(bit_out)
    );

    assign bitline1 = rden1 ? bit_out : 1'bz; 
    assign bitline2 = rden2 ? bit_out : 1'bz; 

endmodule
