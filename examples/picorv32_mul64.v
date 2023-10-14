module picorv32_mul64;

picorv32_tb tb();

initial begin
    $dumpfile("picorv32_mul64.vcd");
    $dumpvars(0, tb);
    $readmemh("software/mul64/32bit.mem", tb.hsm.soc.rom.rom);
end

endmodule
