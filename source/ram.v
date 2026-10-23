
module RAM(clk, reset, Ri, Ro, addr, bus_in, bus_out, prog_mode, prog_write, prog_addr, prog_data, prog_readback);

input clk, reset;
input Ri, Ro;
input [3:0] addr;
input [7:0] bus_in;

input prog_mode, prog_write;
input [3:0] prog_addr;
input [7:0] prog_data;

output [7:0] bus_out;
output [7:0] prog_readback;

reg [7:0] memory [0:15];

always @(posedge clk)
begin
    if (!reset)
    begin
        if (prog_mode && prog_write)
        begin
            memory[prog_addr] <= prog_data;
        end
        else if (!prog_mode && Ri)
        begin
            memory[addr] <= bus_in;
        end
    end
end

assign bus_out = (!reset && !prog_mode && Ro)
                 ? memory[addr] : 8'b00000000;

assign prog_readback = prog_mode
                       ? memory[prog_addr] : 8'b00000000;

endmodule
