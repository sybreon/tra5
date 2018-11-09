# Copyright (C) 2011 Aeste Works (M) Sdn Bhd.

TMP := $(shell mktemp -d)/v
DMP := $(shell hostname)-$(shell date -I)
RND := $(shell date +%N)

VER = $(wildcard verilog/*.v)

LIB = -y ../rtl/verilog
LOG = $(DMP).log
VCD = $(DMP).vcd

rv32i:	rv32i.v vvp clean

rv32i.v:
	@iverilog $(LIB) -tnull -M$(TMP).ls t5_sim.v
	@uniq $(TMP).ls | sed 1d > $(TMP).fs
	@iverilog -c$(TMP).fs -E -tnull -o $(TMP).v t5_sim.v

vvp:
	@iverilog -Wall -o $(TMP).vvp $(TMP).v
	@time -p vvp -l $(LOG) $(TMP).vvp +randseed=$(RND) +dumpfile=$(VCD)

clean:
	@rm -rf $(TMP)*

clear:
	@rm -f *.log
