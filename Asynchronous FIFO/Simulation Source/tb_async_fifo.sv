`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2026 10:07:29 PM
// Design Name: 
// Module Name: tb_async_fifo
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

module tb_async_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;
    parameter ADDR_WIDTH = 4;

    // ------------------------------------------------
    // DUT interface
    // ------------------------------------------------

    reg wclk;
    reg rclk;

    reg wrst_n;
    reg rrst_n;

    reg w_en;
    reg r_en;

    reg [DATA_WIDTH-1:0] wdata;

    wire [DATA_WIDTH-1:0] rdata;
    wire full;
    wire empty;

    // ------------------------------------------------
    // DUT instantiation
    // ------------------------------------------------

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) DUT (
        .wclk(wclk),
        .rclk(rclk),
        .wrst_n(wrst_n),
        .rrst_n(rrst_n),
        .w_en(w_en),
        .wdata(wdata),
        .full(full),
        .r_en(r_en),
        .rdata(rdata),
        .empty(empty)
    );

    // ------------------------------------------------
    // Independent clock generation
    // ------------------------------------------------

    initial wclk = 0;
    initial rclk = 0;

    always #5 wclk = ~wclk;   // 100 MHz
    always #7 rclk = ~rclk;   // ~71.43 MHz

    // ------------------------------------------------
    // Reference model
    // ------------------------------------------------

    // Abstract FIFO queue.
    // This does NOT reproduce the DUT architecture.

    reg [DATA_WIDTH-1:0] model_q[$];

    reg [DATA_WIDTH-1:0] expected_data;

    integer errors;
    integer accepted_writes;
    integer accepted_reads;
    integer rejected_writes;
    integer rejected_reads;

    integer log_fd;
    integer i;

    // ------------------------------------------------
    // Scoreboard: WRITE monitor
    // ------------------------------------------------

    always @(posedge wclk) begin

        if (wrst_n) begin

            if (w_en && !full) begin

                if (model_q.size() >= DEPTH) begin

                    errors = errors + 1;

                    $display(
                        "ERROR: Write accepted while model FIFO full at %0t",
                        $time
                    );

                    $fdisplay(
                        log_fd,
                        "ERROR: Write accepted while model FIFO full at %0t",
                        $time
                    );

                end
                else begin

                    model_q.push_back(wdata);

                    accepted_writes = accepted_writes + 1;

                    $display(
                        "WRITE ACCEPTED: data=%h queue_size=%0d time=%0t",
                        wdata, model_q.size(), $time
                    );

                    $fdisplay(
                        log_fd,
                        "WRITE ACCEPTED: data=%h queue_size=%0d time=%0t",
                        wdata, model_q.size(), $time
                    );

                end

            end

            if (w_en && full) begin

                rejected_writes = rejected_writes + 1;

                $display(
                    "INFO: Write rejected because FIFO is FULL at %0t",
                    $time
                );

                $fdisplay(
                    log_fd,
                    "INFO: Write rejected because FIFO is FULL at %0t",
                    $time
                );

            end

        end

    end

    // ------------------------------------------------
    // Scoreboard: READ monitor
    // ------------------------------------------------

    always @(posedge rclk) begin

        if (rrst_n) begin

            if (r_en && !empty) begin

                if (model_q.size() == 0) begin

                    errors = errors + 1;

                    $display(
                        "ERROR: Read accepted while model FIFO empty at %0t",
                        $time
                    );

                    $fdisplay(
                        log_fd,
                        "ERROR: Read accepted while model FIFO empty at %0t",
                        $time
                    );

                end
                else begin

                    // Capture expected FIFO head.
                    expected_data = model_q.pop_front();

                    accepted_reads = accepted_reads + 1;

                    // Wait for DUT registered output to update.
                    #1;

                    if (rdata !== expected_data) begin

                        errors = errors + 1;

                        $display(
                            "ERROR: DATA MISMATCH | Expected=%h Actual=%h Time=%0t",
                            expected_data, rdata, $time
                        );

                        $fdisplay(
                            log_fd,
                            "ERROR: DATA MISMATCH | Expected=%h Actual=%h Time=%0t",
                            expected_data, rdata, $time
                        );

                    end
                    else begin

                        $display(
                            "READ PASS: Expected=%h Actual=%h Remaining=%0d",
                            expected_data, rdata, model_q.size()
                        );

                        $fdisplay(
                            log_fd,
                            "READ PASS: Expected=%h Actual=%h Remaining=%0d",
                            expected_data, rdata, model_q.size()
                        );

                    end

                end

            end

            if (r_en && empty) begin

                rejected_reads = rejected_reads + 1;

                $display(
                    "INFO: Read rejected because FIFO is EMPTY at %0t",
                    $time
                );

                $fdisplay(
                    log_fd,
                    "INFO: Read rejected because FIFO is EMPTY at %0t",
                    $time
                );

            end

        end

    end

    // ------------------------------------------------
    // WRITE TASK
    // ------------------------------------------------

    task write_word;

        input [DATA_WIDTH-1:0] data;

        begin

            @(negedge wclk);

            w_en = 1;
            wdata = data;

            @(negedge wclk);

            w_en = 0;

        end

    endtask

    // ------------------------------------------------
    // READ TASK
    // ------------------------------------------------

    task read_word;

        begin

            @(negedge rclk);

            r_en = 1;

            @(negedge rclk);

            r_en = 0;

        end

    endtask

    // ------------------------------------------------
    // RESET TASK
    // ------------------------------------------------

    task reset_fifo;

        begin

            wrst_n = 0;
            rrst_n = 0;

            w_en = 0;
            r_en = 0;
            wdata = 0;

            repeat(5) @(posedge wclk);

            @(negedge wclk);
            wrst_n = 1;

            @(negedge rclk);
            rrst_n = 1;

            repeat(5) @(posedge rclk);

            $display("RESET COMPLETE");

            $fdisplay(log_fd, "RESET COMPLETE");

        end

    endtask

    // ------------------------------------------------
    // MAIN TEST SEQUENCE
    // ------------------------------------------------

    initial begin

        log_fd = $fopen("async_fifo_test.log", "w");

        if (log_fd == 0) begin
            $display("ERROR: Could not create log file");
            $finish;
        end

        errors = 0;
        accepted_writes = 0;
        accepted_reads = 0;
        rejected_writes = 0;
        rejected_reads = 0;

        wrst_n = 0;
        rrst_n = 0;

        w_en = 0;
        r_en = 0;
        wdata = 0;

        model_q.delete();

        $display("\n====================================");
        $display("       ASYNCHRONOUS FIFO TEST       ");
        $display("====================================\n");

        $fdisplay(log_fd, "ASYNCHRONOUS FIFO TEST LOG");
        $fdisplay(log_fd, "DATA_WIDTH=%0d DEPTH=%0d",
                  DATA_WIDTH, DEPTH);

        // ============================================
        // TEST 1: RESET
        // ============================================

        $display("\nTEST 1: RESET");

        reset_fifo();

        if (empty !== 1'b1 || full !== 1'b0) begin

            errors = errors + 1;

            $display("ERROR: Initial status flags incorrect");

        end
        else begin

            $display("PASS: Initial status flags correct");

        end

        // ============================================
        // TEST 2: SINGLE WRITE AND READ
        // ============================================

        $display("\nTEST 2: SINGLE WRITE AND READ");

        write_word(8'hA5);

        // Wait for write pointer synchronization.
        wait(empty == 0);

        read_word();

        wait(empty == 1);

        // ============================================
        // TEST 3: MULTIPLE WRITES
        // ============================================

        $display("\nTEST 3: MULTIPLE WRITES");

        write_word(8'h11);
        write_word(8'h22);
        write_word(8'h33);
        write_word(8'h44);

        repeat(5) @(posedge rclk);

        read_word();
        read_word();
        read_word();
        read_word();

        // ============================================
        // TEST 4: FILL FIFO
        // ============================================

        $display("\nTEST 4: FILL FIFO");

        for (i = 0; i < DEPTH; i = i + 1)
            write_word(i);

        repeat(3) @(posedge wclk);

        if (full !== 1'b1) begin

            errors = errors + 1;

            $display("ERROR: FIFO did not become FULL");

        end
        else begin

            $display("PASS: FIFO FULL condition detected");

        end

        // ============================================
        // TEST 5: WRITE WHILE FULL
        // ============================================

        $display("\nTEST 5: OVERFLOW ATTEMPT");

        write_word(8'hDE);
        write_word(8'hAD);

        // ============================================
        // TEST 6: DRAIN FIFO
        // ============================================

        $display("\nTEST 6: DRAIN FIFO");

        repeat(4) @(posedge rclk);

        for (i = 0; i < DEPTH; i = i + 1)
            read_word();

        wait(empty == 1);

        $display("PASS: FIFO drained");

        // ============================================
        // TEST 7: READ WHILE EMPTY
        // ============================================

        $display("\nTEST 7: UNDERFLOW ATTEMPT");

        read_word();
        read_word();

        // ============================================
        // TEST 8: POINTER WRAP-AROUND
        // ============================================

        $display("\nTEST 8: POINTER WRAP-AROUND");

        for (i = 0; i < 40; i = i + 1) begin

            write_word(i);

            wait(empty == 0);

            read_word();

            wait(empty == 1);

        end

        $display("PASS: Repeated pointer wrap-around traffic");

        // ============================================
        // TEST 9: CONCURRENT READ AND WRITE
        // ============================================

        $display("\nTEST 9: CONCURRENT READ AND WRITE");

        fork

            begin
                for (i = 0; i < 100; i = i + 1) begin
                    @(negedge wclk);

                    w_en = ($urandom_range(0,3) != 0);
                    wdata = $urandom;
                end

                @(negedge wclk);
                w_en = 0;
            end

            begin
                for (i = 0; i < 100; i = i + 1) begin
                    @(negedge rclk);

                    r_en = ($urandom_range(0,3) != 0);
                end

                @(negedge rclk);
                r_en = 0;
            end

        join

        // ============================================
        // TEST 10: FINAL DRAIN
        // ============================================

        $display("\nTEST 10: FINAL DRAIN");

        // Allow any pending write pointer updates
        // to cross into the read clock domain.
        repeat(5) @(posedge rclk);

        while (empty !== 1'b1)
            read_word();

        repeat(3) @(posedge rclk);

        // ============================================
        // FINAL SUMMARY
        // ============================================

        $display("\n====================================");
        $display("          TEST SUMMARY              ");
        $display("====================================");

        $display("Accepted writes : %0d", accepted_writes);
        $display("Accepted reads  : %0d", accepted_reads);
        $display("Rejected writes: %0d", rejected_writes);
        $display("Rejected reads : %0d", rejected_reads);
        $display("Remaining model entries: %0d", model_q.size());
        $display("Total errors    : %0d", errors);

        $fdisplay(log_fd, "\n========== TEST SUMMARY ==========");

        $fdisplay(log_fd, "Accepted writes : %0d", accepted_writes);
        $fdisplay(log_fd, "Accepted reads  : %0d", accepted_reads);
        $fdisplay(log_fd, "Rejected writes: %0d", rejected_writes);
        $fdisplay(log_fd, "Rejected reads : %0d", rejected_reads);
        $fdisplay(log_fd, "Remaining model entries: %0d", model_q.size());
        $fdisplay(log_fd, "Total errors    : %0d", errors);

        if (errors == 0 && model_q.size() == 0) begin

            $display("\nRESULT: ALL TESTS PASSED");

            $fdisplay(log_fd, "RESULT: ALL TESTS PASSED");

        end
        else begin

            $display("\nRESULT: TEST FAILED");

            $fdisplay(log_fd, "RESULT: TEST FAILED");

        end

        $fclose(log_fd);

        #20;
        $finish;

    end

    // Simulation timeout
    initial begin
        #1000000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule

