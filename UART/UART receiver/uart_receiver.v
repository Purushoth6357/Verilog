`timescale 1ns/1ps
module uart_receiver #(
    parameter integer CLKS_PER_BIT = 217
)(
    input wire clk,
    input wire rst_n,
    input wire serial_in,

    output reg [7:0] data_out,
    output reg data_ready
);

    // Counter width calculation
    localparam integer COUNT_WIDTH =
        (CLKS_PER_BIT <= 2) ? 1 : $clog2(CLKS_PER_BIT);

    localparam integer HALF_BIT = CLKS_PER_BIT / 2;
    localparam [COUNT_WIDTH-1:0] HALF_BIT_COUNT =
    COUNT_WIDTH'(HALF_BIT - 1);

    localparam [COUNT_WIDTH-1:0] FULL_BIT_COUNT =
    COUNT_WIDTH'(CLKS_PER_BIT - 1);
    // FSM states
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam RECV  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0] state;

    reg [COUNT_WIDTH-1:0] clk_count;
    reg [2:0] bit_index;

    reg [7:0] data_buf;

    // Synchronizer registers
    reg rx_meta;
    reg rx_sync;

    // Two-stage synchronizer
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end
        else begin
            rx_meta <= serial_in;
            rx_sync <= rx_meta;
        end
    end

    // UART receiver FSM
    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state      <= IDLE;
            clk_count  <= 0;
            bit_index  <= 0;
            data_buf   <= 0;
            data_out   <= 0;
            data_ready <= 1'b0;
        end

        else begin

            // Default: one-cycle pulse
            data_ready <= 1'b0;

            case (state)

                // Wait for start bit
                IDLE: begin

                    clk_count <= 0;
                    bit_index <= 0;

                    if (rx_sync == 1'b0)
                        state <= START;

                end

                // Verify start bit at its midpoint
                START: begin

                    if (clk_count == HALF_BIT_COUNT) begin
				
                        clk_count <= 0;

                        if (rx_sync == 1'b0)
                            state <= RECV;
                        else
                            state <= IDLE;

                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end

                end

                // Receive 8 data bits
                RECV: begin

                    if (clk_count == FULL_BIT_COUNT) begin

                        clk_count <= 0;

                        // LSB first
                        data_buf[bit_index] <= rx_sync;

                        if (bit_index == 3'd7) begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                        end

                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end

                end

                // Validate stop bit
                STOP: begin

                    if (clk_count == FULL_BIT_COUNT) begin

                        clk_count <= 0;
                        state <= IDLE;

                        if (rx_sync == 1'b1) begin
                            data_out <= data_buf;
                            data_ready <= 1'b1;
                        end

                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end

                end

                default: begin
                    state <= IDLE;
                    clk_count <= 0;
                    bit_index <= 0;
                end

            endcase
        end
    end

endmodule:uart_receiver
