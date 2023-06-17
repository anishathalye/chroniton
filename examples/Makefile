.PHONY: all
all:
	$(MAKE) -C hardware/picorv32/
	$(MAKE) -C hardware/biriscv/
	$(MAKE) -C hardware/otbn/
	$(MAKE) -C software/mul64/
	$(MAKE) -C software/branch-padding/
	$(MAKE) -C software/ed25519/
	$(MAKE) -C software/wadd/
	$(MAKE) -C software/x25519/

.PHONY: clean
clean:
	$(MAKE) -C hardware/picorv32/ clean
	$(MAKE) -C hardware/biriscv/ clean
	$(MAKE) -C hardware/otbn/ clean
	$(MAKE) -C software/mul64/ clean
	$(MAKE) -C software/branch-padding/ clean
	$(MAKE) -C software/ed25519/ clean
	$(MAKE) -C software/wadd/ clean
	$(MAKE) -C software/x25519/ clean
