module HalfSubtractor_Behavioural (
    input A, B,
    output reg D, Bout
);
    always @(*) begin
        case ({A, B})
            2'b00: {D, Bout} = 2'b00;
            2'b01: {D, Bout} = 2'b11;
            2'b10: {D, Bout} = 2'b10;
            2'b11: {D, Bout} = 2'b01;
            default: {D, Bout} = 2'bxx;
        endcase
    end
    
endmodule