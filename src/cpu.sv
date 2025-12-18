`timescale 1ps/1ps

module cpu(clk, reset);
	input logic clk, reset;
	
	logic [63:0] BrTakenOutput, PCoutput, registerPCoutput; // Program Counter I/O
	logic [31:0] instruction; // InstructionMemory Output
	logic [18:0] CondAddr19;
	logic [25:0] BrAddr26;
	logic [63:0] CondAddr19Extend, BrAddr26Extend, UncondBrOutput, shiftedUncondBrOutput, PCplusBranch, PCplus4Out;
	logic RegWriteMEM, RegWriteWB;
	logic [4:0] MEMrd, WBrd;
	logic UncondBr, BrTaken, Reg2Loc, RegWrite, MemWrite, MemToReg, writeFlag, isS;
	logic [2:0] ALUOp, ALUOpEX;
	logic [1:0] ALUSrc, ALUSrcEX; // chooses 4 vals of ALUSRC MUX
	logic [63:0] dataMemoryOutput, registeredMemToReg, PREMemToRegOutput;
	logic [31:0] preregInstruction;
	// main ALU flag outputs:
	logic zeroStatus, overflowStatus, carryStatus, negativeStatus;
	
	// the current flag(s) contained in the flag register.
	logic flagNegative, flagZero, flagOverflow, flagCarry;
	
	logic isSinstruction, isStur, isCondBr;
	
	logic RegWriteEX, MemWriteEX, MemToRegEX, MemWriteMEM, MemToRegMEM;
	
	logic [4:0] EXrd;
	
	logic isCBZ;
	logic [1:0] forwardCBZ;
	
	
	// Instruction Fetch Stage **************************************************************************************
	// (The control signals all generate here. So for branches, we would get the branch signals in this stage)
	pc programCounter (.in(BrTakenOutput), .out(PCoutput), .clk(clk), .reset(reset)); // instantiate the program counter
	
	instructmem instructionMemory (.address(PCoutput), .instruction(preregInstruction), .clk(clk)); // instruction memory module to fetch instruction
	
	D_FF32 regInstruction (.in(preregInstruction),.out(instruction), .clk, .reset);
	D_FF64 registerPC (.in(PCoutput), .out(registerPCoutput), .clk, .reset);
	
	//Register Fetch Stage (ID) *******************************************************************************************
	// BTW from this stage until WB stage, we have to pass down the RD 5 bit, which will get inputted into the AddressWrite of registerfile
	// ALSO this stage is when the control signals are generated 
	// Registers from machine code instruction
	logic [4:0]  Rd, Rm, Rn;
	logic [5:0] SHAMT;
	logic forwardFlag;
	
	assign Rd = instruction [4:0];
	assign Rm = instruction [20:16];
	assign Rn = instruction [9:5];
	assign SHAMT = instruction [15:10];
	
	assign CondAddr19 = instruction [23:5];
	assign BrAddr26 = instruction [25:0];
	
	
	logic [8:0] DAddr9, registerDaddr9;
	logic [11:0] imm12, registerImm12;
	
	
	
	logic [63:0] mainALUoutput, PREmainALUOutput, registeredStur2;

	
	
	assign imm12 = instruction[21:10]; 
	assign DAddr9 = instruction[20:12];
	
	signExtend #(.WIDTH(19)) extendCondAddr19 (.in(CondAddr19), .out(CondAddr19Extend));
	signExtend #(.WIDTH(26)) extendBrAddr26 (.in(BrAddr26), .out(BrAddr26Extend)); 
	
	mux2_1_64 condOrRegBranchOut (.out(UncondBrOutput), .i1(BrAddr26Extend), .i0(CondAddr19Extend), .sel(UncondBr)); // picks the cond branch or reg branch
	
	shifter shiftUncondBr (.value(UncondBrOutput), .direction(0), .distance(2), .result(shiftedUncondBrOutput)); // shift branch vals by 2 left (mul by 4 bc 4 bytes per instruction)
	
	alu addPCandBranch (.A(registerPCoutput), .B(shiftedUncondBrOutput), .cntrl(3'b010), .result(PCplusBranch), .negative(), .zero(), .overflow(), .carry_out()); // pc = pc + branchVal
	
	alu PCplus4 (.A(PCoutput), .B(64'd4), .cntrl(3'b010), .result(PCplus4Out), .negative(), .zero(), .overflow(), .carry_out()); // pc += 4
	
	mux2_1_64 plus4OrBranchVal (.out(BrTakenOutput), .i1(PCplusBranch), .i0(PCplus4Out), .sel(BrTaken)); // sels between pc += 4 or pc += branchVal
	

	
	logic [4:0] RdorRmOutput;
	mux2_1_5 RdorRm (.out(RdorRmOutput), .i0(Rd), .i1(Rm), .sel(Reg2Loc)); // REG2LOC MUX

	logic [63:0] Da, Db, MemToRegOutput; 
	
	logic invClock;
	not #50 notclock (invClock, clk);
	
	regfile registerFile (.ReadData1(Da), .ReadData2(Db), .WriteData(MemToRegOutput), .ReadRegister1(Rn), .ReadRegister2(RdorRmOutput), .WriteRegister(WBrd), .RegWrite(RegWriteWB), .clk(invClock));
	
	logic [63:0] ALUsrcMuxOut, signExtendedDAddr9, zeroExtendedImm12, shiftedRn;
	
	// these go through the ID_EX register
	D_FF9 registeringDaddr9 (.in(DAddr9), .out(registerDaddr9), .clk, .reset);	
	D_FF12 registeringImm12 (.in(imm12), .out(registerImm12),.clk,.reset);
	
// Forwarding control definitions
/*  3 is zero if we forward X31 which is zero.
	2 is forward from mem stage (2 above)
	1 is forward from ex stage (1 above)
	0 is just use the value currently in the register file 
*/
	logic [63:0] forwardedRegForCBZ;
	
	mux_4_1_64 forwardingCBZreg (.i0(Db), .i1(PREmainALUOutput), .i2(PREMemToRegOutput), .i3(64'b0), .sel(forwardCBZ), .out(forwardedRegForCBZ));
	
	logic DaIsZero;
	nor64 zeroParallel (.in(forwardedRegForCBZ), .out(DaIsZero)); // this is for CBZ to check if reg[rd] == 0
	


	// Make registers for the input port of A and B that is the output of the registerFIle
	
	logic [63:0] registeredA, registeredB, forwardingAout, forwardingBout, sturMuxOut, registeredStur1;
	logic [1:0] forwardA, forwardB, STURcntrl; // selection
	// FORWARDING MUXES: 0 = 64'b0 , 1 = MEM2REG value, 2 = ALUOUTPUT value, 3 = REGULAR VALUE
			
			

	// these 3 muxes are for forwarding rn/rm for port a and b, and rd for the datawrite for datamem for STUR.
	mux_4_1_64 forwardingMuxA (.i0(64'b0), .i1(PREMemToRegOutput), .i2(PREmainALUOutput), .i3(Da), .sel(forwardA), .out(forwardingAout));
	
	mux_4_1_64 forwardingMuxB (.i0(64'b0), .i1(PREMemToRegOutput), .i2(PREmainALUOutput), .i3(Db), .sel(forwardB), .out(forwardingBout));
	
	mux_4_1_64 STURforwardingMux (.i0(64'b0), .i1(PREMemToRegOutput), .i2(PREmainALUOutput), .i3(Db), .sel(STURcntrl), .out(sturMuxOut));

	D_FF64 regAinputForALU (.in(forwardingAout), .out(registeredA), .clk, .reset);
	D_FF64 regBinputForALU (.in(forwardingBout), .out(registeredB), .clk, .reset);
	
	logic [4:0] RFrd;
	
	
	
	D_FF5 registeringRd1 (.in(Rd), .out(RFrd), .clk, .reset);
	D_FF5 registeringrd2 (.in(RFrd), .out(EXrd), .clk, .reset);
	D_FF5 registeringrd3 (.in(EXrd), .out(WBrd), .clk, .reset);
//	D_FF5 registeringrd4 (.in(MEMrd), .out(WBrd), .clk, .reset);

	
	

	logic [31:0] instructionEX, instructionMEM;
	D_FF32 instructionForwarding1 (.in(instruction), .out(instructionEX), .clk, .reset); // one above instruction
	D_FF32 instructionForwarding2 (.in(instructionEX), .out(instructionMEM), .clk, .reset); // two above instruction
	
	
	D_FF64 sturForwarding1 (.in(sturMuxOut), .out(registeredStur1), .clk, .reset);
	D_FF64 sturForwarding2 (.in(registeredStur1), .out(registeredStur2), .clk, .reset);

	
	D_FF2 ALUSrcRegister 	  (.in(ALUSrc), .out(ALUSrcEX), .clk, .reset);
	
	
	D_FF3 ALUOpRegister 	  (.in(ALUOp), .out(ALUOpEX), .clk, .reset);
	
	
	
	D_FF MemWriteRegister1 (.d(MemWrite), .q(MemWriteEX), .clk, .reset);
	D_FF MemWriteRegister2 (.d(MemWriteEX), .q(MemWriteMEM), .clk, .reset);

	
	D_FF MemToRegRegister1 (.d(MemToReg), .q(MemToRegEX), .clk, .reset);
	D_FF MemToRegRegister2 (.d(MemToRegEX), .q(MemToRegMEM), .clk, .reset);

	
	D_FF RegWriteRegister1 (.d(RegWrite), .q(RegWriteEX), .clk, .reset);
	D_FF RegWriteRegister2 (.d(RegWriteEX), .q(RegWriteMEM), .clk, .reset);
	D_FF RegWriteRegister4 (.d(RegWriteMEM), .q(RegWriteWB), .clk, .reset);

	
	logic EXisS;
	D_FF SinstructionEX (.d(isS), .q(EXisS), .clk, .reset);
	
	
  logic writeFlagEX, writeFlagMEM, writeFlagWB; // (use the writeFlagWB so that all flag registers are written at the WB stage.
																// this is to follow along since we are doing all write operations in WB
   D_FF exWriteFlag (.d(writeFlag), .q(writeFlagEX), .clk, .reset);
	
	

	
	
	// EX STAGE *********************************************************************************************************************
	
	signExtend #(.WIDTH(9)) Daddr9SE (.in(registerDaddr9), .out(signExtendedDAddr9));
	zeroExtend #(.WIDTH(12)) imm12ZE (.in(registerImm12), .out(zeroExtendedImm12));
	
	logic [5:0] registeredSHAMT;
	D_FF6 registeringSHAMT (.in(SHAMT), .out(registeredSHAMT), .clk, .reset);
	shifter shifterRn (.value(registeredA), .direction(1), .distance(registeredSHAMT), .result(shiftedRn));	// for LSR
	
	mux_4_1_64 ALUsrcMux (.i0(registeredB), .i1(signExtendedDAddr9), .i2(zeroExtendedImm12), .i3(shiftedRn), .sel(ALUSrcEX), .out(ALUsrcMuxOut));

	
	
	logic forwardedZero, forwardedOverflow, forwardedNegative, forwardedCarry;

	
	// 0 is the old value 1 is the new value.
	
	mux2_1 forwardingNegativeFlag (.out(forwardedNegative), .i0(flagNegative), .i1(negativeStatus), .sel(forwardFlag));
	mux2_1 forwardingOverflowFlag (.out(forwardedOverflow), .i0(flagOverflow), .i1(overflowStatus), .sel(forwardFlag));
	
	alu mainALU (.A(registeredA), .B(ALUsrcMuxOut), .cntrl(ALUOpEX), .result(PREmainALUOutput), .negative(negativeStatus), .zero(zeroStatus), .overflow(overflowStatus), .carry_out(carryStatus));
		
	D_FF64 registeringALUoutput (.in(PREmainALUOutput), .out(mainALUoutput), .clk, .reset);
	
	// MEM STAGE ********************************************************************************************************************
	
	logic WBzero, WBoverflow, WBnegative, WBcarryout;
	
	logic readSig;
	or #50 memRegOrWrite (readSig, MemToRegEX, MemWriteEX);
	
	datamem dataMemory (.address(mainALUoutput), .write_enable(MemWriteMEM), .read_enable(1), .write_data(registeredStur2), .clk, .xfer_size(4'b1000), .read_data(dataMemoryOutput));
	mux2_1_64 memToRegMux (.out(PREMemToRegOutput), .i1(dataMemoryOutput), .i0(mainALUoutput), .sel(MemToRegMEM));
	
	D_FF64 registeringMemToReg (.in(PREMemToRegOutput), .out(MemToRegOutput), .clk, .reset);
	
	
	
		
	// The Flag Register
	enableDFF zeroFlagRegister (.d(zeroStatus), .q(flagZero), .clk(clk), .reset(reset), .enable(forwardFlag));
	enableDFF negativeFlagRegister (.d(negativeStatus), .q(flagNegative), .clk(clk), .reset(reset), .enable(forwardFlag));
	enableDFF overflowFlagRegister (.d(overflowStatus), .q(flagOverflow), .clk(clk), .reset(reset), .enable(forwardFlag));
	enableDFF carryFlagRegister (.d(carryStatus), .q(flagCarry), .clk(clk), .reset(reset), .enable(forwardFlag));
	

	// FORWARDING CONTROL HERE:
	// this is to control our signals for the muxA and muxB.
	logic [4:0] currInstructionRM, currInstructionRN, oneAboveInstructionRD, twoAboveInstructionRD, currInstructionRD;
	assign currInstructionRM = instruction[20:16];
	assign currInstructionRN = instruction[9:5];
	assign oneAboveInstructionRD = instructionEX[4:0];
	assign twoAboveInstructionRD = instructionMEM[4:0];
	assign currInstructionRD = instruction[4:0];
	
	logic [4:0] preregInstructionRM, preregInstructionRN, preregInstructionRD;
	assign preregInstructionRM = preregInstruction[20:16];
	assign preregInstructionRN = preregInstruction[9:5];
	assign preregInstructionRD = preregInstruction[4:0];
	

	// forwarding logic
	always_comb begin
		// default case: just the same values.
		forwardA = 2'b11;
		forwardB = 2'b11;
		STURcntrl = 2'b11;
		forwardFlag = 1'b0; // no forwarding flag 
		forwardCBZ = 2'd0;
		
		if (isCBZ) begin 
			if (currInstructionRD == oneAboveInstructionRD ) begin 
				if (currInstructionRD == 5'b11111) forwardCBZ = 2'd3;
				else forwardCBZ = 2'd1;
			end 
			else if (currInstructionRD == twoAboveInstructionRD) begin 
				if (currInstructionRD == 5'b11111) forwardCBZ = 2'd3;
				else forwardCBZ = 2'd2;
			end 
			
		
		end 
		
		// FORWARDING FLAGS HERE:
		if (isCondBr && EXisS) begin 
			forwardFlag = 1'b1;
		end 
		
		
		// STUR EDGE CASE, forwarding RD.
		
		if (isStur) begin 
			if (currInstructionRD == oneAboveInstructionRD) begin 
				if (currInstructionRD == 5'b11111) STURcntrl = 2'd0;
				else STURcntrl = 2'd2;
			end 
			else if (currInstructionRD == twoAboveInstructionRD) begin 
				if (currInstructionRD == 5'b11111) STURcntrl = 2'd0;
				else STURcntrl = 2'd1;
			end 
		end 
		
		
		// forwarding for RN and RM
		
		if (currInstructionRN == oneAboveInstructionRD && RegWriteEX) begin 
			if (currInstructionRN == 5'b11111) forwardA = 2'b0;
			else forwardA =2'd2;
		end 
		else if (currInstructionRN == twoAboveInstructionRD && RegWriteMEM) begin 
			if (currInstructionRN == 5'b11111) forwardA = 2'b0;
			else forwardA = 2'd1;
		end 
		
		if (currInstructionRM == oneAboveInstructionRD && RegWriteEX) begin 
			if(currInstructionRM == 5'b11111) forwardB = 2'b0;
			else forwardB = 2'd2;
		end 
		else if (currInstructionRM == twoAboveInstructionRD && RegWriteMEM) begin 
			if(currInstructionRM == 5'b11111) forwardB = 2'b0;
			else forwardB = 2'd1;
		end 	
	end 

	
	
	/*
	Control Meanings for ALU control:
	
	// 000:			result = B						value of overflow and carry_out unimportant
	// 010:			result = A + B
	// 011:			result = A - B
	// 100:			result = bitwise A & B		value of overflow and carry_out unimportant
	// 101:			result = bitwise A | B		value of overflow and carry_out unimportant
	// 110:			result = bitwise A XOR B	value of overflow and carry_out unimportant
	
	*/
	
    // OP CODE control decomposition
	always_comb begin
		isCBZ = 1'b0;
		isStur = 1'b0; 
		isS = 1'b0; // S instruction requires updating flag register
		isCondBr = 1'b0;
		casex(instruction[31:21])
			11'b1001000100X: begin // ADDI
				UncondBr = 1'bX;
				BrTaken = 1'b0;
				Reg2Loc = 1'bX;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				writeFlag = 1'b0;
				ALUOp = 3'b010;
				ALUSrc = 2'd2;
			end 
			
			11'b10101011000: begin // ADDS
				UncondBr = 1'bX;
				BrTaken = 1'b0;
				Reg2Loc = 1'b1;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				writeFlag = 1'b1;
				ALUOp = 3'b010;
				ALUSrc = 2'd0;
				isS = 1'b1;
			end 
			
			11'b10001010000: begin // AND
				UncondBr = 1'bX;
				BrTaken = 1'b0;
				Reg2Loc = 1'b1;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				writeFlag = 1'b0;
				ALUOp = 3'b100;
				ALUSrc = 2'd0;
			end 
			
			11'b000101XXXXX: begin  // B ( branch )
				UncondBr = 1'b1;
				BrTaken = 1'b1;
				Reg2Loc = 1'bX;
				RegWrite = 1'b0;
				MemWrite = 1'b0;
				MemToReg = 1'bX;
				writeFlag = 1'b0;
				ALUOp = 3'bX;
				ALUSrc = 2'bX;
			
			
			end 
			11'b01010100XXX: begin // B.Cond
				UncondBr = 1'b0;
				BrTaken = forwardedOverflow ^ forwardedNegative;
				Reg2Loc = 1'bX;
				RegWrite = 1'b0;
				MemWrite = 1'b0;
				MemToReg = 1'bX;
				writeFlag = 1'b0;
				ALUOp = 3'bX;
				ALUSrc = 2'bX;
				isCondBr = 1'b1;
			end 
			
			11'b10110100XXX: begin // CBZ 
				isCBZ = 1'b1;
				UncondBr = 1'b0;
				BrTaken = DaIsZero; 
				Reg2Loc = 1'b0;
				RegWrite = 1'b0;
				MemWrite = 1'b0;
				MemToReg = 1'bX;
				writeFlag = 1'b0;
				ALUOp = 3'b000;
				ALUSrc = 2'b0;
			end
			11'b11001010000: begin // XOR
				UncondBr = 1'bX;
				BrTaken = 1'b0;
				Reg2Loc = 1'b1;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				writeFlag = 1'b0;
				ALUOp = 3'b110;
				ALUSrc = 2'd0;
			end 
			
			11'b11111000010: begin // LDUR
				UncondBr = 1'bX;
				BrTaken = 1'b0;
				Reg2Loc = 1'bX;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				MemToReg = 1'b1;
				writeFlag = 1'b0;
				ALUOp = 3'b010;
				ALUSrc = 2'd1;
			
			end 
			
			11'b11010011010: begin // LSR
				UncondBr = 1'bX;
				BrTaken = 1'b0;
				Reg2Loc = 1'bX;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				writeFlag = 1'b0;
				ALUOp = 3'b000; /
				ALUSrc = 2'd3;
			end 
			
			11'b11111000000: begin // STUR 
				UncondBr = 1'bX;
				BrTaken = 1'b0;
				Reg2Loc = 1'b0;
				RegWrite = 1'b0;
				MemWrite = 1'b1;
				MemToReg = 1'bX;
				writeFlag = 1'b0;
				ALUOp = 3'b010;
				ALUSrc = 2'd1;
				isStur = 1'b1;
			end 
			
			11'b11101011000: begin // SUBS
				UncondBr = 1'bX;
				BrTaken = 1'b0;
				Reg2Loc = 1'b1;
				RegWrite = 1'b1;
				MemWrite = 1'b0;
				MemToReg = 1'b0;
				writeFlag = 1'b1;
				ALUOp = 3'b011;
				ALUSrc = 2'd0;
				isS = 1'b1;
			end 
		endcase 
	end 
endmodule 

module cpu_testbench();
	logic clk, reset;
	
	cpu dut(clk, reset);
	
	parameter CLOCK_PERIOD=10000;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin 
		$display("starting");
		reset <= 1; repeat(4)@(posedge clk);
		reset <= 0; repeat(2000)@(posedge clk);
		$display("finished");
		$stop;
	end 
endmodule 