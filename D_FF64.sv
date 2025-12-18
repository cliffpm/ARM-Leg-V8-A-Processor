`timescale 1ps/1ps


module D_FF64(in, out, clk, reset);
	input logic [63:0] in;
	input logic clk, reset;
	output logic [63:0] out;

	genvar i;
	
	
	generate
	
	for (i = 0; i < 64; i++) begin: eachDFF
		D_FF flipflop (.q(out[i]), .d(in[i]), .reset, .clk);
	end 
	
	endgenerate 
	
endmodule
