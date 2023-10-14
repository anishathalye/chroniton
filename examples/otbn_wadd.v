module otbn_wadd;

otbn_tb tb();

initial begin
    $dumpfile("otbn_wadd.vcd");
    $dumpvars(0, tb);
    $readmemh("software/wadd/main.text.mem", tb.soc.otbn.u_imem.u_mem.gen_generic.u_impl_generic.mem);
    $readmemh("software/wadd/main.data.mem", tb.soc.otbn.u_dmem.u_mem.gen_generic.u_impl_generic.mem);
end

endmodule
