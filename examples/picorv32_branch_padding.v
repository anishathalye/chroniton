module picorv32_branch_padding;

picorv32_tb tb();

initial begin
    $dumpfile("picorv32_branch_padding.vcd");
    $dumpvars(0, tb);
    $readmemh("software/branch-padding/32bit.mem", tb.hsm.soc.rom.rom);
end

endmodule
