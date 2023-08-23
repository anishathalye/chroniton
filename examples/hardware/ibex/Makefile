.PHONY: all
all: ibex.rkt

include ../common/Makefrag

ALL_V := hsm.v $(shell find soc -name '*.v' -o -name '*.sv' | tr '\n' ' ')

CLEAN_FILES += combined.v

combined.v: $(ALL_V)
	sv2v -D SYNTHESIS -D YOSYS $^ > $@

ibex.smt2: combined.v
	cd ../impl; \
	yosys \
		-p "read_verilog -defer $<" \
		-p 'prep -flatten -top hsm -nordff' \
		-p "write_smt2 -stdt $@"
