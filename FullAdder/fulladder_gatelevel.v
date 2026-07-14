module FullAdder_GateLevel(
    input A, B, Cin,
    output S, Cout
);
    wire w1, w2, w3;

    xor (w1, A, B);
    xor (S, w1, Cin);
    and (w2, A, B);
    and (w3, w1, Cin);
    or  (Cout, w2, w3);
endmodule