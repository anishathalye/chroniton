.PHONY: all
all: picorv32.rkt

include ../common/Makefrag

SOC_V := $(shell find soc -name '*.v' | sort | tr '\n' ' ')

picorv32.smt2: hsm.v $(SOC_V)
	yosys \
		-p "read_verilog -defer $< $(SOC_V)" \
		-p 'prep -flatten -top hsm -nordff' \
		-p "write_smt2 -stdt $@"
