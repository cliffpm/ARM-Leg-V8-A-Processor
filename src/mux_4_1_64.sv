
module mux_4_1_64 (i0, i1, i2, i3, sel, out);
	input logic [63:0] i0, i1, i2, i3;
	
	input logic [1:0] sel;
	
	output logic [63:0] out;
	
	
	genvar i;
	
	generate 
		for (i = 0; i < 64; i++) begin: eachMux
			mux4_1 mulplex  (.i0(i0[i]), .i1(i1[i]), .i2(i2[i]), .i3(i3[i]), .sel0(sel[0]), .sel1(sel[1]), .out(out[i]));
		end 
	endgenerate 
	
	

endmodule 