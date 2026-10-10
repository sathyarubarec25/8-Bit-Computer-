module B_reg(clk,reset,Bi,bus_in,B);
input clk,reset,Bi;
input[7:0]bus_in;
output reg[7:0]B;
always @(posedge clk)
begin
if(reset==1)
B<=8'b00000000;
else if(Bi)
B<=bus_in;
end
endmodule








