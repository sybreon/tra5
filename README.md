# Multi-Threaded RISC-V Core

The design of this CPU is inspired by the previous work done with the AEMB2 microprocessor - fine-grain multi-threading.

## Verilator

The Verilator model *MUST* first be compiled before running any of the tests.
To build the simulation model with Verilator, do the following:

$ cd sim/
$ make

## Compliance Tests

The TRA5 core passes ALL the compliance tests except for the EBREAK, which fails simply due to an invalid MCAUSE value. This logic can be fixed easily, if necessary, but was not done in this case because this instruction does not appear to be used much, if at all.

To build and run the tests:

$ cd riscv-compliance-master/
$ make

## Zephyr RTOS

The TRA5 core has some limitations with the RTOS samples.

1. It uses FGMT and unless the core of the OS is modified to cater to this, the RTOS will not be capable of exploiting the full capabilities of the CPU. Also, two lines of assembly was inserted into vectors.S to lock out all threads except for Thread0. This code was borrowed verbatim from the Compliance Tests.
2. It lacks timers, which means that cooperative multi-tasking is required for now. Furthermore, any timing based delay will face issues. 

To build and run the tests:

$ cd zephyr-zephyr-v1.13.0/
$ ./t5_build.sh

The 'console' output is piped to the *.out files.

## Hardware

Although the CPU has been designed in 100% fully-synthesisable Verilog, it has not been tested in hardware. 
Caveat emptor!
