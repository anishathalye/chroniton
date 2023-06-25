.PHONY: all
all: otbn.rkt

include ../common/Makefrag

ALL_V := soc.v $(shell find otbn -name '*.v' -o -name '*.sv' | sort | tr '\n' ' ')

CLEAN_FILES += combined.v

combined.v: $(ALL_V)
	sv2v -D SYNTHESIS -D YOSYS $^ > $@

otbn.smt2: combined.v
	yosys \
		-p 'read_verilog -sv -defer combined.v' \
		-p 'hierarchy -check -top soc' \
		-p 'proc' \
		-p 'flatten' \
		-p 'opt_expr -keepdc' \
		-p 'opt_clean' \
		-p 'check' \
		-p 'opt -noff -keepdc' \
		-p 'wreduce -keepdc' \
		-p 'opt_clean' \
		-p 'memory_collect' \
		-p 'memory_map c:*stack_storage*' \
		-p 'opt -noff -keepdc -fast' \
		-p 'stat' \
		-p 'check' \
		-p "write_smt2 -stdt $@"

