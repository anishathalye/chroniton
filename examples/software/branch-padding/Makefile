.PHONY: all
all: 32bit.mem 64bit.mem

include ../common/riscv.mk

CLEAN_FILES += *.o *.bin *.coe *.lst *.elf *.mem ../common/*.o

CFLAGS += -I../common/

main.elf: ../common/main.ld $(COMMON_O) main.o $(GCC_LIB)
	$(LD) $(LDFLAGS) -T $^ -o $@

%bit.mem: main.bin
	bin2coe --width $(patsubst %bit.mem,%,$@) -i $< -o $@ --mem
