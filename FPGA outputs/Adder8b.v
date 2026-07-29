module adder(
    input wire [7:0] SW,
    input wire KEY0,
    input wire KEY1,
    output wire [7:0] LED
);

reg [7:0] A;
reg [7:0] B;
wire [8:0] SUM;

// Load A when KEY0 is pressed
always @(negedge KEY0)
begin
    A <= SW;
end

// Load B when KEY1 is pressed
always @(negedge KEY1)
begin
    B <= SW;
end

assign SUM = A + B;

// LEDs are active LOW
assign LED = ~SUM[7:0];

endmodule