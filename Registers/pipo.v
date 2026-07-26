module pipo4breg (
    input  wire clk,
    input  wire rst,
    input  wire [3:0] D, // Parallel Input
    output reg [3:0] Q   // Parallel Output
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            Q <= 4'b0000;
        else
            Q <= D; // Load parallel data
    end
endmodule