`timescale 1ns / 1ps

module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] din,
    output reg  [DATA_WIDTH-1:0] dout,
    output wire                 full,
    output wire                 empty
);

    // Pointer and counter widths
    localparam PTR_WIDTH   = (DEPTH <= 1) ? 1 : $clog2(DEPTH);
    localparam COUNT_WIDTH = $clog2(DEPTH + 1);

    // FIFO pointers and occupancy counter
    reg [PTR_WIDTH-1:0] wr_ptr;
    reg [PTR_WIDTH-1:0] rd_ptr;
    reg [COUNT_WIDTH-1:0] count;

    // FIFO memory
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Status flags
    assign full  = (count == DEPTH);
    assign empty = (count == 0);

    // Read and write acceptance
    wire write_accept = wr_en && !full;
    wire read_accept  = rd_en && !empty;

    // Write operation
    always @(posedge clk) begin
        if (write_accept)
            mem[wr_ptr] <= din;
    end

    // Read operation
    always @(posedge clk or posedge rst) begin
        if (rst)
            dout <= 0;
        else if (read_accept)
            dout <= mem[rd_ptr];
    end

    // Write pointer
    always @(posedge clk or posedge rst) begin
        if (rst)
            wr_ptr <= 0;
        else if (write_accept) begin
            if (wr_ptr == DEPTH - 1)
                wr_ptr <= 0;
            else
                wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // Read pointer
    always @(posedge clk or posedge rst) begin
        if (rst)
            rd_ptr <= 0;
        else if (read_accept) begin
            if (rd_ptr == DEPTH - 1)
                rd_ptr <= 0;
            else
                rd_ptr <= rd_ptr + 1'b1;
        end
    end

    // Occupancy counter
    always @(posedge clk or posedge rst) begin
        if (rst)
            count <= 0;
        else begin
            case ({write_accept, read_accept})
                2'b10: count <= count + 1'b1; // Write only
                2'b01: count <= count - 1'b1; // Read only
                default: count <= count;      // Both or neither
            endcase
        end
    end

endmodule
