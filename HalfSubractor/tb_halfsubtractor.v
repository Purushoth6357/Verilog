`timescale 1ns / 1ps
module tb_halfsubtractor;
    reg A, B;
    wire D1, Bout1;
    wire D2, Bout2;
    wire D3, Bout3;

    HalfSubtractor_Behavioural U1 (
        .A(A),
        .B(B),
        .D(D1),
        .Bout(Bout1)
    );

    HalfSubtractor_Dataflow U2 (
        .A(A),
        .B(B),
        .D(D2),
        .Bout(Bout2)
    );

    HalfSubtractor_GateLevel U3 (
        .A(A),
        .B(B),
        .D(D3),
        .Bout(Bout3)
    );

    initial begin
    
        $monitor("Time: %0t | A: %b | B: %b | D1: %b | Bout1: %b | D2: %b | Bout2: %b | D3: %b | Bout3: %b", $time, A, B, D1, Bout1, D2, Bout2, D3, Bout3);
    
        $dumpfile("halfsubtractor.vcd");
        $dumpvars(0, tb_halfsubtractor);
        

        A = 0; B = 0; #10;
        A = 0; B = 1; #10;
        A = 1; B = 0; #10;
        A = 1; B = 1; #10;
        $finish;
    
    end
endmodule 