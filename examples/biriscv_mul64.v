module biriscv_mul64;

biriscv_tb tb();

initial begin
    $dumpfile("biriscv_mul64.vcd");
    $dumpvars(0, tb);
    $readmemh("software/mul64/64bit.mem", tb.biriscv.u_mem.u_rom.ram);
end

endmodule
