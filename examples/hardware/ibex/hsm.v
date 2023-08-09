module hsm #(
    parameter ROM_ADDR_BITS = 17, // 128K ROM
    parameter RAM_ADDR_BITS = 12, // 4K RAM
    parameter FRAM_ADDR_BITS = 12 // 4k FRAM
) (
    input clk,
    input resetn,
    input [7:0] gpio_pin_in,
    output [7:0] gpio_pin_out
);

soc #(
    .ROM_ADDR_BITS (ROM_ADDR_BITS),
    .RAM_ADDR_BITS (RAM_ADDR_BITS),
    .FRAM_ADDR_BITS (FRAM_ADDR_BITS)
) soc (
    .clk,
    .resetn,
    .gpio_pin_in,
    .gpio_pin_out
);

endmodule
