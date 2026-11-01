`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2026 12:57:51 PM
// Design Name: 
// Module Name: wptr_handler
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

module wptr_handler #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                  wclk,
    input  wire                  wrst_n,
    input  wire                  w_en,
    input  wire [ADDR_WIDTH:0]   g_rptr_sync,

    output reg  [ADDR_WIDTH:0]   b_wptr,
    output reg  [ADDR_WIDTH:0]   g_wptr,
    output reg                   full
);

    localparam PTR_WIDTH = ADDR_WIDTH + 1;

    // Next pointer values
    wire [PTR_WIDTH-1:0] b_wptr_next;
    wire [PTR_WIDTH-1:0] g_wptr_next;

    wire wfull_val;

    // Invert the two most significant Gray pointer bits
    localparam [PTR_WIDTH-1:0] FULL_MASK =
        {2'b11, {(PTR_WIDTH-2){1'b0}}};

    // Write pointer increments only when write is accepted
    assign b_wptr_next = b_wptr + (w_en && !full);

    // Binary to Gray conversion
    assign g_wptr_next =
        (b_wptr_next >> 1) ^ b_wptr_next;

    // Full detection
    assign wfull_val =
        (g_wptr_next == (g_rptr_sync ^ FULL_MASK));

    // Sequential pointer and flag update
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            b_wptr <= 0;
            g_wptr <= 0;
            full   <= 0;
        end
        else begin
            b_wptr <= b_wptr_next;
            g_wptr <= g_wptr_next;
            full   <= wfull_val;
        end
    end

endmodule
