
module image_processor_top (
    input  wire       CLOCK_50,
    input  wire [1:0] KEY,
    input  wire [7:0] SW,
    output wire [7:0] LED,
    output wire [3:0] VGA_R,
    output wire [3:0] VGA_G,
    output wire [3:0] VGA_B,
    output wire       VGA_HS,
    output wire       VGA_VS
);

    wire rst_n = KEY[0];

    wire [9:0] pixel_x, pixel_y;
    wire video_active;
    wire pixel_clk;

    vga_controller u_vga (
        .clk(CLOCK_50),
        .rst_n(rst_n),
        .hsync(VGA_HS),
        .vsync(VGA_VS),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .video_active(video_active),
        .pixel_clk(pixel_clk)
    );

    // 64x48 source image scaled 10x to VGA 640x480
    wire [5:0] image_x = pixel_x / 10;
    wire [5:0] image_y = pixel_y / 10;

    wire [11:0] display_address =
        {image_y, image_x};

    wire [23:0] display_pixel;
    wire processing_ready;

    image_processor_core u_core (
        .clk(pixel_clk),
        .rst_n(rst_n),
        .mode(SW[3:0]),
        .display_address(display_address),
        .display_pixel(display_pixel),
        .ready(processing_ready)
    );

    // Delay active-video to match synchronous RAM read
    reg active_d;

    always @(posedge pixel_clk or negedge rst_n) begin
        if (!rst_n)
            active_d <= 1'b0;
        else
            active_d <= video_active;
    end

    assign VGA_R =
        (active_d && processing_ready) ?
        display_pixel[23:20] : 4'h0;

    assign VGA_G =
        (active_d && processing_ready) ?
        display_pixel[15:12] : 4'h0;

    assign VGA_B =
        (active_d && processing_ready) ?
        display_pixel[7:4] : 4'h0;

    assign LED = ~SW;

endmodule
