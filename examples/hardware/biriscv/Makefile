.PHONY: all
all: biriscv.rkt

include ../common/Makefrag

ALL_V := $(shell find . -name '*.v' | tr '\n' ' ')

biriscv.smt2: $(ALL_V)
	yosys \
		-p "read_verilog -defer $^" \
		-p 'prep -flatten -top biriscv -nordff' \
		-p "write_smt2 -stdt $@"
