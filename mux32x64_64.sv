// mux64x32_1
module mux32x64_64(out, i, sel0, sel1, sel2, sel3, sel4);

output logic [63:0] out;
input logic [63:0] i [31:0];
input logic sel0, sel1, sel2, sel3, sel4;
   


	genvar x, j;
	generate
		 for (x= 0; x< 64; x++) begin : mux_bit
			 logic [31:0] bit_index;
			 for (j = 0; j < 32; j++) begin : mux_bit2
				assign bit_index[j] = i[j][x];
			end 
			mux32_1 muxie (.i(bit_index), .sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3), .sel4(sel4), .out(out[x]));
		 end
	endgenerate
endmodule

module mux32x64_64_testbench(); 

    logic [63:0] out;
    logic [31:0][63:0] i;  
    logic sel0, sel1, sel2, sel3, sel4;

    // DUT
    mux32x64_64 dut(
        .out(out),
        .i(i),
        .sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3), .sel4(sel4));
	 
	 initial begin
		integer i; 
		for (i = 0; i < 32; i++) begin 
			i[i] = i; 
		end #10 
		for (i = 0; i < 32; i++) begin 
			{sel4,sel3,sel2,sel1,sel0} = i;
		end #10;
	end 
endmodule 
		
	 
	 