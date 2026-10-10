module IR_reg(clk,reset,Ii,Io,bus_in,IR,bus_out,opcode);
input clk,reset,Ii,Io;
input [7:0]bus_in;
output reg [7:0]IR;
output [7:0]bus_out;
output [3:0]opcode;
always@(posedge clk)
begin
if(reset==1)
IR<=8'b00000000;
else if(Ii)
IR<=bus_in;
end
assign opcode=IR[7:4];
assign bus_out=Io ? {4'b0000,IR[3:0]}:8'b00000000;
endmodule
