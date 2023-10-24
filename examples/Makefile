.PHONY: all
all:
	$(MAKE) -C hardware/picorv32/
	$(MAKE) -C hardware/ibex/
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
	$(MAKE) -C hardware/ibex/ clean
	$(MAKE) -C hardware/biriscv/ clean
	$(MAKE) -C hardware/otbn/ clean
	$(MAKE) -C software/mul64/ clean
	$(MAKE) -C software/branch-padding/ clean
	$(MAKE) -C software/ed25519/ clean
	$(MAKE) -C software/wadd/ clean
	$(MAKE) -C software/x25519/ clean
	rm -rf *.vvp *.vcd

IVERILOG := iverilog
IVERILOG_FLAGS := -g2012 -v -DIVERILOG

PICORV32_V := hardware/picorv32/*.v hardware/picorv32/soc/*.v hardware/common/picorv32_tb.v hardware/common/tb_common.v

picorv32_%.vvp: picorv32_%.v $(PICORV32_V)
	$(IVERILOG) $(IVERILOG_FLAGS) -o $@ $^

IBEX_V := hardware/ibex/combined.v hardware/common/ibex_tb.v hardware/common/tb_common.v

ibex_%.vvp: ibex_%.v $(IBEX_V)
	$(IVERILOG) $(IVERILOG_FLAGS) -Ihardware/ibex/soc/ibex -DSYNTHESIS -DYOSYS -o $@ $^

BIRISCV_V := hardware/biriscv/*.v hardware/biriscv/core/*.v hardware/common/biriscv_tb.v hardware/common/tb_common.v

biriscv_%.vvp: biriscv_%.v $(BIRISCV_V)
	$(IVERILOG) $(IVERILOG_FLAGS) -Ihardware/biriscv/core -o $@ $^

OTBN_V := hardware/otbn/combined.v hardware/common/otbn_tb.v hardware/common/tb_common.v

otbn_%.vvp: otbn_%.v $(OTBN_V)
	$(IVERILOG) $(IVERILOG_FLAGS) -Ihardware/otbn/soc/otbn -DSYNTHESIS -DYOSYS -o $@ $^
