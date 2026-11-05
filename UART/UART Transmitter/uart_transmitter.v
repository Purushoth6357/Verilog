
module uart_transmitter #(
    parameter integer CLKS_PER_BIT = 217
)(
    input  wire       clk,
    input  wire       rst_n,

    input  wire [7:0] data_in,
    input  wire       send,

    output wire       serial_out,
    output wire       busy
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    localparam integer COUNT_WIDTH =
        (CLKS_PER_BIT <= 1) ? 1 : $clog2(CLKS_PER_BIT);

    localparam [COUNT_WIDTH-1:0] FULL_BIT_COUNT =
        CLKS_PER_BIT - 1;

    reg [1:0] state;
    reg [COUNT_WIDTH-1:0] clk_count;

    reg [7:0] data_buf;
    reg [2:0] data_index;

    reg tx_reg;

    assign serial_out = tx_reg;
    assign busy = (state != IDLE);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            clk_count  <= 0;
            data_buf   <= 0;
            data_index <= 0;
            tx_reg     <= 1'b1;
        end
        else begin
            case (state)

                IDLE: begin
                    tx_reg    <= 1'b1;
                    clk_count <= 0;

                    if (send) begin
                        data_buf   <= data_in;
                        data_index <= 0;
                        tx_reg     <= 1'b0;
                        state      <= START;
                    end
                end

                START: begin
                    tx_reg <= 1'b0;

                    if (clk_count == FULL_BIT_COUNT) begin
                        clk_count <= 0;
                        tx_reg    <= data_buf[0];
                        data_buf  <= data_buf >> 1;
                        state     <= DATA;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    if (clk_count == FULL_BIT_COUNT) begin
                        clk_count <= 0;

                        if (data_index == 3'd7) begin
                            data_index <= 0;
                            tx_reg     <= 1'b1;
                            state      <= STOP;
                        end
                        else begin
                            data_index <= data_index + 1'b1;
                            tx_reg     <= data_buf[0];
                            data_buf   <= data_buf >> 1;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    tx_reg <= 1'b1;

                    if (clk_count == FULL_BIT_COUNT) begin
                        clk_count <= 0;
                        state     <= IDLE;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state      <= IDLE;
                    clk_count  <= 0;
                    tx_reg     <= 1'b1;
                    data_index <= 0;
                end

            endcase
        end
    end

endmodule

