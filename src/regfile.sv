//32x64 register file written in verilog. Top level designed according to the pattern in first figure
// will construct this register file using other modules


module regfile (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, clk);
	input logic RegWrite, clk;
	input logic [4:0] ReadRegister1, ReadRegister2, WriteRegister;
	input logic [63:0] WriteData;
	output logic [63:0] ReadData1, ReadData2;
	
	logic [31:0] dc532Output; // we skip one because for last register the value is zero REMEMBER. This is the ENABLE for the 64 bit regs all 32 of them
	dc532 dc (.enable(RegWrite), .s(WriteRegister), .d(dc532Output));
	
	logic [63:0] regOutputs [31:0]; 
	assign regOutputs[31] = 64'b0; // apply assign statement to make last register index 31 0 value.

	genvar i;
	
	generate 
	for (i = 0; i < 31; i++) begin: eachReg // we do < 31 because we only want 31 registers, because reg 32 is zero. So no need to make it
		register64 register (.d(WriteData), .q(regOutputs[i]), .enable(dc532Output[i]), .reset(1'b0), .clk);
	
	end 
	endgenerate
	
	mux32x64_64 mux1 (.out(ReadData1), .i(regOutputs), .sel0(ReadRegister1[0]), .sel1(ReadRegister1[1]), .sel2(ReadRegister1[2]), .sel3(ReadRegister1[3]), .sel4(ReadRegister1[4]));
	
	mux32x64_64 mux2 (.out(ReadData2), .i(regOutputs), .sel0(ReadRegister2[0]), .sel1(ReadRegister2[1]), .sel2(ReadRegister2[2]), .sel3(ReadRegister2[3]), .sel4(ReadRegister2[4]));
	

endmodule 
