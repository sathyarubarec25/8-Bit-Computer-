module flag_reg( clk, reset, Fe, flag_in, flag);
input clk, reset, Fe;
input [1:0]flag_in;
output reg [1:0]flag;
always@(posedge clk)
begin
if (reset)
flag<=2'b00;
else if (Fe)
flag<=flag_in; 
end
endmodule
