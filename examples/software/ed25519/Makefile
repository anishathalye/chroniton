.PHONY: all
all: picorv32.mem biriscv.mem

include ../common/riscv.mk

CLEAN_FILES += *.o *.bin *.coe *.lst *.elf *.mem ../common/*.o ed25519/*.o

ED25519_LIB := $(patsubst %.c, %.o, $(shell find ed25519 -name '*.c'))
CFLAGS += -I../common/

main.elf: ../common/main.ld $(COMMON_O) main.o $(ED25519_LIB) $(GCC_LIB)
	$(LD) $(LDFLAGS) -T $^ -o $@

picorv32.mem: main.bin
	bin2coe --width 32 -i $< -o $@ --mem

biriscv.mem: main.bin
	bin2coe --width 64 -i $< -o $@ --mem
