module D_FF9 (in,out, clk, reset);
	input logic [8:0] in;
	input logic clk, reset;
	output logic [8:0] out;

	genvar i;
	
	
	generate
	
	for (i = 0; i < 9; i++) begin: eachDFF
		D_FF flipflop (.q(out[i]), .d(in[i]), .reset, .clk);
	end 
	
	endgenerate 
	

endmodule 