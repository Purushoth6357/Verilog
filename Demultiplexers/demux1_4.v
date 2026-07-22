module demux1_4 (
    input D,
    input [1:0] S,
    output reg Y0, Y1, Y2, Y3
);
    always @(*) begin
        case (S)
            2'b00: begin
                Y0 = D;
                Y1 = 0;
                Y2 = 0;
                Y3 = 0;
            end
            2'b01: begin
                Y0 = 0;
                Y1 = D;
                Y2 = 0;
                Y3 = 0;
            end
            2'b10: begin
                Y0 = 0;
                Y1 = 0;
                Y2 = D;
                Y3 = 0;
            end
            2'b11: begin
                Y0 = 0;
                Y1 = 0;
                Y2 = 0;
                Y3 = D;
            end
        endcase
    end
endmodule