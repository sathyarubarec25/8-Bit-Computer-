module RAM(clk,addr,Ri,Ro,bus_in,bus_out,prog_mode,prog_write,prog_addr,prog_data,prog_readback);
input Ri,Ro,clk;
input [7:0]bus_in;
input[3:0]addr;
output [7:0]bus_out;
input prog_mode;
input prog_write;
input [3:0]prog_addr;
input[7:0]prog_data;
output [7:0]prog_readback;
reg[7:0]memory[0:15];
initial begin
memory[0]=8'h55;
memory[1]=8'h93;
memory[2]=8'hE0;
memory[3]=8'hF0;
memory[4]=8'h00;
memory[5]=8'h00;
memory[6]=8'h00;
memory[7]=8'h00;
memory[8]=8'h00;
memory[9]=8'h00;
memory[10]=8'h00;
memory[11]=8'h00;
memory[12]=8'h00;
memory[13]=8'h00;
memory[14]=8'h00;
memory[15]=8'h00;
end

wire w_en=prog_mode?prog_write:Ri;
wire[3:0] w_addr=prog_mode?prog_addr:addr;
wire[7:0]w_data=prog_mode?prog_data:bus_in;
always@(posedge clk)
if(w_en)memory[w_addr]<=w_data;
assign bus_out=Ro?memory[addr]:8'b00000000;
assign prog_readback=memory[prog_addr];

endmodule 
