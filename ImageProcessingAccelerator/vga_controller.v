
module vga_controller (
    input  wire clk,
    input  wire rst_n,
    output wire hsync,
    output wire vsync,
    output wire [9:0] pixel_x,
    output wire [9:0] pixel_y,
    output wire video_active,
    output wire pixel_clk
);

    localparam H_VISIBLE = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_TOTAL   = 800;

    localparam V_VISIBLE = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_TOTAL   = 525;

    reg clk_div;
    reg [9:0] h_count;
    reg [9:0] v_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clk_div <= 1'b0;
        else
            clk_div <= ~clk_div;
    end

    assign pixel_clk = clk_div;

    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n) begin
            h_count <= 0;
            v_count <= 0;
        end
        else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;

                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1'b1;
            end
            else begin
                h_count <= h_count + 1'b1;
            end
        end
    end

    assign pixel_x = h_count;
    assign pixel_y = v_count;

    assign video_active =
        (h_count < H_VISIBLE) &&
        (v_count < V_VISIBLE);

    assign hsync = ~(
        (h_count >= H_VISIBLE + H_FRONT) &&
        (h_count < H_VISIBLE + H_FRONT + H_SYNC)
    );

    assign vsync = ~(
        (v_count >= V_VISIBLE + V_FRONT) &&
        (v_count < V_VISIBLE + V_FRONT + V_SYNC)
    );

endmodule
