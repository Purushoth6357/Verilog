
module multiplier8b(
    input  [7:0] A,
    input  [7:0] B,
    output [15:0] P
);

wire [7:0] M0, M1, M2, M3;

multiplier4b U0 (.A(A[3:0]), .B(B[3:0]), .P(M0));
multiplier4b U1 (.A(A[7:4]), .B(B[3:0]), .P(M1));
multiplier4b U2 (.A(A[3:0]), .B(B[7:4]), .P(M2));
multiplier4b U3 (.A(A[7:4]), .B(B[7:4]), .P(M3));

assign P = M0 + (M1 << 4) + (M2 << 4) + (M3 << 8);

endmodule