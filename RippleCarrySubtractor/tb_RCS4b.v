`timescale 1ns/1ps

module tb_RCS4b;

    reg [3:0] A, B;
    reg Bin;

    wire [3:0] D;
    wire Bout;

    RCS4b uut(
        .A(A),
        .B(B),
        .Bin(Bin),
        .D(D),
        .Bout(Bout)
    );

    initial begin
        $dumpfile("tb_RCS4b.vcd");
        $dumpvars(0, tb_RCS4b);
        // Test 1
        A = 4; B = 2; Bin = 0;
        #10;
        $display("4 - 2 = %d  Borrow=%b", D, Bout);

        // Test 2
        A = 3; B = 5; Bin = 0;
        #10;
        $display("3 - 5 = %d  Borrow=%b", D, Bout);

        // Test 3
        A = 7; B = 7; Bin = 0;
        #10;
        $display("7 - 7 = %d  Borrow=%b", D, Bout);

        // Test 4
        A = 0; B = 1; Bin = 0;
        #10;
        $display("0 - 1 = %d  Borrow=%b", D, Bout);

        // Random Test
        A   = $random & 4'hF;
        B   = $random & 4'hF;
        Bin = $random & 1'b1;
        #10;
        $display("Random : %d - %d (Bin=%b) = %d Borrow=%b",
                  A, B, Bin, D, Bout);

        $finish;

    end

endmodule