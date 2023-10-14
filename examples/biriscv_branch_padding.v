module biriscv_branch_padding;

biriscv_tb tb();

initial begin
    $dumpfile("biriscv_branch_padding.vcd");
    $dumpvars(0, tb);
    $readmemh("software/branch-padding/64bit.mem", tb.biriscv.u_mem.u_rom.ram);
end

endmodule
