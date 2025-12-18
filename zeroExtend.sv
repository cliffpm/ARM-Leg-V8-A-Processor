

// 64 bit zero extender
module zeroExtend #(parameter WIDTH = 64) (in, out);
	input logic [WIDTH-1:0] in;
	output logic [63:0] out;
	
	assign out = {{(64-WIDTH){1'b0}}, in};
	

endmodule 