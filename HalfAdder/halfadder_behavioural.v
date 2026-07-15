module HalfAdder_Behavioural (
    input A, B,
    output reg  S, C
);
  always @(*) begin
    case ({A, B})
      2'b00: {S, C} = 2'b00;
      2'b01: {S, C} = 2'b10;
      2'b10: {S, C} = 2'b10;
      2'b11: {S, C} = 2'b01;
      default: {S, C} = 2'bxx;
    endcase
  end  
endmodule