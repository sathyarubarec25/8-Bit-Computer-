module A_reg(clk, reset, Ai, Ao, bus_in, bus_out, A);
input clk,reset,Ai,Ao;
input [7:0] bus_in;
output [7:0] bus_out;
output reg [7:0] A;
always @(posedge clk)
begin
    if (reset == 1)
        A <= 8'b00000000;
    else if (Ai == 1)
        A <= bus_in;
end

assign bus_out = Ao ? A : 8'b00000000;

endmodule