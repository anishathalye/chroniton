module picorv32_tb;

wire clk;
wire resetn;
wire [7:0] gpio_pin_in;
wire [7:0] gpio_pin_out;

tb_common tb_common(
    .clk,
    .resetn,
    .gpio_pin_in,
    .gpio_pin_out
);

hsm hsm(
    .clk,
    .resetn,
    .gpio_pin_in,
    .gpio_pin_out
);

initial begin
    integer i;
    for (i = 0; i < 1024; i++) begin
        hsm.soc.ram.ram[i] = 32'h0;
        hsm.soc.fram.fram[i] = 32'h0;
    end
end

endmodule
