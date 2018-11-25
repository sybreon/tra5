#!/bin/sh
# $1 - ELF
# $2 - OUT
TOP="t5_rv32i"
verilator -I../rtl/verilog/ -cc ../rtl/verilog/$TOP.v --trace -exe t5_sim.cc && \
make -C obj_dir/ -f V$TOP.mk && \
obj_dir/V$TOP $@
