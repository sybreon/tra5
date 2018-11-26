# Shawn Tan
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))
TMP := $(shell mktemp -d)/v

all:	rv32i clean

rv32i:
	@verilator -I$(mkfile_dir)../rtl/verilog/ -cc $(mkfile_dir)../rtl/verilog/t5_rv32i.v -exe $(mkfile_dir)t5_sim.cc --trace
	@make -C $(mkfile_dir)obj_dir/ -f Vt5_rv32i.mk
	@mv $(mkfile_dir)obj_dir/Vt5_rv32i $(mkfile_dir)/Vt5_rv32i.exe

clean:
	@rm -rf $(mkfile_dir)obj_dir/

clear:
	@rm -f *.log
