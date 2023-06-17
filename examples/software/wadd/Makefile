.PHONY: all
all: main.text.mem main.data.mem

include ../common/otbn.mk

CLEAN_FILES += *.o *.bin *.lst *.elf *.mem

main.elf: main.o
	$(OTBN_LD) $^ -o $@
