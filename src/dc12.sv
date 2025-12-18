`timescale 1ps/1ps


module dc12 (enable, s0, d);
	input logic enable, s0;
	output logic [1:0] d;
		
	logic nots0;
	not #50  A (nots0, s0);
	
	and #50 B (d[1], enable, s0);
	and #50 C (d[0], enable, nots0);
	
endmodule 

module dc12_testbench();
	logic enable, s0;
	logic [1:0] d;
	
	dc12 dut(.*);
	
	initial begin 
		enable =0; s0 = 0; #500;
		s0 = 1; #500;
		
		enable =1; s0 =0; #500;
		s0 = 1; #500;
	
	end 


endmodule 