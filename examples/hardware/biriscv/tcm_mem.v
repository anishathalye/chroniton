
module tcm_mem
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           mem_i_rd_i
    ,input           mem_i_flush_i
    ,input           mem_i_invalidate_i
    ,input  [ 31:0]  mem_i_pc_i
    ,input  [ 31:0]  mem_d_addr_i
    ,input  [ 31:0]  mem_d_data_wr_i
    ,input           mem_d_rd_i
    ,input  [  3:0]  mem_d_wr_i
    ,input           mem_d_cacheable_i
    ,input  [ 10:0]  mem_d_req_tag_i
    ,input           mem_d_invalidate_i
    ,input           mem_d_writeback_i
    ,input           mem_d_flush_i
    ,input  [  7:0]  gpio_pin_in_i

    // Outputs
    ,output          mem_i_accept_o
    ,output          mem_i_valid_o
    ,output          mem_i_error_o
    ,output [ 63:0]  mem_i_inst_o
    ,output [ 31:0]  mem_d_data_rd_o
    ,output          mem_d_accept_o
    ,output          mem_d_ack_o
    ,output          mem_d_error_o
    ,output [ 10:0]  mem_d_resp_tag_o
    ,output [  7:0]  gpio_pin_out_o
);

//-------------------------------------------------------------
// ROM, RAM, "FRAM", GPIO
//-------------------------------------------------------------
wire mem_req_w = (mem_d_rd_i || mem_d_wr_i != 4'b0 || mem_d_flush_i || mem_d_invalidate_i || mem_d_writeback_i);
wire rom_sel_w = mem_req_w && mem_d_addr_i[31:24] == 8'h00;
wire        muxed_hi_w   = mem_d_addr_i[2];
wire [63:0] rom_data_r_w;

tcm_mem_rom_2p
u_rom
(
    // Instruction fetch
     .clk0_i(clk_i)
    ,.addr0_i(mem_i_pc_i[16:3])

    // External access / Data access
    ,.clk1_i(clk_i)
    ,.addr1_i(rom_sel_w ? mem_d_addr_i[16:3] : 14'h0)

    // Outputs
    ,.data0_o(mem_i_inst_o)
    ,.data1_o(rom_data_r_w)
);

// "FRAM"
wire fram_sel_w = mem_req_w && mem_d_addr_i[31:24] == 8'h10;
wire [63:0] fram_data_r_w;

tcm_mem_ram_1p
u_fram
(
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.addr_i(fram_sel_w ? mem_d_addr_i[16:3] : 14'h0)
    ,.data_i(fram_sel_w ? (muxed_hi_w ? {mem_d_data_wr_i, 32'b0} : {32'b0, mem_d_data_wr_i}) : 64'h0)
    ,.wr_i(fram_sel_w ? (muxed_hi_w ? {mem_d_wr_i, 4'b0} : {4'b0, mem_d_wr_i}) : 8'b0)

    // Outputs
    ,.data_o(fram_data_r_w)
);

// RAM
wire ram_sel_w = mem_req_w && mem_d_addr_i[31:24] == 8'h20;
wire [63:0] ram_data_r_w;

tcm_mem_ram_1p
u_ram
(
    .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.addr_i(ram_sel_w ? mem_d_addr_i[16:3] : 14'h0)
    ,.data_i(ram_sel_w ? (muxed_hi_w ? {mem_d_data_wr_i, 32'b0} : {32'b0, mem_d_data_wr_i}) : 64'h0)
    ,.wr_i(ram_sel_w ? (muxed_hi_w ? {mem_d_wr_i, 4'b0} : {4'b0, mem_d_wr_i}) : 8'b0)

    // Outputs
    ,.data_o(ram_data_r_w)
);

// GPIO
wire gpio_sel_w;
wire [31:0] gpio_rdata_w;

gpio #(.ADDR(32'h4000_0000))
u_gpio
(
     .clk(clk_i)
    ,.resetn(!rst_i)
    ,.mem_valid(mem_req_w)
    ,.mem_addr(mem_d_addr_i)
    ,.mem_wdata(mem_d_data_wr_i)
    ,.mem_wstrb(mem_d_wr_i)
    ,.gpio_sel(gpio_sel_w)
    ,.gpio_rdata(gpio_rdata_w)
    ,.gpio_pin_in(gpio_pin_in_i)
    ,.gpio_pin_out(gpio_pin_out_o)
);

reg rom_sel_q;
reg fram_sel_q;
reg ram_sel_q;
reg gpio_sel_q;
always @(posedge clk_i) begin
    if (rst_i) begin
        rom_sel_q <= 1'b0;
        fram_sel_q <= 1'b0;
        ram_sel_q <= 1'b0;
        gpio_sel_q <= 1'b0;
    end else begin
        rom_sel_q <= rom_sel_w;
        fram_sel_q <= fram_sel_w;
        ram_sel_q <= ram_sel_w;
        gpio_sel_q <= gpio_sel_w;
    end
end

wire [63:0] data_r_w = rom_sel_q ? rom_data_r_w :
                       fram_sel_q ? fram_data_r_w :
                       ram_sel_q ? ram_data_r_w :
                       gpio_sel_q ? {gpio_rdata_w, gpio_rdata_w} :
                       64'h0;

reg muxed_hi_q;

always @ (posedge clk_i )
if (rst_i)
    muxed_hi_q <= 1'b0;
else
    muxed_hi_q <= muxed_hi_w;

//-------------------------------------------------------------
// Instruction Fetch
//-------------------------------------------------------------
reg        mem_i_valid_q;

always @ (posedge clk_i )
if (rst_i)
    mem_i_valid_q <= 1'b0;
else
    mem_i_valid_q <= mem_i_rd_i;

assign mem_i_accept_o  = 1'b1;
assign mem_i_valid_o   = mem_i_valid_q;
assign mem_i_error_o   = 1'b0;

//-------------------------------------------------------------
// Data Access / Incoming external access
//-------------------------------------------------------------
reg        mem_d_accept_q;
reg        mem_d_ack_q;
reg [10:0] mem_d_tag_q;

always @ (posedge clk_i )
if (rst_i)
begin
    mem_d_ack_q    <= 1'b0;
    mem_d_tag_q    <= 11'b0;
end
else if ((mem_d_rd_i || mem_d_wr_i != 4'b0 || mem_d_flush_i || mem_d_invalidate_i || mem_d_writeback_i) && mem_d_accept_o)
begin
    mem_d_ack_q    <= 1'b1;
    mem_d_tag_q    <= mem_d_req_tag_i;
end
else
    mem_d_ack_q    <= 1'b0;

assign mem_d_ack_o          = mem_d_ack_q;
assign mem_d_resp_tag_o     = mem_d_tag_q;
assign mem_d_data_rd_o      = muxed_hi_q ? data_r_w[63:32] : data_r_w[31:0];
assign mem_d_error_o        = 1'b0;

assign mem_d_accept_o       = 1'b1;

endmodule
