`timescale 1ns/1ps

module tb_fulladder;

reg A, B, Cin;

wire S1, C1;
wire S2, C2;
wire S3, C3;

FullAdder_Behavioural uut1(.A(A), .B(B), .Cin(Cin), .S(S1), .Cout(C1));

FullAdder_Dataflow uut2(.A(A), .B(B), .Cin(Cin), .S(S2), .Cout(C2));

FullAdder_GateLevel uut3(.A(A), .B(B), .Cin(Cin), .S(S3), .Cout(C3));

initial begin
    $dumpfile("fulladder.vcd");
    $dumpvars(0, tb_fulladder);
end

initial begin
    $monitor("A=%b B=%b Cin=%b | Beh=%b%b Data=%b%b Gate=%b%b",
             A,B,Cin,
             C1,S1,
             C2,S2,
             C3,S3);
end


initial begin

A=0; B=0; Cin=0; #10;
A=0; B=0; Cin=1; #10;
A=0; B=1; Cin=0; #10;
A=0; B=1; Cin=1; #10;
A=1; B=0; Cin=0; #10;
A=1; B=0; Cin=1; #10;
A=1; B=1; Cin=0; #10;
A=1; B=1; Cin=1; #10;

$finish;

end

endmodule