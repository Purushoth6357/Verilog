`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2026 03:17:13 PM
// Design Name: 
// Module Name: fifo_mem
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


module fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = 4
)(
    input  wire                    wclk,
    input  wire                    rclk,
    input  wire                    rrst_n,
    input  wire                    w_en,
    input  wire                    r_en,

    input  wire [ADDR_WIDTH:0]     b_wptr,
    input  wire [ADDR_WIDTH:0]     b_rptr,

    input  wire [DATA_WIDTH-1:0]   data_in,
    output reg  [DATA_WIDTH-1:0]   data_out,

    input  wire                    full,
    input  wire                    empty
);

    reg [DATA_WIDTH-1:0] fifo [0:DEPTH-1];

    // Write port
    always @(posedge wclk) begin
        if (w_en && !full)
            fifo[b_wptr[ADDR_WIDTH-1:0]] <= data_in;
    end

    // Registered read port
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            data_out <= 0;
        else if (r_en && !empty)
            data_out <= fifo[b_rptr[ADDR_WIDTH-1:0]];
    end

endmodule