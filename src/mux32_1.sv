//mux32_1
module mux32_1(i,sel0,sel1,sel2,sel3,sel4,out);
	
	output logic out; 
	
	input logic [31:0] i;
	input logic sel0,sel1,sel2,sel3,sel4;
	
	logic mux0;
	logic mux1;
	logic mux2; 
	logic mux3; 
	
	mux8_1 r0(.i0(i[0]),.i1(i[1]),.i2(i[2]),.i3(i[3]),.i4(i[4]),.i5(i[5]),.i6(i[6]),.i7(i[7]),.sel0(sel0),.sel1(sel1),.sel2(sel2),.out(mux0));
	mux8_1 r1(.i0(i[8]),.i1(i[9]),.i2(i[10]),.i3(i[11]),.i4(i[12]),.i5(i[13]),.i6(i[14]),.i7(i[15]),.sel0(sel0),.sel1(sel1),.sel2(sel2),.out(mux1));
	mux8_1 r2(.i0(i[16]),.i1(i[17]),.i2(i[18]),.i3(i[19]),.i4(i[20]),.i5(i[21]),.i6(i[22]),.i7(i[23]),.sel0(sel0),.sel1(sel1),.sel2(sel2),.out(mux2));
	mux8_1 r3(.i0(i[24]),.i1(i[25]),.i2(i[26]),.i3(i[27]),.i4(i[28]),.i5(i[29]),.i6(i[30]),.i7(i[31]),.sel0(sel0),.sel1(sel1),.sel2(sel2),.out(mux3));
	mux4_1 r4(.i0(mux0),.i1(mux1),.i2(mux2),.i3(mux3),.sel0(sel3),.sel1(sel4),.out(out));
	
endmodule 
	
module mux32_1_testbench();

    logic [31:0] i;                  
    logic sel0, sel1, sel2, sel3, sel4;
    logic out;

    // DUT
    mux32_1 dut (
        .i(i),
        .sel0(sel0), .sel1(sel1), .sel2(sel2), .sel3(sel3), .sel4(sel4),
        .out(out)
    );


    initial begin
        integer k;
        for (k = 0; k < 32; k++) begin
            i[k] = k; 
        end

        sel0=0; sel1=0; sel2=0; sel3=0; sel4=0;

        for (k = 0; k < 32; k++) begin
				#10 {sel4,sel3,sel2,sel1,sel0} = k;
        end

        #10;
    end
endmodule
