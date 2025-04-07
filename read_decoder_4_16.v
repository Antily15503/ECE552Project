module read_decoder_4_16 (
    input [3:0] reg_id,
    output [15:0] wordline
);
    decoder_one_hot iRead_Decoder (
        .shift_in(16'h0001),
        .shift_val(reg_id),
        .shift_out(wordline)
    );
endmodule
