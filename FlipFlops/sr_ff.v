module sr_ff (
    input wire S,
    input wire R,
    input wire clk,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @(posedge clk) begin
        if (S && !R) begin
            Q <= 1'b1; // Set
        end else if (!S && R) begin
            Q <= 1'b0; // Reset
        end else if (S && R) begin
            Q <= 1'bx; // Invalid state
        end
            else begin 
            Q <= Q; // Hold state
        end
    end 
endmodule