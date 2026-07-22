module demux1_8(
    input D,
    input [2:0] S,
    output Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7
);

    wire w1, w2;
    assign w1 = D & ~S[2];
    assign w2 = D & S[2];

    demux1_4 demux0 (
        .D(w1),
        .S(S[1:0]),
        .Y0(Y0),
        .Y1(Y1),
        .Y2(Y2),
        .Y3(Y3)
    );

    demux1_4 demux1 (
        .D(w2),
        .S(S[1:0]),
        .Y0(Y4),
        .Y1(Y5),
        .Y2(Y6),
        .Y3(Y7)
    );

    

endmodule
