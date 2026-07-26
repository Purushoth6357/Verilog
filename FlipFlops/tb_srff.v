`timescale 1ns / 1ps

module tb_srff;
  
    reg S;
    reg R;
    reg clk;


    wire Q;
    wire Qbar;


    sr_ff uut (
        .S(S), 
        .R(R), 
        .clk(clk), 
        .Q(Q), 
        .Q_bar(Qbar)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk; 
    

    initial begin

        $dumpfile("tb_srff.vcd");
        $dumpvars(0, tb_srff);

        S = 0;
        R = 0;
        clk = 0;
        

        S = 1; R = 0; #10; 
        S = 0; R = 1; #10;          
        S = 1; R = 1; #10;  
        S = 0; R = 0; #10;  

        $finish;
    end

endmodule