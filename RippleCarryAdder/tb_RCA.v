`timescale 1ns / 1ps

module tb_RCA;
    reg [3:0] A, B;
    reg [7:0] A8, B8;
    reg Cin;
    wire [3:0] S;
    wire Cout;
    wire [7:0] S8;
    wire Cout8;

    RippleCarryAdder4b rca(.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));
    RCA8b rca8(.A(A8), .B(B8), .Cin(Cin), .S(S8), .Cout(Cout8));

    initial begin

        $dumpfile("RCA.vcd");
        $dumpvars(0, tb_RCA);
        // Test case 1
        A = 4'b0000; B = 4'b0000; Cin = 1'b0;
        #10;
        $display("Test case 1: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        // Test case 2
        A = 4'b0001; B = 4'b0010; Cin = 1'b0;
        #10;
        $display("Test case 2: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        // Test case 3
        A = 4'b1111; B = 4'b0001; Cin = 1'b0;
        #10;
        $display("Test case 3: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        // Test case 4
        A = 4'b1010; B = 4'b0101; Cin = 1'b1;
        #10;
        $display("Test case 4: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        // Test case 5
        A = 4'b1111; B = 4'b1111; Cin = 1'b1;
        #10;
        $display("Test case 5: A=%b, B=%b, Cin=%b => S=%b, Cout=%b", A, B, Cin, S, Cout);

        $finish;
    end

endmodule