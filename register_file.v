module register_file (
    input clk,
    input rst,
    input [3:0] src_reg1,
    input [3:0] src_reg2,
    input [3:0] dst_reg,
    input write_reg,
    input [15:0] dst_data,
    inout [15:0] src_data1,
    inout [15:0] src_data2
);
    wire [15:0] wordline_src1;
    wire [15:0] wordline_src2;
    wire [15:0] wordline_dst;
    wire [15:0] src_data1_internal;
    wire [15:0] src_data2_internal;

    read_decoder_4_16 iSRC1 (
        .reg_id(src_reg1),
        .wordline(wordline_src1)
    );

    read_decoder_4_16 iSRC2 (
        .reg_id(src_reg2),
        .wordline(wordline_src2)
    );

    write_decoder_4_16 iDST (
        .reg_id(dst_reg),
        .write_reg(write_reg),
        .wordline(wordline_dst)
    );

    register iRegisters [15:0] (
        .clk(clk),
        .rst(rst),
        .d(dst_data),
        .write_reg(write_reg),
        .rden1(wordline_src1),
        .rden2(wordline_src2),
        .bitline1(src_data1_internal),
        .bitline2(src_data2_internal)
    );

    // Fixed bus contention by ensuring only one driver
    assign src_data1 = (|wordline_src1 & wordline_dst) ? dst_data : src_data1_internal;
    assign src_data2 = (|wordline_src2 & wordline_dst) ? dst_data : src_data2_internal;

endmodule
