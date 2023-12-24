# System-On-Chip with an Array Processor
## Overview

In our design, ZYNQ PS is connected to DMA for DDR memory access through the AXI bus. AXI Lite protocol is used to transfer control information to the fetch unit. Communication between DMA and the fetch unit occurs through the AXI Stream protocol. The Fetch unit is connected to 4 BRAM memory units. Following are the memory capacity of each of the BRAM units. 

Data Mem_1 = (32x4x256)
Data Mem_2 = (32x4x256)
Instr Mem = (12x 4K)
Result Mem = (32x4x256)

The fetch unit will retrieve the two vectors from the DDR memory and save them in the Data Mem 1 and Data Mem 2 respectively. Also, the instructions for the desired operation will be saved in the INSTR MEM block ram by the fetch unit.

## Fetch Unit
The fetch unit consists of one AXI-LITE slave interface, one AXI-STREAM slave interface and one AXI-STREAM master interface. The AXI-LITE slave is connected directly to the master interface of Zynq PS. It is used to transfer the control signals such as the height and width of input matrices to the PL side. The 2 AXI-STREAM interfaces are connected to the DMA. Those are used to get the data from DDR and send data to DDR.
The fetch unit has two modes of loading i.e. normal mode and transpose mode. The mode of loading. It can be set directly from PS through the AXI-LITE interface. When the fetch unit is working in normal mode, it loads the coming data from AXI-STREAM to BRAM in order which means writing pointer(address) always increments by 1. The following figure illustrates the normal mode behaviour.

When the fetch unit works in the transpose mode, it loads the coming data from AXI-STREAM to BRAM by incrementing the write pointer (address) by the height of matrix B. Therefore, it does the matrix transpose while loading the data to BRAM. The following figure illustrates the transpose mode behaviour.

## Instruction Set Architecture
ISA of SIMD processor consists of 11 instructions. These instructions can be categorised into two instruction formats.  Therefore 4 bits are required for opcode. 

### Instruction format 1
The address is used to address DATA MEM 1, DATA MEM 2 or RESULT MEM. 

1. Fetch A
2. Fetch B
3. Store Result


### Instruction format 2
Consists of instructions which do not require data addressing. 

1. Add
2. Subtract
3. Multiply
4. Dot Product
5. Store Temp 1
6. Store Temp 2
7. Stop
8. Nop


## SIMD Processor Architecture

Initially, the program counter of the PE Fetch Unit is set to 0 and it does not change.

The valid signal is coming into the PE Fetch Unit from the Fetch Unit. It indicates that all the data and instructions are stored in the respective BRAMs and the processor can start its operation. Once it receives the valid signal, the PE Fetch Unit increments the program counter in each clock cycle by 1. Since the program counter is combinationally connected to the INSTR MEM, a new instruction will be fetched into the PE Fetch Unit in each clock cycle. 

The address portion in the instruction is combinationally connected to the DATA MEM 1 and DATA MEM 2 read addresses. The enable signal to DATA MEM 1 and DATA MEM 2 is given by decoding the FETCH A and FETCH B opcodes respectively. The data from DATA MEM 1 and DATA MEM 2 will be loaded into internal registers named data_a and data_b respectively. The data_a and data_b registers have a width of 128 bits and can accommodate data from a single location from the above-mentioned block rams. In a STORE instruction, the address mentioned is saved inside the internal res_addr register and the instruction is passed down into the below stages.

Each word in the data_a and data_b registers are combinationally connected to each of the four PEs. Furthermore, the respective instruction is also passed to the PEs. All PEs will receive the same instruction in a single clock cycle. A PE is an ALU which supports all the instructions mentioned above except FETCH A and FETCH B. 

The results of the programming elements will be loaded into the pe_stage_1_output register in the Accumulation and Buffering stage. Then the four values in the pe_stage_1_output register would be summed in a tree structure and the resultant value would be accumulated in the acc_output register. At the same time, the Accumulation and Buffering stage will be buffering the pe_opcode (the same opcode going into the PEs) and the pe_stage_1_output. Then the Accumulation and Buffering stage would consider the last buffered opcodes to determine whether the pe_stage_1_output or accumulated output needs to be given back to the PE Fetch Unit. Instructions like ADD, SUBTRACT and MULTIPLICATION would require the pe_stage_1_output to be given as the result to the PE Fetch Unit while the DOT PRODUCT instruction would require the accumulated output to be given as the result to the PE Fetch Unit.

The PE Fetch Unit has an internal register named result to store the results coming from the Accumulation and Buffering stage. It is 128 bits long. If the pe_stage_1_output is being stored in the PE Fetch Unit (pe_stage_1_valid signal is high), the entire result register gets written from the incoming value. If the accumulated value is being stored in the PE Fetch Unit (pe_stage_2_valid signal is high)  then the result register is shifted left and the incoming value is accommodated at the least significant 32 bits of the result register. If the store result signal is high, then the value in the internal result register is saved in the RESULT MEM at the address saved in the res_addr register.

Once the STOP instruction goes to the end of the Accumulation and Buffering stage, it makes the stop signal high which goes to the Fetch Unit. It indicates that the operation of the SIMD processor is complete and the Fetch Unit can write back the result into the DDR memory.

## Algorithm

Consider 4x4 matrix multiplication operation. Fetch A & Fetch B load the required row and column to the internal data registers from the given address and then DOTP get the dot product of the row and column which contains 4 elements. Then Store Temp 2 stores the result in the temporary buffer. After 4 similar operations, the temporary buffer is transferred to the desired location in the RESULT MEM using Store Result which contains 4 outputs of 4 dot product operations.



When the matrix size is bigger than 4x4, 4 elements are considered at a time. The first 4 elements of the first row of the Mat A stored as the first row in the relevant BRAM. The first 4 elements of the first column of the Mat B are stored as the first row in the relevant BRAM. Get the dot product of them first and store the result temporarily. Then consider the second set of 4 elements and get the dot product and add it to the temporary stored result and then transfer it to the temporary buffer. After the temporary buffer is filled with new 4 values, it is transferred to the desired location by Store instructions.

So any matrix operation can be done by following the same manner.

## Compiler

Since the instructions procedure should be given to do a matrix/vector operation based on the dimension of the matrix/vector and addresses should be calculated for every Load and Store instructions. So custom compiler was designed which is written in C so can be run in PS side as well. If SIMD suppose to do specific operation with fixeonly precompiled instructions can be directly load in to instruction memory without generating instructions in runtime. If the operations or dimensions should be changed in the runtime then instruction can be generated in PS side by ruinning the compiler in PS side. Input matrix dimensions are the input to the compiler and assembly instructions and binary instructions can be generated. Assembly instructions were used to human verification of the compiler and binary instructions can be run on SIMD.



