`timescale 1ns/1ps

module top_uart_apb (
    input         CLK,
    input         RESETn,

    // APB interface
    input  [31:0] PADDR,
    input  [31:0] PWDATA,
    input         PWRITE,
    input         PSELx,
    input         PENABLE,
    output [31:0] PRDATA,
    output        PREADY,

    // UART interface
    input         rx,
    output        tx,
    output        rdy,
    output        tx_busy,
    output [7:0]  dout,
    output        rdy_clr
);
    wire [7:0]  din;
    wire        wr_en;
    uart_apb_bridge bridge_inst (
        .CLK(CLK),
        .RESETn(RESETn),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PSELx(PSELx),
        .PENABLE(PENABLE),
        .PREADY(PREADY),
        .PRDATA(PRDATA),

        .din(din),
        .wr_en(wr_en),
        .tx(tx),
        .tx_busy(tx_busy),
        .rx(rx),
        .dout(dout),
        .rdy(rdy),
        .rdy_clr(rdy_clr)
    );

endmodule

