`timescale 1ns/1ps

module tb_mux4_1;

reg D0, D1, D2, D3;
reg [1:0] S;
wire Y;

mux4_1 uut(
    .D0(D0),
    .D1(D1),
    .D2(D2),
    .D3(D3),
    .S(S),
    .Y(Y)
);

initial begin

    $dumpfile("tb_mux4_1.vcd");
    $dumpvars(0, tb_mux4_1);
    // Test Case 1
    D0 = 1; D1 = 0; D2 = 0; D3 = 0;
    S = 2'b00;
    #10;
    $display("S=%b Y=%b", S, Y);

    // Test Case 2
    D0 = 0; D1 = 1; D2 = 0; D3 = 0;
    S = 2'b01;
    #10;
    $display("S=%b Y=%b", S, Y);

    // Test Case 3
    D0 = 0; D1 = 0; D2 = 1; D3 = 0;
    S = 2'b10;
    #10;
    $display("S=%b Y=%b", S, Y);

    // Test Case 4
    D0 = 0; D1 = 0; D2 = 0; D3 = 1;
    S = 2'b11;
    #10;
    $display("S=%b Y=%b", S, Y);

    $finish;
end

endmodule
