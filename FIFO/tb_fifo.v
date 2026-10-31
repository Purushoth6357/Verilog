`timescale 1ns / 1ps

module tb_fifo;

    // Test configuration
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 5;

    reg clk;
    reg rst;
    reg wr_en;
    reg rd_en;
    reg [DATA_WIDTH-1:0] din;

    wire [DATA_WIDTH-1:0] dout;
    wire full;
    wire empty;

    integer log_fd;
    integer errors;
    integer total_tests;
    integer i;
    integer seed;

    // DUT
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Reference FIFO / scoreboard
    reg [DATA_WIDTH-1:0] reference_mem [0:DEPTH-1];

    integer ref_wr_ptr;
    integer ref_rd_ptr;
    integer ref_count;

    reg [DATA_WIDTH-1:0] expected_dout;

    reg write_accept;
    reg read_accept;

    reg [DATA_WIDTH-1:0] expected_read;

    reg [31:0] random_value;

    // Clock generation: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;


    // ------------------------------------------------
    // Reset task
    // ------------------------------------------------

    task reset_fifo;
    begin
        @(negedge clk);
        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        ref_wr_ptr = 0;
        ref_rd_ptr = 0;
        ref_count = 0;
        expected_dout = 0;

        @(posedge clk);
        #1;

        if (empty !== 1'b1 || full !== 1'b0 ||
            dout !== 0) begin

            errors = errors + 1;
            $display("ERROR: Reset failed");

            $fdisplay(log_fd, "ERROR: Reset failed");
        end
        else begin
            $display("PASS: Reset successful");

            $fdisplay(log_fd, "PASS: Reset successful");
        end

        total_tests = total_tests + 1;

        @(negedge clk);
        rst = 0;
    end
    endtask


    // ------------------------------------------------
    // Main transaction task
    // ------------------------------------------------

    task fifo_transaction;

        input wr;
        input rd;
        input [DATA_WIDTH-1:0] data;

    begin

        @(negedge clk);

        wr_en = wr;
        rd_en = rd;
        din = data;

        // Determine accepted operations using
        // FIFO status BEFORE the active clock edge.

        write_accept = wr && !full;
        read_accept  = rd && !empty;

        // Save expected read data before updating model.
        if (read_accept)
            expected_read = reference_mem[ref_rd_ptr];

        // Update reference read pointer and count.
        if (read_accept) begin

            ref_rd_ptr = (ref_rd_ptr == DEPTH-1)
                       ? 0 : ref_rd_ptr + 1;

            ref_count = ref_count - 1;
        end

        // Update reference write pointer and count.
        if (write_accept) begin

            reference_mem[ref_wr_ptr] = data;

            ref_wr_ptr = (ref_wr_ptr == DEPTH-1)
                       ? 0 : ref_wr_ptr + 1;

            ref_count = ref_count + 1;
        end

        // Expected output changes only on accepted read.
        if (read_accept)
            expected_dout = expected_read;

        @(posedge clk);
        #1;

        total_tests = total_tests + 1;

        // Check read data and output hold behavior.
        if (dout !== expected_dout) begin

            errors = errors + 1;

            $display(
                "ERROR: Data mismatch | Expected=%h Actual=%h",
                expected_dout, dout
            );

            $fdisplay(
                log_fd,
                "ERROR: Data mismatch | Expected=%h Actual=%h",
                expected_dout, dout
            );
        end
        else begin

            $display(
                "PASS: Data check | dout=%h",
                dout
            );

            $fdisplay(
                log_fd,
                "PASS: Data check | dout=%h",
                dout
            );
        end

        // Check status flags.
        if (full !== (ref_count == DEPTH)) begin

            errors = errors + 1;

            $display(
                "ERROR: FULL mismatch | Expected=%b Actual=%b",
                (ref_count == DEPTH), full
            );

            $fdisplay(
                log_fd,
                "ERROR: FULL mismatch | Expected=%b Actual=%b",
                (ref_count == DEPTH), full
            );
        end

        if (empty !== (ref_count == 0)) begin

            errors = errors + 1;

            $display(
                "ERROR: EMPTY mismatch | Expected=%b Actual=%b",
                (ref_count == 0), empty
            );

            $fdisplay(
                log_fd,
                "ERROR: EMPTY mismatch | Expected=%b Actual=%b",
                (ref_count == 0), empty
            );
        end

        // Log transaction details.
        $display(
            "TXN: WR=%b RD=%b DIN=%h | Accepted: W=%b R=%b | Count=%0d | FULL=%b EMPTY=%b",
            wr, rd, data,
            write_accept, read_accept,
            ref_count, full, empty
        );

        $fdisplay(
            log_fd,
            "TXN: WR=%b RD=%b DIN=%h | Accepted: W=%b R=%b | Count=%0d | FULL=%b EMPTY=%b",
            wr, rd, data,
            write_accept, read_accept,
            ref_count, full, empty
        );

        // Identify rejected operations.
        if (wr && !write_accept) begin
            $display("INFO: Illegal write attempted while FULL");
            $fdisplay(log_fd, "INFO: Illegal write attempted while FULL");
        end

        if (rd && !read_accept) begin
            $display("INFO: Illegal read attempted while EMPTY");
            $fdisplay(log_fd, "INFO: Illegal read attempted while EMPTY");
        end

    end
    endtask


    // ------------------------------------------------
    // Main test sequence
    // ------------------------------------------------

    initial begin

        log_fd = $fopen("fifo_test.log", "w");

        if (log_fd == 0) begin
            $display("ERROR: Could not open log file");
            $finish;
        end

        errors = 0;
        total_tests = 0;
        seed = 12345;

        rst = 0;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        ref_wr_ptr = 0;
        ref_rd_ptr = 0;
        ref_count = 0;
        expected_dout = 0;

        $display("\n====================================");
        $display("       SYNCHRONOUS FIFO TEST         ");
        $display("====================================\n");

        $fdisplay(log_fd, "SYNCHRONOUS FIFO TEST LOG");
        $fdisplay(log_fd, "DATA_WIDTH=%0d DEPTH=%0d",
                  DATA_WIDTH, DEPTH);

        // TEST 1: Reset
        $display("\nTEST 1: RESET");
        reset_fifo();


        // TEST 2: Single write and read
        $display("\nTEST 2: SINGLE WRITE AND READ");

        fifo_transaction(1, 0, 8'hA5);
        fifo_transaction(0, 1, 8'h00);


        // TEST 3: Multiple writes
        $display("\nTEST 3: MULTIPLE WRITES");

        fifo_transaction(1, 0, 8'h00);
        fifo_transaction(1, 0, 8'hFF);
        fifo_transaction(1, 0, 8'hAA);
        fifo_transaction(1, 0, 8'h55);


        // TEST 4: Fill FIFO completely
        $display("\nTEST 4: FIFO FULL CONDITION");

        fifo_transaction(1, 0, 8'h11);

        if (full !== 1'b1) begin
            errors = errors + 1;
            $display("ERROR: FIFO did not become FULL");
        end
        else
            $display("PASS: FIFO reached FULL");


        // TEST 5: Illegal write while FULL
        $display("\nTEST 5: WRITE WHILE FULL");

        fifo_transaction(1, 0, 8'hDE);
        fifo_transaction(1, 0, 8'hAD);


        // TEST 6: Read all entries
        $display("\nTEST 6: DRAIN FIFO");

        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);


        // TEST 7: Illegal read while EMPTY
        $display("\nTEST 7: READ WHILE EMPTY");

        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);


        // TEST 8: Simultaneous read and write
        $display("\nTEST 8: SIMULTANEOUS READ AND WRITE");

        fifo_transaction(1, 0, 8'h12);
        fifo_transaction(1, 0, 8'h34);

        fifo_transaction(1, 1, 8'h56);
        fifo_transaction(1, 1, 8'h78);

        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);


        // TEST 9: Pointer wrap-around
        $display("\nTEST 9: POINTER WRAP-AROUND");

        for (i = 0; i < 15; i = i + 1) begin
            fifo_transaction(1, 0, i);
            fifo_transaction(0, 1, 8'h00);
        end


        // TEST 10: Boundary data patterns
        $display("\nTEST 10: DATA PATTERNS");

        fifo_transaction(1, 0, 8'h00);
        fifo_transaction(1, 0, 8'hFF);
        fifo_transaction(1, 0, 8'hAA);
        fifo_transaction(1, 0, 8'h55);
        fifo_transaction(1, 0, 8'h01);

        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);


        // TEST 11: Simultaneous operations at EMPTY
        $display("\nTEST 11: SIMULTANEOUS OPERATION AT EMPTY");

        fifo_transaction(1, 1, 8'hB1);

        // At empty: write accepted, read rejected.
        fifo_transaction(0, 1, 8'h00);


        // TEST 12: Simultaneous operations at FULL
        $display("\nTEST 12: SIMULTANEOUS OPERATION AT FULL");

        fifo_transaction(1, 0, 8'h10);
        fifo_transaction(1, 0, 8'h20);
        fifo_transaction(1, 0, 8'h30);
        fifo_transaction(1, 0, 8'h40);
        fifo_transaction(1, 0, 8'h50);

        fifo_transaction(1, 1, 8'h60);

        // At full: read accepted, write rejected.
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);
        fifo_transaction(0, 1, 8'h00);


        // TEST 13: Randomized transactions
        $display("\nTEST 13: RANDOMIZED TESTING");

        for (i = 0; i < 100; i = i + 1) begin

            random_value = $random(seed);

            fifo_transaction(
                random_value[0],
                random_value[1],
                random_value[15:8]
            );

        end


        // Final summary
        @(negedge clk);

        wr_en = 0;
        rd_en = 0;

        $display("\n====================================");
        $display("           TEST SUMMARY              ");
        $display("====================================");

        $display("Total transactions/checks : %0d", total_tests);
        $display("Total errors               : %0d", errors);

        $fdisplay(log_fd, "\n========== TEST SUMMARY ==========");
        $fdisplay(log_fd, "Total transactions/checks : %0d",
                  total_tests);
        $fdisplay(log_fd, "Total errors               : %0d",
                  errors);

        if (errors == 0) begin
            $display("RESULT: ALL TESTS PASSED");
            $fdisplay(log_fd, "RESULT: ALL TESTS PASSED");
        end
        else begin
            $display("RESULT: TEST FAILED");
            $fdisplay(log_fd, "RESULT: TEST FAILED");
        end

        $display("Log saved to fifo_test.log");

        $fclose(log_fd);

        #10;
        $finish;

    end

endmodule
