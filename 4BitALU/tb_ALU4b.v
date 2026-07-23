`timescale 1ns/1ps

module tb_ALU4b;
    reg [3:0] A, B;
    reg [2:0] ALU_Sel;
    wire [3:0] ALU_Out;
    wire CarryOut;


    ALU4b uut (
        .A(A),
        .B(B),
        .ALU_Sel(ALU_Sel),
        .ALU_Out(ALU_Out),
        .CarryOut(CarryOut)
    );

    initial begin
        $dumpfile("tb_ALU4b.vcd");
        $dumpvars(0, tb_ALU4b);

        // Test Case 1: Addition
        A = 4'b0011; B = 4'b0101; ALU_Sel = 3'b000; #10;
        $display("Addition: A=%b, B=%b, ALU_Out=%b, CarryOut=%b", A, B, ALU_Out, CarryOut);

        // Test Case 2: Subtraction
        A = 4'b0110; B = 4'b0011; ALU_Sel = 3'b001; #10;
        $display("Subtraction: A=%b, B=%b, ALU_Out=%b, CarryOut=%b", A, B, ALU_Out, CarryOut);

        // Test Case 3: AND
        A = 4'b1100; B = 4'b1010; ALU_Sel = 3'b010; #10;
        $display("AND: A=%b, B=%b, ALU_Out=%b", A, B, ALU_Out);

        // Test Case 4: OR
        A = 4'b1100; B = 4'b1010; ALU_Sel = 3'b011; #10;
        $display("OR: A=%b, B=%b, ALU_Out=%b", A, B, ALU_Out);

        // Test Case 5: XOR
        A = 4'b1100; B = 4'b1010; ALU_Sel = 3'b100; #10;
        $display("XOR: A=%b, B=%b, ALU_Out=%b", A, B, ALU_Out);

        // Test Case 6: NOR
        A = 4'b1100; B = 4'b1010; ALU_Sel = 3'b101; #10;
        $display("NOR: A=%b, B=%b, ALU_Out=%b", A, B, ALU_Out);

        // Test Case 7: NAND
        A = 4'b1100; B = 4'b1010; ALU_Sel = 3'b110; #10;
        $display("NAND: A=%b, B=%b, ALU_Out=%b", A, B, ALU_Out);

        $finish;
    end

endmodule

