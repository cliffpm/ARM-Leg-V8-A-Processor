
	
	/*
	Control Meanings:
	
	// 000:	0		result = B						value of overflow and carry_out unimportant
	// 010:	2		result = A + B
	// 011:	3		result = A - B
	// 100:	4		result = bitwise A & B		value of overflow and carry_out unimportant
	// 101:	5		result = bitwise A | B		value of overflow and carry_out unimportant
	// 110:	6		result = bitwise A XOR B	value of overflow and carry_out unimportant
	
	*/
	
`timescale 1ps/1ps

module alu_1bit(A, B, Cout, Cin, result,cntrl);
	input logic A, B, Cin;
	input logic [2:0] cntrl;
	output logic Cout, result;
	

	logic addOut, addOrSubOut, notBOutput, aAndBOutput, aOrBOutput, aXorBOutput, notCntrl2, cntrl1, subtract;
	not #50 notB(notBOutput, B);
	
	//creates subtract signal.
	not #50 notcntrl2 (notCntrl2, cntrl[2]);
	and #50 cntrl1and (cntrl1, notCntrl2, cntrl[1]);
	and #50 subtractionSig (subtract, cntrl1, cntrl[0]);
	
	
	mux2_1 addOrSub (.out(addOrSubOut), .i0(B), .i1(notBOutput), .sel(subtract));
	
	fulladder add (.A(A), .B(addOrSubOut), .Cin(Cin), .Cout(Cout), .S(addOut));
	
	
	and #50 aAndB (aAndBOutput, A, B);
	or #50 aOrB (aOrBOutput, A,B);
	xor #50 aXorB (aXorBOutput, A, B);
	
	mux8_1 aluMux (.i0(B),.i1(1'b0),.i2(addOut),.i3(addOut),.i4(aAndBOutput),.i5(aOrBOutput),.i6(aXorBOutput),.i7(1'b0),.sel0(cntrl[0]),.sel1(cntrl[1]),.sel2(cntrl[2]),.out(result));
		
	
endmodule 

module alu_1bit_testbench();
	logic A, B, Cin, Cout, result;
	logic [2:0] cntrl;
	
	alu_1bit dut(.*);
	
	initial begin 
		A = 0; B = 0; Cin = 0; cntrl = 0; #1000; // expect out and cout to be zero
		
		for (int i = 0; i < 8; i++) begin 
			cntrl = i; #1000;
		end 
		
		
		A = 1; B = 1; #1000;
		
		for (int i = 0; i < 8; i++) begin 
			cntrl = i; #1000;
		end 
		
		A = 1; B = 0; #1000;
		
		for (int i = 0; i < 8; i++) begin 
			cntrl = i; #1000;
		end 
		
		A = 1; B = 1; Cin = 1; #1000;
		
		for (int i = 0; i < 8; i++) begin 
			cntrl = i; #1000;
		end 
		
	
		$stop;
	end 


endmodule 
