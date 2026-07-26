`timescale 1ns/100ps

module tbpiso;

    reg clk;
    reg rst;
    reg [3:0]PI;
    reg load;
    
    wire SO;

    piso4breg uut (.clk(clk), .rst(rst), .PI(PI), .load(load), .SO(SO));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
    $dumpfile("tbpiso.vcd");
    $dumpvars(0, tbpiso);

    rst  = 1;
    load = 0;
    PI   = 4'b0000;

    #10;
    rst = 0;

    // Load data
    PI   = 4'b1011;
    load = 1;

    #10;
    load = 0;

    #50;

    $finish;
end
endmodule 