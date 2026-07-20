`timescale 1ns/1ps

module tb_multiplier8b;

    reg [7:0] A, B;
    wire [15:0] P;

    multiplier8b uut(.A(A), .B(B), .P(P));

    initial begin
        $dumpfile("tb_multiplier8b.vcd");
        $dumpvars(0, tb_multiplier8b);

        A = 8'b00000000; B = 8'b00000000;
        #10;
        $display("0 * 0 = %d", P);

        A = 8'b00000011; B = 8'b00000010;
        #10;
        $display("3 * 2 = %d", P);

        A = 8'b11111111; B = 8'b11111111;
        #10;
        $display("255 * 255 = %d", P);

        A = 8'b10101010; B = 8'b01010101;
        #10;
        $display("170 * 85 = %d", P);

        $finish;
    end
endmodule