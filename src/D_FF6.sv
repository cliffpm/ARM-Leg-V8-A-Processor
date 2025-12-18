`timescale 1ps/1ps

module D_FF6(in, out, clk, reset);
	input logic [5:0] in;
	input logic clk, reset;
	output logic [5:0] out;
	
	genvar i;
	
	
	generate
	
	for (i = 0; i < 6; i++) begin: eachDFF
		D_FF flipflop (.q(out[i]), .d(in[i]), .reset, .clk);
	end 
	
	endgenerate 
	

endmodule 