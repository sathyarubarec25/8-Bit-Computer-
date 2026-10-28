8-Bit Computer Design Using Verilog HDL
This project is about designing an 8-bit computer using Verilog HDL and implementing it on a Spartan-7 FPGA board. I worked on building the processor by connecting different modules such as the ALU, registers, RAM, program counter, and control unit.
The processor follows the Fetch–Decode–Execute cycle to run instructions. It supports basic arithmetic and logical operations, branching, and input/output operations.

Features;
8-bit computer with a custom 16-instruction set
Hardwired FSM control unit
16 × 8 RAM for both instructions and data
Conditional (JZ) and unconditional (JMP) branching
Eight LEDs and a seven-segment display for output
Two slide switches select what the LEDs show: CPU output, PC, accumulator or IR
Simulation and FPGA implementation using Vivado

System Architecture
The processor is built from a datapath and a hardwired control unit that drives it.

Fetch path
PC: holds the address of the next instruction
MAR: holds the address for the current memory access
RAM: 16 × 8 memory for both instructions and data
IR: holds the instruction being executed

Execute path
ACC: main operand and result register
B register: second operand for the ALU
ALU: arithmetic, logic and shift operations
Flag register: zero flag (used by JZ) and carry flag

Control and output
Control unit: FSM that generates all control signals
Output register: holds the value sent by OUT
Clock divider: slows the board clock down so the CPU is observable

Instruction Set
Each instruction is 8 bits: a 4-bit opcode and a 4-bit address or immediate value.
Instructions: NOP, LDA, STA, ADD, SUB, JMP, LDI, INP, OUT, HLT, AND, OR, XOR, NOT, SHIFT, JZ

Working

The program is stored in RAM, and the processor executes it one instruction at a time. The program counter keeps track of the instruction address, while the control unit generates the signals needed for each operation. The ALU performs the calculations, and the result is shown on the LEDs and seven-segment display.

Example program

0: LDI 5
1: ADD 8     (RAM[8] = 3)
2: OUT
3: HLT

Result: 5 + 3 = 8, displayed as 08.

Hardware and Development Tools;
Language: Verilog HDL
Board: Real Digital Boolean Board
FPGA family: AMD/Xilinx Spartan-7
FPGA part: XC7S50-CSGA324-1
Software: Xilinx Vivado

Conclusion

Building this CPU showed me how a processor actually works: fetching an instruction, decoding the opcode, and moving data between registers, RAM and the ALU. Running it on a Spartan-7 board made the theory real, because I could watch the PC, accumulator and output change on the LEDs as the program ran.
