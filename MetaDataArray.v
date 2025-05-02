//Tag Array of 128  blocks
//Each block will have 1 byte
//BlockEnable is one-hot
//WriteEnable is one on writes and zero on reads

//Each block 

module MetaDataArray(
	input clk, 
	input rst, 
	input [7:0] DataIn, 
	input Write, 
	input BlockEnable,
	input [63:0] SetEnable, 
	output [7:0] DataOut
);
	MSet sets[63:0](
		.clk(clk), 
		.rst(rst), 
		.DataIn(DataIn), 
		.Write(Write), 
		.BlockEnable(BlockEnable), 
		.SetEnable(SetEnable), 
		.DataOut(DataOut)
	);
endmodule

module MSet(
	input clk,
	input rst,
	input [7:0] DataIn,
	input Write,
	input BlockEnable,
	input SetEnable,
	output [7:0] DataOut
);
	wire [1:0] BlockEnable_real; 
	assign BlockEnable_real = {BlockEnable, ~BlockEnable};

	Block blk[1:0]( 
		.clk(clk), 
		.rst(rst), 
		.Din(DataIn), 
		.WriteEnable(Write), 
		.Enable(BlockEnable_real), 
		.Dout(DataOut)
	);
endmodule

module MBlock( 
	input clk,  
	input rst, 
	input [7:0] Din, 
	input WriteEnable, 
	input Enable, 
	output [7:0] Dout
);
	MCell mc[7:0]( 
		.clk(clk), 
		.rst(rst), 
		.Din(Din[7:0]), 
		.WriteEnable(WriteEnable), 
		.Enable(Enable), 
		.Dout(Dout[7:0])
	);
endmodule

module MCell( 
	input clk,  
	input rst, 
	input Din, 
	input WriteEnable, 
	input Enable, 
	output Dout
);
	wire q;
	assign Dout = (Enable & ~WriteEnable) ? q:'bz;
	dff dffm(.q(q), .d(Din), .wen(Enable & WriteEnable), .clk(clk), .rst(rst));
endmodule

