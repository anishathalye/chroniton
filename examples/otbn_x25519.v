module otbn_x25519;

otbn_tb tb();

initial begin
    $dumpfile("otbn_x25519.vcd");
    $dumpvars(0, tb.soc.otbn.u_otbn_core.u_otbn_instruction_fetch.insn_fetch_resp_addr_q);
    $dumpvars(0, tb.tb_common.cycle_count);
    $dumpvars(0, tb.clk);
    $readmemh("software/x25519/main.text.mem", tb.soc.otbn.u_imem.u_mem.gen_generic.u_impl_generic.mem);
    $readmemh("software/x25519/main.data.mem", tb.soc.otbn.u_dmem.u_mem.gen_generic.u_impl_generic.mem);
end

always @(posedge tb.clk) begin
    if (tb.tb_common.cycle_count % 1000 == 0) begin
        $display("cycle %d, resp_addr_q = 0x%x", tb.tb_common.cycle_count, tb.soc.otbn.u_otbn_core.u_otbn_instruction_fetch.insn_fetch_resp_addr_q);
    end
end

endmodule
