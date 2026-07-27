`timescale 1ns/1ps

module tb_universal_register;

    // Change this value to test different widths
    parameter WIDTH = 4;

    reg clk;
    reg rst;
    reg [1:0] sel;
    reg SR;
    reg SL;
    reg [WIDTH-1:0] PI;

    wire SO_left;
    wire SO_right;
    wire [WIDTH-1:0] PO;

    // DUT
    universal_register #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .sel(sel),
        .SR(SR),
        .SL(SL),
        .PI(PI),
        .SO_left(SO_left),
        .SO_right(SO_right),
        .PO(PO)
    );

    // Clock Generation
    initial
        clk = 1'b0;

    always #5 clk = ~clk;

    initial begin

        $dumpfile("univ.vcd");
        $dumpvars(0, tb_universal_register);

        // Initialize
        rst = 1;
        sel = 2'b00;
        SR  = 0;
        SL  = 0;
        PI  = 0;

        #10;
        rst = 0;

        // Parallel Load
        sel = 2'b11;
        PI  = 4'b1010;
        #10;

        // Hold
        sel = 2'b00;
        #10;

        // Shift Right
        sel = 2'b01;
        SR  = 1;
        #10;

        // Shift Right again
        SR  = 0;
        #10;

        // Shift Left
        sel = 2'b10;
        SL  = 1;
        #10;

        // Shift Left again
        SL  = 0;
        #10;

        // Parallel Load
        sel = 2'b11;
        PI  = 4'b1101;
        #10;

        // Continuous Right Shift
        sel = 2'b01;
        SR  = 0;
        #40;

        // Continuous Left Shift
        sel = 2'b10;
        SL  = 1;
        #40;

        $finish;

    end

endmodule