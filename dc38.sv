
module dc38 (enable, s, d);
	input logic enable;
	input logic [2:0] s;
	output logic [7:0] d;
	
	// we will build a 3:8 decoder from a 1:2 decoder that maps to select between two 2:4 decoder
	// just realized that since they differ between the 2:4 decoders if MSB is true or false , then 
	// feed enable of dc12A as a negated MSB and the other as the MSB
	logic [1:0] dc12Out;
	dc12 dc12A (.enable(enable), .s0(s[2]), .d(dc12Out));
	
	
	/*0 to 3 Decoder */ dc24 dc24A (.enable(dc12Out[0]), .s(s[1:0]), .d(d[3:0]));
	
	/*4 to 7 Decoder */ dc24 dc24B (.enable(dc12Out[1]), .s(s[1:0]), .d(d[7:4]));
	
endmodule 

module dc38_testbench();
	logic enable;
	logic [2:0] s;
	logic [7:0] d;
	
	dc38 dut (.*);
	

	initial begin 

	
		enable = 0;
		for (int i = 0; i < 8; i ++) begin 
			s = i; #1000;
		end 
		
		enable = 1;
		for (int i = 0; i < 8; i++) begin 
			s = i; #1000;
		end 
		
	end 
	
endmodule 
