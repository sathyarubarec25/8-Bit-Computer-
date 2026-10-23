
module cpu_core(
    input clk,
    input reset,
    input start,
    input inp_loaded,
    input [7:0] inp_data,
    input prog_mode,
    input prog_write,
    input [3:0] prog_addr,
    input [7:0] prog_data,

    output [7:0] prog_readback,
    output inp_req,
    output halted,
    output [3:0] pc_disp,
    output [7:0] out_value
);

// Shared bus
wire [7:0] bus;

// Control signals
wire co, ci, cl;
wire Mi, Ri, Ro;
wire Ii, Io;
wire Ai, Ao, Bi;
wire Alo, Sub, Fe;
wire oi, Inp;

// Internal connections
wire [3:0] pc_bus4;
wire [3:0] mar_addr;
wire [7:0] ir_bus;
wire [3:0] opcode;
wire [7:0] a_bus;
wire [7:0] a_val;
wire [7:0] b_val;
wire [7:0] alu_y;
wire [1:0] alu_flags;
wire [1:0] flags;
wire [7:0] ram_bus;

// Shared bus multiplexer
assign bus =
       (co  ? {4'b0000, pc_bus4} : 8'b0)
     | (Io  ? ir_bus             : 8'b0)
     | (Ao  ? a_bus              : 8'b0)
     | (Alo ? alu_y              : 8'b0)
     | (Ro  ? ram_bus            : 8'b0)
     | (Inp ? inp_data           : 8'b0);

// Control unit
ctrl_unit u_ctrl (
    .clk(clk),
    .reset(reset),
    .start(start),
    .inp_loaded(inp_loaded),
    .opcode(opcode),
    .carry_flag(flags[1]),
    .zero_flag(flags[0]),
    .inp_req(inp_req),
    .halted(halted),
    .co(co),
    .ci(ci),
    .cl(cl),
    .Mi(Mi),
    .Ri(Ri),
    .Ro(Ro),
    .Ii(Ii),
    .Io(Io),
    .Ai(Ai),
    .Ao(Ao),
    .Bi(Bi),
    .Alo(Alo),
    .Sub(Sub),
    .Fe(Fe),
    .oi(oi),
    .Inp(Inp)
);

// Program counter
PC_counter u_pc (
    .clk(clk),
    .reset(reset),
    .co(co),
    .ci(ci),
    .cl(cl),
    .bus_in(bus[3:0]),
    .bus_out(pc_bus4),
    .pc(pc_disp)
);

// Memory address register
MAR u_mar (
    .Mi(Mi),
    .clk(clk),
    .reset(reset),
    .bus_in(bus[3:0]),
    .Mar(mar_addr)
);

// RAM
RAM u_ram (
    .clk(clk),
    .reset(reset),
    .Ri(Ri),
    .Ro(Ro),
    .addr(mar_addr),
    .bus_in(bus),
    .bus_out(ram_bus),
    .prog_mode(prog_mode),
    .prog_write(prog_write),
    .prog_addr(prog_addr),
    .prog_data(prog_data),
    .prog_readback(prog_readback)
);

// Instruction register
IR_reg u_ir (
    .clk(clk),
    .reset(reset),
    .Ii(Ii),
    .Io(Io),
    .bus_in(bus),
    .IR(),
    .bus_out(ir_bus),
    .opcode(opcode)
);

// A register
A_reg u_a (
    .clk(clk),
    .reset(reset),
    .Ai(Ai),
    .Ao(Ao),
    .bus_in(bus),
    .bus_out(a_bus),
    .A(a_val)
);

// B register
B_reg u_b (
    .clk(clk),
    .reset(reset),
    .Bi(Bi),
    .bus_in(bus),
    .B(b_val)
);

// Arithmetic logic unit
alu u_alu (
    .A(a_val),
    .B(b_val),
    .Sub(Sub),
    .y(alu_y),
    .flag_out(alu_flags)
);

// Flag register
flag_reg u_flags (
    .clk(clk),
    .reset(reset),
    .Fe(Fe),
    .flag_in(alu_flags),
    .flag(flags)
);

// Output register
out_reg u_out (
    .clk(clk),
    .reset(reset),
    .oi(oi),
    .bus_in(bus),
    .out_reg(out_value)
);

endmodule
