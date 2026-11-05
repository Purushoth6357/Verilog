
module image_processor_core (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [3:0]  mode,
    input  wire [11:0] display_address,
    output reg  [23:0] display_pixel,
    output reg         ready
);

    localparam W = 64;
    localparam H = 48;
    localparam N = 3072;

    localparam ST_CLEAR = 3'd0;
    localparam ST_PRIME = 3'd1;
    localparam ST_SCAN  = 3'd2;
    localparam ST_DRAIN = 3'd3;
    localparam ST_DONE  = 3'd4;

    reg [2:0] state;

    reg [3:0] mode_previous;
    reg [3:0] mode_latched;

    reg [11:0] clear_addr;
    reg [11:0] scan_addr;

    reg [11:0] rom_addr;
    wire [23:0] source_pixel;

    image_rom_rgb u_rom (
        .clk(clk),
        .address(rom_addr),
        .pixel(source_pixel)
    );

    // Previous two RGB image rows
    reg [23:0] line1 [0:63];
    reg [23:0] line2 [0:63];

    reg [23:0] t2, t1;
    reg [23:0] m2, m1;
    reg [23:0] b2, b1;

    reg [5:0] issue_x;
    reg [5:0] issue_y;
    reg [11:0] issue_addr;

    wire [23:0] top_right = line2[issue_x];
    wire [23:0] mid_right = line1[issue_x];
    wire [23:0] bot_right = source_pixel;

    // -------------------------------------------------
    // Functions
    // -------------------------------------------------

    function [7:0] clamp8;
        input integer value;
        begin
            if (value < 0)
                clamp8 = 8'd0;
            else if (value > 255)
                clamp8 = 8'd255;
            else
                clamp8 = value[7:0];
        end
    endfunction

    function [7:0] luma;
        input [23:0] p;
        reg [15:0] sum;
        begin
            sum =
                p[23:16] * 8'd77 +
                p[15:8]  * 8'd150 +
                p[7:0]   * 8'd29;

            luma = sum[15:8];
        end
    endfunction

    function [7:0] gaussian_channel;
        input [7:0] a,b,c,d,e,f,g,h,i;
        reg [11:0] sum;
        begin
            sum = a + (b << 1) + c +
                  (d << 1) + (e << 2) +
                  (f << 1) + g + (h << 1) + i;

            gaussian_channel = (sum + 8) >> 4;
        end
    endfunction

    function [7:0] sharpen_channel;
        input [7:0] a,b,c,d,e;
        integer sum;
        begin
            sum = 5*c - a - b - d - e;
            sharpen_channel = clamp8(sum);
        end
    endfunction

    function [7:0] emboss_channel;
        input [7:0] a,b;
        integer sum;
        begin
            sum = b - a + 128;
            emboss_channel = clamp8(sum);
        end
    endfunction

    // -------------------------------------------------
    // 3x3 RGB neighbourhood
    // -------------------------------------------------

    wire [23:0] p00 = t2;
    wire [23:0] p01 = t1;
    wire [23:0] p02 = top_right;

    wire [23:0] p10 = m2;
    wire [23:0] p11 = m1;
    wire [23:0] p12 = mid_right;

    wire [23:0] p20 = b2;
    wire [23:0] p21 = b1;
    wire [23:0] p22 = bot_right;

    wire [7:0] y00 = luma(p00);
    wire [7:0] y01 = luma(p01);
    wire [7:0] y02 = luma(p02);

    wire [7:0] y10 = luma(p10);
    wire [7:0] y11 = luma(p11);
    wire [7:0] y12 = luma(p12);

    wire [7:0] y20 = luma(p20);
    wire [7:0] y21 = luma(p21);
    wire [7:0] y22 = luma(p22);

    // -------------------------------------------------
    // Sobel
    // -------------------------------------------------

    wire signed [11:0] gx =
          $signed({4'b0,y02})
        + ($signed({4'b0,y12}) <<< 1)
        + $signed({4'b0,y22})
        - $signed({4'b0,y00})
        - ($signed({4'b0,y10}) <<< 1)
        - $signed({4'b0,y20});

    wire signed [11:0] gy =
          $signed({4'b0,y20})
        + ($signed({4'b0,y21}) <<< 1)
        + $signed({4'b0,y22})
        - $signed({4'b0,y00})
        - ($signed({4'b0,y01}) <<< 1)
        - $signed({4'b0,y02});

    wire [11:0] abs_gx =
        gx[11] ? (~gx + 12'd1) : gx;

    wire [11:0] abs_gy =
        gy[11] ? (~gy + 12'd1) : gy;

    wire [12:0] sobel_mag =
        {1'b0,abs_gx} + {1'b0,abs_gy};

    wire [7:0] sobel8 =
        (sobel_mag > 13'd255) ?
        8'hFF : sobel_mag[7:0];

    // -------------------------------------------------
    // Pointwise filters
    // -------------------------------------------------

    wire [7:0] rr = source_pixel[23:16];
    wire [7:0] gg = source_pixel[15:8];
    wire [7:0] bb = source_pixel[7:0];

    wire [7:0] gray = luma(source_pixel);

    wire [7:0] threshold =
        (gray >= 8'd128) ? 8'hFF : 8'h00;

    reg [23:0] point_result;

    integer sep_r, sep_g, sep_b;

    always @(*) begin
        point_result = source_pixel;

        sep_r = 0;
        sep_g = 0;
        sep_b = 0;

        case (mode_latched)

            4'h0: point_result = source_pixel;

            4'h1: point_result = ~source_pixel;

            4'h2: point_result = {gray,gray,gray};

            4'h3: point_result = {rr,8'h00,8'h00};

            4'h4: point_result = {8'h00,gg,8'h00};

            4'h5: point_result = {8'h00,8'h00,bb};

            4'h6: point_result = {
                clamp8(rr+40),
                clamp8(gg+40),
                clamp8(bb+40)
            };

            4'h7: point_result = {
                clamp8((($signed({1'b0,rr})-128)*3)/2+128),
                clamp8((($signed({1'b0,gg})-128)*3)/2+128),
                clamp8((($signed({1'b0,bb})-128)*3)/2+128)
            };

            4'h8: point_result =
                {threshold,threshold,threshold};

            4'hD: begin
                sep_r = (rr*101 + gg*197 + bb*48) >> 8;
                sep_g = (rr*89  + gg*176 + bb*43) >> 8;
                sep_b = (rr*70  + gg*137 + bb*34) >> 8;

                point_result = {
                    clamp8(sep_r),
                    clamp8(sep_g),
                    clamp8(sep_b)
                };
            end

            4'hE: point_result = {
                {rr[7:5],5'b0},
                {gg[7:5],5'b0},
                {bb[7:5],5'b0}
            };

            4'hF: point_result =
                {~gray,~gray,~gray};

            default:
                point_result = source_pixel;

        endcase
    end

    // -------------------------------------------------
    // Spatial filters
    // -------------------------------------------------

    reg [23:0] spatial_result;

    always @(*) begin
        spatial_result = 24'h000000;

        case (mode_latched)

            // Gaussian blur
            4'h9: spatial_result = {
                gaussian_channel(
                    p00[23:16],p01[23:16],p02[23:16],
                    p10[23:16],p11[23:16],p12[23:16],
                    p20[23:16],p21[23:16],p22[23:16]
                ),
                gaussian_channel(
                    p00[15:8],p01[15:8],p02[15:8],
                    p10[15:8],p11[15:8],p12[15:8],
                    p20[15:8],p21[15:8],p22[15:8]
                ),
                gaussian_channel(
                    p00[7:0],p01[7:0],p02[7:0],
                    p10[7:0],p11[7:0],p12[7:0],
                    p20[7:0],p21[7:0],p22[7:0]
                )
            };

            // Sobel
            4'hA: spatial_result =
                {sobel8,sobel8,sobel8};

            // Sharpen
            4'hB: spatial_result = {
                sharpen_channel(
                    p01[23:16],p10[23:16],
                    p11[23:16],p12[23:16],
                    p21[23:16]
                ),
                sharpen_channel(
                    p01[15:8],p10[15:8],
                    p11[15:8],p12[15:8],
                    p21[15:8]
                ),
                sharpen_channel(
                    p01[7:0],p10[7:0],
                    p11[7:0],p12[7:0],
                    p21[7:0]
                )
            };

            // Emboss
            4'hC: spatial_result = {
                emboss_channel(p00[23:16],p22[23:16]),
                emboss_channel(p00[15:8],p22[15:8]),
                emboss_channel(p00[7:0],p22[7:0])
            };

            default:
                spatial_result = point_result;

        endcase
    end

    // -------------------------------------------------
    // Frame buffer: single write port
    // -------------------------------------------------

    reg [23:0] out_mem [0:3071];

    reg        out_we;
    reg [11:0] out_addr;
    reg [23:0] out_data;

    always @(posedge clk) begin
        if (out_we)
            out_mem[out_addr] <= out_data;

        display_pixel <= out_mem[display_address];
    end

    // -------------------------------------------------
    // Controller
    // -------------------------------------------------

    reg [11:0] write_addr_d;
    reg [23:0] write_data_d;
    reg        write_valid_d;

    reg [11:0] issue_addr_d;
    reg [5:0]  issue_x_d;
    reg [5:0]  issue_y_d;
    reg        issue_valid_d;

    wire spatial_mode =
        (mode_latched >= 4'h9) &&
        (mode_latched <= 4'hC);

    // ROM address follows the scan counter
    always @(*) begin
        rom_addr = scan_addr;
    end

    always @(*) begin
        out_we   = 1'b0;
        out_addr = 12'd0;
        out_data = 24'd0;

        if (state == ST_CLEAR) begin
            out_we   = 1'b1;
            out_addr = clear_addr;
            out_data = 24'h000000;
        end
        else if (state == ST_SCAN ||
                 state == ST_DRAIN) begin

            if (write_valid_d) begin
                out_we   = 1'b1;
                out_addr = write_addr_d;
                out_data = write_data_d;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_CLEAR;

            clear_addr <= 0;
            scan_addr <= 0;

            mode_previous <= 0;
            mode_latched <= 0;

            issue_addr <= 0;
            issue_x <= 0;
            issue_y <= 0;

            issue_addr_d <= 0;
            issue_x_d <= 0;
            issue_y_d <= 0;
            issue_valid_d <= 0;

            write_addr_d <= 0;
            write_data_d <= 0;
            write_valid_d <= 0;

            ready <= 0;

            t2 <= 0; t1 <= 0;
            m2 <= 0; m1 <= 0;
            b2 <= 0; b1 <= 0;
        end
        else begin

            if (mode != mode_previous) begin
                mode_previous <= mode;
                mode_latched <= mode;

                state <= ST_CLEAR;
                clear_addr <= 0;
                scan_addr <= 0;

                issue_valid_d <= 0;
                write_valid_d <= 0;

                ready <= 0;

                t2 <= 0; t1 <= 0;
                m2 <= 0; m1 <= 0;
                b2 <= 0; b1 <= 0;
            end
            else begin

                case (state)

                    ST_CLEAR: begin
                        ready <= 0;

                        if (clear_addr == N-1) begin
                            state <= ST_PRIME;
                            scan_addr <= 0;
                        end
                        else
                            clear_addr <= clear_addr + 1'b1;
                    end

                    ST_PRIME: begin
                        // Prime the synchronous ROM pipeline
                        issue_valid_d <= 0;
                        write_valid_d <= 0;
                        state <= ST_SCAN;
                    end

                    ST_SCAN: begin

                        // Track the pixel associated with
                        // the synchronous ROM output.
                        issue_addr_d <= scan_addr;
                        issue_x_d <= scan_addr[5:0];
                        issue_y_d <= scan_addr[11:6];
                        issue_valid_d <= 1'b1;

                        if (scan_addr == N-1)
                            state <= ST_DRAIN;
                        else
                            scan_addr <= scan_addr + 1'b1;

                        // Process previous ROM pixel
                        if (issue_valid_d) begin

                            issue_addr <= issue_addr_d;
                            issue_x <= issue_x_d;
                            issue_y <= issue_y_d;

                            line2[issue_x_d] <= line1[issue_x_d];
                            line1[issue_x_d] <= source_pixel;

                            if (issue_x_d == 0) begin
                                t2 <= 0;
                                t1 <= line2[issue_x_d];

                                m2 <= 0;
                                m1 <= line1[issue_x_d];

                                b2 <= 0;
                                b1 <= source_pixel;
                            end
                            else begin
                                t2 <= t1;
                                t1 <= line2[issue_x_d];

                                m2 <= m1;
                                m1 <= line1[issue_x_d];

                                b2 <= b1;
                                b1 <= source_pixel;
                            end

                            if (spatial_mode) begin

                                if ((issue_x_d >= 2) &&
                                    (issue_y_d >= 2)) begin

                                    write_valid_d <= 1'b1;

                                    write_addr_d <=
                                        {(issue_y_d-6'd1),
                                         (issue_x_d-6'd1)};

                                    write_data_d <= spatial_result;
                                end
                                else
                                    write_valid_d <= 1'b0;
                            end
                            else begin
                                write_valid_d <= 1'b1;
                                write_addr_d <= issue_addr_d;
                                write_data_d <= point_result;
                            end
                        end
                        else
                            write_valid_d <= 1'b0;
                    end

                    ST_DRAIN: begin
                        issue_valid_d <= 0;

                        if (issue_valid_d) begin

                            line2[issue_x_d] <= line1[issue_x_d];
                            line1[issue_x_d] <= source_pixel;

                            if (issue_x_d == 0) begin
                                t2 <= 0;
                                t1 <= line2[issue_x_d];

                                m2 <= 0;
                                m1 <= line1[issue_x_d];

                                b2 <= 0;
                                b1 <= source_pixel;
                            end
                            else begin
                                t2 <= t1;
                                t1 <= line2[issue_x_d];

                                m2 <= m1;
                                m1 <= line1[issue_x_d];

                                b2 <= b1;
                                b1 <= source_pixel;
                            end

                            if (spatial_mode) begin
                                if ((issue_x_d >= 2) &&
                                    (issue_y_d >= 2)) begin

                                    write_valid_d <= 1'b1;
                                    write_addr_d <=
                                        {(issue_y_d-6'd1),
                                         (issue_x_d-6'd1)};
                                    write_data_d <= spatial_result;
                                end
                                else
                                    write_valid_d <= 0;
                            end
                            else begin
                                write_valid_d <= 1;
                                write_addr_d <= issue_addr_d;
                                write_data_d <= point_result;
                            end
                        end
                        else begin
                            write_valid_d <= 0;
                            state <= ST_DONE;
                        end
                    end

                    ST_DONE: begin
                        ready <= 1'b1;
                    end

                    default: state <= ST_CLEAR;

                endcase
            end
        end
    end

endmodule
