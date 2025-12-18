
module mux2_1_5(out, i1, i0, sel);
	input logic [4:0] i1, i0;
	
	input logic sel;
	output logic [4:0] out;
	
	
	genvar i;
	
	
	generate 
		for (i = 0; i < 5; i++) begin: eachMux
			mux2_1 mulplex (.out(out[i]), .i1(i1[i]), .i0(i0[i]), .sel(sel));
		
		end 
	
	endgenerate

endmodule 