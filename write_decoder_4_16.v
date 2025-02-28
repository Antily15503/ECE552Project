module write_decoder_4_16 (
    input [3:0] reg_id,
    input write_reg,
    output [15:0] wordline
);
    wire [15:0] selected_word_line;

    decoder_one_hot iWrite_Decoder (
        .shift_in(16'h0001),
        .shift_val(reg_id),
        .shift_out(selected_word_line)
    );

    assign wordline = write_reg ? selected_word_line : 16'h0000;
endmodule
