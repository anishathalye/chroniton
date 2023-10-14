module ibex_ed25519;

ibex_tb tb();

initial begin
    $dumpfile("ibex_ed25519.vcd");
    $dumpvars(0, tb.hsm.soc.cpu.u_ibex_core.pc_id);
    $dumpvars(0, tb.tb_common.cycle_count);
    $dumpvars(0, tb.clk);
    $readmemh("software/ed25519/32bit.mem", tb.hsm.soc.rom.rom);
end

always @(posedge tb.clk) begin
    if (tb.tb_common.cycle_count % 100000 == 0) begin
        $display("cycle %d, pc_id = 0x%x", tb.tb_common.cycle_count, tb.hsm.soc.cpu.u_ibex_core.pc_id);
    end
end

endmodule
