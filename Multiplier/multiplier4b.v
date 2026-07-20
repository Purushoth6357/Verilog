module multiplier4b (input [3:0] A, B, output [7:0] P);
wire [3:0] M0, M1, M2, M3;

multiplier2b U0 (.A(A[1:0]), .B(B[1:0]), .P(M0));
multiplier2b U1 (.A(A[3:2]), .B(B[1:0]), .P(M1));
multiplier2b U2 (.A(A[1:0]), .B(B[3:2]), .P(M2));
multiplier2b U3 (.A(A[3:2]), .B(B[3:2]), .P(M3));

assign P = M0 + (M1 << 2) + (M2 << 2) + (M3 << 4);

endmodule