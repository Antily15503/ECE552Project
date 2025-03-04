`ifndef FULL_ADDER_1BIT_V
`define FULL_ADDER_1BIT_V

// Full Adder 1-bit module declaration
module full_adder_1bit(
	input a,
	input b,
	input cin,
	output sum,
	output cout
	);
	
	// Full Adder 1-bit Module Declaration
	wire tmp1,tmp2,tmp3;
	
	// sum calculation using xor gates
	xor X1(sum,a,b,cin);
	
	// and gates for carry calculation
	and A1(tmp1,a,b);
	and A2(tmp2,b,cin);
	and A3(tmp3,a,cin);
	
	// or gate to determine final carry out
	or  O1(cout,tmp1,tmp2,tmp3);

endmodule
`endif
