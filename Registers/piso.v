module piso4breg (
    input  wire       clk,
    input  wire       rst,
    input  wire       load,
    input  wire [3:0] PI,
    output wire       SO
);

    reg [3:0] Q;

    assign SO = Q[0];

    always @(posedge clk or posedge rst) begin
        if (rst)
            Q <= 4'b0000;
        else if (load)
            Q <= PI;                 // Load parallel data
        else
            Q <= {1'b0, Q[3:1]};     // Shift right
    end

endmodule