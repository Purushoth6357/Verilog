`timescale 1ns/1ps

module tb_multiplier4b;

    reg [3:0] A, B;
    wire [7:0] P;

    multiplier4b uut(.A(A), .B(B), .P(P));

    initial begin
        $dumpfile("tb_multiplier4b.vcd");
        $dumpvars(0, tb_multiplier4b);

        A = 4'b0000; B = 4'b0000;
        #10;
        $display("0 * 0 = %d", P);

        A = 4'b0011; B = 4'b0010;
        #10;
        $display("3 * 2 = %d", P);

        A = 4'b1111; B = 4'b1111;
        #10;
        $display("15 * 15 = %d", P);

        A = 4'b1010; B = 4'b0101;
        #10;
        $display("10 * 5 = %d", P);

        $finish;
    end

endmodule