module demux1_8(
    input D,
    input [2:0] S,
    output reg Y0, Y1, Y2, Y3, Y4, Y5, Y6, Y7
);
    always @(*) begin
        case (S)
            3'b000: begin
                Y0 = D;
                Y1 = 0;
                Y2 = 0;
                Y3 = 0;
                Y4 = 0;
                Y5 = 0;
                Y6 = 0;
                Y7 = 0;
            end
            3'b001: begin
                Y0 = 0;
                Y1 = D;
                Y2 = 0;
                Y3 = 0;
                Y4 = 0;
                Y5 = 0;
                Y6 = 0;
                Y7 = 0;
            end
            3'b010: begin
                Y0 = 0;
                Y1 = 0;
                Y2 = D;
                Y3 = 0;
                Y4 = 0;
                Y5 = 0;
                Y6 = 0;
                Y7 = 0;
            end
            3'b011: begin
                Y0 = 0;
                Y1 = 0;
                Y2 = 0;
                Y3 = D;
                Y4 = 0;
                Y5 = 0;
                Y6 = 0;
                Y7 = 0;
            end
            3'b100: begin
                Y0 = 0;
                Y1 = 0;
                Y2 = 0;
                Y3 = 0;
                Y4 = D;
                Y5 = 0;
                Y6 = 0;
                Y7 = 0;
            end
            3'b101: begin 
                Y0 = 0;
                Y1 = 0;
                Y2 = 0;
                Y3 = 0;
                Y4 = 0;
                Y5 = D;
                Y6 = 0;
                Y7 = 0;
            end

            3'b110: begin
                Y0 = 0;
                Y1 = 0;
                Y2 = 0;
                Y3 = 0;
                Y4 = 0;
                Y5 = 0;
                Y6 = D;
                Y7 = 0;
            end

            3'b111: begin
                Y0 = 0;
                Y1 = 0;
                Y2 = 0;
                Y3 = 0;
                Y4 = 0;
                Y5 = 0;
                Y6 = 0;
                Y7 = D;
            end
        endcase
    end
endmodule
