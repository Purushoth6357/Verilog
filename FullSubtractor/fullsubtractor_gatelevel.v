module FullSubtractor_GateLevel (
    input A, B, Bin,
    output D, Bout
);
    wire notA, notB, notBin;
    wire and1_out, and2_out, and3_out;

    not (notA, A);
    not (notB, B);
    not (notBin, Bin);

    xor (D, A, B, Bin);

    and (and1_out, notA, B);
    and (and2_out, notA, Bin);
    and (and3_out, B, Bin);

    or (Bout, and1_out, and2_out, and3_out);

endmodule