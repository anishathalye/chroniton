module ibex_branch_padding;

ibex_tb tb();

initial begin
    $dumpfile("ibex_branch_padding.vcd");
    $dumpvars(0, tb);
    $readmemh("software/branch-padding/32bit.mem", tb.hsm.soc.rom.rom);
end

endmodule
