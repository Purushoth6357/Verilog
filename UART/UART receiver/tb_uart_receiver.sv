
module tb_uart_receiver;

    localparam CLK_PERIOD = 40;
    localparam CLKS_PER_BIT = 217;

    reg clk;
    reg rst_n;
    reg serial_in;

    wire [7:0] data_out;
    wire data_ready;

    integer rx_count;
    integer i;

    uart_receiver #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .serial_in(serial_in),
        .data_out(data_out),
        .data_ready(data_ready)
    );

    // Clock generation
    always #(CLK_PERIOD/2) clk <= ~clk;

    // UART frame transmitter
    task send_uart_frame(input [7:0] payload);
        integer j;
        begin
            // Start bit
            @(negedge clk);
            serial_in = 1'b0;
            repeat(CLKS_PER_BIT) @(negedge clk);

            // 8 data bits, LSB first
            for(j = 0; j < 8; j = j + 1) begin
                serial_in = payload[j];
                repeat(CLKS_PER_BIT) @(negedge clk);
            end

            // Stop bit
            serial_in = 1'b1;
            repeat(CLKS_PER_BIT) @(negedge clk);
        end
    endtask

    // Result checker
    task check(
        input [7:0] expected,
        input string testname
    );
        begin
            @(negedge clk);

            if(data_out !== expected) begin
                $error(
                    "%s FAILED: Expected=%02h Actual=%02h",
                    testname, expected, data_out
                );
            end
            else begin
                $display(
                    "%s PASSED: Data=%02h",
                    testname, data_out
                );
            end
        end
    endtask

    // Receive monitor
    always @(posedge clk) begin
        if(data_ready) begin
            rx_count <= rx_count + 1;

            $display(
                "RX[%0d] @ %0t ns = %02h",
                rx_count, $time, data_out
            );
        end
    end

    // Main test sequence
    initial begin

        clk = 1'b0;
        rst_n = 1'b0;
        serial_in = 1'b1;
        rx_count = 0;

        // Reset
        repeat(10) @(negedge clk);
        rst_n = 1'b1;

        repeat(5) @(negedge clk);

        // Boundary tests
        send_uart_frame(8'hFF);
        check(8'hFF, "HIGH EXTREMA");

        send_uart_frame(8'h00);
        check(8'h00, "LOW EXTREMA");

        // Exhaustive testing: 0x00 to 0xFF
        for(i = 0; i < 256; i = i + 1) begin

            send_uart_frame(i[7:0]);

            check(i[7:0], "EXHAUSTIVE BYTE TEST");

        end

        // Final report
        $display("--------------------------------");
        $display("TOTAL RECEIVED FRAMES = %0d", rx_count);
        $display("UART TESTBENCH COMPLETED");
        $display("--------------------------------");

        $finish;
    end

    // Waveform generation
    initial begin
        $dumpfile("tb_uart_receiver.vcd");
        $dumpvars(0, tb_uart_receiver);
    end


endmodule

