module ibex_mul64;

ibex_tb tb();

initial begin
    $dumpfile("ibex_mul64.vcd");
    $dumpvars(0, tb);
    $readmemh("software/mul64/32bit.mem", tb.hsm.soc.rom.rom);
end

endmodule
