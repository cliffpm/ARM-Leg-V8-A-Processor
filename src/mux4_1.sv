//4_1mux
module mux4_1(i0,i1,i2,i3,sel0,sel1,out);
	output logic out;
	input logic i0, i1, i2, i3, sel0, sel1; 
	
	logic mux0; 
	logic mux1;
	
	mux2_1 r0(.out(mux0), .i0(i0), .i1(i1), .sel(sel0));
	mux2_1 r1(.out(mux1), .i0(i2), .i1(i3), .sel(sel0));
	mux2_1 r2(.out(out), .i0(mux0), .i1(mux1), .sel(sel1));
	
endmodule 
	
	
module mux4_1_testbench();
	logic i0, i1, i2, i3;
	logic sel0, sel1;
   logic out;

	//DUT
   mux4_1 dut (.i0(i0), .i1(i1), .i2(i2), .i3(i3),.sel0(sel0), .sel1(sel1),.out(out));
	
	initial begin
	#10 sel0 = 1; sel1 = 0; // i1
   #10 sel0 = 0; sel1 = 1; // i2
   #10 sel0 = 1; sel1 = 1; // i3

   #10 i0 = 1; i1 = 0; i2 = 1; i3 = 0;
		 sel0 = 0; sel1 = 0; // i0
   #10 sel0 = 1; sel1 = 0; // i1
   #10 sel0 = 0; sel1 = 1; // i2
   #10 sel0 = 1; sel1 = 1; // i3

   #10 $finish;
   end
endmodule

