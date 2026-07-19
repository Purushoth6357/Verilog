module HS (
    input A, Bin,
    output reg D, Bout
);

    always @(*) begin
        case ({A,Bin})
            2'b00: {D,Bout} = 2'b00;
            2'b01: {D,Bout} = 2'b11;
            2'b10: {D,Bout} = 2'b10;
            2'b11: {D,Bout} = 2'b00;
            default: {D,Bout} = 2'bxx;
        endcase
    end
endmodule

module FS (
    input A, Bin, Cin,
    output D, Bout
);
    wire D1, Bout1, Bout2;
    HS hs0(.A(A), .Bin(Bin), .D(D1), .Bout(Bout1));
    HS hs1(.A(D1), .Bin(Cin), .D(D), .Bout(Bout2));
    assign Bout = Bout1 | Bout2;
endmodule

module RCS4b (
    input [3:0] A, B,
    input Bin,
    output [3:0] D,
    output Bout 
);
    wire B1, B2, B3;
    FS fs0(.A(A[0]), .Bin(B[0]), .Cin(Bin), .D(D[0]), .Bout(B1));
    FS fs1(.A(A[1]), .Bin(B[1]), .Cin(B1), .D(D[1]), .Bout(B2));
    FS fs2(.A(A[2]), .Bin(B[2]), .Cin(B2), .D(D[2]), .Bout(B3));
    FS fs3(.A(A[3]), .Bin(B[3]), .Cin(B3), .D(D[3]), .Bout(Bout));
endmodule