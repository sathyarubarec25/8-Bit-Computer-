module out_reg(clk,reset,oi,bus_in,out_reg);
input clk,reset,oi;
input [7:0]bus_in;
output reg[7:0] out_reg;
always@(posedge clk)
begin
if(reset==1)
out_reg<=8'b00000000;
else if(oi)
out_reg<=bus_in;
end 
endmodule