module PC_counter(clk,reset,co,ci,cl,bus_in,bus_out,pc);
output [3:0]bus_out;
output reg [3:0]pc;
input clk,reset,co,ci,cl;
input [3:0]bus_in;
always@(posedge clk)
begin
if (reset==1)
pc<=4'b0000;
else if(cl)
pc<=bus_in;
else if(ci)
pc<=pc+4'b0001;
end
assign bus_out=co ? pc:4'b0000;
endmodule
