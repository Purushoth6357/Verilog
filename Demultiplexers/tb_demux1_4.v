`timescale 1ns/1ps

module tb_demux1_4;

reg D;
reg [1:0] S;
wire Y0, Y1, Y2, Y3;

demux4_1 uut(
    .D(D),
    .S(S),
    .Y0(Y0),
    .Y1(Y1),
    .Y2(Y2),
    .Y3(Y3)
);

initial begin
    $dumpfile("tb_demux1_4.vcd");
    $dumpvars(0, tb_demux1_4);
    // Test Case 1
    D = 1;
    S = 2'b00;
    #10;
    $display("S=%b Y0=%b Y1=%b Y2=%b Y3=%b", S, Y0, Y1, Y2, Y3);

    // Test Case 2
    D = 1;
    S = 2'b01;
    #10;
    $display("S=%b Y0=%b Y1=%b Y2=%b Y3=%b", S, Y0, Y1, Y2, Y3);

    // Test Case 3
    D = 1;
    S = 2'b10;
    #10;
    $display("S=%b Y0=%b Y1=%b Y2=%b Y3=%b", S, Y0, Y1, Y2, Y3);

    // Test Case 4
    D = 1;
    S = 2'b11;
    #10;
    $display("S=%b Y0=%b Y1=%b Y2=%b Y3=%b", S, Y0, Y1, Y2, Y3);
    $finish;
end
endmodule   