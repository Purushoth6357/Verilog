module RCS8b (
    input [7:0] A, B,
    input Bin,
    output [7:0] D,
    output Bout
);

    wire B1;

    RCS4b rcs0(.A(A[3:0]), .B(B[3:0]), .Bin(Bin), .D(D[3:0]), .Bout(B1));
    RCS4b rcs1(.A(A[7:4]), .B(B[7:4]), .Bin(B1), .D(D[7:4]), .Bout(Bout));

endmodule