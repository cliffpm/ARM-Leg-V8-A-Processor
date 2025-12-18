// standard full adder
`timescale 1ps/1ps

module fulladder(A, B, Cin, S, Cout);
	input logic A, B, Cin;
	output logic S, Cout;
	
	
	logic ACi, AB, BCi;
	nand #50  ACiNand (ACi, A, Cin);
	nand #50 ABNand (AB, A,B);
	nand #50  BCiBand (BCi, B, Cin);
	nand #50 CoutRes (Cout, ACi, AB, BCi);
	xor #50 sumRes (S, A, B, Cin);
	
endmodule 

module fulladder_testbench();
	logic A, B, Cin, S, Cout;
	fulladder dut(.*);
	
	initial begin 
	
	for (int i = 0; i < 8; i++) begin 
		{A, B, Cin} = i;
		#200;
	end 
	
	$finish;
	end 



endmodule 