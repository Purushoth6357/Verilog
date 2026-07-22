`timescale 1ns/1ps

module tb_demux1_8;
reg D;
reg [2:0] S;
wire Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7;

demux1_8 uut(
    .D(D),
    .S(S),
    .Y0(Y0),
    .Y1(Y1),
    .Y2(Y2),
    .Y3(Y3),
    .Y4(Y4),
    .Y5(Y5),
    .Y6(Y6),
    .Y7(Y7)
);

initial begin
    $dumpfile("tb_demux1_8.vcd");
    $dumpvars(0, tb_demux1_8);
    // Test Case 1
    D = 1;
    S = 3'b000;
    #10;
    $display("S=%b Y0=%b Y1=%b Y2=%b Y3=%b Y4=%b Y5=%b Y6=%b Y7=%b", S, Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7);

    // Test Case 2
    D = 1;
    S = 3'b001;
    #10;
    $display("S=%b Y0=%b Y1=%b Y2=%b Y3=%b Y4=%b Y5=%b Y6=%b Y7=%b", S, Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7);

    // Test Case 3
    D = 1;
    S = 3'b010;
    #10;
    $display("S=%b Y0=%b Y1=%b Y2=%b Y3=%b Y4=%b Y5=%b Y6=%b Y7=%b", S, Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7);

    // Test Case 4
    D = 1;
    S = 3'b011;
    #10;
    $display("S=%b Y0=%b Y1=%b Y2=%b Y3=%b Y4=%b Y5=%b Y6=%b Y7=%b", S, Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7);
end
endmodule