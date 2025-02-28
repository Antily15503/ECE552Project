module decoder_one_hot (
    input [15:0] shift_in,
    input [3:0] shift_val,
    output reg [15:0] shift_out
);
    reg [15:0] shift_s1;
    reg [15:0] shift_s2;
    reg [15:0] shift_s4;

    always @(*) begin
        shift_s1 = shift_val[0] ? {shift_in[14:0], 1'b0} : shift_in;
        shift_s2 = shift_val[1] ? {shift_s1[13:0], 2'b00} : shift_s1;
        shift_s4 = shift_val[2] ? {shift_s2[11:0], 4'h0} : shift_s2;
        shift_out = shift_val[3] ? {shift_s4[7:0], 8'h00} : shift_s4;
    end

endmodule
