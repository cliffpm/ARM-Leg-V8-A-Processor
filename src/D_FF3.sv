
module D_FF3 (in,out,clk,reset);
	input logic [2:0] in;
	input logic clk, reset;
	output logic [2:0] out;
	
	genvar i;
	
	
	generate
	
	for (i = 0; i < 3; i++) begin: eachDFF
		D_FF flipflop (.q(out[i]), .d(in[i]), .reset, .clk);
	end 
	
	endgenerate 
	

endmodule 