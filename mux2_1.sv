//2_1mux
`timescale 1ps/1ps
module mux2_1(out, i0, i1, sel);
    output logic out;
    input  logic i0, i1, sel;

    logic nsel; 
    logic a0, a1;  
    generate
        not #50 u_not (nsel, sel);
        and #50 u_and0 (a0, i0, nsel);
        and #50 u_and1 (a1, i1, sel);
        or  #50 u_or0  (out, a0, a1);
    endgenerate
endmodule


module mux2_1_testbench();
    logic i0, i1, sel;
    logic out;

    // DUT 
    mux2_1 dut (.out(out), .i0(i0), .i1(i1), .sel(sel));

    initial begin
        sel=0; i0=0; i1=0; #10;
        sel=0; i0=0; i1=1; #10;
        sel=0; i0=1; i1=0; #10;
        sel=0; i0=1; i1=1; #10;
        sel=1; i0=0; i1=0; #10;
        sel=1; i0=0; i1=1; #10;
        sel=1; i0=1; i1=0; #10;
        sel=1; i0=1; i1=1; #10;
      
    end
endmodule
