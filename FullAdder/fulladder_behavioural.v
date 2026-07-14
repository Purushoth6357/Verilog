module FullAdder_Behavioural(
    input A, B, Cin,
    output reg S, Cout
);

always @(*) begin
    S    = A ^ B ^ Cin;
    Cout = (A & B) | (Cin & (A ^ B));
end

endmodule