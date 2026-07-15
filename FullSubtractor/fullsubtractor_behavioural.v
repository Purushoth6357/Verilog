module FullSubtractor_Behavioural (
    input A, B, Bin,
    output reg D, Bout
);
    always @(*) begin
    case ({A, B, Bin})
        3'b000: {D, Bout} = 2'b00;
        3'b001: {D, Bout} = 2'b11;
        3'b010: {D, Bout} = 2'b11;
        3'b011: {D, Bout} = 2'b01;
        3'b100: {D, Bout} = 2'b10;
        3'b101: {D, Bout} = 2'b00;
        3'b110: {D, Bout} = 2'b00;
        3'b111: {D, Bout} = 2'b11;
        default: {D, Bout} = 2'bxx;
    endcase
end
endmodule