
`timescale 1ns/1ps

//============================================================
// TOP LEVEL UART
// 8-bit data, 1 start bit, 1 stop bit, no parity
//============================================================

module uart #(
    parameter integer CLK_FREQ  = 50000000,
    parameter integer BAUD_RATE = 115200
)(
    input  wire       clk_50m,
    input  wire       rst_n,

    input  wire [7:0] din,
    input  wire       wr_en,

    output wire       tx,
    output wire       tx_busy,

    input  wire       rx,
    output wire       rdy,
    input  wire       rdy_clr,
    output wire [7:0] dout
);

    wire rxclk_en;
    wire txclk_en;

    // Baud rate generator
    baud_rate_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uart_baud (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .rxclk_en(rxclk_en),
        .txclk_en(txclk_en)
    );

    // UART transmitter
    transmitter uart_tx (
        .din(din),
        .wr_en(wr_en),
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .clken(txclk_en),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    // UART receiver
    receiver uart_rx (
        .rx(rx),
        .rdy(rdy),
        .rdy_clr(rdy_clr),
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .clken(rxclk_en),
        .data(dout)
    );

endmodule


//============================================================
// BAUD RATE GENERATOR
// TX: 1x baud enable
// RX: 16x baud enable
//============================================================

module baud_rate_gen #(
    parameter integer CLK_FREQ  = 50000000,
    parameter integer BAUD_RATE = 115200
)(
    input  wire clk_50m,
    input  wire rst_n,
    output reg  rxclk_en,
    output reg  txclk_en
);

    localparam integer TX_DIV =
        CLK_FREQ / BAUD_RATE;

    localparam integer RX_DIV =
        CLK_FREQ / (BAUD_RATE * 16);

    reg [31:0] tx_count;
    reg [31:0] rx_count;

    always @(posedge clk_50m) begin

        if (!rst_n) begin
            tx_count <= 0;
            rx_count <= 0;
            txclk_en <= 0;
            rxclk_en <= 0;
        end

        else begin

            // TX baud enable
            if (tx_count == TX_DIV - 1) begin
                tx_count <= 0;
                txclk_en <= 1'b1;
            end
            else begin
                tx_count <= tx_count + 1'b1;
                txclk_en <= 1'b0;
            end

            // RX 16x baud enable
            if (rx_count == RX_DIV - 1) begin
                rx_count <= 0;
                rxclk_en <= 1'b1;
            end
            else begin
                rx_count <= rx_count + 1'b1;
                rxclk_en <= 1'b0;
            end

        end
    end

endmodule


//============================================================
// UART TRANSMITTER
//============================================================

module transmitter(
    input  wire [7:0] din,
    input  wire       wr_en,
    input  wire       clk_50m,
    input  wire       rst_n,
    input  wire       clken,
    output reg        tx,
    output wire       tx_busy
);

    localparam STATE_IDLE  = 2'b00;
    localparam STATE_START = 2'b01;
    localparam STATE_DATA  = 2'b10;
    localparam STATE_STOP  = 2'b11;

    reg [1:0] state;
    reg [7:0] data;
    reg [2:0] bitpos;

    always @(posedge clk_50m) begin

        if (!rst_n) begin
            state  <= STATE_IDLE;
            tx     <= 1'b1;
            data   <= 8'h00;
            bitpos <= 3'b000;
        end

        else begin

            case (state)

                // IDLE STATE
                STATE_IDLE: begin

                    tx <= 1'b1;

                    if (wr_en) begin
                        data   <= din;
                        bitpos <= 0;
                        state  <= STATE_START;
                    end

                end

                // START BIT
                STATE_START: begin

                    if (clken) begin
                        tx    <= 1'b0;
                        state <= STATE_DATA;
                    end

                end

                // DATA BITS - LSB FIRST
                STATE_DATA: begin

                    if (clken) begin

                        tx <= data[bitpos];

                        if (bitpos == 3'd7) begin
                            state <= STATE_STOP;
                        end
                        else begin
                            bitpos <= bitpos + 1'b1;
                        end

                    end

                end

                // STOP BIT
                STATE_STOP: begin

                    if (clken) begin
                        tx    <= 1'b1;
                        state <= STATE_IDLE;
                    end

                end

                default: begin
                    state <= STATE_IDLE;
                    tx    <= 1'b1;
                end

            endcase

        end
    end

    assign tx_busy = (state != STATE_IDLE);

endmodule


//============================================================
// UART RECEIVER
// 16x OVERSAMPLING
//============================================================

module receiver(
    input  wire       rx,
    output reg        rdy,
    input  wire       rdy_clr,
    input  wire       clk_50m,
    input  wire       rst_n,
    input  wire       clken,
    output reg [7:0]  data
);

    localparam RX_IDLE  = 2'b00;
    localparam RX_START = 2'b01;
    localparam RX_DATA  = 2'b10;
    localparam RX_STOP  = 2'b11;

    reg [1:0] state;

    reg [3:0] sample;
    reg [2:0] bitpos;

    reg [7:0] scratch;

    //========================================================
    // TWO-STAGE RX SYNCHRONIZER
    //========================================================

    reg rx_meta;
    reg rx_sync;

    always @(posedge clk_50m) begin

        if (!rst_n) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end

        else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end

    end

    //========================================================
    // RECEIVER FSM
    //========================================================

    always @(posedge clk_50m) begin

        if (!rst_n) begin

            state   <= RX_IDLE;
            sample  <= 0;
            bitpos  <= 0;
            scratch <= 0;
            data    <= 0;
            rdy     <= 0;

        end

        else begin

            // Clear ready flag
            if (rdy_clr)
                rdy <= 1'b0;

            if (clken) begin

                case (state)

                    //========================================
                    // IDLE STATE
                    //========================================

                    RX_IDLE: begin

                        sample <= 0;

                        // Detect falling edge / start bit
                        if (!rx_sync) begin
                            state  <= RX_START;
                            sample <= 0;
                        end

                    end

                    //========================================
                    // START BIT VALIDATION
                    //========================================

                    RX_START: begin

                        // Check start bit midpoint
                        if (sample == 4'd7) begin

                            if (!rx_sync) begin

                                state   <= RX_DATA;
                                sample  <= 0;
                                bitpos  <= 0;
                                scratch <= 0;

                            end

                            else begin

                                // False start detection
                                state  <= RX_IDLE;
                                sample <= 0;

                            end

                        end

                        else begin
                            sample <= sample + 1'b1;
                        end

                    end

                    //========================================
                    // DATA RECEPTION
                    //========================================

                    RX_DATA: begin

                        // Sample every 16 RX enable pulses
                        if (sample == 4'd15) begin

                            sample <= 0;

                            // Store received bit
                            scratch[bitpos] <= rx_sync;

                            if (bitpos == 3'd7) begin

                                state <= RX_STOP;

                            end

                            else begin

                                bitpos <= bitpos + 1'b1;

                            end

                        end

                        else begin
                            sample <= sample + 1'b1;
                        end

                    end

                    //========================================
                    // STOP BIT VALIDATION
                    //========================================

                    RX_STOP: begin

                        // Check stop bit
                        if (sample == 4'd15) begin

                            if (rx_sync) begin

                                // Valid frame
                                data <= scratch;
                                rdy  <= 1'b1;

                            end

                            // Invalid stop bit:
                            // Discard received byte

                            state  <= RX_IDLE;
                            sample <= 0;

                        end

                        else begin
                            sample <= sample + 1'b1;
                        end

                    end

                    //========================================
                    // DEFAULT STATE
                    //========================================

                    default: begin

                        state  <= RX_IDLE;
                        sample <= 0;

                    end

                endcase

            end

        end
    end

endmodule

