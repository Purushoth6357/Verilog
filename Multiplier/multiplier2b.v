module HA(input  A, B, output S, C);
    assign S = A ^ B; 
    assign C = A & B; 
endmodule

module FA(
        input A,  B,  Cin,
        output S,  Cout);

    wire S1, C1, C2;
    HA ha1(.A(A), .B(B), .S(S1), .C(C1));
    HA ha2(.A(S1), .B(Cin), .S(S), .C(C2));
    assign Cout = C1 | C2;

endmodule

module multiplier2b(
    input [1:0] A, B,
    output [3:0] P
);

wire C1, C2;
wire [1:0] S1;

assign P[0] = A[0] & B[0];

HA ha1(
    .A(A[1] & B[0]),
    .B(A[0] & B[1]),
    .S(S1[0]),
    .C(C1)
);

HA ha2(
    .A(A[1] & B[1]),
    .B(C1),
    .S(S1[1]),
    .C(C2)
);

assign P[1] = S1[0];
assign P[2] = S1[1];
assign P[3] = C2;

endmodule