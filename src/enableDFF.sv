module enableDFF(d, q, clk, reset, enable);
	
	// idea : When enable is high, then we pass to Q the new D, else we keep the old D
	// so that should imply we use a mux, since we have two options (new D or old) then its a 2:1 mux
	input logic d, clk, reset, enable;
	output logic q;
	logic muxout;
	
	mux2_1 mul(.out(muxout), .i0(q), .i1(d), .sel(enable));
	D_FF dflop (.q(q), .d(muxout), .reset, .clk);

endmodule 

module enableDFF_testbench ();

	logic d,q,clk,reset,enable;
	
	enableDFF dut (.*);
	
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk; // Forever toggle the clock
	end
	
	initial begin
		reset <= 1; enable <= 1; @(posedge clk);
		reset <= 0; d <= 1; @(posedge clk);
		
		enable <= 0; @(posedge clk);
		d <= 0; @(posedge clk); // should not hold 0 and should still be 1 because enable is off.
		
		enable <= 1; @(posedge clk);
		repeat(25)@(posedge clk);
		// should now hold the new value of 0 in Q.
	$stop;
	end 


endmodule 