

module mux2_1_64(out, i0,i1, sel);
	input logic [63:0] i1, i0;
	input logic sel;
	
	output logic [63:0] out;
	
	genvar i;
	
	
	generate 
		for (i = 0; i < 64; i++)begin: eachMux
			mux2_1 mulplex (.out(out[i]), .i1(i1[i]), .i0(i0[i]), .sel);
		end 
	endgenerate
	
	
endmodule 