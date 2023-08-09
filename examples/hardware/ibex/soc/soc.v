/* verilator lint_off PINMISSING */

`timescale 1 ns / 1 ps

module soc #(
    parameter ROM_ADDR_BITS = 12,
    parameter RAM_ADDR_BITS = 17,
    parameter FRAM_ADDR_BITS = 20
) (
    input clk,
    input resetn,
    input [7:0] gpio_pin_in,
    output [7:0] gpio_pin_out
);

wire mem_valid;
wire mem_instr;
wire mem_ready;
wire [31:0] mem_addr;
wire [31:0] mem_wdata;
wire [3:0] mem_wstrb;
wire data_we_o;
wire [3:0] data_be_o;
wire [31:0] mem_rdata;

assign mem_wstrb = !data_we_o ? 4'b0000 : data_be_o;

wire instr_req_o;
wire [31:0] instr_addr_o;
wire instr_rvalid_i;
wire [31:0] instr_rdata_i;

// CPU
ibex_top #(
    .PMPEnable (1),
    .ResetAllOnStart (1)
) cpu (
    .clk_i (clk),
    .rst_ni (resetn),
    .test_en_i (0),
    .scan_rst_ni (1),
    .ram_cfg_i (0), // default

    .hart_id_i (32'h0),
    .boot_addr_i (32'h0),

    .instr_req_o (instr_req_o),
    .instr_gnt_i (instr_rvalid_i),
    .instr_rvalid_i (instr_rvalid_reg),
    .instr_addr_o (instr_addr_o),
    .instr_rdata_i (instr_rdata_reg),
    .instr_err_i (0),

    .data_req_o (mem_valid),
    .data_gnt_i (mem_ready),
    .data_rvalid_i (mem_ready_reg),
    .data_we_o (data_we_o),
    .data_be_o (data_be_o),
    .data_addr_o (mem_addr),
    .data_wdata_o (mem_wdata),
    .data_rdata_i (mem_rdata_reg),
    .data_err_i (0),

    .irq_software_i         (0),
    .irq_timer_i            (0),
    .irq_external_i         (0),
    .irq_fast_i             (0),
    .irq_nm_i               (0),

    .debug_req_i            (0),

    .fetch_enable_i         (4'b0101),
);

/* delay results by one cycle */
reg [31:0] instr_rdata_reg;
reg instr_rvalid_reg;
reg [31:0] mem_rdata_reg;
reg mem_ready_reg;

always @(posedge clk) begin
    if (!resetn) begin
        instr_rdata_reg <= 32'h0;
        instr_rvalid_reg <= 0;
        mem_rdata_reg <= 32'h0;
        mem_ready_reg <= 0;
    end else begin
        instr_rdata_reg <= instr_rdata_i;
        instr_rvalid_reg <= instr_rvalid_i;
        mem_rdata_reg <= mem_rdata;
        mem_ready_reg <= mem_ready;
    end
end

// ROM
wire instr_valid = instr_req_o && instr_addr_o[31:16] == 16'h0000;
wire [31:0] instr_rdata;
wire instr_ready;
wire rom_valid = mem_valid && mem_addr[31:16] == 16'h0000;
wire [31:0] rom_rdata;
wire rom_ready;
rom #(
    .ADDR_BITS (ROM_ADDR_BITS)
) rom (
    .clk (clk),

    .valid1 (instr_valid),
    .addr1 (instr_addr_o),
    .dout1 (instr_rdata),
    .ready1 (instr_ready),

    .valid2 (rom_valid),
    .addr2 (mem_addr),
    .dout2 (rom_rdata),
    .ready2 (rom_ready)
);
// instruction memory inputs
assign instr_rvalid_i = (instr_valid && instr_ready);
assign instr_rdata_i =
    (instr_valid && instr_ready) ? instr_rdata :
    32'h 0000_0000;

wire fram_valid;
wire fram_ready;
wire [31:0] fram_rdata;
// "FRAM"
assign fram_valid = mem_valid && mem_addr[31:24] == 8'h10;
fram #(
    .ADDR_BITS (FRAM_ADDR_BITS)
) fram (
    .clk (clk),
    .resetn (resetn),
    .valid (fram_valid),
    .addr (mem_addr),
    .din (mem_wdata),
    .wstrb (mem_wstrb),
    .dout (fram_rdata),
    .ready (fram_ready)
);

// RAM
wire ram_valid = mem_valid && mem_addr[31:24] == 8'h20;
wire [31:0] ram_rdata;
wire ram_ready;
ram #(
    .ADDR_BITS (RAM_ADDR_BITS)
) ram (
    .clk (clk),
    .resetn (resetn),
    .valid (ram_valid),
    .addr (mem_addr),
    .din (mem_wdata),
    .wstrb (mem_wstrb),
    .dout (ram_rdata),
    .ready (ram_ready)
);

// GPIO
wire gpio_ready;
wire gpio_sel;
wire [31:0] gpio_rdata;
gpio #(
    .ADDR(32'h4000_0000)
) gpio (
    .clk (clk),
    .resetn (resetn),
    .mem_valid (mem_valid),
    .mem_addr (mem_addr),
    .mem_wdata (mem_wdata),
    .mem_wstrb (mem_wstrb),
    .gpio_ready (gpio_ready),
    .gpio_sel (gpio_sel),
    .gpio_rdata (gpio_rdata),
    .gpio_pin_in (gpio_pin_in),
    .gpio_pin_out (gpio_pin_out)
);

// memory inputs
assign mem_ready = (rom_valid && rom_ready) ||
    (fram_valid && fram_ready) ||
    (ram_valid && ram_ready) ||
    (gpio_sel && gpio_ready);
assign mem_rdata = (rom_valid && rom_ready) ? rom_rdata :
    (fram_valid && fram_ready) ? fram_rdata :
    (ram_valid && ram_ready) ? ram_rdata :
    (gpio_sel) ? gpio_rdata :
    32'h 0000_0000;

endmodule
