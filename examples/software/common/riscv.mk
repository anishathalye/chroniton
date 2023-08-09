MAKEFLAGS += -r
MAKEFLAGS += -R

COMMON_O := ../common/vectors.o ../common/startup.o ../common/drivers.o

.PHONY: clean
clean:
	rm -rf $(CLEAN_FILES)

ifndef PREFIX
PREFIX := $(shell if riscv64-unknown-elf-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-unknown-elf-'; \
	elif riscv64-linux-gnu-objdump -i 2>&1 | grep 'elf64-big' >/dev/null 2>&1; \
	then echo 'riscv64-linux-gnu-'; \
	else echo "***" 1>&2; \
	echo "*** Error: Couldn't find an riscv64 version of GCC/binutils." 1>&2; \
	echo "*** To turn off this error, run 'make PREFIX= ...'." 1>&2; \
	echo "***" 1>&2; exit 1; fi)
endif

CC := $(PREFIX)gcc
AS := $(PREFIX)as
LD := $(PREFIX)ld
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump

CFLAGS := -std=gnu18 -O2 -march=rv32im -mabi=ilp32 -fdata-sections -ffunction-sections -ffreestanding -g
ASFLAGS := -march=rv32im -mabi=ilp32
OBJDUMPFLAGS := --disassemble-all --source --section-headers --demangle
LDFLAGS := --gc-sections -melf32lriscv -nostdlib

GCC_LIB := $(shell $(CC) $(CFLAGS) -print-libgcc-file-name)

HOSTCXX := g++
HOSTCXXFLAGS := -std=c++17 -O2

HEADERFILES := $(shell find ../common -name '*.h')

%.bin: %.elf
	$(OBJCOPY) $< -O binary $@

%.o: %.s $(HEADERFILES)
	$(AS) $(ASFLAGS) -c $< -o $@

%.o: %.S $(HEADERFILES)
	$(CC) $(ASFLAGS) -c $< -o $@

%.o: %.c $(HEADERFILES)
	$(CC) $(CFLAGS) -c $< -o $@

%.lst: %.elf
	$(OBJDUMP) $(OBJDUMPFLAGS) $< > $@
