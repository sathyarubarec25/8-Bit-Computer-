
module ctrl_unit(
    clk,
    reset,
    start,
    inp_loaded,
    opcode,
    carry_flag,
    zero_flag,
    inp_req,
    halted,
    co, ci, cl,
    Mi, Ri, Ro,
    Ii, Io,
    Ai, Ao, Bi,
    Alo, Sub,
    Fe, oi, Inp
);

// Input declarations
input clk;
input reset;
input start;
input inp_loaded;
input [3:0] opcode;
input carry_flag;
input zero_flag;

// Output declarations
output reg inp_req;
output halted;

output reg co, ci, cl;
output reg Mi, Ri, Ro;
output reg Ii, Io;
output reg Ai, Ao, Bi;
output reg Alo, Sub;
output reg Fe, oi, Inp;

// Internal registers
reg [2:0] stage;
reg running;
reg halt;
reg inp_wait;
reg hlt_sig;

// Instruction opcodes
parameter OP_LDA = 4'b0000;
parameter OP_STA = 4'b0001;
parameter OP_LDI = 4'b0010;
parameter OP_ADD = 4'b0011;
parameter OP_SUB = 4'b0100;
parameter OP_JMP = 4'b0101;
parameter OP_JZ  = 4'b0110;
parameter OP_INP = 4'b0111;
parameter OP_OUT = 4'b1000;
parameter OP_HLT = 4'b1001;

// Halt output
assign halted = halt;

// Sequential logic
always @(posedge clk)
begin
    if (reset)
    begin
        stage    <= 3'd0;
        running  <= 1'b0;
        halt     <= 1'b0;
        inp_wait <= 1'b0;
        inp_req  <= 1'b0;
    end

    else if (inp_wait)
    begin
        inp_req <= 1'b1;

        if (inp_loaded)
        begin
            inp_wait <= 1'b0;
            inp_req  <= 1'b0;
            running  <= 1'b1;
            stage    <= stage + 3'd1;
        end
    end

    else if (start && !running && !halt)
    begin
        running <= 1'b1;
        stage   <= 3'd0;
    end

    else if (running)
    begin
        if ((opcode == OP_INP) && (stage == 3'd3))
        begin
            inp_wait <= 1'b1;
            running  <= 1'b0;
        end

        else if (hlt_sig)
        begin
            running <= 1'b0;
            halt    <= 1'b1;
        end

        else if (stage == 3'd5)
        begin
            stage <= 3'd0;
        end

        else
        begin
            stage <= stage + 3'd1;
        end
    end
end

// Control signal generation
always @(*)
begin
    co      = 1'b0;
    ci      = 1'b0;
    cl      = 1'b0;
    Mi      = 1'b0;
    Ri      = 1'b0;
    Ro      = 1'b0;
    Ii      = 1'b0;
    Io      = 1'b0;
    Ai      = 1'b0;
    Ao      = 1'b0;
    Bi      = 1'b0;
    Alo     = 1'b0;
    Sub     = 1'b0;
    Fe      = 1'b0;
    oi      = 1'b0;
    Inp     = 1'b0;
    hlt_sig = 1'b0;

    if (running)
    begin
        case (stage)

            // T1: PC to MAR
            3'd0:
            begin
                co = 1'b1;
                Mi = 1'b1;
            end

            // T2: RAM to IR
            3'd1:
            begin
                Ro = 1'b1;
                Ii = 1'b1;
            end

            // T3: Increment PC
            3'd2:
            begin
                ci = 1'b1;
            end

            // T4: Decode and initial execution
            3'd3:
            begin
                case (opcode)

                    OP_LDA, OP_STA, OP_ADD, OP_SUB:
                    begin
                        Io = 1'b1;
                        Mi = 1'b1;
                    end

                    OP_LDI:
                    begin
                        Io = 1'b1;
                        Ai = 1'b1;
                    end

                    OP_JMP:
                    begin
                        Io = 1'b1;
                        cl = 1'b1;
                    end

                    OP_JZ:
                    begin
                        if (zero_flag)
                        begin
                            Io = 1'b1;
                            cl = 1'b1;
                        end
                    end

                    OP_OUT:
                    begin
                        Ao = 1'b1;
                        oi = 1'b1;
                    end

                    OP_HLT:
                    begin
                        hlt_sig = 1'b1;
                    end

                    default:
                    begin
                    end

                endcase
            end

            // T5: Memory access and input
            3'd4:
            begin
                case (opcode)

                    OP_LDA:
                    begin
                        Ro = 1'b1;
                        Ai = 1'b1;
                    end

                    OP_STA:
                    begin
                        Ao = 1'b1;
                        Ri = 1'b1;
                    end

                    OP_ADD, OP_SUB:
                    begin
                        Ro = 1'b1;
                        Bi = 1'b1;
                    end

                    OP_INP:
                    begin
                        Inp = 1'b1;
                        Ai  = 1'b1;
                    end

                    default:
                    begin
                    end

                endcase
            end

            // T6: Arithmetic operation
            3'd5:
            begin
                case (opcode)

                    OP_ADD:
                    begin
                        Alo = 1'b1;
                        Fe  = 1'b1;
                        Ai  = 1'b1;
                    end

                    OP_SUB:
                    begin
                        Sub = 1'b1;
                        Alo = 1'b1;
                        Fe  = 1'b1;
                        Ai  = 1'b1;
                    end

                    default:
                    begin
                    end

                endcase
            end

            default:
            begin
            end

        endcase
    end
end

endmodule