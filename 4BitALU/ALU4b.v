module ALU4b (
    input [3:0] A,
    input [3:0] B,
    input [2:0] ALU_Sel,
    output reg [3:0] ALU_Out,
    output reg CarryOut
);

    wire [3:0] Sum, Diff;
    wire CarryOutAdd, CarryOutSub;

RippleCarryAdder4b adder (
    .A(A),
    .B(B),
    .Cin(1'b0),
    .S(Sum),
    .Cout(CarryOutAdd)
);

RippleCarryAdder4b subtractor (
    .A(A),
    .B(~B),
    .Cin(1'b1),
    .S(Diff),
    .Cout(CarryOutSub)
);

always @(*) begin

    ALU_Out  = 4'b0000;
    CarryOut = 1'b0;
    
    case (ALU_Sel)
        3'b000: {CarryOut, ALU_Out} = {CarryOutAdd, Sum}; // Addition
        3'b001: {CarryOut, ALU_Out} = {CarryOutSub, Diff}; // Subtraction
        3'b010: ALU_Out = A & B;              // AND
        3'b011: ALU_Out = A | B;              // OR
        3'b100: ALU_Out = A ^ B;              // XOR
        3'b101: ALU_Out = ~(A | B);           // NOR
        3'b110: ALU_Out = ~(A & B);           // NAND
        3'b111: ALU_Out = (A < B) ? 4'b0001 : 4'b0000; // Set on Less Than
        default: {CarryOut, ALU_Out} = 5'b00000; // Default case
    endcase
end

endmodule