/* verilator lint_off PINMISSING */

`timescale 1 ns / 1 ps

module soc #(
    parameter FIRMWARE_FILE = "system.mem"
) (
    input clk,
    input resetn,
    output status_idle,
    input start_cmd,
    output done
);

wire rnd_valid = 1;
wire [255:0] rnd_data = 0;
wire [255:0] urnd_data = 0;

otbn otbn(
    .clk_i (clk),
    .rst_ni (resetn),
    .status_idle,
    .start_cmd,
    .done,
    .rnd_valid,
    .rnd_data,
    .urnd_data
);

endmodule
