module HA(
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

module FA(
    input A, B, Cin,
    output S, Cout
);
wire S1, C1, C2;
HA ha1(.A(A), .B(B), .S(S1), .C(C1));
HA ha2(.A(Cin), .B(S1), .S(S), .C(C2));
assign Cout = C1 | C2;

endmodule

module RippleCarryAdder4b(
    input [3:0] A, B,
    input Cin,
    output [3:0] S,
    output Cout
);
    wire C1, C2, C3;
    FA fa0(.A(A[0]), .B(B[0]), .Cin(Cin), .S(S[0]), .Cout(C1));
    FA fa1(.A(A[1]), .B(B[1]), .Cin(C1), .S(S[1]), .Cout(C2));
    FA fa2(.A(A[2]), .B(B[2]), .Cin(C2), .S(S[2]), .Cout(C3));
    FA fa3(.A(A[3]), .B(B[3]), .Cin(C3), .S(S[3]), .Cout(Cout));
endmodule