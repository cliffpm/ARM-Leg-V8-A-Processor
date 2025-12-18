
// 64 d flip flops in parallel to form a 64 bit register. Meaning the input D and Q are 64 bits
module register64 (d,q,clk,enable, reset);
	input logic clk, enable, reset;
	input logic [63:0] d;
	output logic [63:0] q;
	
	genvar i;
	
	generate 
		for (i = 0; i < 64; i++) begin: eachDFF
			enableDFF dflop (.d(d[i]), .q(q[i]), .clk(clk), .reset(reset), .enable(enable));
		end
	endgenerate 
	
endmodule 


module register64_testbench();
	logic clk, enable, reset;
	logic [63:0] d, q;
	
	
	register64 dut (.*);
	
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin 
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
		enable <= 1; d <= 1; @(posedge clk);
		repeat(25)@(posedge clk);
		enable <= 0; d <= 0; @(posedge clk);
		enable <= 1;  @(posedge clk);
		repeat(25)@(posedge clk);

		$stop;
	
	end 




endmodule 
