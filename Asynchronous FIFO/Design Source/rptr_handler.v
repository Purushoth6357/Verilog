`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2026 03:06:57 PM
// Design Name: 
// Module Name: rptr_handler
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
module rptr_handler #(
    parameter ADDR_WIDTH = 4
)(
    input  wire                  rclk,
    input  wire                  rrst_n,
    input  wire                  r_en,
    input  wire [ADDR_WIDTH:0]   g_wptr_sync,

    output reg  [ADDR_WIDTH:0]   b_rptr,
    output reg  [ADDR_WIDTH:0]   g_rptr,
    output reg                   empty
);

    localparam PTR_WIDTH = ADDR_WIDTH + 1;

    // Next pointer values
    wire [PTR_WIDTH-1:0] b_rptr_next;
    wire [PTR_WIDTH-1:0] g_rptr_next;

    wire rempty_val;

    // Read pointer increments only when read is accepted
    assign b_rptr_next = b_rptr + (r_en && !empty);

    // Binary to Gray conversion
    assign g_rptr_next =
        (b_rptr_next >> 1) ^ b_rptr_next;

    // Empty detection
    assign rempty_val =
        (g_rptr_next == g_wptr_sync);

    // Sequential pointer and flag update
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            b_rptr <= 0;
            g_rptr <= 0;
            empty  <= 1'b1;
        end
        else begin
            b_rptr <= b_rptr_next;
            g_rptr <= g_rptr_next;
            empty  <= rempty_val;
        end
    end

endmodule
