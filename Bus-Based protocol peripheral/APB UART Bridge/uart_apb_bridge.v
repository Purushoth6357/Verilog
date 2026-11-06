`timescale 1ns/1ps

module uart_apb_bridge (
    // APB interface
    input        CLK,
    input        RESETn,
    input [31:0] PADDR,
    input [31:0] PWDATA,
    input        PWRITE,
    input        PSELx,
    input        PENABLE,
    output reg   PREADY,
    output reg [31:0] PRDATA,

    // UART interface
    output reg [7:0] din,
    output reg       wr_en,
    output           tx,
    output            tx_busy,

    input            rx,
    output      [7:0] dout,
    output            rdy,
    output reg       rdy_clr
);

    // Instantiate the UART module
    uart #(
    .CLK_FREQ(50000000),
    .BAUD_RATE(115200)
) uart_inst (
    .clk_50m(CLK),
    .rst_n(RESETn),

    .din(din),
    .wr_en(wr_en),

    .tx(tx),
    .tx_busy(tx_busy),

    .rx(rx),
    .rdy(rdy),
    .rdy_clr(rdy_clr),
    .dout(dout)
);
	
	reg wr_en_next;

    always @(posedge CLK or negedge RESETn) begin
        if (!RESETn) begin
            din      <= 8'd0;
            wr_en    <= 1'b0;
            rdy_clr  <= 1'b0;
            PREADY   <= 1'b0;
            PRDATA   <= 32'd0;
        end else begin
            wr_en    <= 1'b0;
            rdy_clr  <= 1'b0;
            PREADY   <= 1'b0;

            if (PSELx && PENABLE) begin
                PREADY <= 1'b1; // Complete in 1 cycle

                if (PWRITE) begin
                    case (PADDR[7:0])
                        8'h00: begin  // TX data write
                            din   <= PWDATA[7:0];
                            wr_en <= 1'b1;
                        end
                        8'h0C: begin  // Clear RX ready
                            rdy_clr <= 1'b1;
                        end
                    endcase
                end else begin
                    case (PADDR[7:0])
                        8'h04: PRDATA <= {24'd0, dout}; // RX data
                        8'h08: PRDATA <= {30'd0, tx_busy, rdy}; // Status
                        default: PRDATA <= 32'd0;
                    endcase
                end
            end
        end
    end
endmodule
