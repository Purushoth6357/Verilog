module HalfAdder_Behavioural (
    input A, B,
    output reg  S, C
);
  always @(*) begin
    S = A^B;
    C = A&B;
  end  
endmodule