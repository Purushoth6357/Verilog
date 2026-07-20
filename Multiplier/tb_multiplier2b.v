`timescale 1ns/1ps

module tb_multiplier2b;

    reg [1:0] A, B;
    wire [3:0] P;

    multiplier2b uut(.A(A), .B(B), .P(P));

    initial begin
        $dumpfile("tb_multiplier2b.vcd");
        $dumpvars(0, tb_multiplier2b);

        A = 2'b00; B = 2'b00;
        #10;
        $display("0 * 0 = %d", P);

        A = 2'b01; B = 2'b10;
        #10;
        $display("1 * 2 = %d", P);

        A = 2'b11; B = 2'b11;
        #10;
        $display("3 * 3 = %d", P);

        A = 2'b10; B = 2'b01;
        #10;
        $display("2 * 1 = %d", P);

        $finish;
    end
    
endmodule