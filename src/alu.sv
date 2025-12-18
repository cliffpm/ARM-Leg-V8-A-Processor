`timescale 1ps/1ps

module alu(A, B, cntrl, result, negative, zero, overflow, carry_out);

	input logic [63:0] A, B;
	input logic [2:0] cntrl;
	
	output logic zero, overflow, negative, carry_out;
	output logic [63:0] result;
	
	
	genvar i;
	logic [63:0] carryOut;
	
	
	logic notCntrl2, cntrl1, subtract; 
	
	// creating a subtract signal so we know when to add 1 (Cin) to the LSB bit ALU
	not #50 notcntrl2 (notCntrl2, cntrl[2]);
	and #50 cntrl1and (cntrl1, notCntrl2, cntrl[1]);
	and #50 subtractionSig (subtract, cntrl1, cntrl[0]);
	
	alu_1bit alu(.A(A[0]), .B(B[0]), .Cout(carryOut[0]), .Cin(subtract), .result(result[0]), .cntrl(cntrl));
	
	generate
	
		
		for (i = 1; i < 64; i++) begin: eachAlu
			alu_1bit alu (.A(A[i]), .B(B[i]), .Cout(carryOut[i]), .Cin(carryOut[i-1]), .result(result[i]), .cntrl(cntrl));
		
		end
	
	
	endgenerate 
	
	xor #50 overflowCheck (overflow, carryOut[63], carryOut[62]);
	
	assign negative = result[63]; // if MSB is 1, result is negative
	assign carry_out = carryOut[63];
	
	// now need to NOR all the result values but can have atmost 4 inputs per gate
	nor64 zeroChecker (.out(zero), .in(result));
	
	/*
	Control Meanings:
	
	// 000:			result = B						value of overflow and carry_out unimportant
	// 010:			result = A + B
	// 011:			result = A - B
	// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
	// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
	// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
	
	*/
	
	

endmodule
