`timescale 1ns / 1ps
module tb_fullsubtractor;

    reg A, B, Bin;
    wire D1, Bout1;
    wire D2, Bout2;
    wire D3, Bout3;

    FullSubtractor_Behavioural U1 (
        .A(A),
        .B(B),
        .Bin(Bin),
        .D(D1),
        .Bout(Bout1)
    ); 

    FullSubtractor_Dataflow U2 (
        .A(A),
        .B(B),
        .Bin(Bin),
        .D(D2),
        .Bout(Bout2)
    );

    FullSubtractor_GateLevel U3 (
        .A(A),
        .B(B),
        .Bin(Bin),
        .D(D3),
        .Bout(Bout3)
    );

    initial begin
        $monitor("Time: %0t | A: %b | B: %b | Bin: %b | D1: %b | Bout1: %b | D2: %b | Bout2: %b | D3: %b | Bout3: %b", $time, A, B, Bin, D1, Bout1, D2, Bout2, D3, Bout3);
    
        $dumpfile("fullsubtractor.vcd");
        $dumpvars(0, tb_fullsubtractor);
        
        A = 0; B = 0; Bin = 0; #10;
        A = 0; B = 0; Bin = 1; #10;
        A = 0; B = 1; Bin = 0; #10;
        A = 0; B = 1; Bin = 1; #10;
        A = 1; B = 0; Bin = 0; #10;
        A = 1; B = 0; Bin = 1; #10;
        A = 1; B = 1; Bin = 0; #10;
        A = 1; B = 1; Bin = 1; #10;

        $finish;
    end

endmodule