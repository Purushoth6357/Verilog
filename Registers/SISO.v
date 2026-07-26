module siso_4bit (
    input  wire clk,
    input  wire rst,
    input  wire SI,      // Serial Input
    output wire SO       // Serial Output
);

    reg [3:0] Q;

    always @(posedge clk or posedge rst) begin
        if (rst)
            Q <= 4'b0000;
        else
            Q <= {SI, Q[3:1]};   // Right Shift
    end

    assign SO = Q[0];

endmodule