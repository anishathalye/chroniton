module biriscv_ed25519;

biriscv_tb tb();

initial begin
    $dumpfile("biriscv_ed25519.vcd");
    $dumpvars(0, tb.biriscv.u_dut.u_exec0.pc_x_q);
    $dumpvars(0, tb.biriscv.u_dut.u_exec1.pc_x_q);
    $dumpvars(0, tb.tb_common.cycle_count);
    $dumpvars(0, tb.clk);
    $readmemh("software/ed25519/64bit.mem", tb.biriscv.u_mem.u_rom.ram);
end

always @(posedge tb.clk) begin
    if (tb.tb_common.cycle_count % 100000 == 0) begin
        $display("cycle %d, exec0.pc_x_q = 0x%x", tb.tb_common.cycle_count, tb.biriscv.u_dut.u_exec0.pc_x_q);
    end
end

endmodule
