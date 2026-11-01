`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2026 10:06:57 PM
// Design Name: 
// Module Name: async_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module async_fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = 4
)(
    // Write interface
    input  wire                    wclk,
    input  wire                    wrst_n,
    input  wire                    w_en,
    input  wire [DATA_WIDTH-1:0]   wdata,
    output wire                    full,

    // Read interface
    input  wire                    rclk,
    input  wire                    rrst_n,
    input  wire                    r_en,
    output wire [DATA_WIDTH-1:0]   rdata,
    output wire                    empty
);

    localparam PTR_WIDTH = ADDR_WIDTH + 1;

    // Binary pointers
    wire [PTR_WIDTH-1:0] b_wptr;
    wire [PTR_WIDTH-1:0] b_rptr;

    // Gray pointers
    wire [PTR_WIDTH-1:0] g_wptr;
    wire [PTR_WIDTH-1:0] g_rptr;

    // Synchronized Gray pointers
    wire [PTR_WIDTH-1:0] g_wptr_sync;
    wire [PTR_WIDTH-1:0] g_rptr_sync;

    // ------------------------------------------------
    // Write pointer handler
    // ------------------------------------------------

    wptr_handler #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) write_pointer (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .w_en(w_en),
        .g_rptr_sync(g_rptr_sync),
        .b_wptr(b_wptr),
        .g_wptr(g_wptr),
        .full(full)
    );

    // ------------------------------------------------
    // Read pointer handler
    // ------------------------------------------------

    rptr_handler #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) read_pointer (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .r_en(r_en),
        .g_wptr_sync(g_wptr_sync),
        .b_rptr(b_rptr),
        .g_rptr(g_rptr),
        .empty(empty)
    );

    // ------------------------------------------------
    // Write pointer -> Read clock domain
    // ------------------------------------------------

    synchronizer #(
        .WIDTH(PTR_WIDTH)
    ) write_pointer_sync (
        .clk(rclk),
        .rst_n(rrst_n),
        .d_in(g_wptr),
        .d_out(g_wptr_sync)
    );

    // ------------------------------------------------
    // Read pointer -> Write clock domain
    // ------------------------------------------------

    synchronizer #(
        .WIDTH(PTR_WIDTH)
    ) read_pointer_sync (
        .clk(wclk),
        .rst_n(wrst_n),
        .d_in(g_rptr),
        .d_out(g_rptr_sync)
    );

    // ------------------------------------------------
    // Dual-clock memory
    // ------------------------------------------------

    fifo_mem #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) memory (
        .wclk(wclk),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .w_en(w_en),
        .r_en(r_en),
        .b_wptr(b_wptr),
        .b_rptr(b_rptr),
        .data_in(wdata),
        .data_out(rdata),
        .full(full),
        .empty(empty)
    );

    // Parameter validation
    initial begin
        if (DEPTH < 2 || (DEPTH & (DEPTH - 1)) != 0)
            $error("DEPTH must be a power of two and >= 2");

        if (DEPTH != (1 << ADDR_WIDTH))
            $error("ADDR_WIDTH must equal clog2(DEPTH)");
    end

endmodule
