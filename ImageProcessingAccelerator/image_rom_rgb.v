
module image_rom_rgb (
    input  wire        clk,
    input  wire [11:0] address,
    output reg  [23:0] pixel
);

    reg [23:0] memory [0:3071];

    initial begin
        $readmemh("image.hex", memory);
    end

    always @(posedge clk) begin
    pixel <= memory[address];
end

endmodule
