
module apb_timer #(
    parameter integer WIDTH = 8
)(
    // APB3 interface
    input  wire        PCLK,
    input  wire        PRESETn,
    input  wire        PSEL,
    input  wire        PENABLE,
    input  wire        PWRITE,
    input  wire [7:0]  PADDR,
    input  wire [31:0] PWDATA,

    output reg  [31:0] PRDATA,
    output wire        PREADY,
    output wire        PSLVERR,

    // Timer output
    output reg         timer_done
);

    // ------------------------------------------------
    // Register addresses
    // ------------------------------------------------
    localparam [7:0] ADDR_LOAD   = 8'h00;
    localparam [7:0] ADDR_CTRL   = 8'h04;
    localparam [7:0] ADDR_COUNT  = 8'h08;
    localparam [7:0] ADDR_STATUS = 8'h0C;

    // ------------------------------------------------
    // Internal registers
    // ------------------------------------------------
    reg [WIDTH-1:0] load_val;
    reg [WIDTH-1:0] count;
    reg             running;

    // ------------------------------------------------
    // APB3: zero-wait-state slave
    // ------------------------------------------------
    assign PREADY = 1'b1;

    wire apb_access;
    assign apb_access = PSEL && PENABLE && PREADY;

    // Error for invalid addresses and writes to read-only registers
    assign PSLVERR = apb_access &&
                     (
                         (PWRITE &&
                             (PADDR != ADDR_LOAD) &&
                             (PADDR != ADDR_CTRL))
                         ||
                         (!PWRITE &&
                             (PADDR != ADDR_LOAD)   &&
                             (PADDR != ADDR_CTRL)   &&
                             (PADDR != ADDR_COUNT)  &&
                             (PADDR != ADDR_STATUS))
                     );

    // ------------------------------------------------
    // APB read logic
    // ------------------------------------------------
    always @(*) begin
        PRDATA = 32'h00000000;

        if (apb_access && !PWRITE && !PSLVERR) begin
            case (PADDR)

                ADDR_LOAD:
                    PRDATA = {{(32-WIDTH){1'b0}}, load_val};

                ADDR_CTRL:
                    PRDATA = {31'b0, running};

                ADDR_COUNT:
                    PRDATA = {{(32-WIDTH){1'b0}}, count};

                ADDR_STATUS:
                    PRDATA = {31'b0, timer_done};

                default:
                    PRDATA = 32'h00000000;

            endcase
        end
    end

    // ------------------------------------------------
    // Timer and APB write logic
    // All state registers have ONE sequential driver
    // ------------------------------------------------
    always @(posedge PCLK or negedge PRESETn) begin

        if (!PRESETn) begin
            load_val  <= {WIDTH{1'b0}};
            count     <= {WIDTH{1'b0}};
            running   <= 1'b0;
            timer_done <= 1'b0;
        end

        // APB write has priority over timer counting
        else if (apb_access && PWRITE && !PSLVERR) begin

            case (PADDR)

                // Load register
                ADDR_LOAD: begin
                    load_val <= PWDATA[WIDTH-1:0];
                end

                // Control register
                ADDR_CTRL: begin

                    // START or RESTART
                    if (PWDATA[0]) begin

                        count      <= load_val;
                        timer_done <= 1'b0;

                        // Zero load value completes immediately
                        if (load_val == {WIDTH{1'b0}}) begin
                            running    <= 1'b0;
                            timer_done <= 1'b1;
                        end
                        else begin
                            running <= 1'b1;
                        end

                    end

                    // STOP: preserve remaining count
                    else begin
                        running <= 1'b0;
                    end

                end

                default: begin
                    // No writable action
                end

            endcase
        end

        // Timer countdown logic
        else if (running) begin

            if (count > {{(WIDTH-1){1'b0}}, 1'b1}) begin
                count <= count - 1'b1;
            end

            // Final count: complete on this clock edge
            else if (count == {{(WIDTH-1){1'b0}}, 1'b1}) begin
                count      <= {WIDTH{1'b0}};
                running    <= 1'b0;
                timer_done <= 1'b1;
            end

            // Defensive handling if count is already zero
            else begin
                count      <= {WIDTH{1'b0}};
                running    <= 1'b0;
                timer_done <= 1'b1;
            end

        end

    end

endmodule

