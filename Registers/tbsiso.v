`timescale 1ns / 100ps

module tbsiso; 
    reg clk;
    reg rst;
    reg SI;
    wire SO;

    siso_4bit uut (
        .clk(clk),
        .rst(rst),
        .SI(SI),
        .SO(SO)
    );

    initial clk = 0;
    always #5 clk = ~clk; 

    initial begin 
        $dumpfile("tbsiso.vcd");
        $dumpvars(0, tbsiso);

        //initialize inputs
        rst = 1; SI = 0;
        #10;
        rst = 0; 
        SI = 1;#10;
        SI = 0; #10;
        SI = 1; #10;
        SI = 0; #10;

        #10;
        rst = 0;
        SI = 1; #10;
        SI = 1; #10;
        SI = 1; #10;
        SI = 0; #10;

        $finish;
    end
endmodule