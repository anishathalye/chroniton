module biriscv_tb;

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

biriscv biriscv(
    .clk,
    .rst (!resetn),
    .gpio_pin_in,
    .gpio_pin_out
);

initial begin
    integer i;
    for (i = 0; i < 512; i++) begin
        biriscv.u_mem.u_ram.ram[i] = 64'h0;
        biriscv.u_mem.u_fram.ram[i] = 64'h0;
    end
end

endmodule
