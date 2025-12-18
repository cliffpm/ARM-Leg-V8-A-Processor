
module D_FF2(in, out, clk, reset);
	input logic [1:0] in;
	input logic clk, reset;
	output logic [1:0] out;
	
	genvar i;
	
	
	generate
	
	for (i = 0; i < 2; i++) begin: eachDFF
		D_FF flipflop (.q(out[i]), .d(in[i]), .reset, .clk);
	end 
	
	endgenerate 
	

endmodule 