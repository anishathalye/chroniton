.PHONY: all
all: biriscv.rkt

include ../common/Makefrag

ALL_V := ./core/biriscv_defs.v $(shell find . -name '*.v' -a -not -name 'biriscv_defs.v' | sort | tr '\n' ' ')

biriscv.smt2: $(ALL_V)
	yosys \
		-p "read_verilog -defer $^" \
		-p 'prep -flatten -top biriscv -nordff' \
		-p "write_smt2 -stdt $@"
