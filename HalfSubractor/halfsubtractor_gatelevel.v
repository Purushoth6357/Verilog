module HalfSubtractor_GateLevel (
    input A, B,
    output D, Bout
);
    wire notA;
    not (notA, A);
    xor (D, A, B);
    and (Bout, notA, B);
endmodule