# Multi-Threaded RISC-V Core

The design of this CPU is inspired by the previous work done with the AEMB2 microprocessor - uses interleaved multi-threading (IMT).
The name is pronounced like "trust", without the ending 't'.

## Main Features

The cpu core features a standard 5-stage RISC pipeline: Fetch, Decode, Execute, Memory, Writeback.

The cpu core has four internal hardware threads with MHARTID 0-3. This effectively quadruples the size of the register file only. The execution resources are shared between all threads. The clock is shared between all threads too - effectively quarter the speed for each thread.

## Requirements

Work environment uses Ubuntu 18.04 LTS. The software packages are installed directly from the Ubuntu repository, other than the toolchain. This includes the following main tools:

1. Verilator 3.916-1build1
2. Cmake 3.10.2-1ubuntu2
3. Make 4.1-9.1ubuntu1
4. GCC/G++ 7.3.0-3ubuntu2.1

The RISC-V compiler is built directly from https://github.com/riscv/riscv-gnu-toolchain using the following configuration:

$ ./configure --prefix=/opt/rv32i --with-arch=rv32i --with-abi=ilp32
$ make

## Verilator

The Verilator model *MUST* first be built before running any of the tests.
To build the simulation model with Verilator, do the following:

$ cd sim/
$ make

This will produce an executable - "Vt5_rv32i.exe" in the *sim/* directory that is used for the rest of the tests.

## Compliance Tests

The TRA5 processor core passes ALL the compliance tests ad-verbatim, without any modifications to the code. The only minor modifications made were to the build environment. These can be seen in the following files.

1. riscv-compliance-master/riscv-target/tra5/device/rv32i/Makefile.include
2. riscv-compliance-master/riscv-test-env/p/tra5.ld

The Makefile was modified to be able to run the automated tests using the "Vt5_rv32i.exe" instead of some other simulator e.g. spike.
The linker script was modified to install the reset vector code at address 0x00000000 instead of 0x80000000.

Before building and running the tests, modify the RISCV_PREFIX variable in the following "t5_build.sh" file to point to the RISC-V toolchain.

```
make RISCV_TARGET=tra5 RISCV_DEVICE=rv32i RISCV_ISA=rv32i RISCV_PREFIX=riscv32-unknown-elf-
```

To build and run the tests:

$ cd riscv-compliance-master/
$ ./t5_build.sh

It should pass ALL the tests.

## Zephyr RTOS

The TRA5 core has some limitations with the RTOS tests.

1. It uses IMT. Two lines of assembly was inserted into vectors.S to lock out all threads except for Thread0. It is possible to modify Zephyr to exploit all 4 hardware threads but this was not done/tested.
2. It lacks hardware timers, which means that cooperative multi-tasking is required for now. Furthermore, any timing based delay will face issues. 

Before building and running the tests, modify the CROSS_COMPILE variable in the following "t5_build.sh" file to point it to the RISC-V toolchain.

```
export CROSS_COMPILE=/opt/rv32i/bin/riscv32-unknown-elf-
```

To build and run the tests:

$ cd zephyr-zephyr-v1.13.0/
$ ./t5_build.sh

The 'console' output is piped to the *.out files - synchronization.out and philosophers.out.

There is a modification made to the Philosophers application to generate a random number using a software LFSR instead:

```
        static u16_t lfsr = (u16_t)MAGIC;
        u8_t lsb = lfsr & 1;
        lfsr >>= 1;
        if (lsb) lfsr ^= 0xB400u;
        return (lfsr & 0xF) + 1;
```

There is a problem with the philosophers sample application. It runs for a while then crashes due to the use of an unimplemented WFI instruction - in k_cpu_idle(). This triggers a break, which results in the following error message sent to the console, for each thread:

```
Exception cause Breakpoint (3)
Current thread ID = 0x00010300
Faulting instruction address = 0xb40
  ra: 0x34c8  gp: 0x0  tp: 0x0  t0: 0x0
  t1: 0x0  t2: 0x0  t3: 0x0  t4: 0x0
  t5: 0x0  t6: 0x0  a0: 0x0  a1: 0x0
  a2: 0x0  a3: 0x0  a4: 0x0  a5: 0x1800
  a6: 0x0  a7: 0x0
Fatal fault in essential thread! Spinning...
```

## Hardware

Although the CPU has been designed in 100% fully-synthesisable Verilog, it has not been tested in hardware. 
Caveat emptor!

