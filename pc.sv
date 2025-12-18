
`timescale 1ps/1ps

module pc(in, out, clk,reset);
	input logic [63:0] in;
	input logic clk, reset;
	output logic [63:0] out;

	genvar i;
	
	generate
		for (i = 0; i < 64; i++) begin: eachDFF
			D_FF dflop (.q(out[i]), .d(in[i]), .reset(reset), .clk(clk));
		end 
	
	endgenerate
	
endmodule 

module pc_testbench();

	logic [63:0] in, out;
	logic clk, reset;
	
	pc dut (.*);

	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end

	
	initial begin 

		reset <= 1; repeat(25)@(posedge clk);
		reset <= 0; @(posedge clk);
		repeat(20)@(posedge clk);
		in <= $random(); @(posedge clk);
		
		
		in <= $random(); @(posedge clk);
		
	
		in <= $random(); @(posedge clk);
		
		
		in <= $random(); @(posedge clk);
		
		
		
		assert (in == out) @(posedge clk);
		$stop;
		
	end 

endmodule 