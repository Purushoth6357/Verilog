module HalfSubtractor_Behavioural (
    input A, B,
    output reg D, Bout
);
    always @(*) begin
        D   = A ^ B;
        Bout = ~A & B;
    end
    
endmodule