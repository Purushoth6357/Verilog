module RCA8b   (
    input [7:0] A, B,
    input Cin,
    output [7:0] S,
    output Cout
);
    wire C1;

    //Using two 4-bit Ripple Carry Adders to create an 8-bit Ripple Carry Adder
    RippleCarryAdder4b rca0(.A(A[3:0]), .B(B[3:0]), .Cin(Cin), .S(S[3:0]), .Cout(C1));
    RippleCarryAdder4b rca1(.A(A[7:4]), .B(B[7:4]), .Cin(C1), .S(S[7:4]), .Cout(Cout));

endmodule