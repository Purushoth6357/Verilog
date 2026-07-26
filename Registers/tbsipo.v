`timescale 1ns/1ps

module tbsipo;

reg clk;
reg rst;
reg SI;
wire [3:0]PO;

sipo4breg uut(.clk(clk), .rst(rst), .SI(SI), .PO(PO));

initial clk = 0;

always #5 clk = ~clk;

initial begin

    $dumpfile("tbsipo.vcd");
    $dumpvars(0, tbsipo);

    //initial values
    rst = 1'b1;
    SI = 1'b0;

    #5;
    rst = 1'b0;
    SI = 1'b1; #10;
    SI = 1'b0; #10;
    SI = 1'b0; #10;
    SI = 1'b1; #17;

    SI = 1'b0; #10;
    SI = 1'b1; #10;
    SI = 1'b1; #10;
    SI = 1'b0; #14;

    SI = 1'b1; #10;

    $finish;


end
endmodule