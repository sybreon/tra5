#!/bin/sh
verilator -I../rtl/verilog/ -cc ../rtl/verilog/t5_rv32i.v --trace -exe t5_sim.cc && \
make -C obj_dir/ -f Vt5_rv32i.mk && \
obj_dir/Vt5_rv32i
