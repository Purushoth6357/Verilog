
`timescale 1ns/1ps

module tb_uart_apb;

    //========================================================
    // PARAMETERS
    //========================================================

    parameter CLK_PERIOD = 20;  // 50 MHz

    //========================================================
    // TESTBENCH SIGNALS
    //========================================================

    reg CLK;
    reg RESETn;

    // APB interface
    reg  [31:0] PADDR;
    reg  [31:0] PWDATA;
    reg         PWRITE;
    reg         PSELx;
    reg         PENABLE;

    wire [31:0] PRDATA;
    wire        PREADY;

    // UART interface
    reg         rx_drv;
    reg         use_loopback;

    wire        tx;
    wire        rx;
    wire        rdy;
    wire        tx_busy;
    wire [7:0]  dout;
    wire        rdy_clr;

    // APB read result
    reg [31:0] read_result;

    // Timeout counter
    integer timeout_count;

    //========================================================
    // LOOPBACK CONNECTION
    //========================================================

    assign rx = use_loopback ? tx : rx_drv;

    //========================================================
    // CLOCK GENERATION
    //========================================================

    initial CLK = 0;

    always #(CLK_PERIOD/2) CLK = ~CLK;

    //========================================================
    // DUT INSTANTIATION
    //========================================================

    top_uart_apb dut (

        .CLK(CLK),
        .RESETn(RESETn),

        // APB
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PWRITE(PWRITE),
        .PSELx(PSELx),
        .PENABLE(PENABLE),
        .PRDATA(PRDATA),
        .PREADY(PREADY),

        // UART
        .rx(rx),
        .tx(tx),
        .rdy(rdy),
        .tx_busy(tx_busy),
        .dout(dout),
        .rdy_clr(rdy_clr)

    );

    //========================================================
    // APB WRITE TASK
    //========================================================

    task apb_write(
        input [31:0] addr,
        input [31:0] data
    );

        integer wait_count;

        begin

            // SETUP PHASE
            @(negedge CLK);

            PADDR   = addr;
            PWDATA  = data;
            PWRITE  = 1'b1;
            PSELx   = 1'b1;
            PENABLE = 1'b0;

            // ACCESS PHASE
            @(negedge CLK);

            PENABLE = 1'b1;

            wait_count = 0;

            @(posedge CLK);
            #1;

            while ((PREADY !== 1'b1) &&
                   (wait_count < 100000)) begin

                @(posedge CLK);
                #1;

                wait_count = wait_count + 1;

            end

            if (PREADY !== 1'b1) begin

                $display("[%0t] APB WRITE TIMEOUT: ADDR=%h",
                         $time, addr);

                $finish;

            end

            $display("[%0t] APB WRITE: ADDR=%h DATA=%h",
                     $time, addr, data);

            // END TRANSACTION
            @(negedge CLK);

            PSELx   = 1'b0;
            PENABLE = 1'b0;
            PWRITE  = 1'b0;

        end

    endtask

    //========================================================
    // APB READ TASK
    //========================================================

    task apb_read(
        input [31:0] addr
    );

        integer wait_count;

        begin

            // SETUP PHASE
            @(negedge CLK);

            PADDR   = addr;
            PWRITE  = 1'b0;
            PSELx   = 1'b1;
            PENABLE = 1'b0;

            // ACCESS PHASE
            @(negedge CLK);

            PENABLE = 1'b1;

            wait_count = 0;

            @(posedge CLK);
            #1;

            while ((PREADY !== 1'b1) &&
                   (wait_count < 100000)) begin

                @(posedge CLK);
                #1;

                wait_count = wait_count + 1;

            end

            if (PREADY !== 1'b1) begin

                $display("[%0t] APB READ TIMEOUT: ADDR=%h",
                         $time, addr);

                $finish;

            end

            read_result = PRDATA;

            $display("[%0t] APB READ : ADDR=%h DATA=%h",
                     $time, addr, read_result);

            // END TRANSACTION
            @(negedge CLK);

            PSELx   = 1'b0;
            PENABLE = 1'b0;

        end

    endtask

    //========================================================
    // WAIT FOR UART TRANSMISSION
    //========================================================

    task wait_tx_complete;

        integer count;

        begin

            count = 0;

            // First wait until transmission starts
            while ((tx_busy !== 1'b1) &&
                   (count < 100000)) begin

                @(posedge CLK);
                count = count + 1;

            end

            // Then wait until transmission finishes
            while ((tx_busy !== 1'b0) &&
                   (count < 100000)) begin

                @(posedge CLK);
                count = count + 1;

            end

            #1;

            if (tx_busy !== 1'b0)
                $display("ERROR: TX timeout");
            else
                $display("[%0t] TX COMPLETE", $time);

        end

    endtask

    //========================================================
    // WAIT FOR RECEIVED DATA
    //========================================================

    task wait_rx_ready;

        integer count;

        begin

            count = 0;

            while ((rdy !== 1'b1) &&
                   (count < 100000)) begin

                @(posedge CLK);
                count = count + 1;

            end

            #1;

            if (rdy !== 1'b1)
                $display("ERROR: RX timeout");
            else
                $display("[%0t] RX READY: DATA=%h",
                         $time, dout);

        end

    endtask

    //========================================================
    // EXTERNAL UART RX GENERATOR
    //========================================================

    task uart_rx_byte(
        input [7:0] data_in
    );

        integer i;

        begin

            use_loopback = 0;

            // Start bit
            rx_drv = 0;
            #8680;

            // Data bits LSB first
            for (i = 0; i < 8; i = i + 1) begin

                rx_drv = data_in[i];
                #8680;

            end

            // Stop bit
            rx_drv = 1;
            #8680;

            $display("[%0t] EXTERNAL UART RX SENT: %h",
                     $time, data_in);

        end

    endtask

    //========================================================
    // MAIN TEST SEQUENCE
    //========================================================

    initial begin

        $dumpfile("top_uart.vcd");
        $dumpvars(0, tb_uart_apb);

        // Initialize signals
        RESETn       = 0;

        rx_drv       = 1;
        use_loopback = 0;

        PADDR        = 0;
        PWDATA       = 0;
        PWRITE       = 0;
        PSELx        = 0;
        PENABLE      = 0;

        read_result  = 0;

        $display("========================================");
        $display(" APB UART BRIDGE VERIFICATION");
        $display("========================================");

        // RESET
        repeat (10) @(negedge CLK);

        RESETn = 1;

        repeat (10) @(negedge CLK);

        //====================================================
        // TEST 1: UART TX-RX LOOPBACK
        //====================================================

        $display("\nTEST 1: UART LOOPBACK");

        use_loopback = 1;

        // APB writes A5 into TXDATA
        apb_write(32'h00, 32'h000000A5);

        // Wait for transmission
        wait_tx_complete;

        // Wait for receiver
        wait_rx_ready;

        // Read RXDATA
        apb_read(32'h04);

        if (read_result[7:0] === 8'hA5) begin

            $display("PASS: LOOPBACK DATA = A5");

        end

        else begin

            $display("FAIL: EXPECTED A5, GOT %h",
                     read_result[7:0]);

        end

        //====================================================
        // TEST 2: STATUS REGISTER
        //====================================================

        $display("\nTEST 2: STATUS REGISTER");

        apb_read(32'h08);

        $display("STATUS REGISTER = %h", read_result);

        //====================================================
        // TEST 3: CLEAR RX READY
        //====================================================

        $display("\nTEST 3: RX READY CLEAR");

        apb_write(32'h0C, 32'h00000001);

        repeat (5) @(posedge CLK);

        if (rdy == 0)
            $display("PASS: RX READY CLEARED");
        else
            $display("FAIL: RX READY NOT CLEARED");

        //====================================================
        // TEST 4: EXTERNAL UART RECEPTION
        //====================================================

        $display("\nTEST 4: EXTERNAL UART RX");

        uart_rx_byte(8'h3C);

        wait_rx_ready;

        apb_read(32'h04);

        if (read_result[7:0] === 8'h3C)
            $display("PASS: EXTERNAL RX DATA = 3C");
        else
            $display("FAIL: EXPECTED 3C, GOT %h",
                     read_result[7:0]);

        //====================================================
        // FINISH
        //====================================================

        $display("\n========================================");
        $display(" SIMULATION COMPLETED");
        $display("========================================");

        #100;

        $finish;

    end

    //========================================================
    // GLOBAL SIMULATION TIMEOUT
    //========================================================

    initial begin

        #10000000;

        $display("GLOBAL SIMULATION TIMEOUT");

        $finish;

    end

endmodule

