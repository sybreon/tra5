#
# Makefile for AEMB Software
# 
# -Wl,-T -Wl,ld/linker.ld should be added to Lflags for implementation and omitted for simulation 
sim: 
	riscv32-unknown-elf-objcopy -O srec rom.elf rom.srec
	srec_cat rom.srec -byte-swap 4 -offset - -minimum-addr rom.srec -byte-swap 4 -fill 0xAE -within rom.srec -range-pad 4 -o dump.vmem -vmem 32

clean:
	rm *.dump *.srec *.elf
