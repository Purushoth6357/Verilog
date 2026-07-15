module FullAdder_Behavioural(
    input A, B, Cin,
    output reg S, Cout
);

always @(*) begin
    case ({A, B, Cin})
        3'b000: {S, Cout} = 2'b00;
        3'b001: {S, Cout} = 2'b10;
        3'b010: {S, Cout} = 2'b10;
        3'b011: {S, Cout} = 2'b01;
        3'b100: {S, Cout} = 2'b10;
        3'b101: {S, Cout} = 2'b01;
        3'b110: {S, Cout} = 2'b01;
        3'b111: {S, Cout} = 2'b11;
        default: {S, Cout} = 2'bxx;
    endcase
end

endmodule