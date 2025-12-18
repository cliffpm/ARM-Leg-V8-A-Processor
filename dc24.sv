// 2: 4 decoder

module dc24(enable, s, d);
	input logic enable;
	input logic [1:0] s;
	output logic [3:0] d;
	logic [1:0] selOut;
	dc12 sel (.enable(enable), .s0(s[1]), .d(selOut));
	dc12 lower (.enable(selOut[0]), .s0(s[0]), .d(d[1:0])); // 0-1
	dc12 upper (.enable(selOut[1]), .s0(s[0]), .d(d[3:2])); // 2-3
endmodule

module dc24_testbench();
	logic enable;
	logic [1:0] s;
	logic [3:0] d;
	dc24 dut(.*);
	
	
	initial begin
	enable = 0;
	for (int i = 0; i < 4; i++) begin
	 s = i;
	 #700;
	end

	enable = 1;
	for (int i = 0; i < 4; i++) begin
	 s = i;
	 #700;
	end
	end

endmodule 