
module trafficlight #(
    parameter CLK_FREQ = 50_000_000
)(
    input  wire       sideroad_has_car,
    input  wire       config_bit,
    input  wire       clk,
    input  wire       rst_n,

    output reg  [1:0] mainroad,
    output reg  [1:0] sideroad,
    output reg        timer_start
);

    // Active-low LED output encoding
    localparam RED    = 2'b00;
    localparam YELLOW = 2'b01;
    localparam GREEN  = 2'b10;

    // Normal sensor-controlled states
    localparam S0 = 3'b000; // Main green, side red
    localparam S1 = 3'b001; // Main yellow, side red
    localparam S2 = 3'b010; // Main red, side green
    localparam S3 = 3'b011; // Main red, side yellow

    // Fixed-time states
    localparam F0 = 3'b100; // Main red, side green
    localparam F1 = 3'b101; // Main red, side yellow
    localparam F2 = 3'b110; // Main green, side red
    localparam F3 = 3'b111; // Main yellow, side red

    reg [2:0] state, next_state;

    reg [31:0] counter;
    reg timer_done;
    reg [31:0] timer_limit;

    // State register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state logic
    always @(*) begin
        next_state = state;

        if (!config_bit) begin
            // Normal mode
            case (state)
                S0: if (sideroad_has_car)
                        next_state = S1;

                S1: if (timer_done)
                        next_state = S2;

                S2: if (!sideroad_has_car)
                        next_state = S3;

                S3: if (timer_done)
                        next_state = S0;

                default: next_state = S0;
            endcase
        end
        else begin
            // Fixed-time mode
            case (state)
                F0: if (timer_done)
                        next_state = F1;

                F1: if (timer_done)
                        next_state = F2;

                F2: if (timer_done)
                        next_state = F3;

                F3: if (timer_done)
                        next_state = F0;

                default: next_state = F0;
            endcase
        end
    end

    // Output and timer selection logic
    always @(*) begin
        mainroad    = ~RED;
        sideroad    = ~RED;
        timer_start = 1'b0;
        timer_limit = CLK_FREQ * 3;

        case (state)
            // Normal mode
            S0: begin
                mainroad = ~GREEN;
            end

            S1: begin
                mainroad    = ~YELLOW;
                timer_start = 1'b1;
                timer_limit = CLK_FREQ * 3;
            end

            S2: begin
                sideroad = ~GREEN;
            end

            S3: begin
                sideroad    = ~YELLOW;
                timer_start = 1'b1;
                timer_limit = CLK_FREQ * 3;
            end

            // Fixed-time mode
            F0: begin
                sideroad    = ~GREEN;
                timer_start = 1'b1;
                timer_limit = CLK_FREQ * 5;
            end

            F1: begin
                sideroad    = ~YELLOW;
                timer_start = 1'b1;
                timer_limit = CLK_FREQ * 3;
            end

            F2: begin
                mainroad    = ~GREEN;
                timer_start = 1'b1;
                timer_limit = CLK_FREQ * 5;
            end

            F3: begin
                mainroad    = ~YELLOW;
                timer_start = 1'b1;
                timer_limit = CLK_FREQ * 3;
            end

            default: begin
                mainroad    = ~RED;
                sideroad    = ~RED;
            end
        endcase

        // Both roads red when the state belongs to the wrong mode
        if ((!config_bit && state[2]) ||
            (config_bit && !state[2])) begin
            mainroad    = ~RED;
            sideroad    = ~RED;
            timer_start = 1'b0;
        end
    end

    // Shared timer
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter    <= 32'd0;
            timer_done <= 1'b0;
        end
        else if (!timer_start) begin
            counter    <= 32'd0;
            timer_done <= 1'b0;
        end
        else if (counter >= timer_limit - 1'b1) begin
            counter    <= 32'd0;
            timer_done <= 1'b1;
        end
        else begin
            counter    <= counter + 1'b1;
            timer_done <= 1'b0;
        end
    end

endmodule
