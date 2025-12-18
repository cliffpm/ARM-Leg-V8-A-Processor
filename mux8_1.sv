//8_1mux
module mux8_1(i0,i1,i2,i3,i4,i5,i6,i7,sel0,sel1,sel2,out);
	output logic out;
	input logic i0,i1,i2,i3,i4,i5,i6,i7,sel0,sel1,sel2; 
	
	logic mux0;
	logic mux1; 
	
	mux4_1 r0(.i0(i0),.i1(i1),.i2(i2),.i3(i3),.sel0(sel0),.sel1(sel1),.out(mux0));
	mux4_1 r1(.i0(i4),.i1(i5),.i2(i6),.i3(i7),.sel0(sel0),.sel1(sel1),.out(mux1));
	mux2_1 r2(.out(out), .i0(mux0), .i1(mux1), .sel(sel2));
	
endmodule 
	
module mux8_1_testbench();

	logic i0,i1,i2,i3,i4,i5,i6,i7;
	logic sel0,sel1,sel2;
	logic out;

	//DUT
	mux8_1 dut (.i0(i0),.i1(i1),.i2(i2),.i3(i3),.i4(i4),.i5(i5),.i6(i6),.i7(i7),
	.sel0(sel0),.sel1(sel1),.sel2(sel2),.out(out));

   initial begin

   i0=0; i1=1; i2=0; i3=1;
   i4=0; i5=1; i6=0; i7=1;
   sel0=0; sel1=0; sel2=0;


   #10 sel0=1; sel1=0; sel2=0; 
   #10 sel0=0; sel1=1; sel2=0; 
   #10 sel0=1; sel1=1; sel2=0; 
   #10 sel0=0; sel1=0; sel2=1; 
   #10 sel0=1; sel1=0; sel2=1; 
   #10 sel0=0; sel1=1; sel2=1; 
   #10 sel0=1; sel1=1; sel2=1; 

   #10 i0=1; i1=0; i2=1; i3=0;
       i4=1; i5=0; i6=1; i7=0;
       sel0=0; sel1=0; sel2=0; 
   #10 sel0=1; sel1=0; sel2=0; 
   #10 sel0=0; sel1=1; sel2=1; 
   #10 sel0=1; sel1=1; sel2=1; 

	#10;
   end
endmodule
