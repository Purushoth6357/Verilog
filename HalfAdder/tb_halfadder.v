`timescale 1ns/1ps

module tb_halfadder;

reg A, B;

wire S1, C1;
wire S2, C2;
wire S3, C3;

HalfAdder_Behavioural U1 (
    .A(A),
    .B(B),
    .S(S1),
    .C(C1)
);


HalfAdder_Dataflow U2 (
    .A(A),
    .B(B),
    .S(S2),
    .C(C2)
);


HalfAdder_Gatelevel U3 (
    .A(A),
    .B(B),
    .S(S3),
    .C(C3)
);

initial begin
    $monitor("A=%b B=%b | Beh=%b%b Data=%b%b Gate=%b%b",
             A,B,C1,S1,C2,S2,C3,S3);

    $dumpfile("halfadder.vcd");   
    $dumpvars(0, tb_halfadder);             

    A=0; B=0; #10;
    A=0; B=1; #10;
    A=1; B=0; #10;
    A=1; B=1; #10;

    $finish;
end

endmodule