
`timescale 1ns/1ps

module tb_uart_transmitter;

    // -----------------------------------------
    // Parameters
    // -----------------------------------------
    parameter integer CLKS_PER_BIT = 217;
    parameter integer CLK_PERIOD   = 40;

    localparam integer HALF_BIT = CLKS_PER_BIT / 2;

    // -----------------------------------------
    // DUT Signals
    // -----------------------------------------
    reg clk;
    reg rst_n;

    reg [7:0] data_in;
    reg send;

    wire serial_out;
    wire busy;

    // -----------------------------------------
    // Scoreboard
    // -----------------------------------------
    integer pass_count = 0;
    integer fail_count = 0;

    reg [7:0] expected_data;
    integer bit_number;

    // -----------------------------------------
    // DUT Instantiation
    // -----------------------------------------
    uart_transmitter #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(data_in),
        .send(send),
        .serial_out(serial_out),
        .busy(busy)
    );

    // -----------------------------------------
    // Clock Generation
    // 25 MHz = 40 ns period
    // -----------------------------------------
    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // -----------------------------------------
    // VCD Dump
    // -----------------------------------------
    initial begin
        $dumpfile("uart_transmitter.vcd");
        $dumpvars(0, tb_uart_transmitter);
    end

    // -----------------------------------------
    // Reset Task
    // -----------------------------------------
    task reset_dut;
        begin
            rst_n = 1'b0;
            send  = 1'b0;
            data_in = 8'h00;

            repeat(5) @(negedge clk);

            rst_n = 1'b1;

            repeat(2) @(negedge clk);

            if (serial_out !== 1'b1) begin
                $display("[FAIL] TX is not HIGH after reset");
                fail_count = fail_count + 1;
            end
            else begin
                $display("[PASS] Reset and IDLE output");
                pass_count = pass_count + 1;
            end
        end
    endtask

    // -----------------------------------------
    // Scoreboard Checker
    // -----------------------------------------
    task check_bit;
        input expected_bit;
        input [8*20-1:0] description;

        begin
            if (serial_out !== expected_bit) begin
                $display(
                    "[FAIL] %0s | Expected=%b Actual=%b Time=%0t",
                    description,
                    expected_bit,
                    serial_out,
                    $time
                );

                fail_count = fail_count + 1;
            end
            else begin
                $display(
                    "[PASS] %0s | TX=%b Time=%0t",
                    description,
                    serial_out,
                    $time
                );

                pass_count = pass_count + 1;
            end
        end
    endtask

    // -----------------------------------------
    // UART Transaction Task
    // -----------------------------------------
    task send_and_check;
        input [7:0] test_data;

        begin
            expected_data = test_data;

            // Wait until transmitter is idle
            wait(busy == 1'b0);

            // Drive input on falling edge
            @(negedge clk);

            data_in = test_data;
            send    = 1'b1;

            // DUT accepts request on next rising edge
            @(posedge clk);
            #1;

            check_bit(1'b0, "START bit");

            if (busy !== 1'b1) begin
                $display("[FAIL] BUSY not asserted");
                fail_count = fail_count + 1;
            end
            else begin
                $display("[PASS] BUSY asserted");
                pass_count = pass_count + 1;
            end

            // Deassert send
            @(negedge clk);
            send = 1'b0;

            // Sample START bit near its midpoint
            repeat(HALF_BIT) @(posedge clk);
            #1;

            check_bit(1'b0, "START midpoint");

            // ---------------------------------
            // DATA BITS - LSB FIRST
            // ---------------------------------
            for (bit_number = 0;
                 bit_number < 8;
                 bit_number = bit_number + 1) begin

                repeat(CLKS_PER_BIT) @(posedge clk);
                #1;

                check_bit(
                    expected_data[bit_number],
                    bit_number == 0 ? "DATA bit 0" :
                    bit_number == 1 ? "DATA bit 1" :
                    bit_number == 2 ? "DATA bit 2" :
                    bit_number == 3 ? "DATA bit 3" :
                    bit_number == 4 ? "DATA bit 4" :
                    bit_number == 5 ? "DATA bit 5" :
                    bit_number == 6 ? "DATA bit 6" :
                                      "DATA bit 7"
                );

            end

            // ---------------------------------
            // STOP BIT
            // ---------------------------------
            repeat(CLKS_PER_BIT) @(posedge clk);
            #1;

            check_bit(1'b1, "STOP bit");

            // Wait for complete STOP duration
            wait(busy == 1'b0);
            #1;

            if (serial_out !== 1'b1) begin
                $display("[FAIL] TX not HIGH after frame");
                fail_count = fail_count + 1;
            end
            else begin
                $display("[PASS] Frame completed successfully");
                pass_count = pass_count + 1;
            end

            $display("------------------------------------");
        end
    endtask

    // -----------------------------------------
    // Main Test Sequence
    // -----------------------------------------
    initial begin

        $display("");
        $display("====================================");
        $display(" UART TRANSMITTER VERIFICATION");
        $display("====================================");
        $display("CLKS_PER_BIT = %0d", CLKS_PER_BIT);
        $display("Clock period = %0d ns", CLK_PERIOD);
        $display("");

        // Initialize
        clk = 1'b0;
        rst_n = 1'b0;
        data_in = 8'h00;
        send = 1'b0;

        // Reset
        reset_dut();

        // Test 1: Alternating pattern
        $display("[TEST 1] Transmitting 0xA5");
        send_and_check(8'hA5);

        // Test 2: All zeros
        $display("[TEST 2] Transmitting 0x00");
        send_and_check(8'h00);

        // Test 3: All ones
        $display("[TEST 3] Transmitting 0xFF");
        send_and_check(8'hFF);

        // Test 4: Alternating pattern
        $display("[TEST 4] Transmitting 0x55");
        send_and_check(8'h55);

        // Test 5: Mixed pattern
        $display("[TEST 5] Transmitting 0xB2");
        send_and_check(8'hB2);

        // ---------------------------------
        // Final Report
        // ---------------------------------
        $display("");
        $display("====================================");
        $display("       VERIFICATION SUMMARY");
        $display("====================================");

        $display("Passed checks : %0d", pass_count);
        $display("Failed checks : %0d", fail_count);

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: VERIFICATION FAILED");

        $display("====================================");

        $finish;
    end

endmodule
