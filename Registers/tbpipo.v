`timescale 1ns/100ps

module tbpipo;

    reg clk;
    reg rst;
    reg [3:0]D;
    wire [3:0]Q;

    pipo4breg uut (.clk(clk), .rst(rst), .D(D), .Q(Q));

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin

        $dumpfile("tbpipo.vcd");
        $dumpvars(0, tbpipo);

        // Initial values
        rst = 1'b0;
        D = 4'b0000;

        #7
        D = 4'b0010; #10;
        D = 4'b1101; #10;
        D = 4'b1111; #10;
        D = 4'b1010; #10;
        
        $finish;

    end


endmodule