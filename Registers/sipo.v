module sipo4breg (
    input wire clk,
    input wire rst,
    input SI, // Serial Inputs
    output reg [3:0]PO // Parallel Output
);

    always @(posedge clk or posedge rst) begin
        if (rst)
            PO <= 4'b0000;
        else
            PO <= {SI, PO[3:1]};
    end

endmodule