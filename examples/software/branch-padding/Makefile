.PHONY: all
all: picorv32.mem biriscv.mem

include ../common/riscv.mk

CLEAN_FILES += *.o *.bin *.coe *.lst *.elf *.mem ../common/*.o

CFLAGS += -I../common/

main.elf: ../common/main.ld $(COMMON_O) main.o $(GCC_LIB)
	$(LD) $(LDFLAGS) -T $^ -o $@

picorv32.mem: main.bin
	bin2coe --width 32 -i $< -o $@ --mem

biriscv.mem: main.bin
	bin2coe --width 64 -i $< -o $@ --mem
