
module CPU_top(
    input clk,
    input [15:0] sw,
    input [3:0] btn,
    output [7:0] seg,
    output [7:0] an,
    output [15:0] led
);

wire slow_clk;
wire write_pulse;
wire start_pulse;
wire input_pulse;

wire [7:0] prog_readback;
wire inp_req;
wire halted;
wire [3:0] pc_disp;
wire [7:0] out_value;
wire [7:0] display_value;


Clock_divider u_clkdiv(
    .clk(clk),
    .reset(btn[0]),
    .slow_clk(slow_clk)
);

pulse_gen u_write(
    .clk(slow_clk),
    .reset(btn[0]),
    .button(btn[1]),
    .pulse(write_pulse)
);

pulse_gen u_start(
    .clk(clk),
    .reset(btn[0]),
    .button(btn[2]),
    .pulse(start_pulse)
);

pulse_gen u_input(
    .clk(clk),
    .reset(btn[0]),
    .button(btn[3]),
    .pulse(input_pulse)
);

cpu_core u_cpu(
    .clk(slow_clk),
    .reset(btn[0]),
    .start(start_pulse),
    .inp_loaded(input_pulse),
    .inp_data(sw[7:0]),

    .prog_mode(sw[12]),
    .prog_write(write_pulse),
    .prog_addr(sw[11:8]),
    .prog_data(sw[7:0]),
    .prog_readback(prog_readback),

    .inp_req(inp_req),
    .halted(halted),
    .pc_disp(pc_disp),
    .out_value(out_value)
);

assign display_value = sw[12] ? prog_readback : out_value;

seg7_driver u_display(
    .clk(clk),
    .reset(btn[0]),
    .value(display_value),
    .seg(seg),
    .an(an)
);


assign led[3:0]   = pc_disp;
assign led[4]     = inp_req;
assign led[5]     = halted;
assign led[12]    = sw[12];
assign led[11:6]  = 6'b000000;
assign led[15:13] = 3'b000;

endmodule
