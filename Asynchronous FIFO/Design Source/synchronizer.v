`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/01/2026 12:39:40 PM
// Design Name: 
// Module Name: synchronizer
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

module synchronizer #(
    parameter WIDTH = 4
)(
    input clk,
    input rst_n,
    input [WIDTH:0] d_in,
    output wire [WIDTH:0] d_out
);

    reg [WIDTH:0] q1, q2;

    always @(posedge clk) begin
        if (!rst_n) begin
            q1    <= 0;
            q2 <= 0;
        end
        else begin
            q1    <= d_in;
            q2 <= q1;
        end
    end
    
    assign d_out = q2;

endmodule
