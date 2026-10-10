module cpu_top(clk, sw, btn, led, seg, an);

input clk;
input [15:0] sw;
input [3:0] btn;

output [15:0] led;
output [6:0] seg;
output [3:0] an;

// Slow CPU clock
wire cpu_enable;

Clock_divider #(.DIV(5000000)) u_div (
    .clk_in(clk),
    .clk_enable(cpu_enable)
);

// Synchronize mode switch and reset button
reg [1:0] mode_sync = 2'b00;
reg [1:0] rst_sync = 2'b00;

always @(posedge cpu_clk)
begin
    mode_sync <= {mode_sync[0], sw[15]};
    rst_sync <= {rst_sync[0], btn[3]};
end

wire prog_mode;
wire rst_btn;

assign prog_mode = mode_sync[1];
assign rst_btn = rst_sync[1];

// One-clock pulses from buttons
wire write_p;
wire start_p;
wire inp_p;

pulse_gen g_write (
    .clk(cpu_clk),
    .in(btn[0]),
    .pulse(write_p)
);

pulse_gen g_start (
    .clk(cpu_clk),
    .in(btn[1]),
    .pulse(start_p)
);

pulse_gen g_inp (
    .clk(cpu_clk),
    .in(btn[2]),
    .pulse(inp_p)
);

// CPU signals
wire [7:0] prog_readback;
wire [7:0] out_value;
wire [3:0] pc_disp;
wire inp_req;
wire halted;

// CPU core
cpu_core u_core (
    .clk(cpu_clk),
    .reset(rst_btn | prog_mode),
    .start(start_p & ~prog_mode),
    .inp_loaded(inp_p),
    .inp_data(sw[7:0]),
    .prog_mode(prog_mode),
    .prog_write(write_p),
    .prog_addr(sw[11:8]),
    .prog_data(sw[7:0]),
    .prog_readback(prog_readback),
    .inp_req(inp_req),
    .halted(halted),
    .pc_disp(pc_disp),
    .out_value(out_value)
);

// Display value selection
wire [7:0] shown;

assign shown = prog_mode ? prog_readback : out_value;

// Seven-segment display
seg7_driver u_seg (
    .clk(clk),
    .value(shown),
    .seg(seg),
    .an(an)
);

// LED outputs
assign led[7:0] = shown;
assign led[11:8] = pc_disp;
assign led[12] = prog_mode;
assign led[13] = 1'b0;
assign led[14] = inp_req;
assign led[15] = halted;

endmodule


// Clock divider

module Clock_divider #(
    parameter integer DIV = 5000000
)(
    input clk_in,
    output reg clk_enable = 1'b0
);

    reg [31:0] cnt = 0;

    always @(posedge clk_in) begin
        if (cnt == DIV - 1) begin
            cnt <= 0;
            clk_enable <= 1'b1;
        end else begin
            cnt <= cnt + 1;
            clk_enable <= 1'b0;
        end
    end

endmodule

// Button pulse generator
module pulse_gen(clk, in, pulse);

input clk;
input in;
output pulse;

reg s1 = 1'b0;
reg s2 = 1'b0;
reg s3 = 1'b0;

always @(posedge clk)
begin
    s1 <= in;
    s2 <= s1;
    s3 <= s2;
end

assign pulse = s2 & ~s3;

endmodule


// Seven-segment display driver
module seg7_driver(clk, value, seg, an);

parameter SEG_ACTIVE_LOW = 1;
parameter AN_ACTIVE_LOW = 1;

input clk;
input [7:0] value;

output [6:0] seg;
output [3:0] an;

// Decimal digit calculation
wire [3:0] ones;
wire [3:0] tens;
wire [3:0] hundreds;

assign ones = value % 10;
assign tens = (value / 10) % 10;
assign hundreds = value / 100;

// Display refresh counter
reg [16:0] cnt = 17'd0;

always @(posedge clk)
begin
    cnt <= cnt + 1;
end

wire [1:0] sel;

assign sel = cnt[16:15];

reg [3:0] digit;
reg blank;
reg [3:0] an_hot;

always @(*)
begin
    digit = 4'd0;
    blank = 1'b0;
    an_hot = 4'b0000;

    case (sel)
        2'd0:
        begin
            an_hot = 4'b0001;
            digit = ones;
            blank = 1'b0;
        end

        2'd1:
        begin
            an_hot = 4'b0010;
            digit = tens;
            blank = (value < 10);
        end

        2'd2:
        begin
            an_hot = 4'b0100;
            digit = hundreds;
            blank = (value < 100);
        end

        2'd3:
        begin
            an_hot = 4'b1000;
            digit = 4'd0;
            blank = 1'b1;
        end
    endcase
end

// Seven-segment decoder
reg [6:0] seg_hot;

always @(*)
begin
    if (blank)
    begin
        seg_hot = 7'b0000000;
    end
    else
    begin
        case (digit)
            4'd0: seg_hot = 7'b0111111;
            4'd1: seg_hot = 7'b0000110;
            4'd2: seg_hot = 7'b1011011;
            4'd3: seg_hot = 7'b1001111;
            4'd4: seg_hot = 7'b1100110;
            4'd5: seg_hot = 7'b1101101;
            4'd6: seg_hot = 7'b1111101;
            4'd7: seg_hot = 7'b0000111;
            4'd8: seg_hot = 7'b1111111;
            4'd9: seg_hot = 7'b1101111;
            default: seg_hot = 7'b0000000;
        endcase
    end
end

assign seg = SEG_ACTIVE_LOW ? ~seg_hot : seg_hot;
assign an = AN_ACTIVE_LOW ? ~an_hot : an_hot;

endmodule