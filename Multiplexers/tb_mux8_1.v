`timescale 1ns/1ps

module tb_mux8_1;
reg D0, D1, D2, D3, D4, D5, D6, D7;
reg [2:0] S;
wire Y;

mux8_1 uut(
    .D0(D0),
    .D1(D1),
    .D2(D2),
    .D3(D3),
    .D4(D4),
    .D5(D5),
    .D6(D6),
    .D7(D7),
    .S(S),
    .Y(Y)
);

initial begin
    $dumpfile("tb_mux8_1.vcd");
    $dumpvars(0, tb_mux8_1);
    // Test Case 1
    D0 = 1; D1 = 0; D2 = 0; D3 = 0; D4 = 0; D5 = 0; D6 = 0; D7 = 0;
    S = 3'b000;
    #10;
    $display("S=%b Y=%b", S, Y);

    // Test Case 2
    D0 = 0; D1 = 1; D2 = 0; D3 = 0; D4 = 0; D5 = 0; D6 = 0; D7 = 0;
    S = 3'b001;
    #10;
    $display("S=%b Y=%b", S, Y);

    // Test Case 3
    D0 = 0; D1 = 0; D2 = 0; D3 = 1; D4 = 1; D5 = 1; D6 = 1; D7 = 1;
    S = 3'b010;
    #10;
    $display("S=%b Y=%b", S, Y);

    // Test Case 4
    D0 = 0; D1 = 0; D2 = 0; D3 = 1; D4 = 0; D5 = 0; D6 = 0; D7 = 0;
    S = 3'b011;
    #10;
    $display("S=%b Y=%b", S, Y);

    // Test Case 5
    D0 = 0; D1 = 0; D2 = 0; D3 = 0; D4 = 1; D5 = 0; D6 = 0; D7 = 0;
    S = 3'b100;
    #10;
    $display("S=%b Y=%b", S, Y);
    $finish;
end
endmodule