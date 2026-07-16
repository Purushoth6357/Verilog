`timescale 1ns / 1ps

module tb_RCA8b;
    reg [7:0] A, B;
    reg Cin;
    wire [7:0] S;
    wire Cout;

    RCA8b rca8(.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));

    initial begin
        $dumpfile("RCA8b.vcd");
        $dumpvars(0, tb_RCA8b);

        // Test case 1
        A = 8'b00000000; B = 8'b00000000; Cin = 1'b0;
        #10;
        $display("Test case 1: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        // Test case 2
        A = 8'b00000001; B = 8'b00000010; Cin = 1'b0;
        #10;
        $display("Test case 2: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        // Test case 3
        A = 8'b11111111; B = 8'b00000001; Cin = 1'b0;
        #10;
        $display("Test case 3: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        // Test case 4
        A = 8'b10101010; B = 8'b01010101; Cin = 1'b1;
        #10;
        $display("Test case 4: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        // Test case 5
        A = 8'b11111111; B = 8'b11111111; Cin = 1'b1;
        #10;
        $display("Test case 5: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        $finish;
    end
endmodule