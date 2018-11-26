#!/bin/bash
export ZEPHYR_TOOLCHAIN_VARIANT=cross-compile
export CROSS_COMPILE=/opt/rv32i/bin/riscv32-unknown-elf-

source zephyr-env.sh

mkdir -p samples/synchronization/build/ && \
pushd samples/synchronization/build/ && \
cmake -DBOARD=tra5 ../ && \
make && \
popd && \
${CROSS_COMPILE}objcopy -Obinary samples/synchronization/build/zephyr/zephyr.elf synchronization.elf.bin && \
rm -rf samples/synchronization/build/ && \
../sim/Vt5_rv32i.exe synchronization.elf.bin /dev/null 0200 0200 1>synchronization.log 2>synchronization.out

mkdir -p samples/philosophers/build/ && \
pushd samples/philosophers/build/ && \
cmake -DBOARD=tra5 ../ && \
make && \
popd && \
${CROSS_COMPILE}objcopy -Obinary samples/philosophers/build/zephyr/zephyr.elf philosophers.elf.bin && \
rm -rf samples/philosophers/build/ && \
../sim/Vt5_rv32i.exe philosophers.elf.bin /dev/null 0200 0200 1>philosophers.log 2>philosophers.out
