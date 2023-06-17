MAKEFLAGS += -r
MAKEFLAGS += -R

.PHONY: clean
clean:
	rm -rf $(CLEAN_FILES)

OTBN_AS := otbn_as.py
OTBN_LD := otbn_ld.py
OTBN_OBJDUMP := otbn_objdump.py

OBJDUMPFLAGS := --disassemble-all --source --section-headers --demangle

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

OBJCOPY := $(PREFIX)objcopy

%.o: %.s
	$(OTBN_AS) $< -o $@

%.text.bin: %.elf
	$(OBJCOPY) $< -O binary --only-section .text $@

%.data.bin: %.elf
	$(OBJCOPY) $< -O binary --only-section .data $@

%.text.mem: %.text.bin
	bin2coe --width 32 -i $< -o $@ --mem

%.data.mem: %.data.bin
	bin2coe --width 256 -i $< -o $@ --mem

%.lst: %.elf
	$(OTBN_OBJDUMP) $(OBJDUMPFLAGS) $< > $@
