module mux4_1 (
    input D0,
    input D1,
    input D2,
    input D3,
    input [1:0] S,
    output reg Y
);

always @(*) begin
    case (S)
        2'b00: Y = D0;
        2'b01: Y = D1;
        2'b10: Y = D2;
        2'b11: Y = D3;
        default: Y = 1'b0;
    endcase
end

endmodule