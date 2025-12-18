// A few math subunits.
// The multipler can be used to implement the MUL instruction,
// and the shifter can be used to implement LSL and/or LSR.
// DO NOT USE for any other purpose.

module mult (
	input logic		[63:0]	A, B,
	input logic					doSigned,				// 1: signed multiply 0: unsigned multiply
	output logic	[63:0]	mult_low, mult_high 
	);
	
	logic signed	[63:0]	signedA, signedB;
	logic signed	[127:0]	signedResult;
	logic				[127:0]	unsignedResult;
	
	// --- Signed math ---
	always_comb begin
		signedA = A;
		signedB = B;
		signedResult = signedA * signedB;
	end
	
	// --- Unsigned math ---
	always_comb
		unsignedResult = A * B;
		
	// --- Pick the right output ---
	always_comb
		if (doSigned)
			{mult_high, mult_low} = signedResult;
		else
			{mult_high, mult_low} = unsignedResult;

endmodule