module HalfSubtractor_Dataflow(
    input A, B,
    output D, Bout
);
    assign D    = A ^ B;
    assign Bout = ~A & B;
endmodule