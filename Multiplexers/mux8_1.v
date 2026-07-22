module mux8_1 (
    input wire D0, D1, D2, D3, D4, D5, D6, D7,
    input wire [2:0] S,
    output wire Y
);
    wire Y0, Y1;
    mux4_1 mux0 (
        .D0(D0),
        .D1(D1),
        .D2(D2),
        .D3(D3),
        .S(S[1:0]),
        .Y(Y0)
    );

    mux4_1 mux1 (
        .D0(D4),
        .D1(D5),
        .D2(D6),
        .D3(D7),
        .S(S[1:0]),
        .Y(Y1)
    );

    assign Y = (S[2] == 0) ? Y0 : Y1;
endmodule