module MAR(Mi,clk,reset,bus_in,Mar);
input Mi,clk,reset;
input [3:0]bus_in; 
output reg [3:0]Mar;
always@(posedge clk)
begin
if (reset==1)
Mar<=4'b0000;
else if(Mi)
Mar<=bus_in;
end
endmodule
