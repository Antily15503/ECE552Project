//Data Array of 128 cache blocks
//Each block will have 8 words
//BlockEnable and WordEnable are one-hot
//WriteEnable is one on writes and zero on reads

module DataArray(
	input clk, 
	input rst, 
	input [15:0] DataIn, 
	input Write,  //becomes write enable
	input BlockEnable, //enable*
	input [63:0] SetEnable, 
	input [7:0] WordEnable, 
	output [15:0] DataOut
);
	Set sets[63:0](
		.clk(clk),
		.rst(rst),
		.DataIn(DataIn),
		.Write({64{Write}} & SetEnable),
		.BlockEnable(BlockEnable),
		.SetEnable(SetEnable),
		.WordEnable(WordEnable),
		.DataOut(DataOut)
	);
endmodule

module Set(
	input clk, 
	input rst, 
	input [15:0] DataIn, 
	input Write, 
	input BlockEnable,
	input SetEnable, 			//1 high bit out of [63:0] (one hot)
	input [7:0] WordEnable, 
	output [15:0] DataOut
);
	wire [1:0] BlockEnable_real; 
	assign BlockEnable_real = {BlockEnable, ~BlockEnable};
	wire[15:0] DataOut_real;
	Block blk[1:0]( 
		.clk(clk), 
		.rst(rst), 
		.Din(DataIn), 
		.WriteEnable(Write), 
		.Enable(BlockEnable_real), 
		.WordEnable(WordEnable), 
		.Dout(DataOut_real)
	);
	assign DataOut = (SetEnable) ? DataOut_real : 16'bz; //Only for the enabled cache block, you enable the specific word

endmodule

// module DataArray(input clk, input rst, input [15:0] DataIn, input Write, input [127:0] BlockEnable, input [7:0] WordEnable, output [15:0] DataOut);
// 	Block blk[127:0]( .clk(clk), .rst(rst), .Din(DataIn), .WriteEnable(Write), .Enable(BlockEnable), .WordEnable(WordEnable), .Dout(DataOut));
// endmodule

//64 byte (8 word) cache block
module Block( input clk,  input rst, input [15:0] Din, input WriteEnable, input Enable, input [7:0] WordEnable, output [15:0] Dout);
	wire [7:0] WordEnable_real;
	assign WordEnable_real = {8{Enable}} & WordEnable; //Only for the enabled cache block, you enable the specific word
	DWord dw[7:0]( .clk(clk), .rst(rst), .Din(Din), .WriteEnable(WriteEnable), .Enable(WordEnable_real), .Dout(Dout));
endmodule


//Each word has 16 bits
module DWord( input clk,  input rst, input [15:0] Din, input WriteEnable, input Enable, output [15:0] Dout);
	DCell dc[15:0]( .clk(clk), .rst(rst), .Din(Din[15:0]), .WriteEnable(WriteEnable), .Enable(Enable), .Dout(Dout[15:0]));
endmodule


module DCell( input clk,  input rst, input Din, input WriteEnable, input Enable, output Dout);
	wire q;
	assign Dout = (Enable) ? q:'bz;
	dff dffd(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule

