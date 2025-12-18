`timescale 1ps/1ps


module nor64(out, in);
	input logic [63:0] in;
	output logic out;
	
	logic n1out, n2out, n3out, n4out, n5out, n6out, n7out, n8out, n9out, n10out, n11out, n12out, n13out, n14out, n15out, n16out;
	
	nor #50 nor1 (n1out, in[0], in[1], in[2], in[3]);
	nor #50 nor2  (n2out,  in[4],  in[5],  in[6],  in[7]);
	nor #50 nor3  (n3out,  in[8],  in[9],  in[10], in[11]);
	nor #50 nor4  (n4out,  in[12], in[13], in[14], in[15]);
	nor #50 nor5  (n5out,  in[16], in[17], in[18], in[19]);
	nor #50 nor6  (n6out,  in[20], in[21], in[22], in[23]);
	nor #50 nor7  (n7out,  in[24], in[25], in[26], in[27]);
	nor #50 nor8  (n8out,  in[28], in[29], in[30], in[31]);
	nor #50 nor9  (n9out,  in[32], in[33], in[34], in[35]);
	nor #50 nor10 (n10out, in[36], in[37], in[38], in[39]);
	nor #50 nor11 (n11out, in[40], in[41], in[42], in[43]);
	nor #50 nor12 (n12out, in[44], in[45], in[46], in[47]);
	nor #50 nor13 (n13out, in[48], in[49], in[50], in[51]);
	nor #50 nor14 (n14out, in[52], in[53], in[54], in[55]);
	nor #50 nor15 (n15out, in[56], in[57], in[58], in[59]);
	nor #50 nor16 (n16out, in[60], in[61], in[62], in[63]);

	logic a1, a2, a3, a4;
	
	and #50 and1 (a1, n1out, n2out, n3out, n4out);
	
	and #50 and2 (a2, n5out, n6out, n7out, n8out);
	
	and #50 and3 (a3, n9out, n10out, n11out, n12out);
	
	and #50 and4 (a4, n13out, n14out, n15out, n16out);
	
	// final AND
	and #50 lastAnd (out, a1, a2, a3, a4);
	
	
	
	// now if ALL are zero, then that means all 16 outputs of each NOR gate is 1
	// if we AND all these we should get 1 as final result assuming in IS zero
	
endmodule 