module d_ff (
    input wire D,
    input wire clk,
    output reg Q,
    output wire Q_bar
);
    assign Q_bar = ~Q;

    always @(posedge clk) begin
        Q <= D; 
    end
endmodule

