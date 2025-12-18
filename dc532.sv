module dc532 (enable, s, d);
	input logic enable;
	input logic [4:0] s;
	output logic [31:0] d;
	
	logic [3:0] selOut;
	
	dc24 sel (.enable(enable), .s(s[4:3]), .d(selOut));
	
	dc38 A (.enable(selOut[0]), .s(s[2:0]), .d(d[7:0])); // 0-7
	
	dc38 B (.enable(selOut[1]), .s(s[2:0]), .d(d[15:8])); // 8-15
	
	dc38 C (.enable(selOut[2]), .s(s[2:0]), .d(d[23:16]));// 16-23
	
	dc38 D (.enable(selOut[3]), .s(s[2:0]), .d(d[31:24]));// 24-31
	

endmodule 

module dc532_testbench();
	logic enable;
	logic [4:0] s;
	logic [31:0] d;
	
	dc532 dut(.*);
	
	initial begin
		enable = 0;
		for (int i = 0; i < 32; i++) begin 
			s = i; #1000;
		
		end 
		
		enable = 1;
		
		for (int i = 0; i < 32; i++) begin
			s = i; #1000;
		
		end 
	
	end 
	



endmodule 