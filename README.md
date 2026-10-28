**8-Bit Computer Design Using Verilog HDL**

**Project Overview**

This project involves designing and implementing an 8-bit computer using Verilog HDL on a Spartan-7 FPGA board. The processor is built by integrating individual modules such as the ALU, registers, RAM, program counter, instruction register, and control unit.

The processor follows the Fetch–Decode–Execute cycle to execute instructions. The project helped me understand how these modules work together to perform arithmetic operations, manage data, and control instruction execution.

**Features**

8-bit processor with a custom 16-instruction set

Hardwired FSM-based control unit

16 × 8 RAM for storing instructions and data

Support for arithmetic operations and conditional and unconditional branching

Input and output operations

Seven-segment display for output

LED indicators for monitoring processor status

Simulation and FPGA implementation using AMD/Xilinx Vivado



**System Architecture**

The processor consists of a datapath and a hardwired control unit that coordinates the execution of instructions.

**Fetch Path**

Program Counter (PC): Holds the address of the next instruction.

Memory Address Register (MAR): Stores the address used to access RAM.

RAM: Provides storage for instructions and data.

Instruction Register (IR): Holds the current instruction for decoding and execution.

**Execute Path**

Accumulator (A Register): Stores an operand and the results of operations.

B Register: Holds the second operand for ALU operations.

Arithmetic Logic Unit (ALU): Performs arithmetic and logical operations.

Flag Register: Stores status flags used by conditional instructions.

**Control and Output**

Control Unit: Uses a finite-state machine (FSM) to generate the control signals required for each instruction.

Output Register: Stores the value produced by the OUT instruction.

Clock Divider: Slows down the board clock to make processor operation easier to observe on the FPGA board.

**Instruction Set**

Each instruction is 8 bits wide, consisting of a 4-bit opcode and a 4-bit address or immediate value.

The instruction set includes:

NOP, LDA, STA, ADD, SUB, JMP, LDI, JC, JZ, ADI, SUI, XRA, ANA, INP, OUT, and HLT.




**Working Principle**

The program is stored in RAM, and the processor executes instructions through the Fetch–Decode–Execute cycle. The program counter identifies the instruction address, the instruction register holds the fetched instruction, and the control unit generates the signals needed for execution.

The ALU performs calculations, while the registers and RAM manage operands and results. The output register stores the value sent by the OUT instruction, which can then be observed on the seven-segment display.

**Example Program**

The following program demonstrates loading a value, adding a value stored in RAM, displaying the result, and halting execution.

0  LDI 5

Load the immediate value 5 into the accumulator

1  ADD 8

Add the value stored at RAM address 8

2   OUT

Send the result to the output register

3   HLT

Stop execution

If RAM[8] = 3, the expected result is:

5 + 3 = 8

The output is displayed as 08 when the seven-segment display is configured to show the output value in hexadecimal.




**Hardware and Development Tools**

Hardware Description Language: Verilog HDL

Development Board: RealDigital Boolean Board

FPGA Family: AMD/Xilinx Spartan-7

FPGA Part: XC7S50-CSGA324-1

Development Software: AMD/Xilinx Vivado



**Conclusion**

This project provided practical experience in designing a processor and understanding how its internal components work together. Implementing the Fetch–Decode–Execute cycle helped me understand instruction processing, register transfers, memory access, and ALU operations. Testing the design through simulation and FPGA implementation also gave me experience in hardware integration and debugging.
