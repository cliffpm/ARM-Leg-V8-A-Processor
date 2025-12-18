module D_FF12 (in,out, clk, reset);
	input logic [11:0] in;
	input logic clk, reset;
	output logic [11:0] out;

	genvar i;
	
	
	generate
	
	for (i = 0; i < 12; i++) begin: eachDFF
		D_FF flipflop (.q(out[i]), .d(in[i]), .reset, .clk);
	end 
	
	endgenerate 
	

endmodule 