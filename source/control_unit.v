
module ctrl_unit(
    input clk,
    input reset,
    input start,
    input inp_loaded,
    input [3:0] opcode,
    input carry_flag,
    input zero_flag,

    output reg inp_req,
    output reg halted,

    output reg co,
    output reg ci,
    output reg cl,
    output reg Mi,
    output reg Ri,
    output reg Ro,
    output reg Ii,
    output reg Io,
    output reg Ai,
    output reg Ao,
    output reg Bi,
    output reg Alo,
    output reg Sub,
    output reg Fe,
    output reg oi,
    output reg Inp
);

// Instruction opcodes
parameter OP_NOP = 4'b0000;
parameter OP_LDA = 4'b0001;
parameter OP_ADD = 4'b0010;
parameter OP_SUB = 4'b0011;
parameter OP_STA = 4'b0100;
parameter OP_LDI = 4'b0101;
parameter OP_JMP = 4'b0110;
parameter OP_JC  = 4'b0111;
parameter OP_JZ  = 4'b1000;
parameter OP_ADI = 4'b1001;
parameter OP_SUI = 4'b1010;
parameter OP_XRA = 4'b1011;
parameter OP_ANA = 4'b1100;
parameter OP_INP = 4'b1101;
parameter OP_OUT = 4'b1110;
parameter OP_HLT = 4'b1111;

// Timing states
reg [2:0] stage;
reg running;

always @(posedge clk or posedge reset)
begin
    if (reset)
    begin
        stage <= 3'd0;
        running <= 1'b0;
        halted <= 1'b0;
    end
    else
    begin
        if (!running && !halted && start)
        begin
            running <= 1'b1;
            stage <= 3'd0;
        end
        else if (running)
        begin
            case (stage)

                // T0: PC -> MAR
                3'd0:
                    stage <= 3'd1;

                // T1: RAM -> IR
                3'd1:
                    stage <= 3'd2;

                // T2: Increment PC
                3'd2:
                    stage <= 3'd3;

                    // T3: Decode instruction
                3'd3:
                begin
                    case (opcode)

                        OP_LDA, OP_ADD, OP_SUB, OP_STA:
                            stage <= 3'd4;

                        OP_ADI, OP_SUI:
                            stage <= 3'd4;

                        OP_INP:
                        begin
                            if (inp_loaded)
                                stage <= 3'd0;
                            else
                                stage <= 3'd3;
                        end

                        OP_HLT:
                        begin
                            running <= 1'b0;
                            halted <= 1'b1;
                            stage <= 3'd0;
                        end

                        default:
                            stage <= 3'd0;

                    endcase
                end

                // T4: Read operand or perform immediate ALU operation
                3'd4:
                begin
                    case (opcode)

                        OP_ADD, OP_SUB:
                            stage <= 3'd5;

                        default:
                            stage <= 3'd0;

                    endcase
                end

                // T5: Complete ADD/SUB
                3'd5:
                    stage <= 3'd0;

                default:
                    stage <= 3'd0;

            endcase
        end
    end
end

always @(*)
begin
    // Default: disable all control signals
    co = 0;
    ci = 0;
    cl = 0;
    Mi = 0;
    Ri = 0;
    Ro = 0;
    Ii = 0;
    Io = 0;
    Ai = 0;
    Ao = 0;
    Bi = 0;
    Alo = 0;
    Sub = 0;
    Fe = 0;
    oi = 0;
    Inp = 0;
    inp_req = 0;

    if (running && !halted)
    begin
        case (stage)

            // T0: PC -> MAR
            3'd0:
            begin
                co = 1;
                Mi = 1;
            end

            // T1: RAM -> IR
            3'd1:
            begin
                Ro = 1;
                Ii = 1;
            end

            // T2: PC <- PC + 1
            3'd2:
            begin
                ci = 1;
            end

            // T3: Decode and begin execution
            3'd3:
            begin
                case (opcode)

                    OP_LDA, OP_ADD, OP_SUB, OP_STA:
                    begin
                        Io = 1;
                        Mi = 1;
                    end

                    OP_LDI:
                    begin
                        Io = 1;
                        Ai = 1;
                    end

                    OP_JMP:
                    begin
                        Io = 1;
                        cl = 1;
                    end

                    OP_JC:
                    begin
                        if (carry_flag)
                        begin
                            Io = 1;
                            cl = 1;
                        end
                    end

                    OP_JZ:
                    begin
                        if (zero_flag)
                        begin
                            Io = 1;
                            cl = 1;
                        end
                    end

                    OP_ADI, OP_SUI:
                    begin
                        Io = 1;
                        Bi = 1;
                    end

                    OP_INP:
                    begin
                        inp_req = 1;

                        if (inp_loaded)
                        begin
                            Inp = 1;
                            Ai = 1;
                        end
                    end

                    OP_OUT:
                    begin
                        Ao = 1;
                        oi = 1;
                    end

                    default:
                    begin
                        // NOP and unsupported instructions
                    end

                endcase
            end

            // T4: Execute memory operations or immediate ALU
            3'd4:
            begin
                case (opcode)

                    OP_LDA:
                    begin
                        Ro = 1;
                        Ai = 1;
                    end

                    OP_ADD, OP_SUB:
                    begin
                        Ro = 1;
                        Bi = 1;
                    end

                    OP_STA:
                    begin
                        Ao = 1;
                        Ri = 1;
                    end

                    OP_ADI, OP_SUI:
                    begin
                        Alo = 1;
                        Ai = 1;
                        Fe = 1;

                        if (opcode == OP_SUI)
                            Sub = 1;
                    end

                    default:
                    begin
                    end

                endcase
            end

            // T5: ALU operation using A and B
            3'd5:
            begin
                case (opcode)

                    OP_ADD:
                    begin
                        Alo = 1;
                        Ai = 1;
                        Fe = 1;
                    end

                    OP_SUB:
                    begin
                        Alo = 1;
                        Ai = 1;
                        Sub = 1;
                        Fe = 1;
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
