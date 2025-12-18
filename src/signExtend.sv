
module signExtend #(parameter WIDTH = 19)(in, out);
	input logic [WIDTH-1:0] in;
	
	output logic [63:0] out;
	
	assign out = {{(64-WIDTH){in[WIDTH-1]}},in};
	

endmodule 