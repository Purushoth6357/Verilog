module universal_register #(
    parameter WIDTH = 4
) (
    input wire clk,
    input wire rst,
    input wire [1:0] sel,
    input wire SR,
    input wire SL,
    input wire [WIDTH-1:0] PI,

    output wire SO_left,
    output wire SO_right,
    output reg [WIDTH-1:0] PO
);

always @(posedge clk or posedge rst) begin
    if (rst)
        PO <= {WIDTH{1'b0}};

    else begin
        case (sel)
            2'b00: PO <= PO; // Hold
            2'b01: PO <= {SR, PO[WIDTH-1:1]}; // Right Shift
            2'b10: PO <= {PO[WIDTH-2:0], SL}; // Left Shift
            2'b11: PO <= PI; // Parallel load
            default: PO <= PO;
        endcase
    end
end

assign SO_right = PO[0];
assign SO_left = PO[WIDTH-1];
endmodule