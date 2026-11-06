
`timescale 1ns/1ps

module tb_apb_timer;

    parameter WIDTH = 8;

    // -----------------------------------------
    // APB signals
    // -----------------------------------------
    reg         PCLK;
    reg         PRESETn;
    reg         PSEL;
    reg         PENABLE;
    reg         PWRITE;
    reg  [7:0]  PADDR;
    reg  [31:0] PWDATA;

    wire [31:0] PRDATA;
    wire        PREADY;
    wire        PSLVERR;
    wire        timer_done;

    // -----------------------------------------
    // Testbench variables
    // -----------------------------------------
    reg [31:0] read_data;
    integer read_error;

    integer pass_count = 0;
    integer fail_count = 0;

    integer i;
    integer random_load;
    integer random_cycles;
    integer expected_count;
    integer done_seen;

    // -----------------------------------------
    // DUT instantiation
    // -----------------------------------------
    apb_timer #(
        .WIDTH(WIDTH)
    ) uut (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .timer_done(timer_done)
    );

    // -----------------------------------------
    // Clock generation: 10 ns period
    // -----------------------------------------
    initial PCLK = 0;
    always #5 PCLK = ~PCLK;

    // -----------------------------------------
    // VCD waveform
    // -----------------------------------------
    initial begin
        $dumpfile("apb_timer.vcd");
        $dumpvars(0, tb_apb_timer);
    end

    // -----------------------------------------
    // Monitor timer completion
    // -----------------------------------------
    always @(posedge timer_done) begin
        $display("[%0t ns] TIMER DONE", $time);
    end

    // =========================================
    // APB WRITE TASK
    // =========================================
    task apb_write;
        input [7:0]  addr;
        input [31:0] data;
        input        expect_error;

        begin
            // SETUP phase
            @(negedge PCLK);

            PSEL    = 1'b1;
            PENABLE = 1'b0;
            PWRITE  = 1'b1;
            PADDR   = addr;
            PWDATA  = data;

            // ACCESS phase
            @(negedge PCLK);
            PENABLE = 1'b1;

            // Wait for APB completion
            @(posedge PCLK);

            if (!PREADY)
                $display("[%0t ns] Waiting for PREADY", $time);

            if (PSLVERR !== expect_error) begin
                $display(
                    "[%0t ns] WRITE ERROR MISMATCH: ADDR=%h PSLVERR=%b EXPECTED=%b",
                    $time, addr, PSLVERR, expect_error
                );
                fail_count = fail_count + 1;
            end
            else begin
                $display(
                    "[%0t ns] APB WRITE: ADDR=%h DATA=%h PSLVERR=%b",
                    $time, addr, data, PSLVERR
                );
                pass_count = pass_count + 1;
            end

            // IDLE phase
            @(negedge PCLK);

            PSEL    = 1'b0;
            PENABLE = 1'b0;
            PWRITE  = 1'b0;
            PADDR   = 0;
            PWDATA  = 0;
        end
    endtask

    // =========================================
    // APB READ TASK
    // =========================================
    task apb_read;
        input [7:0] addr;

        begin
            // SETUP phase
            @(negedge PCLK);

            PSEL    = 1'b1;
            PENABLE = 1'b0;
            PWRITE  = 1'b0;
            PADDR   = addr;

            // ACCESS phase
            @(negedge PCLK);
            PENABLE = 1'b1;

            // Capture read result
            @(posedge PCLK);

            read_data  = PRDATA;
            read_error = PSLVERR;

            $display(
                "[%0t ns] APB READ: ADDR=%h DATA=%h PSLVERR=%b",
                $time, addr, read_data, read_error
            );

            // IDLE phase
            @(negedge PCLK);

            PSEL    = 1'b0;
            PENABLE = 1'b0;
            PADDR   = 0;
        end
    endtask

    // =========================================
    // READ AND COMPARE TASK
    // =========================================
    task check_read;
        input [7:0]  addr;
        input [31:0] expected;

        begin
            apb_read(addr);

            if (read_data === expected && read_error == 0) begin
                $display(
                    "[PASS] ADDR=%h EXPECTED=%h ACTUAL=%h",
                    addr, expected, read_data
                );
                pass_count = pass_count + 1;
            end
            else begin
                $display(
                    "[FAIL] ADDR=%h EXPECTED=%h ACTUAL=%h ERROR=%0d",
                    addr, expected, read_data, read_error
                );
                fail_count = fail_count + 1;
            end
        end
    endtask

    // =========================================
    // RESET TASK
    // =========================================
    task apply_reset;
        begin
            @(negedge PCLK);
            PRESETn = 0;

            repeat (2) @(posedge PCLK);

            @(negedge PCLK);
            PRESETn = 1;

            $display("[%0t ns] RESET RELEASED", $time);

            repeat (1) @(posedge PCLK);
        end
    endtask

    // =========================================
    // WAIT FOR TIMER COMPLETION
    // =========================================
    task wait_for_done;
        input integer max_cycles;

        begin
            done_seen = 0;

            for (i = 0; i < max_cycles; i = i + 1) begin
                @(posedge PCLK);
                #1;

                if (timer_done === 1'b1) begin
                    done_seen = 1;
                    i = max_cycles;
                end
            end

            if (done_seen) begin
                $display(
                    "[PASS] TIMER completed within %0d cycles",
                    max_cycles
                );
                pass_count = pass_count + 1;
            end
            else begin
                $display(
                    "[FAIL] TIMER did not complete within %0d cycles",
                    max_cycles
                );
                fail_count = fail_count + 1;
            end
        end
    endtask

    // =========================================
    // MAIN TEST SEQUENCE
    // =========================================
    initial begin

        $display("\n====================================");
        $display("       APB TIMER VERIFICATION");
        $display("====================================\n");

        // Initialize signals
        PRESETn = 0;
        PSEL    = 0;
        PENABLE = 0;
        PWRITE  = 0;
        PADDR   = 0;
        PWDATA  = 0;

        // -------------------------------------
        // TEST 1: RESET
        // -------------------------------------
        $display("\n--- TEST 1: RESET ---");

        apply_reset();

        check_read(8'h00, 32'd0);
        check_read(8'h04, 32'd0);
        check_read(8'h08, 32'd0);
        check_read(8'h0C, 32'd0);

        // -------------------------------------
        // TEST 2: NORMAL COUNTDOWN
        // -------------------------------------
        $display("\n--- TEST 2: NORMAL COUNTDOWN ---");

        apb_write(8'h00, 32'd10, 0);
        check_read(8'h00, 32'd10);

        apb_write(8'h04, 32'd1, 0);

        // Start edge loads COUNT=10.
        // Three clocks decrement it to 7.
        repeat (3) @(posedge PCLK);
        #1;

        // STOP transaction has one timer clock
        // during its SETUP phase.
        apb_write(8'h04, 32'd0, 0);

        // Expected: 10 - 3 - 1 = 6
        check_read(8'h08, 32'd6);
        check_read(8'h04, 32'd0);

        // Restart should reload COUNT from LOAD.
        apb_write(8'h04, 32'd1, 0);
        check_read(8'h04, 32'd1);

        wait_for_done(12);

        check_read(8'h08, 32'd0);
        check_read(8'h0C, 32'd1);

        // -------------------------------------
        // TEST 3: BOUNDARY VALUE = 1
        // -------------------------------------
        $display("\n--- TEST 3: BOUNDARY LOAD=1 ---");

        apb_write(8'h00, 32'd1, 0);
        apb_write(8'h04, 32'd1, 0);

        // Done should not assert on START edge.
        if (timer_done === 1'b0) begin
            $display("[PASS] DONE is LOW immediately after START");
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] DONE asserted too early");
            fail_count = fail_count + 1;
        end

        // Next clock should complete the timer.
        @(posedge PCLK);
        #1;

        if (timer_done === 1'b1) begin
            $display("[PASS] LOAD=1 completes after one countdown clock");
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] LOAD=1 did not complete on time");
            fail_count = fail_count + 1;
        end

        check_read(8'h08, 32'd0);
        check_read(8'h0C, 32'd1);

        // -------------------------------------
        // TEST 4: ZERO LOAD
        // -------------------------------------
        $display("\n--- TEST 4: ZERO LOAD ---");

        apb_write(8'h00, 32'd0, 0);
        apb_write(8'h04, 32'd1, 0);

        if (timer_done === 1'b1) begin
            $display("[PASS] ZERO LOAD completes immediately");
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] ZERO LOAD did not complete");
            fail_count = fail_count + 1;
        end

        check_read(8'h08, 32'd0);
        check_read(8'h0C, 32'd1);

        // -------------------------------------
        // TEST 5: MAXIMUM 8-BIT LOAD
        // -------------------------------------
        $display("\n--- TEST 5: MAXIMUM LOAD=255 ---");

        apb_write(8'h00, 32'd255, 0);
        check_read(8'h00, 32'd255);

        apb_write(8'h04, 32'd1, 0);

        wait_for_done(260);

        check_read(8'h08, 32'd0);
        check_read(8'h0C, 32'd1);

        // -------------------------------------
        // TEST 6: RANDOMIZED TESTS
        // -------------------------------------
        $display("\n--- TEST 6: RANDOMIZED TESTS ---");

        for (i = 0; i < 20; i = i + 1) begin

            // Keep loads sufficiently large so
            // random stop occurs before completion.
            random_load   = $urandom_range(20, 255);
            random_cycles = $urandom_range(1, 5);

            $display(
                "\n[RANDOM %0d] LOAD=%0d RUN_CYCLES=%0d",
                i + 1, random_load, random_cycles
            );

            apb_write(8'h00, random_load, 0);
            apb_write(8'h04, 32'd1, 0);

            // Allow the selected number of
            // countdown clocks.
            repeat (random_cycles) @(posedge PCLK);
            #1;

            // Stop transaction adds one countdown
            // clock during its SETUP phase.
            apb_write(8'h04, 32'd0, 0);

            expected_count =
                random_load - random_cycles - 1;

            check_read(8'h08, expected_count);
        end

        // -------------------------------------
        // TEST 7: INVALID WRITE TESTS
        // -------------------------------------
        $display("\n--- TEST 7: INVALID WRITE TESTS ---");

        // COUNT is read-only
        apb_write(8'h08, 32'd55, 1);

        // STATUS is read-only
        apb_write(8'h0C, 32'd1, 1);

        // Invalid address
        apb_write(8'h10, 32'd100, 1);

        // -------------------------------------
        // TEST 8: INVALID READ TEST
        // -------------------------------------
        $display("\n--- TEST 8: INVALID READ TEST ---");

        apb_read(8'h10);

        if (read_error == 1) begin
            $display("[PASS] Invalid read correctly raised PSLVERR");
            pass_count = pass_count + 1;
        end
        else begin
            $display("[FAIL] Invalid read did not raise PSLVERR");
            fail_count = fail_count + 1;
        end

        // -------------------------------------
        // FINAL REPORT
        // -------------------------------------
        $display("\n====================================");
        $display("        VERIFICATION SUMMARY");
        $display("====================================");

        $display("PASSED TESTS : %0d", pass_count);
        $display("FAILED TESTS : %0d", fail_count);

        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***");
        else
            $display("\n*** VERIFICATION FAILED ***");

        $display("====================================\n");

        $finish;
    end

    // -----------------------------------------
    // Simulation timeout protection
    // -----------------------------------------
    initial begin
        #100000;
        $display("[FATAL] Simulation timeout");
        $finish;
    end

endmodule

