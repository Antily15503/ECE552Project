module RegisterFile(input clk, input rst, input [3:0] SrcReg1, input [3:0] SrcReg2, input [3:0] DstReg, input WriteReg, input [15:0] DstData, inout [15:0] SrcData1, inout [15:0] SrcData2);
    wire [15:0] read_enable1;
    wire [15:0] read_enable2;
    wire [15:0] write_enable;
    wire [15:0] sd1, sd2;

    ReadDecoder_4_16 rd1(.RegId(SrcReg1), .Wordline(read_enable1));
    ReadDecoder_4_16 rd2(.RegId(SrcReg2), .Wordline(read_enable2));
    WriteDecoder_4_16 wd(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(write_enable));
    
    Register regesiter0(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[0]), .ReadEnable1(read_enable1[0]), .ReadEnable2(read_enable2[0]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter1(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[1]), .ReadEnable1(read_enable1[1]), .ReadEnable2(read_enable2[1]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter2(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[2]), .ReadEnable1(read_enable1[2]), .ReadEnable2(read_enable2[2]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter3(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[3]), .ReadEnable1(read_enable1[3]), .ReadEnable2(read_enable2[3]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter4(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[4]), .ReadEnable1(read_enable1[4]), .ReadEnable2(read_enable2[4]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter5(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[5]), .ReadEnable1(read_enable1[5]), .ReadEnable2(read_enable2[5]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter6(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[6]), .ReadEnable1(read_enable1[6]), .ReadEnable2(read_enable2[6]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter7(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[7]), .ReadEnable1(read_enable1[7]), .ReadEnable2(read_enable2[7]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter8(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[8]), .ReadEnable1(read_enable1[8]), .ReadEnable2(read_enable2[8]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter9(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[9]), .ReadEnable1(read_enable1[9]), .ReadEnable2(read_enable2[9]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter10(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[10]), .ReadEnable1(read_enable1[10]), .ReadEnable2(read_enable2[10]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter11(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[11]), .ReadEnable1(read_enable1[11]), .ReadEnable2(read_enable2[11]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter12(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[12]), .ReadEnable1(read_enable1[12]), .ReadEnable2(read_enable2[12]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter13(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[13]), .ReadEnable1(read_enable1[13]), .ReadEnable2(read_enable2[13]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter14(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[14]), .ReadEnable1(read_enable1[14]), .ReadEnable2(read_enable2[14]), .Bitline1(sd1), .Bitline2(sd2));
    Register regesiter15(.clk(clk), .rst(rst), .D(DstData), .WriteReg(write_enable[15]), .ReadEnable1(read_enable1[15]), .ReadEnable2(read_enable2[15]), .Bitline1(sd1), .Bitline2(sd2));

    assign SrcData1 = sd1;
    assign SrcData2 = sd2;

endmodule