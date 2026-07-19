`timescale 1ns/1ps

module tb_RCS8b;

    reg [7:0] A, B;
    reg Bin;

    wire [7:0] D;
    wire Bout;

    RCS8b uut(.A(A), .B(B), .Bin(Bin), .D(D), .Bout(Bout));

    initial begin
        $dumpfile("tb_RCS8b.vcd");
        $dumpvars(0, tb_RCS8b);

        A = 8'd15; B = 8'd10; Bin = 0;
        #10;
        $display("15 - 10 = %d  Borrow=%b", D, Bout);

        A = 8'd5; B = 8'd7; Bin = 0;
        #10;
        $display("5 - 7 = %d  Borrow=%b", D, Bout); 

        A = 8'd20; B = 8'd20; Bin = 0;
        #10;
        $display("20 - 20 = %d  Borrow=%b", D, Bout);  

        A = 8'd0; B = 8'd1; Bin = 0;
        #10;
        $display("0 - 1 = %d  Borrow=%b", D, Bout);

        $finish;
    end

endmodule
    